-- =====================================================================
-- SỬA LỖI: bài "Chọn dấu câu thích hợp" (đáp án . ? !) chọn đúng vẫn bị chấm sai.
-- Nguyên nhân: normalize_answer bỏ dấu câu cuối nên đáp án "." thành rỗng.
-- Chạy 1 lần trong Supabase SQL Editor (DB đã chạy 0001_init.sql). Chạy lại cũng an toàn.
-- File này cũng CHẤM LẠI các câu đã trả lời và cập nhật điểm/xếp hạng của các lượt đã làm.
-- =====================================================================

create or replace function public.normalize_answer(p text)
returns text language sql immutable as $$
  select case when s ~ '^[\.\!\?,;:…]+$' then s
              else regexp_replace(s, '[\.\!\?,;:]+$', '') end
    from (select public.vn_lower(regexp_replace(btrim(normalize(coalesce(p, ''), NFC)), '\s+', ' ', 'g')) as s) t
$$;

update public.attempt_answers aa
   set is_correct    = true,
       score_awarded = public.question_points(q, st)
  from public.questions q, public.app_settings st
 where st.id = 1
   and q.id = aa.question_id
   and not aa.is_correct
   and public.check_answer(q, aa.student_answer);

update public.attempts a
   set correct_count = s.c,
       wrong_count   = a.total_questions - s.c,
       score         = s.sc
  from (select aa.attempt_id,
               count(*) filter (where aa.is_correct)::int as c,
               coalesce(sum(aa.score_awarded), 0)::int    as sc
          from public.attempt_answers aa
         group by aa.attempt_id) s
 where a.id = s.attempt_id
   and a.completed_at is not null
   and (a.correct_count <> s.c or a.score <> s.sc);

select count(*) as so_lan_chon_dung_dau_cau
  from public.attempt_answers aa
  join public.questions q on q.id = aa.question_id
 where q.correct_answer ~ '^[\.\!\?]$' and aa.is_correct;
