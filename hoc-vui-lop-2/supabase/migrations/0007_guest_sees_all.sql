-- =====================================================================
-- 0007: BẠN KHÁCH (tên có dấu "-") THẤY BẢNG XẾP HẠNG CỦA TẤT CẢ MỌI NGƯỜI.
-- - Người xem là bạn khách: thấy cả lớp lẫn các bạn khách khác; hạng tính trên toàn bộ.
-- - Người xem là bạn trong lớp (hoặc chưa chọn tên): chỉ thấy các bạn trong lớp như cũ.
-- - Admin (trang quản trị) thấy tất cả như cũ.
-- Áp dụng cho bảng xếp hạng (mọi môn / từng môn) và hạng trên trang chủ.
-- Chạy sau 0001 → 0006. Chạy lại nhiều lần an toàn. Lỡ chạy lại 0001 hoặc 0005 thì chạy lại file này.
-- =====================================================================

create or replace function public.leaderboard_rows_for(p_period text, p_subject_id uuid, p_viewer uuid, p_show_all boolean)
returns table (student_id uuid, full_name text, display_name text, score bigint,
               lessons_done bigint, correct bigint, total bigint, rank bigint, is_guest boolean)
language sql stable security definer set search_path = public as $$
  with r as (select * from public.period_range(p_period)),
  viewer as (
    select p_show_all
           or coalesce((select public.is_guest_name(v.full_name) from public.students v where v.id = p_viewer), false)
           as see_all
  ),
  agg as (
    select a.student_id,
           sum(a.score)            as score,
           count(*)                as lessons_done,
           sum(a.correct_count)    as correct,
           sum(a.total_questions)  as total
      from public.attempts a
      join public.lessons l on l.id = a.lesson_id
      cross join r
     where a.is_ranked
       and a.completed_at >= r.r_start
       and a.completed_at <  r.r_end
       and (p_subject_id is null or l.subject_id = p_subject_id)
     group by a.student_id
  )
  select s.id, s.full_name, s.display_name, agg.score, agg.lessons_done, agg.correct, agg.total,
         rank() over (order by agg.score desc) as rank,
         public.is_guest_name(s.full_name)
    from agg
    join public.students s on s.id = agg.student_id
    cross join viewer
   where s.is_active and agg.score > 0
     and (viewer.see_all or s.id = p_viewer or not public.is_guest_name(s.full_name))
   order by agg.score desc, s.display_name
$$;

revoke execute on function public.leaderboard_rows_for(text, uuid, uuid, boolean) from public, anon, authenticated;
