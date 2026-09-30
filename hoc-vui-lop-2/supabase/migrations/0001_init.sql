-- =====================================================================
-- HỌC VUI LỚP 2 — Database schema, bảo mật (RLS) và hàm nghiệp vụ.
-- Chạy 1 lần trong Supabase > SQL Editor (hoặc `supabase db push`).
-- Học sinh (anon) KHÔNG đọc trực tiếp bảng nào; mọi thao tác qua các
-- hàm SECURITY DEFINER bên dưới => đáp án không bao giờ lộ xuống trình duyệt
-- trước khi nộp, điểm do server tự tính.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. BẢNG
-- ---------------------------------------------------------------------

create table if not exists public.app_settings (
  id                  int primary key default 1 check (id = 1),
  class_name          text not null default 'Lớp 2A1',
  school_year         text not null default '2026 - 2027',
  current_week        int  not null default 1 check (current_week between 1 and 60),
  timezone            text not null default 'Asia/Ho_Chi_Minh',
  leaderboard_enabled boolean not null default true,
  allow_self_register boolean not null default true,
  basic_easy          int not null default 6 check (basic_easy between 0 and 50),
  basic_normal        int not null default 3 check (basic_normal between 0 and 50),
  basic_advanced      int not null default 1 check (basic_advanced between 0 and 50),
  adv_easy            int not null default 2 check (adv_easy between 0 and 50),
  adv_normal          int not null default 3 check (adv_normal between 0 and 50),
  adv_advanced        int not null default 5 check (adv_advanced between 0 and 50),
  points_easy         int not null default 10 check (points_easy between 0 and 1000),
  points_normal       int not null default 15 check (points_normal between 0 and 1000),
  points_advanced     int not null default 25 check (points_advanced between 0 and 1000),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create table if not exists public.subjects (
  id         uuid primary key default gen_random_uuid(),
  code       text not null unique,
  name       text not null,
  color      text not null default 'blue' check (color in ('blue','green','amber','rose','purple')),
  sort_order int  not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id              uuid primary key default gen_random_uuid(),
  subject_id      uuid not null references public.subjects(id) on delete cascade,
  week_number     int  not null check (week_number between 1 and 60),
  lesson_order    int  not null default 1 check (lesson_order between 0 and 999),
  name            text not null check (char_length(name) between 1 and 200),
  description     text,
  is_published    boolean not null default false,
  publish_mode    text not null default 'week' check (publish_mode in ('always','week','date')),
  available_from  timestamptz,
  available_until timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (subject_id, week_number, lesson_order)
);

create table if not exists public.questions (
  id               uuid primary key default gen_random_uuid(),
  lesson_id        uuid not null references public.lessons(id) on delete cascade,
  difficulty       smallint not null default 1 check (difficulty in (1,2,3)),
  question_type    text not null check (question_type in ('multiple_choice','number','text')),
  question_text    text not null check (char_length(question_text) between 1 and 2000),
  option_a         text,
  option_b         text,
  option_c         text,
  option_d         text,
  correct_answer   text not null check (char_length(correct_answer) between 1 and 200),
  accepted_answers jsonb check (accepted_answers is null or jsonb_typeof(accepted_answers) = 'array'),
  explanation      text,
  points           int check (points is null or points between 0 and 1000),
  skill_tag        text,
  source_book      text,
  source_page      int,
  generator_type   text,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  check (question_type <> 'multiple_choice' or (option_a is not null and option_b is not null))
);
create index if not exists questions_lesson_idx on public.questions (lesson_id) where is_active;

create table if not exists public.students (
  id           uuid primary key default gen_random_uuid(),
  full_name    text not null check (char_length(full_name) between 2 and 80),
  display_name text not null default '',
  name_key     text not null default '',
  is_active    boolean not null default true,
  note         text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create unique index if not exists students_name_key_idx on public.students (name_key);

create table if not exists public.attempts (
  id               uuid primary key default gen_random_uuid(),
  student_id       uuid not null references public.students(id) on delete cascade,
  lesson_id        uuid not null references public.lessons(id) on delete cascade,
  exercise_type    text not null check (exercise_type in ('basic','advanced')),
  question_ids     uuid[] not null,
  score            int not null default 0,
  correct_count    int not null default 0,
  wrong_count      int not null default 0,
  total_questions  int not null default 0,
  duration_seconds int,
  is_ranked        boolean not null default false,
  device_token     text,
  started_at       timestamptz not null default now(),
  completed_at     timestamptz
);
create index if not exists attempts_student_idx on public.attempts (student_id, lesson_id, exercise_type);
create index if not exists attempts_completed_idx on public.attempts (completed_at) where is_ranked;

create table if not exists public.attempt_answers (
  id             uuid primary key default gen_random_uuid(),
  attempt_id     uuid not null references public.attempts(id) on delete cascade,
  question_id    uuid not null references public.questions(id) on delete cascade,
  student_answer text not null,
  is_correct     boolean not null,
  score_awarded  int not null default 0,
  answered_at    timestamptz not null default now(),
  unique (attempt_id, question_id)
);
create index if not exists attempt_answers_question_idx on public.attempt_answers (question_id);

create table if not exists public.admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2. HÀM TIỆN ÍCH
-- ---------------------------------------------------------------------

-- lower() của Postgres phụ thuộc locale; tự dịch chữ hoa có dấu để luôn đúng.
create or replace function public.vn_lower(p text)
returns text language sql immutable as $$
  select lower(translate(normalize(coalesce(p, ''), NFC),
    'ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬĐÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ',
    'àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ'))
$$;

create or replace function public.normalize_name(p text)
returns text language sql immutable as $$
  select public.vn_lower(regexp_replace(btrim(normalize(coalesce(p, ''), NFC)), '\s+', ' ', 'g'))
$$;

create or replace function public.default_display_name(p text)
returns text language sql immutable as $$
  select array_to_string(
    (select array_agg(w order by i)
       from unnest(regexp_split_to_array(btrim(regexp_replace(coalesce(p, ''), '\s+', ' ', 'g')), ' '))
            with ordinality as t(w, i)
      where i > greatest(0, array_length(regexp_split_to_array(btrim(regexp_replace(coalesce(p, ''), '\s+', ' ', 'g')), ' '), 1) - 2)),
    ' ')
$$;

-- Chuẩn hóa câu trả lời chữ: bỏ khoảng trắng thừa, chữ thường, bỏ dấu câu cuối.
create or replace function public.normalize_answer(p text)
returns text language sql immutable as $$
  select regexp_replace(
           public.vn_lower(regexp_replace(btrim(normalize(coalesce(p, ''), NFC)), '\s+', ' ', 'g')),
           '[\.\!\?,;:]+$', '')
$$;

-- Số lớp 2 không có phần thập phân; "1.000", "1 000" đều hiểu là 1000.
create or replace function public.normalize_number(p text)
returns text language sql immutable as $$
  select case
           when regexp_replace(coalesce(p, ''), '[\s\.,]', '', 'g') ~ '^-?[0-9]+$'
             then (regexp_replace(p, '[\s\.,]', '', 'g'))::numeric::text
           else null
         end
$$;

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create or replace function public.students_before_write()
returns trigger language plpgsql as $$
begin
  new.full_name := btrim(regexp_replace(normalize(new.full_name, NFC), '\s+', ' ', 'g'));
  if new.display_name is null or btrim(new.display_name) = '' then
    new.display_name := public.default_display_name(new.full_name);
  else
    new.display_name := btrim(new.display_name);
  end if;
  new.name_key := public.normalize_name(new.full_name);
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists trg_students_before_write on public.students;
create trigger trg_students_before_write before insert or update on public.students
  for each row execute function public.students_before_write();

drop trigger if exists trg_lessons_touch on public.lessons;
create trigger trg_lessons_touch before update on public.lessons
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_questions_touch on public.questions;
create trigger trg_questions_touch before update on public.questions
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_settings_touch on public.app_settings;
create trigger trg_settings_touch before update on public.app_settings
  for each row execute function public.touch_updated_at();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid())
$$;

create or replace function public.require_admin()
returns void language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_admin() then
    raise exception 'not_admin' using errcode = '42501';
  end if;
end $$;

create or replace function public.check_answer(q public.questions, p_answer text)
returns boolean language plpgsql stable as $$
declare
  v_ans text;
begin
  if q.question_type = 'number' then
    v_ans := public.normalize_number(p_answer);
    if v_ans is null then
      return false;
    end if;
    return exists (
      select 1
        from (select q.correct_answer as v
              union all
              select jsonb_array_elements_text(coalesce(q.accepted_answers, '[]'::jsonb))) s
       where public.normalize_number(s.v) = v_ans);
  end if;

  v_ans := public.normalize_answer(p_answer);
  if v_ans = '' then
    return false;
  end if;
  return exists (
    select 1
      from (select q.correct_answer as v
            union all
            select jsonb_array_elements_text(coalesce(q.accepted_answers, '[]'::jsonb))) s
     where public.normalize_answer(s.v) = v_ans);
end $$;

create or replace function public.question_points(q public.questions, s public.app_settings)
returns int language sql stable as $$
  select coalesce(q.points,
                  case q.difficulty when 1 then s.points_easy
                                    when 2 then s.points_normal
                                    else s.points_advanced end)
$$;

create or replace function public.lesson_is_visible(l public.lessons, p_current_week int)
returns boolean language sql stable as $$
  select l.is_published and (
       l.publish_mode = 'always'
    or (l.publish_mode = 'week' and l.week_number <= p_current_week)
    or (l.publish_mode = 'date'
        and (l.available_from is null or l.available_from <= now())
        and (l.available_until is null or l.available_until > now())))
$$;

-- Khoảng thời gian (theo múi giờ của lớp) cho bảng xếp hạng: ngày / tuần (T2→CN) / tháng.
create or replace function public.period_range(p_period text, out r_start timestamptz, out r_end timestamptz)
language plpgsql stable set search_path = public as $$
declare
  v_tz  text;
  v_now timestamp;
begin
  select timezone into v_tz from public.app_settings where id = 1;
  v_tz := coalesce(v_tz, 'Asia/Ho_Chi_Minh');
  v_now := now() at time zone v_tz;
  if p_period = 'day' then
    r_start := date_trunc('day', v_now) at time zone v_tz;
    r_end   := (date_trunc('day', v_now) + interval '1 day') at time zone v_tz;
  elsif p_period = 'week' then
    r_start := date_trunc('week', v_now) at time zone v_tz;
    r_end   := (date_trunc('week', v_now) + interval '7 days') at time zone v_tz;
  elsif p_period = 'month' then
    r_start := date_trunc('month', v_now) at time zone v_tz;
    r_end   := (date_trunc('month', v_now) + interval '1 month') at time zone v_tz;
  else
    raise exception 'invalid_period';
  end if;
end $$;

create or replace function public.leaderboard_rows(p_period text)
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
      from public.attempts a, r
     where a.is_ranked
       and a.completed_at >= r.r_start
       and a.completed_at <  r.r_end
     group by a.student_id
  )
  select s.id, s.full_name, s.display_name, agg.score, agg.lessons_done, agg.correct, agg.total,
         rank() over (order by agg.score desc) as rank
    from agg join public.students s on s.id = agg.student_id
   where s.is_active and agg.score > 0
   order by agg.score desc, s.display_name
$$;

-- ---------------------------------------------------------------------
-- 3. API CHO HỌC SINH (anon) — gọi qua supabase.rpc(...)
-- ---------------------------------------------------------------------

create or replace function public.get_public_config()
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'class_name', class_name,
    'school_year', school_year,
    'current_week', current_week,
    'leaderboard_enabled', leaderboard_enabled,
    'allow_self_register', allow_self_register)
  from public.app_settings where id = 1
$$;

create or replace function public.list_students()
returns jsonb language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'full_name', full_name, 'display_name', display_name)
                            order by display_name), '[]'::jsonb)
    from public.students where is_active
$$;

create or replace function public.register_student(p_full_name text)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_name text := btrim(regexp_replace(normalize(coalesce(p_full_name, ''), NFC), '\s+', ' ', 'g'));
  v_row  public.students;
begin
  if char_length(v_name) < 2 or char_length(v_name) > 80
     or v_name ~ '[<>{}\\/@#$%^&*=+|~";:!?_\[\]]'
     or v_name !~ '[^0-9\s\.\-''()]' then
    raise exception 'invalid_name';
  end if;

  select * into v_row from public.students where name_key = public.normalize_name(v_name);
  if found then
    if not v_row.is_active then
      raise exception 'student_disabled';
    end if;
  else
    if not (select allow_self_register from public.app_settings where id = 1) then
      raise exception 'self_register_disabled';
    end if;
    insert into public.students (full_name) values (v_name) returning * into v_row;
  end if;

  return jsonb_build_object('id', v_row.id, 'full_name', v_row.full_name, 'display_name', v_row.display_name);
end $$;

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
    select lr.score, lr.rank into v_row from public.leaderboard_rows(v_period) lr where lr.student_id = p_student_id;
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

create or replace function public.attempt_payload(p_attempt_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'attempt_id', a.id,
    'is_ranked', a.is_ranked,
    'exercise_type', a.exercise_type,
    'completed', a.completed_at is not null,
    'lesson', jsonb_build_object('id', l.id, 'name', l.name, 'week_number', l.week_number,
                                 'lesson_order', l.lesson_order, 'subject_name', sj.name, 'subject_color', sj.color),
    'questions', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'id', q.id,
               'type', q.question_type,
               'text', q.question_text,
               'difficulty', q.difficulty,
               'points', public.question_points(q, st),
               'options', case when q.question_type = 'multiple_choice'
                               then (select jsonb_agg(o) from unnest(array[q.option_a, q.option_b, q.option_c, q.option_d]) o
                                      where o is not null and btrim(o) <> '')
                               else null end
             ) order by ord.i), '[]'::jsonb)
        from unnest(a.question_ids) with ordinality as ord(qid, i)
        join public.questions q on q.id = ord.qid
        cross join public.app_settings st
       where st.id = 1),
    'answered', (
      select coalesce(jsonb_object_agg(aa.question_id, jsonb_build_object(
               'is_correct', aa.is_correct,
               'student_answer', aa.student_answer,
               'correct_answer', q.correct_answer,
               'explanation', q.explanation,
               'score_awarded', aa.score_awarded)), '{}'::jsonb)
        from public.attempt_answers aa join public.questions q on q.id = aa.question_id
       where aa.attempt_id = a.id))
  from public.attempts a
  join public.lessons l on l.id = a.lesson_id
  join public.subjects sj on sj.id = l.subject_id
  where a.id = p_attempt_id
$$;

create or replace function public.start_attempt(p_student_id uuid, p_lesson_id uuid,
                                                p_exercise_type text default 'basic',
                                                p_device_token text default null)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_set    public.app_settings;
  v_lesson public.lessons;
  v_n1 int; v_n2 int; v_n3 int; v_total int;
  v_ids    uuid[];
  v_id     uuid;
  v_ranked boolean;
begin
  if p_exercise_type not in ('basic','advanced') then
    raise exception 'invalid_exercise_type';
  end if;
  perform 1 from public.students where id = p_student_id and is_active;
  if not found then
    raise exception 'student_not_found';
  end if;
  select * into v_set from public.app_settings where id = 1;
  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found or not public.lesson_is_visible(v_lesson, v_set.current_week) then
    raise exception 'lesson_not_available';
  end if;

  -- Tiếp tục lượt đang làm dở (mất mạng, tải lại trang...) trong 3 giờ gần nhất.
  select id into v_id from public.attempts
   where student_id = p_student_id and lesson_id = p_lesson_id and exercise_type = p_exercise_type
     and completed_at is null and started_at > now() - interval '3 hours'
   order by started_at desc limit 1;
  if found then
    return public.attempt_payload(v_id);
  end if;

  if p_exercise_type = 'basic' then
    v_n1 := v_set.basic_easy; v_n2 := v_set.basic_normal; v_n3 := v_set.basic_advanced;
  else
    v_n1 := v_set.adv_easy; v_n2 := v_set.adv_normal; v_n3 := v_set.adv_advanced;
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

  return public.attempt_payload(v_id);
end $$;

create or replace function public.submit_answer(p_attempt_id uuid, p_question_id uuid, p_answer text)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_attempt public.attempts;
  v_q       public.questions;
  v_set     public.app_settings;
  v_prev    public.attempt_answers;
  v_ok      boolean;
  v_score   int;
  v_answer  text := left(btrim(coalesce(p_answer, '')), 200);
begin
  select * into v_attempt from public.attempts where id = p_attempt_id for update;
  if not found then
    raise exception 'attempt_not_found';
  end if;
  if v_attempt.completed_at is not null then
    raise exception 'attempt_completed';
  end if;
  if not (p_question_id = any (v_attempt.question_ids)) then
    raise exception 'question_not_in_attempt';
  end if;

  select * into v_q from public.questions where id = p_question_id;
  select * into v_prev from public.attempt_answers where attempt_id = p_attempt_id and question_id = p_question_id;
  if found then
    return jsonb_build_object('is_correct', v_prev.is_correct, 'correct_answer', v_q.correct_answer,
                              'explanation', v_q.explanation, 'score_awarded', v_prev.score_awarded,
                              'student_answer', v_prev.student_answer);
  end if;

  select * into v_set from public.app_settings where id = 1;
  v_ok := public.check_answer(v_q, v_answer);
  v_score := case when v_ok then public.question_points(v_q, v_set) else 0 end;

  insert into public.attempt_answers (attempt_id, question_id, student_answer, is_correct, score_awarded)
  values (p_attempt_id, p_question_id, v_answer, v_ok, v_score);

  return jsonb_build_object('is_correct', v_ok, 'correct_answer', v_q.correct_answer,
                            'explanation', v_q.explanation, 'score_awarded', v_score,
                            'student_answer', v_answer);
end $$;

create or replace function public.get_attempt_result(p_attempt_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'attempt_id', a.id,
    'student_id', a.student_id,
    'is_ranked', a.is_ranked,
    'exercise_type', a.exercise_type,
    'completed', a.completed_at is not null,
    'score', a.score,
    'correct_count', a.correct_count,
    'wrong_count', a.wrong_count,
    'total_questions', a.total_questions,
    'duration_seconds', a.duration_seconds,
    'completed_at', a.completed_at,
    'max_score', (select coalesce(sum(public.question_points(q, st)), 0)
                    from public.questions q cross join public.app_settings st
                   where st.id = 1 and q.id = any (a.question_ids)),
    'lesson', jsonb_build_object('id', l.id, 'name', l.name, 'week_number', l.week_number,
                                 'lesson_order', l.lesson_order, 'subject_name', sj.name, 'subject_color', sj.color),
    'review', case when a.completed_at is null then '[]'::jsonb else (
      select coalesce(jsonb_agg(jsonb_build_object(
               'question_id', q.id,
               'type', q.question_type,
               'text', q.question_text,
               'student_answer', aa.student_answer,
               'correct_answer', q.correct_answer,
               'is_correct', coalesce(aa.is_correct, false),
               'explanation', q.explanation,
               'score_awarded', coalesce(aa.score_awarded, 0)) order by ord.i), '[]'::jsonb)
        from unnest(a.question_ids) with ordinality as ord(qid, i)
        join public.questions q on q.id = ord.qid
        left join public.attempt_answers aa on aa.attempt_id = a.id and aa.question_id = q.id) end)
  from public.attempts a
  join public.lessons l on l.id = a.lesson_id
  join public.subjects sj on sj.id = l.subject_id
  where a.id = p_attempt_id
$$;

create or replace function public.finish_attempt(p_attempt_id uuid)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_attempt public.attempts;
  v_correct int;
  v_score   int;
  v_ranked  boolean;
begin
  select * into v_attempt from public.attempts where id = p_attempt_id for update;
  if not found then
    raise exception 'attempt_not_found';
  end if;

  if v_attempt.completed_at is null then
    select count(*) filter (where is_correct), coalesce(sum(score_awarded), 0)
      into v_correct, v_score
      from public.attempt_answers where attempt_id = p_attempt_id;

    -- Chỉ lượt hoàn thành đầu tiên của mỗi bài được tính xếp hạng (chống "cày" điểm).
    v_ranked := v_attempt.is_ranked and not exists (
      select 1 from public.attempts
       where student_id = v_attempt.student_id and lesson_id = v_attempt.lesson_id
         and exercise_type = v_attempt.exercise_type and is_ranked
         and completed_at is not null and id <> v_attempt.id);

    update public.attempts
       set completed_at     = now(),
           correct_count    = v_correct,
           wrong_count      = total_questions - v_correct,
           score            = v_score,
           is_ranked        = v_ranked,
           duration_seconds = least(10800, extract(epoch from (now() - started_at))::int)
     where id = p_attempt_id;
  end if;

  return public.get_attempt_result(p_attempt_id);
end $$;

create or replace function public.get_leaderboard(p_period text, p_student_id uuid default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_range record;
  v_me    jsonb;
  v_rows  jsonb;
begin
  select * into v_range from public.period_range(p_period);
  if not (select leaderboard_enabled from public.app_settings where id = 1) and not public.is_admin() then
    return jsonb_build_object('enabled', false, 'period', p_period, 'rows', '[]'::jsonb);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'student_id', student_id, 'full_name', full_name, 'display_name', display_name,
           'score', score, 'lessons_done', lessons_done,
           'accuracy', case when total > 0 then round(100.0 * correct / total) else 0 end,
           'rank', rank)), '[]'::jsonb)
    into v_rows
    from (select * from public.leaderboard_rows(p_period) limit 50) t;

  if p_student_id is not null then
    select jsonb_build_object('rank', rank, 'score', score) into v_me
      from public.leaderboard_rows(p_period) where student_id = p_student_id;
  end if;

  return jsonb_build_object('enabled', true, 'period', p_period,
                            'start', v_range.r_start, 'end', v_range.r_end,
                            'rows', v_rows, 'me', v_me);
end $$;

-- ---------------------------------------------------------------------
-- 4. API CHO ADMIN
-- ---------------------------------------------------------------------

create or replace function public.admin_dashboard()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_day  record;
  v_week record;
  v_set  public.app_settings;
begin
  perform public.require_admin();
  select * into v_set from public.app_settings where id = 1;
  select * into v_day from public.period_range('day');
  select * into v_week from public.period_range('week');

  return jsonb_build_object(
    'total_students', (select count(*) from public.students where is_active),
    'current_week', v_set.current_week,
    'today', (
      select jsonb_build_object(
        'active_students', count(distinct a.student_id),
        'attempts_completed', count(*) filter (where a.completed_at is not null),
        'answers', (select count(*) from public.attempt_answers aa
                     where aa.answered_at >= v_day.r_start and aa.answered_at < v_day.r_end),
        'accuracy', (select case when count(*) > 0 then round(100.0 * count(*) filter (where aa.is_correct) / count(*)) end
                       from public.attempt_answers aa
                      where aa.answered_at >= v_day.r_start and aa.answered_at < v_day.r_end))
        from public.attempts a
       where a.started_at >= v_day.r_start and a.started_at < v_day.r_end),
    'week', (
      select jsonb_build_object(
        'active_students', count(distinct a.student_id),
        'attempts_completed', count(*) filter (where a.completed_at is not null),
        'accuracy', (select case when count(*) > 0 then round(100.0 * count(*) filter (where aa.is_correct) / count(*)) end
                       from public.attempt_answers aa
                      where aa.answered_at >= v_week.r_start and aa.answered_at < v_week.r_end))
        from public.attempts a
       where a.started_at >= v_week.r_start and a.started_at < v_week.r_end),
    'question_count', (select count(*) from public.questions where is_active),
    'lesson_count', (select count(*) from public.lessons),
    'published_count', (select count(*) from public.lessons where is_published),
    'hardest', (
      select coalesce(jsonb_agg(h order by (h->>'wrong_rate')::numeric desc), '[]'::jsonb) from (
        select jsonb_build_object(
                 'question_id', q.id, 'text', q.question_text, 'lesson_name', l.name,
                 'week_number', l.week_number, 'answered', count(*),
                 'wrong', count(*) filter (where not aa.is_correct),
                 'wrong_rate', round(100.0 * count(*) filter (where not aa.is_correct) / count(*))) as h
          from public.attempt_answers aa
          join public.questions q on q.id = aa.question_id
          join public.lessons l on l.id = q.lesson_id
         group by q.id, q.question_text, l.name, l.week_number
        having count(*) >= 3 and count(*) filter (where not aa.is_correct) > 0
         order by 100.0 * count(*) filter (where not aa.is_correct) / count(*) desc
         limit 8) t),
    'inactive_today', (
      select coalesce(jsonb_agg(jsonb_build_object('id', s.id, 'display_name', s.display_name, 'full_name', s.full_name)
                                order by s.display_name), '[]'::jsonb)
        from public.students s
       where s.is_active
         and not exists (select 1 from public.attempts a where a.student_id = s.id
                          and a.started_at >= v_day.r_start and a.started_at < v_day.r_end)),
    'recent', (
      select coalesce(jsonb_agg(r order by r->>'completed_at' desc), '[]'::jsonb) from (
        select jsonb_build_object('id', a.id, 'student', s.display_name, 'lesson', l.name,
                                  'exercise_type', a.exercise_type, 'score', a.score,
                                  'correct_count', a.correct_count, 'total_questions', a.total_questions,
                                  'is_ranked', a.is_ranked, 'completed_at', a.completed_at) as r
          from public.attempts a
          join public.students s on s.id = a.student_id
          join public.lessons l on l.id = a.lesson_id
         where a.completed_at is not null
         order by a.completed_at desc limit 10) t));
end $$;

-- ---------------------------------------------------------------------
-- 5. VIEW CHO ADMIN (security_invoker => vẫn áp dụng RLS của bảng gốc)
-- ---------------------------------------------------------------------

create or replace view public.v_lessons with (security_invoker = true) as
select l.*,
       sj.code as subject_code, sj.name as subject_name, sj.color as subject_color, sj.sort_order as subject_sort,
       (select count(*) from public.questions q where q.lesson_id = l.id and q.is_active)                     as question_count,
       (select count(*) from public.questions q where q.lesson_id = l.id and q.is_active and q.difficulty = 1) as easy_count,
       (select count(*) from public.questions q where q.lesson_id = l.id and q.is_active and q.difficulty = 2) as normal_count,
       (select count(*) from public.questions q where q.lesson_id = l.id and q.is_active and q.difficulty = 3) as advanced_count,
       (select count(distinct a.student_id) from public.attempts a
         where a.lesson_id = l.id and a.completed_at is not null)                                               as students_done,
       (select round(100.0 * sum(a.correct_count) / nullif(sum(a.total_questions), 0)) from public.attempts a
         where a.lesson_id = l.id and a.completed_at is not null and a.is_ranked)                               as accuracy
  from public.lessons l join public.subjects sj on sj.id = l.subject_id;

create or replace view public.v_questions with (security_invoker = true) as
select q.*,
       l.name as lesson_name, l.week_number, l.lesson_order, l.subject_id,
       sj.code as subject_code, sj.name as subject_name,
       (select count(*) from public.attempt_answers aa where aa.question_id = q.id)                     as answered_count,
       (select count(*) from public.attempt_answers aa where aa.question_id = q.id and aa.is_correct)   as correct_count
  from public.questions q
  join public.lessons l on l.id = q.lesson_id
  join public.subjects sj on sj.id = l.subject_id;

create or replace view public.v_attempts with (security_invoker = true) as
select a.id, a.student_id, a.lesson_id, a.exercise_type, a.score, a.correct_count, a.wrong_count,
       a.total_questions, a.duration_seconds, a.is_ranked, a.started_at, a.completed_at,
       s.full_name as student_name, s.display_name as student_display_name,
       l.name as lesson_name, l.week_number, l.lesson_order, sj.name as subject_name
  from public.attempts a
  join public.students s on s.id = a.student_id
  join public.lessons l on l.id = a.lesson_id
  join public.subjects sj on sj.id = l.subject_id;

create or replace view public.v_student_stats with (security_invoker = true) as
select s.*,
       (select count(*) from public.attempts a where a.student_id = s.id and a.completed_at is not null)       as attempts_completed,
       (select coalesce(sum(a.score), 0) from public.attempts a where a.student_id = s.id and a.is_ranked
           and a.completed_at is not null)                                                                    as total_score,
       (select round(100.0 * sum(a.correct_count) / nullif(sum(a.total_questions), 0)) from public.attempts a
         where a.student_id = s.id and a.completed_at is not null)                                            as accuracy,
       (select max(a.started_at) from public.attempts a where a.student_id = s.id)                            as last_active_at
  from public.students s;

-- ---------------------------------------------------------------------
-- 6. BẢO MẬT: RLS + QUYỀN
-- ---------------------------------------------------------------------

alter table public.app_settings    enable row level security;
alter table public.subjects        enable row level security;
alter table public.lessons         enable row level security;
alter table public.questions       enable row level security;
alter table public.students        enable row level security;
alter table public.attempts        enable row level security;
alter table public.attempt_answers enable row level security;
alter table public.admins          enable row level security;

do $$
declare t text;
begin
  foreach t in array array['app_settings','subjects','lessons','questions','students','attempts','attempt_answers'] loop
    execute format('drop policy if exists admin_all on public.%I', t);
    execute format('create policy admin_all on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

drop policy if exists admin_self_read on public.admins;
create policy admin_self_read on public.admins for select to authenticated using (user_id = auth.uid());

revoke all on all tables in schema public from anon;
grant select, insert, update, delete on
  public.app_settings, public.subjects, public.lessons, public.questions,
  public.students, public.attempts, public.attempt_answers to authenticated;
grant select on public.admins to authenticated;
grant select on public.v_lessons, public.v_questions, public.v_attempts, public.v_student_stats to authenticated;

revoke execute on all functions in schema public from public, anon, authenticated;

grant execute on function
  public.get_public_config(),
  public.list_students(),
  public.register_student(text),
  public.get_student_home(uuid),
  public.start_attempt(uuid, uuid, text, text),
  public.submit_answer(uuid, uuid, text),
  public.finish_attempt(uuid),
  public.get_attempt_result(uuid),
  public.get_leaderboard(text, uuid)
to anon, authenticated;

grant execute on function
  public.is_admin(),
  public.admin_dashboard(),
  public.vn_lower(text),
  public.normalize_name(text),
  public.default_display_name(text),
  public.students_before_write(),
  public.touch_updated_at()
to authenticated;
