-- =====================================================================
-- 0005: BẠN KHÁCH (không thuộc lớp) — nhận biết bằng dấu "-" trong họ tên, VD "Tiểu Nguyên - Khoai".
-- Bạn khách vẫn học, được tính điểm bình thường và thấy mình trên bảng xếp hạng;
-- các bạn trong lớp KHÔNG thấy bạn khách (bị loại ra trước khi xếp hạng nên thứ hạng của lớp không lệch).
-- Admin (trang quản trị) thấy tất cả.
-- Chạy sau 0001 → 0004. Chạy lại nhiều lần an toàn. Lỡ chạy lại 0001 thì chạy lại file này.
-- =====================================================================

create or replace function public.is_guest_name(p_name text)
returns boolean language sql immutable as $$
  select coalesce(p_name, '') ~ '[-–—]'
$$;

-- Xếp hạng theo người xem: bỏ bạn khách, trừ chính người xem (p_viewer); p_show_all = true => hiện tất cả.
-- p_subject_id = null => tất cả các môn.
create or replace function public.leaderboard_rows_for(p_period text, p_subject_id uuid, p_viewer uuid, p_show_all boolean)
returns table (student_id uuid, full_name text, display_name text, score bigint,
               lessons_done bigint, correct bigint, total bigint, rank bigint, is_guest boolean)
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
         rank() over (order by agg.score desc) as rank,
         public.is_guest_name(s.full_name)
    from agg join public.students s on s.id = agg.student_id
   where s.is_active and agg.score > 0
     and (p_show_all or s.id = p_viewer or not public.is_guest_name(s.full_name))
   order by agg.score desc, s.display_name
$$;

-- Học sinh luôn gửi p_student_id; trang admin không gửi => admin mới thấy bạn khách
-- (máy dùng chung mà admin đang đăng nhập thì trang học sinh vẫn ẩn bạn khách).
create or replace function public.get_leaderboard(p_period text, p_student_id uuid default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
begin
  return public.get_subject_leaderboard(p_period, null, p_student_id);
end $$;

create or replace function public.get_subject_leaderboard(p_period text, p_subject_id uuid default null,
                                                          p_student_id uuid default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_range    record;
  v_subjects jsonb;
  v_me       jsonb;
  v_rows     jsonb;
  v_all      boolean := p_student_id is null and public.is_admin();
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
           'rank', rank, 'is_guest', is_guest)), '[]'::jsonb)
    into v_rows
    from (select * from public.leaderboard_rows_for(p_period, p_subject_id, p_student_id, v_all) limit 50) t;

  if p_student_id is not null then
    select jsonb_build_object('rank', rank, 'score', score) into v_me
      from public.leaderboard_rows_for(p_period, p_subject_id, p_student_id, false) where student_id = p_student_id;
  end if;

  return jsonb_build_object('enabled', true, 'period', p_period, 'subject_id', p_subject_id,
                            'subjects', v_subjects,
                            'start', v_range.r_start, 'end', v_range.r_end,
                            'rows', v_rows, 'me', v_me);
end $$;

-- Giống 0001, chỉ đổi phần tính điểm/hạng sang leaderboard_rows_for (hạng của bạn trong lớp không tính bạn khách).
create or replace function public.get_student_home(p_student_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_student public.students;
  v_set     public.app_settings;
  v_points  jsonb := '{}'::jsonb;
  v_ranks   jsonb := '{}'::jsonb;
  v_period  text;
  v_row     record;
  v_lessons jsonb;
begin
  select * into v_student from public.students where id = p_student_id and is_active;
  if not found then
    raise exception 'student_not_found';
  end if;
  select * into v_set from public.app_settings where id = 1;

  foreach v_period in array array['day','week','month'] loop
    select lr.score, lr.rank into v_row
      from public.leaderboard_rows_for(v_period, null, p_student_id, false) lr where lr.student_id = p_student_id;
    v_points := v_points || jsonb_build_object(v_period, coalesce(v_row.score, 0));
    v_ranks  := v_ranks  || jsonb_build_object(v_period, v_row.rank);
  end loop;

  select coalesce(jsonb_agg(x order by x->>'subject_sort', (x->>'week_number')::int, (x->>'lesson_order')::int), '[]'::jsonb)
    into v_lessons
    from (
      select jsonb_build_object(
               'id', l.id,
               'subject_code', sj.code,
               'subject_name', sj.name,
               'subject_color', sj.color,
               'subject_sort', lpad(sj.sort_order::text, 4, '0'),
               'week_number', l.week_number,
               'lesson_order', l.lesson_order,
               'name', l.name,
               'description', l.description,
               'question_count', qc.cnt,
               'basic_best', (select max(a.score) from public.attempts a
                               where a.student_id = p_student_id and a.lesson_id = l.id
                                 and a.exercise_type = 'basic' and a.completed_at is not null),
               'basic_ranked_score', (select a.score from public.attempts a
                               where a.student_id = p_student_id and a.lesson_id = l.id
                                 and a.exercise_type = 'basic' and a.is_ranked and a.completed_at is not null limit 1),
               'basic_correct', (select a.correct_count || '/' || a.total_questions from public.attempts a
                               where a.student_id = p_student_id and a.lesson_id = l.id
                                 and a.exercise_type = 'basic' and a.is_ranked and a.completed_at is not null limit 1),
               'advanced_best', (select max(a.score) from public.attempts a
                               where a.student_id = p_student_id and a.lesson_id = l.id
                                 and a.exercise_type = 'advanced' and a.completed_at is not null),
               'advanced_correct', (select a.correct_count || '/' || a.total_questions from public.attempts a
                               where a.student_id = p_student_id and a.lesson_id = l.id
                                 and a.exercise_type = 'advanced' and a.is_ranked and a.completed_at is not null limit 1),
               'has_advanced', qc.adv > 0
             ) as x
        from public.lessons l
        join public.subjects sj on sj.id = l.subject_id
        join lateral (select count(*) as cnt, count(*) filter (where q.difficulty >= 2) as adv
                        from public.questions q where q.lesson_id = l.id and q.is_active) qc on true
       where public.lesson_is_visible(l, v_set.current_week) and qc.cnt > 0
    ) t;

  return jsonb_build_object(
    'student', jsonb_build_object('id', v_student.id, 'full_name', v_student.full_name, 'display_name', v_student.display_name),
    'config', public.get_public_config(),
    'points', v_points,
    'ranks', v_ranks,
    'basic_count', v_set.basic_easy + v_set.basic_normal + v_set.basic_advanced,
    'advanced_count', v_set.adv_easy + v_set.adv_normal + v_set.adv_advanced,
    'lessons', v_lessons);
end $$;

revoke execute on function public.is_guest_name(text) from public, anon, authenticated;
revoke execute on function public.leaderboard_rows_for(text, uuid, uuid, boolean) from public, anon, authenticated;
revoke execute on function public.get_leaderboard(text, uuid) from public, anon, authenticated;
revoke execute on function public.get_subject_leaderboard(text, uuid, uuid) from public, anon, authenticated;
revoke execute on function public.get_student_home(uuid) from public, anon, authenticated;
grant execute on function public.get_leaderboard(text, uuid) to anon, authenticated;
grant execute on function public.get_subject_leaderboard(text, uuid, uuid) to anon, authenticated;
grant execute on function public.get_student_home(uuid) to anon, authenticated;
