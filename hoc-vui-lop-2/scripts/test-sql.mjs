// Kiểm thử logic database (chấm điểm, xếp hạng, chống cày điểm...) bằng PGlite.
// Chạy: npm run test:sql
import { PGlite } from '@electric-sql/pglite';
import { readFileSync, existsSync } from 'node:fs';
import assert from 'node:assert/strict';

const root = new URL('..', import.meta.url);
const read = (p) => readFileSync(new URL(p, root), 'utf8');

const db = new PGlite();
await db.exec(read('supabase/demo/supabase_stubs.sql'));
await db.exec(read('supabase/migrations/0001_init.sql'));
await db.exec(read('supabase/migrations/0003_student_birthday.sql'));
await db.exec(read('supabase/migrations/0004_subject_stats.sql'));
await db.exec(read('supabase/migrations/0004_subject_stats.sql'));

const rpc = async (fn, args = {}) => {
  const keys = Object.keys(args);
  const sql = `select public.${fn}(${keys.map((k, i) => `${k} => $${i + 1}`).join(', ')}) as r`;
  const res = await db.query(sql, keys.map((k) => args[k]));
  return res.rows[0].r;
};
const expectError = async (p, code) => {
  await assert.rejects(p, (e) => String(e.message).includes(code), `expected error ${code}`);
};

let passed = 0;
const ok = (name) => { passed++; console.log('  ✓', name); };

// --- helpers
const one = async (sql, params) => (await db.query(sql, params)).rows[0];

// 1. Hàm tiện ích
assert.equal((await one(`select public.default_display_name('Nguyễn  Minh Anh') v`)).v, 'Minh Anh');
assert.equal((await one(`select public.default_display_name('An') v`)).v, 'An');
assert.equal((await one(`select public.normalize_name('  ĐỖ   Đăng KHOA ') v`)).v, 'đỗ đăng khoa');
assert.equal((await one(`select public.normalize_answer(' Nằm. ') v`)).v, 'nằm');
assert.equal((await one(`select public.normalize_answer(' . ') v`)).v, '.');
assert.equal((await one(`select public.normalize_answer('?') v`)).v, '?');
assert.equal((await one(`select public.normalize_answer('Ồ!') v`)).v, 'ồ');
assert.equal((await one(`select public.normalize_number(' 1.000 ') v`)).v, '1000');
assert.equal((await one(`select public.normalize_number('08') v`)).v, '8');
assert.equal((await one(`select public.normalize_number('abc') v`)).v, null);
ok('hàm chuẩn hóa tên/đáp án');

// 2. Dữ liệu mẫu
const subj = await one(`insert into subjects (code, name) values ('toan','Toán') returning id`);
const lesson = await one(
  `insert into lessons (subject_id, week_number, lesson_order, name, is_published) values ($1, 1, 1, 'Ôn tập', true) returning id`,
  [subj.id]);
const hidden = await one(
  `insert into lessons (subject_id, week_number, lesson_order, name, is_published) values ($1, 9, 30, 'Tuần sau', true) returning id`,
  [subj.id]);
const qIns = `insert into questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers)
              values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) returning id`;
for (let i = 0; i < 8; i++) {
  await db.query(qIns, [lesson.id, 1, 'number', `${i} + 1 = ?`, null, null, null, null, String(i + 1), null]);
}
for (let i = 0; i < 4; i++) {
  await db.query(qIns, [lesson.id, 2, 'multiple_choice', `${10 + i} + 10 = ?`, String(20 + i), String(21 + i), String(19 + i), null, String(20 + i), null]);
}
for (let i = 0; i < 3; i++) {
  await db.query(qIns, [lesson.id, 3, 'text', `Con mèo đang ___ (${i})`, null, null, null, null, 'nằm', JSON.stringify(['đang nằm'])]);
}
await db.query(qIns, [hidden.id, 1, 'number', '1+1', null, null, null, null, '2', null]);
ok('tạo dữ liệu mẫu');

// 3. Học sinh
const cfg = await rpc('get_public_config');
assert.equal(cfg.current_week, 1);
const s1 = await rpc('register_student', { p_full_name: 'Nguyễn Minh Anh' });
const s1b = await rpc('register_student', { p_full_name: '  nguyễn   minh ANH ' });
assert.equal(s1.id, s1b.id, 'không tạo trùng học sinh');
assert.equal(s1.display_name, 'Minh Anh');
const s2 = await rpc('register_student', { p_full_name: 'Trần Gia Huy' });
await expectError(rpc('register_student', { p_full_name: '<script>' }), 'invalid_name');
await expectError(rpc('register_student', { p_full_name: '123' }), 'invalid_name');
const list = await rpc('list_students');
assert.equal(list.length, 2);
await db.query(`update app_settings set allow_self_register = false`);
await expectError(rpc('register_student', { p_full_name: 'Người Lạ' }), 'self_register_disabled');
assert.equal((await rpc('register_student', { p_full_name: 'Trần Gia Huy' })).id, s2.id, 'tên có sẵn vẫn vào được');
await db.query(`update app_settings set allow_self_register = true`);
ok('đăng ký / chọn học sinh, chống trùng tên');

// 3b. Xác nhận ngày sinh (0003)
{
  const v0 = await rpc('verify_student', { p_student_id: s2.id, p_day: 1, p_month: 1 });
  assert.equal(v0.ok, true, 'chưa có ngày sinh thì vào thẳng');
  const kid = await one(`insert into students (full_name, birth_date) values ('Lê Ngọc Thảo Chi', '2019-03-05') returning id`);
  const listed = (await rpc('list_students')).find((s) => s.id === kid.id);
  assert.equal(listed.needs_birthday, true);
  assert.ok(!JSON.stringify(await rpc('list_students')).includes('2019'), 'không lộ ngày sinh ra danh sách');
  assert.equal((await rpc('list_students')).find((s) => s.id === s2.id).needs_birthday, false);
  await expectError(rpc('register_student', { p_full_name: 'lê ngọc thảo chi' }), 'student_exists');

  const good = await rpc('verify_student', { p_student_id: kid.id, p_day: 5, p_month: 3 });
  assert.equal(good.ok, true);
  assert.equal(good.student.display_name, 'Thảo Chi');
  assert.ok(!JSON.stringify(good).includes('2019'), 'không trả ngày sinh về');

  let bad;
  for (let i = 1; i <= 4; i++) {
    bad = await rpc('verify_student', { p_student_id: kid.id, p_day: 3, p_month: 5 });
    assert.equal(bad.ok, false);
    assert.equal(bad.remaining, 5 - i);
  }
  bad = await rpc('verify_student', { p_student_id: kid.id, p_day: 3, p_month: 5 });
  assert.equal(bad.locked_seconds, 300, 'sai 5 lần thì khoá 5 phút');
  const whileLocked = await rpc('verify_student', { p_student_id: kid.id, p_day: 5, p_month: 3 });
  assert.equal(whileLocked.ok, false, 'đang khoá thì nhập đúng cũng chưa vào được');
  assert.ok(whileLocked.locked_seconds > 0);

  await db.query(`update students set verify_locked_until = now() - interval '1 second' where id = $1`, [kid.id]);
  bad = await rpc('verify_student', { p_student_id: kid.id, p_day: 3, p_month: 5 });
  assert.equal(bad.remaining, 4, 'hết khoá thì đếm lại từ đầu');
  assert.equal((await rpc('verify_student', { p_student_id: kid.id, p_day: 5, p_month: 3 })).ok, true);
  assert.equal((await one(`select verify_fails from students where id = $1`, [kid.id])).verify_fails, 0, 'đúng thì xoá số lần sai');

  const stats = await one(`select birth_date::text as b from v_student_stats where id = $1`, [kid.id]);
  assert.equal(stats.b, '2019-03-05');
  await db.query(`delete from students where id = $1`, [kid.id]);
}
ok('xác nhận ngày sinh: không lộ ngày sinh, chống đoán, chặn gõ lại tên để vào thẳng');

// 4. Trang chủ: chỉ thấy bài đã mở
let home = await rpc('get_student_home', { p_student_id: s1.id });
assert.equal(home.lessons.length, 1, 'bài tuần 9 chưa hiện khi đang tuần 1');
assert.equal(home.lessons[0].question_count, 15);
assert.equal(home.basic_count, 10);
ok('trang chủ lọc bài theo tuần hiện tại');

// 5. Làm bài
const att = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: lesson.id, p_exercise_type: 'basic', p_device_token: 'dev1' });
assert.equal(att.questions.length, 10);
assert.equal(att.is_ranked, true);
const diffs = att.questions.map((q) => q.difficulty);
assert.deepEqual([...diffs].sort(), diffs, 'câu dễ trước, khó sau');
assert.equal(diffs.filter((d) => d === 1).length, 6);
assert.equal(diffs.filter((d) => d === 2).length, 3);
assert.equal(diffs.filter((d) => d === 3).length, 1);
assert.ok(!JSON.stringify(att).includes('correct_answer'), 'không lộ đáp án khi bắt đầu');
const mcq = att.questions.find((q) => q.type === 'multiple_choice');
assert.ok(Array.isArray(mcq.options) && mcq.options.length === 3);
await expectError(rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: hidden.id }), 'lesson_not_available');
ok('bắt đầu bài: đủ số câu, đúng tỉ lệ độ khó, không lộ đáp án');

// Resume
const attAgain = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: lesson.id, p_exercise_type: 'basic' });
assert.equal(attAgain.attempt_id, att.attempt_id, 'tiếp tục lượt đang làm dở');
ok('tiếp tục lượt làm dở');

// Trả lời: đúng hết trừ 1 câu
const answerFor = async (q) => {
  const row = await one(`select correct_answer from questions where id = $1`, [q.id]);
  return row.correct_answer;
};
let expectedScore = 0;
for (const [i, q] of att.questions.entries()) {
  let ans = await answerFor(q);
  if (q.type === 'text') ans = '  ĐANG   Nằm. ';
  if (q.type === 'number' && i === 0) ans = '0' + ans;
  if (i === 1) ans = '999';
  const r = await rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: q.id, p_answer: ans });
  if (i === 1) {
    assert.equal(r.is_correct, false);
  } else {
    assert.equal(r.is_correct, true, `câu ${i} (${q.type}) phải đúng`);
    expectedScore += q.points;
  }
}
const dup = await rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: att.questions[1].id, p_answer: 'đổi ý' });
assert.equal(dup.is_correct, false, 'không cho trả lời lại câu đã nộp');
const foreignQ = await one(`select id from questions where lesson_id = $1`, [hidden.id]);
await expectError(rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: foreignQ.id, p_answer: '2' }), 'question_not_in_attempt');
ok('chấm điểm phía server (số, chữ, trắc nghiệm), không sửa được đáp án đã nộp');

const res = await rpc('finish_attempt', { p_attempt_id: att.attempt_id });
assert.equal(res.completed, true);
assert.equal(res.correct_count, 9);
assert.equal(res.wrong_count, 1);
assert.equal(res.score, expectedScore);
assert.equal(res.review.length, 10);
assert.equal(res.is_ranked, true);
await expectError(rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: att.questions[1].id, p_answer: '1' }), 'attempt_completed');
ok(`hoàn thành bài: 9/10 đúng, ${expectedScore} điểm`);

// 6. Lượt 2 không tính xếp hạng
const att2 = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: lesson.id, p_exercise_type: 'basic' });
assert.notEqual(att2.attempt_id, att.attempt_id);
assert.equal(att2.is_ranked, false);
for (const q of att2.questions) {
  await rpc('submit_answer', { p_attempt_id: att2.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
}
const res2 = await rpc('finish_attempt', { p_attempt_id: att2.attempt_id });
assert.equal(res2.correct_count, 10);
assert.equal(res2.is_ranked, false);
ok('lượt làm lại chỉ để luyện tập, không cộng điểm xếp hạng');

// Hai lượt "xếp hạng" chạy song song: chỉ lượt hoàn thành đầu tiên được tính
const a3 = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: lesson.id, p_exercise_type: 'advanced' });
await db.query(`update attempts set started_at = now() - interval '4 hours' where id = $1`, [a3.attempt_id]);
const a4 = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: lesson.id, p_exercise_type: 'advanced' });
assert.equal(a3.is_ranked && a4.is_ranked, true);
assert.equal(a4.questions.filter((q) => q.difficulty === 3).length, 3, 'nâng cao lấy tối đa câu khó có sẵn');
for (const q of a4.questions) {
  await rpc('submit_answer', { p_attempt_id: a4.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
}
const r4 = await rpc('finish_attempt', { p_attempt_id: a4.attempt_id });
const r3 = await rpc('finish_attempt', { p_attempt_id: a3.attempt_id });
assert.equal(r4.is_ranked, true);
assert.equal(r3.is_ranked, false);
ok('chống cày điểm khi mở nhiều lượt cùng lúc');

// 7. Bảng xếp hạng
for (const period of ['day', 'week', 'month']) {
  const lb = await rpc('get_leaderboard', { p_period: period, p_student_id: s1.id });
  assert.equal(lb.enabled, true);
  assert.equal(lb.rows.length, 2);
  const me = lb.rows.find((r) => r.student_id === s1.id);
  assert.equal(me.score, expectedScore);
  assert.equal(lb.me.score, expectedScore);
}
const lbDay = await rpc('get_leaderboard', { p_period: 'day' });
assert.equal(lbDay.rows[0].rank, 1);
assert.ok(lbDay.rows[0].score >= lbDay.rows[1].score);
await expectError(rpc('get_leaderboard', { p_period: 'year' }), 'invalid_period');
// Điểm của hôm qua không nằm trong bảng "Hôm nay"
await db.query(`update attempts set completed_at = now() - interval '2 days' where id = $1`, [r4.attempt_id]);
const lbDay2 = await rpc('get_leaderboard', { p_period: 'day' });
assert.equal(lbDay2.rows.length, 1);
home = await rpc('get_student_home', { p_student_id: s1.id });
assert.equal(home.points.day, expectedScore);
assert.equal(home.ranks.day, 1);
assert.equal(home.lessons[0].basic_correct, '9/10');
ok('bảng xếp hạng ngày / tuần / tháng');

// 7b. Xếp hạng theo môn (0004)
const tv = await one(`insert into subjects (code, name, sort_order) values ('tieng_viet','Tiếng Việt', 2) returning id`);
const tvLesson = await one(
  `insert into lessons (subject_id, week_number, lesson_order, name, is_published) values ($1, 1, 1, 'Chính tả', true) returning id`,
  [tv.id]);
for (let i = 0; i < 10; i++) {
  await db.query(qIns, [tvLesson.id, 1, 'number', `Có mấy chữ cái trong từ số ${i}?`, null, null, null, null, String(i + 2), null]);
}
const tvAtt = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' });
for (const q of tvAtt.questions) {
  await rpc('submit_answer', { p_attempt_id: tvAtt.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
}
const tvRes = await rpc('finish_attempt', { p_attempt_id: tvAtt.attempt_id });
assert.equal(tvRes.is_ranked, true);

const lbAll = await rpc('get_subject_leaderboard', { p_period: 'day', p_student_id: s1.id });
assert.equal(lbAll.subject_id, null);
assert.deepEqual(lbAll.subjects.map((x) => x.code), ['toan', 'tieng_viet']);
assert.deepEqual(lbAll.rows.map((r) => r.student_id).sort(), [s1.id, s2.id].sort(), 'Tất cả môn: cộng điểm mọi môn');
const lbOld = await rpc('get_leaderboard', { p_period: 'day' });
assert.deepEqual(lbOld.rows, lbAll.rows, 'get_leaderboard cũ và tab "Tất cả" phải khớp nhau');

const lbTv = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id, p_student_id: s1.id });
assert.equal(lbTv.rows.length, 1);
assert.equal(lbTv.rows[0].student_id, s2.id);
assert.equal(lbTv.rows[0].score, tvRes.score);
assert.equal(lbTv.rows[0].accuracy, 100);
assert.equal(lbTv.me, null, 'chưa làm môn này thì chưa có hạng');

const lbToan = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: subj.id, p_student_id: s1.id });
assert.deepEqual(lbToan.rows.map((r) => r.student_id), [s1.id]);
assert.equal(lbToan.me.score, expectedScore);
assert.equal(lbToan.me.rank, 1);

await expectError(rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: '00000000-0000-0000-0000-000000000123' }), 'subject_not_found');
await expectError(rpc('get_subject_leaderboard', { p_period: 'year' }), 'invalid_period');
await db.query(`update app_settings set leaderboard_enabled = false where id = 1`);
const lbOff = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id });
assert.equal(lbOff.enabled, false);
assert.equal(lbOff.rows.length, 0);
assert.equal(lbOff.subjects.length, 2);
await db.query(`update app_settings set leaderboard_enabled = true where id = 1`);
await expectError(rpc('admin_subject_stats', { p_period: 'week' }), 'not_admin');
ok('bảng xếp hạng theo từng môn + tab "Tất cả" khớp bảng cũ');

// 8. Quyền admin
await expectError(rpc('admin_dashboard'), 'not_admin');
const uid = '00000000-0000-0000-0000-00000000a001';
await db.query(`insert into auth.users (id, email) values ($1, 'admin@demo')`, [uid]);
await db.query(`insert into admins (user_id) values ($1)`, [uid]);
await db.query(`select set_config('demo.uid', $1, false)`, [uid]);
const dash = await rpc('admin_dashboard');
assert.equal(dash.total_students, 2);
assert.ok(dash.today.attempts_completed >= 3);
const vq = await db.query(`select * from v_questions where lesson_id = $1`, [lesson.id]);
assert.equal(vq.rows.length, 15);
const vl = await one(`select * from v_lessons where id = $1`, [lesson.id]);
assert.equal(Number(vl.question_count), 15);
ok('admin dashboard + view thống kê');

// 8b. Thống kê theo môn cho admin (0004)
const ssAll = await rpc('admin_subject_stats', { p_period: 'all' });
assert.equal(ssAll.start, null);
assert.equal(ssAll.total_students, 2);
const ssToan = ssAll.subjects.find((x) => x.code === 'toan');
const ssTv = ssAll.subjects.find((x) => x.code === 'tieng_viet');
assert.deepEqual(ssAll.subjects.map((x) => x.code), ['toan', 'tieng_viet']);
assert.equal(ssToan.attempts_completed, 4);
assert.equal(ssToan.active_students, 2);
assert.equal(ssToan.lesson_count, 2);
assert.equal(ssToan.question_count, 16);
assert.equal(ssTv.attempts_completed, 1);
assert.equal(ssTv.active_students, 1);
assert.equal(ssTv.accuracy, 100);
assert.equal(ssTv.ranked_score, tvRes.score);
const ssS1 = ssAll.students.find((x) => x.student_id === s1.id);
const ssS2 = ssAll.students.find((x) => x.student_id === s2.id);
assert.deepEqual(Object.keys(ssS1.by_subject), [subj.id], 'môn chưa làm thì không có số liệu');
assert.equal(ssS1.by_subject[subj.id].attempts, 2);
assert.equal(ssS1.by_subject[subj.id].score, expectedScore, 'chỉ cộng điểm lượt xếp hạng');
assert.equal(ssS2.by_subject[tv.id].accuracy, 100);
assert.ok(Array.isArray(ssAll.hardest));
const ssDay = await rpc('admin_subject_stats', { p_period: 'day' });
assert.ok(ssDay.start && ssDay.end);
assert.equal(ssDay.subjects.find((x) => x.code === 'toan').attempts_completed, 3, 'lượt làm hôm kia không tính vào hôm nay');
assert.equal(ssDay.students.find((x) => x.student_id === s2.id).by_subject[subj.id].score, 0);
await expectError(rpc('admin_subject_stats', { p_period: 'year' }), 'invalid_period');
ok('thống kê theo môn cho admin (môn, học sinh × môn, lọc thời gian)');

// 9. Quyền của anon (kiểm tra GRANT/RLS)
const grants = await db.query(`
  select has_table_privilege('anon', 'public.questions', 'select') as q,
         has_function_privilege('anon', 'public.submit_answer(uuid,uuid,text)', 'execute') as sa,
         has_function_privilege('anon', 'public.admin_dashboard()', 'execute') as ad,
         has_function_privilege('anon', 'public.leaderboard_rows(text)', 'execute') as lr,
         has_function_privilege('anon', 'public.leaderboard_rows_by(text,uuid)', 'execute') as lrb,
         has_function_privilege('anon', 'public.get_subject_leaderboard(text,uuid,uuid)', 'execute') as gsl,
         has_function_privilege('anon', 'public.admin_subject_stats(text)', 'execute') as ass,
         (select relrowsecurity from pg_class where oid = 'public.questions'::regclass) as rls`);
assert.deepEqual(grants.rows[0], { q: false, sa: true, ad: false, lr: false, lrb: false, gsl: true, ass: false, rls: true });
ok('anon không đọc được bảng câu hỏi, chỉ gọi được API học sinh');

if (existsSync(new URL('supabase/seed.sql', root))) {
  const fresh = new PGlite();
  await fresh.exec(read('supabase/demo/supabase_stubs.sql'));
  await fresh.exec(read('supabase/migrations/0001_init.sql'));
  await fresh.exec(read('supabase/migrations/0003_student_birthday.sql'));
  await fresh.exec(read('supabase/migrations/0004_subject_stats.sql'));
  await fresh.exec(read('supabase/seed.sql'));
  const c = (await fresh.query(`select (select count(*) from lessons) l, (select count(*) from questions) q, (select count(*) from students) s`)).rows[0];
  console.log(`  ✓ seed.sql chạy được: ${c.l} bài, ${c.q} câu hỏi, ${c.s} học sinh`);
  passed++;

  if (existsSync(new URL('supabase/archimes.sql', root))) {
    const archimesSql = read('supabase/archimes.sql');
    const countArchimes = async () => (await fresh.query(`
      select (select count(*) from lessons where lesson_order = 100) as l,
             (select count(*) from questions where generator_type = 'archimes') as q`)).rows[0];
    await fresh.exec(archimesSql);
    const a1 = await countArchimes();
    await fresh.exec(archimesSql);
    const a2 = await countArchimes();
    assert.deepEqual(a2, a1, 'chạy lại archimes.sql không được tạo trùng');
    if (Number(a1.q) > 0) {
      const bad = await fresh.query(`
        select q.id, q.question_text, q.correct_answer from questions q
         where (not public.check_answer(q, q.correct_answer)
                or (q.question_type = 'multiple_choice'
                    and q.correct_answer not in (coalesce(q.option_a, ''), coalesce(q.option_b, ''), coalesce(q.option_c, ''), coalesce(q.option_d, '')))
                or exists (select 1 from jsonb_array_elements_text(coalesce(q.accepted_answers, '[]'::jsonb)) x
                            where not public.check_answer(q, x)))`);
      assert.equal(bad.rows.length, 0, 'câu hỏi (mẫu/Archimes) chấm sai đáp án của chính nó: ' + JSON.stringify(bad.rows.slice(0, 3)));
      const thin = await fresh.query(`
        select l.week_number, l.name from lessons l
         where l.lesson_order = 100
           and ((select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 1) < 6
             or (select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 2) < 3
             or (select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 3) < 5)`);
      assert.equal(thin.rows.length, 0, 'bài Archimes thiếu câu cho đề Cơ bản/Nâng cao: ' + JSON.stringify(thin.rows));
    }
    console.log(`  ✓ archimes.sql chạy được, chạy lại không trùng: ${a1.l} bài, ${a1.q} câu hỏi, đáp án tự chấm đúng 100%`);
    passed++;
  }

  if (existsSync(new URL('supabase/ky_nang_khoa_hoc.sql', root))) {
    const kt = read('supabase/ky_nang_khoa_hoc.sql');
    const countKt = async () => (await fresh.query(`
      select s.code, count(distinct l.id)::int as l, count(q.id)::int as q
        from subjects s join lessons l on l.subject_id = s.id left join questions q on q.lesson_id = l.id
       where s.code in ('ky_nang_song', 'khoa_hoc') group by s.code order by s.code`)).rows;
    await fresh.exec(kt);
    const k1 = await countKt();
    await fresh.exec(kt);
    assert.deepEqual(await countKt(), k1, 'chạy lại ky_nang_khoa_hoc.sql không được tạo trùng');
    assert.equal(k1.length, 2, 'phải có 2 môn Kỹ năng sống và Khoa học');
    const badKt = await fresh.query(`
      select q.question_text, q.correct_answer from questions q join lessons l on l.id = q.lesson_id join subjects s on s.id = l.subject_id
       where s.code in ('ky_nang_song', 'khoa_hoc')
         and (not public.check_answer(q, q.correct_answer)
              or (q.question_type = 'multiple_choice'
                  and q.correct_answer not in (coalesce(q.option_a, ''), coalesce(q.option_b, ''), coalesce(q.option_c, ''), coalesce(q.option_d, '')))
              or exists (select 1 from jsonb_array_elements_text(coalesce(q.accepted_answers, '[]'::jsonb)) x where not public.check_answer(q, x)))`);
    assert.equal(badKt.rows.length, 0, 'câu Kỹ năng sống/Khoa học chấm sai đáp án của chính nó: ' + JSON.stringify(badKt.rows.slice(0, 3)));
    const thinKt = await fresh.query(`
      select s.code, l.week_number from lessons l join subjects s on s.id = l.subject_id
       where s.code in ('ky_nang_song', 'khoa_hoc')
         and ((select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 1) < 6
           or (select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 2) < 3
           or (select count(*) from questions q where q.lesson_id = l.id and q.difficulty = 3) < 5)`);
    assert.equal(thinKt.rows.length, 0, 'bài thiếu câu cho đề Cơ bản/Nâng cao: ' + JSON.stringify(thinKt.rows));
    console.log(`  ✓ ky_nang_khoa_hoc.sql chạy được, chạy lại không trùng: ${k1.map((r) => `${r.code} ${r.l} bài/${r.q} câu`).join(', ')}, đáp án tự chấm đúng 100%`);
    passed++;
  }

  // 0002: chấm lại câu "chọn dấu câu" từng bị chấm sai
  const pq = (await fresh.query(`select id, lesson_id from questions where correct_answer = '.' limit 1`)).rows[0];
  const st = (await fresh.query(`insert into students (full_name) values ('Lê Ngọc Thảo Chi') returning id`)).rows[0];
  const at = (await fresh.query(
    `insert into attempts (student_id, lesson_id, exercise_type, question_ids, total_questions, score, correct_count, wrong_count, is_ranked, completed_at)
     values ($1, $2, 'basic', array[$3::uuid], 1, 0, 0, 1, true, now()) returning id`, [st.id, pq.lesson_id, pq.id])).rows[0];
  await fresh.query(`insert into attempt_answers (attempt_id, question_id, student_answer, is_correct, score_awarded) values ($1, $2, '.', false, 0)`, [at.id, pq.id]);
  const fix = read('supabase/migrations/0002_fix_dau_cau.sql');
  await fresh.exec(fix);
  await fresh.exec(fix);
  const after = (await fresh.query(
    `select a.correct_count, a.wrong_count, a.score, aa.is_correct, aa.score_awarded,
            (select public.question_points(q, s) from questions q, app_settings s where q.id = $2 and s.id = 1) as pts
       from attempts a join attempt_answers aa on aa.attempt_id = a.id where a.id = $1`, [at.id, pq.id])).rows[0];
  assert.equal(after.is_correct, true);
  assert.equal(after.correct_count, 1);
  assert.equal(after.wrong_count, 0);
  assert.equal(after.score, after.pts);
  assert.equal(after.score_awarded, after.pts);
  await fresh.query(`delete from students where id = $1`, [st.id]);
  ok('0002_fix_dau_cau: chấm lại câu dấu câu và cập nhật điểm lượt làm');

  if (existsSync(new URL('supabase/demo/demo_data.sql', root))) {
    await fresh.exec(read('supabase/demo/demo_data.sql'));
    const d = (await fresh.query(`
      select count(*) filter (where completed_at is not null) as done,
             count(*) filter (where duration_seconds between 60 and 420) as timed,
             count(distinct student_id) as students
        from attempts`)).rows[0];
    assert.ok(Number(d.done) > 20, 'demo phải có bài làm');
    assert.equal(Number(d.timed), Number(d.done));
    console.log(`  ✓ demo_data.sql chạy được: ${d.done} lượt làm bài của ${d.students} học sinh`);
    passed++;
  }
}

console.log(`\nTất cả ${passed} nhóm kiểm thử đều ĐẠT.`);
