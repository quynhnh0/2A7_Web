-- =====================================================================
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

-- Toán • Tuần 1 • Bài 1: Ôn tập các số đến 100
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 1, 1, 'Ôn tập các số đến 100', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số gồm 8 chục và 4 đơn vị là số nào?', null, null, null, null, '84', null::jsonb, '8 chục là 80, thêm 4 đơn vị được 84.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  21  ___  12', '>', '<', '=', null, '>', null::jsonb, '21 > 12.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', 'Số gồm 6 chục và 4 đơn vị là số nào?', null, null, null, null, '64', null::jsonb, '6 chục là 60, thêm 4 đơn vị được 64.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  84  ___  48', '>', '<', '=', null, '>', null::jsonb, '84 > 48.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', 'Số gồm 7 chục và 6 đơn vị là số nào?', null, null, null, null, '76', null::jsonb, '7 chục là 70, thêm 6 đơn vị được 76.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  46  ___  64', '>', '<', '=', null, '<', null::jsonb, '46 < 64.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', 'Số gồm 3 chục và 6 đơn vị là số nào?', null, null, null, null, '36', null::jsonb, '3 chục là 30, thêm 6 đơn vị được 36.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  41  ___  14', '>', '<', '=', null, '>', null::jsonb, '41 > 14.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', 'Số gồm 8 chục và 0 đơn vị là số nào?', null, null, null, null, '80', null::jsonb, '8 chục là 80, thêm 0 đơn vị được 80.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  89  ___  98', '>', '<', '=', null, '<', null::jsonb, '89 < 98.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', 'Số gồm 8 chục và 3 đơn vị là số nào?', null, null, null, null, '83', null::jsonb, '8 chục là 80, thêm 3 đơn vị được 83.', 'so_den_100', 'rule:so_den_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  71  ___  17', '>', '<', '=', null, '>', null::jsonb, '71 > 17.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Số 53 gồm:', '3 chục và 5 đơn vị', '5 chục và 4 đơn vị', '5 chục và 3 đơn vị', '6 chục và 3 đơn vị', '5 chục và 3 đơn vị', null::jsonb, 'Chữ số 5 ở hàng chục, chữ số 3 ở hàng đơn vị.', 'so_den_100', 'rule:so_den_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  81 + 18  ___  99', '>', '<', '=', null, '=', null::jsonb, '81 + 18 = 99; 99 = 99.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Số 26 gồm:', '2 chục và 7 đơn vị', '2 chục và 6 đơn vị', '3 chục và 6 đơn vị', '6 chục và 2 đơn vị', '2 chục và 6 đơn vị', null::jsonb, 'Chữ số 2 ở hàng chục, chữ số 6 ở hàng đơn vị.', 'so_den_100', 'rule:so_den_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  44 + 31  ___  75', '>', '<', '=', null, '=', null::jsonb, '44 + 31 = 75; 75 = 75.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Số 23 gồm:', '2 chục và 3 đơn vị', '2 chục và 4 đơn vị', '3 chục và 2 đơn vị', '3 chục và 3 đơn vị', '2 chục và 3 đơn vị', null::jsonb, 'Chữ số 2 ở hàng chục, chữ số 3 ở hàng đơn vị.', 'so_den_100', 'rule:so_den_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  80 + 10  ___  90', '>', '<', '=', null, '=', null::jsonb, '80 + 10 = 90; 90 = 90.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Số 84 gồm:', '4 chục và 8 đơn vị', '9 chục và 4 đơn vị', '8 chục và 5 đơn vị', '8 chục và 4 đơn vị', '8 chục và 4 đơn vị', null::jsonb, 'Chữ số 8 ở hàng chục, chữ số 4 ở hàng đơn vị.', 'so_den_100', 'rule:so_den_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  40 + 49  ___  88', '>', '<', '=', null, '>', null::jsonb, '40 + 49 = 89; 89 > 88.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Số 21 gồm:', '3 chục và 1 đơn vị', '1 chục và 2 đơn vị', '2 chục và 1 đơn vị', '2 chục và 2 đơn vị', '2 chục và 1 đơn vị', null::jsonb, 'Chữ số 2 ở hàng chục, chữ số 1 ở hàng đơn vị.', 'so_den_100', 'rule:so_den_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  41 + 57  ___  98', '>', '<', '=', null, '=', null::jsonb, '41 + 57 = 98; 98 = 98.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Số tròn chục liền sau số 61 là số nào?', null, null, null, null, '70', null::jsonb, null, 'so_den_100', 'rule:so_den_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  88 + 11  ___  27 - 14', '>', '<', '=', null, '>', null::jsonb, '88 + 11 = 99; 27 - 14 = 13; 99 > 13.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Số tròn chục liền sau số 38 là số nào?', null, null, null, null, '40', null::jsonb, null, 'so_den_100', 'rule:so_den_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  76 + 23  ___  44 - 20', '>', '<', '=', null, '>', null::jsonb, '76 + 23 = 99; 44 - 20 = 24; 99 > 24.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Từ hai chữ số 1 và 3, viết được số lớn nhất có hai chữ số khác nhau là số nào?', null, null, null, null, '31', null::jsonb, 'Đặt chữ số lớn hơn ở hàng chục: 31.', 'so_den_100', 'rule:so_den_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  87 + 10  ___  95 - 65', '>', '<', '=', null, '>', null::jsonb, '87 + 10 = 97; 95 - 65 = 30; 97 > 30.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Số tròn chục liền sau số 11 là số nào?', null, null, null, null, '20', null::jsonb, null, 'so_den_100', 'rule:so_den_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  41 + 26  ___  54 - 23', '>', '<', '=', null, '>', null::jsonb, '41 + 26 = 67; 54 - 23 = 31; 67 > 31.', 'so_sanh', 'rule:so_sanh')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 1 and l.lesson_order = 1
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 1 • Bài 2: Tia số. Số liền trước, số liền sau
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 1, 2, 'Tia số. Số liền trước, số liền sau', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số liền sau của 12 là số nào?', null, null, null, null, '13', null::jsonb, 'Số liền sau thì hơn số đó 1 đơn vị: 12 + 1 = 13.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  20,  21,  22,  ___', null, null, null, null, '23', null::jsonb, 'Mỗi số hơn số trước 1 đơn vị.', 'day_so', 'rule:day_so'),
    (1::smallint, 'number', 'Số liền sau của 84 là số nào?', null, null, null, null, '85', null::jsonb, 'Số liền sau thì hơn số đó 1 đơn vị: 84 + 1 = 85.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  0,  10,  20,  ___', null, null, null, null, '30', null::jsonb, 'Mỗi số hơn số trước 10 đơn vị.', 'day_so', 'rule:day_so'),
    (1::smallint, 'number', 'Số liền trước của 47 là số nào?', null, null, null, null, '46', null::jsonb, 'Số liền trước thì kém số đó 1 đơn vị: 47 - 1 = 46.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  60,  70,  80,  ___', null, null, null, null, '90', null::jsonb, 'Mỗi số hơn số trước 10 đơn vị.', 'day_so', 'rule:day_so'),
    (1::smallint, 'number', 'Số liền trước của 45 là số nào?', null, null, null, null, '44', null::jsonb, 'Số liền trước thì kém số đó 1 đơn vị: 45 - 1 = 44.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  40,  50,  60,  ___', null, null, null, null, '70', null::jsonb, 'Mỗi số hơn số trước 10 đơn vị.', 'day_so', 'rule:day_so'),
    (1::smallint, 'number', 'Số liền trước của 26 là số nào?', null, null, null, null, '25', null::jsonb, 'Số liền trước thì kém số đó 1 đơn vị: 26 - 1 = 25.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  30,  40,  50,  ___', null, null, null, null, '60', null::jsonb, 'Mỗi số hơn số trước 10 đơn vị.', 'day_so', 'rule:day_so'),
    (1::smallint, 'number', 'Số liền sau của 46 là số nào?', null, null, null, null, '47', null::jsonb, 'Số liền sau thì hơn số đó 1 đơn vị: 46 + 1 = 47.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (1::smallint, 'number', 'Điền số tiếp theo:  89,  90,  91,  ___', null, null, null, null, '92', null::jsonb, 'Mỗi số hơn số trước 1 đơn vị.', 'day_so', 'rule:day_so'),
    (2::smallint, 'multiple_choice', 'Số liền trước của 20 là:', '10', '19', '18', '21', '19', null::jsonb, null, 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (2::smallint, 'number', 'Điền số còn thiếu:  0,  2,  ___,  6', null, null, null, null, '4', null::jsonb, 'Mỗi số hơn số trước 2 đơn vị.', 'day_so', 'rule:day_so'),
    (2::smallint, 'multiple_choice', 'Số liền trước của 40 là:', '39', '41', '38', '30', '39', null::jsonb, null, 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (2::smallint, 'number', 'Điền số còn thiếu:  18,  20,  ___,  24', null, null, null, null, '22', null::jsonb, 'Mỗi số hơn số trước 2 đơn vị.', 'day_so', 'rule:day_so'),
    (2::smallint, 'number', 'Ba số liên tiếp:  75,  ___,  77', null, null, null, null, '76', null::jsonb, null, 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (2::smallint, 'number', 'Điền số còn thiếu:  55,  60,  ___,  70', null, null, null, null, '65', null::jsonb, 'Mỗi số hơn số trước 5 đơn vị.', 'day_so', 'rule:day_so'),
    (2::smallint, 'number', 'Ba số liên tiếp:  35,  ___,  37', null, null, null, null, '36', null::jsonb, null, 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (2::smallint, 'number', 'Điền số còn thiếu:  26,  28,  ___,  32', null, null, null, null, '30', null::jsonb, 'Mỗi số hơn số trước 2 đơn vị.', 'day_so', 'rule:day_so'),
    (2::smallint, 'number', 'Ba số liên tiếp:  32,  ___,  34', null, null, null, null, '33', null::jsonb, null, 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (2::smallint, 'number', 'Điền số còn thiếu:  60,  65,  ___,  75', null, null, null, null, '70', null::jsonb, 'Mỗi số hơn số trước 5 đơn vị.', 'day_so', 'rule:day_so'),
    (3::smallint, 'number', 'Số liền trước của số liền trước 57 là số nào?', null, null, null, null, '55', null::jsonb, '57 → 56 → 55.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (3::smallint, 'number', 'Điền số tiếp theo:  50,  48,  46,  ___', null, null, null, null, '44', null::jsonb, 'Mỗi số kém số trước 2 đơn vị.', 'day_so', 'rule:day_so'),
    (3::smallint, 'number', 'Số liền sau của số liền sau 69 là số nào?', null, null, null, null, '71', null::jsonb, '69 → 70 → 71.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (3::smallint, 'number', 'Điền số tiếp theo:  90,  85,  80,  ___', null, null, null, null, '75', null::jsonb, 'Mỗi số kém số trước 5 đơn vị.', 'day_so', 'rule:day_so'),
    (3::smallint, 'number', 'Số liền sau của số liền sau 57 là số nào?', null, null, null, null, '59', null::jsonb, '57 → 58 → 59.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (3::smallint, 'number', 'Điền số tiếp theo:  46,  36,  26,  ___', null, null, null, null, '16', null::jsonb, 'Mỗi số kém số trước 10 đơn vị.', 'day_so', 'rule:day_so'),
    (3::smallint, 'number', 'Số liền sau của số liền trước 41 là số nào?', null, null, null, null, '41', null::jsonb, 'Số liền trước 41 là 40; số liền sau 40 là 41.', 'lien_truoc_lien_sau', 'rule:lien_truoc_lien_sau'),
    (3::smallint, 'number', 'Điền số tiếp theo:  16,  14,  12,  ___', null, null, null, null, '10', null::jsonb, 'Mỗi số kém số trước 2 đơn vị.', 'day_so', 'rule:day_so')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 1 and l.lesson_order = 2
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 2 • Bài 3: Các thành phần của phép cộng, phép trừ
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 2, 3, 'Các thành phần của phép cộng, phép trừ', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'multiple_choice', 'Trong phép tính 11 - 1 = 10, số 10 được gọi là:', 'Số bị trừ', 'Tổng', 'Số trừ', 'Hiệu', 'Hiệu', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 12 - 2 = 10, số 10 được gọi là:', 'Số bị trừ', 'Số trừ', 'Hiệu', 'Tổng', 'Hiệu', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 61 + 34 = 95, số 95 được gọi là:', 'Số trừ', 'Số hạng', 'Hiệu', 'Tổng', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 82 + 11 = 93, số 82 được gọi là:', 'Số hạng', 'Hiệu', 'Tổng', 'Số trừ', 'Số hạng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 53 + 14 = 67, số 67 được gọi là:', 'Tổng', 'Hiệu', 'Số hạng', 'Số trừ', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 51 - 30 = 21, số 51 được gọi là:', 'Số bị trừ', 'Số trừ', 'Hiệu', 'Tổng', 'Số bị trừ', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 12 + 2 = 14, số 14 được gọi là:', 'Số trừ', 'Số hạng', 'Tổng', 'Hiệu', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 15 + 1 = 16, số 16 được gọi là:', 'Số hạng', 'Hiệu', 'Số trừ', 'Tổng', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 33 - 20 = 13, số 13 được gọi là:', 'Số trừ', 'Hiệu', 'Số bị trừ', 'Tổng', 'Hiệu', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 88 - 46 = 42, số 46 được gọi là:', 'Tổng', 'Số bị trừ', 'Hiệu', 'Số trừ', 'Số trừ', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 14 + 31 = 45, số 45 được gọi là:', 'Tổng', 'Số trừ', 'Hiệu', 'Số hạng', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 21 + 23 = 44, số 21 được gọi là:', 'Tổng', 'Hiệu', 'Số trừ', 'Số hạng', 'Số hạng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Hiệu của 28 và 12 là bao nhiêu?', null, null, null, null, '16', null::jsonb, '28 - 12 = 16.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 31 và 62 là bao nhiêu?', null, null, null, null, '93', null::jsonb, '31 + 62 = 93.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 69 và 30 là bao nhiêu?', null, null, null, null, '99', null::jsonb, '69 + 30 = 99.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 73 và 11 là bao nhiêu?', null, null, null, null, '84', null::jsonb, '73 + 11 = 84.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Hiệu của 74 và 44 là bao nhiêu?', null, null, null, null, '30', null::jsonb, '74 - 44 = 30.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 83 và 10 là bao nhiêu?', null, null, null, null, '93', null::jsonb, '83 + 10 = 93.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Hiệu của 93 và 23 là bao nhiêu?', null, null, null, null, '70', null::jsonb, '93 - 23 = 70.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 41 và 14 là bao nhiêu?', null, null, null, null, '55', null::jsonb, '41 + 14 = 55.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 32 và 36 là bao nhiêu?', null, null, null, null, '68', null::jsonb, '32 + 36 = 68.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Tổng của 62 và 13 là bao nhiêu?', null, null, null, null, '75', null::jsonb, '62 + 13 = 75.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số trừ là 13, hiệu là 10. Số bị trừ là bao nhiêu?', null, null, null, null, '23', null::jsonb, '10 + 13 = 23.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số trừ là 20, hiệu là 11. Số bị trừ là bao nhiêu?', null, null, null, null, '31', null::jsonb, '11 + 20 = 31.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 84, tổng là 94. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '10', null::jsonb, '94 - 84 = 10.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số trừ là 23, hiệu là 13. Số bị trừ là bao nhiêu?', null, null, null, null, '36', null::jsonb, '13 + 23 = 36.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số trừ là 20, hiệu là 31. Số bị trừ là bao nhiêu?', null, null, null, null, '51', null::jsonb, '31 + 20 = 51.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 86, tổng là 98. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '12', null::jsonb, '98 - 86 = 12.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 47, tổng là 98. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '51', null::jsonb, '98 - 47 = 51.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 25, tổng là 66. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '41', null::jsonb, '66 - 25 = 41.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 2 and l.lesson_order = 3
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 2 • Bài 4: Hơn, kém nhau bao nhiêu
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 2, 4, 'Hơn, kém nhau bao nhiêu', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '6 kém 18 bao nhiêu?', null, null, null, null, '12', null::jsonb, '18 - 6 = 12.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '10 hơn 8 bao nhiêu?', null, null, null, null, '2', null::jsonb, '10 - 8 = 2.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '19 hơn 13 bao nhiêu?', null, null, null, null, '6', null::jsonb, '19 - 13 = 6.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '13 hơn 5 bao nhiêu?', null, null, null, null, '8', null::jsonb, '13 - 5 = 8.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '10 hơn 2 bao nhiêu?', null, null, null, null, '8', null::jsonb, '10 - 2 = 8.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '18 hơn 14 bao nhiêu?', null, null, null, null, '4', null::jsonb, '18 - 14 = 4.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '1 kém 16 bao nhiêu?', null, null, null, null, '15', null::jsonb, '16 - 1 = 15.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '2 kém 16 bao nhiêu?', null, null, null, null, '14', null::jsonb, '16 - 2 = 14.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '12 hơn 4 bao nhiêu?', null, null, null, null, '8', null::jsonb, '12 - 4 = 8.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '1 kém 12 bao nhiêu?', null, null, null, null, '11', null::jsonb, '12 - 1 = 11.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '15 hơn 12 bao nhiêu?', null, null, null, null, '3', null::jsonb, '15 - 12 = 3.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '6 kém 19 bao nhiêu?', null, null, null, null, '13', null::jsonb, '19 - 6 = 13.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Nam có 49 quả táo, An có 13 quả táo. Hỏi Nam có nhiều hơn An bao nhiêu quả táo?', null, null, null, null, '36', null::jsonb, '49 - 13 = 36.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Ngọc có 99 viên bi, Hà có 25 viên bi. Hỏi Ngọc có nhiều hơn Hà bao nhiêu viên bi?', null, null, null, null, '74', null::jsonb, '99 - 25 = 74.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Lan có 54 cái bút chì, Linh có 44 cái bút chì. Hỏi Lan có nhiều hơn Linh bao nhiêu cái bút chì?', null, null, null, null, '10', null::jsonb, '54 - 44 = 10.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Linh có 45 con tem, Nam có 25 con tem. Hỏi Linh có nhiều hơn Nam bao nhiêu con tem?', null, null, null, null, '20', null::jsonb, '45 - 25 = 20.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Nam có 65 quả táo, Mai có 15 quả táo. Hỏi Nam có nhiều hơn Mai bao nhiêu quả táo?', null, null, null, null, '50', null::jsonb, '65 - 15 = 50.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Lan có 21 quả táo, Mai có 11 quả táo. Hỏi Lan có nhiều hơn Mai bao nhiêu quả táo?', null, null, null, null, '10', null::jsonb, '21 - 11 = 10.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Ngọc có 54 nhãn vở, Mai có 13 nhãn vở. Hỏi Ngọc có nhiều hơn Mai bao nhiêu nhãn vở?', null, null, null, null, '41', null::jsonb, '54 - 13 = 41.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Mai có 73 quả cam, Minh có 43 quả cam. Hỏi Mai có nhiều hơn Minh bao nhiêu quả cam?', null, null, null, null, '30', null::jsonb, '73 - 43 = 30.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Nam có 51 quả táo, Tú có 10 quả táo. Hỏi Nam có nhiều hơn Tú bao nhiêu quả táo?', null, null, null, null, '41', null::jsonb, '51 - 10 = 41.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Ngọc có 83 cái kẹo, Hà có 71 cái kẹo. Hỏi Ngọc có nhiều hơn Hà bao nhiêu cái kẹo?', null, null, null, null, '12', null::jsonb, '83 - 71 = 12.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào hơn 50 là 30 đơn vị?', null, null, null, null, '80', null::jsonb, '50 + 30 = 80.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào kém 24 là 23 đơn vị?', null, null, null, null, '1', null::jsonb, '24 - 23 = 1.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào hơn 27 là 29 đơn vị?', null, null, null, null, '56', null::jsonb, '27 + 29 = 56.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào kém 37 là 24 đơn vị?', null, null, null, null, '13', null::jsonb, '37 - 24 = 13.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào hơn 46 là 3 đơn vị?', null, null, null, null, '49', null::jsonb, '46 + 3 = 49.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào kém 48 là 11 đơn vị?', null, null, null, null, '37', null::jsonb, '48 - 11 = 37.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào hơn 29 là 9 đơn vị?', null, null, null, null, '38', null::jsonb, '29 + 9 = 38.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Số nào hơn 46 là 16 đơn vị?', null, null, null, null, '62', null::jsonb, '46 + 16 = 62.', 'hon_kem', 'rule:hon_kem')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 2 and l.lesson_order = 4
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 3 • Bài 5: Ôn tập phép cộng, phép trừ (không nhớ) trong phạm vi 100
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 3, 5, 'Ôn tập phép cộng, phép trừ (không nhớ) trong phạm vi 100', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '17 + 1 = ?', null, null, null, null, '18', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'multiple_choice', '14 - 2 = ?', '10', '12', '2', '14', '12', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'multiple_choice', '10 + 8 = ?', '20', '19', '18', '28', '18', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'number', '12 - 1 = ?', null, null, null, null, '11', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'number', '18 + 1 = ?', null, null, null, null, '19', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'number', '19 - 1 = ?', null, null, null, null, '18', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'multiple_choice', '18 + 1 = ?', '21', '17', '29', '19', '19', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'number', '18 - 4 = ?', null, null, null, null, '14', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'multiple_choice', '17 + 1 = ?', '8', '18', '20', '17', '18', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'multiple_choice', '16 - 1 = ?', '17', '25', '14', '15', '15', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'number', '18 - 2 = ?', null, null, null, null, '16', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (1::smallint, 'number', '16 + 1 = ?', null, null, null, null, '17', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'multiple_choice', '64 - 41 = ?', '33', '24', '21', '23', '23', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (2::smallint, 'number', '72 + 15 = ?', null, null, null, null, '87', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'multiple_choice', '71 - 20 = ?', '41', '61', '49', '51', '51', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (2::smallint, 'multiple_choice', '36 + 42 = ?', '78', '88', '80', '77', '78', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'number', '90 - 10 = ?', null, null, null, null, '80', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (2::smallint, 'number', '36 + 43 = ?', null, null, null, null, '79', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'number', '80 - 20 = ?', null, null, null, null, '60', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (2::smallint, 'number', '54 + 23 = ?', null, null, null, null, '77', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'number', '62 - 42 = ?', null, null, null, null, '20', null::jsonb, null, 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (2::smallint, 'multiple_choice', '64 + 35 = ?', '99', '97', '89', '101', '99', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'number', '___ - 15 = 22', null, null, null, null, '37', null::jsonb, 'Số bị trừ = hiệu + số trừ: 22 + 15 = 37.', 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (3::smallint, 'number', '___ + 20 = 79', null, null, null, null, '59', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 79 - 20 = 59.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'number', '34 - ___ = 24', null, null, null, null, '10', null::jsonb, 'Số trừ = số bị trừ - hiệu: 34 - 24 = 10.', 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (3::smallint, 'number', '___ + 44 = 69', null, null, null, null, '25', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 69 - 44 = 25.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'number', '___ - 40 = 40', null, null, null, null, '80', null::jsonb, 'Số bị trừ = hiệu + số trừ: 40 + 40 = 80.', 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (3::smallint, 'number', '62 + ___ = 77', null, null, null, null, '15', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 77 - 62 = 15.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'number', '31 - ___ = 21', null, null, null, null, '10', null::jsonb, 'Số trừ = số bị trừ - hiệu: 31 - 21 = 10.', 'tru_khong_nho_100', 'rule:tru_khong_nho_100'),
    (3::smallint, 'number', '___ + 36 = 99', null, null, null, null, '63', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 99 - 36 = 63.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 3 and l.lesson_order = 5
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 3 • Bài 6: Luyện tập chung
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 3, 6, 'Luyện tập chung', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  14  ___  41', '>', '<', '=', null, '<', null::jsonb, '14 < 41.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 97 - 26 = 71, số 97 được gọi là:', 'Tổng', 'Số bị trừ', 'Số trừ', 'Hiệu', 'Số bị trừ', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '10 kém 12 bao nhiêu?', null, null, null, null, '2', null::jsonb, '12 - 10 = 2.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '17 + 2 = ?', null, null, null, null, '19', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  15  ___  51', '>', '<', '=', null, '<', null::jsonb, '15 < 51.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 53 + 20 = 73, số 53 được gọi là:', 'Số hạng', 'Số trừ', 'Hiệu', 'Tổng', 'Số hạng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '10 hơn 7 bao nhiêu?', null, null, null, null, '3', null::jsonb, '10 - 7 = 3.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', '13 + 1 = ?', null, null, null, null, '14', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  63  ___  19', '>', '<', '=', null, '>', null::jsonb, '63 > 19.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 84 - 32 = 52, số 84 được gọi là:', 'Số trừ', 'Tổng', 'Số bị trừ', 'Hiệu', 'Số bị trừ', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '14 hơn 11 bao nhiêu?', null, null, null, null, '3', null::jsonb, '14 - 11 = 3.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'multiple_choice', '13 + 6 = ?', '29', '21', '17', '19', '19', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  81 + 15  ___  95', '>', '<', '=', null, '>', null::jsonb, '81 + 15 = 96; 96 > 95.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', 'Hiệu của 68 và 26 là bao nhiêu?', null, null, null, null, '42', null::jsonb, '68 - 26 = 42.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Lan có 27 con tem, Bình có 14 con tem. Hỏi Lan có nhiều hơn Bình bao nhiêu con tem?', null, null, null, null, '13', null::jsonb, '27 - 14 = 13.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', '65 + 24 = ?', null, null, null, null, '89', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  52 + 10  ___  61', '>', '<', '=', null, '>', null::jsonb, '52 + 10 = 62; 62 > 61.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', 'Hiệu của 58 và 33 là bao nhiêu?', null, null, null, null, '25', null::jsonb, '58 - 33 = 25.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Minh có 84 quả táo, Bình có 10 quả táo. Hỏi Minh có nhiều hơn Bình bao nhiêu quả táo?', null, null, null, null, '74', null::jsonb, '84 - 10 = 74.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', '35 + 24 = ?', null, null, null, null, '59', null::jsonb, null, 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  84 + 11  ___  96', '>', '<', '=', null, '<', null::jsonb, '84 + 11 = 95; 95 < 96.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', 'Hiệu của 83 và 60 là bao nhiêu?', null, null, null, null, '23', null::jsonb, '83 - 60 = 23.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số nào hơn 59 là 19 đơn vị?', null, null, null, null, '78', null::jsonb, '59 + 19 = 78.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', '13 + ___ = 83', null, null, null, null, '70', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 83 - 13 = 70.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  45 + 30  ___  28 - 10', '>', '<', '=', null, '>', null::jsonb, '45 + 30 = 75; 28 - 10 = 18; 75 > 18.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Số trừ là 31, hiệu là 30. Số bị trừ là bao nhiêu?', null, null, null, null, '61', null::jsonb, '30 + 31 = 61.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số nào kém 40 là 16 đơn vị?', null, null, null, null, '24', null::jsonb, '40 - 16 = 24.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', '___ + 40 = 93', null, null, null, null, '53', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 93 - 40 = 53.', 'cong_khong_nho_100', 'rule:cong_khong_nho_100'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  31 + 54  ___  27 - 17', '>', '<', '=', null, '>', null::jsonb, '31 + 54 = 85; 27 - 17 = 10; 85 > 10.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 57, tổng là 68. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '11', null::jsonb, '68 - 57 = 11.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 3 and l.lesson_order = 6
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 4 • Bài 7: Phép cộng (qua 10) trong phạm vi 20
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 4, 7, 'Phép cộng (qua 10) trong phạm vi 20', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '9 + 4 = ?', null, null, null, null, '13', null::jsonb, 'Tách 4 = 1 + 3; 9 + 1 = 10; 10 + 3 = 13.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 5 = ?', null, null, null, null, '14', null::jsonb, 'Tách 5 = 1 + 4; 9 + 1 = 10; 10 + 4 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '8 + 3 = ?', null, null, null, null, '11', null::jsonb, 'Tách 3 = 2 + 1; 8 + 2 = 10; 10 + 1 = 11.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '8 + 4 = ?', null, null, null, null, '12', null::jsonb, 'Tách 4 = 2 + 2; 8 + 2 = 10; 10 + 2 = 12.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 3 = ?', null, null, null, null, '12', null::jsonb, 'Tách 3 = 1 + 2; 9 + 1 = 10; 10 + 2 = 12.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '8 + 9 = ?', null, null, null, null, '17', null::jsonb, 'Tách 9 = 2 + 7; 8 + 2 = 10; 10 + 7 = 17.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 7 = ?', null, null, null, null, '16', null::jsonb, 'Tách 7 = 1 + 6; 9 + 1 = 10; 10 + 6 = 16.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 2 = ?', null, null, null, null, '11', null::jsonb, 'Tách 2 = 1 + 1; 9 + 1 = 10; 10 + 1 = 11.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '8 + 8 = ?', null, null, null, null, '16', null::jsonb, 'Tách 8 = 2 + 6; 8 + 2 = 10; 10 + 6 = 16.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 8 = ?', null, null, null, null, '17', null::jsonb, 'Tách 8 = 1 + 7; 9 + 1 = 10; 10 + 7 = 17.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 9 = ?', null, null, null, null, '18', null::jsonb, 'Tách 9 = 1 + 8; 9 + 1 = 10; 10 + 8 = 18.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '9 + 6 = ?', null, null, null, null, '15', null::jsonb, 'Tách 6 = 1 + 5; 9 + 1 = 10; 10 + 5 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', '7 + 8 = ?', '14', '5', '15', '25', '15', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', '5 + 7 = ?', '14', '13', '22', '12', '12', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '7 + 7 = ?', null, null, null, null, '14', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '7 + 8 = ?', null, null, null, null, '15', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', '7 + 6 = ?', '12', '14', '15', '13', '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '5 + 7 = ?', null, null, null, null, '12', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', '6 + 6 = ?', '2', '12', '22', '10', '12', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '6 + 7 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '7 + 4 = ?', null, null, null, null, '11', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '8 + 5 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '8 + ___ = 13', null, null, null, null, '5', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 13 - 8 = 5.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '2 + 7 + 4 = ?', null, null, null, null, '13', null::jsonb, '2 + 7 = 9; 9 + 4 = 13.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '5 + ___ = 14', null, null, null, null, '9', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 14 - 5 = 9.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '___ + 8 = 16', null, null, null, null, '8', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 16 - 8 = 8.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '5 + 8 + 1 = ?', null, null, null, null, '14', null::jsonb, '5 + 8 = 13; 13 + 1 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '3 + 9 + 2 = ?', null, null, null, null, '14', null::jsonb, '3 + 9 = 12; 12 + 2 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '3 + 4 + 5 = ?', null, null, null, null, '12', null::jsonb, '3 + 4 = 7; 7 + 5 = 12.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '5 + ___ = 11', null, null, null, null, '6', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 11 - 5 = 6.', 'cong_qua_10', 'rule:cong_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 4 and l.lesson_order = 7
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 4 • Bài 8: Bảng cộng (qua 10)
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 4, 8, 'Bảng cộng (qua 10)', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '8 + 7 = ?', null, null, null, null, '15', null::jsonb, 'Tách 7 = 2 + 5; 8 + 2 = 10; 10 + 5 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  74  ___  89', '>', '<', '=', null, '<', null::jsonb, '74 < 89.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', '9 + 6 = ?', null, null, null, null, '15', null::jsonb, 'Tách 6 = 1 + 5; 9 + 1 = 10; 10 + 5 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  73  ___  37', '>', '<', '=', null, '>', null::jsonb, '73 > 37.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', '9 + 2 = ?', null, null, null, null, '11', null::jsonb, 'Tách 2 = 1 + 1; 9 + 1 = 10; 10 + 1 = 11.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  27  ___  72', '>', '<', '=', null, '<', null::jsonb, '27 < 72.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', '8 + 5 = ?', null, null, null, null, '13', null::jsonb, 'Tách 5 = 2 + 3; 8 + 2 = 10; 10 + 3 = 13.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  29  ___  15', '>', '<', '=', null, '>', null::jsonb, '29 > 15.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', '9 + 5 = ?', null, null, null, null, '14', null::jsonb, 'Tách 5 = 1 + 4; 9 + 1 = 10; 10 + 4 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  58  ___  65', '>', '<', '=', null, '<', null::jsonb, '58 < 65.', 'so_sanh', 'rule:so_sanh'),
    (1::smallint, 'number', '9 + 4 = ?', null, null, null, null, '13', null::jsonb, 'Tách 4 = 1 + 3; 9 + 1 = 10; 10 + 3 = 13.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  46  ___  80', '>', '<', '=', null, '<', null::jsonb, '46 < 80.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', '5 + 7 = ?', null, null, null, null, '12', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  51 + 11  ___  62', '>', '<', '=', null, '=', null::jsonb, '51 + 11 = 62; 62 = 62.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  64 + 15  ___  79', '>', '<', '=', null, '=', null::jsonb, '64 + 15 = 79; 79 = 79.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', '6 + 7 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  54 + 40  ___  104', '>', '<', '=', null, '<', null::jsonb, '54 + 40 = 94; 94 < 104.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'multiple_choice', '6 + 7 = ?', '23', '3', '11', '13', '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  14 + 60  ___  74', '>', '<', '=', null, '=', null::jsonb, '14 + 60 = 74; 74 = 74.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', '6 + 9 = ?', null, null, null, null, '15', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  57 + 30  ___  87', '>', '<', '=', null, '=', null::jsonb, '57 + 30 = 87; 87 = 87.', 'so_sanh', 'rule:so_sanh'),
    (2::smallint, 'number', '6 + 5 = ?', null, null, null, null, '11', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  56 + 30  ___  82 - 32', '>', '<', '=', null, '>', null::jsonb, '56 + 30 = 86; 82 - 32 = 50; 86 > 50.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', '4 + 8 + 4 = ?', null, null, null, null, '16', null::jsonb, '4 + 8 = 12; 12 + 4 = 16.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  29 + 40  ___  53 - 13', '>', '<', '=', null, '>', null::jsonb, '29 + 40 = 69; 53 - 13 = 40; 69 > 40.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', '5 + 4 + 8 = ?', null, null, null, null, '17', null::jsonb, '5 + 4 = 9; 9 + 8 = 17.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  11 + 20  ___  92 - 40', '>', '<', '=', null, '<', null::jsonb, '11 + 20 = 31; 92 - 40 = 52; 31 < 52.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', '7 + ___ = 11', null, null, null, null, '4', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 11 - 7 = 4.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  20 + 77  ___  59 - 35', '>', '<', '=', null, '>', null::jsonb, '20 + 77 = 97; 59 - 35 = 24; 97 > 24.', 'so_sanh', 'rule:so_sanh'),
    (3::smallint, 'number', '8 + 3 + 8 = ?', null, null, null, null, '19', null::jsonb, '8 + 3 = 11; 11 + 8 = 19.', 'cong_qua_10', 'rule:cong_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 4 and l.lesson_order = 8
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 5 • Bài 9: Bài toán về thêm, bớt một số đơn vị
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 5, 9, 'Bài toán về thêm, bớt một số đơn vị', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Hà có 4 quả táo, mẹ cho thêm 16 quả táo. Hỏi Hà có tất cả bao nhiêu quả táo?', null, null, null, null, '20', null::jsonb, '4 + 16 = 20.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Ngọc có 8 cái bút chì, Ngọc cho bạn 4 cái bút chì. Hỏi Ngọc còn lại bao nhiêu cái bút chì?', null, null, null, null, '4', null::jsonb, '8 - 4 = 4.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Linh có 20 quyển vở, Linh cho bạn 4 quyển vở. Hỏi Linh còn lại bao nhiêu quyển vở?', null, null, null, null, '16', null::jsonb, '20 - 4 = 16.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Lan có 5 nhãn vở, mẹ cho thêm 5 nhãn vở. Hỏi Lan có tất cả bao nhiêu nhãn vở?', null, null, null, null, '10', null::jsonb, '5 + 5 = 10.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Khôi có 20 cái bút chì, Khôi cho bạn 16 cái bút chì. Hỏi Khôi còn lại bao nhiêu cái bút chì?', null, null, null, null, '4', null::jsonb, '20 - 16 = 4.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Linh có 7 cái bút chì, mẹ cho thêm 6 cái bút chì. Hỏi Linh có tất cả bao nhiêu cái bút chì?', null, null, null, null, '13', null::jsonb, '7 + 6 = 13.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Mai có 16 quả cam, Mai cho bạn 5 quả cam. Hỏi Mai còn lại bao nhiêu quả cam?', null, null, null, null, '11', null::jsonb, '16 - 5 = 11.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Lan có 8 cái kẹo, mẹ cho thêm 9 cái kẹo. Hỏi Lan có tất cả bao nhiêu cái kẹo?', null, null, null, null, '17', null::jsonb, '8 + 9 = 17.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Bình có 13 quả cam, Bình cho bạn 6 quả cam. Hỏi Bình còn lại bao nhiêu quả cam?', null, null, null, null, '7', null::jsonb, '13 - 6 = 7.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Khôi có 20 con tem, Khôi cho bạn 14 con tem. Hỏi Khôi còn lại bao nhiêu con tem?', null, null, null, null, '6', null::jsonb, '20 - 14 = 6.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'An có 20 nhãn vở, An cho bạn 7 nhãn vở. Hỏi An còn lại bao nhiêu nhãn vở?', null, null, null, null, '13', null::jsonb, '20 - 7 = 13.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Nam có 16 cái bút chì, Nam cho bạn 13 cái bút chì. Hỏi Nam còn lại bao nhiêu cái bút chì?', null, null, null, null, '3', null::jsonb, '16 - 13 = 3.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Minh có 65 cái bút chì. Linh có nhiều hơn Minh 34 cái bút chì. Hỏi Linh có bao nhiêu cái bút chì?', null, null, null, null, '99', null::jsonb, 'Nhiều hơn thì làm phép cộng: 65 + 34 = 99.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Bình có 49 quyển vở. Nam có nhiều hơn Bình 40 quyển vở. Hỏi Nam có bao nhiêu quyển vở?', null, null, null, null, '89', null::jsonb, 'Nhiều hơn thì làm phép cộng: 49 + 40 = 89.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Ngọc có 49 quả cam. Hoa có ít hơn Ngọc 33 quả cam. Hỏi Hoa có bao nhiêu quả cam?', null, null, null, null, '16', null::jsonb, 'Ít hơn thì làm phép trừ: 49 - 33 = 16.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Bình có 47 viên bi. Khôi có ít hơn Bình 15 viên bi. Hỏi Khôi có bao nhiêu viên bi?', null, null, null, null, '32', null::jsonb, 'Ít hơn thì làm phép trừ: 47 - 15 = 32.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Linh có 49 nhãn vở. Hà có nhiều hơn Linh 30 nhãn vở. Hỏi Hà có bao nhiêu nhãn vở?', null, null, null, null, '79', null::jsonb, 'Nhiều hơn thì làm phép cộng: 49 + 30 = 79.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Ngọc có 79 cái bút chì. Bình có ít hơn Ngọc 23 cái bút chì. Hỏi Bình có bao nhiêu cái bút chì?', null, null, null, null, '56', null::jsonb, 'Ít hơn thì làm phép trừ: 79 - 23 = 56.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Nam có 93 con tem. An có ít hơn Nam 30 con tem. Hỏi An có bao nhiêu con tem?', null, null, null, null, '63', null::jsonb, 'Ít hơn thì làm phép trừ: 93 - 30 = 63.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Nam có 53 quả táo. An có ít hơn Nam 20 quả táo. Hỏi An có bao nhiêu quả táo?', null, null, null, null, '33', null::jsonb, 'Ít hơn thì làm phép trừ: 53 - 20 = 33.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'An có 41 con tem. Linh có nhiều hơn An 21 con tem. Hỏi Linh có bao nhiêu con tem?', null, null, null, null, '62', null::jsonb, 'Nhiều hơn thì làm phép cộng: 41 + 21 = 62.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Lan có 64 viên bi. Bình có ít hơn Lan 54 viên bi. Hỏi Bình có bao nhiêu viên bi?', null, null, null, null, '10', null::jsonb, 'Ít hơn thì làm phép trừ: 64 - 54 = 10.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lớp 2A có 15 bạn nam và 14 bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?', null, null, null, null, '29', null::jsonb, '15 + 14 = 29.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lớp 2A có 13 bạn nam và 12 bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?', null, null, null, null, '25', null::jsonb, '13 + 12 = 25.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Ngọc cho bạn 18 con tem thì còn lại 37 con tem. Hỏi lúc đầu Ngọc có bao nhiêu con tem?', null, null, null, null, '55', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 18 + 37 = 55.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lớp 2A có 15 bạn nam và 18 bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?', null, null, null, null, '33', null::jsonb, '15 + 18 = 33.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lan cho bạn 10 quả cam thì còn lại 8 quả cam. Hỏi lúc đầu Lan có bao nhiêu quả cam?', null, null, null, null, '18', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 10 + 8 = 18.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lớp 2A có 16 bạn nam và 18 bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?', null, null, null, null, '34', null::jsonb, '16 + 18 = 34.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Lớp 2A có 13 bạn nam và 16 bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?', null, null, null, null, '29', null::jsonb, '13 + 16 = 29.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Ngọc cho bạn 21 nhãn vở thì còn lại 7 nhãn vở. Hỏi lúc đầu Ngọc có bao nhiêu nhãn vở?', null, null, null, null, '28', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 21 + 7 = 28.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 5 and l.lesson_order = 9
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 5 • Bài 10: Luyện tập chung
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 5, 10, 'Luyện tập chung', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '9 + 6 = ?', null, null, null, null, '15', null::jsonb, 'Tách 6 = 1 + 5; 9 + 1 = 10; 10 + 5 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', 'Linh có 12 bông hoa, mẹ cho thêm 3 bông hoa. Hỏi Linh có tất cả bao nhiêu bông hoa?', null, null, null, null, '15', null::jsonb, '12 + 3 = 15.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '9 + 4 = ?', null, null, null, null, '13', null::jsonb, 'Tách 4 = 1 + 3; 9 + 1 = 10; 10 + 3 = 13.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', 'Hoa có 7 viên bi, mẹ cho thêm 12 viên bi. Hỏi Hoa có tất cả bao nhiêu viên bi?', null, null, null, null, '19', null::jsonb, '7 + 12 = 19.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '8 + 8 = ?', null, null, null, null, '16', null::jsonb, 'Tách 8 = 2 + 6; 8 + 2 = 10; 10 + 6 = 16.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', 'Hà có 10 cái kẹo, mẹ cho thêm 5 cái kẹo. Hỏi Hà có tất cả bao nhiêu cái kẹo?', null, null, null, null, '15', null::jsonb, '10 + 5 = 15.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '9 + 3 = ?', null, null, null, null, '12', null::jsonb, 'Tách 3 = 1 + 2; 9 + 1 = 10; 10 + 2 = 12.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', 'Linh có 16 bông hoa, Linh cho bạn 2 bông hoa. Hỏi Linh còn lại bao nhiêu bông hoa?', null, null, null, null, '14', null::jsonb, '16 - 2 = 14.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Tú có 11 cái bút chì, Tú cho bạn 10 cái bút chì. Hỏi Tú còn lại bao nhiêu cái bút chì?', null, null, null, null, '1', null::jsonb, '11 - 10 = 1.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '9 + 2 = ?', null, null, null, null, '11', null::jsonb, 'Tách 2 = 1 + 1; 9 + 1 = 10; 10 + 1 = 11.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', 'Lan có 7 quả táo, mẹ cho thêm 6 quả táo. Hỏi Lan có tất cả bao nhiêu quả táo?', null, null, null, null, '13', null::jsonb, '7 + 6 = 13.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Minh có 9 quả táo, mẹ cho thêm 5 quả táo. Hỏi Minh có tất cả bao nhiêu quả táo?', null, null, null, null, '14', null::jsonb, '9 + 5 = 14.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', '5 + 8 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', 'Hà có 15 nhãn vở. Khôi có nhiều hơn Hà 54 nhãn vở. Hỏi Khôi có bao nhiêu nhãn vở?', null, null, null, null, '69', null::jsonb, 'Nhiều hơn thì làm phép cộng: 15 + 54 = 69.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', '8 + 5 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', 'Hà có 27 con tem. An có ít hơn Hà 10 con tem. Hỏi An có bao nhiêu con tem?', null, null, null, null, '17', null::jsonb, 'Ít hơn thì làm phép trừ: 27 - 10 = 17.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'multiple_choice', '5 + 8 = ?', '14', '12', '15', '13', '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', 'Hoa có 81 con tem. Hà có nhiều hơn Hoa 15 con tem. Hỏi Hà có bao nhiêu con tem?', null, null, null, null, '96', null::jsonb, 'Nhiều hơn thì làm phép cộng: 81 + 15 = 96.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', '7 + 8 = ?', null, null, null, null, '15', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', 'Ngọc có 15 cái bút chì. Hoa có nhiều hơn Ngọc 74 cái bút chì. Hỏi Hoa có bao nhiêu cái bút chì?', null, null, null, null, '89', null::jsonb, 'Nhiều hơn thì làm phép cộng: 15 + 74 = 89.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Ngọc có 29 quyển vở. Minh có ít hơn Ngọc 11 quyển vở. Hỏi Minh có bao nhiêu quyển vở?', null, null, null, null, '18', null::jsonb, 'Ít hơn thì làm phép trừ: 29 - 11 = 18.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'multiple_choice', '8 + 9 = ?', '18', '7', '16', '17', '17', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', 'An cho bạn 17 cái kẹo thì còn lại 20 cái kẹo. Hỏi lúc đầu An có bao nhiêu cái kẹo?', null, null, null, null, '37', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 17 + 20 = 37.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', '8 + ___ = 16', null, null, null, null, '8', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 16 - 8 = 8.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', 'Linh cho bạn 23 quyển vở thì còn lại 25 quyển vở. Hỏi lúc đầu Linh có bao nhiêu quyển vở?', null, null, null, null, '48', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 23 + 25 = 48.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', '6 + 2 + 7 = ?', null, null, null, null, '15', null::jsonb, '6 + 2 = 8; 8 + 7 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', 'Mai cho bạn 9 quả táo thì còn lại 18 quả táo. Hỏi lúc đầu Mai có bao nhiêu quả táo?', null, null, null, null, '27', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 9 + 18 = 27.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', '6 + 9 + 2 = ?', null, null, null, null, '17', null::jsonb, '6 + 9 = 15; 15 + 2 = 17.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', 'Trong vườn có 38 cây. Bố trồng thêm 5 cây, sau đó chặt bớt 12 cây già. Hỏi trong vườn còn bao nhiêu cây?', null, null, null, null, '31', null::jsonb, '38 + 5 - 12 = 31.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', '___ + 8 = 14', null, null, null, null, '6', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 14 - 8 = 6.', 'cong_qua_10', 'rule:cong_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 5 and l.lesson_order = 10
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 6 • Bài 11: Phép trừ (qua 10) trong phạm vi 20
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 6, 11, 'Phép trừ (qua 10) trong phạm vi 20', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '16 - 9 = ?', null, null, null, null, '7', null::jsonb, '16 - 6 = 10; 10 - 3 = 7.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '14 - 9 = ?', null, null, null, null, '5', null::jsonb, '14 - 4 = 10; 10 - 5 = 5.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 2 = ?', null, null, null, null, '9', null::jsonb, '11 - 1 = 10; 10 - 1 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 3 = ?', null, null, null, null, '8', null::jsonb, '11 - 1 = 10; 10 - 2 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 9 = ?', null, null, null, null, '2', null::jsonb, '11 - 1 = 10; 10 - 8 = 2.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '12 - 9 = ?', null, null, null, null, '3', null::jsonb, '12 - 2 = 10; 10 - 7 = 3.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '17 - 9 = ?', null, null, null, null, '8', null::jsonb, '17 - 7 = 10; 10 - 2 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 5 = ?', null, null, null, null, '6', null::jsonb, '11 - 1 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '13 - 9 = ?', null, null, null, null, '4', null::jsonb, '13 - 3 = 10; 10 - 6 = 4.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 4 = ?', null, null, null, null, '7', null::jsonb, '11 - 1 = 10; 10 - 3 = 7.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 6 = ?', null, null, null, null, '5', null::jsonb, '11 - 1 = 10; 10 - 5 = 5.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '15 - 9 = ?', null, null, null, null, '6', null::jsonb, '15 - 5 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '14 - 7 = ?', null, null, null, null, '7', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '14 - 8 = ?', null, null, null, null, '6', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '13 - 8 = ?', null, null, null, null, '5', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '16 - 8 = ?', '18', '9', '8', '10', '8', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '13 - 4 = ?', '10', '19', '9', '11', '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '18 - 9 = ?', null, null, null, null, '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '17 - 8 = ?', '9', '11', '8', '19', '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '13 - 7 = ?', null, null, null, null, '6', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '18 - 9 = ?', '7', '9', '8', '11', '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '15 - 9 = ?', '8', '5', '4', '6', '6', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '16 - ___ = 8', null, null, null, null, '8', null::jsonb, 'Số trừ = số bị trừ - hiệu: 16 - 8 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '11 - ___ = 8', null, null, null, null, '3', null::jsonb, 'Số trừ = số bị trừ - hiệu: 11 - 8 = 3.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '17 - ___ = 8', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 17 - 8 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '14 - ___ = 5', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 14 - 5 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '___ - 3 = 9', null, null, null, null, '12', null::jsonb, 'Số bị trừ = hiệu + số trừ: 9 + 3 = 12.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '16 - ___ = 9', null, null, null, null, '7', null::jsonb, 'Số trừ = số bị trừ - hiệu: 16 - 9 = 7.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '___ - 8 = 4', null, null, null, null, '12', null::jsonb, 'Số bị trừ = hiệu + số trừ: 4 + 8 = 12.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '16 - ___ = 7', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 16 - 7 = 9.', 'tru_qua_10', 'rule:tru_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 6 and l.lesson_order = 11
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 6 • Bài 12: Bảng trừ (qua 10)
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 6, 12, 'Bảng trừ (qua 10)', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '17 - 9 = ?', null, null, null, null, '8', null::jsonb, '17 - 7 = 10; 10 - 2 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 10 + 7 = 17, số 17 được gọi là:', 'Tổng', 'Hiệu', 'Số trừ', 'Số hạng', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '11 - 5 = ?', null, null, null, null, '6', null::jsonb, '11 - 1 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 11 + 7 = 18, số 11 được gọi là:', 'Số hạng', 'Tổng', 'Hiệu', 'Số trừ', 'Số hạng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '15 - 9 = ?', null, null, null, null, '6', null::jsonb, '15 - 5 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 74 + 11 = 85, số 85 được gọi là:', 'Số hạng', 'Tổng', 'Hiệu', 'Số trừ', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '11 - 3 = ?', null, null, null, null, '8', null::jsonb, '11 - 1 = 10; 10 - 2 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 11 + 1 = 12, số 12 được gọi là:', 'Hiệu', 'Số trừ', 'Số hạng', 'Tổng', 'Tổng', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '14 - 9 = ?', null, null, null, null, '5', null::jsonb, '14 - 4 = 10; 10 - 5 = 5.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 58 - 31 = 27, số 58 được gọi là:', 'Số bị trừ', 'Số trừ', 'Hiệu', 'Tổng', 'Số bị trừ', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'multiple_choice', 'Trong phép tính 81 - 51 = 30, số 30 được gọi là:', 'Tổng', 'Số trừ', 'Hiệu', 'Số bị trừ', 'Hiệu', null::jsonb, null, 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (1::smallint, 'number', '11 - 9 = ?', null, null, null, null, '2', null::jsonb, '11 - 1 = 10; 10 - 8 = 2.', 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', 'Tổng của 52 và 27 là bao nhiêu?', null, null, null, null, '79', null::jsonb, '52 + 27 = 79.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', '12 - 5 = ?', null, null, null, null, '7', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', 'Tổng của 30 và 62 là bao nhiêu?', null, null, null, null, '92', null::jsonb, '30 + 62 = 92.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', '16 - 8 = ?', null, null, null, null, '8', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', 'Hiệu của 71 và 41 là bao nhiêu?', null, null, null, null, '30', null::jsonb, '71 - 41 = 30.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'multiple_choice', '13 - 4 = ?', '9', '19', '10', '7', '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', 'Hiệu của 36 và 24 là bao nhiêu?', null, null, null, null, '12', null::jsonb, '36 - 24 = 12.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'number', 'Hiệu của 40 và 30 là bao nhiêu?', null, null, null, null, '10', null::jsonb, '40 - 30 = 10.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (2::smallint, 'multiple_choice', '18 - 9 = ?', '7', '10', '8', '9', '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', 'Hiệu của 21 và 10 là bao nhiêu?', null, null, null, null, '11', null::jsonb, '21 - 10 = 11.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', '17 - ___ = 8', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 17 - 8 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', 'Số trừ là 17, hiệu là 11. Số bị trừ là bao nhiêu?', null, null, null, null, '28', null::jsonb, '11 + 17 = 28.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', '18 - ___ = 9', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 18 - 9 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', 'Số trừ là 11, hiệu là 81. Số bị trừ là bao nhiêu?', null, null, null, null, '92', null::jsonb, '81 + 11 = 92.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', '___ - 4 = 8', null, null, null, null, '12', null::jsonb, 'Số bị trừ = hiệu + số trừ: 8 + 4 = 12.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', 'Số trừ là 10, hiệu là 20. Số bị trừ là bao nhiêu?', null, null, null, null, '30', null::jsonb, '20 + 10 = 30.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', 'Số hạng thứ nhất là 51, tổng là 73. Số hạng thứ hai là bao nhiêu?', null, null, null, null, '22', null::jsonb, '73 - 51 = 22.', 'thanh_phan_phep_tinh', 'rule:thanh_phan_phep_tinh'),
    (3::smallint, 'number', '___ - 9 = 8', null, null, null, null, '17', null::jsonb, 'Số bị trừ = hiệu + số trừ: 8 + 9 = 17.', 'tru_qua_10', 'rule:tru_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 6 and l.lesson_order = 12
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 7 • Bài 13: Bài toán về nhiều hơn, ít hơn một số đơn vị
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 7, 13, 'Bài toán về nhiều hơn, ít hơn một số đơn vị', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Tú có 6 cái bút chì, mẹ cho thêm 8 cái bút chì. Hỏi Tú có tất cả bao nhiêu cái bút chì?', null, null, null, null, '14', null::jsonb, '6 + 8 = 14.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '3 kém 6 bao nhiêu?', null, null, null, null, '3', null::jsonb, '6 - 3 = 3.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', 'Nam có 12 viên bi, mẹ cho thêm 2 viên bi. Hỏi Nam có tất cả bao nhiêu viên bi?', null, null, null, null, '14', null::jsonb, '12 + 2 = 14.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '13 hơn 8 bao nhiêu?', null, null, null, null, '5', null::jsonb, '13 - 8 = 5.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', 'Khôi có 4 bông hoa, mẹ cho thêm 3 bông hoa. Hỏi Khôi có tất cả bao nhiêu bông hoa?', null, null, null, null, '7', null::jsonb, '4 + 3 = 7.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '10 kém 12 bao nhiêu?', null, null, null, null, '2', null::jsonb, '12 - 10 = 2.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', 'Tú có 10 viên bi, mẹ cho thêm 9 viên bi. Hỏi Tú có tất cả bao nhiêu viên bi?', null, null, null, null, '19', null::jsonb, '10 + 9 = 19.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '2 kém 10 bao nhiêu?', null, null, null, null, '8', null::jsonb, '10 - 2 = 8.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', 'Hoa có 17 bông hoa, Hoa cho bạn 9 bông hoa. Hỏi Hoa còn lại bao nhiêu bông hoa?', null, null, null, null, '8', null::jsonb, '17 - 9 = 8.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', 'Tú có 6 con tem, mẹ cho thêm 10 con tem. Hỏi Tú có tất cả bao nhiêu con tem?', null, null, null, null, '16', null::jsonb, '6 + 10 = 16.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (1::smallint, 'number', '6 hơn 2 bao nhiêu?', null, null, null, null, '4', null::jsonb, '6 - 2 = 4.', 'hon_kem', 'rule:hon_kem'),
    (1::smallint, 'number', 'Nam có 17 quả cam, Nam cho bạn 15 quả cam. Hỏi Nam còn lại bao nhiêu quả cam?', null, null, null, null, '2', null::jsonb, '17 - 15 = 2.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Tú có 49 quả táo, Bình có 39 quả táo. Hỏi Tú có nhiều hơn Bình bao nhiêu quả táo?', null, null, null, null, '10', null::jsonb, '49 - 39 = 10.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Minh có 80 bông hoa. Khôi có nhiều hơn Minh 13 bông hoa. Hỏi Khôi có bao nhiêu bông hoa?', null, null, null, null, '93', null::jsonb, 'Nhiều hơn thì làm phép cộng: 80 + 13 = 93.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Hoa có 45 cái bút chì, Nam có 11 cái bút chì. Hỏi Hoa có nhiều hơn Nam bao nhiêu cái bút chì?', null, null, null, null, '34', null::jsonb, '45 - 11 = 34.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Khôi có 78 con tem. Nam có nhiều hơn Khôi 10 con tem. Hỏi Nam có bao nhiêu con tem?', null, null, null, null, '88', null::jsonb, 'Nhiều hơn thì làm phép cộng: 78 + 10 = 88.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Lan có 36 quyển vở, Linh có 25 quyển vở. Hỏi Lan có nhiều hơn Linh bao nhiêu quyển vở?', null, null, null, null, '11', null::jsonb, '36 - 25 = 11.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Bình có 63 quyển vở. Tú có nhiều hơn Bình 22 quyển vở. Hỏi Tú có bao nhiêu quyển vở?', null, null, null, null, '85', null::jsonb, 'Nhiều hơn thì làm phép cộng: 63 + 22 = 85.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Minh có 80 viên bi, Mai có 50 viên bi. Hỏi Minh có nhiều hơn Mai bao nhiêu viên bi?', null, null, null, null, '30', null::jsonb, '80 - 50 = 30.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'Lan có 22 quả cam. Linh có ít hơn Lan 12 quả cam. Hỏi Linh có bao nhiêu quả cam?', null, null, null, null, '10', null::jsonb, 'Ít hơn thì làm phép trừ: 22 - 12 = 10.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (2::smallint, 'number', 'Linh có 74 quyển vở, Bình có 54 quyển vở. Hỏi Linh có nhiều hơn Bình bao nhiêu quyển vở?', null, null, null, null, '20', null::jsonb, '74 - 54 = 20.', 'hon_kem', 'rule:hon_kem'),
    (2::smallint, 'number', 'An có 45 nhãn vở. Hà có nhiều hơn An 10 nhãn vở. Hỏi Hà có bao nhiêu nhãn vở?', null, null, null, null, '55', null::jsonb, 'Nhiều hơn thì làm phép cộng: 45 + 10 = 55.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Số nào hơn 40 là 13 đơn vị?', null, null, null, null, '53', null::jsonb, '40 + 13 = 53.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Trong vườn có 39 cây. Bố trồng thêm 14 cây, sau đó chặt bớt 5 cây già. Hỏi trong vườn còn bao nhiêu cây?', null, null, null, null, '48', null::jsonb, '39 + 14 - 5 = 48.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Số nào kém 43 là 29 đơn vị?', null, null, null, null, '14', null::jsonb, '43 - 29 = 14.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Trong vườn có 25 cây. Bố trồng thêm 12 cây, sau đó chặt bớt 12 cây già. Hỏi trong vườn còn bao nhiêu cây?', null, null, null, null, '25', null::jsonb, '25 + 12 - 12 = 25.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Số nào kém 33 là 6 đơn vị?', null, null, null, null, '27', null::jsonb, '33 - 6 = 27.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Linh cho bạn 24 bông hoa thì còn lại 20 bông hoa. Hỏi lúc đầu Linh có bao nhiêu bông hoa?', null, null, null, null, '44', null::jsonb, 'Lúc đầu = số đã cho + số còn lại: 24 + 20 = 44.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van'),
    (3::smallint, 'number', 'Số nào kém 39 là 28 đơn vị?', null, null, null, null, '11', null::jsonb, '39 - 28 = 11.', 'hon_kem', 'rule:hon_kem'),
    (3::smallint, 'number', 'Trong vườn có 27 cây. Bố trồng thêm 10 cây, sau đó chặt bớt 7 cây già. Hỏi trong vườn còn bao nhiêu cây?', null, null, null, null, '30', null::jsonb, '27 + 10 - 7 = 30.', 'bai_toan_loi_van', 'rule:bai_toan_loi_van')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 7 and l.lesson_order = 13
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 7 • Bài 14: Luyện tập chung
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 7, 14, 'Luyện tập chung', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '9 + 5 = ?', null, null, null, null, '14', null::jsonb, 'Tách 5 = 1 + 4; 9 + 1 = 10; 10 + 4 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '14 - 9 = ?', null, null, null, null, '5', null::jsonb, '14 - 4 = 10; 10 - 5 = 5.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '8 + 6 = ?', null, null, null, null, '14', null::jsonb, 'Tách 6 = 2 + 4; 8 + 2 = 10; 10 + 4 = 14.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '11 - 5 = ?', null, null, null, null, '6', null::jsonb, '11 - 1 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 8 = ?', null, null, null, null, '3', null::jsonb, '11 - 1 = 10; 10 - 7 = 3.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '9 + 3 = ?', null, null, null, null, '12', null::jsonb, 'Tách 3 = 1 + 2; 9 + 1 = 10; 10 + 2 = 12.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '12 - 9 = ?', null, null, null, null, '3', null::jsonb, '12 - 2 = 10; 10 - 7 = 3.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '16 - 9 = ?', null, null, null, null, '7', null::jsonb, '16 - 6 = 10; 10 - 3 = 7.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '11 - 4 = ?', null, null, null, null, '7', null::jsonb, '11 - 1 = 10; 10 - 3 = 7.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '8 + 7 = ?', null, null, null, null, '15', null::jsonb, 'Tách 7 = 2 + 5; 8 + 2 = 10; 10 + 5 = 15.', 'cong_qua_10', 'rule:cong_qua_10'),
    (1::smallint, 'number', '15 - 9 = ?', null, null, null, null, '6', null::jsonb, '15 - 5 = 10; 10 - 4 = 6.', 'tru_qua_10', 'rule:tru_qua_10'),
    (1::smallint, 'number', '9 + 7 = ?', null, null, null, null, '16', null::jsonb, 'Tách 7 = 1 + 6; 9 + 1 = 10; 10 + 6 = 16.', 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '13 - 5 = ?', null, null, null, null, '8', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '5 + 9 = ?', null, null, null, null, '14', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '16 - 7 = ?', null, null, null, null, '9', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '5 + 9 = ?', '14', '4', '13', '16', '14', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '13 - 6 = ?', null, null, null, null, '7', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '6 + 7 = ?', null, null, null, null, '13', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'multiple_choice', '12 - 6 = ?', '6', '5', '8', '7', '6', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'number', '6 + 5 = ?', null, null, null, null, '11', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (2::smallint, 'number', '15 - 7 = ?', null, null, null, null, '8', null::jsonb, null, 'tru_qua_10', 'rule:tru_qua_10'),
    (2::smallint, 'multiple_choice', '5 + 6 = ?', '11', '12', '13', '9', '11', null::jsonb, null, 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '___ - 6 = 6', null, null, null, null, '12', null::jsonb, 'Số bị trừ = hiệu + số trừ: 6 + 6 = 12.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '8 + 7 + 5 = ?', null, null, null, null, '20', null::jsonb, '8 + 7 = 15; 15 + 5 = 20.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '___ - 9 = 8', null, null, null, null, '17', null::jsonb, 'Số bị trừ = hiệu + số trừ: 8 + 9 = 17.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '6 + 5 + 7 = ?', null, null, null, null, '18', null::jsonb, '6 + 5 = 11; 11 + 7 = 18.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '16 - ___ = 8', null, null, null, null, '8', null::jsonb, 'Số trừ = số bị trừ - hiệu: 16 - 8 = 8.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '9 + 9 + 1 = ?', null, null, null, null, '19', null::jsonb, '9 + 9 = 18; 18 + 1 = 19.', 'cong_qua_10', 'rule:cong_qua_10'),
    (3::smallint, 'number', '11 - ___ = 2', null, null, null, null, '9', null::jsonb, 'Số trừ = số bị trừ - hiệu: 11 - 2 = 9.', 'tru_qua_10', 'rule:tru_qua_10'),
    (3::smallint, 'number', '5 + 7 + 5 = ?', null, null, null, null, '17', null::jsonb, '5 + 7 = 12; 12 + 5 = 17.', 'cong_qua_10', 'rule:cong_qua_10')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 7 and l.lesson_order = 14
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 8 • Bài 15: Ki-lô-gam
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 8, 15, 'Ki-lô-gam', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '29 l + 16 l = ___ l', null, null, null, null, '45', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '20 l + 3 l = ___ l', null, null, null, null, '23', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '38 l + 15 l = ___ l', null, null, null, null, '53', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '39 l + 25 l = ___ l', null, null, null, null, '64', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '24 l + 29 l = ___ l', null, null, null, null, '53', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '15 l + 30 l = ___ l', null, null, null, null, '45', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '15 l + 20 l = ___ l', null, null, null, null, '35', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '15 l + 18 l = ___ l', null, null, null, null, '33', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '32 l + 18 l = ___ l', null, null, null, null, '50', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '32 l + 23 l = ___ l', null, null, null, null, '55', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '26 kg + 26 kg = ___ kg', null, null, null, null, '52', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '9 l + 18 l = ___ l', null, null, null, null, '27', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '78 kg - 45 kg = ___ kg', null, null, null, null, '33', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '26 kg - 15 kg = ___ kg', null, null, null, null, '11', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '69 l - 37 l = ___ l', null, null, null, null, '32', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '49 l - 20 l = ___ l', null, null, null, null, '29', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '39 kg - 13 kg = ___ kg', null, null, null, null, '26', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '51 kg - 45 kg = ___ kg', null, null, null, null, '6', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '21 l - 12 l = ___ l', null, null, null, null, '9', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '78 l - 32 l = ___ l', null, null, null, null, '46', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '74 l - 21 l = ___ l', null, null, null, null, '53', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '43 l - 5 l = ___ l', null, null, null, null, '38', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 33 kg, bao ngô nhẹ hơn bao gạo 5 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '28', null::jsonb, '33 - 5 = 28.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 11 l nước, can bé đựng 20 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '31', null::jsonb, '11 + 20 = 31.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 38 kg, bao ngô nhẹ hơn bao gạo 19 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '19', null::jsonb, '38 - 19 = 19.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 22 l nước, can bé đựng 20 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '42', null::jsonb, '22 + 20 = 42.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 25 l nước, can bé đựng 13 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '38', null::jsonb, '25 + 13 = 38.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 13 l nước, can bé đựng 20 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '33', null::jsonb, '13 + 20 = 33.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 21 l nước, can bé đựng 16 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '37', null::jsonb, '21 + 16 = 37.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 58 kg, bao ngô nhẹ hơn bao gạo 8 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '50', null::jsonb, '58 - 8 = 50.', 'kg_lit', 'rule:kg_lit')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 8 and l.lesson_order = 15
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 8 • Bài 16: Lít
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 8, 16, 'Lít', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '10 kg + 22 kg = ___ kg', null, null, null, null, '32', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '5 kg + 12 kg = ___ kg', null, null, null, null, '17', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '31 l + 22 l = ___ l', null, null, null, null, '53', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '38 l + 6 l = ___ l', null, null, null, null, '44', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '11 kg + 24 kg = ___ kg', null, null, null, null, '35', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '36 kg + 4 kg = ___ kg', null, null, null, null, '40', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '13 l + 13 l = ___ l', null, null, null, null, '26', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '38 kg + 18 kg = ___ kg', null, null, null, null, '56', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '22 kg + 6 kg = ___ kg', null, null, null, null, '28', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '15 kg + 26 kg = ___ kg', null, null, null, null, '41', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '13 l + 20 l = ___ l', null, null, null, null, '33', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (1::smallint, 'number', '34 l + 30 l = ___ l', null, null, null, null, '64', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '47 kg - 35 kg = ___ kg', null, null, null, null, '12', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '60 kg - 44 kg = ___ kg', null, null, null, null, '16', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '36 kg - 19 kg = ___ kg', null, null, null, null, '17', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '85 kg - 36 kg = ___ kg', null, null, null, null, '49', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '90 kg - 30 kg = ___ kg', null, null, null, null, '60', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '57 kg - 18 kg = ___ kg', null, null, null, null, '39', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '21 l - 10 l = ___ l', null, null, null, null, '11', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '31 kg - 22 kg = ___ kg', null, null, null, null, '9', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '66 kg - 7 kg = ___ kg', null, null, null, null, '59', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (2::smallint, 'number', '68 kg - 56 kg = ___ kg', null, null, null, null, '12', null::jsonb, null, 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 55 kg, bao ngô nhẹ hơn bao gạo 14 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '41', null::jsonb, '55 - 14 = 41.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 16 l nước, can bé đựng 7 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '23', null::jsonb, '16 + 7 = 23.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 43 kg, bao ngô nhẹ hơn bao gạo 16 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '27', null::jsonb, '43 - 16 = 27.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 19 l nước, can bé đựng 10 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '29', null::jsonb, '19 + 10 = 29.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 56 kg, bao ngô nhẹ hơn bao gạo 6 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '50', null::jsonb, '56 - 6 = 50.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 15 l nước, can bé đựng 16 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '31', null::jsonb, '15 + 16 = 31.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Bao gạo nặng 44 kg, bao ngô nhẹ hơn bao gạo 6 kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?', null, null, null, null, '38', null::jsonb, '44 - 6 = 38.', 'kg_lit', 'rule:kg_lit'),
    (3::smallint, 'number', 'Can to đựng 23 l nước, can bé đựng 7 l nước. Hỏi cả hai can đựng bao nhiêu lít nước?', null, null, null, null, '30', null::jsonb, '23 + 7 = 30.', 'kg_lit', 'rule:kg_lit')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 8 and l.lesson_order = 16
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 9 • Bài 17: Xăng-ti-mét, đề-xi-mét
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 9, 17, 'Xăng-ti-mét, đề-xi-mét', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '6 dm = ___ cm', null, null, null, null, '60', null::jsonb, '1 dm = 10 cm nên 6 dm = 60 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '5 dm = ___ cm', null, null, null, null, '50', null::jsonb, '1 dm = 10 cm nên 5 dm = 50 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '2 dm = ___ cm', null, null, null, null, '20', null::jsonb, '1 dm = 10 cm nên 2 dm = 20 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '7 dm = ___ cm', null, null, null, null, '70', null::jsonb, '1 dm = 10 cm nên 7 dm = 70 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '1 dm = ___ cm', null, null, null, null, '10', null::jsonb, '1 dm = 10 cm nên 1 dm = 10 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '4 dm = ___ cm', null, null, null, null, '40', null::jsonb, '1 dm = 10 cm nên 4 dm = 40 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '8 dm = ___ cm', null, null, null, null, '80', null::jsonb, '1 dm = 10 cm nên 8 dm = 80 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '9 dm = ___ cm', null, null, null, null, '90', null::jsonb, '1 dm = 10 cm nên 9 dm = 90 cm.', 'do_dai', 'rule:do_dai'),
    (1::smallint, 'number', '3 dm = ___ cm', null, null, null, null, '30', null::jsonb, '1 dm = 10 cm nên 3 dm = 30 cm.', 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '31 cm + 26 cm = ___ cm', null, null, null, null, '57', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '41 cm + 20 cm = ___ cm', null, null, null, null, '61', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '30 cm = ___ dm', null, null, null, null, '3', null::jsonb, '10 cm = 1 dm nên 30 cm = 3 dm.', 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '30 cm + 33 cm = ___ cm', null, null, null, null, '63', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '35 cm + 7 cm = ___ cm', null, null, null, null, '42', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '60 cm = ___ dm', null, null, null, null, '6', null::jsonb, '10 cm = 1 dm nên 60 cm = 6 dm.', 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '24 cm + 26 cm = ___ cm', null, null, null, null, '50', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '41 cm + 16 cm = ___ cm', null, null, null, null, '57', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '40 cm = ___ dm', null, null, null, null, '4', null::jsonb, '10 cm = 1 dm nên 40 cm = 4 dm.', 'do_dai', 'rule:do_dai'),
    (2::smallint, 'number', '45 cm + 5 cm = ___ cm', null, null, null, null, '50', null::jsonb, null, 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '1 m = ___ cm', null, null, null, null, '100', null::jsonb, '1 m = 10 dm = 100 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp:  6 dm  ___  65 cm', '>', '<', '=', null, '<', null::jsonb, '6 dm = 60 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '9 dm 8 cm = ___ cm', null, null, null, null, '98', null::jsonb, '9 dm = 90 cm, thêm 8 cm được 98 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '1 dm 8 cm = ___ cm', null, null, null, null, '18', null::jsonb, '1 dm = 10 cm, thêm 8 cm được 18 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '1 dm 7 cm = ___ cm', null, null, null, null, '17', null::jsonb, '1 dm = 10 cm, thêm 7 cm được 17 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '6 dm 7 cm = ___ cm', null, null, null, null, '67', null::jsonb, '6 dm = 60 cm, thêm 7 cm được 67 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '8 dm 7 cm = ___ cm', null, null, null, null, '87', null::jsonb, '8 dm = 80 cm, thêm 7 cm được 87 cm.', 'do_dai', 'rule:do_dai'),
    (3::smallint, 'number', '9 dm 9 cm = ___ cm', null, null, null, null, '99', null::jsonb, '9 dm = 90 cm, thêm 9 cm được 99 cm.', 'do_dai', 'rule:do_dai')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 9 and l.lesson_order = 17
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 10 • Bài 18: Phép cộng có nhớ trong phạm vi 100
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 10, 18, 'Phép cộng có nhớ trong phạm vi 100', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '19 + 4 = ?', null, null, null, null, '23', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '79 + 3 = ?', null, null, null, null, '82', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '39 + 6 = ?', null, null, null, null, '45', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'multiple_choice', '35 + 7 = ?', '43', '32', '42', '52', '42', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '86 + 8 = ?', null, null, null, null, '94', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '15 + 9 = ?', null, null, null, null, '24', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'multiple_choice', '77 + 4 = ?', '83', '80', '79', '81', '81', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'multiple_choice', '34 + 8 = ?', '44', '42', '41', '43', '42', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '77 + 4 = ?', null, null, null, null, '81', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '32 + 8 = ?', null, null, null, null, '40', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '53 + 9 = ?', null, null, null, null, '62', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (1::smallint, 'number', '54 + 6 = ?', null, null, null, null, '60', null::jsonb, null, 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '38 + 26 = ?', null, null, null, null, '64', null::jsonb, 'Cộng hàng đơn vị: 8 + 6 = 14, viết 4 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '35 + 47 = ?', null, null, null, null, '82', null::jsonb, 'Cộng hàng đơn vị: 5 + 7 = 12, viết 2 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '12 + 59 = ?', null, null, null, null, '71', null::jsonb, 'Cộng hàng đơn vị: 2 + 9 = 11, viết 1 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '53 + 29 = ?', null, null, null, null, '82', null::jsonb, 'Cộng hàng đơn vị: 3 + 9 = 12, viết 2 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '28 + 54 = ?', null, null, null, null, '82', null::jsonb, 'Cộng hàng đơn vị: 8 + 4 = 12, viết 2 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '54 + 16 = ?', null, null, null, null, '70', null::jsonb, 'Cộng hàng đơn vị: 4 + 6 = 10, viết 0 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '24 + 28 = ?', null, null, null, null, '52', null::jsonb, 'Cộng hàng đơn vị: 4 + 8 = 12, viết 2 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '64 + 26 = ?', null, null, null, null, '90', null::jsonb, 'Cộng hàng đơn vị: 4 + 6 = 10, viết 0 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '42 + 19 = ?', null, null, null, null, '61', null::jsonb, 'Cộng hàng đơn vị: 2 + 9 = 11, viết 1 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (2::smallint, 'number', '28 + 69 = ?', null, null, null, null, '97', null::jsonb, 'Cộng hàng đơn vị: 8 + 9 = 17, viết 7 nhớ 1.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', 'Hoa có 22 quả cam, Bình có 68 quả cam. Hỏi cả hai bạn có tất cả bao nhiêu quả cam?', null, null, null, null, '90', null::jsonb, '22 + 68 = 90.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', 'Mai có 39 nhãn vở, Bình có 24 nhãn vở. Hỏi cả hai bạn có tất cả bao nhiêu nhãn vở?', null, null, null, null, '63', null::jsonb, '39 + 24 = 63.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', '66 + ___ = 85', null, null, null, null, '19', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 85 - 66 = 19.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', 'Hoa có 59 bông hoa, Lan có 22 bông hoa. Hỏi cả hai bạn có tất cả bao nhiêu bông hoa?', null, null, null, null, '81', null::jsonb, '59 + 22 = 81.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', '___ + 67 = 83', null, null, null, null, '16', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 83 - 67 = 16.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', 'Ngọc có 13 quyển vở, Mai có 28 quyển vở. Hỏi cả hai bạn có tất cả bao nhiêu quyển vở?', null, null, null, null, '41', null::jsonb, '13 + 28 = 41.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', 'Hà có 28 viên bi, Nam có 18 viên bi. Hỏi cả hai bạn có tất cả bao nhiêu viên bi?', null, null, null, null, '46', null::jsonb, '28 + 18 = 46.', 'cong_co_nho_100', 'rule:cong_co_nho_100'),
    (3::smallint, 'number', '22 + ___ = 81', null, null, null, null, '59', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 81 - 22 = 59.', 'cong_co_nho_100', 'rule:cong_co_nho_100')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 10 and l.lesson_order = 18
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Toán • Tuần 10 • Bài 19: Phép trừ có nhớ trong phạm vi 100
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 10, 19, 'Phép trừ có nhớ trong phạm vi 100', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '68 - 9 = ?', null, null, null, null, '59', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '55 - 9 = ?', '47', '36', '48', '46', '46', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '30 - 4 = ?', '36', '26', '27', '25', '26', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '45 - 8 = ?', '36', '39', '27', '37', '37', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'number', '56 - 8 = ?', null, null, null, null, '48', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'number', '74 - 8 = ?', null, null, null, null, '66', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'number', '51 - 6 = ?', null, null, null, null, '45', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '71 - 7 = ?', '74', '54', '64', '63', '64', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'number', '38 - 9 = ?', null, null, null, null, '29', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '44 - 6 = ?', '38', '39', '28', '36', '38', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'number', '53 - 5 = ?', null, null, null, null, '48', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (1::smallint, 'multiple_choice', '67 - 9 = ?', '68', '57', '60', '58', '58', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '70 - 44 = ?', null, null, null, null, '26', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'multiple_choice', '52 - 14 = ?', '48', '28', '39', '38', '38', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '48 - 19 = ?', null, null, null, null, '29', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '43 - 18 = ?', null, null, null, null, '25', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '67 - 38 = ?', null, null, null, null, '29', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'multiple_choice', '90 - 36 = ?', '54', '44', '55', '64', '54', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '54 - 39 = ?', null, null, null, null, '15', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'multiple_choice', '51 - 25 = ?', '26', '24', '16', '25', '26', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '93 - 58 = ?', null, null, null, null, '35', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (2::smallint, 'number', '32 - 15 = ?', null, null, null, null, '17', null::jsonb, null, 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', 'Lan có 76 cái bút chì, Lan cho bạn 19 cái bút chì. Hỏi Lan còn lại bao nhiêu cái bút chì?', null, null, null, null, '57', null::jsonb, '76 - 19 = 57.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', '___ - 19 = 28', null, null, null, null, '47', null::jsonb, 'Số bị trừ = hiệu + số trừ: 28 + 19 = 47.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', 'Ngọc có 31 quả táo, Ngọc cho bạn 19 quả táo. Hỏi Ngọc còn lại bao nhiêu quả táo?', null, null, null, null, '12', null::jsonb, '31 - 19 = 12.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', '___ - 12 = 48', null, null, null, null, '60', null::jsonb, 'Số bị trừ = hiệu + số trừ: 48 + 12 = 60.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', 'Lan có 32 quả táo, Lan cho bạn 17 quả táo. Hỏi Lan còn lại bao nhiêu quả táo?', null, null, null, null, '15', null::jsonb, '32 - 17 = 15.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', '94 - ___ = 39', null, null, null, null, '55', null::jsonb, 'Số trừ = số bị trừ - hiệu: 94 - 39 = 55.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', '44 - ___ = 16', null, null, null, null, '28', null::jsonb, 'Số trừ = số bị trừ - hiệu: 44 - 16 = 28.', 'tru_co_nho_100', 'rule:tru_co_nho_100'),
    (3::smallint, 'number', '85 - ___ = 39', null, null, null, null, '46', null::jsonb, 'Số trừ = số bị trừ - hiệu: 85 - 39 = 46.', 'tru_co_nho_100', 'rule:tru_co_nho_100')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 10 and l.lesson_order = 19
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 1 • Bài 1: Bảng chữ cái tiếng Việt
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 1, 1, 'Bảng chữ cái tiếng Việt', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "p" là chữ nào?', 'q', 'y', 'â', 'g', 'q', null::jsonb, 'Thứ tự: ơ, p, q.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "h" là chữ nào?', 'ư', 'y', 'i', 'c', 'i', null::jsonb, 'Thứ tự: g, h, i.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "r" là chữ nào?', 'y', 'k', 'ă', 's', 's', null::jsonb, 'Thứ tự: q, r, s.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "r" là chữ nào?', 'n', 's', 'ư', 'đ', 's', null::jsonb, 'Thứ tự: q, r, s.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "q" là chữ nào?', 'g', 'v', 'ê', 'r', 'r', null::jsonb, 'Thứ tự: p, q, r.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "u" là chữ nào?', 'p', 'h', 'y', 'ư', 'ư', null::jsonb, 'Thứ tự: t, u, ư.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "p" là chữ nào?', 't', 'q', 'b', 'a', 'q', null::jsonb, 'Thứ tự: ơ, p, q.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "ă" là chữ nào?', 'b', 'â', 's', 'm', 'â', null::jsonb, 'Thứ tự: a, ă, â.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "p" là chữ nào?', 'g', 'q', 'c', 'đ', 'q', null::jsonb, 'Thứ tự: ơ, p, q.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "o" là chữ nào?', 'u', 'ô', 'd', 'x', 'ô', null::jsonb, 'Thứ tự: n, o, ô.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "q" là chữ nào?', 's', 'c', 'đ', 'r', 'r', null::jsonb, 'Thứ tự: p, q, r.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (1::smallint, 'multiple_choice', 'Chữ cái đứng ngay sau chữ "đ" là chữ nào?', 'i', 'b', 'e', 'o', 'e', null::jsonb, 'Thứ tự: d, đ, e.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "x" là chữ nào?', 'ô', 'v', 'k', 'u', 'v', null::jsonb, 'Thứ tự: v, x, y.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "â" là chữ nào?', 'ă', 'o', 'ư', 'q', 'ă', null::jsonb, 'Thứ tự: ă, â, b.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "x" là chữ nào?', 'p', 'v', 'n', 'q', 'v', null::jsonb, 'Thứ tự: v, x, y.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "â" là chữ nào?', 'ă', 'c', 'đ', 'ơ', 'ă', null::jsonb, 'Thứ tự: ă, â, b.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "ă" là chữ nào?', 'h', 'a', 'c', 'ơ', 'a', null::jsonb, 'Thứ tự: a, ă, â.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "x" là chữ nào?', 'm', 'g', 'v', 'ư', 'v', null::jsonb, 'Thứ tự: v, x, y.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "m" là chữ nào?', 'ô', 'o', 'c', 'l', 'l', null::jsonb, 'Thứ tự: l, m, n.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "d" là chữ nào?', 'ê', 'c', 'ă', 'i', 'c', null::jsonb, 'Thứ tự: c, d, đ.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "i" là chữ nào?', 'm', 'ô', 'ơ', 'h', 'h', null::jsonb, 'Thứ tự: h, i, k.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (2::smallint, 'multiple_choice', 'Chữ cái đứng ngay trước chữ "m" là chữ nào?', 'd', 'u', 'l', 'a', 'l', null::jsonb, 'Thứ tự: l, m, n.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'number', 'Bảng chữ cái tiếng Việt có bao nhiêu chữ cái?', null, null, null, null, '29', null::jsonb, 'Bảng chữ cái tiếng Việt có 29 chữ cái.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "ă" là chữ nào?', null, null, null, null, 'â', null::jsonb, 'Thứ tự: a, ă, â.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "t" là chữ nào?', null, null, null, null, 'u', null::jsonb, 'Thứ tự: s, t, u.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "m" là chữ nào?', null, null, null, null, 'n', null::jsonb, 'Thứ tự: l, m, n.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "k" là chữ nào?', null, null, null, null, 'l', null::jsonb, 'Thứ tự: i, k, l.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "g" là chữ nào?', null, null, null, null, 'h', null::jsonb, 'Thứ tự: ê, g, h.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "x" là chữ nào?', null, null, null, null, 'y', null::jsonb, 'Thứ tự: v, x, y.', 'bang_chu_cai', 'rule:bang_chu_cai'),
    (3::smallint, 'text', 'Chữ cái đứng ngay sau chữ "e" là chữ nào?', null, null, null, null, 'ê', null::jsonb, 'Thứ tự: đ, e, ê.', 'bang_chu_cai', 'rule:bang_chu_cai')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 1 and l.lesson_order = 1
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 1 • Bài 2: Chính tả: c hay k
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 1, 2, 'Chính tả: c hay k', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'que cem', 'cái cìm', 'que kem', 'con kua', 'que kem', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'kổng trường', 'con ciến', 'con cá', 'con ká', 'con cá', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'quả kam', 'con ciến', 'kốc nước', 'cốc nước', 'cốc nước', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cái cẹo', 'cì diệu', 'dòng cênh', 'cái kẹo', 'cái kẹo', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con kua', 'lá kờ', 'cái céo', 'lá cờ', 'lá cờ', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'lá kờ', 'lá cờ', 'con ká', 'kốc nước', 'lá cờ', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'kể chuyện', 'dòng cênh', 'cể chuyện', 'cái cẹo', 'kể chuyện', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'lá cờ', 'cể chuyện', 'bãi kỏ', 'lá kờ', 'lá cờ', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'hoa kúc', 'cái cẹo', 'kây xanh', 'hoa cúc', 'hoa cúc', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cây xanh', 'con ciến', 'đeo cính', 'kây xanh', 'cây xanh', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cầu thang', 'kầu thang', 'cể chuyện', 'kây xanh', 'cầu thang', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'lá kờ', 'que cem', 'que kem', 'con ciến', 'que kem', null::jsonb, 'Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  ___ô giáo', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: cô giáo. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  ___ể chuyện', null, null, null, null, 'k', null::jsonb, 'Viết đúng là: kể chuyện. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  bãi ___ỏ', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: bãi cỏ. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  cái ___ìm', null, null, null, null, 'k', null::jsonb, 'Viết đúng là: cái kìm. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  ___ầu thang', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: cầu thang. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  đeo ___ính', null, null, null, null, 'k', null::jsonb, 'Viết đúng là: đeo kính. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  dòng ___ênh', null, null, null, null, 'k', null::jsonb, 'Viết đúng là: dòng kênh. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  con ___á', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: con cá. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  hoa ___úc', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: hoa cúc. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (2::smallint, 'text', 'Điền "c" hoặc "k" vào chỗ trống:  ___ây xanh', null, null, null, null, 'c', null::jsonb, 'Viết đúng là: cây xanh. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'lá cờ', 'con kua', 'cổng trường', 'cốc nước', 'con kua', null::jsonb, 'Viết đúng là: con cua. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'hoa kúc', 'cổng trường', 'bãi cỏ', 'cầu thang', 'hoa kúc', null::jsonb, 'Viết đúng là: hoa cúc. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'đeo kính', 'con cua', 'kể chuyện', 'kổng trường', 'kổng trường', null::jsonb, 'Viết đúng là: cổng trường. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'cì diệu', 'cái kéo', 'lá cờ', 'cây xanh', 'cì diệu', null::jsonb, 'Viết đúng là: kì diệu. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'cốc nước', 'con cá', 'kô giáo', 'đeo kính', 'kô giáo', null::jsonb, 'Viết đúng là: cô giáo. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'cổng trường', 'cô giáo', 'đeo kính', 'kây xanh', 'kây xanh', null::jsonb, 'Viết đúng là: cây xanh. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'quả kam', 'con cua', 'cô giáo', 'cổng trường', 'quả kam', null::jsonb, 'Viết đúng là: quả cam. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'bãi kỏ', 'con cá', 'cái kéo', 'que kem', 'bãi kỏ', null::jsonb, 'Viết đúng là: bãi cỏ. Viết k trước i, e, ê; viết c trước các chữ còn lại.', 'chinh_ta_c_k', 'rule:chinh_ta_c_k')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 1 and l.lesson_order = 2
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 2 • Bài 3: Từ chỉ sự vật, hoạt động, đặc điểm
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 2, 3, 'Từ chỉ sự vật, hoạt động, đặc điểm', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'con chó', 'chạy', 'ngoan ngoãn', 'đọc sách', 'con chó', null::jsonb, '"con chó" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'nhảy dây', 'ngoan ngoãn', 'cái cặp', 'bơi', 'cái cặp', null::jsonb, '"cái cặp" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'nhỏ xíu', 'bơi', 'bàn học', 'hát', 'bàn học', null::jsonb, '"bàn học" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'bông hoa', 'xanh biếc', 'bơi', 'viết bài', 'bông hoa', null::jsonb, '"bông hoa" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'mềm mại', 'ngôi nhà', 'hiền lành', 'nhảy dây', 'ngôi nhà', null::jsonb, '"ngôi nhà" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'đá bóng', 'quét nhà', 'con mèo', 'rửa bát', 'con mèo', null::jsonb, '"con mèo" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'cái cặp', 'tưới cây', 'chạy', 'rửa bát', 'cái cặp', null::jsonb, '"cái cặp" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'học bài', 'rửa bát', 'quả bóng', 'xanh biếc', 'quả bóng', null::jsonb, '"quả bóng" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'xinh đẹp', 'xanh biếc', 'con mèo', 'chăm chỉ', 'con mèo', null::jsonb, '"con mèo" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'học sinh', 'hát', 'vui vẻ', 'thấp', 'học sinh', null::jsonb, '"học sinh" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'học sinh', 'xanh biếc', 'tưới cây', 'thơm ngát', 'học sinh', null::jsonb, '"học sinh" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'rửa bát', 'thấp', 'cái cặp', 'to lớn', 'cái cặp', null::jsonb, '"cái cặp" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'học bài', 'hiền lành', 'ngôi nhà', 'mềm mại', 'học bài', null::jsonb, '"học bài" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'cô giáo', 'thơm ngát', 'dịu dàng', 'bơi', 'bơi', null::jsonb, '"bơi" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'con chó', 'con mèo', 'học bài', 'vui vẻ', 'học bài', null::jsonb, '"học bài" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'nấu cơm', 'cái bảng', 'dịu dàng', 'hiền lành', 'nấu cơm', null::jsonb, '"nấu cơm" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'ngôi nhà', 'tưới cây', 'mềm mại', 'chăm chỉ', 'tưới cây', null::jsonb, '"tưới cây" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'vẽ tranh', 'đôi dép', 'thơm ngát', 'cái cặp', 'vẽ tranh', null::jsonb, '"vẽ tranh" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'rửa bát', 'hiền lành', 'đôi dép', 'bông hoa', 'rửa bát', null::jsonb, '"rửa bát" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'múa', 'chăm chỉ', 'con chó', 'quả bóng', 'múa', null::jsonb, '"múa" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'bông hoa', 'mềm mại', 'đỏ tươi', 'rửa bát', 'rửa bát', null::jsonb, '"rửa bát" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'vui vẻ', 'to lớn', 'tưới cây', 'mềm mại', 'tưới cây', null::jsonb, '"tưới cây" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ hoạt động?', 'đọc sách', 'nấu cơm', 'rửa bát', 'cô giáo', 'cô giáo', null::jsonb, 'Các từ còn lại đều chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ đặc điểm?', 'chăm chỉ', 'thấp', 'con mèo', 'thơm ngát', 'con mèo', null::jsonb, 'Các từ còn lại đều chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ hoạt động?', 'múa', 'đá bóng', 'chạy', 'hiền lành', 'hiền lành', null::jsonb, 'Các từ còn lại đều chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ sự vật?', 'cái bảng', 'xanh biếc', 'bông hoa', 'đôi dép', 'xanh biếc', null::jsonb, 'Các từ còn lại đều chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ hoạt động?', 'đá bóng', 'múa', 'nhảy dây', 'dịu dàng', 'dịu dàng', null::jsonb, 'Các từ còn lại đều chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ sự vật?', 'múa', 'quả bóng', 'bàn học', 'đôi dép', 'múa', null::jsonb, 'Các từ còn lại đều chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'chăm chỉ', 'vẽ tranh', 'quét nhà', 'con chó', 'chăm chỉ', null::jsonb, '"chăm chỉ" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ hoạt động?', 'đọc sách', 'ngôi nhà', 'tưới cây', 'đá bóng', 'ngôi nhà', null::jsonb, 'Các từ còn lại đều chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 2 and l.lesson_order = 3
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 2 • Bài 4: Chính tả: g hay gh
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 2, 4, 'Chính tả: g hay gh', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con ghẹ', 'con gẹ', 'con ghấu bông', 'gép hình', 'con ghẹ', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ghõ cửa', 'con ghẹ', 'con gẹ', 'cái gim', 'con ghẹ', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con ghấu', 'con ghẹ', 'con ghấu bông', 'con gẹ', 'con ghẹ', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cái ghối', 'ghọn gàng', 'bàn gỗ', 'bàn ghỗ', 'bàn gỗ', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cây ghậy', 'con gẹ', 'con ghẹ', 'thác gềnh', 'con ghẹ', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con gà', 'con ghà', 'củ ghừng', 'con ghấu', 'con gà', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con ghấu', 'hạt ghạo', 'cái gương', 'cái ghương', 'cái gương', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ghép hình', 'cái gim', 'con gẹ', 'gép hình', 'ghép hình', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cái gế', 'con ghà', 'cái ghế', 'bàn ghỗ', 'cái ghế', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ghõ cửa', 'cây gậy', 'cây ghậy', 'con ghấu', 'cây gậy', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cái gế', 'cái gim', 'con ghà', 'con gà', 'con gà', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'cái ghương', 'ghõ cửa', 'hạt ghạo', 'hạt gạo', 'hạt gạo', null::jsonb, 'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  con ___ấu bông', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: con gấu bông. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  cây ___ậy', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: cây gậy. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  con ___à', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: con gà. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  ___i nhớ', null, null, null, null, 'gh', null::jsonb, 'Viết đúng là: ghi nhớ. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  ___ọn gàng', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: gọn gàng. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  bàn ___ỗ', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: bàn gỗ. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  cái ___ối', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: cái gối. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  cái ___ương', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: cái gương. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  củ ___ừng', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: củ gừng. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (2::smallint, 'text', 'Điền "g" hoặc "gh" vào chỗ trống:  con ___ấu', null, null, null, null, 'g', null::jsonb, 'Viết đúng là: con gấu. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'thác gềnh', 'gọn gàng', 'ghép hình', 'hạt gạo', 'thác gềnh', null::jsonb, 'Viết đúng là: thác ghềnh. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'con gà', 'con ghấu', 'thác ghềnh', 'cái gương', 'con ghấu', null::jsonb, 'Viết đúng là: con gấu. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'con ghẹ', 'hạt ghạo', 'gọn gàng', 'ghép hình', 'hạt ghạo', null::jsonb, 'Viết đúng là: hạt gạo. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'cái ghế', 'cái gối', 'ghi nhớ', 'gép hình', 'gép hình', null::jsonb, 'Viết đúng là: ghép hình. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'hạt ghạo', 'cây gậy', 'ghép hình', 'cái gương', 'hạt ghạo', null::jsonb, 'Viết đúng là: hạt gạo. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'cái gối', 'cái gương', 'con ghấu bông', 'con gấu', 'con ghấu bông', null::jsonb, 'Viết đúng là: con gấu bông. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'gọn gàng', 'thác ghềnh', 'cái gim', 'ghi nhớ', 'cái gim', null::jsonb, 'Viết đúng là: cái ghim. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'bàn gỗ', 'ghọn gàng', 'con gấu bông', 'cái gối', 'ghọn gàng', null::jsonb, 'Viết đúng là: gọn gàng. Viết gh trước i, e, ê; viết g trước các chữ còn lại.', 'chinh_ta_g_gh', 'rule:chinh_ta_g_gh')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 2 and l.lesson_order = 4
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 3 • Bài 5: Dấu câu và kiểu câu
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 3, 5, 'Dấu câu và kiểu câu', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Em là học sinh lớp 2 ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bà kể chuyện cổ tích cho em nghe ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Chúng em chơi đá cầu ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Con mèo đâu rồi ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Hôm nay bạn có vui không ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Nhà bạn ở đâu ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Sân trường có cây bàng rất to ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Mẹ em là cô giáo ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Con mèo nằm trên ghế ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bạn tên là gì ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Hôm nay trời nắng đẹp ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Ai đang hát thế ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bạn học lớp mấy ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Hoan hô, đội mình thắng rồi ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Ồ, tuyết rơi kìa ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Trời ơi, con diều bay cao quá ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  A, mẹ về rồi ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bố em đi làm từ sáng sớm ___', '.', '?', '!', null, '.', null::jsonb, 'Câu kể kết thúc bằng dấu chấm.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bao giờ chúng mình đi chơi ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Chà, chiếc cặp mới đẹp quá ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Ôi, bông hoa đẹp quá ___', '.', '?', '!', null, '!', null::jsonb, 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp:  Bạn thích con vật nào nhất ___', '.', '?', '!', null, '?', null::jsonb, 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.', 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu nêu đặc điểm (Ai thế nào?)?', 'Bố tưới cây ngoài vườn.', 'Bạn Nam là lớp trưởng.', 'Bông hoa hồng rất đẹp.', 'Đây là cô giáo của em.', 'Bông hoa hồng rất đẹp.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu nêu đặc điểm (Ai thế nào?)?', 'Em là học sinh lớp 2A.', 'Chú mèo nhà em rất ngoan.', 'Mẹ em là bác sĩ.', 'Bạn Nam là lớp trưởng.', 'Chú mèo nhà em rất ngoan.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu nêu hoạt động (Ai làm gì?)?', 'Em đang đọc truyện.', 'Chú mèo nhà em rất ngoan.', 'Cô giáo em rất hiền.', 'Mẹ em là bác sĩ.', 'Em đang đọc truyện.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu nêu hoạt động (Ai làm gì?)?', 'Bông hoa hồng rất đẹp.', 'Chú mèo nhà em rất ngoan.', 'Bố tưới cây ngoài vườn.', 'Đây là cô giáo của em.', 'Bố tưới cây ngoài vườn.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu hỏi?', 'Bố em đi làm từ sáng sớm.', 'Hôm nay trời nắng đẹp.', 'Chúng em chơi đá cầu.', 'Hôm nay bạn có vui không?', 'Hôm nay bạn có vui không?', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu giới thiệu (Ai là gì?)?', 'Chú mèo nhà em rất ngoan.', 'Mẹ em là bác sĩ.', 'Bố tưới cây ngoài vườn.', 'Bông hoa hồng rất đẹp.', 'Mẹ em là bác sĩ.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu nêu hoạt động (Ai làm gì?)?', 'Em là học sinh lớp 2A.', 'Bầu trời hôm nay trong xanh.', 'Bạn Nam là lớp trưởng.', 'Em đang đọc truyện.', 'Em đang đọc truyện.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau'),
    (3::smallint, 'multiple_choice', 'Câu nào là câu giới thiệu (Ai là gì?)?', 'Cô giáo em rất hiền.', 'Bạn Nam là lớp trưởng.', 'Bố tưới cây ngoài vườn.', 'Mẹ đang nấu cơm.', 'Bạn Nam là lớp trưởng.', null::jsonb, null, 'dau_cau_kieu_cau', 'rule:dau_cau_kieu_cau')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 3 and l.lesson_order = 5
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 3 • Bài 6: Chính tả: ng hay ngh
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 3, 6, 'Chính tả: ng hay ngh', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'bắp nghô', 'suy ngĩ', 'con ngé', 'suy nghĩ', 'suy nghĩ', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'suy nghĩ', 'suy ngĩ', 'ngỉ ngơi', 'một ngìn', 'suy nghĩ', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ngiêng đầu', 'nghày mai', 'ngày mai', 'nghón tay', 'ngày mai', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'bắp nghô', 'lắng nge', 'con nghan', 'con ngan', 'con ngan', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'kẹo ngọt', 'con nghỗng', 'đi nghủ', 'kẹo nghọt', 'kẹo ngọt', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ngỉ ngơi', 'đi nghủ', 'nghỉ ngơi', 'một ngìn', 'nghỉ ngơi', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ngề nông', 'ngiêng đầu', 'nghề nông', 'con ngé', 'nghề nông', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'nghày mai', 'con nghựa', 'suy ngĩ', 'ngày mai', 'ngày mai', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'suy nghĩ', 'bắp nghô', 'nghón tay', 'suy ngĩ', 'suy nghĩ', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'con nghỗng', 'nghà voi', 'con nghé', 'con ngé', 'con nghé', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ngề nông', 'nghà voi', 'con nghựa', 'ngà voi', 'ngà voi', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'nghõ nhỏ', 'bắp nghô', 'con ngé', 'con nghé', 'con nghé', null::jsonb, 'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  suy ___ĩ', null, null, null, null, 'ngh', null::jsonb, 'Viết đúng là: suy nghĩ. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  lắng ___e', null, null, null, null, 'ngh', null::jsonb, 'Viết đúng là: lắng nghe. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  bắp ___ô', null, null, null, null, 'ng', null::jsonb, 'Viết đúng là: bắp ngô. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  ___à voi', null, null, null, null, 'ng', null::jsonb, 'Viết đúng là: ngà voi. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  ___ỉ ngơi', null, null, null, null, 'ngh', null::jsonb, 'Viết đúng là: nghỉ ngơi. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  ___ày mai', null, null, null, null, 'ng', null::jsonb, 'Viết đúng là: ngày mai. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  con ___é', null, null, null, null, 'ngh', null::jsonb, 'Viết đúng là: con nghé. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  ___ề nông', null, null, null, null, 'ngh', null::jsonb, 'Viết đúng là: nghề nông. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  kẹo ___ọt', null, null, null, null, 'ng', null::jsonb, 'Viết đúng là: kẹo ngọt. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (2::smallint, 'text', 'Điền "ng" hoặc "ngh" vào chỗ trống:  con ___an', null, null, null, null, 'ng', null::jsonb, 'Viết đúng là: con ngan. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'con ngựa', 'đi ngủ', 'ngỉ ngơi', 'bắp ngô', 'ngỉ ngơi', null::jsonb, 'Viết đúng là: nghỉ ngơi. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'ngiêng đầu', 'con ngựa', 'ngõ nhỏ', 'nghề nông', 'ngiêng đầu', null::jsonb, 'Viết đúng là: nghiêng đầu. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'con ngan', 'lắng nge', 'con ngựa', 'đi ngủ', 'lắng nge', null::jsonb, 'Viết đúng là: lắng nghe. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'bắp ngô', 'lắng nghe', 'nghỉ ngơi', 'nghà voi', 'nghà voi', null::jsonb, 'Viết đúng là: ngà voi. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'nghiêng đầu', 'con nghé', 'lắng nghe', 'con nghựa', 'con nghựa', null::jsonb, 'Viết đúng là: con ngựa. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'lắng nghe', 'bắp nghô', 'con ngựa', 'đi ngủ', 'bắp nghô', null::jsonb, 'Viết đúng là: bắp ngô. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'nghề nông', 'ngõ nhỏ', 'con ngan', 'một ngìn', 'một ngìn', null::jsonb, 'Viết đúng là: một nghìn. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh'),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'con ngỗng', 'suy nghĩ', 'ngỉ ngơi', 'kẹo ngọt', 'ngỉ ngơi', null::jsonb, 'Viết đúng là: nghỉ ngơi. Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', 'chinh_ta_ng_ngh', 'rule:chinh_ta_ng_ngh')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 3 and l.lesson_order = 6
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 4 • Bài 7: Từ trái nghĩa
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 4, 7, 'Từ trái nghĩa', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "to" là:', 'dưới', 'cũ', 'nhỏ', 'nóng', 'nhỏ', null::jsonb, '"to" và "nhỏ" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "sai" là:', 'đúng', 'sạch', 'yếu', 'ngọt', 'đúng', null::jsonb, '"sai" và "đúng" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "mới" là:', 'khỏe', 'to', 'chậm', 'cũ', 'cũ', null::jsonb, '"mới" và "cũ" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "vui" là:', 'cao', 'ngắn', 'buồn', 'già', 'buồn', null::jsonb, '"vui" và "buồn" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "gần" là:', 'dưới', 'bẩn', 'ngọt', 'xa', 'xa', null::jsonb, '"gần" và "xa" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "xa" là:', 'to', 'ngắn', 'gần', 'chăm chỉ', 'gần', null::jsonb, '"xa" và "gần" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "nhanh" là:', 'chậm', 'gần', 'nhỏ', 'trên', 'chậm', null::jsonb, '"nhanh" và "chậm" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "buồn" là:', 'cũ', 'vui', 'yếu', 'ngọt', 'vui', null::jsonb, '"buồn" và "vui" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "cao" là:', 'thấp', 'đen', 'mới', 'già', 'thấp', null::jsonb, '"cao" và "thấp" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "nóng" là:', 'sạch', 'lạnh', 'dài', 'đắng', 'lạnh', null::jsonb, '"nóng" và "lạnh" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "trẻ" là:', 'sạch', 'già', 'mới', 'nhỏ', 'già', null::jsonb, '"trẻ" và "già" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "cũ" là:', 'mới', 'xa', 'lười biếng', 'to', 'mới', null::jsonb, '"cũ" và "mới" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "đêm":', null, null, null, null, 'ngày', null::jsonb, '"đêm" và "ngày" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "sáng":', null, null, null, null, 'tối', null::jsonb, '"sáng" và "tối" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "dưới":', null, null, null, null, 'trên', null::jsonb, '"dưới" và "trên" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "đắng":', null, null, null, null, 'ngọt', null::jsonb, '"đắng" và "ngọt" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "bẩn":', null, null, null, null, 'sạch', null::jsonb, '"bẩn" và "sạch" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "tối":', null, null, null, null, 'sáng', null::jsonb, '"tối" và "sáng" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "cứng":', null, null, null, null, 'mềm', null::jsonb, '"cứng" và "mềm" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "ngày":', null, null, null, null, 'đêm', null::jsonb, '"ngày" và "đêm" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "nóng":', null, null, null, null, 'lạnh', null::jsonb, '"nóng" và "lạnh" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (2::smallint, 'text', 'Viết từ trái nghĩa với từ "đúng":', null, null, null, null, 'sai', null::jsonb, '"đúng" và "sai" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'ngọt – chậm', 'nhanh – nhỏ', 'to – đắng', 'đúng – sai', 'đúng – sai', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'chăm chỉ – đêm', 'ngày – lạnh', 'nóng – lười biếng', 'khỏe – yếu', 'khỏe – yếu', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'nóng – lạnh', 'cứng – nhỏ', 'to – lười biếng', 'chăm chỉ – mềm', 'nóng – lạnh', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'to – lạnh', 'xa – gần', 'ngày – nhỏ', 'nóng – đêm', 'xa – gần', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'mới – cũ', 'nhanh – đen', 'trắng – đắng', 'ngọt – chậm', 'mới – cũ', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'mới – trẻ', 'già – dưới', 'trên – cũ', 'đúng – sai', 'đúng – sai', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'cao – thấp', 'nhanh – sai', 'đúng – đắng', 'ngọt – chậm', 'cao – thấp', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia'),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa?', 'vui – cũ', 'mới – mềm', 'ngày – đêm', 'cứng – buồn', 'ngày – đêm', null::jsonb, null, 'tu_trai_nghia', 'rule:tu_trai_nghia')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 4 and l.lesson_order = 7
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);

-- Tiếng Việt • Tuần 4 • Bài 8: Chọn từ điền vào câu
insert into public.lessons (subject_id, week_number, lesson_order, name, is_published, publish_mode)
select id, 4, 8, 'Chọn từ điền vào câu', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, v.generator_type
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Con gà trống ___ ò ó o mỗi sáng.', 'bơi', 'gáy', 'sủa', 'hót', 'gáy', null::jsonb, 'Con gà trống gáy ò ó o mỗi sáng.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'cô giáo', 'vẽ tranh', 'viết bài', 'bơi', 'cô giáo', null::jsonb, '"cô giáo" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Con chó ___ gâu gâu.', 'hót', 'gáy', 'kêu meo meo', 'sủa', 'sủa', null::jsonb, 'Con chó sủa gâu gâu.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'hiền lành', 'to lớn', 'học sinh', 'vui vẻ', 'học sinh', null::jsonb, '"học sinh" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Em dùng ___ để cắt giấy.', 'bút', 'tẩy', 'thước', 'kéo', 'kéo', null::jsonb, 'Em dùng kéo để cắt giấy.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'viết bài', 'con mèo', 'vui vẻ', 'nhảy dây', 'con mèo', null::jsonb, '"con mèo" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Con cá đang ___ dưới nước.', 'bay', 'bơi', 'chạy', 'nhảy dây', 'bơi', null::jsonb, 'Con cá đang bơi dưới nước.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'dịu dàng', 'nhỏ xíu', 'viết bài', 'con chó', 'con chó', null::jsonb, '"con chó" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'đá bóng', 'cây bàng', 'thơm ngát', 'mềm mại', 'cây bàng', null::jsonb, '"cây bàng" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'rửa bát', 'học bài', 'quả bóng', 'vui vẻ', 'quả bóng', null::jsonb, '"quả bóng" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Mẹ đang ___ cơm trong bếp.', 'bay', 'đọc', 'viết', 'nấu', 'nấu', null::jsonb, 'Mẹ đang nấu cơm trong bếp.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sự vật?', 'đọc sách', 'bông hoa', 'mềm mại', 'hát', 'bông hoa', null::jsonb, '"bông hoa" là từ chỉ sự vật.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Em dùng ___ để viết bài.', 'kéo', 'hồ dán', 'tẩy', 'bút', 'bút', null::jsonb, 'Em dùng bút để viết bài.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'ngoan ngoãn', 'thơm ngát', 'bông hoa', 'nhảy dây', 'nhảy dây', null::jsonb, '"nhảy dây" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Muối có vị ___.', 'mặn', 'ngọt', 'chua', 'cay', 'mặn', null::jsonb, 'Muối có vị mặn.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'nhỏ xíu', 'hát', 'bàn học', 'thấp', 'hát', null::jsonb, '"hát" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Quả chanh có vị ___.', 'cay', 'ngọt lịm', 'mặn', 'chua', 'chua', null::jsonb, 'Quả chanh có vị chua.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'tưới cây', 'bàn học', 'thơm ngát', 'ngoan ngoãn', 'tưới cây', null::jsonb, '"tưới cây" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'tưới cây', 'to lớn', 'xanh biếc', 'con mèo', 'tưới cây', null::jsonb, '"tưới cây" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Buổi sáng, ông mặt trời ___ ở đằng đông.', 'lặn', 'chạy', 'rơi', 'mọc', 'mọc', null::jsonb, 'Buổi sáng, ông mặt trời mọc ở đằng đông.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'chăm chỉ', 'bơi', 'thơm ngát', 'đỏ tươi', 'bơi', null::jsonb, '"bơi" là từ chỉ hoạt động.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp điền vào chỗ trống:  Mùa đông thời tiết rất ___.', 'nóng bức', 'lạnh', 'mặn', 'ngọt', 'lạnh', null::jsonb, 'Mùa đông thời tiết rất lạnh.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'đọc sách', 'con mèo', 'xinh đẹp', 'học sinh', 'xinh đẹp', null::jsonb, '"xinh đẹp" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'text', 'Điền từ thích hợp vào chỗ trống:  Muối có vị ___.', null, null, null, null, 'mặn', null::jsonb, 'Muối có vị mặn.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ đặc điểm?', 'dịu dàng', 'xanh biếc', 'hiền lành', 'chạy', 'chạy', null::jsonb, 'Các từ còn lại đều chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'vẽ tranh', 'ngoan ngoãn', 'tưới cây', 'bàn học', 'ngoan ngoãn', null::jsonb, '"ngoan ngoãn" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'text', 'Điền từ thích hợp vào chỗ trống:  Con cá đang ___ dưới nước.', null, null, null, null, 'bơi', null::jsonb, 'Con cá đang bơi dưới nước.', 'dien_tu_vao_cau', 'rule:dien_tu_vao_cau'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'đôi dép', 'học bài', 'học sinh', 'xinh đẹp', 'xinh đẹp', null::jsonb, '"xinh đẹp" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'cái cặp', 'đá bóng', 'con mèo', 'to lớn', 'to lớn', null::jsonb, '"to lớn" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem'),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm?', 'hát', 'thấp', 'viết bài', 'vẽ tranh', 'thấp', null::jsonb, '"thấp" là từ chỉ đặc điểm.', 'tu_su_vat_hoat_dong_dac_diem', 'rule:tu_su_vat_hoat_dong_dac_diem')
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, generator_type)
 where l.week_number = 4 and l.lesson_order = 8
   and not exists (select 1 from public.questions q where q.lesson_id = l.id);
