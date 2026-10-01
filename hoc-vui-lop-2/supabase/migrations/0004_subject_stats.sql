-- =====================================================================
-- 0004: Bảng xếp hạng và thống kê THEO TỪNG MÔN HỌC.
-- Chạy sau 0001_init.sql (và 0003). Chạy lại nhiều lần an toàn.
-- Dùng tên hàm mới (không thêm tham số vào hàm cũ) để không tạo hàm trùng tên
-- khiến Supabase báo "could not choose the best candidate function".
-- =====================================================================

-- Xếp hạng trong 1 khoảng thời gian; p_subject_id = null => tất cả các môn.
create or replace function public.leaderboard_rows_by(p_period text, p_subject_id uuid)
returns table (student_id uuid, full_name text, display_name text, score bigint,
               lessons_done bigint, correct bigint, total bigint, rank bigint)
language sql stable security definer set search_path = public as $$
  with r as (select * from public.period_range(p_period)),
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
         rank() over (order by agg.score desc) as rank
    from agg join public.students s on s.id = agg.student_id
   where s.is_active and agg.score > 0
   order by agg.score desc, s.display_name
$$;

-- API bảng xếp hạng (học sinh + admin). Trả kèm danh sách môn để vẽ các tab.
create or replace function public.get_subject_leaderboard(p_period text, p_subject_id uuid default null,
                                                          p_student_id uuid default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_range    record;
  v_subjects jsonb;
  v_me       jsonb;
  v_rows     jsonb;
begin
  select * into v_range from public.period_range(p_period);
  if p_subject_id is not null and not exists (select 1 from public.subjects where id = p_subject_id) then
    raise exception 'subject_not_found';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object('id', sj.id, 'code', sj.code, 'name', sj.name, 'color', sj.color)
                            order by sj.sort_order, sj.name), '[]'::jsonb)
    into v_subjects
    from public.subjects sj
   where exists (select 1 from public.lessons l where l.subject_id = sj.id);

  if not (select leaderboard_enabled from public.app_settings where id = 1) and not public.is_admin() then
    return jsonb_build_object('enabled', false, 'period', p_period, 'subject_id', p_subject_id,
                              'subjects', v_subjects, 'rows', '[]'::jsonb);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'student_id', student_id, 'full_name', full_name, 'display_name', display_name,
           'score', score, 'lessons_done', lessons_done,
           'accuracy', case when total > 0 then round(100.0 * correct / total) else 0 end,
           'rank', rank)), '[]'::jsonb)
    into v_rows
    from (select * from public.leaderboard_rows_by(p_period, p_subject_id) limit 50) t;

  if p_student_id is not null then
    select jsonb_build_object('rank', rank, 'score', score) into v_me
      from public.leaderboard_rows_by(p_period, p_subject_id) where student_id = p_student_id;
  end if;

  return jsonb_build_object('enabled', true, 'period', p_period, 'subject_id', p_subject_id,
                            'subjects', v_subjects,
                            'start', v_range.r_start, 'end', v_range.r_end,
                            'rows', v_rows, 'me', v_me);
end $$;

-- Thống kê theo môn cho admin. p_period: 'day' | 'week' | 'month' | 'all' (từ trước tới nay).
create or replace function public.admin_subject_stats(p_period text default 'week')
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_start timestamptz := '-infinity';
  v_end   timestamptz := 'infinity';
begin
  perform public.require_admin();
  if p_period <> 'all' then
    select r_start, r_end into v_start, v_end from public.period_range(p_period);
  end if;

  return jsonb_build_object(
    'period', p_period,
    'start', case when p_period = 'all' then null else v_start end,
    'end',   case when p_period = 'all' then null else v_end end,
    'total_students', (select count(*) from public.students where is_active),

    'subjects', (
      select coalesce(jsonb_agg(x order by (x->>'sort_order')::int, x->>'name'), '[]'::jsonb) from (
        select jsonb_build_object(
                 'id', sj.id, 'code', sj.code, 'name', sj.name, 'color', sj.color, 'sort_order', sj.sort_order,
                 'lesson_count', (select count(*) from public.lessons l where l.subject_id = sj.id),
                 'published_count', (select count(*) from public.lessons l where l.subject_id = sj.id and l.is_published),
                 'question_count', (select count(*) from public.questions q join public.lessons l on l.id = q.lesson_id
                                     where l.subject_id = sj.id and q.is_active),
                 'attempts_completed', st.attempts,
                 'active_students', st.students,
                 'ranked_score', st.score,
                 'accuracy', st.accuracy,
                 'avg_duration', st.avg_duration) as x
          from public.subjects sj
          cross join lateral (
            select count(*)                                                     as attempts,
                   count(distinct a.student_id)                                 as students,
                   coalesce(sum(a.score) filter (where a.is_ranked), 0)         as score,
                   round(100.0 * sum(a.correct_count) / nullif(sum(a.total_questions), 0)) as accuracy,
                   round(avg(a.duration_seconds))                               as avg_duration
              from public.attempts a
              join public.lessons l on l.id = a.lesson_id
             where l.subject_id = sj.id
               and a.completed_at >= v_start and a.completed_at < v_end
          ) st) t),

    -- Mỗi học sinh (đang học) × mỗi môn: số lượt, điểm xếp hạng, tỉ lệ đúng. Môn chưa làm thì không có khoá.
    'students', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'student_id', s.id, 'full_name', s.full_name, 'display_name', s.display_name,
               'by_subject', coalesce(m.by_subject, '{}'::jsonb)) order by s.display_name), '[]'::jsonb)
        from public.students s
        left join lateral (
          select jsonb_object_agg(x.subject_id, jsonb_build_object(
                   'attempts', x.attempts, 'score', x.score, 'accuracy', x.accuracy)) as by_subject
            from (select l.subject_id,
                         count(*)                                             as attempts,
                         coalesce(sum(a.score) filter (where a.is_ranked), 0) as score,
                         round(100.0 * sum(a.correct_count) / nullif(sum(a.total_questions), 0)) as accuracy
                    from public.attempts a
                    join public.lessons l on l.id = a.lesson_id
                   where a.student_id = s.id
                     and a.completed_at >= v_start and a.completed_at < v_end
                   group by l.subject_id) x
        ) m on true
       where s.is_active),

    -- Tối đa 5 câu sai nhiều nhất mỗi môn (cần >= 3 lượt trả lời).
    'hardest', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'subject_id', z.subject_id, 'question_id', z.id, 'text', z.question_text,
               'lesson_name', z.lesson_name, 'week_number', z.week_number,
               'answered', z.answered, 'wrong', z.wrong, 'wrong_rate', z.wrong_rate)
             order by z.subject_id, z.rn), '[]'::jsonb)
        from (
          select l.subject_id, q.id, q.question_text, l.name as lesson_name, l.week_number,
                 count(*)                                     as answered,
                 count(*) filter (where not aa.is_correct)    as wrong,
                 round(100.0 * count(*) filter (where not aa.is_correct) / count(*)) as wrong_rate,
                 row_number() over (partition by l.subject_id
                                    order by 1.0 * count(*) filter (where not aa.is_correct) / count(*) desc,
                                             count(*) desc) as rn
            from public.attempt_answers aa
            join public.questions q on q.id = aa.question_id
            join public.lessons l on l.id = q.lesson_id
           where aa.answered_at >= v_start and aa.answered_at < v_end
           group by l.subject_id, q.id, q.question_text, l.name, l.week_number
          having count(*) >= 3 and count(*) filter (where not aa.is_correct) > 0
        ) z
       where z.rn <= 5));
end $$;

-- Supabase tự cấp quyền chạy hàm mới cho anon/authenticated => thu hồi rồi cấp lại đúng chỗ.
revoke execute on function public.leaderboard_rows_by(text, uuid) from public, anon, authenticated;
revoke execute on function public.get_subject_leaderboard(text, uuid, uuid) from public, anon, authenticated;
revoke execute on function public.admin_subject_stats(text) from public, anon, authenticated;
grant execute on function public.get_subject_leaderboard(text, uuid, uuid) to anon, authenticated;
grant execute on function public.admin_subject_stats(text) to authenticated;
