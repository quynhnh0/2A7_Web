-- =====================================================================
-- XÁC NHẬN NGÀY SINH khi học sinh chọn tên.
-- Bạn nào đã có ngày sinh thì phải nhập đúng NGÀY + THÁNG sinh mới vào được;
-- bạn chưa có ngày sinh vào như cũ. Ngày sinh không bao giờ gửi về trình duyệt học sinh,
-- máy chủ tự so sánh. Sai 5 lần liên tiếp thì khoá 5 phút.
-- Chạy SAU 0001_init.sql (và 0002). Chạy lại nhiều lần an toàn.
-- =====================================================================

alter table public.students add column if not exists birth_date date;
alter table public.students add column if not exists verify_fails smallint not null default 0;
alter table public.students add column if not exists verify_locked_until timestamptz;

create or replace function public.list_students()
returns jsonb language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'full_name', full_name, 'display_name', display_name,
                                               'needs_birthday', birth_date is not null)
                            order by display_name), '[]'::jsonb)
    from public.students where is_active
$$;

create or replace function public.verify_student(p_student_id uuid, p_day int, p_month int)
returns jsonb language plpgsql volatile security definer set search_path = public as $$
declare
  c_max_fails constant int := 5;
  c_lock      constant interval := interval '5 minutes';
  v     public.students;
  v_fails int;
begin
  select * into v from public.students where id = p_student_id and is_active for update;
  if not found then
    raise exception 'student_not_found';
  end if;

  if v.birth_date is not null then
    if v.verify_locked_until > now() then
      return jsonb_build_object('ok', false, 'remaining', 0,
                                'locked_seconds', ceil(extract(epoch from v.verify_locked_until - now()))::int);
    end if;

    if p_day is distinct from extract(day from v.birth_date)::int
       or p_month is distinct from extract(month from v.birth_date)::int then
      v_fails := case when v.verify_locked_until is not null then 1 else v.verify_fails + 1 end;
      if v_fails >= c_max_fails then
        update public.students set verify_fails = 0, verify_locked_until = now() + c_lock where id = v.id;
        return jsonb_build_object('ok', false, 'remaining', 0,
                                  'locked_seconds', extract(epoch from c_lock)::int);
      end if;
      update public.students set verify_fails = v_fails, verify_locked_until = null where id = v.id;
      return jsonb_build_object('ok', false, 'remaining', c_max_fails - v_fails, 'locked_seconds', 0);
    end if;

    if v.verify_fails <> 0 or v.verify_locked_until is not null then
      update public.students set verify_fails = 0, verify_locked_until = null where id = v.id;
    end if;
  end if;

  return jsonb_build_object('ok', true,
    'student', jsonb_build_object('id', v.id, 'full_name', v.full_name, 'display_name', v.display_name));
end $$;

-- Gõ lại đúng tên một bạn đã có ngày sinh thì không được vào thẳng (phải chọn tên + nhập ngày sinh).
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
    if v_row.birth_date is not null then
      raise exception 'student_exists';
    end if;
  else
    if not (select allow_self_register from public.app_settings where id = 1) then
      raise exception 'self_register_disabled';
    end if;
    insert into public.students (full_name) values (v_name) returning * into v_row;
  end if;

  return jsonb_build_object('id', v_row.id, 'full_name', v_row.full_name, 'display_name', v_row.display_name);
end $$;

-- s.* đã gồm cột mới nên phải tạo lại view (create or replace không đổi được thứ tự cột).
drop view if exists public.v_student_stats;
create view public.v_student_stats with (security_invoker = true) as
select s.*,
       (select count(*) from public.attempts a where a.student_id = s.id and a.completed_at is not null)       as attempts_completed,
       (select coalesce(sum(a.score), 0) from public.attempts a where a.student_id = s.id and a.is_ranked
           and a.completed_at is not null)                                                                    as total_score,
       (select round(100.0 * sum(a.correct_count) / nullif(sum(a.total_questions), 0)) from public.attempts a
         where a.student_id = s.id and a.completed_at is not null)                                            as accuracy,
       (select max(a.started_at) from public.attempts a where a.student_id = s.id)                            as last_active_at
  from public.students s;

grant select on public.v_student_stats to authenticated;
revoke execute on function public.verify_student(uuid, int, int) from public;
grant execute on function public.verify_student(uuid, int, int) to anon, authenticated;
