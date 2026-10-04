-- =====================================================================
-- 0006: LUẬT HỌC TẬP (đều chỉnh được trong trang admin → Cài đặt)
--  - Điểm lần làm đầu: Cơ bản dễ 1 / vừa 2 / khó 3; Nâng cao dễ 1 / vừa 3 / khó 4; sai trừ 1 điểm.
--  - Làm lại: không tính bảng xếp hạng, chỉ cộng sao (mỗi câu đúng 1 sao, hoặc 2 đúng +1 / 2 sai -1).
--  - 1 điểm = 1 sao, 100 sao = 1 kim cương. Huy chương tuần theo % điểm tối đa của các đề trong tuần.
--  - Giới hạn số đề mỗi môn mỗi ngày, khung giờ làm bài, cài đặt riêng từng môn, gợi ý độ khó.
-- Chạy sau 0001 → 0005. Chạy lại nhiều lần an toàn. Lỡ chạy lại 0001 thì chạy lại 0003 → 0006.
-- LẦN CHẠY ĐẦU: đổi thang điểm 10/15/25 sang 1/2/3 và TÍNH LẠI điểm mọi lượt đã làm theo luật mới.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. CẤU HÌNH
-- ---------------------------------------------------------------------

alter table public.app_settings
  add column if not exists adv_points_easy        int not null default 1 check (adv_points_easy between 0 and 1000),
  add column if not exists adv_points_normal      int not null default 3 check (adv_points_normal between 0 and 1000),
  add column if not exists adv_points_advanced    int not null default 4 check (adv_points_advanced between 0 and 1000),
  add column if not exists wrong_penalty          int not null default 1 check (wrong_penalty between 0 and 100),
  add column if not exists score_floor_zero       boolean not null default true,
  add column if not exists retake_mode            text not null default 'per_correct' check (retake_mode in ('per_correct', 'pair')),
  add column if not exists daily_max_lessons      int not null default 3 check (daily_max_lessons between 0 and 50),
  add column if not exists stars_per_diamond      int not null default 100 check (stars_per_diamond between 1 and 100000),
  add column if not exists medal_gold_pct         int not null default 80 check (medal_gold_pct between 0 and 100),
  add column if not exists medal_silver_pct       int not null default 70 check (medal_silver_pct between 0 and 100),
  add column if not exists medal_bronze_pct       int not null default 60 check (medal_bronze_pct between 0 and 100),
  add column if not exists medal_include_advanced boolean not null default false,
  add column if not exists schedule_enabled       boolean not null default true,
  -- Thứ theo ISO (1 = thứ Hai … 7 = Chủ nhật) → [giờ mở, giờ đóng]; thiếu ngày nào là ngày đó đóng cả ngày.
  add column if not exists schedule               jsonb not null default
    '{"1":["17:00","22:30"],"2":["17:00","22:30"],"3":["17:00","22:30"],"4":["17:00","22:30"],"5":["17:00","22:30"],"6":["00:00","24:00"],"7":["00:00","22:00"]}'::jsonb
    check (jsonb_typeof(schedule) = 'object'),
  add column if not exists adapt_min_answers      int not null default 10 check (adapt_min_answers between 1 and 10000),
  add column if not exists adapt_up_pct           int not null default 90 check (adapt_up_pct between 0 and 100),
  add column if not exists adapt_down_pct         int not null default 40 check (adapt_down_pct between 0 and 100),
  add column if not exists rules_version          int not null default 0;

alter table public.app_settings
  alter column points_easy set default 1,
  alter column points_normal set default 2,
  alter column points_advanced set default 3;

-- Cài đặt riêng từng môn: để trống (null) = theo cài đặt chung.
create table if not exists public.subject_settings (
  subject_id          uuid primary key references public.subjects(id) on delete cascade,
  daily_max_lessons   int check (daily_max_lessons between 0 and 50),
  basic_easy          int check (basic_easy between 0 and 50),
  basic_normal        int check (basic_normal between 0 and 50),
  basic_advanced      int check (basic_advanced between 0 and 50),
  adv_easy            int check (adv_easy between 0 and 50),
  adv_normal          int check (adv_normal between 0 and 50),
  adv_advanced        int check (adv_advanced between 0 and 50),
  points_easy         int check (points_easy between 0 and 1000),
  points_normal       int check (points_normal between 0 and 1000),
  points_advanced     int check (points_advanced between 0 and 1000),
  adv_points_easy     int check (adv_points_easy between 0 and 1000),
  adv_points_normal   int check (adv_points_normal between 0 and 1000),
  adv_points_advanced int check (adv_points_advanced between 0 and 1000),
  wrong_penalty       int check (wrong_penalty between 0 and 100),
  retake_mode         text check (retake_mode in ('per_correct', 'pair')),
  updated_at          timestamptz not null default now()
);

-- Tuần lịch (thứ Hai) ↔ "Tuần học" của lớp lúc đó: để biết tuần nào phát huy chương cho những bài nào.
create table if not exists public.week_log (
  week_start date primary key,
  class_week int  not null check (class_week between 1 and 60),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_subject_settings_touch on public.subject_settings;
create trigger trg_subject_settings_touch before update on public.subject_settings
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------
-- 2. HÀM TIỆN ÍCH
-- ---------------------------------------------------------------------

create or replace function public.class_tz()
returns text language sql stable security definer set search_path = public as $$
  select coalesce((select timezone from public.app_settings where id = 1), 'Asia/Ho_Chi_Minh')
$$;

create or replace function public.week_start_of(p_ts timestamptz)
returns date language sql stable security definer set search_path = public as $$
  select date_trunc('week', p_ts at time zone public.class_tz())::date
$$;

create or replace function public.app_settings_log_week()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.current_week is distinct from old.current_week then
    insert into public.week_log (week_start, class_week) values (public.week_start_of(now()), new.current_week)
    on conflict (week_start) do update set class_week = excluded.class_week, updated_at = now();
  end if;
  return new;
end $$;

drop trigger if exists trg_settings_log_week on public.app_settings;
create trigger trg_settings_log_week after update on public.app_settings
  for each row execute function public.app_settings_log_week();

-- Cài đặt chung + phần ghi đè của môn, trả về cùng kiểu với app_settings.
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

create or replace function public.question_points_for(q public.questions, s public.app_settings, p_type text)
returns int language sql stable as $$
  select coalesce(q.points,
                  case when p_type = 'advanced' then
                         case q.difficulty when 1 then s.adv_points_easy when 2 then s.adv_points_normal else s.adv_points_advanced end
                       else
                         case q.difficulty when 1 then s.points_easy when 2 then s.points_normal else s.points_advanced end
                  end)
$$;

-- p_mode: 'ranked' (lần đầu) | 'per_correct' | 'pair' (làm lại; 'pair' được chốt cả bài lúc nộp).
create or replace function public.answer_points(q public.questions, s public.app_settings, p_type text, p_mode text, p_ok boolean)
returns int language sql stable as $$
  select case p_mode
           when 'ranked'      then case when p_ok then public.question_points_for(q, s, p_type) else -s.wrong_penalty end
           when 'per_correct' then case when p_ok then 1 else 0 end
           else 0
         end
$$;

-- ---------------------------------------------------------------------
-- 3. GIỜ LÀM BÀI + GIỚI HẠN MỖI NGÀY
-- ---------------------------------------------------------------------

create or replace function public.schedule_window(p_day date, out r_open timestamptz, out r_close timestamptz)
language plpgsql stable security definer set search_path = public as $$
declare
  v_e  jsonb;
  v_tz text := public.class_tz();
begin
  select schedule -> extract(isodow from p_day)::int::text into v_e from public.app_settings where id = 1;
  if v_e is null or jsonb_typeof(v_e) <> 'array' or jsonb_array_length(v_e) < 2 then
    return;
  end if;
  begin
    r_open  := (p_day + (v_e ->> 0)::time) at time zone v_tz;
    r_close := (p_day + (v_e ->> 1)::time) at time zone v_tz;
  exception when others then
    r_open := null; r_close := null;
    return;
  end;
  if r_close <= r_open then
    r_open := null; r_close := null;
  end if;
end $$;

create or replace function public.schedule_status()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_set   public.app_settings;
  v_today date;
  v_w     record;
  v_open  boolean := false;
  v_next  timestamptz;
  v_close timestamptz;
  i       int;
begin
  select * into v_set from public.app_settings where id = 1;
  if not v_set.schedule_enabled then
    return jsonb_build_object('enabled', false, 'open', true, 'schedule', v_set.schedule);
  end if;
  v_today := (now() at time zone public.class_tz())::date;
  for i in 0..7 loop
    select * into v_w from public.schedule_window(v_today + i);
    continue when v_w.r_open is null;
    if v_close is null then
      if now() < v_w.r_close then
        if now() >= v_w.r_open then
          v_open := true;
          v_close := v_w.r_close;
        else
          v_next := v_w.r_open;
          exit;
        end if;
      end if;
    elsif v_w.r_open <= v_close then
      -- Khung giờ nối liền qua nửa đêm (VD thứ Bảy 24:00 → Chủ nhật 00:00).
      v_close := greatest(v_close, v_w.r_close);
    else
      exit;
    end if;
  end loop;
  return jsonb_build_object('enabled', true, 'open', v_open, 'closes_at', v_close, 'next_open_at', v_next,
                            'schedule', v_set.schedule);
end $$;

create or replace function public.is_open_now()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((public.schedule_status() ->> 'open')::boolean, true)
$$;

-- Số đề của môn bạn đã BẮT ĐẦU hôm nay (cả làm lại; tiếp tục bài dở không tính thêm).
create or replace function public.daily_used(p_student_id uuid, p_subject_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int
    from public.attempts a
    join public.lessons l on l.id = a.lesson_id
    cross join public.period_range('day') r
   where a.student_id = p_student_id and l.subject_id = p_subject_id
     and a.started_at >= r.r_start and a.started_at < r.r_end
$$;

-- ---------------------------------------------------------------------
-- 4. CHẤM ĐIỂM
-- ---------------------------------------------------------------------

-- Tính lại điểm từng câu + tổng điểm của 1 lượt theo luật hiện tại (dùng khi nộp bài và khi đổi luật).
create or replace function public.rescore_attempt(p_attempt_id uuid)
returns int language plpgsql volatile security definer set search_path = public as $$
declare
  v_a       public.attempts;
  v_set     public.app_settings;
  v_subject uuid;
  v_mode    text;
  v_correct int;
  v_wrong   int;
  v_score   int;
begin
  select * into v_a from public.attempts where id = p_attempt_id;
  if not found then
    return 0;
  end if;
  select l.subject_id into v_subject from public.lessons l where l.id = v_a.lesson_id;
  v_set := public.effective_settings(v_subject);
  v_mode := case when v_a.is_ranked then 'ranked' else v_set.retake_mode end;

  update public.attempt_answers aa
     set score_awarded = public.answer_points(q, v_set, v_a.exercise_type, v_mode, aa.is_correct)
    from public.questions q
   where aa.attempt_id = p_attempt_id and q.id = aa.question_id;

  select count(*) filter (where is_correct), count(*) filter (where not is_correct), coalesce(sum(score_awarded), 0)
    into v_correct, v_wrong, v_score
    from public.attempt_answers where attempt_id = p_attempt_id;
  if v_mode = 'pair' then
    v_score := v_correct / 2 - v_wrong / 2;
  end if;
  if v_set.score_floor_zero then
    v_score := greatest(0, v_score);
  end if;

  update public.attempts
     set score = v_score, correct_count = v_correct, wrong_count = total_questions - v_correct
   where id = p_attempt_id;
  return v_score;
end $$;

-- ---------------------------------------------------------------------
-- 5. HUY CHƯƠNG TUẦN + SAO / KIM CƯƠNG
-- ---------------------------------------------------------------------

-- Điểm tối đa ước tính của 1 đề (theo tỉ lệ câu và số câu có sẵn; thiếu câu thì bù câu dễ trước).
create or replace function public.lesson_max_score(p_lesson_id uuid, p_type text)
returns int language plpgsql stable security definer set search_path = public as $$
declare
  v_set     public.app_settings;
  v_subject uuid;
  v_av      int[];
  v_n       int[];
  v_pts     int[];
  v_take    int[] := array[0, 0, 0];
  v_total   int;
  v_left    int;
  v_add     int;
  d         int;
begin
  select l.subject_id into v_subject from public.lessons l where l.id = p_lesson_id;
  if not found then
    return 0;
  end if;
  v_set := public.effective_settings(v_subject);
  select array[count(*) filter (where difficulty = 1), count(*) filter (where difficulty = 2), count(*) filter (where difficulty = 3)]::int[]
    into v_av
    from public.questions where lesson_id = p_lesson_id and is_active;
  if p_type = 'advanced' then
    if v_av[2] + v_av[3] = 0 then
      return 0;
    end if;
    v_n   := array[v_set.adv_easy, v_set.adv_normal, v_set.adv_advanced];
    v_pts := array[v_set.adv_points_easy, v_set.adv_points_normal, v_set.adv_points_advanced];
  else
    v_n   := array[v_set.basic_easy, v_set.basic_normal, v_set.basic_advanced];
    v_pts := array[v_set.points_easy, v_set.points_normal, v_set.points_advanced];
  end if;
  v_total := least(greatest(1, v_n[1] + v_n[2] + v_n[3]), v_av[1] + v_av[2] + v_av[3]);
  for d in 1..3 loop
    v_take[d] := least(v_n[d], v_av[d]);
  end loop;
  v_left := v_total - (v_take[1] + v_take[2] + v_take[3]);
  for d in 1..3 loop
    exit when v_left <= 0;
    v_add := least(v_left, v_av[d] - v_take[d]);
    v_take[d] := v_take[d] + v_add;
    v_left := v_left - v_add;
  end loop;
  return v_take[1] * v_pts[1] + v_take[2] * v_pts[2] + v_take[3] * v_pts[3];
end $$;

-- Tuần học của lớp ứng với tuần lịch + tổng điểm tối đa của tất cả đề tuần đó.
create or replace function public.week_medal_base(p_week_start date, out class_week int, out max_score bigint)
language plpgsql stable security definer set search_path = public as $$
declare
  v_set public.app_settings;
begin
  select * into v_set from public.app_settings where id = 1;
  select wl.class_week into class_week from public.week_log wl where wl.week_start = p_week_start;
  if class_week is null and p_week_start = public.week_start_of(now()) then
    class_week := v_set.current_week;
  end if;
  if class_week is null then
    max_score := 0;
    return;
  end if;
  select coalesce(sum(public.lesson_max_score(l.id, 'basic')
                      + case when v_set.medal_include_advanced then public.lesson_max_score(l.id, 'advanced') else 0 end), 0)
    into max_score
    from public.lessons l
   where l.week_number = week_medal_base.class_week and l.is_published;
end $$;

create or replace function public.medal_for(p_pct numeric, s public.app_settings)
returns text language sql stable as $$
  select case when p_pct > s.medal_gold_pct   then 'gold'
              when p_pct > s.medal_silver_pct then 'silver'
              when p_pct > s.medal_bronze_pct then 'bronze'
              else 'encourage' end
$$;

-- Huy chương của tuần bắt đầu p_week_start: điểm lần đầu của các đề tuần đó (làm trong tuần) / điểm tối đa.
-- Chỉ bạn đã làm ít nhất 1 đề trong tuần mới có dòng.
create or replace function public.weekly_medals(p_week_start date, p_student_id uuid default null)
returns table (student_id uuid, full_name text, display_name text, score bigint, max_score bigint,
               pct numeric, medal text, class_week int)
language plpgsql stable security definer set search_path = public as $$
#variable_conflict use_column
declare
  v_set   public.app_settings;
  v_base  record;
  v_tz    text := public.class_tz();
  v_start timestamptz := p_week_start::timestamp at time zone v_tz;
  v_end   timestamptz := (p_week_start + 7)::timestamp at time zone v_tz;
begin
  select * into v_set from public.app_settings where id = 1;
  select * into v_base from public.week_medal_base(p_week_start);
  if v_base.class_week is null or v_base.max_score <= 0 then
    return;
  end if;
  return query
    select s.id, s.full_name, s.display_name, t.sc, v_base.max_score,
           round(least(100, 100.0 * greatest(t.sc, 0) / v_base.max_score), 1),
           public.medal_for(100.0 * t.sc / v_base.max_score, v_set),
           v_base.class_week
      from (select a.student_id as sid, sum(a.score)::bigint as sc
              from public.attempts a
              join public.lessons l on l.id = a.lesson_id
             where a.is_ranked
               and a.completed_at >= v_start and a.completed_at < v_end
               and l.week_number = v_base.class_week
               and (v_set.medal_include_advanced or a.exercise_type = 'basic')
               and (p_student_id is null or a.student_id = p_student_id)
             group by a.student_id) t
      join public.students s on s.id = t.sid
     where s.is_active
       and not public.is_guest_name(s.full_name)  -- bạn khách (tên có dấu "-") không xét huy chương
     order by t.sc desc, s.display_name;
end $$;

create or replace function public.student_rewards(p_student_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_set    public.app_settings;
  v_tz     text := public.class_tz();
  v_cur    date := public.week_start_of(now());
  v_stars  bigint;
  v_base   record;
  v_this   jsonb;
  v_last   jsonb;
  v_counts jsonb;
  v_guest  boolean;
begin
  select * into v_set from public.app_settings where id = 1;
  select greatest(0, coalesce(sum(a.score), 0)) into v_stars
    from public.attempts a where a.student_id = p_student_id and a.completed_at is not null;
  select public.is_guest_name(s.full_name) into v_guest from public.students s where s.id = p_student_id;
  v_guest := coalesce(v_guest, false);

  select * into v_base from public.week_medal_base(v_cur);
  select to_jsonb(m) into v_this from public.weekly_medals(v_cur, p_student_id) m;
  if v_this is null and not v_guest and coalesce(v_base.max_score, 0) > 0 then
    v_this := jsonb_build_object('score', 0, 'max_score', v_base.max_score, 'pct', 0, 'medal', null,
                                 'class_week', v_base.class_week);
  end if;
  select to_jsonb(m) into v_last from public.weekly_medals(v_cur - 7, p_student_id) m;

  select coalesce(jsonb_object_agg(x.medal, x.n), '{}'::jsonb) into v_counts
    from (select m.medal, count(*) as n
            from public.week_log wl
            cross join lateral public.weekly_medals(wl.week_start, p_student_id) m
           where wl.week_start < v_cur
             and exists (select 1 from public.attempts a
                          where a.student_id = p_student_id and a.is_ranked
                            and a.completed_at >= wl.week_start::timestamp at time zone v_tz
                            and a.completed_at <  (wl.week_start + 7)::timestamp at time zone v_tz)
           group by m.medal) x;

  return jsonb_build_object(
    'stars_total', v_stars,
    'stars_per_diamond', v_set.stars_per_diamond,
    'diamonds', v_stars / v_set.stars_per_diamond,
    'stars', v_stars % v_set.stars_per_diamond,
    'thresholds', jsonb_build_object('gold', v_set.medal_gold_pct, 'silver', v_set.medal_silver_pct,
                                     'bronze', v_set.medal_bronze_pct),
    'medal_eligible', not v_guest,
    'this_week', v_this,
    'last_week', v_last,
    'medal_counts', v_counts);
end $$;

-- ---------------------------------------------------------------------
-- 6. API HỌC SINH (viết lại, giữ nguyên tham số)
-- ---------------------------------------------------------------------

create or replace function public.get_public_config()
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'class_name', class_name,
    'school_year', school_year,
    'current_week', current_week,
    'leaderboard_enabled', leaderboard_enabled,
    'allow_self_register', allow_self_register,
    'stars_per_diamond', stars_per_diamond)
  from public.app_settings where id = 1
$$;

create or replace function public.attempt_payload(p_attempt_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_a    public.attempts;
  v_l    public.lessons;
  v_sj   public.subjects;
  v_set  public.app_settings;
  v_mode text;
begin
  select * into v_a from public.attempts where id = p_attempt_id;
  if not found then
    return null;
  end if;
  select * into v_l from public.lessons where id = v_a.lesson_id;
  select * into v_sj from public.subjects where id = v_l.subject_id;
  v_set := public.effective_settings(v_l.subject_id);
  v_mode := case when v_a.is_ranked then 'ranked' else v_set.retake_mode end;

  return jsonb_build_object(
    'attempt_id', v_a.id,
    'is_ranked', v_a.is_ranked,
    'exercise_type', v_a.exercise_type,
    'completed', v_a.completed_at is not null,
    'scoring', jsonb_build_object('mode', v_mode,
                                  'wrong_penalty', case when v_mode = 'ranked' then v_set.wrong_penalty else 0 end,
                                  'floor_zero', v_set.score_floor_zero),
    'lesson', jsonb_build_object('id', v_l.id, 'name', v_l.name, 'week_number', v_l.week_number,
                                 'lesson_order', v_l.lesson_order, 'subject_name', v_sj.name, 'subject_color', v_sj.color),
    'questions', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'id', q.id,
               'type', q.question_type,
               'text', q.question_text,
               'difficulty', q.difficulty,
               'points', case v_mode when 'ranked' then public.question_points_for(q, v_set, v_a.exercise_type)
                                     when 'per_correct' then 1 else null end,
               'options', case when q.question_type = 'multiple_choice'
                               then (select jsonb_agg(o) from unnest(array[q.option_a, q.option_b, q.option_c, q.option_d]) o
                                      where o is not null and btrim(o) <> '')
                               else null end
             ) order by ord.i), '[]'::jsonb)
        from unnest(v_a.question_ids) with ordinality as ord(qid, i)
        join public.questions q on q.id = ord.qid),
    'answered', (
      select coalesce(jsonb_object_agg(aa.question_id, jsonb_build_object(
               'is_correct', aa.is_correct,
               'student_answer', aa.student_answer,
               'correct_answer', q.correct_answer,
               'explanation', q.explanation,
               'score_awarded', aa.score_awarded)), '{}'::jsonb)
        from public.attempt_answers aa join public.questions q on q.id = aa.question_id
       where aa.attempt_id = v_a.id));
end $$;

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
  -- Khoá dòng học sinh để 2 lượt bắt đầu cùng lúc không vượt giới hạn mỗi ngày.
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

create or replace function public.submit_answer(p_attempt_id uuid, p_question_id uuid, p_answer text)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_attempt public.attempts;
  v_q       public.questions;
  v_set     public.app_settings;
  v_subject uuid;
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

  select l.subject_id into v_subject from public.lessons l where l.id = v_attempt.lesson_id;
  v_set := public.effective_settings(v_subject);
  v_ok := public.check_answer(v_q, v_answer);
  v_score := public.answer_points(v_q, v_set, v_attempt.exercise_type,
                                  case when v_attempt.is_ranked then 'ranked' else v_set.retake_mode end, v_ok);

  insert into public.attempt_answers (attempt_id, question_id, student_answer, is_correct, score_awarded)
  values (p_attempt_id, p_question_id, v_answer, v_ok, v_score);

  return jsonb_build_object('is_correct', v_ok, 'correct_answer', v_q.correct_answer,
                            'explanation', v_q.explanation, 'score_awarded', v_score,
                            'student_answer', v_answer);
end $$;

create or replace function public.get_attempt_result(p_attempt_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_a       public.attempts;
  v_l       public.lessons;
  v_sj      public.subjects;
  v_set     public.app_settings;
  v_mode    text;
  v_max     int;
  v_correct int;
  v_wrong   int;
  v_gain    int;
  v_lost    int;
begin
  select * into v_a from public.attempts where id = p_attempt_id;
  if not found then
    return null;
  end if;
  select * into v_l from public.lessons where id = v_a.lesson_id;
  select * into v_sj from public.subjects where id = v_l.subject_id;
  v_set := public.effective_settings(v_l.subject_id);
  v_mode := case when v_a.is_ranked then 'ranked' else v_set.retake_mode end;

  if v_mode = 'ranked' then
    select coalesce(sum(public.question_points_for(q, v_set, v_a.exercise_type)), 0) into v_max
      from public.questions q where q.id = any (v_a.question_ids);
  elsif v_mode = 'per_correct' then
    v_max := v_a.total_questions;
  else
    v_max := v_a.total_questions / 2;
  end if;

  select count(*) filter (where is_correct), count(*) filter (where not is_correct),
         coalesce(sum(score_awarded) filter (where score_awarded > 0), 0),
         coalesce(-sum(score_awarded) filter (where score_awarded < 0), 0)
    into v_correct, v_wrong, v_gain, v_lost
    from public.attempt_answers where attempt_id = p_attempt_id;
  if v_mode = 'pair' then
    v_gain := v_correct / 2;
    v_lost := v_wrong / 2;
  end if;

  return jsonb_build_object(
    'attempt_id', v_a.id,
    'student_id', v_a.student_id,
    'is_ranked', v_a.is_ranked,
    'exercise_type', v_a.exercise_type,
    'completed', v_a.completed_at is not null,
    'score', v_a.score,
    'correct_count', v_a.correct_count,
    'wrong_count', v_a.wrong_count,
    'total_questions', v_a.total_questions,
    'duration_seconds', v_a.duration_seconds,
    'completed_at', v_a.completed_at,
    'max_score', v_max,
    'scoring', jsonb_build_object('mode', v_mode,
                                  'wrong_penalty', case when v_mode = 'ranked' then v_set.wrong_penalty else 0 end,
                                  'floor_zero', v_set.score_floor_zero),
    'points_gained', v_gain,
    'points_lost', v_lost,
    'lesson', jsonb_build_object('id', v_l.id, 'name', v_l.name, 'week_number', v_l.week_number,
                                 'lesson_order', v_l.lesson_order, 'subject_name', v_sj.name, 'subject_color', v_sj.color),
    'review', case when v_a.completed_at is null then '[]'::jsonb else (
      select coalesce(jsonb_agg(jsonb_build_object(
               'question_id', q.id,
               'type', q.question_type,
               'text', q.question_text,
               'student_answer', aa.student_answer,
               'correct_answer', q.correct_answer,
               'is_correct', coalesce(aa.is_correct, false),
               'explanation', q.explanation,
               'score_awarded', coalesce(aa.score_awarded, 0)) order by ord.i), '[]'::jsonb)
        from unnest(v_a.question_ids) with ordinality as ord(qid, i)
        join public.questions q on q.id = ord.qid
        left join public.attempt_answers aa on aa.attempt_id = v_a.id and aa.question_id = q.id) end);
end $$;

create or replace function public.finish_attempt(p_attempt_id uuid)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  v_attempt public.attempts;
  v_ranked  boolean;
begin
  select * into v_attempt from public.attempts where id = p_attempt_id for update;
  if not found then
    raise exception 'attempt_not_found';
  end if;

  if v_attempt.completed_at is null then
    -- Chỉ lượt hoàn thành đầu tiên của mỗi bài được tính xếp hạng (chống "cày" điểm).
    v_ranked := v_attempt.is_ranked and not exists (
      select 1 from public.attempts
       where student_id = v_attempt.student_id and lesson_id = v_attempt.lesson_id
         and exercise_type = v_attempt.exercise_type and is_ranked
         and completed_at is not null and id <> v_attempt.id);

    update public.attempts
       set completed_at     = now(),
           is_ranked        = v_ranked,
           duration_seconds = least(10800, extract(epoch from (now() - started_at))::int)
     where id = p_attempt_id;
    perform public.rescore_attempt(p_attempt_id);
  end if;

  return public.get_attempt_result(p_attempt_id);
end $$;

-- Giống 0005, thêm: phần thưởng (sao/kim cương/huy chương), giờ làm bài, lượt còn lại hôm nay theo môn.
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

-- ---------------------------------------------------------------------
-- 7. API ADMIN
-- ---------------------------------------------------------------------

create or replace function public.admin_weekly_medals(p_week_start date default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_set  public.app_settings;
  v_cur  date := public.week_start_of(now());
  v_week date;
  v_base record;
  v_rows jsonb;
  v_weeks jsonb;
begin
  perform public.require_admin();
  select * into v_set from public.app_settings where id = 1;
  v_week := public.week_start_of(coalesce(p_week_start, v_cur)::timestamp at time zone public.class_tz());
  select * into v_base from public.week_medal_base(v_week);

  select coalesce(jsonb_agg(to_jsonb(m) || jsonb_build_object('is_guest', public.is_guest_name(m.full_name))
                            order by m.score desc, m.display_name), '[]'::jsonb)
    into v_rows
    from public.weekly_medals(v_week, null) m;

  select coalesce(jsonb_agg(jsonb_build_object('week_start', w.week_start, 'class_week', w.class_week)
                            order by w.week_start desc), '[]'::jsonb)
    into v_weeks
    from (select wl.week_start, wl.class_week from public.week_log wl
          union
          select v_cur, v_set.current_week where not exists (select 1 from public.week_log where week_start = v_cur)) w;

  return jsonb_build_object(
    'week_start', v_week,
    'is_current', v_week = v_cur,
    'class_week', v_base.class_week,
    'max_score', v_base.max_score,
    'include_advanced', v_set.medal_include_advanced,
    'thresholds', jsonb_build_object('gold', v_set.medal_gold_pct, 'silver', v_set.medal_silver_pct,
                                     'bronze', v_set.medal_bronze_pct),
    'rows', v_rows,
    'weeks', v_weeks);
end $$;

-- Sửa "tuần học" dùng để tính huy chương của 1 tuần lịch (VD lỡ đổi tuần học sớm vào tối Chủ nhật).
create or replace function public.admin_set_week_class(p_week_start date, p_class_week int)
returns void language plpgsql volatile security definer set search_path = public as $$
begin
  perform public.require_admin();
  if p_class_week is null or p_class_week not between 1 and 60 then
    raise exception 'invalid_week';
  end if;
  insert into public.week_log (week_start, class_week)
  values (public.week_start_of(p_week_start::timestamp at time zone public.class_tz()), p_class_week)
  on conflict (week_start) do update set class_week = excluded.class_week, updated_at = now();
end $$;

-- ---------------------------------------------------------------------
-- 8. LẦN CHẠY ĐẦU: đổi thang điểm + tính lại điểm các lượt đã làm
-- ---------------------------------------------------------------------

do $$
begin
  if (select rules_version from public.app_settings where id = 1) < 6 then
    update public.app_settings
       set points_easy = 1, points_normal = 2, points_advanced = 3, rules_version = 6
     where id = 1;
    perform public.rescore_attempt(a.id) from public.attempts a where a.completed_at is not null;
  end if;
end $$;

insert into public.week_log (week_start, class_week)
select public.week_start_of(now()), current_week from public.app_settings where id = 1
on conflict (week_start) do nothing;

-- ---------------------------------------------------------------------
-- 9. BẢO MẬT
-- ---------------------------------------------------------------------

alter table public.subject_settings enable row level security;
alter table public.week_log         enable row level security;

do $$
declare t text;
begin
  foreach t in array array['subject_settings','week_log'] loop
    execute format('drop policy if exists admin_all on public.%I', t);
    execute format('create policy admin_all on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

revoke all on public.subject_settings, public.week_log from anon;
grant select, insert, update, delete on public.subject_settings, public.week_log to authenticated;

revoke execute on function
  public.class_tz(),
  public.week_start_of(timestamptz),
  public.app_settings_log_week(),
  public.effective_settings(uuid),
  public.question_points_for(public.questions, public.app_settings, text),
  public.answer_points(public.questions, public.app_settings, text, text, boolean),
  public.schedule_window(date),
  public.schedule_status(),
  public.is_open_now(),
  public.daily_used(uuid, uuid),
  public.rescore_attempt(uuid),
  public.lesson_max_score(uuid, text),
  public.week_medal_base(date),
  public.medal_for(numeric, public.app_settings),
  public.weekly_medals(date, uuid),
  public.student_rewards(uuid),
  public.get_public_config(),
  public.attempt_payload(uuid),
  public.start_attempt(uuid, uuid, text, text),
  public.submit_answer(uuid, uuid, text),
  public.get_attempt_result(uuid),
  public.finish_attempt(uuid),
  public.get_student_home(uuid),
  public.admin_weekly_medals(date),
  public.admin_set_week_class(date, int)
from public, anon, authenticated;

grant execute on function
  public.get_public_config(),
  public.start_attempt(uuid, uuid, text, text),
  public.submit_answer(uuid, uuid, text),
  public.get_attempt_result(uuid),
  public.finish_attempt(uuid),
  public.get_student_home(uuid)
to anon, authenticated;

grant execute on function
  public.app_settings_log_week(),
  public.admin_weekly_medals(date),
  public.admin_set_week_class(date, int)
to authenticated;
