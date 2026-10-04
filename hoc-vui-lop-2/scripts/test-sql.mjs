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
await db.exec(read('supabase/migrations/0005_guest_students.sql'));
await db.exec(read('supabase/migrations/0005_guest_students.sql'));
await db.exec(read('supabase/migrations/0006_learning_rules.sql'));
await db.exec(read('supabase/migrations/0006_learning_rules.sql'));
await db.exec(read('supabase/migrations/0007_guest_sees_all.sql'));
await db.exec(read('supabase/migrations/0007_guest_sees_all.sql'));
// Giờ làm bài và giới hạn mỗi ngày được kiểm riêng ở nhóm 8d.
await db.query(`update app_settings set schedule_enabled = false, daily_max_lessons = 0 where id = 1`);

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
assert.equal(att.scoring.mode, 'ranked');
assert.equal(att.scoring.wrong_penalty, 1);
assert.deepEqual(att.questions.map((q) => q.points), att.questions.map((q) => q.difficulty), 'bài cơ bản: dễ 1, vừa 2, khó 3 điểm');
let expectedScore = 0;
for (const [i, q] of att.questions.entries()) {
  let ans = await answerFor(q);
  if (q.type === 'text') ans = '  ĐANG   Nằm. ';
  if (q.type === 'number' && i === 0) ans = '0' + ans;
  if (i === 1) ans = '999';
  const r = await rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: q.id, p_answer: ans });
  if (i === 1) {
    assert.equal(r.is_correct, false);
    assert.equal(r.score_awarded, -1, 'sai trừ 1 điểm');
    expectedScore -= 1;
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
assert.equal(res.max_score, 15);
assert.equal(res.points_lost, 1);
assert.equal(res.points_gained, expectedScore + 1);
await expectError(rpc('submit_answer', { p_attempt_id: att.attempt_id, p_question_id: att.questions[1].id, p_answer: '1' }), 'attempt_completed');
ok(`hoàn thành bài: 9/10 đúng, ${expectedScore} điểm`);

// 6. Lượt 2 không tính xếp hạng
const att2 = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: lesson.id, p_exercise_type: 'basic' });
assert.notEqual(att2.attempt_id, att.attempt_id);
assert.equal(att2.is_ranked, false);
assert.equal(att2.scoring.mode, 'per_correct');
assert.ok(att2.questions.every((q) => q.points === 1));
for (const q of att2.questions) {
  const r = await rpc('submit_answer', { p_attempt_id: att2.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
  assert.equal(r.score_awarded, 1, 'làm lại: mỗi câu đúng 1 sao');
}
const res2 = await rpc('finish_attempt', { p_attempt_id: att2.attempt_id });
assert.equal(res2.correct_count, 10);
assert.equal(res2.is_ranked, false);
assert.equal(res2.score, 10);
assert.equal(res2.max_score, 10);
ok('lượt làm lại không cộng điểm xếp hạng, mỗi câu đúng được 1 sao');

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

// 8c. Bạn khách (0005, 0007): tên có dấu "-" => bạn trong lớp không thấy bạn khách; bạn khách (và admin) thấy tất cả
{
  assert.equal((await one(`select public.is_guest_name('Tiểu Nguyên - Khoai') a, public.is_guest_name('Nguyễn Minh Anh') b`)).a, true);
  const guest = await rpc('register_student', { p_full_name: 'Tiểu Nguyên - Khoai' });
  const gAtt = await rpc('start_attempt', { p_student_id: guest.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' });
  for (const q of gAtt.questions) {
    await rpc('submit_answer', { p_attempt_id: gAtt.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
  }
  const gRes = await rpc('finish_attempt', { p_attempt_id: gAtt.attempt_id });
  assert.equal(gRes.is_ranked, true);
  const ids = (lb) => lb.rows.map((r) => r.student_id);

  const asAdmin = await rpc('get_subject_leaderboard', { p_period: 'day' });
  assert.ok(ids(asAdmin).includes(guest.id), 'admin thấy bạn khách');
  assert.equal(asAdmin.rows.find((r) => r.student_id === guest.id).is_guest, true);
  const adminViaStudentPage = await rpc('get_leaderboard', { p_period: 'day', p_student_id: s1.id });
  assert.ok(!ids(adminViaStudentPage).includes(guest.id), 'trang học sinh (có p_student_id) vẫn ẩn bạn khách dù máy đang đăng nhập admin');

  await db.query(`select set_config('demo.uid', '', false)`);
  for (const fn of ['get_leaderboard', 'get_subject_leaderboard']) {
    const classView = await rpc(fn, { p_period: 'day', p_student_id: s1.id });
    assert.ok(!ids(classView).includes(guest.id), `${fn}: bạn trong lớp không thấy bạn khách`);
    assert.deepEqual(classView.rows.map((r) => r.rank), classView.rows.map((_, i) => i + 1), 'hạng của lớp liền mạch, không chừa chỗ cho bạn khách');
    const anonView = await rpc(fn, { p_period: 'day' });
    assert.ok(!ids(anonView).includes(guest.id), `${fn}: khách vãng lai không thấy bạn khách`);
    const guestView = await rpc(fn, { p_period: 'day', p_student_id: guest.id });
    assert.ok(ids(guestView).includes(guest.id), `${fn}: bạn khách thấy chính mình`);
    assert.equal(guestView.me.score, gRes.score);
    for (const id of ids(classView)) assert.ok(ids(guestView).includes(id), `${fn}: bạn khách thấy cả các bạn trong lớp`);
    assert.equal(guestView.rows.length, classView.rows.length + 1);
  }
  const other = await rpc('register_student', { p_full_name: 'Bạn Khác – Lớp Bên' });
  const oAtt = await rpc('start_attempt', { p_student_id: other.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' });
  for (const q of oAtt.questions) await rpc('submit_answer', { p_attempt_id: oAtt.attempt_id, p_question_id: q.id, p_answer: await answerFor(q) });
  await rpc('finish_attempt', { p_attempt_id: oAtt.attempt_id });
  const g2 = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id, p_student_id: guest.id });
  assert.ok(ids(g2).includes(other.id), 'bạn khách thấy cả bạn khách khác (thấy tất cả mọi người)');
  const o2 = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id, p_student_id: other.id });
  assert.deepEqual(ids(o2), ids(g2), 'mọi bạn khách thấy cùng một bảng đầy đủ');
  const s2Tv = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id, p_student_id: s2.id });
  assert.ok(!ids(s2Tv).includes(guest.id) && !ids(s2Tv).includes(other.id), 'bạn trong lớp vẫn không thấy bạn khách nào');
  assert.ok(g2.rows.length > s2Tv.rows.length);

  const tvClass = await rpc('get_subject_leaderboard', { p_period: 'day', p_subject_id: tv.id, p_student_id: s2.id });
  assert.equal(tvClass.me.rank, 1, 'bạn khách điểm bằng/cao hơn cũng không đẩy hạng bạn trong lớp xuống');
  const homeS2 = await rpc('get_student_home', { p_student_id: s2.id });
  const homeG = await rpc('get_student_home', { p_student_id: guest.id });
  assert.equal(homeG.points.day, gRes.score, 'trang chủ bạn khách có điểm');
  assert.ok(homeG.ranks.day >= 1, 'trang chủ bạn khách có hạng');
  const guestDay = await rpc('get_leaderboard', { p_period: 'day', p_student_id: guest.id });
  assert.equal(homeG.ranks.day, guestDay.me.rank, 'hạng trên trang chủ bạn khách khớp bảng đầy đủ bạn ấy thấy');
  const classDay = await rpc('get_leaderboard', { p_period: 'day', p_student_id: s2.id });
  assert.equal(homeS2.ranks.day, classDay.me.rank, 'hạng trên trang chủ khớp bảng xếp hạng của lớp');

  await db.query(`select set_config('demo.uid', $1, false)`, [uid]);
  await db.query(`update students set is_active = false where id = any($1)`, [[guest.id, other.id]]);
}
ok('bạn khách (tên có dấu "-"): thấy bảng xếp hạng của tất cả; bạn trong lớp chỉ thấy bạn trong lớp');

// 8d. Luật học tập (0006): làm lại kiểu "cặp", điểm không âm, sao/kim cương, giới hạn mỗi ngày, cài đặt môn, giờ làm bài, huy chương
{
  const answerAll = async (a, wrongIdx = []) => {
    for (const [i, q] of a.questions.entries()) {
      const ans = wrongIdx.includes(i) ? 'sai-roi' : await answerFor(q);
      await rpc('submit_answer', { p_attempt_id: a.attempt_id, p_question_id: q.id, p_answer: ans });
    }
    return rpc('finish_attempt', { p_attempt_id: a.attempt_id });
  };
  const weekBefore = (await rpc('get_leaderboard', { p_period: 'week', p_student_id: s1.id })).me.score;

  // Làm lại kiểu "cặp": 7 đúng / 3 sai => 3 - 1 = 2 sao, không đổi bảng xếp hạng
  await db.query(`update app_settings set retake_mode = 'pair' where id = 1`);
  const pr = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: lesson.id, p_exercise_type: 'basic' });
  assert.equal(pr.scoring.mode, 'pair');
  assert.ok(pr.questions.every((q) => q.points === null));
  const prRes = await answerAll(pr, [0, 1, 2]);
  assert.equal(prRes.score, 2);
  assert.equal(prRes.points_gained, 3);
  assert.equal(prRes.points_lost, 1);
  assert.equal((await rpc('get_leaderboard', { p_period: 'week', p_student_id: s1.id })).me.score, weekBefore, 'làm lại không đổi BXH');
  await db.query(`update app_settings set retake_mode = 'per_correct' where id = 1`);

  // Bài lần đầu sai hết: điểm không âm (tuỳ chọn tắt thì được âm)
  const l3 = await one(`insert into lessons (subject_id, week_number, lesson_order, name, is_published) values ($1, 1, 3, 'Luyện thêm', true) returning id`, [subj.id]);
  for (let i = 0; i < 10; i++) await db.query(qIns, [l3.id, 1, 'number', `${i} + 2 = ?`, null, null, null, null, String(i + 2), null]);
  const z = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: l3.id, p_exercise_type: 'basic' });
  const zRes = await answerAll(z, [...Array(10).keys()]);
  assert.equal(zRes.is_ranked, true);
  assert.equal(zRes.score, 0, 'sai hết vẫn 0 điểm, không âm');
  assert.equal(zRes.points_lost, 10);
  await db.query(`update app_settings set score_floor_zero = false where id = 1`);
  assert.equal((await one(`select public.rescore_attempt($1) v`, [z.attempt_id])).v, -10);
  await db.query(`update app_settings set score_floor_zero = true where id = 1`);
  assert.equal((await one(`select public.rescore_attempt($1) v`, [z.attempt_id])).v, 0);

  // Sao / kim cương: 1 điểm = 1 sao, cộng cả lần làm lại
  const totalStars = Number((await one(`select sum(score) v from attempts where student_id = $1 and completed_at is not null`, [s1.id])).v);
  assert.equal(totalStars, expectedScore + 10 + 2);
  await db.query(`update app_settings set stars_per_diamond = 5 where id = 1`);
  let rw = await rpc('student_rewards', { p_student_id: s1.id });
  assert.equal(rw.stars_total, totalStars);
  assert.equal(rw.diamonds, Math.floor(totalStars / 5));
  assert.equal(rw.stars, totalStars % 5);
  await db.query(`update app_settings set stars_per_diamond = 100 where id = 1`);

  // Giới hạn số đề mỗi ngày (tính cả làm lại) + cài đặt riêng của môn
  await db.query(`update app_settings set daily_max_lessons = 3 where id = 1`);
  await expectError(rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: l3.id, p_exercise_type: 'basic' }), 'daily_limit_reached');
  let h = await rpc('get_student_home', { p_student_id: s1.id });
  assert.deepEqual([h.daily.toan.used, h.daily.toan.max], [3, 3]);
  assert.equal(h.daily.tieng_viet.used, 0);
  await db.query(`insert into subject_settings (subject_id, daily_max_lessons, basic_easy, basic_normal, basic_advanced, points_easy)
                  values ($1, 5, 2, 0, 0, 5)`, [subj.id]);
  h = await rpc('get_student_home', { p_student_id: s1.id });
  assert.deepEqual([h.daily.toan.max, h.daily.toan.basic_count, h.daily.tieng_viet.max], [5, 2, 3], 'môn Toán có cài đặt riêng, môn khác theo cài đặt chung');
  const ov = await rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: l3.id, p_exercise_type: 'basic' });
  assert.equal(ov.questions.length, 2, 'số câu theo cài đặt môn');
  assert.ok(ov.questions.every((q) => q.points === 5), 'điểm theo cài đặt môn');
  const ovRes = await answerAll(ov);
  assert.equal(ovRes.score, 10);
  await db.query(`update attempts set score = 0 where id = $1`, [ov.attempt_id]);
  await db.query(`delete from subject_settings where subject_id = $1`, [subj.id]);
  await db.query(`update app_settings set daily_max_lessons = 0 where id = 1`);

  // Giờ làm bài: đóng thì không bắt đầu đề mới được, đề đang làm dở vẫn tiếp tục
  const open = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' });
  await db.query(`update app_settings set schedule_enabled = true, schedule = '{}' where id = 1`);
  let sch = await rpc('schedule_status');
  assert.deepEqual([sch.enabled, sch.open, sch.next_open_at], [true, false, null]);
  await expectError(rpc('start_attempt', { p_student_id: s1.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' }), 'closed_hours');
  const resumed = await rpc('start_attempt', { p_student_id: s2.id, p_lesson_id: tvLesson.id, p_exercise_type: 'basic' });
  assert.equal(resumed.attempt_id, open.attempt_id, 'hết giờ vẫn làm tiếp bài dở');
  const allDay = Object.fromEntries([1, 2, 3, 4, 5, 6, 7].map((d) => [String(d), ['00:00', '24:00']]));
  const todayDow = Number((await one(`select extract(isodow from now() at time zone 'Asia/Ho_Chi_Minh')::int d`)).d);
  delete allDay[String(todayDow)];
  await db.query(`update app_settings set schedule = $1 where id = 1`, [JSON.stringify(allDay)]);
  sch = await rpc('schedule_status');
  const tomorrow = (await one(`select (((now() at time zone 'Asia/Ho_Chi_Minh')::date + 1)::timestamp at time zone 'Asia/Ho_Chi_Minh') t`)).t;
  assert.equal(sch.open, false);
  assert.equal(new Date(sch.next_open_at).getTime(), new Date(tomorrow).getTime(), 'mở lại lúc 0:00 hôm sau');
  allDay[String(todayDow)] = ['00:00', '24:00'];
  await db.query(`update app_settings set schedule = $1 where id = 1`, [JSON.stringify(allDay)]);
  sch = await rpc('schedule_status');
  assert.equal(sch.open, true);
  assert.ok(new Date(sch.closes_at) > new Date(Date.now() + 6 * 86400e3), 'các ngày mở cả ngày nối liền nhau');
  await db.query(`update app_settings set schedule_enabled = false where id = 1`);
  await rpc('finish_attempt', { p_attempt_id: open.attempt_id });

  // Huy chương tuần: điểm lần đầu đề tuần 1 (cơ bản) / điểm tối đa của tất cả đề tuần 1
  // Toán Ôn tập 6/3/1 câu => 6 + 6 + 3 = 15; Chính tả 10 câu dễ => 10; Luyện thêm 10 câu dễ => 10
  const medalOf = async (sid) => (await db.query(`select * from public.weekly_medals(public.week_start_of(now()), $1)`, [sid])).rows[0];
  let m1 = await medalOf(s1.id);
  assert.equal(Number(m1.max_score), 35);
  assert.equal(Number(m1.score), expectedScore);
  assert.equal(Number(m1.pct), Math.round((1000 * expectedScore) / 35) / 10);
  assert.equal(m1.medal, 'encourage');
  await db.query(`update app_settings set medal_bronze_pct = 30 where id = 1`);
  assert.equal((await medalOf(s1.id)).medal, 'bronze');
  await db.query(`update app_settings set medal_bronze_pct = 60 where id = 1`);
  rw = await rpc('student_rewards', { p_student_id: s1.id });
  assert.equal(rw.this_week.medal, 'encourage');
  assert.equal(rw.last_week, null);
  const s3 = await rpc('register_student', { p_full_name: 'Phạm Bảo Châu' });
  const rw3 = await rpc('student_rewards', { p_student_id: s3.id });
  assert.deepEqual([rw3.this_week.score, rw3.this_week.max_score, rw3.this_week.medal], [0, 35, null], 'chưa làm bài vẫn thấy tiến độ 0%');
  assert.equal(rw3.medal_eligible, true);

  // Bạn khách (tên có dấu "-") không xét huy chương nhưng vẫn có sao
  const s1Name = (await one(`select full_name from students where id = $1`, [s1.id])).full_name;
  await db.query(`update students set full_name = full_name || ' - Khách' where id = $1`, [s1.id]);
  assert.equal(await medalOf(s1.id), undefined, 'bạn khách không có huy chương');
  const rwGuest = await rpc('student_rewards', { p_student_id: s1.id });
  assert.deepEqual([rwGuest.medal_eligible, rwGuest.this_week, rwGuest.last_week], [false, null, null]);
  assert.equal(rwGuest.stars_total, totalStars, 'bạn khách vẫn có sao');
  assert.ok(!(await rpc('admin_weekly_medals')).rows.some((r) => r.student_id === s1.id), 'admin không thấy bạn khách trong bảng huy chương');
  await db.query(`update students set full_name = $2 where id = $1`, [s1.id, s1Name]);

  // Tuần trước: admin đặt tuần học cho tuần lịch, bài làm tuần trước được tính huy chương tuần trước
  await expectError(rpc('admin_set_week_class', { p_week_start: '2026-01-05', p_class_week: 99 }), 'invalid_week');
  const prevWeek = (await one(`select (public.week_start_of(now()) - 7)::text d`)).d;
  await rpc('admin_set_week_class', { p_week_start: prevWeek, p_class_week: 1 });
  await db.query(`update attempts set completed_at = completed_at - interval '7 days' where id = $1`, [att.attempt_id]);
  rw = await rpc('student_rewards', { p_student_id: s1.id });
  assert.equal(rw.last_week.medal, 'encourage');
  assert.deepEqual(rw.medal_counts, { encourage: 1 });
  const adm = await rpc('admin_weekly_medals', { p_week_start: prevWeek });
  assert.equal(adm.class_week, 1);
  assert.equal(adm.is_current, false);
  assert.deepEqual(adm.rows.map((r) => r.student_id), [s1.id]);
  assert.ok(adm.weeks.length >= 2);
  await db.query(`update attempts set completed_at = completed_at + interval '7 days' where id = $1`, [att.attempt_id]);
  await db.query(`update students set is_active = false where id = $1`, [s3.id]);

  await db.query(`select set_config('demo.uid', '', false)`);
  await expectError(rpc('admin_weekly_medals'), 'not_admin');
  await expectError(rpc('admin_set_week_class', { p_week_start: prevWeek, p_class_week: 2 }), 'not_admin');
  await db.query(`select set_config('demo.uid', $1, false)`, [uid]);
}
ok('luật 0006: làm lại kiểu cặp, điểm không âm, sao/kim cương, giới hạn mỗi ngày, cài đặt môn, giờ làm bài, huy chương tuần');

// 9. Quyền của anon (kiểm tra GRANT/RLS)
const grants = await db.query(`
  select has_table_privilege('anon', 'public.questions', 'select') as q,
         has_function_privilege('anon', 'public.submit_answer(uuid,uuid,text)', 'execute') as sa,
         has_function_privilege('anon', 'public.admin_dashboard()', 'execute') as ad,
         has_function_privilege('anon', 'public.leaderboard_rows(text)', 'execute') as lr,
         has_function_privilege('anon', 'public.leaderboard_rows_by(text,uuid)', 'execute') as lrb,
         has_function_privilege('anon', 'public.get_subject_leaderboard(text,uuid,uuid)', 'execute') as gsl,
         has_function_privilege('anon', 'public.admin_subject_stats(text)', 'execute') as ass,
         has_function_privilege('anon', 'public.leaderboard_rows_for(text,uuid,uuid,boolean)', 'execute') as lrf,
         has_function_privilege('anon', 'public.get_leaderboard(text,uuid)', 'execute') as gl,
         has_function_privilege('anon', 'public.get_student_home(uuid)', 'execute') as gsh,
         has_function_privilege('anon', 'public.start_attempt(uuid,uuid,text,text)', 'execute') as st,
         has_function_privilege('anon', 'public.finish_attempt(uuid)', 'execute') as fa,
         has_function_privilege('anon', 'public.get_attempt_result(uuid)', 'execute') as gar,
         has_function_privilege('anon', 'public.rescore_attempt(uuid)', 'execute') as rsc,
         has_function_privilege('anon', 'public.effective_settings(uuid)', 'execute') as es,
         has_function_privilege('anon', 'public.student_rewards(uuid)', 'execute') as srw,
         has_function_privilege('anon', 'public.weekly_medals(date,uuid)', 'execute') as wm,
         has_function_privilege('anon', 'public.admin_weekly_medals(date)', 'execute') as awm,
         has_function_privilege('anon', 'public.admin_set_week_class(date,int)', 'execute') as asw,
         has_function_privilege('authenticated', 'public.admin_weekly_medals(date)', 'execute') as awm_auth,
         has_table_privilege('anon', 'public.subject_settings', 'select') as ss,
         has_table_privilege('anon', 'public.week_log', 'select') as wl,
         (select relrowsecurity from pg_class where oid = 'public.subject_settings'::regclass) as ss_rls,
         (select relrowsecurity from pg_class where oid = 'public.questions'::regclass) as rls`);
assert.deepEqual(grants.rows[0], {
  q: false, sa: true, ad: false, lr: false, lrb: false, gsl: true, ass: false, lrf: false, gl: true, gsh: true,
  st: true, fa: true, gar: true, rsc: false, es: false, srw: false, wm: false, awm: false, asw: false, awm_auth: true,
  ss: false, wl: false, ss_rls: true, rls: true,
});
ok('anon không đọc được bảng câu hỏi, chỉ gọi được API học sinh');

if (existsSync(new URL('supabase/seed.sql', root))) {
  const fresh = new PGlite();
  await fresh.exec(read('supabase/demo/supabase_stubs.sql'));
  await fresh.exec(read('supabase/migrations/0001_init.sql'));
  await fresh.exec(read('supabase/migrations/0003_student_birthday.sql'));
  await fresh.exec(read('supabase/migrations/0004_subject_stats.sql'));
  await fresh.exec(read('supabase/migrations/0005_guest_students.sql'));
  await fresh.exec(read('supabase/migrations/0006_learning_rules.sql'));
  await fresh.exec(read('supabase/migrations/0007_guest_sees_all.sql'));
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

// 10. Nâng cấp DB đang chạy lên 0006: đổi thang điểm 10/15/25 → 1/2/3 và tính lại điểm cũ đúng 1 lần
{
  const up = new PGlite();
  await up.exec(read('supabase/demo/supabase_stubs.sql'));
  for (const f of ['0001_init', '0003_student_birthday', '0004_subject_stats', '0005_guest_students']) {
    await up.exec(read(`supabase/migrations/${f}.sql`));
  }
  const q1 = async (sql, params) => (await up.query(sql, params)).rows[0];
  const call = async (fn, args) => {
    const keys = Object.keys(args);
    return (await q1(`select public.${fn}(${keys.map((k, i) => `${k} => $${i + 1}`).join(', ')}) as r`, keys.map((k) => args[k]))).r;
  };
  const sj = await q1(`insert into subjects (code, name) values ('toan', 'Toán') returning id`);
  const ls = await q1(`insert into lessons (subject_id, week_number, lesson_order, name, is_published) values ($1, 1, 1, 'Bài 1', true) returning id`, [sj.id]);
  for (const [d, n] of [[1, 6], [2, 3], [3, 1]]) {
    for (let i = 0; i < n; i++) {
      await up.query(`insert into questions (lesson_id, difficulty, question_type, question_text, correct_answer) values ($1, $2, 'number', $3, $4)`,
        [ls.id, d, `${d}-${i}`, String(d * 10 + i)]);
    }
  }
  const st = await call('register_student', { p_full_name: 'Đỗ Đăng Khoa' });
  const runAttempt = async (wrongFirst) => {
    const a = await call('start_attempt', { p_student_id: st.id, p_lesson_id: ls.id, p_exercise_type: 'basic' });
    for (const [i, q] of a.questions.entries()) {
      const c = (await q1(`select correct_answer from questions where id = $1`, [q.id])).correct_answer;
      await call('submit_answer', { p_attempt_id: a.attempt_id, p_question_id: q.id, p_answer: wrongFirst && i === 0 ? 'x' : c });
    }
    return call('finish_attempt', { p_attempt_id: a.attempt_id });
  };
  const old1 = await runAttempt(true);
  const old2 = await runAttempt(false);
  assert.equal(old1.score, 5 * 10 + 3 * 15 + 25, 'trước 0006: thang 10/15/25, sai không trừ');
  assert.equal(old2.score, 6 * 10 + 3 * 15 + 25);

  const m6 = read('supabase/migrations/0006_learning_rules.sql');
  await up.exec(m6);
  const scoreOf = async (id) => (await q1(`select score from attempts where id = $1`, [id])).score;
  assert.equal(await scoreOf(old1.attempt_id), 5 + 6 + 3 - 1, 'lượt đầu tính lại: đúng 1/2/3, sai trừ 1');
  assert.equal(await scoreOf(old2.attempt_id), 10, 'lượt làm lại tính lại: mỗi câu đúng 1 sao');
  const set1 = await q1(`select points_easy, points_normal, points_advanced, rules_version from app_settings`);
  assert.deepEqual(set1, { points_easy: 1, points_normal: 2, points_advanced: 3, rules_version: 6 });

  await up.query(`update app_settings set points_easy = 2 where id = 1`);
  await up.exec(m6);
  assert.equal((await q1(`select points_easy from app_settings`)).points_easy, 2, 'chạy lại 0006 không ghi đè cài đặt admin đã sửa');
  assert.equal(await scoreOf(old1.attempt_id), 13, 'chạy lại 0006 không tính lại điểm lần nữa');
  await up.close();
}
ok('nâng cấp lên 0006: đổi thang điểm và tính lại điểm cũ đúng 1 lần');

console.log(`\nTất cả ${passed} nhóm kiểm thử đều ĐẠT.`);
