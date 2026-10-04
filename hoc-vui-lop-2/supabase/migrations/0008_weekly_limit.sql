-- =====================================================================
-- 0008: GIỚI HẠN SỐ ĐỀ MỖI MÔN MỖI TUẦN (thứ Hai → Chủ nhật, giờ Việt Nam).
-- - Cài đặt chung: admin → Cài đặt → "Lượng bài mỗi ngày / mỗi tuần". Mặc định 0 = không giới hạn.
-- - Cài đặt riêng từng môn: admin → Bài học → Cài đặt môn → "Tối đa đề / tuần" (để trống = theo cài đặt chung).
-- - Đếm như giới hạn mỗi ngày: mọi lần bắt đầu đề (cả làm lại); làm tiếp bài đang dở không tính thêm.
-- Chạy sau 0001 → 0007. Chạy lại nhiều lần an toàn. Lỡ chạy lại 0006 thì chạy lại file này.
-- =====================================================================

alter table public.app_settings
  add column if not exists weekly_max_lessons int not null default 0 check (weekly_max_lessons between 0 and 300);

alter table public.subject_settings
  add column if not exists weekly_max_lessons int check (weekly_max_lessons between 0 and 300);

-- Giống 0006, thêm weekly_max_lessons.
create or replace function public.effective_settings(p_subject_id uuid)
returns public.app_settings language plpgsql stable security definer set search_path = public as $$
declare
  v public.app_settings;
  o public.subject_settings;
begin
  select * into v from public.app_settings where id = 1;
  select * into o from public.subject_settings where subject_id = p_subject_id;
  if found then
    v.daily_max_lessons   := coalesce(o.daily_max_lessons, v.daily_max_lessons);
    v.weekly_max_lessons  := coalesce(o.weekly_max_lessons, v.weekly_max_lessons);
    v.basic_easy          := coalesce(o.basic_easy, v.basic_easy);
    v.basic_normal        := coalesce(o.basic_normal, v.basic_normal);
    v.basic_advanced      := coalesce(o.basic_advanced, v.basic_advanced);
    v.adv_easy            := coalesce(o.adv_easy, v.adv_easy);
    v.adv_normal          := coalesce(o.adv_normal, v.adv_normal);
    v.adv_advanced        := coalesce(o.adv_advanced, v.adv_advanced);
    v.points_easy         := coalesce(o.points_easy, v.points_easy);
    v.points_normal       := coalesce(o.points_normal, v.points_normal);
    v.points_advanced     := coalesce(o.points_advanced, v.points_advanced);
    v.adv_points_easy     := coalesce(o.adv_points_easy, v.adv_points_easy);
    v.adv_points_normal   := coalesce(o.adv_points_normal, v.adv_points_normal);
    v.adv_points_advanced := coalesce(o.adv_points_advanced, v.adv_points_advanced);
    v.wrong_penalty       := coalesce(o.wrong_penalty, v.wrong_penalty);
    v.retake_mode         := coalesce(o.retake_mode, v.retake_mode);
  end if;
  return v;
end $$;

-- Như daily_used nhưng tính cả tuần (thứ Hai → Chủ nhật).
create or replace function public.weekly_used(p_student_id uuid, p_subject_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int
    from public.attempts a
    join public.lessons l on l.id = a.lesson_id
    cross join public.period_range('week') r
   where a.student_id = p_student_id and l.subject_id = p_subject_id
     and a.started_at >= r.r_start and a.started_at < r.r_end
$$;

-- Giống 0006, thêm kiểm tra giới hạn tuần (weekly_limit_reached).
create or replace function public.start_attempt(p_student_id uuid, p_lesson_id uuid,
                                                p_exercise_type text default 'basic',
                                                p_device_token text default null)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_set    public.app_settings;
  v_eff    public.app_settings;
  v_lesson public.lessons;
  v_n1 int; v_n2 int; v_n3 int; v_total int;
  v_ids    uuid[];
  v_id     uuid;
  v_ranked boolean;
begin
  if p_exercise_type not in ('basic','advanced') then
    raise exception 'invalid_exercise_type';
  end if;
  -- Khoá dòng học sinh để 2 lượt bắt đầu cùng lúc không vượt giới hạn mỗi ngày / mỗi tuần.
  perform 1 from public.students where id = p_student_id and is_active for update;
  if not found then
    raise exception 'student_not_found';
  end if;
  select * into v_set from public.app_settings where id = 1;
  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found or not public.lesson_is_visible(v_lesson, v_set.current_week) then
    raise exception 'lesson_not_available';
  end if;

  -- Tiếp tục lượt đang làm dở (mất mạng, tải lại trang...) trong 3 giờ gần nhất — kể cả khi đã hết giờ làm bài.
  select id into v_id from public.attempts
   where student_id = p_student_id and lesson_id = p_lesson_id and exercise_type = p_exercise_type
     and completed_at is null and started_at > now() - interval '3 hours'
   order by started_at desc limit 1;
  if found then
    return public.attempt_payload(v_id);
  end if;

  if not public.is_open_now() then
    raise exception 'closed_hours';
  end if;
  v_eff := public.effective_settings(v_lesson.subject_id);
  if v_eff.daily_max_lessons > 0
     and public.daily_used(p_student_id, v_lesson.subject_id) >= v_eff.daily_max_lessons then
    raise exception 'daily_limit_reached';
  end if;
  if v_eff.weekly_max_lessons > 0
     and public.weekly_used(p_student_id, v_lesson.subject_id) >= v_eff.weekly_max_lessons then
    raise exception 'weekly_limit_reached';
  end if;

  if p_exercise_type = 'basic' then
    v_n1 := v_eff.basic_easy; v_n2 := v_eff.basic_normal; v_n3 := v_eff.basic_advanced;
  else
    v_n1 := v_eff.adv_easy; v_n2 := v_eff.adv_normal; v_n3 := v_eff.adv_advanced;
  end if;
  v_total := greatest(1, v_n1 + v_n2 + v_n3);

  -- Chọn theo tỉ lệ độ khó, ưu tiên câu bé chưa gặp; thiếu thì bù bằng câu khác.
  with pool as (
    select q.id, q.difficulty, random() as r,
           exists (select 1 from public.attempt_answers aa join public.attempts pa on pa.id = aa.attempt_id
                    where pa.student_id = p_student_id and aa.question_id = q.id) as seen
      from public.questions q
     where q.lesson_id = p_lesson_id and q.is_active
  ),
  ranked as (
    select id, difficulty, r, seen,
           row_number() over (partition by difficulty order by seen, r) <=
             case difficulty when 1 then v_n1 when 2 then v_n2 else v_n3 end as in_quota
      from pool
  ),
  picked as (
    select id, difficulty from ranked order by in_quota desc, seen, r limit v_total
  )
  select array_agg(id order by difficulty, random()) into v_ids from picked;

  if v_ids is null or array_length(v_ids, 1) = 0 then
    raise exception 'no_questions';
  end if;

  v_ranked := not exists (
    select 1 from public.attempts
     where student_id = p_student_id and lesson_id = p_lesson_id and exercise_type = p_exercise_type
       and is_ranked and completed_at is not null);

  insert into public.attempts (student_id, lesson_id, exercise_type, question_ids, total_questions, is_ranked, device_token)
  values (p_student_id, p_lesson_id, p_exercise_type, v_ids, array_length(v_ids, 1), v_ranked, left(p_device_token, 100))
  returning id into v_id;

  insert into public.week_log (week_start, class_week) values (public.week_start_of(now()), v_set.current_week)
  on conflict (week_start) do nothing;

  return public.attempt_payload(v_id);
end $$;

-- Giống 0006, thêm week_used / week_max vào phần "daily" của từng môn.
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
  v_daily   jsonb;
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

  select coalesce(jsonb_object_agg(sj.code, jsonb_build_object(
           'used', public.daily_used(p_student_id, sj.id),
           'max', es.daily_max_lessons,
           'week_used', public.weekly_used(p_student_id, sj.id),
           'week_max', es.weekly_max_lessons,
           'basic_count', es.basic_easy + es.basic_normal + es.basic_advanced,
           'advanced_count', es.adv_easy + es.adv_normal + es.adv_advanced)), '{}'::jsonb)
    into v_daily
    from public.subjects sj
    cross join lateral public.effective_settings(sj.id) es;

  return jsonb_build_object(
    'student', jsonb_build_object('id', v_student.id, 'full_name', v_student.full_name, 'display_name', v_student.display_name),
    'config', public.get_public_config(),
    'points', v_points,
    'ranks', v_ranks,
    'basic_count', v_set.basic_easy + v_set.basic_normal + v_set.basic_advanced,
    'advanced_count', v_set.adv_easy + v_set.adv_normal + v_set.adv_advanced,
    'lessons', v_lessons,
    'rewards', public.student_rewards(p_student_id),
    'schedule', public.schedule_status(),
    'daily', v_daily);
end $$;

revoke execute on function
  public.effective_settings(uuid),
  public.weekly_used(uuid, uuid),
  public.start_attempt(uuid, uuid, text, text),
  public.get_student_home(uuid)
from public, anon, authenticated;

grant execute on function
  public.start_attempt(uuid, uuid, text, text),
  public.get_student_home(uuid)
to anon, authenticated;
