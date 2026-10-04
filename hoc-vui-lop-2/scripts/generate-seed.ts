// Sinh ngân hàng câu hỏi mẫu => supabase/seed.sql + data/*.csv + supabase/demo/demo_data.sql
// Chạy: npm run seed:generate
import { mkdirSync, writeFileSync } from 'node:fs';
import { createRng, generateBatch, getSkill, type GeneratedQuestion, type Skill } from '../src/lib/generators/index.ts';

interface LessonSeed {
  subject: 'toan' | 'tieng_viet';
  week: number;
  order: number;
  name: string;
  skills: string[];
}

const LESSONS: LessonSeed[] = [
  { subject: 'toan', week: 1, order: 1, name: 'Ôn tập các số đến 100', skills: ['so_den_100', 'so_sanh'] },
  { subject: 'toan', week: 1, order: 2, name: 'Tia số. Số liền trước, số liền sau', skills: ['lien_truoc_lien_sau', 'day_so'] },
  { subject: 'toan', week: 2, order: 3, name: 'Các thành phần của phép cộng, phép trừ', skills: ['thanh_phan_phep_tinh'] },
  { subject: 'toan', week: 2, order: 4, name: 'Hơn, kém nhau bao nhiêu', skills: ['hon_kem'] },
  { subject: 'toan', week: 3, order: 5, name: 'Ôn tập phép cộng, phép trừ (không nhớ) trong phạm vi 100', skills: ['cong_khong_nho_100', 'tru_khong_nho_100'] },
  { subject: 'toan', week: 3, order: 6, name: 'Luyện tập chung', skills: ['so_sanh', 'thanh_phan_phep_tinh', 'hon_kem', 'cong_khong_nho_100'] },
  { subject: 'toan', week: 4, order: 7, name: 'Phép cộng (qua 10) trong phạm vi 20', skills: ['cong_qua_10'] },
  { subject: 'toan', week: 4, order: 8, name: 'Bảng cộng (qua 10)', skills: ['cong_qua_10', 'so_sanh'] },
  { subject: 'toan', week: 5, order: 9, name: 'Bài toán về thêm, bớt một số đơn vị', skills: ['bai_toan_loi_van'] },
  { subject: 'toan', week: 5, order: 10, name: 'Luyện tập chung', skills: ['cong_qua_10', 'bai_toan_loi_van'] },
  { subject: 'toan', week: 6, order: 11, name: 'Phép trừ (qua 10) trong phạm vi 20', skills: ['tru_qua_10'] },
  { subject: 'toan', week: 6, order: 12, name: 'Bảng trừ (qua 10)', skills: ['tru_qua_10', 'thanh_phan_phep_tinh'] },
  { subject: 'toan', week: 7, order: 13, name: 'Bài toán về nhiều hơn, ít hơn một số đơn vị', skills: ['bai_toan_loi_van', 'hon_kem'] },
  { subject: 'toan', week: 7, order: 14, name: 'Luyện tập chung', skills: ['cong_qua_10', 'tru_qua_10'] },
  { subject: 'toan', week: 8, order: 15, name: 'Ki-lô-gam', skills: ['kg_lit'] },
  { subject: 'toan', week: 8, order: 16, name: 'Lít', skills: ['kg_lit'] },
  { subject: 'toan', week: 9, order: 17, name: 'Xăng-ti-mét, đề-xi-mét', skills: ['do_dai'] },
  { subject: 'toan', week: 10, order: 18, name: 'Phép cộng có nhớ trong phạm vi 100', skills: ['cong_co_nho_100'] },
  { subject: 'toan', week: 10, order: 19, name: 'Phép trừ có nhớ trong phạm vi 100', skills: ['tru_co_nho_100'] },
  { subject: 'tieng_viet', week: 1, order: 1, name: 'Bảng chữ cái tiếng Việt', skills: ['bang_chu_cai'] },
  { subject: 'tieng_viet', week: 1, order: 2, name: 'Chính tả: c hay k', skills: ['chinh_ta_c_k'] },
  { subject: 'tieng_viet', week: 2, order: 3, name: 'Từ chỉ sự vật, hoạt động, đặc điểm', skills: ['tu_su_vat_hoat_dong_dac_diem'] },
  { subject: 'tieng_viet', week: 2, order: 4, name: 'Chính tả: g hay gh', skills: ['chinh_ta_g_gh'] },
  { subject: 'tieng_viet', week: 3, order: 5, name: 'Dấu câu và kiểu câu', skills: ['dau_cau_kieu_cau'] },
  { subject: 'tieng_viet', week: 3, order: 6, name: 'Chính tả: ng hay ngh', skills: ['chinh_ta_ng_ngh'] },
  { subject: 'tieng_viet', week: 4, order: 7, name: 'Từ trái nghĩa', skills: ['tu_trai_nghia'] },
  { subject: 'tieng_viet', week: 4, order: 8, name: 'Chọn từ điền vào câu', skills: ['dien_tu_vao_cau', 'tu_su_vat_hoat_dong_dac_diem'] },
];

const COUNTS = { easy: 12, normal: 10, advanced: 8 };

const DEMO_STUDENTS = [
  'Nguyễn Minh Anh', 'Trần Gia Huy', 'Lê Hà My', 'Đỗ Đăng Khoa', 'Bùi Bảo Hân', 'Phạm Phúc An', 'Trịnh Thùy Linh',
  'Vũ Đức Trí', 'Hoàng Khánh Vy', 'Ngô Tuấn Kiệt', 'Đặng Ngọc Diệp', 'Phan Minh Khang', 'Võ Thảo Nhi', 'Dương Quốc Bảo',
  'Lý Mai Chi', 'Hồ Nhật Nam', 'Mai Tường Vi', 'Đinh Hoàng Long', 'Cao Bảo Ngọc', 'Tạ Anh Thư',
];

const sqlStr = (v: string | null | undefined) => (v === null || v === undefined || v === '' ? 'null' : `'${v.replace(/'/g, "''")}'`);
const csvCell = (v: string | number | null | undefined) => {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};

const rng = createRng(20260905);
const root = new URL('..', import.meta.url);
const sql: string[] = [];
const csvRows: string[] = [
  'subject,week,lesson,lesson_name,difficulty,type,question,option_a,option_b,option_c,option_d,answer,accepted_answers,explanation,skill_tag,source_page',
];

sql.push(`-- =====================================================================
-- NGÂN HÀNG CÂU HỎI MẪU (tự sinh bởi scripts/generate-seed.ts — đừng sửa tay).
-- Chạy SAU 0001_init.sql. Có thể chạy lại nhiều lần: không tạo trùng.
-- Tên bài bám theo chương trình lớp 2 (tham khảo) — thầy cô/phụ huynh có thể
-- đổi tên, thêm bớt bài và câu hỏi trong trang Quản trị.
-- =====================================================================

insert into public.subjects (code, name, color, sort_order) values
  ('toan', 'Toán', 'blue', 1),
  ('tieng_viet', 'Tiếng Việt', 'green', 2)
on conflict (code) do nothing;

update public.app_settings set current_week = 4 where id = 1 and current_week = 1;
`);

let total = 0;
for (const lesson of LESSONS) {
  const skills = lesson.skills.map((id) => {
    const s = getSkill(id);
    if (!s) throw new Error('Không có skill ' + id);
    return s;
  }) as Skill[];
  const questions: GeneratedQuestion[] = generateBatch(skills, COUNTS, rng);
  total += questions.length;

  sql.push(`
-- ${lesson.subject === 'toan' ? 'Toán' : 'Tiếng Việt'} • Tuần ${lesson.week} • Bài ${lesson.order}: ${lesson.name}
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, ${lesson.week}, ${lesson.order}, ${sqlStr(lesson.name)}, true, 'week' from public.subjects where code = '${lesson.subject}'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = '${lesson.subject}'
  cross join (values
${questions.map((q) => {
    const o = q.options ?? [];
    const acc = q.accepted_answers ? `'${JSON.stringify(q.accepted_answers).replace(/'/g, "''")}'::jsonb` : 'null::jsonb';
    return `    (${q.difficulty}::smallint, '${q.question_type}', ${sqlStr(q.question_text)}, ${sqlStr(o[0])}, ${sqlStr(o[1])}, ${sqlStr(o[2])}, ${sqlStr(o[3])}, ${sqlStr(q.correct_answer)}, ${acc}, ${sqlStr(q.explanation)}, '${q.skill_tag}', '${q.generator_type}')`;
  }).join(',\n')}
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = ${lesson.week} and l.lesson_order = ${lesson.order}
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);
`);

  for (const q of questions) {
    const o = q.options ?? [];
    csvRows.push([
      lesson.subject, lesson.week, lesson.order, lesson.name, q.difficulty, q.question_type, q.question_text,
      o[0], o[1], o[2], o[3], q.correct_answer, (q.accepted_answers ?? []).join('|'), q.explanation, q.skill_tag, '',
    ].map(csvCell).join(','));
  }
}

mkdirSync(new URL('supabase/', root), { recursive: true });
mkdirSync(new URL('data/', root), { recursive: true });
mkdirSync(new URL('public/mau/', root), { recursive: true });
writeFileSync(new URL('supabase/seed.sql', root), sql.join(''));
const questionCsv = '\ufeff' + csvRows.join('\n') + '\n';
const studentCsv = '\ufeffho_ten\n' + DEMO_STUDENTS.map(csvCell).join('\n') + '\n';
for (const dir of ['data/', 'public/mau/']) {
  writeFileSync(new URL(`${dir}ngan_hang_cau_hoi_mau.csv`, root), questionCsv);
  writeFileSync(new URL(`${dir}mau_danh_sach_hoc_sinh.csv`, root), studentCsv);
}

writeFileSync(new URL('supabase/demo/demo_data.sql', root), `-- Dữ liệu giả lập cho CHẾ ĐỘ DEMO (không chạy trên Supabase thật).
insert into public.students (full_name) values
${DEMO_STUDENTS.map((n) => `  (${sqlStr(n)})`).join(',\n')}
on conflict do nothing;

do $$
declare
  s record; l record; a jsonb; q jsonb; ans text; skill float; ago interval; aid uuid; dur int;
  v_sched boolean; v_daily int;
begin
  -- Tạm tắt giờ làm bài / giới hạn mỗi ngày (0006) để sinh dữ liệu ở bất kỳ giờ nào.
  select schedule_enabled, daily_max_lessons into v_sched, v_daily from public.app_settings where id = 1;
  update public.app_settings set schedule_enabled = false, daily_max_lessons = 0 where id = 1;
  for s in select id from public.students order by full_name loop
    skill := 0.55 + random() * 0.42;
    for l in select id from public.lessons where is_published and week_number <= 4 order by random() limit 3 + floor(random() * 5)::int loop
      a := public.start_attempt(s.id, l.id, case when random() < 0.25 then 'advanced' else 'basic' end, 'demo');
      aid := (a->>'attempt_id')::uuid;
      for q in select * from jsonb_array_elements(a->'questions') loop
        select case when random() < skill then correct_answer else '0' end into ans
          from public.questions where id = (q->>'id')::uuid;
        perform public.submit_answer(aid, (q->>'id')::uuid, ans);
      end loop;
      perform public.finish_attempt(aid);
      ago := case when random() < 0.3 then interval '0' else random() * interval '12 days' end;
      dur := 60 + floor(random() * 360)::int;
      update public.attempts
         set completed_at = completed_at - ago,
             started_at = completed_at - ago - make_interval(secs => dur),
             duration_seconds = dur
       where id = aid;
      update public.attempt_answers set answered_at = answered_at - ago where attempt_id = aid;
    end loop;
  end loop;
  update public.app_settings set schedule_enabled = v_sched, daily_max_lessons = v_daily where id = 1;
end $$;
`);

console.log(`Đã sinh ${LESSONS.length} bài, ${total} câu hỏi.`);
