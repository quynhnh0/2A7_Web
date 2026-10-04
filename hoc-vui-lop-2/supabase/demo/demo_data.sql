-- Dữ liệu giả lập cho CHẾ ĐỘ DEMO (không chạy trên Supabase thật).
insert into public.students (full_name) values
  ('Nguyễn Minh Anh'),
  ('Trần Gia Huy'),
  ('Lê Hà My'),
  ('Đỗ Đăng Khoa'),
  ('Bùi Bảo Hân'),
  ('Phạm Phúc An'),
  ('Trịnh Thùy Linh'),
  ('Vũ Đức Trí'),
  ('Hoàng Khánh Vy'),
  ('Ngô Tuấn Kiệt'),
  ('Đặng Ngọc Diệp'),
  ('Phan Minh Khang'),
  ('Võ Thảo Nhi'),
  ('Dương Quốc Bảo'),
  ('Lý Mai Chi'),
  ('Hồ Nhật Nam'),
  ('Mai Tường Vi'),
  ('Đinh Hoàng Long'),
  ('Cao Bảo Ngọc'),
  ('Tạ Anh Thư')
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
