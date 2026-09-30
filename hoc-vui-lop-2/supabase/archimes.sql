-- =====================================================================
-- NGÂN HÀNG CÂU HỎI "Archimes" (tự sinh bởi scripts/build-archimes.ts — đừng sửa tay,
-- hãy sửa data/archimes/*.json rồi chạy: npm run archimes:build).
-- Soạn theo bộ phiếu bài tập Archimedes School: Toán 2 và Tiếng Việt 2, tuần 1–35.
-- Mỗi tuần, mỗi môn là 1 bài "Archimes: …" (lesson_order = 100), mở theo tuần hiện tại.
-- Chạy SAU 0001_init.sql (và seed.sql nếu có). Chạy lại nhiều lần không tạo trùng.
-- =====================================================================

insert into public.subjects (code, name, color, sort_order) values
  ('toan', 'Toán', 'blue', 1),
  ('tieng_viet', 'Tiếng Việt', 'green', 2)
on conflict (code) do nothing;

-- Toán • Tuần 1: Ôn tập các số đến 100. Số hạng, tổng. Đề-xi-mét (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 1, 100, 'Archimes: Ôn tập các số đến 100. Số hạng, tổng. Đề-xi-mét', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 1', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số gồm 5 chục và 8 đơn vị là ___.', null, null, null, null, '58', null::jsonb, '5 chục là 50, thêm 8 đơn vị được 58.', 'cau_tao_so', 12::int),
    (1::smallint, 'number', 'Có tất cả ___ số có một chữ số.', null, null, null, null, '10', null::jsonb, 'Các số có một chữ số là 0; 1; 2; …; 9, gồm 10 số.', 'cau_tao_so', 12::int),
    (1::smallint, 'number', 'Số liền sau của số lớn nhất có hai chữ số là ___.', null, null, null, null, '100', null::jsonb, 'Số lớn nhất có hai chữ số là 99, số liền sau của 99 là 100.', 'so_lien_truoc_sau', 12::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 26 + 13 ___ 37 + 2', '>', '<', '=', null, '=', null::jsonb, '26 + 13 = 39, 37 + 2 = 39, mà 39 = 39.', 'so_sanh', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 44 - 12 ___ 44 - 11', '>', '<', '=', null, '<', null::jsonb, '44 - 12 = 32, 44 - 11 = 33, mà 32 < 33.', 'so_sanh', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 45 - 24 ___ 17 + 10', '>', '<', '=', null, '<', null::jsonb, '45 - 24 = 21, 17 + 10 = 27, mà 21 < 27.', 'so_sanh', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 37 - 17 ___ 56 - 36', '>', '<', '=', null, '=', null::jsonb, '37 - 17 = 20, 56 - 36 = 20, mà 20 = 20.', 'so_sanh', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 31 + 4 ___ 35 + 0', '>', '<', '=', null, '=', null::jsonb, '31 + 4 = 35, 35 + 0 = 35, mà 35 = 35.', 'so_sanh', 12::int),
    (1::smallint, 'number', 'Tính: 31 + 3 + 5 = ___', null, null, null, null, '39', null::jsonb, 'Tính từ trái sang phải: 31 + 3 = 34, 34 + 5 = 39.', 'tinh_day_phep_tinh', 6::int),
    (1::smallint, 'number', 'Tính: 54 + 23 - 17 = ___', null, null, null, null, '60', null::jsonb, 'Tính từ trái sang phải: 54 + 23 = 77, 77 - 17 = 60.', 'tinh_day_phep_tinh', 6::int),
    (1::smallint, 'number', '3 dm = ___ cm', null, null, null, null, '30', null::jsonb, '1 dm = 10 cm nên 3 dm = 30 cm.', 'doi_don_vi', 10::int),
    (1::smallint, 'number', '40 cm = ___ dm', null, null, null, null, '4', null::jsonb, '10 cm = 1 dm nên 40 cm = 4 dm.', 'doi_don_vi', 10::int),
    (1::smallint, 'text', 'Trong phép cộng 45 + 13 = 58, số 58 được gọi là ___.', null, null, null, null, 'tổng', null::jsonb, 'Trong phép cộng, kết quả được gọi là tổng; 45 và 13 là các số hạng.', 'so_hang_tong', 5::int),
    (2::smallint, 'number', '3 dm 2 cm = ___ cm', null, null, null, null, '32', null::jsonb, '3 dm = 30 cm, thêm 2 cm được 32 cm.', 'doi_don_vi', 10::int),
    (2::smallint, 'number', '87 cm - 47 cm = ___ dm', null, null, null, null, '4', null::jsonb, '87 cm - 47 cm = 40 cm = 4 dm.', 'doi_don_vi', 10::int),
    (2::smallint, 'number', '4 dm + 5 dm = ___ cm', null, null, null, null, '90', null::jsonb, '4 dm + 5 dm = 9 dm = 90 cm.', 'doi_don_vi', 10::int),
    (2::smallint, 'number', 'Một cuộn dây dài 53 dm, người ta cắt đi một đoạn dài 21 dm. Cuộn dây còn lại dài ___ dm.', null, null, null, null, '32', null::jsonb, 'Còn lại: 53 - 21 = 32 (dm).', 'bai_toan_co_loi_van', 7::int),
    (2::smallint, 'number', 'Nhà An nuôi 14 con vịt và 1 chục con gà. Số con ngan bằng tổng số con gà và vịt. Nhà An nuôi ___ con ngan.', null, null, null, null, '24', null::jsonb, '1 chục = 10, số ngan là 14 + 10 = 24 (con).', 'bai_toan_co_loi_van', 7::int),
    (2::smallint, 'number', 'Trong hộp có 30 bút chì màu xanh và 25 bút chì màu đỏ. Trong hộp có tất cả ___ chiếc bút chì.', null, null, null, null, '55', null::jsonb, 'Tất cả có: 30 + 25 = 55 (chiếc).', 'bai_toan_co_loi_van', 12::int),
    (2::smallint, 'number', 'Mảnh vải xanh dài 12 dm, mảnh vải đỏ dài 70 cm. Cả hai mảnh vải dài ___ dm.', null, null, null, null, '19', null::jsonb, '70 cm = 7 dm, cả hai mảnh dài 12 + 7 = 19 (dm).', 'bai_toan_co_loi_van', 12::int),
    (2::smallint, 'multiple_choice', 'Băng giấy đỏ dài 41 cm, vàng dài 4 dm, trắng dài 3 dm 8 cm, xanh dài 44 cm, nâu dài 5 dm. Băng giấy nào dài nhất?', 'Băng giấy xanh', 'Băng giấy đỏ', 'Băng giấy vàng', 'Băng giấy nâu', 'Băng giấy nâu', null::jsonb, 'Đổi ra cm: đỏ 41, vàng 40, trắng 38, xanh 44, nâu 50. Nâu dài nhất.', 'do_dai', 6::int),
    (2::smallint, 'multiple_choice', 'Băng giấy đỏ dài 41 cm, vàng dài 4 dm, trắng dài 3 dm 8 cm, xanh dài 44 cm, nâu dài 5 dm. Băng giấy nào ngắn nhất?', 'Băng giấy vàng', 'Băng giấy đỏ', 'Băng giấy trắng', 'Băng giấy xanh', 'Băng giấy trắng', null::jsonb, 'Đổi ra cm: đỏ 41, vàng 40, trắng 38, xanh 44, nâu 50. Trắng ngắn nhất.', 'do_dai', 6::int),
    (2::smallint, 'number', 'Số thứ nhất là số liền trước của 41, số thứ hai là số liền sau của 29. Tổng của hai số đó là ___.', null, null, null, null, '70', null::jsonb, 'Số liền trước của 41 là 40, số liền sau của 29 là 30; 40 + 30 = 70.', 'so_lien_truoc_sau', 8::int),
    (2::smallint, 'multiple_choice', 'Số *7 là số có hai chữ số và *7 < 24. Chữ số * là:', '2', '1', '0', '3', '1', null::jsonb, '*7 là số có hai chữ số nên * khác 0; 17 < 24 còn 27 > 24, nên * = 1.', 'cau_tao_so', 10::int),
    (3::smallint, 'number', 'Khúc gỗ thứ nhất dài 4 dm, khúc gỗ thứ hai dài 10 dm, khúc gỗ thứ ba dài bằng tổng độ dài hai khúc gỗ kia. Cả ba khúc gỗ dài ___ dm.', null, null, null, null, '28', null::jsonb, 'Khúc thứ ba dài 4 + 10 = 14 dm; cả ba khúc dài 4 + 10 + 14 = 28 (dm).', 'bai_toan_co_loi_van', 7::int),
    (3::smallint, 'number', 'Số có hai chữ số, chữ số hàng chục là số chẵn lớn nhất có một chữ số, chữ số hàng đơn vị là số liền trước của số lớn nhất có một chữ số. Số đó là ___.', null, null, null, null, '88', null::jsonb, 'Số chẵn lớn nhất có một chữ số là 8; số liền trước của 9 là 8. Số cần tìm là 88.', 'cau_tao_so', 8::int),
    (3::smallint, 'number', 'Số có hai chữ số, chữ số hàng chục là số liền trước của số bé nhất có hai chữ số, chữ số hàng đơn vị là số liền sau của số bé nhất có một chữ số. Số đó là ___.', null, null, null, null, '91', null::jsonb, 'Liền trước của 10 là 9; liền sau của 0 là 1. Số cần tìm là 91.', 'cau_tao_so', 8::int),
    (3::smallint, 'number', 'Số có hai chữ số, chữ số hàng chục là số liền trước của số chẵn lớn nhất có một chữ số, chữ số hàng đơn vị là số liền trước của số nhỏ nhất có hai chữ số. Số đó là ___.', null, null, null, null, '79', null::jsonb, 'Liền trước của 8 là 7; liền trước của 10 là 9. Số cần tìm là 79.', 'cau_tao_so', 8::int),
    (3::smallint, 'number', 'Số thứ nhất là số lẻ liền trước của 29, số thứ hai là số tròn chục lớn nhất nhỏ hơn 54. Tổng hai số là ___.', null, null, null, null, '77', null::jsonb, 'Số lẻ liền trước 29 là 27; số tròn chục lớn nhất nhỏ hơn 54 là 50; 27 + 50 = 77.', 'cau_tao_so', 9::int),
    (3::smallint, 'number', 'Viết các số có hai chữ số khác nhau mà tổng các chữ số bằng 8. Tổng của số lớn nhất và số nhỏ nhất trong các số đó là ___.', null, null, null, null, '97', null::jsonb, 'Các số: 17, 26, 35, 53, 62, 71, 80. Lớn nhất 80, nhỏ nhất 17; 80 + 17 = 97.', 'cau_tao_so', 9::int),
    (3::smallint, 'number', 'Số bé nhất có hai chữ số mà tổng các chữ số bằng 6, cộng với số lớn nhất có hai chữ số mà tổng các chữ số bằng 6, được ___.', null, null, null, null, '75', null::jsonb, 'Số bé nhất là 15, số lớn nhất là 60; 15 + 60 = 75.', 'cau_tao_so', 11::int),
    (3::smallint, 'number', 'Một số là số bé nhất có hai chữ số có tổng các chữ số bằng 5, số kia là số lẻ lớn nhất có hai chữ số có tổng các chữ số bằng 5. Tổng hai số là ___.', null, null, null, null, '55', null::jsonb, 'Số bé nhất là 14; số lẻ lớn nhất là 41 (50 là số chẵn); 14 + 41 = 55.', 'cau_tao_so', 11::int),
    (3::smallint, 'number', 'Tìm một số, biết lấy 14 cộng với số đó thì được kết quả bằng 49 trừ đi 22. Số đó là ___.', null, null, null, null, '13', null::jsonb, '49 - 22 = 27; số cần tìm là 27 - 14 = 13.', 'tim_so', 13::int),
    (3::smallint, 'number', 'Viết các số có hai chữ số khác nhau từ hai trong ba chữ số 1; 2; 4. Tổng của số lớn nhất và số bé nhất là ___.', null, null, null, null, '54', null::jsonb, 'Các số: 12, 14, 21, 24, 41, 42. Lớn nhất 42, bé nhất 12; 42 + 12 = 54.', 'cau_tao_so', 10::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 1 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 2: Số bị trừ, số trừ, hiệu (36 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 2, 100, 'Archimes: Số bị trừ, số trừ, hiệu', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 2', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Tính: 46 - 24 = ___', null, null, null, null, '22', null::jsonb, 'Ta tính: 46 - 24 = 22.', 'tru_khong_nho', 15::int),
    (1::smallint, 'number', 'Tính: 99 - 18 = ___', null, null, null, null, '81', null::jsonb, 'Ta tính: 99 - 18 = 81.', 'tru_khong_nho', 15::int),
    (1::smallint, 'number', 'Tính: 69 - 12 = ___', null, null, null, null, '57', null::jsonb, 'Ta tính: 69 - 12 = 57.', 'tru_khong_nho', 15::int),
    (1::smallint, 'number', '12 dm - 2 dm = ___ dm', null, null, null, null, '10', null::jsonb, 'Ta tính: 12 - 2 = 10.', 'do_dai', 15::int),
    (1::smallint, 'number', '8 dm + 21 dm = ___ dm', null, null, null, null, '29', null::jsonb, 'Ta tính: 8 + 21 = 29.', 'do_dai', 15::int),
    (1::smallint, 'number', 'Số chẵn liền trước của 100 là ___.', null, null, null, null, '98', null::jsonb, 'Hai số chẵn liên tiếp hơn kém nhau 2 đơn vị: 100 - 2 = 98.', 'so_lien_truoc_sau', 15::int),
    (1::smallint, 'number', 'Số lẻ liền sau của 39 là ___.', null, null, null, null, '41', null::jsonb, 'Hai số lẻ liên tiếp hơn kém nhau 2 đơn vị: 39 + 2 = 41.', 'so_lien_truoc_sau', 15::int),
    (1::smallint, 'text', 'Trong phép trừ 49 - 15 = 34, số 49 được gọi là ___.', null, null, null, null, 'số bị trừ', null::jsonb, 'Trong phép trừ: 49 là số bị trừ, 15 là số trừ, 34 là hiệu.', 'thanh_phan_phep_tru', 14::int),
    (1::smallint, 'text', 'Trong phép trừ 49 - 15 = 34, số 34 được gọi là ___.', null, null, null, null, 'hiệu', null::jsonb, 'Kết quả của phép trừ được gọi là hiệu.', 'thanh_phan_phep_tru', 14::int),
    (1::smallint, 'multiple_choice', 'Một số bất kì trừ đi chính nó thì được kết quả là:', '0', 'Chính số đó', '1', '10', '0', null::jsonb, 'Ví dụ 32 - 32 = 0.', 'thanh_phan_phep_tru', 14::int),
    (1::smallint, 'number', 'Tính nhẩm: 80 - 60 + 10 = ___', null, null, null, null, '30', null::jsonb, 'Ta tính: 80 - 60 + 10 = 30.', 'tinh_nham', 17::int),
    (1::smallint, 'number', '19 + 7 = 19 + 1 + ___', null, null, null, null, '6', null::jsonb, 'Tách 7 = 1 + 6 để 19 + 1 được 20 tròn chục.', 'tinh_nham', 17::int),
    (1::smallint, 'number', 'Tính: 37 + 12 - 24 = ___', null, null, null, null, '25', null::jsonb, '37 + 12 = 49, 49 - 24 = 25.', 'tinh_day_phep_tinh', 21::int),
    (2::smallint, 'number', 'Nam đọc một quyển truyện dày 96 trang. Nam đã đọc được 45 trang. Nam còn ___ trang chưa đọc.', null, null, null, null, '51', null::jsonb, 'Số trang chưa đọc: 96 - 45 = 51 (trang).', 'bai_toan_co_loi_van', 15::int),
    (2::smallint, 'number', 'Lớp 2A có 35 bạn. Có 5 bạn đi tập văn nghệ, các bạn còn lại trang trí lớp. Có ___ bạn trang trí lớp.', null, null, null, null, '30', null::jsonb, 'Số bạn trang trí lớp: 35 - 5 = 30 (bạn).', 'bai_toan_co_loi_van', 16::int),
    (2::smallint, 'number', 'Hiệu của số lớn nhất có hai chữ số và 34 là ___.', null, null, null, null, '65', null::jsonb, 'Số lớn nhất có hai chữ số là 99; 99 - 34 = 65.', 'bai_toan_co_loi_van', 16::int),
    (2::smallint, 'number', 'Hai lớp 2A và 2B có 64 học sinh, trong đó có 31 học sinh nữ. Hai lớp có ___ học sinh nam.', null, null, null, null, '33', null::jsonb, 'Số học sinh nam: 64 - 31 = 33 (học sinh).', 'bai_toan_co_loi_van', 17::int),
    (2::smallint, 'number', 'Lan có 19 cái nhãn vở, Lan cho Huệ và Mai mỗi bạn 4 cái. Lan còn lại ___ cái nhãn vở.', null, null, null, null, '11', null::jsonb, 'Lan cho đi 4 + 4 = 8 cái, còn 19 - 8 = 11 (cái).', 'bai_toan_co_loi_van', 17::int),
    (2::smallint, 'number', 'Đàn gà có 75 con. Người ta bán đi 3 chục con và 5 con nữa. Đàn gà còn lại ___ con.', null, null, null, null, '40', null::jsonb, '3 chục = 30; 75 - 30 - 5 = 40 (con).', 'bai_toan_co_loi_van', 18::int),
    (2::smallint, 'number', 'Hiệu của 45 cm và 2 dm là ___ cm.', null, null, null, null, '25', null::jsonb, '2 dm = 20 cm; 45 - 20 = 25 (cm).', 'do_dai', 21::int),
    (2::smallint, 'number', 'Mẹ biếu bà 2 chục quả cam thì mẹ còn lại 12 quả. Lúc đầu mẹ có ___ quả cam.', null, null, null, null, '32', null::jsonb, '2 chục = 20; lúc đầu mẹ có 20 + 12 = 32 (quả).', 'bai_toan_co_loi_van', 21::int),
    (2::smallint, 'number', 'Bố có cuộn dây điện dài 88 dm. Sau khi dùng một đoạn thì còn lại 34 dm. Bố đã dùng ___ dm dây.', null, null, null, null, '54', null::jsonb, 'Đoạn đã dùng: 88 - 34 = 54 (dm).', 'bai_toan_co_loi_van', 21::int),
    (2::smallint, 'number', 'Mai gấp được 25 ngôi sao. Mai tặng bạn một số ngôi sao thì còn lại 1 chục ngôi sao. Mai đã tặng bạn ___ ngôi sao.', null, null, null, null, '15', null::jsonb, '1 chục = 10; số sao đã tặng: 25 - 10 = 15.', 'bai_toan_co_loi_van', 20::int),
    (2::smallint, 'multiple_choice', 'Điền dấu + hoặc - vào hai ô trống: 40 ☐ 30 ☐ 20 = 30. Hai dấu lần lượt là:', '+, -', '+, +', '-, -', '-, +', '-, +', null::jsonb, '40 - 30 + 20 = 10 + 20 = 30.', 'dien_dau', 19::int),
    (2::smallint, 'number', 'Tính bằng cách thuận tiện: 19 + 17 - 9 - 7 = ___', null, null, null, null, '20', null::jsonb, '(19 - 9) + (17 - 7) = 10 + 10 = 20.', 'tinh_thuan_tien', 19::int),
    (3::smallint, 'number', 'Hiện nay, tổng số tuổi của hai anh em là 21 tuổi. Ba năm nữa, tổng số tuổi của hai anh em là ___ tuổi.', null, null, null, null, '27', null::jsonb, 'Mỗi người thêm 3 tuổi nên tổng tăng 6: 21 + 6 = 27.', 'tuoi', 16::int),
    (3::smallint, 'number', 'Hiện nay, tổng số tuổi của hai bà cháu là 69 tuổi. Ba năm trước, tổng số tuổi của hai bà cháu là ___ tuổi.', null, null, null, null, '63', null::jsonb, 'Mỗi người bớt 3 tuổi nên tổng giảm 6: 69 - 6 = 63.', 'tuoi', 16::int),
    (3::smallint, 'number', 'Hai năm nữa, tổng số tuổi của bố, mẹ và con gái là 69 tuổi. Hiện nay, tổng số tuổi của ba người là ___ tuổi.', null, null, null, null, '63', null::jsonb, 'Ba người, mỗi người bớt 2 tuổi nên tổng giảm 6: 69 - 6 = 63.', 'tuoi', 20::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó cộng với 36 rồi trừ đi 2 thì được 67. Số đó là ___.', null, null, null, null, '33', null::jsonb, 'Trước khi trừ 2 là 67 + 2 = 69; số cần tìm là 69 - 36 = 33.', 'tim_so', 18::int),
    (3::smallint, 'number', 'Tìm một số, biết lấy 87 trừ đi số đó rồi trừ tiếp đi 32 thì được 50. Số đó là ___.', null, null, null, null, '5', null::jsonb, '87 trừ số đó được 50 + 32 = 82; số cần tìm là 87 - 82 = 5.', 'tim_so', 18::int),
    (3::smallint, 'number', 'Trên xe buýt có 28 hành khách. Tới trạm thứ nhất có 6 người xuống và 7 người lên. Tới trạm thứ hai có 8 người xuống và 9 người lên. Lúc này trên xe có ___ hành khách.', null, null, null, null, '30', null::jsonb, '28 - 6 + 7 = 29; 29 - 8 + 9 = 30 (hành khách).', 'bai_toan_co_loi_van', 20::int),
    (3::smallint, 'number', 'Trong rổ có 56 quả cam và quýt. Bác Hà lấy ra 12 quả cam và bỏ vào rổ 24 quả quýt. Lúc này trong rổ có ___ quả cam và quýt.', null, null, null, null, '68', null::jsonb, '56 - 12 = 44; 44 + 24 = 68 (quả).', 'bai_toan_co_loi_van', 19::int),
    (3::smallint, 'number', 'Trong một phép trừ, số bị trừ và hiệu đều bằng 65. Số trừ là ___.', null, null, null, null, '0', null::jsonb, 'Số trừ = số bị trừ - hiệu = 65 - 65 = 0.', 'thanh_phan_phep_tru', 21::int),
    (3::smallint, 'number', 'Hiệu lớn nhất của hai số có một chữ số là ___.', null, null, null, null, '9', null::jsonb, 'Lấy số lớn nhất có một chữ số (9) trừ số bé nhất (0): 9 - 0 = 9.', 'thanh_phan_phep_tru', 21::int),
    (3::smallint, 'number', 'Hiệu của số chẵn lớn nhất có hai chữ số giống nhau với số lẻ nhỏ nhất có hai chữ số khác nhau là ___.', null, null, null, null, '75', null::jsonb, 'Số chẵn lớn nhất có hai chữ số giống nhau là 88; số lẻ nhỏ nhất có hai chữ số khác nhau là 13; 88 - 13 = 75.', 'cau_tao_so', 22::int),
    (3::smallint, 'number', 'Tính bằng cách thuận tiện: 23 + 24 + 25 - 13 - 14 - 15 = ___', null, null, null, null, '30', null::jsonb, '(23 - 13) + (24 - 14) + (25 - 15) = 10 + 10 + 10 = 30.', 'tinh_thuan_tien', 22::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 2 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 3: Phép cộng có tổng bằng 10. Phép cộng dạng 26 + 4; 36 + 24. 9 cộng với một số (36 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 3, 100, 'Archimes: Phép cộng có tổng bằng 10. Phép cộng dạng 26 + 4; 36 + 24. 9 cộng với một số', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 3', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '6 + ___ = 10', null, null, null, null, '4', null::jsonb, 'Vì 6 + 4 = 10.', 'tong_bang_10', 23::int),
    (1::smallint, 'number', '3 + ___ = 10', null, null, null, null, '7', null::jsonb, 'Vì 3 + 7 = 10.', 'tong_bang_10', 23::int),
    (1::smallint, 'number', '9 + 7 = ___', null, null, null, null, '16', null::jsonb, '9 + 1 = 10, thêm 6 nữa được 16.', 'bang_cong_9', 23::int),
    (1::smallint, 'number', '9 + 5 = ___', null, null, null, null, '14', null::jsonb, '9 + 1 = 10, thêm 4 nữa được 14.', 'bang_cong_9', 23::int),
    (1::smallint, 'number', 'Tính: 52 + 8 = ___', null, null, null, null, '60', null::jsonb, 'Ta tính: 52 + 8 = 60.', 'cong_tron_chuc', 24::int),
    (1::smallint, 'number', 'Tính: 59 + 21 = ___', null, null, null, null, '80', null::jsonb, 'Ta tính: 59 + 21 = 80.', 'cong_tron_chuc', 24::int),
    (1::smallint, 'number', 'Tính: 28 + 42 = ___', null, null, null, null, '70', null::jsonb, 'Ta tính: 28 + 42 = 70.', 'cong_tron_chuc', 24::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 26 + 4 ___ 13 + 17', '>', '<', '=', null, '=', null::jsonb, '26 + 4 = 30, 13 + 17 = 30, mà 30 = 30.', 'so_sanh', 26::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 66 + 24 ___ 40 + 52', '>', '<', '=', null, '<', null::jsonb, '66 + 24 = 90, 40 + 52 = 92, mà 90 < 92.', 'so_sanh', 26::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 43 + 17 ___ 89 - 29', '>', '<', '=', null, '=', null::jsonb, '43 + 17 = 60, 89 - 29 = 60, mà 60 = 60.', 'so_sanh', 26::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 59 + 41 ___ 48 + 50', '>', '<', '=', null, '>', null::jsonb, '59 + 41 = 100, 48 + 50 = 98, mà 100 > 98.', 'so_sanh', 26::int),
    (1::smallint, 'text', 'Khi đổi chỗ các số hạng trong một tổng thì tổng ___.', null, null, null, null, 'không thay đổi', '["không đổi"]'::jsonb, 'Ví dụ 26 + 4 = 4 + 26 = 30.', 'tinh_chat_giao_hoan', 23::int),
    (2::smallint, 'number', '18 cm + 32 cm = ___ dm', null, null, null, null, '5', null::jsonb, '18 cm + 32 cm = 50 cm = 5 dm.', 'doi_don_vi', 24::int),
    (2::smallint, 'number', 'Rổ thứ nhất có 21 quả cam, rổ thứ hai có 29 quả, rổ thứ ba có 31 quả. Cả ba rổ có ___ quả cam.', null, null, null, null, '81', null::jsonb, '21 + 29 = 50; 50 + 31 = 81 (quả).', 'bai_toan_co_loi_van', 24::int),
    (2::smallint, 'number', 'Bố cưa một khúc gỗ, lần đầu cưa đi 36 cm, lần thứ hai cưa đi 14 cm. Sau hai lần cưa, khúc gỗ ngắn đi ___ dm.', null, null, null, null, '5', null::jsonb, '36 + 14 = 50 cm = 5 dm.', 'bai_toan_co_loi_van', 25::int),
    (2::smallint, 'number', 'Trong hộp có 6 viên bi. Nam bỏ vào thêm 4 viên, rồi bỏ tiếp 10 viên. Lúc sau trong hộp có ___ viên bi.', null, null, null, null, '20', null::jsonb, '6 + 4 = 10; 10 + 10 = 20 (viên).', 'bai_toan_co_loi_van', 25::int),
    (2::smallint, 'number', 'Tính bằng cách thuận tiện: 17 + 35 + 25 + 13 = ___', null, null, null, null, '90', null::jsonb, '(17 + 13) + (35 + 25) = 30 + 60 = 90.', 'tinh_thuan_tien', 26::int),
    (2::smallint, 'number', 'Tính bằng cách thuận tiện: 15 + 32 + 48 + 5 = ___', null, null, null, null, '100', null::jsonb, '(15 + 5) + (32 + 48) = 20 + 80 = 100.', 'tinh_thuan_tien', 26::int),
    (2::smallint, 'number', 'Đoạn thẳng AB dài 1 dm, BC dài 6 cm, CD dài 3 dm. Cả ba đoạn thẳng dài ___ cm.', null, null, null, null, '46', null::jsonb, '1 dm = 10 cm, 3 dm = 30 cm; 10 + 6 + 30 = 46 (cm).', 'do_dai', 27::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 9 + 2 + 39 ___ 39 - 18 + 26', '>', '<', '=', null, '>', null::jsonb, '9 + 2 + 39 = 50, 39 - 18 + 26 = 47, mà 50 > 47.', 'so_sanh', 30::int),
    (2::smallint, 'number', 'Hà có 25 cái kẹo. Mẹ cho thêm Hà 5 cái, Hà lại cho bạn 10 cái. Hà còn lại ___ cái kẹo.', null, null, null, null, '20', null::jsonb, '25 + 5 = 30; 30 - 10 = 20 (cái).', 'bai_toan_co_loi_van', 30::int),
    (2::smallint, 'number', 'Hồng tặng Mai 1 chục con tem thì Hồng còn lại 16 con tem. Lúc đầu Hồng có ___ con tem.', null, null, null, null, '26', null::jsonb, '1 chục = 10; lúc đầu Hồng có 10 + 16 = 26 (con tem).', 'bai_toan_co_loi_van', 30::int),
    (2::smallint, 'number', 'Tổng của 5 và số liền trước của số nhỏ nhất có hai chữ số là ___.', null, null, null, null, '14', null::jsonb, 'Số nhỏ nhất có hai chữ số là 10, số liền trước là 9; 5 + 9 = 14.', 'bai_toan_co_loi_van', 30::int),
    (2::smallint, 'number', 'Đoạn thẳng AB dài 2 dm, đoạn thẳng CD dài 12 cm. Tổng độ dài hai đoạn thẳng là ___ cm.', null, null, null, null, '32', null::jsonb, '2 dm = 20 cm; 20 + 12 = 32 (cm).', 'do_dai', 30::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: a7 + 12 ___ a8 + 12 (a khác 0)', '>', '<', '=', null, '<', null::jsonb, 'Hai số a7 và a8 cùng chữ số hàng chục, mà 7 < 8 nên a7 < a8, cộng cùng 12 thì vẫn bé hơn.', 'so_sanh_chu_so', 28::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: a9 + 15 ___ a9 - 15 (a khác 0)', '>', '<', '=', null, '>', null::jsonb, 'Cùng số a9: cộng thêm 15 thì lớn hơn trừ đi 15.', 'so_sanh_chu_so', 28::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 6a - 32 ___ 32 + 6a', '>', '<', '=', null, '<', null::jsonb, 'Cùng số 6a: trừ đi 32 thì nhỏ hơn cộng thêm 32.', 'so_sanh_chu_so', 28::int),
    (3::smallint, 'number', 'Tính bằng cách thuận tiện: 3 + 5 + 7 + 13 + 15 + 17 = ___', null, null, null, null, '60', null::jsonb, '(3 + 17) + (5 + 15) + (7 + 13) = 20 + 20 + 20 = 60.', 'tinh_thuan_tien', 28::int),
    (3::smallint, 'number', 'Tính: 1 + 2 - 3 + 4 - 5 + 6 - 7 + 8 - 9 + 10 = ___', null, null, null, null, '7', null::jsonb, 'Tổng các số được cộng: 1 + 2 + 4 + 6 + 8 + 10 = 31; các số bị trừ: 3 + 5 + 7 + 9 = 24; 31 - 24 = 7.', 'tinh_thuan_tien', 28::int),
    (3::smallint, 'number', 'Số thứ nhất là tổng của 9 và 7, số thứ hai là hiệu của số thứ nhất và 12. Tổng của hai số là ___.', null, null, null, null, '20', null::jsonb, 'Số thứ nhất 9 + 7 = 16; số thứ hai 16 - 12 = 4; tổng 16 + 4 = 20.', 'tim_so', 28::int),
    (3::smallint, 'number', 'Hai số có hai chữ số có tổng là 74. Số thứ nhất có chữ số hàng đơn vị là 9, số thứ hai có chữ số hàng chục là 5. Số thứ nhất là ___.', null, null, null, null, '19', null::jsonb, 'Hàng đơn vị: 9 + 5 = 14 (viết 4 nhớ 1) nên số thứ hai là 55; số thứ nhất là 74 - 55 = 19.', 'tim_so', 28::int),
    (3::smallint, 'number', 'Hai số có hai chữ số có tổng là 80. Số thứ nhất có chữ số hàng đơn vị là 0, số thứ hai có chữ số hàng chục là 3. Số thứ hai là ___.', null, null, null, null, '30', null::jsonb, 'Hàng đơn vị: 0 + ? có tận cùng là 0 nên ? = 0, số thứ hai là 30 (số thứ nhất là 50).', 'tim_so', 29::int),
    (3::smallint, 'number', 'Tuấn tặng Bình 15 cái nhãn vở, sau đó Bình tặng lại Tuấn 3 cái thì mỗi bạn đều có 28 cái. Lúc đầu Tuấn có ___ cái nhãn vở.', null, null, null, null, '40', null::jsonb, 'Ngược lại: Tuấn trả 3 cái còn 25, nhận lại 15 cái được 40.', 'tim_so', 29::int),
    (3::smallint, 'number', 'Chuyển 14 viên bi từ túi A sang túi B, rồi chuyển 10 viên từ túi B sang túi A thì mỗi túi có 26 viên. Ban đầu túi A có ___ viên bi.', null, null, null, null, '30', null::jsonb, 'Ngược lại: túi A bớt 10 viên còn 16, thêm lại 14 viên được 30.', 'tim_so', 29::int),
    (3::smallint, 'multiple_choice', 'Ba bạn Hải, Minh, Long ngồi thành một hàng để chụp ảnh. Có tất cả bao nhiêu cách sắp xếp chỗ ngồi?', '3', '4', '6', '9', '6', null::jsonb, 'Mỗi bạn ngồi đầu hàng thì có 2 cách xếp hai bạn còn lại: 2 + 2 + 2 = 6 cách.', 'suy_luan', 27::int),
    (3::smallint, 'number', 'Cuộn dây được cắt thành ba đoạn: đoạn thứ nhất dài 13 dm, đoạn thứ hai dài 17 dm, đoạn thứ ba bằng tổng độ dài hai đoạn kia. Cả cuộn dây dài ___ dm.', null, null, null, null, '60', null::jsonb, 'Đoạn thứ ba: 13 + 17 = 30 dm; cả cuộn: 13 + 17 + 30 = 60 (dm).', 'bai_toan_co_loi_van', 31::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 3 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 4: Phép cộng dạng 29 + 5; 49 + 25. 8 cộng với một số. Phép cộng dạng 28 + 5; 38 + 25 (37 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 4, 100, 'Archimes: Phép cộng dạng 29 + 5; 49 + 25. 8 cộng với một số. Phép cộng dạng 28 + 5; 38 + 25', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 4', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Tính: 29 + 5 = ___', null, null, null, null, '34', null::jsonb, 'Ta tính: 29 + 5 = 34.', 'cong_co_nho', 33::int),
    (1::smallint, 'number', 'Tính: 39 + 24 = ___', null, null, null, null, '63', null::jsonb, 'Ta tính: 39 + 24 = 63.', 'cong_co_nho', 33::int),
    (1::smallint, 'number', 'Tính: 49 + 26 = ___', null, null, null, null, '75', null::jsonb, 'Ta tính: 49 + 26 = 75.', 'cong_co_nho', 33::int),
    (1::smallint, 'number', '8 + 5 = ___', null, null, null, null, '13', null::jsonb, '8 + 2 = 10, thêm 3 nữa được 13.', 'bang_cong_8', 32::int),
    (1::smallint, 'number', '8 + 7 = ___', null, null, null, null, '15', null::jsonb, '8 + 2 = 10, thêm 5 nữa được 15.', 'bang_cong_8', 32::int),
    (1::smallint, 'number', 'Tính: 28 + 49 = ___', null, null, null, null, '77', null::jsonb, 'Ta tính: 28 + 49 = 77.', 'cong_co_nho', 35::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bằng 74?', '19 + 33', '49 + 25', '29 + 17', '69 + 16', '49 + 25', null::jsonb, '49 + 25 = 74; còn 19 + 33 = 52, 29 + 17 = 46, 69 + 16 = 85.', 'cong_co_nho', 33::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bằng 52?', '9 + 43', '79 + 6', '19 + 27', '39 + 35', '9 + 43', null::jsonb, '9 + 43 = 52; còn 79 + 6 = 85, 19 + 27 = 46, 39 + 35 = 74.', 'cong_co_nho', 33::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 18 + 17 ___ 19 + 16', '>', '<', '=', null, '=', null::jsonb, '18 + 17 = 35, 19 + 16 = 35, mà 35 = 35.', 'so_sanh', 35::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 29 - 11 ___ 9 + 8', '>', '<', '=', null, '>', null::jsonb, '29 - 11 = 18, 9 + 8 = 17, mà 18 > 17.', 'so_sanh', 35::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 91 - 50 ___ 38 + 3', '>', '<', '=', null, '=', null::jsonb, '91 - 50 = 41, 38 + 3 = 41, mà 41 = 41.', 'so_sanh', 35::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 58 + 26 ___ 48 + 27', '>', '<', '=', null, '>', null::jsonb, '58 + 26 = 84, 48 + 27 = 75, mà 84 > 75.', 'so_sanh', 35::int),
    (1::smallint, 'number', 'Tính: 29 + 51 - 20 = ___', null, null, null, null, '60', null::jsonb, '29 + 51 = 80; 80 - 20 = 60.', 'tinh_day_phep_tinh', 39::int),
    (2::smallint, 'number', 'Một cửa hàng có 34 hộp bút màu xanh và 29 hộp bút màu đỏ. Cửa hàng có tất cả ___ hộp bút.', null, null, null, null, '63', null::jsonb, '34 + 29 = 63 (hộp).', 'bai_toan_co_loi_van', 33::int),
    (2::smallint, 'number', 'Sợi dây thứ nhất dài 90 cm, sợi thứ hai dài 7 dm. Sợi thứ ba dài bằng tổng độ dài hai sợi đầu. Sợi thứ ba dài ___ dm.', null, null, null, null, '16', null::jsonb, '90 cm = 9 dm; 9 + 7 = 16 (dm).', 'bai_toan_co_loi_van', 34::int),
    (2::smallint, 'number', 'Ngăn thứ nhất có 19 quyển sách, ngăn thứ hai có 25 quyển, ngăn thứ ba có 9 quyển. Cả ba ngăn có ___ quyển sách.', null, null, null, null, '53', null::jsonb, '19 + 25 = 44; 44 + 9 = 53 (quyển).', 'bai_toan_co_loi_van', 34::int),
    (2::smallint, 'number', 'Đoạn thẳng AB gồm đoạn AC dài 3 dm và đoạn CB dài 24 cm. Đoạn thẳng AB dài ___ cm.', null, null, null, null, '54', null::jsonb, '3 dm = 30 cm; 30 + 24 = 54 (cm).', 'bai_toan_co_loi_van', 36::int),
    (2::smallint, 'number', 'Có 68 con gà và vịt, trong đó có 36 con gà. Có ___ con vịt.', null, null, null, null, '32', null::jsonb, 'Số vịt: 68 - 36 = 32 (con).', 'bai_toan_co_loi_van', 36::int),
    (2::smallint, 'number', 'Mùa hè mẹ đi công tác ba đợt: đợt một 1 chục ngày, đợt hai 9 ngày, đợt ba 1 tuần lễ. Mẹ đi công tác tất cả ___ ngày.', null, null, null, null, '26', null::jsonb, '1 chục = 10 ngày, 1 tuần lễ = 7 ngày; 10 + 9 + 7 = 26 (ngày).', 'bai_toan_co_loi_van', 36::int),
    (2::smallint, 'number', 'Một phép cộng có tổng bằng 29, một số hạng là số lớn nhất có một chữ số. Số hạng còn lại là ___.', null, null, null, null, '20', null::jsonb, 'Số lớn nhất có một chữ số là 9; số hạng còn lại là 29 - 9 = 20.', 'tim_so_hang', 35::int),
    (2::smallint, 'number', 'Sáng nay dì Út mang trứng ra chợ bán. Dì bán đi 48 quả thì còn lại 35 quả. Dì Út đã mang ___ quả trứng ra chợ.', null, null, null, null, '83', null::jsonb, 'Số trứng mang ra chợ: 48 + 35 = 83 (quả).', 'bai_toan_co_loi_van', 39::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 35 + 49 ___ 77 - 43 + 19', '>', '<', '=', null, '>', null::jsonb, '35 + 49 = 84, 77 - 43 + 19 = 53, mà 84 > 53.', 'so_sanh', 39::int),
    (2::smallint, 'number', 'Tổng của hai số là 50. Nếu số hạng thứ nhất tăng thêm 4, số hạng thứ hai giữ nguyên thì tổng mới là ___.', null, null, null, null, '54', null::jsonb, 'Một số hạng tăng 4 thì tổng tăng 4: 50 + 4 = 54.', 'thay_doi_tong', 37::int),
    (2::smallint, 'number', 'Tổng của hai số là 43. Nếu số hạng thứ nhất bớt đi 3, số hạng thứ hai giữ nguyên thì tổng mới là ___.', null, null, null, null, '40', null::jsonb, 'Một số hạng bớt 3 thì tổng bớt 3: 43 - 3 = 40.', 'thay_doi_tong', 38::int),
    (3::smallint, 'number', 'Tổng của hai số là 68. Nếu số hạng thứ nhất tăng thêm 4, số hạng thứ hai tăng thêm 8 thì tổng mới là ___.', null, null, null, null, '80', null::jsonb, 'Tổng tăng 4 + 8 = 12: 68 + 12 = 80.', 'thay_doi_tong', 38::int),
    (3::smallint, 'number', 'Tổng của hai số là 98. Nếu số hạng thứ nhất bớt đi 7, số hạng thứ hai bớt đi 10 thì tổng mới là ___.', null, null, null, null, '81', null::jsonb, 'Tổng bớt 7 + 10 = 17: 98 - 17 = 81.', 'thay_doi_tong', 38::int),
    (3::smallint, 'number', 'Tổng của hai số là 74. Nếu số hạng thứ nhất tăng thêm 9, số hạng thứ hai bớt đi 3 thì tổng mới là ___.', null, null, null, null, '80', null::jsonb, '74 + 9 = 83; 83 - 3 = 80.', 'thay_doi_tong', 38::int),
    (3::smallint, 'number', 'Nếu tăng số hạng thứ nhất thêm 18 và tăng số hạng thứ hai thêm 15 thì tổng tăng thêm ___ đơn vị.', null, null, null, null, '33', null::jsonb, 'Tổng tăng thêm 18 + 15 = 33 đơn vị.', 'thay_doi_tong', 38::int),
    (3::smallint, 'number', 'Tính bằng cách thuận tiện: 9 + 13 + 15 + 27 + 11 + 5 = ___', null, null, null, null, '80', null::jsonb, '(9 + 11) + (13 + 27) + (15 + 5) = 20 + 40 + 20 = 80.', 'tinh_thuan_tien', 37::int),
    (3::smallint, 'number', 'Tính bằng cách thuận tiện: 45 + 17 + 29 - 7 - 15 - 9 = ___', null, null, null, null, '60', null::jsonb, '(45 - 15) + (17 - 7) + (29 - 9) = 30 + 10 + 20 = 60.', 'tinh_thuan_tien', 37::int),
    (3::smallint, 'multiple_choice', 'Có bao nhiêu số có hai chữ số mà tổng hai chữ số bằng 15?', '3', '5', '6', '4', '4', null::jsonb, 'Đó là các số 69, 78, 87, 96.', 'cau_tao_so', 37::int),
    (3::smallint, 'number', 'Viết các số có hai chữ số khác nhau mà hiệu hai chữ số bằng 7. Tổng của số tròn chục và số nhỏ nhất trong các số đó là ___.', null, null, null, null, '88', null::jsonb, 'Các số: 18, 29, 70, 81, 92. Số tròn chục là 70, số nhỏ nhất là 18; 70 + 18 = 88.', 'cau_tao_so', 37::int),
    (3::smallint, 'number', 'Số thứ nhất là tổng của 19 và số nhỏ nhất có hai chữ số mà tổng các chữ số là 7. Số thứ hai là tổng của số thứ nhất và số nhỏ nhất có hai chữ số. Số thứ hai là ___.', null, null, null, null, '45', null::jsonb, 'Số nhỏ nhất có tổng chữ số là 7 là 16; số thứ nhất 19 + 16 = 35; số thứ hai 35 + 10 = 45.', 'tim_so', 34::int),
    (3::smallint, 'number', '89 - ___ = 37 + 19', null, null, null, null, '33', null::jsonb, '37 + 19 = 56; số cần điền là 89 - 56 = 33.', 'tim_so', 39::int),
    (3::smallint, 'number', 'Hai số có tổng bằng 85. Số hạng thứ nhất có chữ số hàng chục là 4, số hạng thứ hai có chữ số hàng đơn vị là 9. Số hạng thứ nhất là ___.', null, null, null, null, '46', null::jsonb, 'Hàng đơn vị: ? + 9 có tận cùng 5 nên ? = 6 (nhớ 1); hàng chục: 4 + ? + 1 = 8 nên ? = 3. Hai số là 46 và 39.', 'tim_so', 39::int),
    (3::smallint, 'number', 'Cho 4 điểm A, B, C, D cùng nằm trên một đường thẳng. Nối các điểm đó với nhau ta được tất cả ___ đoạn thẳng.', null, null, null, null, '6', null::jsonb, 'Các đoạn: AB, AC, AD, BC, BD, CD, tất cả 6 đoạn.', 'hinh_hoc', 39::int),
    (3::smallint, 'number', 'Tổng của hai số là số lớn nhất có hai chữ số khác nhau, biết một số là 25. Số còn lại là ___.', null, null, null, null, '73', null::jsonb, 'Số lớn nhất có hai chữ số khác nhau là 98; số còn lại là 98 - 25 = 73.', 'tim_so_hang', 40::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 4 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 5: Hình chữ nhật, hình tứ giác. Bài toán về nhiều hơn (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 5, 100, 'Archimes: Hình chữ nhật, hình tứ giác. Bài toán về nhiều hơn', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 5', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Tính: 18 + 26 = ___', null, null, null, null, '44', null::jsonb, 'Ta tính: 18 + 26 = 44.', 'cong_co_nho', 42::int),
    (1::smallint, 'number', 'Tính: 78 + 9 = ___', null, null, null, null, '87', null::jsonb, 'Ta tính: 78 + 9 = 87.', 'cong_co_nho', 42::int),
    (1::smallint, 'number', 'Tính: 35 + 38 = ___', null, null, null, null, '73', null::jsonb, 'Ta tính: 35 + 38 = 73.', 'cong_co_nho', 42::int),
    (1::smallint, 'number', 'Tính: 38 + 17 = ___', null, null, null, null, '55', null::jsonb, 'Ta tính: 38 + 17 = 55.', 'cong_co_nho', 42::int),
    (1::smallint, 'number', 'Tính: 48 + 7 = ___', null, null, null, null, '55', null::jsonb, 'Ta tính: 48 + 7 = 55.', 'cong_co_nho', 49::int),
    (1::smallint, 'number', 'Tính: 9 + 53 = ___', null, null, null, null, '62', null::jsonb, 'Ta tính: 9 + 53 = 62.', 'cong_co_nho', 49::int),
    (1::smallint, 'number', 'Tính: 44 + 38 - 22 = ___', null, null, null, null, '60', null::jsonb, '44 + 38 = 82; 82 - 22 = 60.', 'tinh_day_phep_tinh', 48::int),
    (1::smallint, 'number', 'Số hạng thứ nhất là 78, số hạng thứ hai là số lớn nhất có một chữ số. Tổng của hai số là ___.', null, null, null, null, '87', null::jsonb, 'Số lớn nhất có một chữ số là 9; 78 + 9 = 87.', 'tinh_day_phep_tinh', 48::int),
    (1::smallint, 'multiple_choice', 'Hình tứ giác có mấy cạnh?', '3 cạnh', '5 cạnh', '4 cạnh', '6 cạnh', '4 cạnh', null::jsonb, 'Hình tứ giác có 4 cạnh và 4 đỉnh.', 'hinh_hoc', 41::int),
    (1::smallint, 'multiple_choice', 'Hình nào dưới đây cũng là một hình tứ giác?', 'Hình chữ nhật', 'Hình tam giác', 'Hình tròn', null, 'Hình chữ nhật', null::jsonb, 'Hình chữ nhật có 4 cạnh, 4 đỉnh nên cũng là hình tứ giác.', 'hinh_hoc', 41::int),
    (1::smallint, 'text', 'Hình chữ nhật ABCD có ___ đỉnh là A, B, C, D.', null, null, null, null, 'bốn', '["4"]'::jsonb, 'Hình chữ nhật ABCD có 4 đỉnh: A, B, C, D.', 'hinh_hoc', 41::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 14 + 25 + 37 ___ 65 - 32 + 24', '>', '<', '=', null, '>', null::jsonb, '14 + 25 + 37 = 76, 65 - 32 + 24 = 57, mà 76 > 57.', 'so_sanh', 48::int),
    (2::smallint, 'number', 'Đoạn thẳng thứ nhất dài 18 cm, đoạn thứ hai dài 17 cm, đoạn thứ ba dài 9 cm. Cả ba đoạn thẳng dài ___ cm.', null, null, null, null, '44', null::jsonb, '18 + 17 = 35; 35 + 9 = 44 (cm).', 'do_dai', 42::int),
    (2::smallint, 'number', 'Hùng có 15 viên bi, Hải có nhiều hơn Hùng 9 viên bi. Hải có ___ viên bi.', null, null, null, null, '24', null::jsonb, 'Nhiều hơn thì làm phép cộng: 15 + 9 = 24 (viên).', 'bai_toan_nhieu_hon', 44::int),
    (2::smallint, 'number', 'Hiện nay mẹ 38 tuổi, bố nhiều hơn mẹ 9 tuổi. Hiện nay bố ___ tuổi.', null, null, null, null, '47', null::jsonb, 'Tuổi bố: 38 + 9 = 47 (tuổi).', 'bai_toan_nhieu_hon', 44::int),
    (2::smallint, 'number', 'Bình 7 tuổi, Linh 18 tuổi. Linh nhiều hơn Bình ___ tuổi.', null, null, null, null, '11', null::jsonb, 'Tìm phần hơn thì làm phép trừ: 18 - 7 = 11 (tuổi).', 'bai_toan_nhieu_hon', 45::int),
    (2::smallint, 'number', 'Đoạn thẳng AB dài 8 cm. Đoạn thẳng BC dài hơn đoạn AB là 3 cm. Đoạn BC dài ___ cm.', null, null, null, null, '11', null::jsonb, 'BC dài: 8 + 3 = 11 (cm).', 'bai_toan_nhieu_hon', 45::int),
    (2::smallint, 'number', 'Lớp 2A có 28 học sinh. Lớp 2B có nhiều hơn lớp 2A là 7 học sinh. Lớp 2B có ___ học sinh.', null, null, null, null, '35', null::jsonb, 'Lớp 2B có: 28 + 7 = 35 (học sinh).', 'bai_toan_nhieu_hon', 48::int),
    (2::smallint, 'number', 'Cô giáo thưởng cho học sinh 48 quyển vở thì cô còn lại 23 quyển. Lúc đầu cô có ___ quyển vở.', null, null, null, null, '71', null::jsonb, 'Lúc đầu cô có: 48 + 23 = 71 (quyển).', 'bai_toan_co_loi_van', 48::int),
    (2::smallint, 'number', 'Mảnh vải hoa dài 68 cm, mảnh vải xanh dài 32 cm. Cả hai mảnh vải dài ___ dm.', null, null, null, null, '10', null::jsonb, '68 + 32 = 100 cm = 10 dm.', 'bai_toan_co_loi_van', 48::int),
    (2::smallint, 'number', 'Tổng của hai số là 18. Giữ nguyên một số hạng và tăng số hạng kia thêm 4 thì tổng mới là ___.', null, null, null, null, '22', null::jsonb, 'Một số hạng tăng 4 thì tổng tăng 4: 18 + 4 = 22.', 'thay_doi_tong', 48::int),
    (2::smallint, 'number', 'Ngăn sách thứ hai có 35 quyển và nhiều hơn ngăn thứ ba 5 quyển. Ngăn thứ ba có ___ quyển sách.', null, null, null, null, '30', null::jsonb, 'Ngăn thứ hai nhiều hơn nên ngăn thứ ba ít hơn 5 quyển: 35 - 5 = 30.', 'bai_toan_nhieu_hon', 46::int),
    (2::smallint, 'number', 'Một hình chữ nhật được kẻ thêm một đoạn thẳng chia thành 2 hình chữ nhật nhỏ. Có tất cả ___ hình chữ nhật.', null, null, null, null, '3', null::jsonb, '2 hình chữ nhật nhỏ và 1 hình chữ nhật lớn: 3 hình.', 'hinh_hoc', 43::int),
    (3::smallint, 'number', 'Một hình chữ nhật được kẻ thêm 2 đoạn thẳng dọc chia thành 3 hình chữ nhật nhỏ xếp thành một hàng. Có tất cả ___ hình chữ nhật.', null, null, null, null, '6', null::jsonb, '3 hình đơn, 2 hình ghép đôi, 1 hình ghép ba: 3 + 2 + 1 = 6.', 'hinh_hoc', 43::int),
    (3::smallint, 'number', 'Đoạn thẳng MN dài 18 cm và dài hơn đoạn thẳng PQ 1 dm. Đoạn thẳng PQ dài ___ cm.', null, null, null, null, '8', null::jsonb, '1 dm = 10 cm; PQ dài 18 - 10 = 8 (cm).', 'bai_toan_nhieu_hon', 46::int),
    (3::smallint, 'number', 'Đoạn thẳng MN dài 18 cm và dài hơn đoạn thẳng PQ 1 dm. Cả hai đoạn thẳng dài ___ cm.', null, null, null, null, '26', null::jsonb, 'PQ dài 18 - 10 = 8 cm; cả hai đoạn: 18 + 8 = 26 (cm).', 'bai_toan_nhieu_hon', 46::int),
    (3::smallint, 'number', 'Kệ sách có ba ngăn. Ngăn thứ nhất có 28 quyển, ngăn thứ hai có 35 quyển và nhiều hơn ngăn thứ ba 5 quyển. Cả ba ngăn có ___ quyển.', null, null, null, null, '93', null::jsonb, 'Ngăn thứ ba: 35 - 5 = 30; cả ba ngăn: 28 + 35 + 30 = 93 (quyển).', 'bai_toan_nhieu_hon', 46::int),
    (3::smallint, 'number', 'Bình gấp được 48 con hạc. Hoa gấp nhiều hơn Bình 3 con nhưng ít hơn Nam 8 con. Nam gấp được ___ con hạc.', null, null, null, null, '59', null::jsonb, 'Hoa: 48 + 3 = 51; Nam nhiều hơn Hoa 8: 51 + 8 = 59 (con).', 'bai_toan_nhieu_hon', 46::int),
    (3::smallint, 'multiple_choice', 'Lan gấp nhiều hơn Mai 6 ngôi sao. Sau đó Lan gấp thêm 9 ngôi sao, Mai gấp thêm 11 ngôi sao. Lúc này thì:', 'Mai nhiều hơn Lan 2 ngôi sao', 'Lan nhiều hơn Mai 4 ngôi sao', 'Lan nhiều hơn Mai 6 ngôi sao', 'Lan nhiều hơn Mai 8 ngôi sao', 'Lan nhiều hơn Mai 4 ngôi sao', null::jsonb, 'Mai gấp thêm nhiều hơn Lan 11 - 9 = 2 ngôi sao, nên Lan còn nhiều hơn 6 - 2 = 4 ngôi sao.', 'bai_toan_nhieu_hon', 47::int),
    (3::smallint, 'number', 'Quân có nhiều hơn Bảo 10 quyển truyện. Quân phải cho Bảo mượn ___ quyển để số truyện của hai bạn bằng nhau.', null, null, null, null, '5', null::jsonb, 'Cho mượn 5 quyển thì Quân bớt 5, Bảo thêm 5, hai bạn bằng nhau.', 'bai_toan_nhieu_hon', 47::int),
    (3::smallint, 'multiple_choice', 'Lúc đầu số bi ở hộp xanh bằng số bi ở hộp đỏ. An chuyển 3 viên bi từ hộp xanh sang hộp đỏ. Lúc này:', 'Hộp đỏ nhiều hơn 6 viên', 'Hộp đỏ nhiều hơn 3 viên', 'Hộp xanh nhiều hơn 3 viên', 'Hai hộp bằng nhau', 'Hộp đỏ nhiều hơn 6 viên', null::jsonb, 'Hộp xanh bớt 3 viên, hộp đỏ thêm 3 viên nên hộp đỏ nhiều hơn 3 + 3 = 6 viên.', 'bai_toan_nhieu_hon', 47::int),
    (3::smallint, 'multiple_choice', 'Có bao nhiêu số có hai chữ số mà chữ số hàng đơn vị lớn hơn chữ số hàng chục 5 đơn vị?', '5', '3', '6', '4', '4', null::jsonb, 'Đó là các số 16, 27, 38, 49.', 'cau_tao_so', 45::int),
    (3::smallint, 'number', 'Trong rổ có một số quả trứng. Mẹ bán lần đầu 18 quả, lần sau 2 chục quả thì trong rổ còn 19 quả. Lúc đầu trong rổ có ___ quả trứng.', null, null, null, null, '57', null::jsonb, 'Mẹ đã bán 18 + 20 = 38 quả; lúc đầu có 38 + 19 = 57 (quả).', 'bai_toan_co_loi_van', 49::int),
    (3::smallint, 'number', 'Đoạn thẳng AB dài 29 cm, đoạn thẳng CD dài hơn AB là 11 cm. Đoạn thẳng CD dài ___ dm.', null, null, null, null, '4', null::jsonb, 'CD dài 29 + 11 = 40 cm = 4 dm.', 'bai_toan_co_loi_van', 49::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 5 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 6: Phép cộng dạng 7 + 5; 47 + 5; 47 + 25. Bài toán về ít hơn (38 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 6, 100, 'Archimes: Phép cộng dạng 7 + 5; 47 + 5; 47 + 25. Bài toán về ít hơn', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 6', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '7 + 5 = ___', null, null, null, null, '12', null::jsonb, '7 + 3 = 10, thêm 2 nữa được 12.', 'bang_cong_7', 50::int),
    (1::smallint, 'number', '7 + 8 = ___', null, null, null, null, '15', null::jsonb, '7 + 3 = 10, thêm 5 nữa được 15.', 'bang_cong_7', 50::int),
    (1::smallint, 'number', 'Tính: 17 + 58 = ___', null, null, null, null, '75', null::jsonb, 'Ta tính: 17 + 58 = 75.', 'cong_co_nho', 51::int),
    (1::smallint, 'number', 'Tính: 27 + 36 = ___', null, null, null, null, '63', null::jsonb, 'Ta tính: 27 + 36 = 63.', 'cong_co_nho', 51::int),
    (1::smallint, 'number', 'Tính: 7 + 89 = ___', null, null, null, null, '96', null::jsonb, 'Ta tính: 7 + 89 = 96.', 'cong_co_nho', 51::int),
    (1::smallint, 'number', 'Tính: 47 + 4 = ___', null, null, null, null, '51', null::jsonb, 'Ta tính: 47 + 4 = 51.', 'cong_co_nho', 51::int),
    (1::smallint, 'number', '25 cm + 17 cm = ___ cm', null, null, null, null, '42', null::jsonb, 'Ta tính: 25 + 17 = 42.', 'do_dai', 53::int),
    (1::smallint, 'number', '47 dm + 36 dm = ___ dm', null, null, null, null, '83', null::jsonb, 'Ta tính: 47 + 36 = 83.', 'do_dai', 53::int),
    (1::smallint, 'number', '97 dm - 63 dm = ___ dm', null, null, null, null, '34', null::jsonb, 'Ta tính: 97 - 63 = 34.', 'do_dai', 53::int),
    (1::smallint, 'number', 'Tính: 32 + 15 + 49 = ___', null, null, null, null, '96', null::jsonb, '32 + 15 = 47; 47 + 49 = 96.', 'tinh_day_phep_tinh', 57::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 39 + 15 ___ 59 - 12 + 34', '>', '<', '=', null, '<', null::jsonb, '39 + 15 = 54, 59 - 12 + 34 = 81, mà 54 < 81.', 'so_sanh', 57::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 28 + 17 - 11 ___ 19 + 27', '>', '<', '=', null, '<', null::jsonb, '28 + 17 - 11 = 34, 19 + 27 = 46, mà 34 < 46.', 'so_sanh', 55::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 37 + 6 + 28 ___ 39 + 22', '>', '<', '=', null, '>', null::jsonb, '37 + 6 + 28 = 71, 39 + 22 = 61, mà 71 > 61.', 'so_sanh', 55::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 67 - 31 + 49 ___ 25 + 61', '>', '<', '=', null, '<', null::jsonb, '67 - 31 + 49 = 85, 25 + 61 = 86, mà 85 < 86.', 'so_sanh', 55::int),
    (2::smallint, 'number', '___ + 25 = 57', null, null, null, null, '32', null::jsonb, 'Muốn tìm số hạng, lấy tổng trừ số hạng kia: 57 - 25 = 32.', 'tim_so_hang', 53::int),
    (2::smallint, 'number', '___ - 17 = 60', null, null, null, null, '77', null::jsonb, 'Muốn tìm số bị trừ, lấy hiệu cộng số trừ: 60 + 17 = 77.', 'tim_so_hang', 53::int),
    (2::smallint, 'number', '49 - ___ = 27', null, null, null, null, '22', null::jsonb, 'Muốn tìm số trừ, lấy số bị trừ trừ hiệu: 49 - 27 = 22.', 'tim_so_hang', 53::int),
    (2::smallint, 'number', 'Lớp 2A trồng được 37 cây, ít hơn lớp 2B 5 cây. Lớp 2B trồng được ___ cây.', null, null, null, null, '42', null::jsonb, '2A ít hơn nghĩa là 2B nhiều hơn 5 cây: 37 + 5 = 42 (cây).', 'bai_toan_it_hon', 51::int),
    (2::smallint, 'number', 'Tuần thứ nhất cửa hàng bán được 45 gói đường, tuần thứ hai bán ít hơn tuần thứ nhất 13 gói. Tuần thứ hai bán được ___ gói đường.', null, null, null, null, '32', null::jsonb, 'Ít hơn thì làm phép trừ: 45 - 13 = 32 (gói).', 'bai_toan_it_hon', 52::int),
    (2::smallint, 'number', 'Đoạn thẳng AB dài 15 cm, đoạn thẳng CD ngắn hơn AB là 5 cm. Đoạn CD dài ___ cm.', null, null, null, null, '10', null::jsonb, 'CD dài: 15 - 5 = 10 (cm).', 'bai_toan_it_hon', 52::int),
    (2::smallint, 'number', 'Một đàn gà có 67 con gà trống, ít hơn số gà mái 14 con. Đàn gà có ___ con gà mái.', null, null, null, null, '81', null::jsonb, 'Gà trống ít hơn nên gà mái nhiều hơn 14 con: 67 + 14 = 81 (con).', 'bai_toan_it_hon', 53::int),
    (2::smallint, 'number', 'Buổi sáng cửa hàng bán được 28 túi kẹo, buổi chiều bán ít hơn buổi sáng 12 túi. Buổi chiều bán được ___ túi kẹo.', null, null, null, null, '16', null::jsonb, 'Buổi chiều: 28 - 12 = 16 (túi).', 'bai_toan_it_hon', 53::int),
    (2::smallint, 'number', 'Hùng có 25 thẻ bài, Hải ít hơn Hùng 4 thẻ bài. Hải có ___ thẻ bài.', null, null, null, null, '21', null::jsonb, 'Hải có: 25 - 4 = 21 (thẻ).', 'bai_toan_it_hon', 54::int),
    (2::smallint, 'number', 'Hiện nay mẹ 39 tuổi, mẹ ít hơn bố 5 tuổi. Hiện nay bố ___ tuổi.', null, null, null, null, '44', null::jsonb, 'Mẹ ít hơn bố 5 tuổi nên bố hơn mẹ 5 tuổi: 39 + 5 = 44.', 'bai_toan_it_hon', 57::int),
    (2::smallint, 'number', 'Dũng có 37 cái kẹo, Hùng có 22 cái kẹo. Hùng ít hơn Dũng ___ cái kẹo.', null, null, null, null, '15', null::jsonb, 'Hùng ít hơn Dũng: 37 - 22 = 15 (cái).', 'bai_toan_it_hon', 57::int),
    (2::smallint, 'number', 'Tùng có 98 cái tem và nhiều hơn Hải 12 cái. Hải có ___ cái tem.', null, null, null, null, '86', null::jsonb, 'Tùng nhiều hơn nên Hải ít hơn 12 cái: 98 - 12 = 86.', 'bai_toan_it_hon', 57::int),
    (2::smallint, 'number', 'Chi gấp được 57 ngôi sao. Nếu Chi gấp thêm 14 ngôi sao nữa thì bằng số ngôi sao Hà gấp được. Hà gấp được ___ ngôi sao.', null, null, null, null, '71', null::jsonb, 'Hà gấp được: 57 + 14 = 71 (ngôi sao).', 'bai_toan_it_hon', 57::int),
    (3::smallint, 'number', 'Buổi sáng cửa hàng bán 28 túi kẹo, buổi chiều bán ít hơn buổi sáng 12 túi, buổi tối bán 25 túi. Cả ngày bán được ___ túi kẹo.', null, null, null, null, '69', null::jsonb, 'Buổi chiều: 28 - 12 = 16; cả ngày: 28 + 16 + 25 = 69 (túi).', 'bai_toan_it_hon', 53::int),
    (3::smallint, 'number', 'Mảnh vải thứ nhất dài 37 dm, mảnh thứ hai ngắn hơn mảnh thứ nhất 13 dm. Cả hai mảnh vải dài ___ dm.', null, null, null, null, '61', null::jsonb, 'Mảnh thứ hai: 37 - 13 = 24 dm; cả hai: 37 + 24 = 61 (dm).', 'bai_toan_it_hon', 54::int),
    (3::smallint, 'number', 'Hùng có 25 thẻ bài, Hải ít hơn Hùng 4 thẻ, Dũng nhiều hơn Hùng 2 thẻ. Cả ba bạn có ___ thẻ bài.', null, null, null, null, '73', null::jsonb, 'Hải 21 thẻ, Dũng 27 thẻ; cả ba: 25 + 21 + 27 = 73 (thẻ).', 'bai_toan_it_hon', 54::int),
    (3::smallint, 'number', 'An, Hải, Bình có số bi là các số tròn chục khác nhau, tổng là 60 viên. An có ít bi nhất, Bình có nhiều bi nhất. Bình có ___ viên bi.', null, null, null, null, '30', null::jsonb, 'Ba số tròn chục khác nhau có tổng 60 chỉ có 10, 20, 30. Bình nhiều nhất: 30 viên.', 'suy_luan', 55::int),
    (3::smallint, 'number', 'Nam, Bình, Minh có số bi là các số tròn chục khác nhau, tổng là 70 viên. Nam có ít bi nhất, Minh có nhiều bi nhất. Minh có ___ viên bi.', null, null, null, null, '40', null::jsonb, 'Ba số tròn chục khác nhau có tổng 70 chỉ có 10, 20, 40. Minh nhiều nhất: 40 viên.', 'suy_luan', 55::int),
    (3::smallint, 'multiple_choice', 'Thùng cam có 65 quả, thùng quýt có 85 quả. Mẹ bán số cam và số quýt bằng nhau. Lúc này:', 'Quýt còn ít hơn cam 20 quả', 'Cam còn ít hơn quýt 10 quả', 'Cam còn ít hơn quýt 20 quả', 'Cam và quýt còn bằng nhau', 'Cam còn ít hơn quýt 20 quả', null::jsonb, 'Bớt đi hai số bằng nhau thì phần hơn kém không đổi: 85 - 65 = 20, cam vẫn ít hơn.', 'suy_luan', 55::int),
    (3::smallint, 'number', 'Tổng số tem của Lan và Mai là 27 cái. Tổng số tem của Mai và Chi là 19 cái. Mai có 11 cái. Cả ba bạn có ___ cái tem.', null, null, null, null, '35', null::jsonb, 'Lan: 27 - 11 = 16, Chi: 19 - 11 = 8; cả ba: 16 + 11 + 8 = 35 (cái).', 'suy_luan', 56::int),
    (3::smallint, 'number', 'Số cam ở hai đĩa bằng nhau. Lan lấy 2 quả từ đĩa thứ nhất chuyển sang đĩa thứ hai. Lúc này đĩa thứ hai nhiều hơn đĩa thứ nhất ___ quả.', null, null, null, null, '4', null::jsonb, 'Đĩa thứ nhất bớt 2, đĩa thứ hai thêm 2 nên hơn nhau 2 + 2 = 4 quả.', 'suy_luan', 56::int),
    (3::smallint, 'multiple_choice', 'Hải có nhiều hơn Đức 8 quả bóng bay. Hải cho Đức 3 quả. Lúc này:', 'Hải nhiều hơn Đức 5 quả', 'Hải nhiều hơn Đức 2 quả', 'Đức nhiều hơn Hải 3 quả', 'Hải nhiều hơn Đức 11 quả', 'Hải nhiều hơn Đức 2 quả', null::jsonb, 'Hải bớt 3, Đức thêm 3 nên phần hơn giảm 6: 8 - 6 = 2 quả.', 'suy_luan', 56::int),
    (3::smallint, 'number', 'Vườn có 29 cây táo, số cây cam ít hơn cây táo 5 cây, số cây nhãn nhiều hơn cây cam 6 cây. Vườn có tất cả ___ cây.', null, null, null, null, '83', null::jsonb, 'Cam: 29 - 5 = 24; nhãn: 24 + 6 = 30; tất cả: 29 + 24 + 30 = 83 (cây).', 'suy_luan', 58::int),
    (3::smallint, 'number', 'Trà gấp 38 con thuyền. Tú gấp ít hơn Trà 10 con nhưng nhiều hơn Vy 3 con. Vy gấp nhiều hơn Hân 4 con. Hân gấp được ___ con thuyền.', null, null, null, null, '21', null::jsonb, 'Tú: 38 - 10 = 28; Vy: 28 - 3 = 25; Hân: 25 - 4 = 21 (con).', 'suy_luan', 58::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 6 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 7: Ki-lô-gam. Phép cộng dạng 6 + 5; 26 + 5; 36 + 15 (39 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 7, 100, 'Archimes: Ki-lô-gam. Phép cộng dạng 6 + 5; 26 + 5; 36 + 15', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 7', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '6 + 5 = ___', null, null, null, null, '11', null::jsonb, '6 + 4 = 10, thêm 1 nữa được 11.', 'bang_cong_6', 59::int),
    (1::smallint, 'number', '6 + 8 = ___', null, null, null, null, '14', null::jsonb, '6 + 4 = 10, thêm 4 nữa được 14.', 'bang_cong_6', 59::int),
    (1::smallint, 'number', 'Tính: 26 + 9 = ___', null, null, null, null, '35', null::jsonb, 'Ta tính: 26 + 9 = 35.', 'cong_co_nho', 62::int),
    (1::smallint, 'number', 'Tính: 46 + 8 = ___', null, null, null, null, '54', null::jsonb, 'Ta tính: 46 + 8 = 54.', 'cong_co_nho', 62::int),
    (1::smallint, 'number', 'Tính: 76 + 5 = ___', null, null, null, null, '81', null::jsonb, 'Ta tính: 76 + 5 = 81.', 'cong_co_nho', 62::int),
    (1::smallint, 'number', '9 kg + 21 kg = ___ kg', null, null, null, null, '30', null::jsonb, 'Ta tính: 9 + 21 = 30.', 'khoi_luong', 62::int),
    (1::smallint, 'number', '29 kg + 14 kg = ___ kg', null, null, null, null, '43', null::jsonb, 'Ta tính: 29 + 14 = 43.', 'khoi_luong', 62::int),
    (1::smallint, 'number', '49 kg - 27 kg = ___ kg', null, null, null, null, '22', null::jsonb, 'Ta tính: 49 - 27 = 22.', 'khoi_luong', 62::int),
    (1::smallint, 'text', 'Ki-lô-gam viết tắt là ___.', null, null, null, null, 'kg', null::jsonb, 'Ki-lô-gam kí hiệu là kg.', 'khoi_luong', 59::int),
    (1::smallint, 'multiple_choice', 'Đơn vị nào dùng để đo độ nặng (khối lượng) của một vật?', 'Ki-lô-gam', 'Xăng-ti-mét', 'Đề-xi-mét', null, 'Ki-lô-gam', null::jsonb, 'Ki-lô-gam (kg) là đơn vị đo khối lượng; cm, dm dùng đo độ dài.', 'khoi_luong', 59::int),
    (1::smallint, 'number', 'Số gồm 7 chục và 5 đơn vị là ___.', null, null, null, null, '75', null::jsonb, '7 chục là 70, thêm 5 đơn vị được 75.', 'cau_tao_so', 66::int),
    (1::smallint, 'multiple_choice', 'Số lớn nhất trong các số 82; 47; 91; 89; 45 là:', '91', '89', '82', '47', '91', null::jsonb, 'So sánh hàng chục: 9 lớn nhất, trong 91 và 89 thì 91 lớn hơn.', 'cau_tao_so', 66::int),
    (1::smallint, 'number', '38 kg + 16 kg - 21 kg = ___ kg', null, null, null, null, '33', null::jsonb, '38 + 16 = 54; 54 - 21 = 33 (kg).', 'cau_tao_so', 66::int),
    (2::smallint, 'number', 'Trên bãi cỏ có 45 con trâu. Số bò ít hơn số trâu 11 con. Có ___ con bò.', null, null, null, null, '34', null::jsonb, 'Số bò: 45 - 11 = 34 (con).', 'bai_toan_it_hon', 60::int),
    (2::smallint, 'number', 'Vườn nhà Hoa có 55 cây bưởi. Số cây bưởi ít hơn số cây nhãn 13 cây. Vườn có ___ cây nhãn.', null, null, null, null, '68', null::jsonb, 'Bưởi ít hơn nên nhãn nhiều hơn 13 cây: 55 + 13 = 68.', 'bai_toan_it_hon', 60::int),
    (2::smallint, 'number', 'Hiện nay mẹ 34 tuổi và ít hơn bố 7 tuổi. Hiện nay bố ___ tuổi.', null, null, null, null, '41', null::jsonb, 'Bố hơn mẹ 7 tuổi: 34 + 7 = 41.', 'bai_toan_it_hon', 60::int),
    (2::smallint, 'number', 'Quyển sách thứ nhất có 48 trang, quyển thứ hai ít hơn quyển thứ nhất 16 trang. Quyển thứ hai có ___ trang.', null, null, null, null, '32', null::jsonb, 'Quyển thứ hai: 48 - 16 = 32 (trang).', 'bai_toan_it_hon', 61::int),
    (2::smallint, 'number', 'Bà mang ra chợ 46 quả trứng gà và 28 quả trứng vịt. Bà mang tất cả ___ quả trứng.', null, null, null, null, '74', null::jsonb, '46 + 28 = 74 (quả).', 'bai_toan_co_loi_van', 62::int),
    (2::smallint, 'number', 'Cửa hàng bán được 68 kg gạo gồm gạo nếp và gạo tẻ, trong đó có 34 kg gạo nếp. Cửa hàng bán được ___ kg gạo tẻ.', null, null, null, null, '34', null::jsonb, 'Gạo tẻ: 68 - 34 = 34 (kg).', 'bai_toan_co_loi_van', 62::int),
    (2::smallint, 'number', 'Bao thóc thứ nhất nặng 58 kg và nặng hơn bao thứ hai 17 kg. Bao thóc thứ hai nặng ___ kg.', null, null, null, null, '41', null::jsonb, 'Bao thứ hai nhẹ hơn 17 kg: 58 - 17 = 41 (kg).', 'khoi_luong', 63::int),
    (2::smallint, 'number', 'Bao bột mì nặng 28 kg. Bao gạo nặng hơn bao bột mì 7 kg. Bao gạo nặng ___ kg.', null, null, null, null, '35', null::jsonb, 'Bao gạo: 28 + 7 = 35 (kg).', 'khoi_luong', 66::int),
    (2::smallint, 'number', 'Mỗi túi gạo nặng 26 kg. Hai túi gạo như thế nặng ___ kg.', null, null, null, null, '52', null::jsonb, 'Hai túi: 26 + 26 = 52 (kg).', 'khoi_luong', 66::int),
    (2::smallint, 'multiple_choice', 'Chữ số thích hợp điền vào chỗ trống: 7___ > 69 + 9', '8', '7', '0', '9', '9', null::jsonb, '69 + 9 = 78; cần số 7_ lớn hơn 78 nên chữ số là 9 (79 > 78).', 'so_sanh', 66::int),
    (2::smallint, 'number', 'Hà có số tờ giấy màu là số tròn chục liền sau của 54. Hà ít hơn Mai 17 tờ. Mai có ___ tờ giấy màu.', null, null, null, null, '77', null::jsonb, 'Số tròn chục liền sau 54 là 60; Mai có 60 + 17 = 77 (tờ).', 'bai_toan_it_hon', 67::int),
    (3::smallint, 'number', 'Năm nay ông 76 tuổi và cháu 8 tuổi. Hai năm nữa, tổng số tuổi của hai ông cháu là ___ tuổi.', null, null, null, null, '88', null::jsonb, 'Hiện nay tổng là 84; hai năm nữa mỗi người thêm 2 tuổi: 84 + 4 = 88.', 'tuoi', 61::int),
    (3::smallint, 'number', 'Nam giải được 37 câu đố, ít hơn Minh 19 câu. Cả hai bạn giải được ___ câu đố.', null, null, null, null, '93', null::jsonb, 'Minh: 37 + 19 = 56; cả hai: 37 + 56 = 93 (câu).', 'bai_toan_it_hon', 61::int),
    (3::smallint, 'number', 'Ngày thứ nhất cửa hàng bán 34 kg bột mì, ngày thứ hai bán nhiều hơn ngày thứ nhất 7 kg. Cả hai ngày bán được ___ kg.', null, null, null, null, '75', null::jsonb, 'Ngày thứ hai: 34 + 7 = 41 kg; cả hai ngày: 34 + 41 = 75 (kg).', 'khoi_luong', 63::int),
    (3::smallint, 'number', 'Hồng cho Đào và Mai mỗi bạn 1 chục con tem thì số tem của ba bạn bằng nhau và bằng 54 con. Lúc đầu Hồng có ___ con tem.', null, null, null, null, '74', null::jsonb, 'Hồng đã cho đi 10 + 10 = 20 con; lúc đầu có 54 + 20 = 74 (con).', 'suy_luan', 63::int),
    (3::smallint, 'number', 'Tùng có 30 viên bi. Tùng cho Toàn 5 viên, Toàn lại cho Dũng 3 viên thì số bi của ba bạn bằng nhau. Lúc đầu Toàn có ___ viên bi.', null, null, null, null, '23', null::jsonb, 'Tùng còn 25 viên nên mỗi bạn có 25; Toàn trước khi cho Dũng có 28, trước khi nhận của Tùng có 28 - 5 = 23.', 'suy_luan', 65::int),
    (3::smallint, 'number', 'Số hạng thứ nhất là số liền trước của 60, số hạng thứ hai bé hơn số hạng thứ nhất 20 đơn vị. Tổng hai số là ___.', null, null, null, null, '98', null::jsonb, 'Số thứ nhất 59; số thứ hai 59 - 20 = 39; tổng 59 + 39 = 98.', 'tim_so', 65::int),
    (3::smallint, 'number', 'Số bị trừ là số chẵn lớn nhất có hai chữ số. Số trừ là số lẻ liền sau số có chữ số hàng chục là 5 và chữ số hàng đơn vị là số lẻ nhỏ nhất có một chữ số. Hiệu là ___.', null, null, null, null, '45', null::jsonb, 'Số bị trừ 98; số có hàng chục 5, hàng đơn vị 1 là 51, số lẻ liền sau là 53; 98 - 53 = 45.', 'tim_so', 65::int),
    (3::smallint, 'number', 'Một số trừ đi 7, rồi trừ tiếp 16, rồi cộng 21, rồi cộng 15 thì được 79. Số đó là ___.', null, null, null, null, '66', null::jsonb, 'Tính ngược: 79 - 15 = 64, 64 - 21 = 43, 43 + 16 = 59, 59 + 7 = 66.', 'tim_so', 64::int),
    (3::smallint, 'number', 'Một số cộng 4, rồi trừ 20 thì được 64. Số đó là ___.', null, null, null, null, '80', null::jsonb, 'Tính ngược: 64 + 20 = 84, 84 - 4 = 80.', 'tim_so', 64::int),
    (3::smallint, 'multiple_choice', 'Điền dấu + hoặc - vào các ô trống: 12 ☐ 34 ☐ 5 ☐ 20 ☐ 21 = 0. Các dấu lần lượt là:', '+, +, -, -', '+, -, +, -', '+, -, -, -', '-, +, -, -', '+, -, -, -', null::jsonb, '12 + 34 = 46; 46 - 5 - 20 - 21 = 0.', 'dien_dau', 64::int),
    (3::smallint, 'multiple_choice', 'Cách điền dấu nào đúng: 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 ☐ 6 = 1?', '1 + 2 - 3 + 4 - 5 + 6', '1 + 2 + 3 - 4 + 5 - 6', '1 + 2 + 3 - 4 - 5 + 6', '1 + 2 + 3 + 4 - 5 - 6', '1 + 2 + 3 - 4 + 5 - 6', null::jsonb, '1 + 2 + 3 = 6; 6 - 4 = 2; 2 + 5 = 7; 7 - 6 = 1.', 'dien_dau', 64::int),
    (3::smallint, 'multiple_choice', 'Từ các chữ số 0; 1; 3; 5; 7; 8, viết được những số có hai chữ số nào mà tổng các chữ số bằng 9?', '18 và 81', '18; 81 và 90', '27 và 72', '36 và 63', '18 và 81', null::jsonb, 'Chỉ có 1 + 8 = 9 dùng được các chữ số đã cho, nên có 18 và 81.', 'cau_tao_so', 64::int),
    (3::smallint, 'number', 'Dãy số: 1; 1; 2; 3; 5; 8; … (mỗi số bằng tổng hai số đứng trước). Số thứ chín của dãy là ___.', null, null, null, null, '34', null::jsonb, 'Dãy tiếp theo: 13; 21; 34. Số thứ chín là 34.', 'day_so', 66::int),
    (3::smallint, 'number', 'Minh có 95 viên bi, Bình nhiều hơn Minh 4 viên, An ít hơn Bình 2 chục viên. An có ___ viên bi.', null, null, null, null, '79', null::jsonb, 'Bình: 95 + 4 = 99; An: 99 - 20 = 79 (viên).', 'bai_toan_nhieu_hon', 67::int),
    (3::smallint, 'number', 'Thùng thứ nhất có 26 kg bột mì, thùng thứ hai nhiều hơn thùng thứ nhất 16 kg, thùng thứ ba ít hơn thùng thứ nhất 5 kg. Cả ba thùng có ___ kg.', null, null, null, null, '89', null::jsonb, 'Thùng hai: 42 kg; thùng ba: 21 kg; cả ba: 26 + 42 + 21 = 89 (kg).', 'bai_toan_nhieu_hon', 67::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 7 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 8: Bảng cộng. Phép cộng có tổng bằng 100 (45 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 8, 100, 'Archimes: Bảng cộng. Phép cộng có tổng bằng 100', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 8', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '9 + 6 = ___', null, null, null, null, '15', null::jsonb, 'Ta tính: 9 + 6 = 15.', 'bang_cong', 68::int),
    (1::smallint, 'number', '8 + 6 = ___', null, null, null, null, '14', null::jsonb, 'Ta tính: 8 + 6 = 14.', 'bang_cong', 68::int),
    (1::smallint, 'number', '7 + 6 = ___', null, null, null, null, '13', null::jsonb, 'Ta tính: 7 + 6 = 13.', 'bang_cong', 68::int),
    (1::smallint, 'number', 'Tính: 64 + 36 = ___', null, null, null, null, '100', null::jsonb, '4 + 6 = 10 viết 0 nhớ 1; 6 + 3 thêm 1 bằng 10. Kết quả 100.', 'tong_bang_100', 75::int),
    (1::smallint, 'number', 'Tính: 51 + 39 = ___', null, null, null, null, '90', null::jsonb, 'Ta tính: 51 + 39 = 90.', 'cong_co_nho', 75::int),
    (1::smallint, 'number', 'Tính: 88 + 3 = ___', null, null, null, null, '91', null::jsonb, 'Ta tính: 88 + 3 = 91.', 'cong_co_nho', 75::int),
    (1::smallint, 'number', 'Tính: 35 - 21 + 86 = ___', null, null, null, null, '100', null::jsonb, '35 - 21 = 14; 14 + 86 = 100.', 'tinh_day_phep_tinh', 69::int),
    (1::smallint, 'number', '90 cm + 10 cm - 20 cm = ___ cm', null, null, null, null, '80', null::jsonb, '90 + 10 = 100; 100 - 20 = 80 (cm).', 'tinh_day_phep_tinh', 69::int),
    (1::smallint, 'number', '67 kg - 25 kg - 20 kg = ___ kg', null, null, null, null, '22', null::jsonb, '67 - 25 = 42; 42 - 20 = 22 (kg).', 'khoi_luong', 75::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 18 + 29 ___ 28 + 19', '>', '<', '=', null, '=', null::jsonb, '18 + 29 = 47, 28 + 19 = 47, mà 47 = 47.', 'so_sanh', 71::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 34 + 39 ___ 68 + 24', '>', '<', '=', null, '<', null::jsonb, '34 + 39 = 73, 68 + 24 = 92, mà 73 < 92.', 'so_sanh', 71::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 11 + 28 + 19 ___ 79 - 22', '>', '<', '=', null, '>', null::jsonb, '11 + 28 + 19 = 58, 79 - 22 = 57, mà 58 > 57.', 'so_sanh', 71::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 23 + 27 + 12 ___ 73 - 10', '>', '<', '=', null, '<', null::jsonb, '23 + 27 + 12 = 62, 73 - 10 = 63, mà 62 < 63.', 'so_sanh', 71::int),
    (2::smallint, 'number', '___ + 14 = 25', null, null, null, null, '11', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 25 - 14 = 11.', 'tim_so_hang', 71::int),
    (2::smallint, 'number', '60 + ___ = 92', null, null, null, null, '32', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 92 - 60 = 32.', 'tim_so_hang', 71::int),
    (2::smallint, 'number', 'Số hạng thứ nhất là 23, tổng là 45. Số hạng thứ hai là ___.', null, null, null, null, '22', null::jsonb, 'Số hạng thứ hai: 45 - 23 = 22.', 'tim_so_hang', 69::int),
    (2::smallint, 'number', 'Mai có 12 cái nhãn vở, chị Lan cho Mai 4 cái, sau đó mẹ cho Mai 15 cái nữa. Lúc này Mai có ___ cái nhãn vở.', null, null, null, null, '31', null::jsonb, '12 + 4 = 16; 16 + 15 = 31 (cái).', 'bai_toan_co_loi_van', 69::int),
    (2::smallint, 'number', 'Nhà bà Nga nuôi 27 con gà, 33 con vịt và 40 con thỏ. Nhà bà Nga nuôi tất cả ___ con.', null, null, null, null, '100', null::jsonb, '27 + 33 = 60; 60 + 40 = 100 (con).', 'bai_toan_co_loi_van', 71::int),
    (2::smallint, 'number', 'Có 34 xe khách rời bến, trên bến còn 19 xe khách chưa rời bến. Lúc đầu bến có ___ xe khách.', null, null, null, null, '53', null::jsonb, 'Lúc đầu có: 34 + 19 = 53 (xe khách).', 'bai_toan_co_loi_van', 71::int),
    (2::smallint, 'number', 'Từ một thùng sách lấy ra 12 quyển thì còn lại 38 quyển. Lúc đầu thùng có ___ quyển sách.', null, null, null, null, '50', null::jsonb, 'Lúc đầu có: 12 + 38 = 50 (quyển).', 'bai_toan_co_loi_van', 75::int),
    (2::smallint, 'number', 'Tổng số tuổi của hai mẹ con Khánh là 52 tuổi, Khánh 12 tuổi. Mẹ Khánh ___ tuổi.', null, null, null, null, '40', null::jsonb, 'Tuổi mẹ: 52 - 12 = 40 (tuổi).', 'bai_toan_co_loi_van', 75::int),
    (2::smallint, 'number', 'Tổng của số lớn nhất có hai chữ số với số liền sau của 0 là ___.', null, null, null, null, '100', null::jsonb, 'Số lớn nhất có hai chữ số là 99, số liền sau của 0 là 1; 99 + 1 = 100.', 'bai_toan_co_loi_van', 75::int),
    (2::smallint, 'number', 'Điền số tiếp theo của dãy: 1; 4; 7; 10; ___', null, null, null, null, '13', null::jsonb, 'Mỗi số hơn số trước 3 đơn vị: 10 + 3 = 13.', 'day_so', 75::int),
    (2::smallint, 'number', 'Điền số tiếp theo của dãy: 97; 86; 75; 64; ___', null, null, null, null, '53', null::jsonb, 'Mỗi số kém số trước 11 đơn vị: 64 - 11 = 53.', 'day_so', 75::int),
    (2::smallint, 'multiple_choice', 'Có bao nhiêu số có hai chữ số mà tổng hai chữ số bằng 10?', '10', '8', '5', '9', '9', null::jsonb, 'Đó là 19, 28, 37, 46, 55, 64, 73, 82, 91.', 'cau_tao_so', 75::int),
    (3::smallint, 'number', 'Lớp 2A có 27 học sinh, lớp 2B có 29 học sinh, lớp 2C nhiều hơn lớp 2B 3 học sinh. Cả ba lớp có ___ học sinh.', null, null, null, null, '88', null::jsonb, 'Lớp 2C: 29 + 3 = 32; cả ba lớp: 27 + 29 + 32 = 88.', 'bai_toan_nhieu_hon', 70::int),
    (3::smallint, 'number', 'Thảo nặng 21 kg, Vân nặng 24 kg, Linh nặng hơn Vân 5 kg. Cả ba bạn nặng ___ kg.', null, null, null, null, '74', null::jsonb, 'Linh: 24 + 5 = 29 kg; cả ba: 21 + 24 + 29 = 74 (kg).', 'bai_toan_nhieu_hon', 70::int),
    (3::smallint, 'number', 'Năm trước lớp 1A có 17 bạn nam, lớp 1B có 19 bạn nam. Lên lớp 2, mỗi lớp có thêm 4 bạn nam chuyển đến. Lúc này hai lớp có ___ bạn nam.', null, null, null, null, '44', null::jsonb, '17 + 19 = 36; thêm 4 + 4 = 8 bạn: 36 + 8 = 44.', 'bai_toan_nhieu_hon', 70::int),
    (3::smallint, 'number', 'Bến xe có 25 xe buýt và 34 xe khách rời bến, trên bến còn 16 xe buýt và 19 xe khách. Lúc đầu bến có tất cả ___ xe buýt và xe khách.', null, null, null, null, '94', null::jsonb, 'Xe buýt: 25 + 16 = 41; xe khách: 34 + 19 = 53; tất cả: 41 + 53 = 94.', 'bai_toan_nhieu_hon', 71::int),
    (3::smallint, 'number', 'Ba lớp 2A, 2B, 2C có 96 học sinh. Lớp 2A và 2B có 61 học sinh, lớp 2B và 2C có 65 học sinh. Lớp 2B có ___ học sinh.', null, null, null, null, '30', null::jsonb, 'Lớp 2C: 96 - 61 = 35; lớp 2B: 65 - 35 = 30.', 'suy_luan', 72::int),
    (3::smallint, 'number', 'Bắc có số bi là số nhỏ nhất có hai chữ số giống nhau, Trung có số bi là số chẵn lớn nhất có một chữ số, Nam có số bi bằng tổng số bi hai bạn. Nam phải cho Bắc ___ viên để hai bạn bằng nhau.', null, null, null, null, '4', null::jsonb, 'Bắc 11, Trung 8, Nam 19. Nam hơn Bắc 8 viên, cho Bắc 4 viên thì bằng nhau.', 'suy_luan', 72::int),
    (3::smallint, 'number', 'Điền chữ số thích hợp: ☐3 + 18 = 81. Chữ số cần điền là ___.', null, null, null, null, '6', null::jsonb, '81 - 18 = 63, nên chữ số cần điền là 6.', 'cau_tao_so', 73::int),
    (3::smallint, 'number', 'Số 67 thay đổi thế nào nếu xóa chữ số 7? Số đó giảm đi ___ đơn vị.', null, null, null, null, '61', null::jsonb, 'Xóa chữ số 7 còn số 6; 67 - 6 = 61.', 'cau_tao_so', 73::int),
    (3::smallint, 'number', 'Một số có hai chữ số, nếu chữ số hàng chục tăng thêm 4 thì số đó tăng thêm ___ đơn vị.', null, null, null, null, '40', null::jsonb, 'Mỗi đơn vị ở hàng chục là 10, tăng 4 chục là tăng 40 đơn vị.', 'cau_tao_so', 73::int),
    (3::smallint, 'multiple_choice', 'Một số có hai chữ số, nếu chữ số hàng chục tăng thêm 1 và chữ số hàng đơn vị giảm đi 1 thì số đó:', 'Không thay đổi', 'Giảm 9 đơn vị', 'Tăng 9 đơn vị', 'Tăng 11 đơn vị', 'Tăng 9 đơn vị', null::jsonb, 'Tăng 1 chục (10) và giảm 1 đơn vị: 10 - 1 = 9, số tăng 9 đơn vị.', 'cau_tao_so', 73::int),
    (3::smallint, 'number', 'Hai số có hai chữ số có cùng chữ số hàng đơn vị, chữ số hàng chục hơn kém nhau 3. Hai số đó hơn kém nhau ___ đơn vị.', null, null, null, null, '30', null::jsonb, 'Hơn kém 3 chục tức là 30 đơn vị.', 'cau_tao_so', 74::int),
    (3::smallint, 'multiple_choice', 'Có bao nhiêu số có hai chữ số mà khi đổi chỗ chữ số hàng chục và hàng đơn vị thì số đó không đổi?', '10', '9', '8', '11', '9', null::jsonb, 'Đó là các số có hai chữ số giống nhau: 11, 22, …, 99.', 'cau_tao_so', 74::int),
    (3::smallint, 'number', 'Huy có 40 viên bi đựng trong hai túi. Chuyển 15 viên từ túi A sang túi B, rồi chuyển 12 viên từ túi B sang túi A thì hai túi bằng nhau. Ban đầu túi A có ___ viên bi.', null, null, null, null, '23', null::jsonb, 'Cuối cùng mỗi túi 20 viên; tính ngược túi A: 20 - 12 + 15 = 23.', 'suy_luan', 74::int),
    (3::smallint, 'number', 'Mai nhiều hơn Hoa một số kẹo. Mai cho Hoa 5 cái thì Mai lại ít hơn Hoa 2 cái. Lúc đầu Mai nhiều hơn Hoa ___ cái kẹo.', null, null, null, null, '8', null::jsonb, 'Cho 5 cái thì phần hơn giảm 10; từ hơn thành kém 2 nên lúc đầu hơn 10 - 2 = 8 cái.', 'suy_luan', 74::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 46 + x ___ 45 + x', '>', '<', '=', null, '>', null::jsonb, 'Cùng cộng x, mà 46 > 45 nên 46 + x > 45 + x.', 'so_sanh_chu_so', 71::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: x + 12 ___ 5 + 7 + x', '>', '<', '=', null, '=', null::jsonb, '5 + 7 = 12 nên 5 + 7 + x = 12 + x = x + 12.', 'so_sanh_chu_so', 71::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 46 - x ___ 47 - x', '>', '<', '=', null, '<', null::jsonb, 'Cùng trừ đi x, mà 46 < 47 nên 46 - x < 47 - x.', 'so_sanh_chu_so', 76::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 25 + x - 15 ___ 15 + 4 + x', '>', '<', '=', null, '<', null::jsonb, '25 + x - 15 = 10 + x, còn 15 + 4 + x = 19 + x, mà 10 < 19.', 'so_sanh_chu_so', 76::int),
    (3::smallint, 'number', 'Hiện nay mẹ 26 tuổi. Khi tuổi con bằng tuổi mẹ hiện nay thì mẹ 49 tuổi. Hiện nay con ___ tuổi.', null, null, null, null, '3', null::jsonb, 'Mẹ hơn con 49 - 26 = 23 tuổi; tuổi con hiện nay: 26 - 23 = 3.', 'tuoi', 76::int),
    (3::smallint, 'number', 'Nếu Chủ nhật tuần này là ngày 22 tháng 5 thì thứ Bảy tuần sau là ngày ___ tháng 5.', null, null, null, null, '28', null::jsonb, 'Thứ Hai tuần sau là ngày 23, đến thứ Bảy là thêm 6 ngày: 22 + 6 = 28.', 'suy_luan', 75::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 8 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 9: Lít. Tìm số hạng trong một tổng. Ôn tập (45 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 9, 100, 'Archimes: Lít. Tìm số hạng trong một tổng. Ôn tập', 'Ngân hàng Archimes — Toán 2 - Quyển 1, tuần 9', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '23 l + 17 l = ___ l', null, null, null, null, '40', null::jsonb, 'Ta tính: 23 + 17 = 40.', 'lit', 78::int),
    (1::smallint, 'number', '43 l - 32 l = ___ l', null, null, null, null, '11', null::jsonb, 'Ta tính: 43 - 32 = 11.', 'lit', 78::int),
    (1::smallint, 'number', '27 l + 14 l = ___ l', null, null, null, null, '41', null::jsonb, 'Ta tính: 27 + 14 = 41.', 'lit', 78::int),
    (1::smallint, 'number', '38 kg + 45 kg = ___ kg', null, null, null, null, '83', null::jsonb, 'Ta tính: 38 + 45 = 83.', 'cong_don_vi', 78::int),
    (1::smallint, 'number', '97 dm - 82 dm = ___ dm', null, null, null, null, '15', null::jsonb, 'Ta tính: 97 - 82 = 15.', 'cong_don_vi', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 25 + 7 ___ 37 - 6', '>', '<', '=', null, '>', null::jsonb, '25 + 7 = 32, 37 - 6 = 31, mà 32 > 31.', 'so_sanh', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 43 + 19 ___ 25 + 38', '>', '<', '=', null, '<', null::jsonb, '43 + 19 = 62, 25 + 38 = 63, mà 62 < 63.', 'so_sanh', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 16 + 8 ___ 29 - 5', '>', '<', '=', null, '=', null::jsonb, '16 + 8 = 24, 29 - 5 = 24, mà 24 = 24.', 'so_sanh', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 75 + 25 ___ 46 + 54', '>', '<', '=', null, '=', null::jsonb, '75 + 25 = 100, 46 + 54 = 100, mà 100 = 100.', 'so_sanh', 78::int),
    (1::smallint, 'number', '7 dm = ___ cm', null, null, null, null, '70', null::jsonb, '1 dm = 10 cm nên 7 dm = 70 cm.', 'doi_don_vi', 84::int),
    (1::smallint, 'number', '4 l < ___ l < 6 l', null, null, null, null, '5', null::jsonb, 'Số lớn hơn 4 và bé hơn 6 là 5.', 'doi_don_vi', 84::int),
    (1::smallint, 'text', 'Lít viết tắt là ___.', null, null, null, null, 'l', null::jsonb, 'Lít kí hiệu là l.', 'lit', 77::int),
    (1::smallint, 'number', 'Tính: 37 + 48 = ___', null, null, null, null, '85', null::jsonb, 'Ta tính: 37 + 48 = 85.', 'cong_co_nho', 84::int),
    (2::smallint, 'number', '___ + 14 = 46', null, null, null, null, '32', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 46 - 14 = 32.', 'tim_so_hang', 80::int),
    (2::smallint, 'number', '35 + ___ = 95', null, null, null, null, '60', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 95 - 35 = 60.', 'tim_so_hang', 80::int),
    (2::smallint, 'number', '21 + 19 + ___ = 90', null, null, null, null, '50', null::jsonb, '21 + 19 = 40; số cần điền: 90 - 40 = 50.', 'tim_so_hang', 84::int),
    (2::smallint, 'number', 'Tuấn nặng 29 kg. Hà nặng hơn Tuấn 5 kg. Hà nặng ___ kg.', null, null, null, null, '34', null::jsonb, 'Hà nặng: 29 + 5 = 34 (kg).', 'bai_toan_nhieu_hon', 78::int),
    (2::smallint, 'number', 'Thùng thứ nhất có 29 l nước, thùng thứ hai có ít hơn thùng thứ nhất 14 l. Thùng thứ hai có ___ l nước.', null, null, null, null, '15', null::jsonb, 'Thùng thứ hai: 29 - 14 = 15 (l).', 'bai_toan_nhieu_hon', 78::int),
    (2::smallint, 'number', 'Nam nặng 32 kg, nặng hơn Hà 2 kg nhưng nhẹ hơn Bình 5 kg. Bình nặng ___ kg.', null, null, null, null, '37', null::jsonb, 'Nam nhẹ hơn Bình 5 kg nên Bình nặng 32 + 5 = 37 (kg).', 'bai_toan_nhieu_hon', 79::int),
    (2::smallint, 'number', 'Số lớn nhất có hai chữ số mà tổng hai chữ số bằng 11 là ___.', null, null, null, null, '92', null::jsonb, 'Chọn chữ số hàng chục lớn nhất là 9, hàng đơn vị là 11 - 9 = 2: số 92.', 'cau_tao_so', 80::int),
    (2::smallint, 'number', 'Từ một can nước mắm lấy đi 7 l thì còn lại 15 l. Lúc đầu can có ___ l nước mắm.', null, null, null, null, '22', null::jsonb, 'Lúc đầu có: 7 + 15 = 22 (l).', 'bai_toan_co_loi_van', 84::int),
    (2::smallint, 'number', 'Bao gạo thứ nhất nặng 40 kg. Bao thứ hai nặng hơn bao thứ nhất 8 kg. Bao thứ hai nặng ___ kg.', null, null, null, null, '48', null::jsonb, 'Bao thứ hai: 40 + 8 = 48 (kg).', 'bai_toan_co_loi_van', 84::int),
    (2::smallint, 'number', 'Tuần thứ nhất cửa hàng bán 45 l nước mắm, tuần thứ hai bán 36 l. Cả hai tuần bán được ___ l.', null, null, null, null, '81', null::jsonb, '45 + 36 = 81 (l).', 'bai_toan_co_loi_van', 85::int),
    (2::smallint, 'number', 'Khối Năm trồng được 37 cây, khối Bốn trồng 28 cây, khối Ba trồng 19 cây. Cả ba khối trồng được ___ cây.', null, null, null, null, '84', null::jsonb, '37 + 28 = 65; 65 + 19 = 84 (cây).', 'bai_toan_co_loi_van', 81::int),
    (2::smallint, 'number', 'Điền số tiếp theo của dãy: 18; 23; 28; 33; 38; ___', null, null, null, null, '43', null::jsonb, 'Mỗi số hơn số trước 5 đơn vị: 38 + 5 = 43.', 'day_so', 82::int),
    (2::smallint, 'number', 'Điền số tiếp theo của dãy: 29; 38; 47; 56; 65; ___', null, null, null, null, '74', null::jsonb, 'Mỗi số hơn số trước 9 đơn vị: 65 + 9 = 74.', 'day_so', 82::int),
    (3::smallint, 'number', 'Tìm x, biết: x + 15 = 48. Vậy x = ___', null, null, null, null, '33', null::jsonb, 'Muốn tìm số hạng, lấy tổng trừ số hạng kia: x = 48 - 15 = 33.', 'tim_so_hang', 84::int),
    (3::smallint, 'number', '24 + ___ = 98 - 13', null, null, null, null, '61', null::jsonb, '98 - 13 = 85; số cần điền: 85 - 24 = 61.', 'tim_so_hang', 80::int),
    (3::smallint, 'number', '21 + 45 = ___ + 14', null, null, null, null, '52', null::jsonb, '21 + 45 = 66; số cần điền: 66 - 14 = 52.', 'tim_so_hang', 80::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó cộng với 10 rồi cộng với 14 thì được 44. Số đó là ___.', null, null, null, null, '20', null::jsonb, 'Tính ngược: 44 - 14 = 30; 30 - 10 = 20.', 'tim_so_hang', 80::int),
    (3::smallint, 'number', 'Hiệu của số chẵn lớn nhất có hai chữ số và số lớn nhất có hai chữ số mà tổng hai chữ số là 13 là ___.', null, null, null, null, '4', null::jsonb, 'Số chẵn lớn nhất có hai chữ số là 98; số lớn nhất có tổng hai chữ số bằng 13 là 94; 98 - 94 = 4.', 'tim_so_hang', 80::int),
    (3::smallint, 'number', 'Nam có 57 cái tem, Bình có ít hơn Nam 15 cái. Cả hai bạn có ___ cái tem.', null, null, null, null, '99', null::jsonb, 'Bình: 57 - 15 = 42; cả hai: 57 + 42 = 99 (cái).', 'bai_toan_it_hon', 79::int),
    (3::smallint, 'number', 'Nam nặng 32 kg, nặng hơn Hà 2 kg nhưng nhẹ hơn Bình 5 kg. Cả ba bạn nặng ___ kg.', null, null, null, null, '99', null::jsonb, 'Hà 30 kg, Bình 37 kg; cả ba: 32 + 30 + 37 = 99 (kg).', 'bai_toan_it_hon', 79::int),
    (3::smallint, 'number', 'Mẹ mang ra chợ 78 quả trứng. Buổi sáng bán được 34 quả, buổi chiều bán được 37 quả. Mẹ còn lại ___ quả trứng.', null, null, null, null, '7', null::jsonb, 'Cả hai buổi bán 34 + 37 = 71 quả; còn lại 78 - 71 = 7 (quả).', 'bai_toan_co_loi_van', 81::int),
    (3::smallint, 'number', 'Ngày thứ nhất cửa hàng bán 47 kg gạo và bán nhiều hơn ngày thứ hai 10 kg. Cả hai ngày bán được ___ kg gạo.', null, null, null, null, '84', null::jsonb, 'Ngày thứ hai: 47 - 10 = 37 kg; cả hai ngày: 47 + 37 = 84 (kg).', 'bai_toan_co_loi_van', 85::int),
    (3::smallint, 'number', 'Hai bao ngô nặng tất cả 56 kg. Người ta đổ 8 kg từ bao thứ nhất sang bao thứ hai. Lúc đó cả hai bao nặng ___ kg.', null, null, null, null, '56', null::jsonb, 'Chỉ đổ từ bao này sang bao kia nên tổng vẫn là 56 kg.', 'suy_luan', 84::int),
    (3::smallint, 'number', 'Cách đây một năm Hùng 8 tuổi. Sau ba năm nữa Hùng ___ tuổi.', null, null, null, null, '12', null::jsonb, 'Hiện nay Hùng 8 + 1 = 9 tuổi; ba năm nữa: 9 + 3 = 12 tuổi.', 'tuoi', 84::int),
    (3::smallint, 'number', 'Số tự nhiên y lớn nhất thỏa mãn y + 14 < 45 là ___.', null, null, null, null, '30', null::jsonb, 'y + 14 < 45 nên y < 31; y lớn nhất là 30.', 'tim_so_hang', 82::int),
    (3::smallint, 'number', 'Số tự nhiên y lớn nhất thỏa mãn 22 + y < 32 + 47 là ___.', null, null, null, null, '56', null::jsonb, '32 + 47 = 79; 22 + y < 79 nên y < 57; y lớn nhất là 56.', 'tim_so_hang', 82::int),
    (3::smallint, 'number', 'Điền số tiếp theo của dãy: 15; 16; 18; 21; 25; ___', null, null, null, null, '30', null::jsonb, 'Các khoảng cách tăng dần 1, 2, 3, 4 nên tiếp theo cộng 5: 25 + 5 = 30.', 'day_so', 82::int),
    (3::smallint, 'number', 'Hai số liền nhau, mỗi số có một chữ số, có tổng bằng 15. Số lớn hơn là ___.', null, null, null, null, '8', null::jsonb, 'Hai số liền nhau có tổng 15 là 7 và 8; số lớn hơn là 8.', 'day_so', 82::int),
    (3::smallint, 'multiple_choice', 'Có ba mũ màu xanh, đỏ, vàng cho ba bạn Hà, Bình, An. An không đội mũ vàng. Mũ của Bình không phải màu vàng, cũng không phải màu xanh. An đội mũ màu gì?', 'Màu xanh', 'Màu đỏ', 'Màu vàng', null, 'Màu xanh', null::jsonb, 'Bình không vàng, không xanh nên Bình đội mũ đỏ; An không vàng nên An đội mũ xanh; Hà đội mũ vàng.', 'suy_luan', 83::int),
    (3::smallint, 'multiple_choice', 'Duy, Phúc, Bảo mỗi bạn thích một cầu thủ khác nhau: Xuân Trường, Quang Hải, Công Phượng. Duy thích Quang Hải. Bạn thích Xuân Trường nói chuyện với Bảo. Bảo thích cầu thủ nào?', 'Quang Hải', 'Công Phượng', 'Xuân Trường', null, 'Công Phượng', null::jsonb, 'Bạn thích Xuân Trường không phải Duy, cũng không phải Bảo nên là Phúc; vậy Bảo thích Công Phượng.', 'suy_luan', 83::int),
    (3::smallint, 'multiple_choice', 'Năm hộp quà: đỏ lớn hơn trắng; vàng lớn hơn trắng; đen nhỏ hơn đỏ; xanh lớn hơn vàng nhưng nhỏ hơn đen. Hộp lớn nhất màu gì?', 'Màu đỏ', 'Màu đen', 'Màu xanh', 'Màu vàng', 'Màu đỏ', null::jsonb, 'Sắp xếp từ lớn đến nhỏ: đỏ, đen, xanh, vàng, trắng. Hộp đỏ lớn nhất.', 'suy_luan', 83::int),
    (3::smallint, 'multiple_choice', 'Năm hộp quà: đỏ lớn hơn trắng; vàng lớn hơn trắng; đen nhỏ hơn đỏ; xanh lớn hơn vàng nhưng nhỏ hơn đen. Hộp nhỏ nhất màu gì?', 'Màu vàng', 'Màu xanh', 'Màu đen', 'Màu trắng', 'Màu trắng', null::jsonb, 'Sắp xếp từ lớn đến nhỏ: đỏ, đen, xanh, vàng, trắng. Hộp trắng nhỏ nhất.', 'suy_luan', 83::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 9 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 10: Số tròn chục trừ đi một số. 11 trừ đi một số. Tìm số hạng chưa biết trong một tổng (31 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 10, 100, 'Archimes: Số tròn chục trừ đi một số. 11 trừ đi một số. Tìm số hạng chưa biết trong một tổng', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 10', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '30 - 17 = ___', null, null, null, null, '13', null::jsonb, 'Đặt tính: 0 không trừ được 7, lấy 10 - 7 = 3, nhớ 1; 3 - 1 - 1 = 1. Kết quả 13.', 'tron_chuc_tru_mot_so', 6::int),
    (1::smallint, 'number', '70 - 49 = ___', null, null, null, null, '21', null::jsonb, '10 - 9 = 1, nhớ 1; 7 - 4 - 1 = 2. Kết quả 21.', 'tron_chuc_tru_mot_so', 6::int),
    (1::smallint, 'number', '90 - 36 = ___', null, null, null, null, '54', null::jsonb, '10 - 6 = 4, nhớ 1; 9 - 3 - 1 = 5. Kết quả 54.', 'tron_chuc_tru_mot_so', 6::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bằng 33?', '50 - 17', '40 - 19', '80 - 44', '60 - 42', '50 - 17', null::jsonb, '50 - 17 = 33; còn 40 - 19 = 21, 80 - 44 = 36, 60 - 42 = 18.', 'tron_chuc_tru_mot_so', 6::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 12 = 50
x = ___', null, null, null, null, '38', null::jsonb, 'Muốn tìm số hạng chưa biết, lấy tổng trừ số hạng đã biết: 50 - 12 = 38.', 'tim_so_hang', 6::int),
    (1::smallint, 'number', 'Tìm x, biết: 41 + x = 80
x = ___', null, null, null, null, '39', null::jsonb, 'x = 80 - 41 = 39.', 'tim_so_hang', 6::int),
    (1::smallint, 'number', '31 - 12 = ___', null, null, null, null, '19', null::jsonb, '11 - 2 = 9, nhớ 1; 3 - 1 - 1 = 1. Kết quả 19.', 'tru_dang_31_5', 8::int),
    (1::smallint, 'number', '81 - 28 = ___', null, null, null, null, '53', null::jsonb, '11 - 8 = 3, nhớ 1; 8 - 2 - 1 = 5. Kết quả 53.', 'tru_dang_31_5', 8::int),
    (1::smallint, 'multiple_choice', '91 - 54 = ?', '47', '37', '43', '145', '37', null::jsonb, '11 - 4 = 7, nhớ 1; 9 - 5 - 1 = 3. Kết quả 37.', 'tru_dang_31_5', 8::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 11 - 7 ___ 11 - 4 - 3', '>', '<', '=', null, '=', null::jsonb, '11 - 7 = 4 và 11 - 4 - 3 = 4, nên hai bên bằng nhau.', 'so_sanh', 12::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 25 = 41
x = ___', null, null, null, null, '16', null::jsonb, 'x = 41 - 25 = 16.', 'tim_so_hang', 12::int),
    (1::smallint, 'text', 'Điền từ còn thiếu: Muốn tìm số hạng chưa biết, ta lấy tổng trừ đi số hạng ___.', null, null, null, null, 'đã biết', null::jsonb, 'Số hạng chưa biết = Tổng - Số hạng đã biết.', 'tim_so_hang', 5::int),
    (2::smallint, 'number', 'Lớp 2A có 30 học sinh, trong đó có 12 học sinh nam. Lớp 2A có ___ học sinh nữ.', null, null, null, null, '18', null::jsonb, 'Số học sinh nữ là 30 - 12 = 18 bạn.', 'bai_toan_tim_so_hang', 7::int),
    (2::smallint, 'number', 'Tính: 36 + 25 - 3 = ___', null, null, null, null, '58', null::jsonb, 'Tính từ trái sang phải: 36 + 25 = 61, 61 - 3 = 58.', 'tinh_bieu_thuc', 8::int),
    (2::smallint, 'number', 'Tính: 52 + 19 - 34 = ___', null, null, null, null, '37', null::jsonb, '52 + 19 = 71, 71 - 34 = 37.', 'tinh_bieu_thuc', 8::int),
    (2::smallint, 'number', 'Tìm x, biết: 25 + x = 51 + 10
x = ___', null, null, null, null, '36', null::jsonb, '25 + x = 61 nên x = 61 - 25 = 36.', 'tim_so_hang', 8::int),
    (2::smallint, 'number', 'Một sợi dây dài 3 dm 1 cm được cắt ra một đoạn dài 7 cm. Phần sợi dây còn lại dài ___ cm.', null, null, null, null, '24', null::jsonb, '3 dm 1 cm = 31 cm; 31 - 7 = 24 cm.', 'do_dai', 9::int),
    (2::smallint, 'number', 'Mẹ có 21 quả cam. Mẹ biếu bà một số quả cam thì mẹ còn lại 4 quả. Mẹ đã biếu bà ___ quả cam.', null, null, null, null, '17', null::jsonb, 'Số cam mẹ biếu bà là 21 - 4 = 17 quả.', 'bai_toan_tim_so_hang', 9::int),
    (2::smallint, 'multiple_choice', 'Nam có một số viên bi. Minh cho Nam thêm 15 viên bi thì Nam có 41 viên. Lúc đầu Nam có bao nhiêu viên bi?', '56 viên', '36 viên', '24 viên', '26 viên', '26 viên', null::jsonb, 'Lúc đầu Nam có 41 - 15 = 26 viên bi.', 'bai_toan_tim_so_hang', 9::int),
    (2::smallint, 'number', 'Minh có 28 viên bi. Tân có nhiều hơn Minh 7 viên bi. Tân có ___ viên bi.', null, null, null, null, '35', null::jsonb, 'Tân có 28 + 7 = 35 viên bi.', 'bai_toan_nhieu_hon', 12::int),
    (2::smallint, 'multiple_choice', 'Một đàn gia cầm có 40 con gồm gà, ngan và vịt. Tổng số gà và ngan là 21 con. Đàn có bao nhiêu con vịt?', '19 con', '61 con', '29 con', '21 con', '19 con', null::jsonb, 'Số vịt là 40 - 21 = 19 con.', 'bai_toan_tim_so_hang', 12::int),
    (2::smallint, 'number', 'Tính bằng cách hợp lý: 12 + 23 + 28 + 37 = ___', null, null, null, null, '100', null::jsonb, '(12 + 28) + (23 + 37) = 40 + 60 = 100.', 'tinh_hop_ly', 10::int),
    (3::smallint, 'number', 'Tìm x, biết: x + 13 + 10 = 30
x = ___', null, null, null, null, '7', null::jsonb, 'x + 23 = 30 nên x = 30 - 23 = 7.', 'tim_so_hang', 6::int),
    (3::smallint, 'number', 'Một cửa hàng có 80 hộp bánh. Buổi sáng bán được 30 hộp. Buổi chiều bán được nhiều hơn buổi sáng 8 hộp. Cuối ngày cửa hàng còn lại ___ hộp bánh.', null, null, null, null, '12', null::jsonb, 'Buổi chiều bán 30 + 8 = 38 hộp; còn lại 80 - 30 - 38 = 12 hộp.', 'bai_toan_hai_buoc', 7::int),
    (3::smallint, 'number', 'Ngăn thứ nhất có 41 hộp bút và nhiều hơn ngăn thứ hai 7 hộp. Cả hai ngăn có tất cả ___ hộp bút.', null, null, null, null, '75', null::jsonb, 'Ngăn thứ hai có 41 - 7 = 34 hộp; cả hai ngăn có 41 + 34 = 75 hộp.', 'bai_toan_hai_buoc', 9::int),
    (3::smallint, 'number', 'Tìm số tự nhiên x, biết: 49 < 28 + x < 51
x = ___', null, null, null, null, '22', null::jsonb, 'Số nằm giữa 49 và 51 là 50, nên 28 + x = 50, x = 22.', 'tim_x_nang_cao', 10::int),
    (3::smallint, 'number', 'Tìm số tự nhiên x lớn nhất, biết: x + 27 < 79
x = ___', null, null, null, null, '51', null::jsonb, 'x + 27 lớn nhất bằng 78, nên x = 78 - 27 = 51.', 'tim_x_nang_cao', 11::int),
    (3::smallint, 'number', 'Nam có 35 viên bi. Hùng có ít hơn Nam 4 viên bi và nhiều hơn Bảo 5 viên bi. Cả ba bạn có ___ viên bi.', null, null, null, null, '92', null::jsonb, 'Hùng có 31 viên, Bảo có 26 viên; cả ba có 35 + 31 + 26 = 92 viên.', 'bai_toan_nhieu_buoc', 11::int),
    (3::smallint, 'number', 'Từ các chữ số 0; 1; 3; 7 viết các số có hai chữ số khác nhau. Hiệu của số tròn chục lớn nhất và số nhỏ nhất trong các số đó là ___', null, null, null, null, '60', null::jsonb, 'Số tròn chục lớn nhất là 70, số nhỏ nhất là 10; 70 - 10 = 60.', 'cau_tao_so', 11::int),
    (3::smallint, 'multiple_choice', 'Số tiếp theo của dãy số 1; 2; 4; 7; 11; 16; ... là:', '21', '23', '22', '20', '22', null::jsonb, 'Các số lần lượt tăng thêm 1, 2, 3, 4, 5 nên số tiếp theo là 16 + 6 = 22.', 'day_so_quy_luat', 12::int),
    (3::smallint, 'number', 'Tổng của hai số có hai chữ số là 81. Số thứ nhất là số nhỏ nhất có tổng hai chữ số bằng 8. Số thứ hai là ___', null, null, null, null, '64', null::jsonb, 'Số nhỏ nhất có tổng hai chữ số bằng 8 là 17; số thứ hai là 81 - 17 = 64.', 'cau_tao_so', 13::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 10 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 11: 12 trừ đi một số. Phép trừ dạng 32 - 8; 52 - 28 (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 11, 100, 'Archimes: 12 trừ đi một số. Phép trừ dạng 32 - 8; 52 - 28', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 11', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '12 - 5 = ___', null, null, null, null, '7', null::jsonb, '12 - 2 = 10, 10 - 3 = 7.', 'tru_dang_12', 14::int),
    (1::smallint, 'number', '32 - 15 = ___', null, null, null, null, '17', null::jsonb, '12 - 5 = 7, nhớ 1; 3 - 1 - 1 = 1. Kết quả 17.', 'tru_dang_32_8', 15::int),
    (1::smallint, 'number', '42 - 28 = ___', null, null, null, null, '14', null::jsonb, '12 - 8 = 4, nhớ 1; 4 - 2 - 1 = 1. Kết quả 14.', 'tru_dang_32_8', 15::int),
    (1::smallint, 'number', '72 - 37 = ___', null, null, null, null, '35', null::jsonb, '12 - 7 = 5, nhớ 1; 7 - 3 - 1 = 3. Kết quả 35.', 'tru_dang_32_8', 15::int),
    (1::smallint, 'multiple_choice', '92 - 43 = ?', '59', '49', '51', '135', '49', null::jsonb, '12 - 3 = 9, nhớ 1; 9 - 4 - 1 = 4. Kết quả 49.', 'tru_dang_32_8', 15::int),
    (1::smallint, 'number', 'Tìm y, biết: y + 24 = 62
y = ___', null, null, null, null, '38', null::jsonb, 'y = 62 - 24 = 38.', 'tim_so_hang', 15::int),
    (1::smallint, 'number', 'Tính: 41 - 2 - 8 = ___', null, null, null, null, '31', null::jsonb, '41 - 2 - 8 = 41 - 10 = 31.', 'tinh_bieu_thuc', 19::int),
    (1::smallint, 'number', '82 - 34 = ___', null, null, null, null, '48', null::jsonb, '12 - 4 = 8, nhớ 1; 8 - 3 - 1 = 4. Kết quả 48.', 'tru_dang_32_8', 17::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 20 + 44 ___ 39 + 25', '>', '<', '=', null, '=', null::jsonb, '20 + 44 = 64 và 39 + 25 = 64.', 'so_sanh', 17::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 51 - 14 ___ 14 + 20', '>', '<', '=', null, '>', null::jsonb, '51 - 14 = 37, 14 + 20 = 34, mà 37 > 34.', 'so_sanh', 17::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 80 - 16 ___ 72 - 6', '>', '<', '=', null, '<', null::jsonb, '80 - 16 = 64, 72 - 6 = 66, mà 64 < 66.', 'so_sanh', 17::int),
    (1::smallint, 'number', 'Tổng của hai số là 82, số thứ nhất là 54. Số thứ hai là ___', null, null, null, null, '28', null::jsonb, 'Số thứ hai = 82 - 54 = 28.', 'tim_so_hang', 21::int),
    (1::smallint, 'number', 'Trong một phép cộng hai số, nếu tổng bằng một số hạng thì số hạng còn lại là ___', null, null, null, null, '0', null::jsonb, 'Số nào cộng với 0 cũng bằng chính nó, nên số hạng còn lại là 0.', 'tim_so_hang', 21::int),
    (1::smallint, 'text', 'Trong phép cộng 38 + 24 = 62, số 62 được gọi là ___', null, null, null, null, 'tổng', null::jsonb, 'Trong phép cộng, 38 và 24 là số hạng, 62 là tổng.', 'thanh_phan_phep_tinh', 14::int),
    (2::smallint, 'number', 'Điền số thích hợp: ___ + 25 = 19 + 53', null, null, null, null, '47', null::jsonb, '19 + 53 = 72, số cần điền là 72 - 25 = 47.', 'tim_so_hang', 21::int),
    (2::smallint, 'number', 'Nam có 42 viên bi, Nam cho Dũng 14 viên bi. Nam còn lại ___ viên bi.', null, null, null, null, '28', null::jsonb, 'Nam còn lại 42 - 14 = 28 viên bi.', 'bai_toan_mot_buoc', 15::int),
    (2::smallint, 'number', 'Bố hơn con 29 tuổi. Hiện nay bố 42 tuổi. Tuổi con hiện nay là ___ tuổi.', null, null, null, null, '13', null::jsonb, 'Tuổi con là 42 - 29 = 13 tuổi.', 'bai_toan_tuoi', 15::int),
    (2::smallint, 'number', 'Tìm y, biết: y + 34 = 53 + 19
y = ___', null, null, null, null, '38', null::jsonb, '53 + 19 = 72, y = 72 - 34 = 38.', 'tim_so_hang', 15::int),
    (2::smallint, 'number', 'Hai can dầu chứa tất cả 72 l dầu, can thứ nhất chứa 33 l dầu. Can thứ hai chứa ___ l dầu.', null, null, null, null, '39', null::jsonb, 'Can thứ hai chứa 72 - 33 = 39 l dầu.', 'bai_toan_tim_so_hang', 21::int),
    (2::smallint, 'multiple_choice', 'Túi gạo tẻ nặng 32 kg và nặng hơn túi gạo nếp 14 kg. Túi gạo nếp nặng bao nhiêu ki-lô-gam?', '46 kg', '28 kg', '22 kg', '18 kg', '18 kg', null::jsonb, 'Túi gạo nếp nhẹ hơn nên lấy 32 - 14 = 18 kg.', 'bai_toan_it_hon', 21::int),
    (2::smallint, 'number', 'Tổng của hai số bằng 52, số thứ nhất là số chẵn lớn nhất có một chữ số. Số thứ hai là ___', null, null, null, null, '44', null::jsonb, 'Số chẵn lớn nhất có một chữ số là 8; số thứ hai là 52 - 8 = 44.', 'tim_so_hang', 16::int),
    (2::smallint, 'number', 'Bạn Hùng nặng hơn bạn Nam 6 kg, bạn Nam nặng hơn bạn Lan 2 kg. Bạn Hùng nặng hơn bạn Lan ___ kg.', null, null, null, null, '8', null::jsonb, 'Hùng hơn Nam 6 kg, Nam hơn Lan 2 kg nên Hùng hơn Lan 6 + 2 = 8 kg.', 'bai_toan_nhieu_hon', 16::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 32 - 3 ___ 42 - 27 + 14', '>', '<', '=', null, '=', null::jsonb, '32 - 3 = 29; 42 - 27 + 14 = 15 + 14 = 29.', 'so_sanh', 17::int),
    (2::smallint, 'number', 'Hiện nay mẹ 42 tuổi. Lúc mẹ sinh con, mẹ 27 tuổi. Tuổi con hiện nay là ___ tuổi.', null, null, null, null, '15', null::jsonb, 'Mẹ hơn con 27 tuổi, nên con 42 - 27 = 15 tuổi.', 'bai_toan_tuoi', 20::int),
    (3::smallint, 'number', 'Tổng của hai số bằng 62, số thứ nhất là số nhỏ nhất có hai chữ số mà tổng hai chữ số bằng 6. Số thứ hai là ___', null, null, null, null, '47', null::jsonb, 'Số thứ nhất là 15; số thứ hai là 62 - 15 = 47.', 'cau_tao_so', 16::int),
    (3::smallint, 'number', 'Một kho hàng có 42 bộ bàn ghế. Buổi sáng chuyển đi 16 bộ, buổi chiều chuyển tiếp đi 18 bộ. Kho hàng còn lại ___ bộ bàn ghế.', null, null, null, null, '8', null::jsonb, '42 - 16 = 26, 26 - 18 = 8 bộ (hoặc 42 - 34 = 8).', 'bai_toan_hai_buoc', 17::int),
    (3::smallint, 'number', 'Lớp 2A có 32 học sinh và nhiều hơn lớp 2B 4 học sinh. Lớp 2B nhiều hơn lớp 2C 5 học sinh. Lớp 2C có ___ học sinh.', null, null, null, null, '23', null::jsonb, 'Lớp 2B có 32 - 4 = 28 bạn; lớp 2C có 28 - 5 = 23 bạn.', 'bai_toan_hai_buoc', 18::int),
    (3::smallint, 'number', 'Ba lớp 2A, 2B, 2C có 96 học sinh. Lớp 2A và 2B có 61 học sinh, lớp 2B và 2C có 67 học sinh. Lớp 2B có ___ học sinh.', null, null, null, null, '32', null::jsonb, 'Lớp 2C có 96 - 61 = 35 bạn; lớp 2B có 67 - 35 = 32 bạn.', 'bai_toan_nhieu_buoc', 18::int),
    (3::smallint, 'number', 'Ba bạn Nam, Mai, Hoa có tất cả 42 cái kẹo. Nam và Mai có 27 cái. Nam nhiều hơn Hoa 2 cái. Mai có ___ cái kẹo.', null, null, null, null, '10', null::jsonb, 'Hoa có 42 - 27 = 15 cái, Nam có 15 + 2 = 17 cái, Mai có 27 - 17 = 10 cái.', 'bai_toan_nhieu_buoc', 18::int),
    (3::smallint, 'number', 'Hiện nay tổng số tuổi của Lan và Mai là 22 tuổi. 2 năm trước, tổng số tuổi của hai bạn là ___ tuổi.', null, null, null, null, '18', null::jsonb, 'Mỗi bạn kém đi 2 tuổi nên tổng kém đi 4 tuổi: 22 - 4 = 18.', 'bai_toan_tuoi', 19::int),
    (3::smallint, 'number', 'Hiện nay bố 38 tuổi, con 4 tuổi. Khi con 12 tuổi thì bố ___ tuổi.', null, null, null, null, '46', null::jsonb, 'Sau 12 - 4 = 8 năm con 12 tuổi, bố thêm 8 tuổi: 38 + 8 = 46.', 'bai_toan_tuoi', 20::int),
    (3::smallint, 'number', 'Hiện nay anh 14 tuổi, em 8 tuổi. Sau ___ năm nữa thì tổng số tuổi của hai anh em là 30 tuổi.', null, null, null, null, '4', null::jsonb, 'Hiện tổng là 22 tuổi, cần thêm 8; mỗi năm tổng tăng 2 tuổi nên cần 4 năm.', 'bai_toan_tuoi', 20::int),
    (3::smallint, 'number', 'Trong các số có hai chữ số mà chữ số hàng chục trừ chữ số hàng đơn vị bằng 4, số lớn nhất là ___', null, null, null, null, '95', null::jsonb, 'Các số đó là 40, 51, 62, 73, 84, 95; số lớn nhất là 95.', 'cau_tao_so', 22::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 11 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 12: Số bị trừ. 13 trừ đi một số. Phép trừ dạng 33 - 5; 53 - 15 (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 12, 100, 'Archimes: Số bị trừ. 13 trừ đi một số. Phép trừ dạng 33 - 5; 53 - 15', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 12', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Tìm x, biết: x - 14 = 46
x = ___', null, null, null, null, '60', null::jsonb, 'Muốn tìm số bị trừ, lấy hiệu cộng số trừ: 46 + 14 = 60.', 'tim_so_bi_tru', 24::int),
    (1::smallint, 'number', 'Tìm x, biết: x - 45 = 55
x = ___', null, null, null, null, '100', null::jsonb, 'x = 55 + 45 = 100.', 'tim_so_bi_tru', 24::int),
    (1::smallint, 'text', 'Điền từ còn thiếu: Muốn tìm số bị trừ, ta lấy hiệu cộng với số ___.', null, null, null, null, 'trừ', null::jsonb, 'Số bị trừ = Hiệu + Số trừ.', 'tim_so_bi_tru', 23::int),
    (1::smallint, 'number', '13 - 6 = ___', null, null, null, null, '7', null::jsonb, '13 - 3 = 10, 10 - 3 = 7.', 'tru_dang_13', 23::int),
    (1::smallint, 'number', '43 - 19 = ___', null, null, null, null, '24', null::jsonb, '13 - 9 = 4, nhớ 1; 4 - 1 - 1 = 2. Kết quả 24.', 'tru_dang_33_5', 26::int),
    (1::smallint, 'number', '63 - 27 = ___', null, null, null, null, '36', null::jsonb, '13 - 7 = 6, nhớ 1; 6 - 2 - 1 = 3. Kết quả 36.', 'tru_dang_33_5', 26::int),
    (1::smallint, 'number', '83 - 46 = ___', null, null, null, null, '37', null::jsonb, '13 - 6 = 7, nhớ 1; 8 - 4 - 1 = 3. Kết quả 37.', 'tru_dang_33_5', 26::int),
    (1::smallint, 'multiple_choice', '93 - 58 = ?', '45', '35', '25', '151', '35', null::jsonb, '13 - 8 = 5, nhớ 1; 9 - 5 - 1 = 3. Kết quả 35.', 'tru_dang_33_5', 26::int),
    (1::smallint, 'number', 'Trong một phép trừ, số trừ là 19, hiệu là 64. Số bị trừ là ___', null, null, null, null, '83', null::jsonb, 'Số bị trừ = 64 + 19 = 83.', 'tim_so_bi_tru', 24::int),
    (1::smallint, 'number', 'Tính: 35 + 18 - 29 = ___', null, null, null, null, '24', null::jsonb, '35 + 18 = 53, 53 - 29 = 24.', 'tinh_bieu_thuc', 30::int),
    (1::smallint, 'number', 'Tính: 33 l + 5 l + 16 l = ___ l', null, null, null, null, '54', null::jsonb, '33 + 5 = 38, 38 + 16 = 54 (lít).', 'don_vi_lit', 30::int),
    (1::smallint, 'number', 'Tìm x, biết: x - 63 = 18
x = ___', null, null, null, null, '81', null::jsonb, 'x = 18 + 63 = 81.', 'tim_so_bi_tru', 30::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 51 - 17 ___ 14 + 18', '>', '<', '=', null, '>', null::jsonb, '51 - 17 = 34, 14 + 18 = 32, mà 34 > 32.', 'so_sanh', 31::int),
    (2::smallint, 'number', 'Tìm x, biết: x - 28 = 72 - 28
x = ___', null, null, null, null, '72', null::jsonb, '72 - 28 = 44, x = 44 + 28 = 72.', 'tim_so_bi_tru', 24::int),
    (2::smallint, 'number', 'Cô giáo có một số ngôi sao. Cô thưởng 18 ngôi sao cho các bạn học tốt thì còn lại 50 ngôi sao. Lúc đầu cô có ___ ngôi sao.', null, null, null, null, '68', null::jsonb, 'Lúc đầu cô có 50 + 18 = 68 ngôi sao.', 'bai_toan_tim_so_bi_tru', 24::int),
    (2::smallint, 'number', 'Lớp 2A nhận được tất cả 43 sao, trong đó có 8 sao về nề nếp, còn lại là sao về học tập. Lớp 2A có ___ sao về học tập.', null, null, null, null, '35', null::jsonb, 'Số sao về học tập là 43 - 8 = 35 sao.', 'bai_toan_mot_buoc', 26::int),
    (2::smallint, 'number', 'Trong một phép trừ có hiệu là 20. Nếu tăng số bị trừ thêm 14 đơn vị và giữ nguyên số trừ thì hiệu mới là ___', null, null, null, null, '34', null::jsonb, 'Số bị trừ tăng bao nhiêu thì hiệu tăng bấy nhiêu: 20 + 14 = 34.', 'quan_he_phep_tru', 28::int),
    (2::smallint, 'number', 'Trong một phép trừ có hiệu là 35. Nếu giảm số bị trừ đi 15 đơn vị và giữ nguyên số trừ thì hiệu mới là ___', null, null, null, null, '20', null::jsonb, 'Số bị trừ giảm bao nhiêu thì hiệu giảm bấy nhiêu: 35 - 15 = 20.', 'quan_he_phep_tru', 28::int),
    (2::smallint, 'multiple_choice', 'Trong một phép trừ có hiệu là 62. Nếu tăng số trừ thêm 4 đơn vị và giữ nguyên số bị trừ thì hiệu mới là:', '66', '62', '58', '54', '58', null::jsonb, 'Số trừ tăng bao nhiêu thì hiệu giảm bấy nhiêu: 62 - 4 = 58.', 'quan_he_phep_tru', 28::int),
    (2::smallint, 'number', 'Trong một phép trừ có hiệu là 16 (số trừ lớn hơn 5). Nếu giảm số trừ đi 5 đơn vị và giữ nguyên số bị trừ thì hiệu mới là ___', null, null, null, null, '21', null::jsonb, 'Số trừ giảm bao nhiêu thì hiệu tăng bấy nhiêu: 16 + 5 = 21.', 'quan_he_phep_tru', 28::int),
    (2::smallint, 'number', 'Tính: 95 - 52 - 15 = ___', null, null, null, null, '28', null::jsonb, '95 - 52 = 43, 43 - 15 = 28.', 'tinh_bieu_thuc', 26::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 52 - 15 ___ 45 + 36 - 17', '>', '<', '=', null, '<', null::jsonb, '52 - 15 = 37; 45 + 36 - 17 = 81 - 17 = 64, mà 37 < 64.', 'so_sanh', 31::int),
    (2::smallint, 'number', 'Tìm x, biết: x - 28 = 18 + 29
x = ___', null, null, null, null, '75', null::jsonb, '18 + 29 = 47, x = 47 + 28 = 75.', 'tim_so_bi_tru', 31::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó trừ đi 23 rồi trừ tiếp đi 5 thì được 39. Số đó là ___', null, null, null, null, '67', null::jsonb, 'Làm ngược lại: 39 + 5 = 44, 44 + 23 = 67.', 'tim_so_bi_tru', 24::int),
    (3::smallint, 'number', 'Tìm số bị trừ, biết hiệu là số chẵn lớn nhất có hai chữ số và số trừ là số nhỏ nhất có một chữ số. Số bị trừ là ___', null, null, null, null, '98', null::jsonb, 'Hiệu là 98, số trừ là 0; số bị trừ là 98 + 0 = 98.', 'tim_so_bi_tru', 25::int),
    (3::smallint, 'number', 'An và Bình có tất cả 32 chiếc bút chì. Nếu An cho Bình 5 chiếc thì An còn lại 14 chiếc. Lúc đầu Bình có ___ chiếc bút chì.', null, null, null, null, '13', null::jsonb, 'Lúc đầu An có 14 + 5 = 19 chiếc; Bình có 32 - 19 = 13 chiếc.', 'bai_toan_nhieu_buoc', 25::int),
    (3::smallint, 'number', 'Huệ tặng Hà 42 ngôi sao và tặng Lan ít hơn Hà 13 ngôi sao thì Huệ còn lại 14 ngôi sao. Lúc đầu Huệ gấp được ___ ngôi sao.', null, null, null, null, '85', null::jsonb, 'Lan được 42 - 13 = 29 ngôi sao; lúc đầu Huệ có 42 + 29 + 14 = 85 ngôi sao.', 'bai_toan_nhieu_buoc', 25::int),
    (3::smallint, 'number', 'Bao thứ nhất chứa 33 kg đường. Bao thứ hai chứa ít hơn bao thứ nhất 7 kg và ít hơn bao thứ ba 15 kg. Cả ba bao chứa ___ kg đường.', null, null, null, null, '100', null::jsonb, 'Bao hai: 26 kg, bao ba: 26 + 15 = 41 kg; cả ba: 33 + 26 + 41 = 100 kg.', 'bai_toan_nhieu_buoc', 27::int),
    (3::smallint, 'multiple_choice', 'Có ba bao gạo. Bao thứ nhất nhẹ hơn bao thứ hai 2 kg, bao thứ ba nặng hơn bao thứ hai 3 kg. Bao nặng nhất nặng hơn bao nhẹ nhất bao nhiêu ki-lô-gam?', '1 kg', '3 kg', '2 kg', '5 kg', '5 kg', null::jsonb, 'Bao ba nặng nhất, bao một nhẹ nhất; bao ba hơn bao một 3 + 2 = 5 kg.', 'bai_toan_so_do', 27::int),
    (3::smallint, 'number', 'Trong một phép trừ có hiệu là 41 (số trừ lớn hơn 11). Nếu tăng số bị trừ thêm 8 đơn vị và giảm số trừ đi 11 đơn vị thì hiệu mới là ___', null, null, null, null, '60', null::jsonb, 'Tăng số bị trừ 8 thì hiệu tăng 8; giảm số trừ 11 thì hiệu tăng 11: 41 + 8 + 11 = 60.', 'quan_he_phep_tru', 29::int),
    (3::smallint, 'multiple_choice', 'An cho Bình 9 viên bi, sau đó Bình cho lại An 5 viên bi thì Bình còn 18 viên bi. Lúc đầu Bình có bao nhiêu viên bi?', '14 viên', '22 viên', '32 viên', '4 viên', '14 viên', null::jsonb, 'Bình nhận 9 viên rồi cho lại 5 viên, tức là nhiều thêm 4 viên; lúc đầu Bình có 18 - 4 = 14 viên.', 'bai_toan_nhieu_buoc', 30::int),
    (3::smallint, 'number', 'Khi ông 60 tuổi thì mẹ 30 tuổi. Hiện nay mẹ 35 tuổi. Tuổi ông hiện nay là ___ tuổi.', null, null, null, null, '65', null::jsonb, 'Đã qua 35 - 30 = 5 năm, ông cũng thêm 5 tuổi: 60 + 5 = 65.', 'bai_toan_tuoi', 30::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 12 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 13: 14 trừ đi một số. 15, 16, 17, 18 trừ đi một số (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 13, 100, 'Archimes: 14 trừ đi một số. 15, 16, 17, 18 trừ đi một số', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 13', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '14 - 8 = ___', null, null, null, null, '6', null::jsonb, '14 - 4 = 10, 10 - 4 = 6.', 'tru_dang_14', 32::int),
    (1::smallint, 'number', '17 - 9 = ___', null, null, null, null, '8', null::jsonb, '17 - 7 = 10, 10 - 2 = 8.', 'tru_dang_15_18', 32::int),
    (1::smallint, 'number', '34 - 19 = ___', null, null, null, null, '15', null::jsonb, '14 - 9 = 5, nhớ 1; 3 - 1 - 1 = 1. Kết quả 15.', 'tru_dang_34_8', 33::int),
    (1::smallint, 'number', '54 - 26 = ___', null, null, null, null, '28', null::jsonb, '14 - 6 = 8, nhớ 1; 5 - 2 - 1 = 2. Kết quả 28.', 'tru_dang_34_8', 33::int),
    (1::smallint, 'number', '64 - 37 = ___', null, null, null, null, '27', null::jsonb, '14 - 7 = 7, nhớ 1; 6 - 3 - 1 = 2. Kết quả 27.', 'tru_dang_34_8', 33::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bằng 16?', '94 - 19', '44 - 28', '54 - 17', '64 - 25', '44 - 28', null::jsonb, '44 - 28 = 16; còn 94 - 19 = 75, 54 - 17 = 37, 64 - 25 = 39.', 'tru_dang_34_8', 33::int),
    (1::smallint, 'number', '84 - 38 = ___', null, null, null, null, '46', null::jsonb, '14 - 8 = 6, nhớ 1; 8 - 3 - 1 = 4. Kết quả 46.', 'tru_dang_34_8', 35::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 18 = 72
x = ___', null, null, null, null, '54', null::jsonb, 'x = 72 - 18 = 54.', 'tim_so_hang', 35::int),
    (1::smallint, 'number', 'Tìm x, biết: x - 12 = 54
x = ___', null, null, null, null, '66', null::jsonb, 'x = 54 + 12 = 66.', 'tim_so_bi_tru', 35::int),
    (1::smallint, 'number', 'Tính: 37 + 25 - 48 = ___', null, null, null, null, '14', null::jsonb, '37 + 25 = 62, 62 - 48 = 14.', 'tinh_bieu_thuc', 39::int),
    (1::smallint, 'number', '81 - 9 = ___', null, null, null, null, '72', null::jsonb, '11 - 9 = 2, nhớ 1; 8 - 1 = 7. Kết quả 72.', 'tru_co_nho', 39::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bé nhất?', '15 - 8', '16 - 7', '17 - 8', '18 - 9', '15 - 8', null::jsonb, '15 - 8 = 7, còn 16 - 7, 17 - 8, 18 - 9 đều bằng 9.', 'tru_dang_15_18', 32::int),
    (1::smallint, 'text', 'Trong phép trừ 54 - 26 = 28, số 28 được gọi là ___', null, null, null, null, 'hiệu', null::jsonb, 'Trong phép trừ, 54 là số bị trừ, 26 là số trừ, 28 là hiệu.', 'thanh_phan_phep_tinh', 33::int),
    (2::smallint, 'number', 'Thùng thứ nhất đựng 54 l nước và nhiều hơn thùng thứ hai 9 l. Thùng thứ hai đựng ___ l nước.', null, null, null, null, '45', null::jsonb, 'Thùng thứ hai ít hơn nên lấy 54 - 9 = 45 l.', 'bai_toan_it_hon', 33::int),
    (2::smallint, 'number', 'Mẹ mang ra chợ bán 42 quả trứng. Mẹ đã bán được 18 quả. Mẹ còn lại ___ quả trứng.', null, null, null, null, '24', null::jsonb, 'Mẹ còn lại 42 - 18 = 24 quả trứng.', 'bai_toan_mot_buoc', 39::int),
    (2::smallint, 'number', 'Lớp 2A có 24 học sinh nữ, số học sinh nữ nhiều hơn số học sinh nam 7 bạn. Lớp 2A có ___ học sinh nam.', null, null, null, null, '17', null::jsonb, 'Số học sinh nam ít hơn: 24 - 7 = 17 bạn.', 'bai_toan_it_hon', 39::int),
    (2::smallint, 'number', 'Tìm x, biết: x + 18 = 49 + 17
x = ___', null, null, null, null, '48', null::jsonb, '49 + 17 = 66, x = 66 - 18 = 48.', 'tim_so_hang', 39::int),
    (2::smallint, 'number', 'Tìm một số, biết tổng của số đó với 42 là số chẵn lớn nhất có hai chữ số. Số đó là ___', null, null, null, null, '56', null::jsonb, 'Số chẵn lớn nhất có hai chữ số là 98; số cần tìm là 98 - 42 = 56.', 'tim_so_hang', 39::int),
    (2::smallint, 'number', 'Tìm một số, biết hiệu của 94 với số đó là 49. Số đó là ___', null, null, null, null, '45', null::jsonb, '94 - ? = 49 nên số đó là 94 - 49 = 45.', 'tim_so_tru', 39::int),
    (2::smallint, 'multiple_choice', 'Hai số có tổng là 74, số thứ hai là số liền sau của 37. Số thứ nhất là:', '37', '38', '36', '35', '36', null::jsonb, 'Số thứ hai là 38; số thứ nhất là 74 - 38 = 36.', 'tim_so_hang', 39::int),
    (2::smallint, 'number', 'Hiệu của hai số là 53. Nếu số bị trừ giảm đi 19 đơn vị và giữ nguyên số trừ thì hiệu mới là ___', null, null, null, null, '34', null::jsonb, 'Số bị trừ giảm 19 thì hiệu giảm 19: 53 - 19 = 34.', 'quan_he_phep_tru', 39::int),
    (2::smallint, 'number', 'Tìm x, biết: x + 18 = 72 + 12
x = ___', null, null, null, null, '66', null::jsonb, '72 + 12 = 84, x = 84 - 18 = 66.', 'tim_so_hang', 35::int),
    (2::smallint, 'number', 'Tìm số tự nhiên x, biết: 36 < x + 4 < 38
x = ___', null, null, null, null, '33', null::jsonb, 'Số nằm giữa 36 và 38 là 37, nên x + 4 = 37, x = 33.', 'tim_x_nang_cao', 40::int),
    (3::smallint, 'number', 'Bạn Ngọc nặng 28 kg. Ngọc bế 2 chú mèo nặng bằng nhau đứng lên cân thì cân chỉ 36 kg. Mỗi chú mèo nặng ___ kg.', null, null, null, null, '4', null::jsonb, 'Hai chú mèo nặng 36 - 28 = 8 kg; 4 + 4 = 8 nên mỗi chú nặng 4 kg.', 'can_dong_do', 32::int),
    (3::smallint, 'multiple_choice', 'Lớp 2D có 32 học sinh, trong đó có 13 học sinh nữ. Câu nào đúng?', 'Nữ nhiều hơn nam 6 bạn', 'Nam nhiều hơn nữ 19 bạn', 'Nam nhiều hơn nữ 13 bạn', 'Nam nhiều hơn nữ 6 bạn', 'Nam nhiều hơn nữ 6 bạn', null::jsonb, 'Số nam là 32 - 13 = 19 bạn; 19 - 13 = 6, nên nam nhiều hơn nữ 6 bạn.', 'bai_toan_hai_buoc', 34::int),
    (3::smallint, 'number', 'Tìm x, biết: x - 34 - 12 = 54
x = ___', null, null, null, null, '100', null::jsonb, 'x - 34 = 54 + 12 = 66, x = 66 + 34 = 100.', 'tim_so_bi_tru', 35::int),
    (3::smallint, 'number', 'Ba thùng có tất cả 64 l dầu. Thùng thứ nhất và thùng thứ hai có 48 l. Thùng thứ ba ít hơn thùng thứ hai 9 l. Thùng thứ nhất có ___ l dầu.', null, null, null, null, '23', null::jsonb, 'Thùng ba: 64 - 48 = 16 l; thùng hai: 16 + 9 = 25 l; thùng một: 48 - 25 = 23 l.', 'bai_toan_nhieu_buoc', 35::int),
    (3::smallint, 'number', 'Ba khối Một, Hai, Ba trồng được 96 cây. Khối Một và khối Hai trồng được 62 cây. Khối Ba trồng nhiều hơn khối Hai 5 cây. Khối Hai trồng được ___ cây.', null, null, null, null, '29', null::jsonb, 'Khối Ba trồng 96 - 62 = 34 cây; khối Hai trồng 34 - 5 = 29 cây.', 'bai_toan_nhieu_buoc', 36::int),
    (3::smallint, 'number', 'Tìm số tự nhiên y nhỏ nhất, biết: 23 + y > 49
y = ___', null, null, null, null, '27', null::jsonb, '23 + y nhỏ nhất là 50, nên y = 50 - 23 = 27.', 'tim_x_nang_cao', 37::int),
    (3::smallint, 'number', 'Trong một phép trừ, nếu tăng số bị trừ thêm 14 đơn vị và giảm số trừ đi 9 đơn vị thì hiệu mới bằng 55. Hiệu ban đầu là ___', null, null, null, null, '32', null::jsonb, 'Hiệu mới lớn hơn hiệu cũ 14 + 9 = 23 đơn vị; hiệu cũ là 55 - 23 = 32.', 'quan_he_phep_tru', 38::int),
    (3::smallint, 'multiple_choice', 'An có nhiều hơn Linh 12 quyển truyện. An mua thêm 8 quyển, Linh mua thêm 15 quyển. Lúc này:', 'Linh nhiều hơn An 5 quyển', 'An nhiều hơn Linh 19 quyển', 'An nhiều hơn Linh 5 quyển', 'Linh nhiều hơn An 3 quyển', 'An nhiều hơn Linh 5 quyển', null::jsonb, 'Linh mua nhiều hơn An 15 - 8 = 7 quyển, nên An còn hơn Linh 12 - 7 = 5 quyển.', 'bai_toan_suy_luan', 38::int),
    (3::smallint, 'number', 'Duy có 24 thẻ bài. Sơn có ít hơn Duy 7 thẻ nhưng nhiều hơn Hiếu 8 thẻ. Ba bạn có tất cả ___ thẻ bài.', null, null, null, null, '50', null::jsonb, 'Sơn có 17 thẻ, Hiếu có 9 thẻ; cả ba có 24 + 17 + 9 = 50 thẻ.', 'bai_toan_nhieu_buoc', 40::int),
    (3::smallint, 'number', 'Tìm x, biết: 77 < x - 18 < 79
x = ___', null, null, null, null, '96', null::jsonb, 'Số nằm giữa 77 và 79 là 78, nên x - 18 = 78, x = 96.', 'tim_x_nang_cao', 40::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 13 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 14: Phép trừ dạng 55 - 8; 65 - 38. Bảng trừ (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 14, 100, 'Archimes: Phép trừ dạng 55 - 8; 65 - 38. Bảng trừ', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 14', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '25 - 16 = ___', null, null, null, null, '9', null::jsonb, '15 - 6 = 9, nhớ 1; 2 - 1 - 1 = 0. Kết quả 9.', 'tru_dang_55_8', 42::int),
    (1::smallint, 'number', '36 - 19 = ___', null, null, null, null, '17', null::jsonb, '16 - 9 = 7, nhớ 1; 3 - 1 - 1 = 1. Kết quả 17.', 'tru_dang_55_8', 42::int),
    (1::smallint, 'number', '57 - 28 = ___', null, null, null, null, '29', null::jsonb, '17 - 8 = 9, nhớ 1; 5 - 2 - 1 = 2. Kết quả 29.', 'tru_dang_55_8', 42::int),
    (1::smallint, 'number', '68 - 29 = ___', null, null, null, null, '39', null::jsonb, '18 - 9 = 9, nhớ 1; 6 - 2 - 1 = 3. Kết quả 39.', 'tru_dang_55_8', 42::int),
    (1::smallint, 'multiple_choice', '44 - 38 = ?', '14', '16', '6', '82', '6', null::jsonb, '14 - 8 = 6, nhớ 1; 4 - 3 - 1 = 0. Kết quả 6.', 'tru_dang_55_8', 42::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 9 = 37
x = ___', null, null, null, null, '28', null::jsonb, 'x = 37 - 9 = 28.', 'tim_so_hang', 42::int),
    (1::smallint, 'number', 'Tìm x, biết: x - 27 = 45
x = ___', null, null, null, null, '72', null::jsonb, 'x = 45 + 27 = 72.', 'tim_so_bi_tru', 42::int),
    (1::smallint, 'number', 'Tính: 67 - 18 + 20 = ___', null, null, null, null, '69', null::jsonb, '67 - 18 = 49, 49 + 20 = 69.', 'tinh_bieu_thuc', 42::int),
    (1::smallint, 'number', '98 dm - 53 dm - 16 dm = ___ dm', null, null, null, null, '29', null::jsonb, '98 - 53 = 45, 45 - 16 = 29 (dm).', 'do_dai', 42::int),
    (1::smallint, 'number', 'Tính: 63 - 37 + 28 = ___', null, null, null, null, '54', null::jsonb, '63 - 37 = 26, 26 + 28 = 54.', 'tinh_bieu_thuc', 48::int),
    (1::smallint, 'number', '78 - 19 = ___', null, null, null, null, '59', null::jsonb, '18 - 9 = 9, nhớ 1; 7 - 1 - 1 = 5. Kết quả 59.', 'tru_dang_55_8', 49::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 15 - 7 ___ 16 - 9', '>', '<', '=', null, '>', null::jsonb, '15 - 7 = 8, 16 - 9 = 7, mà 8 > 7.', 'bang_tru', 41::int),
    (1::smallint, 'text', 'Trong phép trừ 65 - 38 = 27, số 65 được gọi là số ___', null, null, null, null, 'bị trừ', '["số bị trừ"]'::jsonb, '65 là số bị trừ, 38 là số trừ, 27 là hiệu.', 'thanh_phan_phep_tinh', 41::int),
    (2::smallint, 'number', 'Tìm x, biết: x - 39 = 91 - 35
x = ___', null, null, null, null, '95', null::jsonb, '91 - 35 = 56, x = 56 + 39 = 95.', 'tim_so_bi_tru', 42::int),
    (2::smallint, 'number', 'Tìm x, biết: x - 28 = 17 + 39
x = ___', null, null, null, null, '84', null::jsonb, '17 + 39 = 56, x = 56 + 28 = 84.', 'tim_so_bi_tru', 42::int),
    (2::smallint, 'number', 'Ngăn thứ nhất có 58 quyển sách và nhiều hơn ngăn thứ hai 9 quyển. Ngăn thứ hai có ___ quyển sách.', null, null, null, null, '49', null::jsonb, 'Ngăn thứ hai ít hơn: 58 - 9 = 49 quyển.', 'bai_toan_it_hon', 43::int),
    (2::smallint, 'number', 'Bà mang ra chợ 6 chục quả trứng. Bà đã bán 25 quả. Bà còn lại ___ quả trứng.', null, null, null, null, '35', null::jsonb, '6 chục = 60; 60 - 25 = 35 quả.', 'bai_toan_mot_buoc', 48::int),
    (2::smallint, 'number', 'Tìm một số, biết tổng của số đó với 38 bằng số lẻ lớn nhất có hai chữ số. Số đó là ___', null, null, null, null, '61', null::jsonb, 'Số lẻ lớn nhất có hai chữ số là 99; 99 - 38 = 61.', 'tim_so_hang', 48::int),
    (2::smallint, 'number', 'Tổng của hai số là 30. Nếu một số hạng giảm đi 15 đơn vị thì tổng mới là ___', null, null, null, null, '15', null::jsonb, 'Một số hạng giảm 15 thì tổng giảm 15: 30 - 15 = 15.', 'quan_he_phep_cong', 48::int),
    (2::smallint, 'number', 'Trong vườn có 34 cây cam và cây bưởi. Số cây bưởi là số lớn nhất có một chữ số. Trong vườn có ___ cây cam.', null, null, null, null, '25', null::jsonb, 'Có 9 cây bưởi; số cây cam là 34 - 9 = 25 cây.', 'bai_toan_tim_so_hang', 48::int),
    (2::smallint, 'number', 'Có 6 que diêm được xếp cách đều nhau thành một hàng. Giữa 6 que diêm có ___ khoảng cách.', null, null, null, null, '5', null::jsonb, 'Xếp thành hàng thì số khoảng cách ít hơn số que 1: 6 - 1 = 5.', 'bai_toan_khoang_cach', 46::int),
    (2::smallint, 'multiple_choice', 'Số tiếp theo của dãy số 11; 22; 33; 44; 55; ... là:', '65', '66', '56', '60', '66', null::jsonb, 'Mỗi số hơn số trước 11 đơn vị: 55 + 11 = 66.', 'day_so_quy_luat', 49::int),
    (2::smallint, 'number', 'Lan gấp được 15 ngôi sao, Hoa gấp được 9 ngôi sao. Hoa phải gấp thêm ___ ngôi sao nữa để số ngôi sao của hai bạn bằng nhau.', null, null, null, null, '6', null::jsonb, 'Hoa kém Lan 15 - 9 = 6 ngôi sao.', 'bai_toan_it_hon', 48::int),
    (3::smallint, 'number', 'Hiện nay tổng số tuổi của bố và con là 56 tuổi. Ba năm trước, tổng số tuổi của hai bố con là ___ tuổi.', null, null, null, null, '50', null::jsonb, 'Mỗi người kém đi 3 tuổi nên tổng kém đi 6 tuổi: 56 - 6 = 50.', 'bai_toan_tuoi', 44::int),
    (3::smallint, 'number', 'Hiện nay tổng số tuổi của hai chị em là 32 tuổi. Năm năm sau, tổng số tuổi của hai chị em là ___ tuổi.', null, null, null, null, '42', null::jsonb, 'Mỗi người thêm 5 tuổi nên tổng thêm 10 tuổi: 32 + 10 = 42.', 'bai_toan_tuoi', 44::int),
    (3::smallint, 'number', 'Khi em 5 tuổi thì tổng số tuổi của hai chị em là 15 tuổi. Hiện nay em 12 tuổi thì chị ___ tuổi.', null, null, null, null, '17', null::jsonb, 'Khi đó chị 10 tuổi, hơn em 5 tuổi; nay em 12 tuổi thì chị 12 + 5 = 17 tuổi.', 'bai_toan_tuoi', 45::int),
    (3::smallint, 'number', 'Khi con 7 tuổi thì tổng số tuổi của hai mẹ con là 45 tuổi. Hiện nay con 11 tuổi thì mẹ ___ tuổi.', null, null, null, null, '42', null::jsonb, 'Khi đó mẹ 45 - 7 = 38 tuổi; sau 4 năm mẹ 38 + 4 = 42 tuổi.', 'bai_toan_tuoi', 45::int),
    (3::smallint, 'number', 'Con đường trước trường có 5 cây được trồng cách đều nhau, hai cây liền nhau cách nhau 20 dm. Cây thứ năm cách cây thứ nhất ___ dm.', null, null, null, null, '80', null::jsonb, 'Từ cây 1 đến cây 5 có 4 khoảng cách: 20 + 20 + 20 + 20 = 80 dm.', 'bai_toan_khoang_cach', 47::int),
    (3::smallint, 'number', 'Có 5 cột đèn được lắp dọc một đoạn đường, giữa hai cột đèn liền nhau trồng 2 cây xanh. Có tất cả ___ cây xanh.', null, null, null, null, '8', null::jsonb, '5 cột đèn có 4 khoảng, mỗi khoảng 2 cây: 2 + 2 + 2 + 2 = 8 cây.', 'bai_toan_khoang_cach', 47::int),
    (3::smallint, 'multiple_choice', 'Có 9 học sinh xếp cách đều nhau thành một vòng tròn. Có bao nhiêu khoảng cách giữa 9 học sinh đó?', '8', '10', '7', '9', '9', null::jsonb, 'Xếp thành vòng tròn thì số khoảng cách bằng số bạn: 9 khoảng cách.', 'bai_toan_khoang_cach', 46::int),
    (3::smallint, 'number', 'Bao thứ nhất đựng 25 kg đường. Bao thứ hai ít hơn bao thứ nhất 6 kg. Bao thứ ba nhiều hơn bao thứ hai 13 kg. Cả ba bao đựng ___ kg đường.', null, null, null, null, '76', null::jsonb, 'Bao hai: 19 kg, bao ba: 19 + 13 = 32 kg; cả ba: 25 + 19 + 32 = 76 kg.', 'bai_toan_nhieu_buoc', 43::int),
    (3::smallint, 'number', 'Tổng của hai số có hai chữ số là 67. Số thứ hai là số nhỏ nhất có tổng hai chữ số bằng 11. Số thứ nhất là ___', null, null, null, null, '38', null::jsonb, 'Số nhỏ nhất có tổng hai chữ số bằng 11 là 29; số thứ nhất là 67 - 29 = 38.', 'cau_tao_so', 48::int),
    (3::smallint, 'number', 'Số tiếp theo của dãy số 9; 10; 12; 15; 19; ... là ___', null, null, null, null, '24', null::jsonb, 'Các số lần lượt tăng thêm 1, 2, 3, 4 nên số tiếp theo là 19 + 5 = 24.', 'day_so_quy_luat', 49::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 14 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 15: 100 trừ đi một số. Tìm số trừ. Đường thẳng. Luyện tập (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 15, 100, 'Archimes: 100 trừ đi một số. Tìm số trừ. Đường thẳng. Luyện tập', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 15', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '100 - 15 = ___', null, null, null, null, '85', null::jsonb, '10 - 5 = 5, nhớ 1; 10 - 1 - 1 = 8. Kết quả 85.', 'tru_100', 51::int),
    (1::smallint, 'number', '100 - 77 = ___', null, null, null, null, '23', null::jsonb, '10 - 7 = 3, nhớ 1; 10 - 7 - 1 = 2. Kết quả 23.', 'tru_100', 51::int),
    (1::smallint, 'number', '100 - 48 = ___', null, null, null, null, '52', null::jsonb, '10 - 8 = 2, nhớ 1; 10 - 4 - 1 = 5. Kết quả 52.', 'tru_100', 51::int),
    (1::smallint, 'multiple_choice', '100 - 52 = ?', '58', '48', '52', '47', '48', null::jsonb, '10 - 2 = 8, nhớ 1; 10 - 5 - 1 = 4. Kết quả 48.', 'tru_100', 51::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 27 = 100
x = ___', null, null, null, null, '73', null::jsonb, 'x = 100 - 27 = 73.', 'tim_so_hang', 51::int),
    (1::smallint, 'number', 'Tìm x, biết: 100 - x = 37
x = ___', null, null, null, null, '63', null::jsonb, 'Muốn tìm số trừ, lấy số bị trừ trừ đi hiệu: 100 - 37 = 63.', 'tim_so_tru', 53::int),
    (1::smallint, 'number', 'Tìm x, biết: 58 - x = 39
x = ___', null, null, null, null, '19', null::jsonb, 'x = 58 - 39 = 19.', 'tim_so_tru', 53::int),
    (1::smallint, 'text', 'Điền từ còn thiếu: Muốn tìm số trừ, ta lấy số bị trừ trừ đi ___.', null, null, null, null, 'hiệu', null::jsonb, 'Số trừ = Số bị trừ - Hiệu.', 'tim_so_tru', 50::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 100 - 61 ___ 39', '>', '<', '=', null, '=', null::jsonb, '100 - 61 = 39.', 'so_sanh', 53::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 100 - 72 ___ 27', '>', '<', '=', null, '>', null::jsonb, '100 - 72 = 28, mà 28 > 27.', 'so_sanh', 53::int),
    (1::smallint, 'number', 'Tính: 85 - 18 - 7 = ___', null, null, null, null, '60', null::jsonb, '85 - 18 = 67, 67 - 7 = 60.', 'tinh_bieu_thuc', 57::int),
    (1::smallint, 'multiple_choice', 'Ba điểm A, B, C cùng nằm trên một đường thẳng. Ta nói A, B, C là ba điểm:', 'trùng nhau', 'tạo thành hình tam giác', 'nằm riêng lẻ', 'thẳng hàng', 'thẳng hàng', null::jsonb, 'Ba điểm cùng nằm trên một đường thẳng gọi là ba điểm thẳng hàng.', 'duong_thang', 50::int),
    (2::smallint, 'number', 'Tìm x, biết: x - 24 = 25 + 45
x = ___', null, null, null, null, '94', null::jsonb, '25 + 45 = 70, x = 70 + 24 = 94.', 'tim_so_bi_tru', 51::int),
    (2::smallint, 'number', 'Mẹ có 100 quả táo để trong hai rổ. Rổ thứ nhất có 64 quả. Rổ thứ hai có ___ quả táo.', null, null, null, null, '36', null::jsonb, 'Rổ thứ hai có 100 - 64 = 36 quả.', 'bai_toan_tim_so_hang', 57::int),
    (2::smallint, 'number', 'Số bị trừ là 85, hiệu là số tròn chục có chữ số hàng chục là 2. Số trừ là ___', null, null, null, null, '65', null::jsonb, 'Hiệu là 20; số trừ = 85 - 20 = 65.', 'tim_so_tru', 57::int),
    (2::smallint, 'number', 'Cô giáo mua 40 hộp bút màu làm phần thưởng. Sau khi thưởng cho học sinh giỏi, cô còn lại 2 hộp. Cô đã thưởng ___ hộp bút màu.', null, null, null, null, '38', null::jsonb, 'Cô đã thưởng 40 - 2 = 38 hộp.', 'bai_toan_tim_so_tru', 57::int),
    (2::smallint, 'number', 'Hiệu của hai số bằng 100. Nếu số bị trừ giảm đi 26 đơn vị và giữ nguyên số trừ thì hiệu mới là ___', null, null, null, null, '74', null::jsonb, 'Số bị trừ giảm 26 thì hiệu giảm 26: 100 - 26 = 74.', 'quan_he_phep_tru', 57::int),
    (2::smallint, 'number', 'Số bị trừ là số lớn nhất có hai chữ số, hiệu là số nhỏ nhất có hai chữ số. Số trừ là ___', null, null, null, null, '89', null::jsonb, 'Số trừ = 99 - 10 = 89.', 'tim_so_tru', 57::int),
    (2::smallint, 'number', 'Hiệu của số nhỏ nhất có hai chữ số giống nhau và số lớn nhất có một chữ số là ___', null, null, null, null, '2', null::jsonb, 'Số nhỏ nhất có hai chữ số giống nhau là 11; 11 - 9 = 2.', 'cau_tao_so', 57::int),
    (2::smallint, 'number', 'Mẹ có 2 chục quả và 5 quả cam. Mẹ cho Lan một số quả cam thì mẹ còn lại 9 quả. Mẹ đã cho Lan ___ quả cam.', null, null, null, null, '16', null::jsonb, 'Mẹ có 25 quả; mẹ cho Lan 25 - 9 = 16 quả.', 'bai_toan_tim_so_tru', 54::int),
    (2::smallint, 'number', 'Một con ốc sên bò trên đoạn đường dài 10 dm. Sau một đêm, đoạn đường còn lại dài 18 cm. Trong đêm đó ốc sên bò được ___ cm.', null, null, null, null, '82', null::jsonb, '10 dm = 100 cm; ốc sên bò được 100 - 18 = 82 cm.', 'do_dai', 54::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 100 - 28 - 32 ___ 41', '>', '<', '=', null, '<', null::jsonb, '100 - 28 - 32 = 72 - 32 = 40, mà 40 < 41.', 'so_sanh', 53::int),
    (3::smallint, 'number', 'Cửa hàng bánh buổi sáng bán được 53 hộp, buổi chiều bán ít hơn buổi sáng 17 hộp thì còn lại 11 hộp. Lúc đầu cửa hàng có ___ hộp bánh.', null, null, null, null, '100', null::jsonb, 'Buổi chiều bán 36 hộp; lúc đầu có 53 + 36 + 11 = 100 hộp.', 'bai_toan_nhieu_buoc', 52::int),
    (3::smallint, 'number', 'Một cửa hàng có 100 l mật ong. Buổi sáng bán 36 l, buổi chiều bán nhiều hơn buổi sáng 14 l. Cửa hàng còn lại ___ l mật ong.', null, null, null, null, '14', null::jsonb, 'Buổi chiều bán 50 l; còn lại 100 - 36 - 50 = 14 l.', 'bai_toan_nhieu_buoc', 52::int),
    (3::smallint, 'multiple_choice', 'Chị Hoa cao 14 dm và cao hơn Hồng 3 dm. Em Cúc thấp hơn chị Hoa 2 dm. Giữa Cúc và Hồng, ai cao hơn và cao hơn bao nhiêu?', 'Hồng cao hơn Cúc 1 dm', 'Cúc cao hơn Hồng 5 dm', 'Cúc cao hơn Hồng 1 dm', 'Hai bạn cao bằng nhau', 'Cúc cao hơn Hồng 1 dm', null::jsonb, 'Hồng cao 11 dm, Cúc cao 12 dm; Cúc cao hơn Hồng 1 dm.', 'bai_toan_suy_luan', 54::int),
    (3::smallint, 'number', 'Một phép trừ có hiệu là 54, số bị trừ là số chẵn lớn nhất có hai chữ số. Số trừ là ___', null, null, null, null, '44', null::jsonb, 'Số bị trừ là 98; số trừ = 98 - 54 = 44.', 'tim_so_tru', 55::int),
    (3::smallint, 'number', 'Tổng của hai số là 67. Số thứ nhất có chữ số hàng đơn vị là số chẵn lớn nhất có một chữ số. Số thứ hai có chữ số hàng chục là 4. Số thứ nhất là ___', null, null, null, null, '18', null::jsonb, 'Số thứ nhất có dạng _8, số thứ hai có dạng 4_; thử ra 18 + 49 = 67.', 'cau_tao_so', 55::int),
    (3::smallint, 'multiple_choice', 'Trong một phép trừ, nếu tăng số trừ lên 10 đơn vị và giữ nguyên số bị trừ thì hiệu:', 'tăng 10 đơn vị', 'không thay đổi', 'tăng 20 đơn vị', 'giảm 10 đơn vị', 'giảm 10 đơn vị', null::jsonb, 'Số trừ tăng bao nhiêu thì hiệu giảm bấy nhiêu.', 'quan_he_phep_tru', 56::int),
    (3::smallint, 'number', 'Trong một phép trừ, nếu số trừ giảm đi 32 đơn vị thì hiệu mới bằng 59. Hiệu ban đầu là ___', null, null, null, null, '27', null::jsonb, 'Số trừ giảm 32 thì hiệu tăng 32, nên hiệu ban đầu là 59 - 32 = 27.', 'quan_he_phep_tru', 56::int),
    (3::smallint, 'number', 'Nếu mẹ trồng thêm 15 cây hoa hồng thì số cây hoa cúc nhiều hơn số cây hoa hồng 25 cây. Lúc đầu, số cây hoa cúc nhiều hơn số cây hoa hồng ___ cây.', null, null, null, null, '40', null::jsonb, 'Trồng thêm 15 cây hồng thì khoảng cách giảm 15, nên lúc đầu cúc hơn hồng 25 + 15 = 40 cây.', 'quan_he_phep_tru', 56::int),
    (3::smallint, 'number', 'Minh cho em 5 chiếc kẹo thì số kẹo của hai anh em bằng nhau. Lúc đầu Minh có nhiều hơn em ___ chiếc kẹo.', null, null, null, null, '10', null::jsonb, 'Minh bớt 5 chiếc và em thêm 5 chiếc thì bằng nhau, nên Minh hơn em 5 + 5 = 10 chiếc.', 'bai_toan_suy_luan', 57::int),
    (3::smallint, 'number', 'Một sợi dây dài 10 dm. Lần đầu cắt đi 36 cm, lần thứ hai cắt đoạn dài hơn lần đầu 8 cm. Sau hai lần cắt, sợi dây còn lại dài ___ cm.', null, null, null, null, '20', null::jsonb, '10 dm = 100 cm; lần hai cắt 44 cm; còn lại 100 - 36 - 44 = 20 cm.', 'do_dai', 58::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 15 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 16: Ngày, giờ. Ngày, tháng (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 16, 100, 'Archimes: Ngày, giờ. Ngày, tháng', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 16', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Một ngày có ___ giờ.', null, null, null, null, '24', null::jsonb, 'Một ngày có 24 giờ, tính từ 12 giờ đêm hôm trước đến 12 giờ đêm hôm sau.', 'ngay_gio', 59::int),
    (1::smallint, 'multiple_choice', '3 giờ chiều còn gọi là:', '13 giờ', '15 giờ', '3 giờ', '16 giờ', '15 giờ', null::jsonb, '3 giờ chiều = 12 + 3 = 15 giờ.', 'ngay_gio', 59::int),
    (1::smallint, 'multiple_choice', '20 giờ còn gọi là:', '8 giờ sáng', '10 giờ tối', '8 giờ tối', '2 giờ chiều', '8 giờ tối', null::jsonb, '20 - 12 = 8, nên 20 giờ là 8 giờ tối.', 'ngay_gio', 59::int),
    (1::smallint, 'number', '17 giờ còn gọi là ___ giờ chiều.', null, null, null, null, '5', null::jsonb, '17 - 12 = 5, nên 17 giờ là 5 giờ chiều.', 'ngay_gio', 59::int),
    (1::smallint, 'number', 'Tháng 12 có ___ ngày.', null, null, null, null, '31', null::jsonb, 'Các tháng 1, 3, 5, 7, 8, 10, 12 có 31 ngày.', 'ngay_thang', 59::int),
    (1::smallint, 'multiple_choice', 'Tháng nào dưới đây có 30 ngày?', 'Tháng 5', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 9', null::jsonb, 'Các tháng 4, 6, 9, 11 có 30 ngày.', 'ngay_thang', 59::int),
    (1::smallint, 'number', 'Một năm có ___ tháng.', null, null, null, null, '12', null::jsonb, 'Một năm có 12 tháng.', 'ngay_thang', 59::int),
    (1::smallint, 'text', 'Trong một năm, tháng chỉ có 28 hoặc 29 ngày là tháng ___', null, null, null, null, '2', '["hai","tháng 2","tháng hai"]'::jsonb, 'Tháng 2 có 28 hoặc 29 ngày, các tháng khác có 30 hoặc 31 ngày.', 'ngay_thang', 59::int),
    (1::smallint, 'number', '2 ngày = ___ giờ', null, null, null, null, '48', null::jsonb, 'Mỗi ngày có 24 giờ: 24 + 24 = 48 giờ.', 'ngay_gio', 66::int),
    (1::smallint, 'number', '1 tuần lễ có ___ ngày.', null, null, null, null, '7', null::jsonb, 'Một tuần có 7 ngày: từ thứ Hai đến Chủ nhật.', 'ngay_thang', 61::int),
    (1::smallint, 'multiple_choice', '23 giờ còn gọi là:', '11 giờ đêm', '11 giờ trưa', '3 giờ chiều', '10 giờ đêm', '11 giờ đêm', null::jsonb, '23 - 12 = 11, nên 23 giờ là 11 giờ đêm.', 'ngay_gio', 60::int),
    (1::smallint, 'number', 'Lúc 6 giờ sáng, kim phút chỉ vào số 12, còn kim giờ chỉ vào số ___', null, null, null, null, '6', null::jsonb, 'Đồng hồ chỉ giờ đúng thì kim phút chỉ số 12, kim giờ chỉ đúng số giờ.', 'xem_dong_ho', 60::int),
    (1::smallint, 'multiple_choice', 'Tháng 11 năm 2020, ngày 1 là Chủ nhật. Ngày 8 tháng 11 là thứ mấy?', 'Thứ Bảy', 'Chủ nhật', 'Thứ Hai', 'Thứ Sáu', 'Chủ nhật', null::jsonb, 'Sau 7 ngày lại đến cùng thứ: 1 + 7 = 8, nên ngày 8 cũng là Chủ nhật.', 'xem_lich', 62::int),
    (2::smallint, 'number', 'Chú An bắt đầu làm việc từ 8 giờ sáng và xong việc lúc 5 giờ chiều cùng ngày. Chú An làm việc trong ___ giờ.', null, null, null, null, '9', null::jsonb, '5 giờ chiều là 17 giờ; 17 - 8 = 9 giờ.', 'tinh_thoi_gian', 61::int),
    (2::smallint, 'multiple_choice', 'Tháng 11 năm 2020, ngày 1 là Chủ nhật. Ngày 20 tháng 11 là thứ mấy?', 'Thứ Năm', 'Thứ Bảy', 'Thứ Sáu', 'Thứ Tư', 'Thứ Sáu', null::jsonb, 'Các ngày Chủ nhật là 1, 8, 15, 22; ngày 20 kém 22 hai ngày nên là thứ Sáu.', 'xem_lich', 62::int),
    (2::smallint, 'number', 'Tháng 11 năm 2020 có 30 ngày, ngày 1 là Chủ nhật. Tháng đó có ___ ngày thứ Hai.', null, null, null, null, '5', null::jsonb, 'Các ngày thứ Hai là 2, 9, 16, 23, 30, tất cả 5 ngày.', 'xem_lich', 62::int),
    (2::smallint, 'number', 'Nghỉ hè, Minh về quê nội 1 tuần 5 ngày, sau đó về quê ngoại 1 tuần 2 ngày. Minh đã về quê tất cả ___ ngày.', null, null, null, null, '21', null::jsonb, 'Quê nội 12 ngày, quê ngoại 9 ngày; 12 + 9 = 21 ngày.', 'ngay_thang', 61::int),
    (2::smallint, 'number', '3 tuần và 2 ngày = ___ ngày', null, null, null, null, '23', null::jsonb, '3 tuần = 7 + 7 + 7 = 21 ngày; 21 + 2 = 23 ngày.', 'ngay_thang', 66::int),
    (2::smallint, 'number', 'Mỗi ngày một cửa hàng mở cửa lúc 8 giờ sáng và đóng cửa lúc 6 giờ chiều. Cửa hàng mở cửa ___ giờ mỗi ngày.', null, null, null, null, '10', null::jsonb, '6 giờ chiều là 18 giờ; 18 - 8 = 10 giờ.', 'tinh_thoi_gian', 66::int),
    (2::smallint, 'multiple_choice', 'Bố bắt đầu làm việc lúc 8 giờ sáng và làm trong 9 giờ. Bố làm xong lúc:', '5 giờ chiều', '4 giờ chiều', '6 giờ chiều', '1 giờ chiều', '5 giờ chiều', null::jsonb, '8 + 9 = 17 giờ, tức là 5 giờ chiều.', 'tinh_thoi_gian', 66::int),
    (2::smallint, 'number', 'Một xe ô tô đi từ Hà Nội lúc 9 giờ sáng và đến Thanh Hóa lúc 13 giờ. Xe đi hết ___ giờ.', null, null, null, null, '4', null::jsonb, '13 - 9 = 4 giờ.', 'tinh_thoi_gian', 67::int),
    (2::smallint, 'multiple_choice', 'An bắt đầu học đàn lúc 7 giờ tối và học liên tục trong 2 giờ. An học xong lúc:', '5 giờ tối', '9 giờ tối', '8 giờ tối', '9 giờ sáng', '9 giờ tối', null::jsonb, '7 + 2 = 9, An học xong lúc 9 giờ tối.', 'tinh_thoi_gian', 67::int),
    (2::smallint, 'multiple_choice', 'Ngày 1 tháng 12 năm 2020 là thứ Ba. Ngày 22 tháng 12 năm 2020 là thứ mấy?', 'Thứ Hai', 'Thứ Tư', 'Thứ Ba', 'Chủ nhật', 'Thứ Ba', null::jsonb, 'Các ngày thứ Ba là 1, 8, 15, 22, nên ngày 22 là thứ Ba.', 'xem_lich', 63::int),
    (3::smallint, 'number', 'Thứ Tư tuần này là ngày 2 tháng 12. Thứ Sáu tuần sau là ngày ___ tháng 12.', null, null, null, null, '11', null::jsonb, 'Thứ Tư tuần sau là ngày 9; thứ Sáu sau đó 2 ngày là ngày 11.', 'xem_lich', 63::int),
    (3::smallint, 'multiple_choice', 'Ngày 5 tháng 12 năm 2020 là thứ Bảy. Ngày 1 tháng 1 năm 2021 (Tết Dương lịch) là thứ mấy?', 'Thứ Năm', 'Chủ nhật', 'Thứ Bảy', 'Thứ Sáu', 'Thứ Sáu', null::jsonb, 'Các thứ Bảy: 5, 12, 19, 26 tháng 12; tháng 12 có 31 ngày nên 31/12 là thứ Năm, 1/1 là thứ Sáu.', 'xem_lich', 63::int),
    (3::smallint, 'number', 'Tháng 5 năm 2020 có năm ngày Chủ nhật, Chủ nhật đầu tiên là ngày 3. Chủ nhật cuối cùng của tháng là ngày ___', null, null, null, null, '31', null::jsonb, 'Các ngày Chủ nhật là 3, 10, 17, 24, 31.', 'xem_lich', 63::int),
    (3::smallint, 'multiple_choice', 'Ngày 12 tháng 11 là thứ Năm. Ngày 20 tháng 11 cùng năm đó là thứ mấy?', 'Thứ Năm', 'Thứ Bảy', 'Thứ Tư', 'Thứ Sáu', 'Thứ Sáu', null::jsonb, 'Ngày 19 là thứ Năm (12 + 7), nên ngày 20 là thứ Sáu.', 'xem_lich', 63::int),
    (3::smallint, 'number', 'Thứ Tư tuần này là ngày 17 tháng 4. Thứ Ba tuần sau là ngày ___ tháng 4.', null, null, null, null, '23', null::jsonb, 'Thứ Tư tuần sau là ngày 24; thứ Ba liền trước là ngày 23.', 'xem_lich', 63::int),
    (3::smallint, 'multiple_choice', 'Thứ Hai là ngày 14 tháng 8. Ngày 24 tháng 8 năm đó là thứ mấy?', 'Thứ Năm', 'Thứ Tư', 'Thứ Sáu', 'Thứ Ba', 'Thứ Năm', null::jsonb, 'Ngày 21 là thứ Hai (14 + 7), nên ngày 24 là thứ Năm.', 'xem_lich', 66::int),
    (3::smallint, 'number', 'Ngày 12 tháng 4 tuần này là thứ Ba. Thứ Ba tuần trước là ngày ___ tháng 4.', null, null, null, null, '5', null::jsonb, 'Lùi lại 7 ngày: 12 - 7 = 5.', 'xem_lich', 66::int),
    (3::smallint, 'number', 'Thứ Năm tuần này là ngày 8 tháng 3. Thứ Tư tuần sau là ngày ___ tháng 3.', null, null, null, null, '14', null::jsonb, 'Thứ Năm tuần sau là ngày 15; thứ Tư liền trước là ngày 14.', 'xem_lich', 66::int),
    (3::smallint, 'number', 'Tháng này mẹ đi công tác hai đợt. Đợt thứ nhất đi 1 tuần 3 ngày, đợt thứ hai đi số ngày bằng số lớn nhất có một chữ số. Mẹ đi công tác tất cả ___ ngày.', null, null, null, null, '19', null::jsonb, 'Đợt một 10 ngày, đợt hai 9 ngày; 10 + 9 = 19 ngày.', 'ngay_thang', 61::int),
    (3::smallint, 'number', 'Tháng 11 bố đi công tác hai đợt. Đợt một bố đi 1 tuần 4 ngày và nhiều hơn đợt hai 2 ngày. Cả hai đợt bố đi ___ ngày.', null, null, null, null, '20', null::jsonb, 'Đợt một 11 ngày, đợt hai 11 - 2 = 9 ngày; 11 + 9 = 20 ngày.', 'ngay_thang', 67::int),
    (3::smallint, 'number', 'Nhà Hải nuôi gà và vịt. Mẹ mua thêm 17 con vịt thì số vịt nhiều hơn số gà 100 con. Lúc đầu số gà ít hơn số vịt ___ con.', null, null, null, null, '83', null::jsonb, 'Thêm 17 con vịt thì vịt hơn gà thêm 17; lúc đầu vịt hơn gà 100 - 17 = 83 con.', 'bai_toan_suy_luan', 66::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 16 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 17: Ôn tập: cộng, trừ có nhớ, tìm thành phần chưa biết, đơn vị đo và bài toán tư duy (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 17, 100, 'Archimes: Ôn tập: cộng, trừ có nhớ, tìm thành phần chưa biết, đơn vị đo và bài toán tư duy', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 17', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '45 + 27 = ___', null, null, null, null, '72', null::jsonb, '5 + 7 = 12, viết 2 nhớ 1; 4 + 2 + 1 = 7. Kết quả 72.', 'cong_co_nho', 69::int),
    (1::smallint, 'number', '32 - 19 = ___', null, null, null, null, '13', null::jsonb, '12 - 9 = 3, nhớ 1; 3 - 1 - 1 = 1. Kết quả 13.', 'tru_co_nho', 69::int),
    (1::smallint, 'number', '8 + 46 = ___', null, null, null, null, '54', null::jsonb, '8 + 6 = 14, viết 4 nhớ 1; 4 + 1 = 5. Kết quả 54.', 'cong_co_nho', 69::int),
    (1::smallint, 'multiple_choice', '46 - 17 = ?', '39', '29', '63', '31', '29', null::jsonb, '16 - 7 = 9, nhớ 1; 4 - 1 - 1 = 2. Kết quả 29.', 'tru_co_nho', 69::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 18 = 73
x = ___', null, null, null, null, '55', null::jsonb, 'x = 73 - 18 = 55.', 'tim_so_hang', 69::int),
    (1::smallint, 'number', 'Tìm x, biết: x - 47 = 25
x = ___', null, null, null, null, '72', null::jsonb, 'x = 25 + 47 = 72.', 'tim_so_bi_tru', 69::int),
    (1::smallint, 'number', 'Tìm x, biết: 100 - x = 53
x = ___', null, null, null, null, '47', null::jsonb, 'x = 100 - 53 = 47.', 'tim_so_tru', 69::int),
    (1::smallint, 'number', '13 kg + 17 kg = ___ kg', null, null, null, null, '30', null::jsonb, '13 + 17 = 30 (kg).', 'don_vi_kg', 71::int),
    (1::smallint, 'number', '36 l + 46 l = ___ l', null, null, null, null, '82', null::jsonb, '36 + 46 = 82 (l).', 'don_vi_lit', 71::int),
    (1::smallint, 'number', '85 dm - 29 dm = ___ dm', null, null, null, null, '56', null::jsonb, '85 - 29 = 56 (dm).', 'do_dai', 71::int),
    (1::smallint, 'multiple_choice', 'Hình có 3 cạnh và 3 đỉnh là hình gì?', 'Hình tứ giác', 'Hình chữ nhật', 'Hình tam giác', 'Hình vuông', 'Hình tam giác', null::jsonb, 'Hình tam giác có 3 cạnh, 3 đỉnh.', 'hinh_hoc', 68::int),
    (1::smallint, 'text', 'Hình có 4 cạnh và 4 đỉnh được gọi chung là hình ___', null, null, null, null, 'tứ giác', '["hình tứ giác"]'::jsonb, 'Hình có 4 cạnh, 4 đỉnh là hình tứ giác (hình chữ nhật, hình vuông cũng là hình tứ giác).', 'hinh_hoc', 68::int),
    (1::smallint, 'number', 'Tính: 50 - 14 - 28 = ___', null, null, null, null, '8', null::jsonb, '50 - 14 = 36, 36 - 28 = 8.', 'tinh_bieu_thuc', 69::int),
    (2::smallint, 'number', '7 dm + 2 dm = ___ cm', null, null, null, null, '90', null::jsonb, '7 dm + 2 dm = 9 dm = 90 cm.', 'do_dai', 71::int),
    (2::smallint, 'number', '45 cm - 25 cm = ___ dm', null, null, null, null, '2', null::jsonb, '45 - 25 = 20 cm = 2 dm.', 'do_dai', 71::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 25 kg + 36 kg - 9 kg ___ 47 kg - 18 kg + 16 kg', '>', '<', '=', null, '>', null::jsonb, 'Vế trái: 61 - 9 = 52 kg; vế phải: 29 + 16 = 45 kg; 52 > 45.', 'so_sanh', 75::int),
    (2::smallint, 'number', 'Tìm x, biết: 69 + x = 32 + 68
x = ___', null, null, null, null, '31', null::jsonb, '32 + 68 = 100, x = 100 - 69 = 31.', 'tim_so_hang', 69::int),
    (2::smallint, 'number', 'Tìm x, biết: 80 - x = 100 - 57
x = ___', null, null, null, null, '37', null::jsonb, '100 - 57 = 43, x = 80 - 43 = 37.', 'tim_so_tru', 69::int),
    (2::smallint, 'number', '48 cm + 52 cm - 25 cm = ___ cm', null, null, null, null, '75', null::jsonb, '48 + 52 = 100, 100 - 25 = 75 (cm).', 'do_dai', 71::int),
    (2::smallint, 'number', 'Số tiếp theo của dãy số 13; 25; 37; 49; 61; ... là ___', null, null, null, null, '73', null::jsonb, 'Mỗi số hơn số trước 12 đơn vị: 61 + 12 = 73.', 'day_so_quy_luat', 71::int),
    (2::smallint, 'number', 'Tìm một số, biết số đó trừ đi 26 thì được tổng của 19 và 17. Số đó là ___', null, null, null, null, '62', null::jsonb, '19 + 17 = 36; số đó là 36 + 26 = 62.', 'tim_so_bi_tru', 75::int),
    (2::smallint, 'number', 'Tìm một số, biết 45 cộng với số đó thì được hiệu của 75 và 18. Số đó là ___', null, null, null, null, '12', null::jsonb, '75 - 18 = 57; số đó là 57 - 45 = 12.', 'tim_so_hang', 75::int),
    (2::smallint, 'number', 'Hiệu của hai số bằng 100. Nếu số trừ tăng lên 28 đơn vị thì hiệu mới là ___', null, null, null, null, '72', null::jsonb, 'Số trừ tăng 28 thì hiệu giảm 28: 100 - 28 = 72.', 'quan_he_phep_tru', 75::int),
    (3::smallint, 'number', 'Thùng thứ nhất đựng 36 l nước và đựng ít hơn thùng thứ hai 17 l. Cả hai thùng đựng ___ l nước.', null, null, null, null, '89', null::jsonb, 'Thùng thứ hai đựng 36 + 17 = 53 l; cả hai: 36 + 53 = 89 l.', 'bai_toan_hai_buoc', 76::int),
    (3::smallint, 'number', 'Tìm x, biết: 78 - x - 22 = 17
x = ___', null, null, null, null, '39', null::jsonb, '78 - x = 17 + 22 = 39, x = 78 - 39 = 39.', 'tim_so_tru', 70::int),
    (3::smallint, 'number', 'Sau khi tặng Linh 12 ngôi sao và tặng Hoa 15 ngôi sao thì Ngọc còn lại 16 ngôi sao. Lúc đầu Ngọc có ___ ngôi sao.', null, null, null, null, '43', null::jsonb, 'Lúc đầu Ngọc có 12 + 15 + 16 = 43 ngôi sao.', 'bai_toan_nhieu_buoc', 70::int),
    (3::smallint, 'number', 'Cửa hàng có 82 l mật ong. Tháng thứ nhất bán 42 l và nhiều hơn tháng thứ hai 8 l. Sau hai tháng cửa hàng còn lại ___ l mật ong.', null, null, null, null, '6', null::jsonb, 'Tháng hai bán 34 l; cả hai tháng bán 76 l; còn lại 82 - 76 = 6 l.', 'bai_toan_nhieu_buoc', 72::int),
    (3::smallint, 'number', 'Cô thưởng tổ Một 12 phiếu khen, tổ Hai nhiều hơn tổ Một 6 phiếu, tổ Ba ít hơn tổ Hai 5 phiếu thì cô còn lại 6 phiếu. Lúc đầu cô chuẩn bị ___ phiếu khen.', null, null, null, null, '49', null::jsonb, 'Tổ Hai 18 phiếu, tổ Ba 13 phiếu; lúc đầu có 12 + 18 + 13 + 6 = 49 phiếu.', 'bai_toan_nhieu_buoc', 73::int),
    (3::smallint, 'multiple_choice', 'Ba bạn Cúc, Đào, Hồng mỗi bạn làm một bông hoa: cúc, đào, hồng. Bạn Hồng không làm hoa cúc. Bạn Cúc không làm hoa cúc và hoa đào. Bạn Đào làm hoa gì?', 'Hoa cúc', 'Hoa đào', 'Hoa hồng', null, 'Hoa cúc', null::jsonb, 'Cúc làm hoa hồng; Hồng không làm hoa cúc nên làm hoa đào; còn Đào làm hoa cúc.', 'suy_luan_logic', 73::int),
    (3::smallint, 'multiple_choice', 'Ba bạn Lan, Mai, Phượng chăm sóc 3 cây lan, mai, phượng; không ai chăm cây trùng tên mình. Bạn chăm cây mai đang nói chuyện với bạn Lan. Bạn Lan chăm cây gì?', 'Cây lan', 'Cây mai', 'Cây phượng', null, 'Cây phượng', null::jsonb, 'Người chăm cây mai không phải Lan, không phải Mai nên là Phượng; Lan không chăm cây lan nên chăm cây phượng.', 'suy_luan_logic', 74::int),
    (3::smallint, 'number', 'Trong túi có 4 viên bi xanh và 6 viên bi trắng. Không nhìn vào túi, phải lấy ra ít nhất ___ viên bi để chắc chắn có 2 viên bi khác màu.', null, null, null, null, '7', null::jsonb, 'Xui nhất là lấy cả 6 viên trắng trước; lấy thêm 1 viên nữa chắc chắn có bi xanh: 6 + 1 = 7.', 'suy_luan_logic', 74::int),
    (3::smallint, 'multiple_choice', 'An gấp 10 con hạc giấy màu xanh và màu hồng. Số hạc xanh là số lẻ lớn hơn 1 và ít hơn số hạc hồng. An gấp bao nhiêu con hạc xanh?', '5 con', '1 con', '7 con', '3 con', '3 con', null::jsonb, 'Hạc xanh ít hơn hạc hồng nên ít hơn 5; số lẻ lớn hơn 1 và nhỏ hơn 5 là 3 (hạc hồng 7 con).', 'suy_luan_logic', 74::int),
    (3::smallint, 'number', 'Chủ nhật tuần trước là ngày 22 tháng 6. Thứ Hai tuần sau là ngày ___ tháng 6.', null, null, null, null, '30', null::jsonb, 'Thứ Hai tuần này là ngày 23; thứ Hai tuần sau là 23 + 7 = 30.', 'xem_lich', 75::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 17 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 18: Ôn tập về giải toán. Luyện tập chung (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 18, 100, 'Archimes: Ôn tập về giải toán. Luyện tập chung', 'Ngân hàng Archimes — Toán 2 - Quyển 2, tuần 18', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '36 + 46 = ___', null, null, null, null, '82', null::jsonb, '6 + 6 = 12, viết 2 nhớ 1; 3 + 4 + 1 = 8. Kết quả 82.', 'cong_co_nho', 78::int),
    (1::smallint, 'number', '8 + 92 = ___', null, null, null, null, '100', null::jsonb, '8 + 92 = 100.', 'cong_co_nho', 78::int),
    (1::smallint, 'number', '100 - 45 = ___', null, null, null, null, '55', null::jsonb, '10 - 5 = 5, nhớ 1; 10 - 4 - 1 = 5. Kết quả 55.', 'tru_100', 78::int),
    (1::smallint, 'number', '100 - 72 = ___', null, null, null, null, '28', null::jsonb, '10 - 2 = 8, nhớ 1; 10 - 7 - 1 = 2. Kết quả 28.', 'tru_100', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 27 + 15 ___ 65 - 17', '>', '<', '=', null, '<', null::jsonb, '27 + 15 = 42, 65 - 17 = 48, mà 42 < 48.', 'so_sanh', 78::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 41 + 59 ___ 33 + 67', '>', '<', '=', null, '=', null::jsonb, '41 + 59 = 100 và 33 + 67 = 100.', 'so_sanh', 78::int),
    (1::smallint, 'number', 'Tìm x, biết: x + 14 = 33
x = ___', null, null, null, null, '19', null::jsonb, 'x = 33 - 14 = 19.', 'tim_so_hang', 78::int),
    (1::smallint, 'number', 'Tìm x, biết: 19 + x = 53
x = ___', null, null, null, null, '34', null::jsonb, 'x = 53 - 19 = 34.', 'tim_so_hang', 78::int),
    (1::smallint, 'number', 'Tìm x, biết: 100 - x = 35
x = ___', null, null, null, null, '65', null::jsonb, 'x = 100 - 35 = 65.', 'tim_so_tru', 78::int),
    (1::smallint, 'multiple_choice', 'Tổng của hai số là 45, số thứ nhất là 27. Số thứ hai là:', '18', '17', '19', '28', '18', null::jsonb, 'Số thứ hai = 45 - 27 = 18.', 'tim_so_hang', 80::int),
    (1::smallint, 'text', 'Điền từ còn thiếu: Muốn tìm số bị trừ, ta lấy hiệu ___ với số trừ.', null, null, null, null, 'cộng', null::jsonb, 'Số bị trừ = Hiệu + Số trừ.', 'tim_so_bi_tru', 77::int),
    (1::smallint, 'number', 'Tổng của hai số là 54, số thứ nhất là 17. Số thứ hai là ___', null, null, null, null, '37', null::jsonb, 'Số thứ hai = 54 - 17 = 37.', 'tim_so_hang', 81::int),
    (2::smallint, 'multiple_choice', 'Mảnh vải thứ nhất dài 27 dm, mảnh vải thứ hai dài hơn mảnh thứ nhất 4 dm. Mảnh vải thứ hai dài:', '31 cm', '23 dm', '31 dm', '32 dm', '31 dm', null::jsonb, '27 + 4 = 31 dm (chú ý đơn vị là dm).', 'bai_toan_nhieu_hon', 80::int),
    (2::smallint, 'number', 'Bà mang 20 quả trứng gà ra chợ. Sau khi bán, bà còn 9 quả. Bà đã bán ___ quả trứng gà.', null, null, null, null, '11', null::jsonb, 'Bà đã bán 20 - 9 = 11 quả.', 'bai_toan_tim_so_tru', 78::int),
    (2::smallint, 'number', 'Cây nhãn cao 27 dm. Cây xoài cao hơn cây nhãn 8 dm. Cây xoài cao ___ dm.', null, null, null, null, '35', null::jsonb, 'Cây xoài cao 27 + 8 = 35 dm.', 'bai_toan_nhieu_hon', 79::int),
    (2::smallint, 'number', 'Một can nhựa đựng được 35 l dầu và đựng được ít hơn thùng phuy 25 l. Thùng phuy đựng được ___ l dầu.', null, null, null, null, '60', null::jsonb, 'Can ít hơn thùng phuy nên thùng phuy đựng 35 + 25 = 60 l.', 'bai_toan_nhieu_hon', 79::int),
    (2::smallint, 'multiple_choice', 'Tổng của hai số là 29. Nếu số hạng thứ nhất tăng lên 17 đơn vị và giữ nguyên số hạng thứ hai thì tổng mới là:', '36', '12', '56', '46', '46', null::jsonb, 'Một số hạng tăng 17 thì tổng tăng 17: 29 + 17 = 46.', 'quan_he_phep_cong', 80::int),
    (2::smallint, 'multiple_choice', 'Hiệu của hai số là 29. Nếu giữ nguyên số bị trừ và tăng số trừ thêm 6 đơn vị thì hiệu mới là:', '29', '23', '35', '45', '23', null::jsonb, 'Số trừ tăng 6 thì hiệu giảm 6: 29 - 6 = 23.', 'quan_he_phep_tru', 80::int),
    (2::smallint, 'number', 'Tổng của số lớn nhất có một chữ số với số liền sau của 45 là ___', null, null, null, null, '55', null::jsonb, '9 + 46 = 55.', 'cau_tao_so', 80::int),
    (2::smallint, 'number', 'Mẹ ra ngoài lúc 9 giờ sáng và về lúc 5 giờ chiều cùng ngày. Mẹ đã ra ngoài trong ___ giờ.', null, null, null, null, '8', null::jsonb, '5 giờ chiều là 17 giờ; 17 - 9 = 8 giờ.', 'tinh_thoi_gian', 80::int),
    (2::smallint, 'number', 'Tính: 85 - 28 + 37 - 45 = ___', null, null, null, null, '49', null::jsonb, '85 - 28 = 57, 57 + 37 = 94, 94 - 45 = 49.', 'tinh_bieu_thuc', 84::int),
    (2::smallint, 'number', 'Tính bằng cách hợp lý: 29 + 16 + 41 + 4 = ___', null, null, null, null, '90', null::jsonb, '(29 + 41) + (16 + 4) = 70 + 20 = 90.', 'tinh_hop_ly', 82::int),
    (3::smallint, 'number', 'Tìm x, biết: x - 47 - 12 = 28
x = ___', null, null, null, null, '87', null::jsonb, 'x - 47 = 28 + 12 = 40, x = 40 + 47 = 87.', 'tim_so_bi_tru', 78::int),
    (3::smallint, 'number', 'Hoa, Hồng, Huệ gấp được tất cả 27 chiếc thuyền. Hoa và Hồng gấp được 17 chiếc, Hồng và Huệ gấp được 19 chiếc. Hồng gấp được ___ chiếc thuyền.', null, null, null, null, '9', null::jsonb, 'Huệ gấp 27 - 17 = 10 chiếc; Hồng gấp 19 - 10 = 9 chiếc.', 'bai_toan_nhieu_buoc', 79::int),
    (3::smallint, 'multiple_choice', 'Nam nhiều hơn Việt 17 viên bi. Nếu Nam cho Việt 3 viên bi thì Nam còn nhiều hơn Việt bao nhiêu viên bi?', '13 viên bi', '14 viên bi', '17 viên bi', '11 viên bi', '11 viên bi', null::jsonb, 'Nam bớt 3 viên, Việt thêm 3 viên nên khoảng cách giảm 6: 17 - 6 = 11 viên.', 'bai_toan_suy_luan', 80::int),
    (3::smallint, 'multiple_choice', 'Ngày 22 tháng 12 là thứ Tư. Ngày 10 tháng 12 cùng năm đó là thứ mấy?', 'Thứ Bảy', 'Chủ nhật', 'Thứ Sáu', 'Thứ Hai', 'Thứ Sáu', null::jsonb, 'Các ngày thứ Tư là 22, 15, 8; ngày 10 sau ngày 8 hai ngày nên là thứ Sáu.', 'xem_lich', 80::int),
    (3::smallint, 'number', 'Linh, Thảo, Vân cắt được 96 ngôi sao. Linh và Thảo cắt được 58 ngôi sao, Thảo và Vân cắt được 6 chục ngôi sao. Thảo cắt được ___ ngôi sao.', null, null, null, null, '22', null::jsonb, 'Vân cắt 96 - 58 = 38 ngôi sao; Thảo cắt 60 - 38 = 22 ngôi sao.', 'bai_toan_nhieu_buoc', 81::int),
    (3::smallint, 'number', 'Điền số bé nhất thích hợp vào chỗ trống: 45 + 37 < ___ + 54', null, null, null, null, '29', null::jsonb, '45 + 37 = 82, cần ___ + 54 ít nhất là 83, nên số bé nhất là 83 - 54 = 29.', 'tim_x_nang_cao', 82::int),
    (3::smallint, 'number', 'Hiện nay bà 58 tuổi, mẹ 32 tuổi, con 7 tuổi. Sau ___ năm nữa thì tổng số tuổi của ba người là 100.', null, null, null, null, '1', null::jsonb, 'Hiện tổng là 97 tuổi, cần thêm 3; mỗi năm tổng tăng 3 tuổi nên cần 1 năm.', 'bai_toan_tuoi', 83::int),
    (3::smallint, 'number', 'Mẹ có một rổ cam. Mẹ biếu bà 7 quả, rồi biếu ông một nửa số cam còn lại. Sau đó mẹ cho nhà dì Hà 6 quả thì còn 5 quả. Lúc đầu mẹ có ___ quả cam.', null, null, null, null, '29', null::jsonb, 'Trước khi cho dì có 11 quả; trước khi biếu ông có 11 + 11 = 22 quả; lúc đầu có 22 + 7 = 29 quả.', 'bai_toan_tinh_nguoc', 83::int),
    (3::smallint, 'number', 'Số thứ nhất là số lớn nhất có hai chữ số mà tổng hai chữ số bằng 10, số thứ hai là số lớn nhất có một chữ số. Tổng hai số là ___', null, null, null, null, '100', null::jsonb, 'Số thứ nhất là 91, số thứ hai là 9; 91 + 9 = 100.', 'cau_tao_so', 84::int),
    (3::smallint, 'number', 'Bác Lâm chuyển 12 kg gạo từ bao thứ nhất sang bao thứ hai thì hai bao bằng nhau. Trước khi chuyển, bao thứ hai ít hơn bao thứ nhất ___ kg.', null, null, null, null, '24', null::jsonb, 'Bao một bớt 12 kg, bao hai thêm 12 kg thì bằng nhau, nên lúc đầu chênh nhau 12 + 12 = 24 kg.', 'bai_toan_suy_luan', 84::int),
    (3::smallint, 'number', 'Từ 5 điểm A, B, C, D, E (không có ba điểm nào thẳng hàng), ta vẽ được nhiều nhất ___ đoạn thẳng nối hai điểm trong các điểm đó.', null, null, null, null, '10', null::jsonb, 'Từ A có 4 đoạn, từ B thêm 3, từ C thêm 2, từ D thêm 1: 4 + 3 + 2 + 1 = 10.', 'dem_hinh', 84::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 18 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 19: Tổng của nhiều số. Phép nhân. Bảng nhân 2, bảng nhân 3 (37 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 19, 100, 'Archimes: Tổng của nhiều số. Phép nhân. Bảng nhân 2, bảng nhân 3', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 19', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '12 + 24 + 59 = ___', null, null, null, null, '95', null::jsonb, 'Cộng lần lượt: 12 + 24 = 36, 36 + 59 = 95.', 'tong_nhieu_so', 6::int),
    (1::smallint, 'number', '23 + 7 + 35 = ___', null, null, null, null, '65', null::jsonb, '23 + 7 = 30, 30 + 35 = 65.', 'tong_nhieu_so', 6::int),
    (1::smallint, 'number', '8 + 8 + 8 = ___', null, null, null, null, '24', null::jsonb, '8 + 8 = 16, 16 + 8 = 24.', 'tong_nhieu_so', 6::int),
    (1::smallint, 'number', '26 + 14 + 25 = ___', null, null, null, null, '65', null::jsonb, '26 + 14 = 40, 40 + 25 = 65.', 'tong_nhieu_so', 6::int),
    (1::smallint, 'multiple_choice', 'Tổng 2 + 2 + 2 + 2 viết thành phép nhân là:', '4 x 4', '2 x 2', '2 + 4', '2 x 4', '2 x 4', null::jsonb, 'Số 2 được lấy 4 lần nên viết là 2 x 4.', 'viet_tong_thanh_tich', 8::int),
    (1::smallint, 'number', '2 x 7 = ___', null, null, null, null, '14', null::jsonb, 'Bảng nhân 2: 2 x 7 = 14.', 'bang_nhan_2', 5::int),
    (1::smallint, 'number', '3 x 8 = ___', null, null, null, null, '24', null::jsonb, 'Bảng nhân 3: 3 x 8 = 24.', 'bang_nhan_3', 5::int),
    (1::smallint, 'multiple_choice', 'Trong phép tính 2 x 5 = 10, số 5 được gọi là:', 'Thừa số', 'Tích', 'Số hạng', 'Tổng', 'Thừa số', null::jsonb, '2 và 5 là các thừa số, 10 là tích.', 'thanh_phan_phep_nhan', 12::int),
    (1::smallint, 'multiple_choice', 'Tổng 5 + 5 + 5 + 5 + 5 + 5 viết dưới dạng tích là:', '6 x 6', '5 x 6', '5 x 5', '5 + 6', '5 x 6', null::jsonb, 'Số 5 được lấy 6 lần nên viết là 5 x 6.', 'viet_tong_thanh_tich', 12::int),
    (1::smallint, 'multiple_choice', 'Phép nhân 7 x 2 bằng tổng nào dưới đây?', '7 + 2', '7 + 7 + 7', '7 + 7', '2 + 2', '7 + 7', null::jsonb, '7 x 2 nghĩa là số 7 được lấy 2 lần: 7 + 7.', 'viet_tich_thanh_tong', 8::int),
    (1::smallint, 'number', '2 dm x 3 = ___ dm', null, null, null, null, '6', null::jsonb, '2 x 3 = 6 nên 2 dm x 3 = 6 dm.', 'bang_nhan_2', 12::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 6 + 6 + 6 ___ 3 x 5', '<', '>', '=', null, '>', null::jsonb, '6 + 6 + 6 = 18, 3 x 5 = 15, mà 18 > 15.', 'so_sanh', 12::int),
    (1::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): 3 + 3 + 3 + 3 = 3 x 4. ___', null, null, null, null, 'Đ', '["đúng"]'::jsonb, 'Số 3 được lấy 4 lần nên 3 + 3 + 3 + 3 = 3 x 4 = 12.', 'viet_tong_thanh_tich', 8::int),
    (1::smallint, 'text', 'Trong phép nhân 2 x 3 = 6, số 6 được gọi là ___.', null, null, null, null, 'tích', null::jsonb, 'Kết quả của phép nhân gọi là tích.', 'thanh_phan_phep_nhan', 5::int),
    (2::smallint, 'number', '2 x 4 + 7 = ___', null, null, null, null, '15', null::jsonb, 'Nhân trước, cộng sau: 2 x 4 = 8, 8 + 7 = 15.', 'thu_tu_phep_tinh', 8::int),
    (2::smallint, 'number', '70 - 3 x 7 = ___', null, null, null, null, '49', null::jsonb, 'Nhân trước: 3 x 7 = 21, rồi 70 - 21 = 49.', 'thu_tu_phep_tinh', 10::int),
    (2::smallint, 'number', '58 + 3 x 8 = ___', null, null, null, null, '82', null::jsonb, '3 x 8 = 24, 58 + 24 = 82.', 'thu_tu_phep_tinh', 10::int),
    (2::smallint, 'number', 'An sưu tầm được 19 con tem, mẹ cho An thêm 7 con tem, bố cho An thêm 5 con tem. An có tất cả ___ con tem.', null, null, null, null, '31', null::jsonb, '19 + 7 + 5 = 31 (con tem).', 'tong_nhieu_so', 7::int),
    (2::smallint, 'number', 'Thảo cắt được 28 bông hoa, sau đó cắt thêm 17 bông hoa xanh và 19 bông hoa đỏ. Thảo đã cắt được tất cả ___ bông hoa.', null, null, null, null, '64', null::jsonb, '28 + 17 + 19 = 64 (bông hoa).', 'tong_nhieu_so', 7::int),
    (2::smallint, 'number', 'Số học sinh nữ khối Hai: lớp 2A1 có 19 bạn, 2A2 có 12 bạn, 2A3 có 20 bạn, 2A4 có 18 bạn, 2A5 có 15 bạn. Khối Hai có tất cả ___ học sinh nữ.', null, null, null, null, '84', null::jsonb, '19 + 12 + 20 + 18 + 15 = 84 (học sinh).', 'tong_nhieu_so', 7::int),
    (2::smallint, 'number', 'Mỗi bạn mua 2 quả bóng. 9 bạn mua tất cả ___ quả bóng.', null, null, null, null, '18', null::jsonb, '2 x 9 = 18 (quả bóng).', 'bai_toan_phep_nhan', 9::int),
    (2::smallint, 'number', 'Một bàn học có 2 học sinh ngồi. 10 bàn học như thế có tất cả ___ học sinh.', null, null, null, null, '20', null::jsonb, '2 x 10 = 20 (học sinh).', 'bai_toan_phep_nhan', 9::int),
    (2::smallint, 'number', 'Một chiếc xe đạp có 2 bánh xe. 7 chiếc xe đạp như thế có tất cả ___ bánh xe.', null, null, null, null, '14', null::jsonb, '2 x 7 = 14 (bánh xe).', 'bai_toan_phep_nhan', 9::int),
    (2::smallint, 'number', 'Bà chia đủ cam cho 8 cháu, mỗi cháu 2 quả. Bà có ___ quả cam.', null, null, null, null, '16', null::jsonb, '2 x 8 = 16 (quả cam).', 'bai_toan_phep_nhan', 9::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 3 x 9 - 9 ___ 3 x 7 - 2', '>', '=', '<', null, '<', null::jsonb, '3 x 9 - 9 = 18, 3 x 7 - 2 = 19, mà 18 < 19.', 'so_sanh', 10::int),
    (2::smallint, 'multiple_choice', 'Không tính kết quả, chọn dấu: 6 x 3 ___ 3 + 3 + 3 + 3 + 3 + 3', '=', '>', '<', null, '=', null::jsonb, '3 được lấy 6 lần là 3 x 6, mà 3 x 6 = 6 x 3.', 'so_sanh', 13::int),
    (2::smallint, 'number', 'Tích của 2 với số lớn nhất có một chữ số là ___.', null, null, null, null, '18', null::jsonb, 'Số lớn nhất có một chữ số là 9; 2 x 9 = 18.', 'bang_nhan_2', 12::int),
    (2::smallint, 'number', 'Thừa số thứ nhất là 2, thừa số thứ hai là số bé nhất có hai chữ số. Tích của hai thừa số đó là ___.', null, null, null, null, '20', null::jsonb, 'Số bé nhất có hai chữ số là 10; 2 x 10 = 20.', 'thanh_phan_phep_nhan', 12::int),
    (3::smallint, 'number', 'Có ba bạn, mỗi bạn có 2 viên bi đỏ và 1 viên bi vàng. Cả ba bạn có tất cả ___ viên bi.', null, null, null, null, '9', null::jsonb, 'Mỗi bạn có 2 + 1 = 3 viên; ba bạn có 3 x 3 = 9 viên.', 'bai_toan_phep_nhan', 10::int),
    (3::smallint, 'number', 'Có 2 con đường đi từ nhà Minh đến nhà Bình và 3 con đường đi từ nhà Bình đến trường. Có ___ cách đi từ nhà Minh đến trường mà phải đi qua nhà Bình.', null, null, null, null, '6', null::jsonb, 'Mỗi đường đến nhà Bình lại có 3 đường đến trường: 2 x 3 = 6 cách.', 'suy_luan', 10::int),
    (3::smallint, 'number', 'Cô giáo chia lớp thành 4 nhóm, mỗi nhóm 2 học sinh và 7 nhóm, mỗi nhóm 3 học sinh. Lớp học có tất cả ___ học sinh.', null, null, null, null, '29', null::jsonb, '2 x 4 = 8, 3 x 7 = 21, 8 + 21 = 29 (học sinh).', 'bai_toan_hai_buoc', 11::int),
    (3::smallint, 'multiple_choice', 'Hai số có tổng bằng 7 và tích bằng 10 là:', '3 và 4', '1 và 6', '1 và 10', '2 và 5', '2 và 5', null::jsonb, '2 + 5 = 7 và 2 x 5 = 10.', 'tim_hai_so', 11::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 6 và hiệu bằng 1 là:', '1 và 6', '3 và 4', '1 và 2', '2 và 3', '2 và 3', null::jsonb, '2 x 3 = 6 và 3 - 2 = 1.', 'tim_hai_so', 11::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 8 và tổng bằng 6 là:', '2 và 4', '1 và 8', '3 và 3', '2 và 6', '2 và 4', null::jsonb, '2 x 4 = 8 và 2 + 4 = 6.', 'tim_hai_so', 13::int),
    (3::smallint, 'number', 'Tìm số thứ mười trong dãy số: 2; 3; 4; 6; 6; 9; 8; ... Số thứ mười là ___.', null, null, null, null, '15', null::jsonb, 'Các số ở vị trí chẵn là 3; 6; 9; 12; 15 nên số thứ mười là 15.', 'day_so', 12::int),
    (3::smallint, 'number', 'Lớp 2A có ba tổ: tổ Một ngồi vừa đủ 4 bàn, tổ Hai 6 bàn, tổ Ba 5 bàn. Mỗi bàn có 2 bạn. Lớp 2A có ___ bạn.', null, null, null, null, '30', null::jsonb, 'Tổ Một 8 bạn, tổ Hai 12 bạn, tổ Ba 10 bạn: 8 + 12 + 10 = 30.', 'bai_toan_hai_buoc', 13::int),
    (3::smallint, 'number', 'Ba bạn Nam, Bình, An, mỗi bạn mua 1 quả bóng đỏ và 1 quả bóng xanh. Ba bạn đã mua tất cả ___ quả bóng.', null, null, null, null, '6', null::jsonb, 'Mỗi bạn mua 2 quả; ba bạn mua 2 x 3 = 6 quả.', 'bai_toan_phep_nhan', 12::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 19 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 20: Phép nhân (tiếp theo). Bảng nhân 4, bảng nhân 5. Thừa số – tích (39 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 20, 100, 'Archimes: Phép nhân (tiếp theo). Bảng nhân 4, bảng nhân 5. Thừa số – tích', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 20', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '4 x 6 = ___', null, null, null, null, '24', null::jsonb, 'Bảng nhân 4: 4 x 6 = 24.', 'bang_nhan_4', 14::int),
    (1::smallint, 'number', '4 x 9 = ___', null, null, null, null, '36', null::jsonb, 'Bảng nhân 4: 4 x 9 = 36.', 'bang_nhan_4', 14::int),
    (1::smallint, 'number', '5 x 7 = ___', null, null, null, null, '35', null::jsonb, 'Bảng nhân 5: 5 x 7 = 35.', 'bang_nhan_5', 14::int),
    (1::smallint, 'number', '5 x 9 = ___', null, null, null, null, '45', null::jsonb, 'Bảng nhân 5: 5 x 9 = 45.', 'bang_nhan_5', 14::int),
    (1::smallint, 'number', '5 x 10 = ___', null, null, null, null, '50', null::jsonb, 'Bảng nhân 5: 5 x 10 = 50.', 'bang_nhan_5', 14::int),
    (1::smallint, 'multiple_choice', 'Trong phép tính 3 x 5 = 15, số 15 được gọi là:', 'Tích', 'Thừa số', 'Tổng', 'Số hạng', 'Tích', null::jsonb, 'Kết quả của phép nhân gọi là tích.', 'thanh_phan_phep_nhan', 21::int),
    (1::smallint, 'multiple_choice', 'Phép nhân nào có kết quả bằng 20?', '4 x 4', '4 x 5', '3 x 7', '2 x 9', '4 x 5', null::jsonb, '4 x 5 = 20.', 'bang_nhan_4', 15::int),
    (1::smallint, 'multiple_choice', 'Phép nhân nào có kết quả bằng 24?', '4 x 5', '3 x 7', '3 x 8', '2 x 10', '3 x 8', null::jsonb, '3 x 8 = 24.', 'bang_nhan_3', 15::int),
    (1::smallint, 'number', '4 x 1 x 2 = ___', null, null, null, null, '8', null::jsonb, '4 x 1 = 4, 4 x 2 = 8.', 'bang_nhan_4', 15::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 4 x 3 ___ 3 x 4', '=', '>', '<', null, '=', null::jsonb, 'Đổi chỗ các thừa số thì tích không đổi: cả hai bằng 12.', 'so_sanh', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 4 x 10 ___ 5 x 9', '>', '<', '=', null, '<', null::jsonb, '4 x 10 = 40, 5 x 9 = 45, mà 40 < 45.', 'so_sanh', 22::int),
    (1::smallint, 'number', '5 + 5 + 5 + 5 = 5 x ___', null, null, null, null, '4', null::jsonb, 'Số 5 được lấy 4 lần nên viết là 5 x 4.', 'viet_tong_thanh_tich', 19::int),
    (1::smallint, 'text', 'Trong phép nhân 4 x 7 = 28, số 4 và số 7 được gọi là các ___.', null, null, null, null, 'thừa số', null::jsonb, '4 và 7 là các thừa số, 28 là tích.', 'thanh_phan_phep_nhan', 19::int),
    (2::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): 5 x 2 + 5 = 5 + 5 + 5. ___', null, null, null, null, 'Đ', '["đúng"]'::jsonb, '5 x 2 + 5 = 10 + 5 = 15 và 5 + 5 + 5 = 15.', 'thua_so_tich', 22::int),
    (2::smallint, 'number', '4 x 8 + 29 = ___', null, null, null, null, '61', null::jsonb, '4 x 8 = 32, 32 + 29 = 61.', 'thu_tu_phep_tinh', 15::int),
    (2::smallint, 'number', '91 - 4 x 3 = ___', null, null, null, null, '79', null::jsonb, '4 x 3 = 12, 91 - 12 = 79.', 'thu_tu_phep_tinh', 15::int),
    (2::smallint, 'number', '5 x 7 - 23 = ___', null, null, null, null, '12', null::jsonb, '5 x 7 = 35, 35 - 23 = 12.', 'thu_tu_phep_tinh', 17::int),
    (2::smallint, 'number', '5 x 9 + 47 = ___', null, null, null, null, '92', null::jsonb, '5 x 9 = 45, 45 + 47 = 92.', 'thu_tu_phep_tinh', 21::int),
    (2::smallint, 'number', 'Mỗi khay táo có 4 quả. 8 khay như thế có ___ quả táo.', null, null, null, null, '32', null::jsonb, '4 x 8 = 32 (quả táo).', 'bai_toan_phep_nhan', 16::int),
    (2::smallint, 'number', 'Mỗi thùng mì nặng 4 kg. 6 thùng mì như thế nặng tất cả ___ kg.', null, null, null, null, '24', null::jsonb, '4 x 6 = 24 (kg).', 'bai_toan_phep_nhan', 16::int),
    (2::smallint, 'number', 'Mỗi túi gạo có 5 kg gạo. 10 túi như thế có tất cả ___ kg gạo.', null, null, null, null, '50', null::jsonb, '5 x 10 = 50 (kg).', 'bai_toan_phep_nhan', 21::int),
    (2::smallint, 'number', 'Mỗi nhóm có 5 học sinh. 8 nhóm như thế có tất cả ___ học sinh.', null, null, null, null, '40', null::jsonb, '5 x 8 = 40 (học sinh).', 'bai_toan_phep_nhan', 21::int),
    (2::smallint, 'number', 'Mỗi can đựng 3 l dầu. 6 can như thế đựng tất cả ___ l dầu.', null, null, null, null, '18', null::jsonb, '3 x 6 = 18 (l).', 'bai_toan_phep_nhan', 21::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 5 x 4 + 5 ___ 5 x 6', '>', '=', '<', null, '<', null::jsonb, '5 x 4 + 5 = 25, 5 x 6 = 30, mà 25 < 30.', 'so_sanh', 22::int),
    (2::smallint, 'multiple_choice', 'Viết 4 x 3 + 4 x 2 thành tích của hai thừa số:', '4 x 6', '8 x 5', '4 x 1', '4 x 5', '4 x 5', null::jsonb, '4 được lấy 3 lần rồi thêm 2 lần, tất cả 5 lần: 4 x 5.', 'thua_so_tich', 19::int),
    (2::smallint, 'number', '5 x 4 + 5 x 6 = 5 x ___', null, null, null, null, '10', null::jsonb, '5 được lấy 4 lần rồi thêm 6 lần, tất cả 10 lần.', 'thua_so_tich', 19::int),
    (2::smallint, 'number', '5 x 6 - 5 x 1 = 5 x ___', null, null, null, null, '5', null::jsonb, '5 được lấy 6 lần, bớt đi 1 lần, còn 5 lần.', 'thua_so_tich', 19::int),
    (3::smallint, 'number', 'Năm nay Lan 4 tuổi, tuổi chị Mai bằng tuổi Lan nhân với 2. Khi Lan bằng tuổi chị Mai hiện nay thì chị Mai ___ tuổi.', null, null, null, null, '12', null::jsonb, 'Chị Mai 8 tuổi, hơn Lan 4 tuổi. Khi Lan 8 tuổi thì chị Mai 8 + 4 = 12 tuổi.', 'bai_toan_tuoi', 16::int),
    (3::smallint, 'number', 'Năm nay Bình 5 tuổi, tuổi mẹ bằng tuổi Bình nhân với 6, tuổi bố bằng tuổi Bình nhân với 7. Tổng số tuổi của ba người là ___ tuổi.', null, null, null, null, '70', null::jsonb, 'Mẹ 30 tuổi, bố 35 tuổi: 5 + 30 + 35 = 70.', 'bai_toan_tuoi', 17::int),
    (3::smallint, 'number', 'Ba bạn Bắc, Trung, Nam, mỗi bạn viết thư cho năm bạn An, Hòa, Bình, Đông, Thu. Có tất cả ___ lá thư.', null, null, null, null, '15', null::jsonb, 'Mỗi bạn viết 5 lá, ba bạn viết 5 x 3 = 15 lá.', 'suy_luan', 18::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó nhân với 5 rồi trừ đi 12 thì bằng 38. Số đó là ___.', null, null, null, null, '10', null::jsonb, 'Trước khi trừ 12 là 38 + 12 = 50; 50 = 10 x 5 nên số đó là 10.', 'tim_so', 18::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó nhân với 4 rồi cộng với 28 thì bằng 60. Số đó là ___.', null, null, null, null, '8', null::jsonb, 'Trước khi cộng 28 là 60 - 28 = 32; 32 = 8 x 4 nên số đó là 8.', 'tim_so', 18::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 27 và tổng bằng 12 là:', '1 và 27', '4 và 8', '5 và 7', '3 và 9', '3 và 9', null::jsonb, '3 x 9 = 27 và 3 + 9 = 12.', 'tim_hai_so', 18::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 20 và hiệu bằng 1 là:', '4 và 5', '2 và 10', '1 và 20', '5 và 6', '4 và 5', null::jsonb, '4 x 5 = 20 và 5 - 4 = 1.', 'tim_hai_so', 18::int),
    (3::smallint, 'number', 'Trong phép nhân số 4 với một số, An sửa số 4 thành số 2, thừa số còn lại giữ nguyên nên tích là 10. Tích ban đầu là ___.', null, null, null, null, '20', null::jsonb, 'Thừa số còn lại là 5 (vì 2 x 5 = 10). Tích ban đầu là 4 x 5 = 20.', 'thua_so_tich', 20::int),
    (3::smallint, 'number', 'Điền số thích hợp: 4 x ___ + 16 = 52', null, null, null, null, '9', null::jsonb, '4 x ___ = 52 - 16 = 36, mà 4 x 9 = 36.', 'tim_so', 21::int),
    (3::smallint, 'number', 'Tìm số thứ mười trong dãy số: 4; 5; 8; 10; 12; 15; 16; ... Số thứ mười là ___.', null, null, null, null, '25', null::jsonb, 'Các số ở vị trí chẵn là 5; 10; 15; 20; 25 nên số thứ mười là 25.', 'day_so', 21::int),
    (3::smallint, 'number', 'Có 5 con đường đi từ nhà Lan đến nhà Hồng và 3 con đường đi từ nhà Hồng đến nhà Mai. Có ___ cách đi từ nhà Lan đến nhà Mai mà phải đi qua nhà Hồng.', null, null, null, null, '15', null::jsonb, 'Mỗi đường đến nhà Hồng lại có 3 đường đến nhà Mai: 5 x 3 = 15 cách.', 'suy_luan', 22::int),
    (3::smallint, 'multiple_choice', 'Số có hai chữ số, biết chữ số hàng đơn vị bằng chữ số hàng chục nhân với 5, là:', '51', '15', '10', '25', '15', null::jsonb, 'Hàng chục là 1 thì hàng đơn vị là 1 x 5 = 5; hàng chục là 2 thì 2 x 5 = 10 (không được).', 'cau_tao_so', 19::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 20 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 21: Đường gấp khúc. Lập số – dãy số (38 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 21, 100, 'Archimes: Đường gấp khúc. Lập số – dãy số', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 21', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Đường gấp khúc EGHI có EG = 2 cm, GH = 3 cm, HI = 4 cm. Độ dài đường gấp khúc EGHI là ___ cm.', null, null, null, null, '9', null::jsonb, '2 + 3 + 4 = 9 (cm).', 'duong_gap_khuc', 24::int),
    (1::smallint, 'number', 'Đường gấp khúc ABCD có AB + BC = 36 cm, đoạn CD dài 25 cm. Độ dài đường gấp khúc ABCD là ___ cm.', null, null, null, null, '61', null::jsonb, '36 + 25 = 61 (cm).', 'duong_gap_khuc', 25::int),
    (1::smallint, 'number', 'Đường gấp khúc ABCDA có AB = 2 cm, BC = 4 cm, CD = 6 cm, DA = 3 cm. Độ dài đường gấp khúc ABCDA là ___ cm.', null, null, null, null, '15', null::jsonb, '2 + 4 + 6 + 3 = 15 (cm).', 'duong_gap_khuc', 27::int),
    (1::smallint, 'multiple_choice', 'Độ dài đường gấp khúc bằng:', 'Độ dài đoạn thẳng dài nhất', 'Tổng độ dài các đoạn thẳng', 'Hiệu độ dài các đoạn thẳng', 'Số đoạn thẳng', 'Tổng độ dài các đoạn thẳng', null::jsonb, 'Độ dài đường gấp khúc bằng tổng độ dài các đoạn thẳng của nó.', 'duong_gap_khuc', 23::int),
    (1::smallint, 'number', 'Số có chữ số hàng chục là 4, chữ số hàng đơn vị là 7 là số ___.', null, null, null, null, '47', null::jsonb, '4 chục và 7 đơn vị là 47.', 'cau_tao_so', 23::int),
    (1::smallint, 'multiple_choice', 'Dãy số 37; 33; 29; 25; ... Số tiếp theo là:', '22', '20', '21', '23', '21', null::jsonb, 'Mỗi số kém số trước 4 đơn vị: 25 - 4 = 21.', 'day_so', 31::int),
    (1::smallint, 'number', 'Viết số tiếp theo của dãy: 46; 41; 36; 31; ___', null, null, null, null, '26', null::jsonb, 'Mỗi số kém số trước 5 đơn vị: 31 - 5 = 26.', 'day_so', 31::int),
    (1::smallint, 'number', 'Viết số tiếp theo của dãy: 23; 34; 45; ___', null, null, null, null, '56', null::jsonb, 'Mỗi số hơn số trước 11 đơn vị: 45 + 11 = 56.', 'day_so', 31::int),
    (1::smallint, 'number', 'Một đường gấp khúc gồm 5 đoạn thẳng, mỗi đoạn dài 5 cm. Độ dài đường gấp khúc là ___ cm.', null, null, null, null, '25', null::jsonb, 'Các đoạn bằng nhau: 5 x 5 = 25 (cm).', 'duong_gap_khuc', 27::int),
    (1::smallint, 'number', 'Đường gấp khúc MNP có MN = 5 cm, NP = 3 cm. Độ dài đường gấp khúc MNP là ___ cm.', null, null, null, null, '8', null::jsonb, '5 + 3 = 8 (cm).', 'duong_gap_khuc', 26::int),
    (1::smallint, 'multiple_choice', 'Cho dãy số 2; 4; 6; 8; ... Số nào dưới đây có trong dãy?', '79', '77', '81', '78', '78', null::jsonb, 'Dãy gồm các số chẵn; trong các số đã cho chỉ 78 là số chẵn.', 'day_so', 31::int),
    (2::smallint, 'text', 'Cho dãy số 2; 4; 6; 8; ... Điền Đ (đúng) hoặc S (sai): Số 79 là số hạng của dãy. ___', null, null, null, null, 'S', '["sai"]'::jsonb, 'Dãy gồm các số chẵn, còn 79 là số lẻ nên không thuộc dãy.', 'day_so', 31::int),
    (2::smallint, 'multiple_choice', 'Đường gấp khúc ABCD gồm mấy đoạn thẳng?', '3 đoạn thẳng', '4 đoạn thẳng', '2 đoạn thẳng', '5 đoạn thẳng', '3 đoạn thẳng', null::jsonb, 'ABCD gồm các đoạn AB, BC, CD.', 'duong_gap_khuc', 24::int),
    (2::smallint, 'number', 'Đường gấp khúc MNPQ có MN = 8 cm, NP = 1 dm, PQ = 4 cm. Độ dài đường gấp khúc MNPQ là ___ cm.', null, null, null, null, '22', null::jsonb, 'Đổi 1 dm = 10 cm; 8 + 10 + 4 = 22 (cm).', 'duong_gap_khuc', 25::int),
    (2::smallint, 'number', 'Đường gấp khúc ABCD có AB = 18 cm, BC = 20 cm, CD ngắn hơn BC 1 cm. Độ dài đường gấp khúc ABCD là ___ cm.', null, null, null, null, '57', null::jsonb, 'CD = 20 - 1 = 19 cm; 18 + 20 + 19 = 57 (cm).', 'duong_gap_khuc', 26::int),
    (2::smallint, 'number', 'Một đường gấp khúc gồm hai đoạn thẳng, dài 31 dm. Đoạn thẳng thứ nhất dài 15 dm. Đoạn thẳng thứ hai dài ___ dm.', null, null, null, null, '16', null::jsonb, '31 - 15 = 16 (dm).', 'duong_gap_khuc', 26::int),
    (2::smallint, 'number', 'Đường gấp khúc MNPQR có MN = 5 cm, NP = 3 cm, PQ = 4 cm, QR = 3 cm. Độ dài đường gấp khúc NPQR là ___ cm.', null, null, null, null, '10', null::jsonb, 'NPQR gồm NP, PQ, QR: 3 + 4 + 3 = 10 (cm).', 'duong_gap_khuc', 26::int),
    (2::smallint, 'number', 'Đường gấp khúc MNPQR có MN = 5 cm, NP = 3 cm, PQ = 4 cm, QR = 3 cm. Độ dài đường gấp khúc MNPQR là ___ cm.', null, null, null, null, '15', null::jsonb, '5 + 3 + 4 + 3 = 15 (cm).', 'duong_gap_khuc', 26::int),
    (2::smallint, 'number', 'Đường gấp khúc hình ngôi sao gồm 10 đoạn thẳng dài bằng nhau, mỗi đoạn 2 cm. Độ dài đường gấp khúc đó là ___ cm.', null, null, null, null, '20', null::jsonb, '2 x 10 = 20 (cm).', 'duong_gap_khuc', 28::int),
    (2::smallint, 'multiple_choice', 'Đường gấp khúc ABC có AB = 5 cm, BC = 3 cm. Đường gấp khúc CDE có CD = 4 cm, DE = 5 cm. So sánh: độ dài ABC ___ độ dài CDE', '>', '=', '<', null, '<', null::jsonb, 'ABC dài 8 cm, CDE dài 9 cm, mà 8 < 9.', 'duong_gap_khuc', 28::int),
    (2::smallint, 'number', 'Mỗi học sinh được thưởng 4 quyển vở. 7 học sinh được thưởng ___ quyển vở.', null, null, null, null, '28', null::jsonb, '4 x 7 = 28 (quyển vở).', 'bai_toan_phep_nhan', 32::int),
    (2::smallint, 'number', '5 x 9 + 27 = ___', null, null, null, null, '72', null::jsonb, '5 x 9 = 45, 45 + 27 = 72.', 'thu_tu_phep_tinh', 32::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 2 x 9 + 12 ___ 5 x 9 - 16', '>', '<', '=', null, '>', null::jsonb, '2 x 9 + 12 = 30, 5 x 9 - 16 = 29, mà 30 > 29.', 'so_sanh', 33::int),
    (2::smallint, 'multiple_choice', 'Cho dãy số 13; 17; 21; 25; ... Hai số tiếp theo lần lượt là:', '28; 31', '29; 32', '30; 35', '29; 33', '29; 33', null::jsonb, 'Mỗi số hơn số trước 4 đơn vị: 25 + 4 = 29, 29 + 4 = 33.', 'day_so', 32::int),
    (2::smallint, 'number', 'An chia hộp bi ra ba phần bằng nhau, mỗi phần được 5 viên bi. Hộp bi của An có ___ viên bi.', null, null, null, null, '15', null::jsonb, '5 x 3 = 15 (viên bi).', 'bai_toan_phep_nhan', 32::int),
    (3::smallint, 'number', 'Một đường gấp khúc gồm hai đoạn thẳng, đoạn thứ nhất dài 27 cm, đoạn thứ hai dài hơn đoạn thứ nhất 24 cm. Độ dài đường gấp khúc là ___ cm.', null, null, null, null, '78', null::jsonb, 'Đoạn thứ hai: 27 + 24 = 51 cm; độ dài: 27 + 51 = 78 (cm).', 'duong_gap_khuc', 25::int),
    (3::smallint, 'number', 'Đường gấp khúc ABCD có AB = 2 dm 5 cm, BC dài hơn AB 8 cm và ngắn hơn CD 9 cm. Độ dài đường gấp khúc ABCD là ___ cm.', null, null, null, null, '100', null::jsonb, 'AB = 25 cm, BC = 33 cm, CD = 42 cm; 25 + 33 + 42 = 100 (cm).', 'duong_gap_khuc', 27::int),
    (3::smallint, 'multiple_choice', 'Hai đường gấp khúc ABC và MNP dài bằng nhau, đoạn AB dài hơn đoạn MN. So sánh BC và NP:', 'BC dài hơn NP', 'BC ngắn hơn NP', 'BC bằng NP', null, 'BC ngắn hơn NP', null::jsonb, 'Tổng bằng nhau mà AB dài hơn MN thì BC phải ngắn hơn NP.', 'suy_luan', 28::int),
    (3::smallint, 'number', 'Lấy chữ số 3 hoặc 4 làm chữ số hàng chục, chữ số 7, 8 hoặc 9 làm chữ số hàng đơn vị. Viết được tất cả ___ số có hai chữ số.', null, null, null, null, '6', null::jsonb, 'Mỗi chữ số hàng chục ghép được với 3 chữ số hàng đơn vị: 2 x 3 = 6 số.', 'lap_so', 30::int),
    (3::smallint, 'number', 'Từ ba chữ số 2; 3; 6 viết các số có hai chữ số khác nhau. Tổng của số lớn nhất và số bé nhất viết được là ___.', null, null, null, null, '86', null::jsonb, 'Số lớn nhất là 63, số bé nhất là 23; 63 + 23 = 86.', 'lap_so', 30::int),
    (3::smallint, 'number', 'Từ ba chữ số 0; 2; 3 viết được ___ số có hai chữ số khác nhau.', null, null, null, null, '4', null::jsonb, 'Các số đó là 20; 23; 30; 32 (chữ số 0 không đứng ở hàng chục).', 'lap_so', 30::int),
    (3::smallint, 'number', 'Từ bốn chữ số 0; 1; 2; 3 viết được ___ số có hai chữ số khác nhau.', null, null, null, null, '9', null::jsonb, 'Hàng chục có 3 cách (1, 2, 3), mỗi cách ghép với 3 chữ số còn lại: 3 x 3 = 9 số.', 'lap_so', 30::int),
    (3::smallint, 'number', 'Để viết các số từ 0 đến 14 phải dùng tất cả ___ chữ số.', null, null, null, null, '20', null::jsonb, 'Từ 0 đến 9 dùng 10 chữ số; từ 10 đến 14 có 5 số, mỗi số 2 chữ số: 10 + 10 = 20.', 'day_so', 31::int),
    (3::smallint, 'number', 'Viết số tiếp theo của dãy: 88; 85; 79; 70; ___', null, null, null, null, '58', null::jsonb, 'Các số lần lượt bớt đi 3, 6, 9 nên tiếp theo bớt 12: 70 - 12 = 58.', 'day_so', 31::int),
    (3::smallint, 'number', 'Thầy giáo có 45 quyển vở. Thầy thưởng cho 6 học sinh, mỗi bạn 4 quyển. Thầy còn lại ___ quyển vở.', null, null, null, null, '21', null::jsonb, 'Thầy thưởng 4 x 6 = 24 quyển; còn 45 - 24 = 21 quyển.', 'bai_toan_hai_buoc', 33::int),
    (3::smallint, 'number', 'Chia một bao gạo vào các túi, mỗi túi 3 kg thì được 10 túi và còn thừa 2 kg. Bao gạo có ___ kg.', null, null, null, null, '32', null::jsonb, '3 x 10 = 30 kg, thêm 2 kg thừa: 30 + 2 = 32 (kg).', 'bai_toan_hai_buoc', 33::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó nhân với 4 thì được số liền sau của số nhỏ nhất có hai chữ số giống nhau. Số đó là ___.', null, null, null, null, '3', null::jsonb, 'Số nhỏ nhất có hai chữ số giống nhau là 11, số liền sau là 12; 12 = 3 x 4.', 'tim_so', 32::int),
    (3::smallint, 'number', 'Đôi thỏ nhà Thu đẻ được 6 con. Chuồng thỏ nhà Thu có tất cả ___ cái chân thỏ.', null, null, null, null, '32', null::jsonb, 'Có 2 + 6 = 8 con thỏ, mỗi con 4 chân: 8 x 4 = 32.', 'bai_toan_hai_buoc', 32::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 21 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 22: Phép chia. Bảng chia 2. Một phần hai. Số bị chia – số chia – thương (43 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 22, 100, 'Archimes: Phép chia. Bảng chia 2. Một phần hai. Số bị chia – số chia – thương', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 22', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '8 : 2 = ___', null, null, null, null, '4', null::jsonb, 'Bảng chia 2: 8 : 2 = 4.', 'bang_chia_2', 34::int),
    (1::smallint, 'number', '14 : 2 = ___', null, null, null, null, '7', null::jsonb, 'Bảng chia 2: 14 : 2 = 7.', 'bang_chia_2', 34::int),
    (1::smallint, 'number', '18 : 2 = ___', null, null, null, null, '9', null::jsonb, 'Bảng chia 2: 18 : 2 = 9.', 'bang_chia_2', 34::int),
    (1::smallint, 'multiple_choice', 'Trong phép chia 6 : 2 = 3, số 2 được gọi là:', 'Số bị chia', 'Thương', 'Số chia', 'Thừa số', 'Số chia', null::jsonb, '6 là số bị chia, 2 là số chia, 3 là thương.', 'thanh_phan_phep_chia', 34::int),
    (1::smallint, 'multiple_choice', 'Từ phép nhân 2 x 4 = 8, ta viết được phép chia nào?', '8 : 8 = 1', '4 : 2 = 2', '8 : 4 = 4', '8 : 2 = 4', '8 : 2 = 4', null::jsonb, 'Phép chia là phép tính ngược của phép nhân: 8 : 2 = 4 và 8 : 4 = 2.', 'phep_chia', 34::int),
    (1::smallint, 'number', 'Một nửa của 14 dm là ___ dm.', null, null, null, null, '7', null::jsonb, 'Một nửa của 14 dm là 14 : 2 = 7 (dm).', 'mot_phan_hai', 34::int),
    (1::smallint, 'number', '1/2 của 20 kg là ___ kg.', null, null, null, null, '10', null::jsonb, '20 : 2 = 10 (kg).', 'mot_phan_hai', 37::int),
    (1::smallint, 'number', '1/2 của 18 l là ___ l.', null, null, null, null, '9', null::jsonb, '18 : 2 = 9 (l).', 'mot_phan_hai', 37::int),
    (1::smallint, 'number', '1/2 của 12 dm là ___ dm.', null, null, null, null, '6', null::jsonb, '12 : 2 = 6 (dm).', 'mot_phan_hai', 37::int),
    (1::smallint, 'multiple_choice', 'Một phần hai còn được gọi là:', 'Một nửa', 'Một đôi', 'Một phần ba', 'Gấp đôi', 'Một nửa', null::jsonb, 'Một phần hai còn gọi là một nửa.', 'mot_phan_hai', 34::int),
    (1::smallint, 'number', 'Số bị chia là 16, số chia là 2. Thương là ___.', null, null, null, null, '8', null::jsonb, '16 : 2 = 8.', 'thanh_phan_phep_chia', 39::int),
    (1::smallint, 'text', 'Trong phép chia 14 : 2 = 7, số 7 được gọi là ___.', null, null, null, null, 'thương', null::jsonb, 'Kết quả của phép chia gọi là thương.', 'thanh_phan_phep_chia', 39::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 1/2 của 18 ___ 1/2 của 16', '<', '>', '=', null, '>', null::jsonb, '1/2 của 18 là 9, 1/2 của 16 là 8, mà 9 > 8.', 'mot_phan_hai', 37::int),
    (2::smallint, 'multiple_choice', 'Có 10 cái kẹo chia đều cho 2 bạn. Phép tính tìm số kẹo mỗi bạn là:', '10 - 2 = 8', '10 x 2 = 20', '10 : 2 = 5', '10 + 2 = 12', '10 : 2 = 5', null::jsonb, 'Chia đều cho 2 bạn thì lấy 10 : 2 = 5 (cái).', 'bai_toan_phep_chia', 35::int),
    (2::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): 1/2 của 10 l là 20 l. ___', null, null, null, null, 'S', '["sai"]'::jsonb, '1/2 của 10 l là 10 : 2 = 5 l.', 'mot_phan_hai', 37::int),
    (2::smallint, 'number', '16 : 2 + 23 = ___', null, null, null, null, '31', null::jsonb, 'Chia trước: 16 : 2 = 8, rồi 8 + 23 = 31.', 'thu_tu_phep_tinh', 35::int),
    (2::smallint, 'number', '81 - 18 : 2 = ___', null, null, null, null, '72', null::jsonb, '18 : 2 = 9, 81 - 9 = 72.', 'thu_tu_phep_tinh', 35::int),
    (2::smallint, 'number', '4 x 5 : 2 = ___', null, null, null, null, '10', null::jsonb, 'Tính từ trái sang phải: 4 x 5 = 20, 20 : 2 = 10.', 'thu_tu_phep_tinh', 35::int),
    (2::smallint, 'number', 'Có 8 quả táo được chia đều vào 2 túi. Mỗi túi có ___ quả táo.', null, null, null, null, '4', null::jsonb, '8 : 2 = 4 (quả táo).', 'bai_toan_phep_chia', 35::int),
    (2::smallint, 'number', 'Có 20 học sinh xếp thành các hàng, mỗi hàng có 2 bạn. Xếp được ___ hàng.', null, null, null, null, '10', null::jsonb, '20 : 2 = 10 (hàng).', 'bai_toan_phep_chia', 35::int),
    (2::smallint, 'number', 'Năm nay anh 12 tuổi, tuổi anh bằng tuổi em nhân với 2. Năm nay em ___ tuổi.', null, null, null, null, '6', null::jsonb, '12 : 2 = 6 (tuổi).', 'bai_toan_phep_chia', 35::int),
    (2::smallint, 'number', 'Lan có 18 que tính. Hồng có số que tính bằng 1/2 số que tính của Lan. Hồng có ___ que tính.', null, null, null, null, '9', null::jsonb, '18 : 2 = 9 (que tính).', 'mot_phan_hai', 37::int),
    (2::smallint, 'number', 'Một thước dây dài 100 cm. Một nửa thước dây đó dài ___ dm.', null, null, null, null, '5', null::jsonb, 'Một nửa là 100 : 2 = 50 cm = 5 dm.', 'mot_phan_hai', 41::int),
    (2::smallint, 'number', 'Ông chia đều số kẹo cho hai cháu thì mỗi cháu được 7 cái. Ông có ___ cái kẹo.', null, null, null, null, '14', null::jsonb, '7 x 2 = 14 (cái kẹo).', 'tim_so_bi_chia', 41::int),
    (2::smallint, 'number', '1/2 túi gạo nặng 5 kg. Cả túi gạo nặng ___ kg.', null, null, null, null, '10', null::jsonb, 'Cả túi gấp đôi nửa túi: 5 x 2 = 10 (kg).', 'mot_phan_hai', 39::int),
    (2::smallint, 'number', 'Số bị chia là ___, số chia là 2, thương là 7.', null, null, null, null, '14', null::jsonb, 'Số bị chia = thương x số chia = 7 x 2 = 14.', 'thanh_phan_phep_chia', 39::int),
    (2::smallint, 'number', 'Điền số tiếp theo của dãy: 48; 24; 12; 6; ___', null, null, null, null, '3', null::jsonb, 'Mỗi số bằng một nửa số trước: 6 : 2 = 3.', 'day_so', 41::int),
    (2::smallint, 'number', 'An cắt một mảnh giấy thành 6 mảnh nhỏ, rồi cắt mỗi mảnh nhỏ thành 2 mảnh nữa. An có tất cả ___ mảnh giấy.', null, null, null, null, '12', null::jsonb, '6 x 2 = 12 (mảnh giấy).', 'suy_luan', 38::int),
    (3::smallint, 'number', 'Nam có hai chục viên bi. Nam cho em 4 viên rồi chia đều số bi còn lại vào 2 túi. Mỗi túi có ___ viên bi.', null, null, null, null, '8', null::jsonb, 'Còn 20 - 4 = 16 viên; 16 : 2 = 8 (viên).', 'bai_toan_hai_buoc', 36::int),
    (3::smallint, 'number', 'Mẹ cho Lan 15 cái kẹo, bố cho thêm 3 cái. Lan chia số kẹo đó thành hai phần bằng nhau. Mỗi phần có ___ cái kẹo.', null, null, null, null, '9', null::jsonb, 'Có 15 + 3 = 18 cái; 18 : 2 = 9 (cái).', 'bai_toan_hai_buoc', 36::int),
    (3::smallint, 'number', 'Bố mua 16 quyển truyện, mẹ mua thêm 4 quyển. Số truyện được chia đều cho hai anh em. Mỗi người nhận được ___ quyển.', null, null, null, null, '10', null::jsonb, 'Có 16 + 4 = 20 quyển; 20 : 2 = 10 (quyển).', 'bai_toan_hai_buoc', 36::int),
    (3::smallint, 'number', 'Oanh gấp được 16 con hạc. Số hạc Hồng gấp bằng 1/2 số hạc của Oanh. Cả hai bạn gấp được ___ con hạc.', null, null, null, null, '24', null::jsonb, 'Hồng gấp 16 : 2 = 8 con; cả hai: 16 + 8 = 24 (con).', 'mot_phan_hai', 38::int),
    (3::smallint, 'number', 'Bình có 36 viên bi xanh, đỏ, vàng. Có 12 viên bi xanh, số bi đỏ bằng 1/2 số bi xanh. Bình có ___ viên bi vàng.', null, null, null, null, '18', null::jsonb, 'Bi đỏ: 12 : 2 = 6 viên; bi vàng: 36 - 12 - 6 = 18 (viên).', 'mot_phan_hai', 38::int),
    (3::smallint, 'number', 'Một bao gạo nặng 42 kg. Lần thứ nhất lấy ra 22 kg, lần thứ hai lấy tiếp 1/2 số gạo còn lại. Trong bao còn ___ kg gạo.', null, null, null, null, '10', null::jsonb, 'Sau lần một còn 20 kg; lần hai lấy 10 kg; còn 20 - 10 = 10 (kg).', 'mot_phan_hai', 39::int),
    (3::smallint, 'number', 'Biết 1/2 số bi xanh là 7 viên, 1/2 số bi đỏ là 9 viên. Tổng số bi xanh và bi đỏ là ___ viên.', null, null, null, null, '32', null::jsonb, 'Bi xanh 14 viên, bi đỏ 18 viên; 14 + 18 = 32 (viên).', 'mot_phan_hai', 40::int),
    (3::smallint, 'number', 'Biết 1/2 số tuổi anh là 5 tuổi, 1/2 số tuổi em là 3 tuổi. Anh hơn em ___ tuổi.', null, null, null, null, '4', null::jsonb, 'Anh 10 tuổi, em 6 tuổi; 10 - 6 = 4 (tuổi).', 'mot_phan_hai', 40::int),
    (3::smallint, 'number', 'Xếp vào mỗi hộp 2 chiếc cốc thì được 8 hộp và thừa 1 chiếc cốc. Có tất cả ___ chiếc cốc.', null, null, null, null, '17', null::jsonb, '2 x 8 = 16, thêm 1 chiếc thừa: 17 (chiếc).', 'bai_toan_hai_buoc', 41::int),
    (3::smallint, 'number', 'Hưng có 8 thẻ bài và bằng một nửa số thẻ bài của Hoàn. Cả hai bạn có tất cả ___ thẻ bài.', null, null, null, null, '24', null::jsonb, 'Hoàn có 8 x 2 = 16 thẻ; cả hai: 8 + 16 = 24 (thẻ).', 'mot_phan_hai', 41::int),
    (3::smallint, 'number', 'Chi làm được 10 bông hoa xanh. Số hoa xanh ít hơn hoa đỏ 5 bông và bằng một nửa số hoa vàng. Chi làm được tất cả ___ bông hoa.', null, null, null, null, '45', null::jsonb, 'Hoa đỏ 15 bông, hoa vàng 20 bông; 10 + 15 + 20 = 45 (bông).', 'bai_toan_hai_buoc', 42::int),
    (3::smallint, 'number', 'Linh cho Vân 1/2 số ngôi sao của mình thì Linh còn lại 9 ngôi sao. Lúc đầu Linh có ___ ngôi sao.', null, null, null, null, '18', null::jsonb, 'Cho đi một nửa thì còn một nửa là 9; lúc đầu có 9 x 2 = 18.', 'mot_phan_hai', 42::int),
    (3::smallint, 'number', 'Tìm y, biết: 18 + y = 40 : 2. y = ___', null, null, null, null, '2', null::jsonb, '40 : 2 = 20; y = 20 - 18 = 2.', 'tim_x', 42::int),
    (3::smallint, 'number', 'Tìm x, biết: x - 25 = 18 : 2. x = ___', null, null, null, null, '34', null::jsonb, '18 : 2 = 9; x = 9 + 25 = 34.', 'tim_x', 37::int),
    (3::smallint, 'number', 'Lập được bao nhiêu số chẵn có hai chữ số khác nhau từ hai trong năm chữ số 0; 1; 2; 6; 9? Trả lời: ___ số.', null, null, null, null, '10', null::jsonb, 'Tận cùng 0: 10, 20, 60, 90; tận cùng 2: 12, 62, 92; tận cùng 6: 16, 26, 96. Có 10 số.', 'lap_so', 41::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 22 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 23: Tìm thừa số chưa biết của phép nhân. Bảng chia 3. Một phần ba (47 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 23, 100, 'Archimes: Tìm thừa số chưa biết của phép nhân. Bảng chia 3. Một phần ba', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 23', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '21 : 3 = ___', null, null, null, null, '7', null::jsonb, 'Bảng chia 3: 21 : 3 = 7.', 'bang_chia_3', 43::int),
    (1::smallint, 'number', '27 : 3 = ___', null, null, null, null, '9', null::jsonb, 'Bảng chia 3: 27 : 3 = 9.', 'bang_chia_3', 43::int),
    (1::smallint, 'number', '12 : 3 = ___', null, null, null, null, '4', null::jsonb, 'Bảng chia 3: 12 : 3 = 4.', 'bang_chia_3', 43::int),
    (1::smallint, 'number', '15 dm : 3 = ___ dm', null, null, null, null, '5', null::jsonb, '15 : 3 = 5 nên 15 dm : 3 = 5 dm.', 'bang_chia_3', 44::int),
    (1::smallint, 'number', '18 phút : 3 = ___ phút', null, null, null, null, '6', null::jsonb, '18 : 3 = 6 nên 18 phút : 3 = 6 phút.', 'bang_chia_3', 44::int),
    (1::smallint, 'number', '9 cm : 3 = ___ cm', null, null, null, null, '3', null::jsonb, '9 : 3 = 3 nên 9 cm : 3 = 3 cm.', 'bang_chia_3', 44::int),
    (1::smallint, 'number', '1/3 của 12 l là ___ l.', null, null, null, null, '4', null::jsonb, '12 : 3 = 4 (l).', 'mot_phan_ba', 43::int),
    (1::smallint, 'number', '1/3 của 21 là ___.', null, null, null, null, '7', null::jsonb, '21 : 3 = 7.', 'mot_phan_ba', 46::int),
    (1::smallint, 'number', '1/3 của 27 l sữa là ___ l sữa.', null, null, null, null, '9', null::jsonb, '27 : 3 = 9 (l).', 'mot_phan_ba', 50::int),
    (1::smallint, 'multiple_choice', 'Muốn tìm một thừa số, ta lấy:', 'Tích nhân với thừa số kia', 'Tích trừ đi thừa số kia', 'Thừa số kia chia cho tích', 'Tích chia cho thừa số kia', 'Tích chia cho thừa số kia', null::jsonb, 'Muốn tìm một thừa số ta lấy tích chia cho thừa số kia.', 'tim_thua_so', 43::int),
    (1::smallint, 'number', 'Số bị chia là 24, số chia là 3. Thương là ___.', null, null, null, null, '8', null::jsonb, '24 : 3 = 8.', 'bang_chia_3', 44::int),
    (1::smallint, 'multiple_choice', 'Một phần ba viết là:', '1/3', '3/1', '1/2', '3', '1/3', null::jsonb, 'Một phần ba viết là 1/3.', 'mot_phan_ba', 43::int),
    (1::smallint, 'text', 'Trong phép nhân y x 3 = 15, y được gọi là ___ chưa biết.', null, null, null, null, 'thừa số', null::jsonb, 'y và 3 là các thừa số, 15 là tích.', 'tim_thua_so', 43::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 1/3 của 18 ___ 1/2 của 12', '>', '<', '=', null, '=', null::jsonb, '1/3 của 18 là 6, 1/2 của 12 cũng là 6.', 'mot_phan_ba', 46::int),
    (2::smallint, 'multiple_choice', 'Tìm y, biết: y x 3 = 15. Giá trị của y là:', '45', '5', '12', '18', '5', null::jsonb, 'y = 15 : 3 = 5.', 'tim_thua_so', 48::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 24 : 3 ___ 3 x 3', '>', '<', '=', null, '<', null::jsonb, '24 : 3 = 8, 3 x 3 = 9, mà 8 < 9.', 'so_sanh', 44::int),
    (2::smallint, 'number', '5 x 6 : 3 = ___', null, null, null, null, '10', null::jsonb, '5 x 6 = 30, 30 : 3 = 10.', 'thu_tu_phep_tinh', 44::int),
    (2::smallint, 'number', '15 : 3 x 9 = ___', null, null, null, null, '45', null::jsonb, '15 : 3 = 5, 5 x 9 = 45.', 'thu_tu_phep_tinh', 44::int),
    (2::smallint, 'number', '91 - 18 : 3 = ___', null, null, null, null, '85', null::jsonb, '18 : 3 = 6, 91 - 6 = 85.', 'thu_tu_phep_tinh', 44::int),
    (2::smallint, 'number', '27 : 3 + 5 x 7 = ___', null, null, null, null, '44', null::jsonb, '27 : 3 = 9, 5 x 7 = 35, 9 + 35 = 44.', 'thu_tu_phep_tinh', 44::int),
    (2::smallint, 'number', 'Có 27 học sinh xếp thành 3 hàng bằng nhau. Mỗi hàng có ___ học sinh.', null, null, null, null, '9', null::jsonb, '27 : 3 = 9 (học sinh).', 'bai_toan_phep_chia', 44::int),
    (2::smallint, 'number', 'Có 12 người khách sang sông, mỗi thuyền chở 3 người khách. Cần ___ thuyền để chở hết số khách.', null, null, null, null, '4', null::jsonb, '12 : 3 = 4 (thuyền).', 'bai_toan_phep_chia', 45::int),
    (2::smallint, 'number', 'Tìm y, biết: 2 x y = 18. y = ___', null, null, null, null, '9', null::jsonb, 'y = 18 : 2 = 9.', 'tim_thua_so', 48::int),
    (2::smallint, 'number', 'Tìm y, biết: y x 3 = 24. y = ___', null, null, null, null, '8', null::jsonb, 'y = 24 : 3 = 8.', 'tim_thua_so', 48::int),
    (2::smallint, 'number', 'Cô giáo có 27 quyển vở, cô lấy 1/3 số vở để tặng An. An được tặng ___ quyển vở.', null, null, null, null, '9', null::jsonb, '27 : 3 = 9 (quyển).', 'mot_phan_ba', 46::int),
    (2::smallint, 'number', 'Một tổng gồm ba số hạng bằng nhau và tổng bằng 24. Mỗi số hạng bằng ___.', null, null, null, null, '8', null::jsonb, 'Số hạng x 3 = 24 nên số hạng = 24 : 3 = 8.', 'tim_thua_so', 48::int),
    (2::smallint, 'number', 'Mẹ cắm hoa vào các lọ, mỗi lọ 3 bông thì được 7 lọ. Bó hoa có tất cả ___ bông hoa.', null, null, null, null, '21', null::jsonb, '3 x 7 = 21 (bông).', 'bai_toan_phep_nhan', 50::int),
    (2::smallint, 'number', 'Túi thứ nhất đựng 8 kg gạo và bằng 1/2 số gạo của túi thứ hai. Túi thứ hai đựng ___ kg gạo.', null, null, null, null, '16', null::jsonb, '8 x 2 = 16 (kg).', 'mot_phan_hai', 50::int),
    (2::smallint, 'number', 'Hiện nay 1/3 số tuổi của chị Lan là 6 tuổi. Chị Lan năm nay ___ tuổi.', null, null, null, null, '18', null::jsonb, '6 x 3 = 18 (tuổi).', 'mot_phan_ba', 50::int),
    (2::smallint, 'number', 'Một khúc gỗ dài 24 dm được cưa thành ba đoạn bằng nhau. Mỗi đoạn dài ___ dm.', null, null, null, null, '8', null::jsonb, '24 : 3 = 8 (dm).', 'bai_toan_phep_chia', 45::int),
    (3::smallint, 'number', 'Cưa một khúc gỗ thành ba đoạn bằng nhau thì phải cưa ___ lần.', null, null, null, null, '2', null::jsonb, 'Cưa 1 lần được 2 đoạn, cưa 2 lần được 3 đoạn.', 'suy_luan', 45::int),
    (3::smallint, 'number', 'Mẹ chia đều số bánh vào 6 hộp, mỗi hộp 5 cái. Nếu chia đều số bánh đó vào 3 hộp thì mỗi hộp có ___ cái.', null, null, null, null, '10', null::jsonb, 'Có 6 x 5 = 30 cái; 30 : 3 = 10 (cái).', 'bai_toan_hai_buoc', 45::int),
    (3::smallint, 'number', 'Một cửa hàng có 24 chiếc xe đạp, đã bán đi 1/3 số xe. Cửa hàng còn lại ___ chiếc xe đạp.', null, null, null, null, '16', null::jsonb, 'Đã bán 24 : 3 = 8 chiếc; còn 24 - 8 = 16 (chiếc).', 'mot_phan_ba', 46::int),
    (3::smallint, 'number', 'Quỳnh gấp được 9 ngôi sao và bằng 1/3 số ngôi sao Chi gấp được. Cả hai bạn gấp được ___ ngôi sao.', null, null, null, null, '36', null::jsonb, 'Chi gấp 9 x 3 = 27 ngôi sao; cả hai: 9 + 27 = 36.', 'mot_phan_ba', 47::int),
    (3::smallint, 'number', 'Mẹ làm được 18 chiếc bánh. Mẹ biếu bà 1/3 số bánh đó và thêm 2 cái nữa. Mẹ còn lại ___ cái bánh.', null, null, null, null, '10', null::jsonb, 'Biếu bà 6 + 2 = 8 cái; còn 18 - 8 = 10 (cái).', 'mot_phan_ba', 47::int),
    (3::smallint, 'number', 'Bác Thanh có 24 quả trứng. Bác biếu bà 1/3 số trứng, sau đó cho nhà Hồng 1/2 số trứng còn lại. Bác còn lại ___ quả trứng.', null, null, null, null, '8', null::jsonb, 'Biếu bà 8 quả, còn 16 quả; cho nhà Hồng 8 quả; còn 8 quả.', 'mot_phan_ba', 47::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 2 = 60 - 44. y = ___', null, null, null, null, '8', null::jsonb, 'y x 2 = 16 nên y = 16 : 2 = 8.', 'tim_thua_so', 48::int),
    (3::smallint, 'number', 'Tìm y, biết: 3 x y = 9 + 3 x 6. y = ___', null, null, null, null, '9', null::jsonb, '9 + 18 = 27, 3 x y = 27 nên y = 9.', 'tim_thua_so', 48::int),
    (3::smallint, 'number', 'Tìm y, biết: 3 x y = 40 - 19. y = ___', null, null, null, null, '7', null::jsonb, '3 x y = 21 nên y = 21 : 3 = 7.', 'tim_thua_so', 50::int),
    (3::smallint, 'number', 'Có một số lít dầu, đựng vào mỗi can 2 l thì được 7 can và còn thừa 1 l. Có tất cả ___ l dầu.', null, null, null, null, '15', null::jsonb, '2 x 7 = 14 l, thêm 1 l thừa: 15 (l).', 'bai_toan_hai_buoc', 48::int),
    (3::smallint, 'number', 'Mẹ xếp cam được 10 đĩa, mỗi đĩa 2 quả thì thừa 1 quả. Nếu xếp mỗi đĩa 3 quả thì mẹ xếp được ___ đĩa.', null, null, null, null, '7', null::jsonb, 'Có 2 x 10 + 1 = 21 quả; 21 : 3 = 7 (đĩa).', 'bai_toan_hai_buoc', 49::int),
    (3::smallint, 'number', 'Mai chia đều cam vào 5 giỏ, mỗi giỏ 3 quả thì thiếu 1 quả. Mai có tất cả ___ quả cam.', null, null, null, null, '14', null::jsonb, 'Cần 5 x 3 = 15 quả mà thiếu 1: 15 - 1 = 14 (quả).', 'bai_toan_hai_buoc', 49::int),
    (3::smallint, 'number', 'Minh chia đều bi vào 4 túi, mỗi túi 5 viên thì thiếu 2 viên. Nếu chia đều số bi đó vào 3 túi thì mỗi túi có ___ viên.', null, null, null, null, '6', null::jsonb, 'Minh có 20 - 2 = 18 viên; 18 : 3 = 6 (viên).', 'bai_toan_hai_buoc', 49::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó nhân với 3 rồi trừ đi 8 thì được 19. Số đó là ___.', null, null, null, null, '9', null::jsonb, 'Trước khi trừ 8 là 19 + 8 = 27; 27 : 3 = 9.', 'tim_so', 50::int),
    (3::smallint, 'number', 'Một đàn gà vịt có 24 con, số vịt bằng 1/3 tổng số gà và vịt. Đàn có ___ con gà.', null, null, null, null, '16', null::jsonb, 'Số vịt: 24 : 3 = 8 con; số gà: 24 - 8 = 16 (con).', 'mot_phan_ba', 51::int),
    (3::smallint, 'number', 'Mẹ mua ba chục quả cam, mẹ biếu bà 1/3 số quả cam. Mẹ còn lại ___ quả cam.', null, null, null, null, '20', null::jsonb, 'Ba chục là 30; biếu bà 10 quả; còn 30 - 10 = 20 (quả).', 'mot_phan_ba', 51::int),
    (3::smallint, 'number', 'Tìm a, biết: a - 35 = 4 x 9. a = ___', null, null, null, null, '71', null::jsonb, '4 x 9 = 36; a = 36 + 35 = 71.', 'tim_x', 51::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 23 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 24: Mối quan hệ giữa phép nhân và phép chia. Bảng chia 4, 5. Một phần tư, một phần năm (47 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 24, 100, 'Archimes: Mối quan hệ giữa phép nhân và phép chia. Bảng chia 4, 5. Một phần tư, một phần năm', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 24', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '32 : 4 = ___', null, null, null, null, '8', null::jsonb, 'Bảng chia 4: 32 : 4 = 8.', 'bang_chia_4', 52::int),
    (1::smallint, 'number', '24 : 4 = ___', null, null, null, null, '6', null::jsonb, 'Bảng chia 4: 24 : 4 = 6.', 'bang_chia_4', 52::int),
    (1::smallint, 'number', '20 : 4 = ___', null, null, null, null, '5', null::jsonb, 'Bảng chia 4: 20 : 4 = 5.', 'bang_chia_4', 52::int),
    (1::smallint, 'number', '35 : 5 = ___', null, null, null, null, '7', null::jsonb, 'Bảng chia 5: 35 : 5 = 7.', 'bang_chia_5', 52::int),
    (1::smallint, 'number', '45 : 5 = ___', null, null, null, null, '9', null::jsonb, 'Bảng chia 5: 45 : 5 = 9.', 'bang_chia_5', 52::int),
    (1::smallint, 'number', '40 : 5 = ___', null, null, null, null, '8', null::jsonb, 'Bảng chia 5: 40 : 5 = 8.', 'bang_chia_5', 52::int),
    (1::smallint, 'number', '1/4 của 16 cm là ___ cm.', null, null, null, null, '4', null::jsonb, '16 : 4 = 4 (cm).', 'mot_phan_tu', 52::int),
    (1::smallint, 'number', '1/5 của 40 kg là ___ kg.', null, null, null, null, '8', null::jsonb, '40 : 5 = 8 (kg).', 'mot_phan_nam', 52::int),
    (1::smallint, 'number', '1/4 của 32 kg gạo là ___ kg gạo.', null, null, null, null, '8', null::jsonb, '32 : 4 = 8 (kg).', 'mot_phan_tu', 59::int),
    (1::smallint, 'multiple_choice', 'Từ phép nhân 4 x 5 = 20, ta viết được hai phép chia là:', '20 : 4 = 5 và 20 : 5 = 4', '20 : 4 = 4 và 20 : 5 = 5', '20 : 2 = 10 và 20 : 10 = 2', null, '20 : 4 = 5 và 20 : 5 = 4', null::jsonb, 'Lấy tích chia cho thừa số này được thừa số kia.', 'nhan_chia', 52::int),
    (1::smallint, 'multiple_choice', 'Một phần năm viết là:', '5/1', '1/5', '1/4', '5', '1/5', null::jsonb, 'Một phần năm viết là 1/5.', 'mot_phan_nam', 52::int),
    (1::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): 1/4 của 20 là 4. ___', null, null, null, null, 'S', '["sai"]'::jsonb, '1/4 của 20 là 20 : 4 = 5, không phải 4.', 'mot_phan_tu', 52::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 1/4 của 20 ___ 1/5 của 20', '<', '=', '>', null, '>', null::jsonb, '1/4 của 20 là 5, 1/5 của 20 là 4, mà 5 > 4.', 'mot_phan_tu', 52::int),
    (2::smallint, 'multiple_choice', 'Từ phép nhân 5 x 3 = 15, phép chia nào dưới đây đúng?', '15 : 3 = 15', '5 : 3 = 15', '15 : 5 = 5', '15 : 5 = 3', '15 : 5 = 3', null::jsonb, 'Lấy tích chia cho một thừa số được thừa số kia: 15 : 5 = 3.', 'nhan_chia', 52::int),
    (2::smallint, 'number', '12 : 4 x 5 = ___', null, null, null, null, '15', null::jsonb, '12 : 4 = 3, 3 x 5 = 15.', 'thu_tu_phep_tinh', 53::int),
    (2::smallint, 'number', '32 - 36 : 4 = ___', null, null, null, null, '23', null::jsonb, '36 : 4 = 9, 32 - 9 = 23.', 'thu_tu_phep_tinh', 53::int),
    (2::smallint, 'number', '81 - 45 : 5 = ___', null, null, null, null, '72', null::jsonb, '45 : 5 = 9, 81 - 9 = 72.', 'thu_tu_phep_tinh', 53::int),
    (2::smallint, 'number', '43 + 40 : 5 = ___', null, null, null, null, '51', null::jsonb, '40 : 5 = 8, 43 + 8 = 51.', 'thu_tu_phep_tinh', 53::int),
    (2::smallint, 'number', '24 : 4 + 5 x 9 = ___', null, null, null, null, '51', null::jsonb, '24 : 4 = 6, 5 x 9 = 45, 6 + 45 = 51.', 'thu_tu_phep_tinh', 59::int),
    (2::smallint, 'number', 'Tìm y, biết: y x 4 = 12. y = ___', null, null, null, null, '3', null::jsonb, 'y = 12 : 4 = 3.', 'tim_thua_so', 53::int),
    (2::smallint, 'number', 'Tìm y, biết: 5 x y = 25. y = ___', null, null, null, null, '5', null::jsonb, 'y = 25 : 5 = 5.', 'tim_thua_so', 53::int),
    (2::smallint, 'number', 'Có 36 cái kẹo được chia đều vào 4 túi. Mỗi túi có ___ cái kẹo.', null, null, null, null, '9', null::jsonb, '36 : 4 = 9 (cái).', 'bai_toan_phep_chia', 59::int),
    (2::smallint, 'number', '1/5 của 2 dm là ___ cm.', null, null, null, null, '4', null::jsonb, 'Đổi 2 dm = 20 cm; 20 : 5 = 4 (cm).', 'mot_phan_nam', 59::int),
    (2::smallint, 'number', 'Biết 1/5 số tuổi của An hiện nay là 3 tuổi. An năm nay ___ tuổi.', null, null, null, null, '15', null::jsonb, '3 x 5 = 15 (tuổi).', 'mot_phan_nam', 59::int),
    (2::smallint, 'number', 'Chi có 20 quyển truyện, số truyện của Tùng bằng 1/4 số truyện của Chi. Tùng có ___ quyển truyện.', null, null, null, null, '5', null::jsonb, '20 : 4 = 5 (quyển).', 'mot_phan_tu', 69::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 28 : 4 + 56 ___ 25 : 5 + 77', '>', '<', '=', null, '<', null::jsonb, '28 : 4 + 56 = 63, 25 : 5 + 77 = 82, mà 63 < 82.', 'so_sanh', 60::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 4 = 17 + 15. y = ___', null, null, null, null, '8', null::jsonb, 'y x 4 = 32 nên y = 32 : 4 = 8.', 'tim_thua_so', 53::int),
    (3::smallint, 'number', 'Tìm y, biết: 4 x y = 5 x 8. y = ___', null, null, null, null, '10', null::jsonb, '4 x y = 40 nên y = 40 : 4 = 10.', 'tim_thua_so', 53::int),
    (3::smallint, 'number', 'Tìm y, biết: 54 - y = 30 : 5 + 28. y = ___', null, null, null, null, '20', null::jsonb, '30 : 5 + 28 = 34; y = 54 - 34 = 20.', 'tim_x', 54::int),
    (3::smallint, 'number', 'Cô giáo chia táo cho 10 bạn, mỗi bạn 4 quả thì cô còn đúng 3 quả. Cô giáo có tất cả ___ quả táo.', null, null, null, null, '43', null::jsonb, '4 x 10 = 40, thêm 3 quả còn lại: 43 (quả).', 'bai_toan_hai_buoc', 54::int),
    (3::smallint, 'number', 'Nhà Hà nuôi đàn mèo, số mèo là số có một chữ số và số chân mèo lớn hơn 35. Nhà Hà nuôi ___ con mèo.', null, null, null, null, '9', null::jsonb, 'Mỗi con 4 chân; 8 con có 32 chân (chưa đủ), 9 con có 36 chân > 35.', 'suy_luan', 54::int),
    (3::smallint, 'number', 'Lan làm được 24 chiếc bánh, Lan biếu bà 1/4 số bánh đó. Lan còn lại ___ chiếc bánh.', null, null, null, null, '18', null::jsonb, 'Biếu bà 24 : 4 = 6 chiếc; còn 24 - 6 = 18 (chiếc).', 'mot_phan_tu', 55::int),
    (3::smallint, 'number', 'Việt và Nam có 50 viên bi. Số bi của Việt bằng 1/5 số bi của cả hai bạn. Nam có ___ viên bi.', null, null, null, null, '40', null::jsonb, 'Việt có 50 : 5 = 10 viên; Nam có 50 - 10 = 40 (viên).', 'mot_phan_nam', 55::int),
    (3::smallint, 'number', 'Lớp 2A có 7 bạn nam và số bạn nam bằng 1/4 số bạn nữ. Lớp 2A có tất cả ___ học sinh.', null, null, null, null, '35', null::jsonb, 'Số bạn nữ: 7 x 4 = 28; cả lớp: 7 + 28 = 35.', 'mot_phan_tu', 55::int),
    (3::smallint, 'number', 'Năm nay con 7 tuổi và bằng 1/5 tuổi mẹ. Mẹ hơn con ___ tuổi.', null, null, null, null, '28', null::jsonb, 'Mẹ 7 x 5 = 35 tuổi; mẹ hơn con 35 - 7 = 28 tuổi.', 'mot_phan_nam', 56::int),
    (3::smallint, 'number', 'An có 28 viên bi. 1/4 số bi của An bằng 1/5 số bi của Hùng. Hùng có ___ viên bi.', null, null, null, null, '35', null::jsonb, '1/4 số bi của An là 7 viên; Hùng có 7 x 5 = 35 (viên).', 'mot_phan_nam', 56::int),
    (3::smallint, 'multiple_choice', 'Các số có hai chữ số mà chữ số hàng đơn vị bằng 1/4 chữ số hàng chục là:', '14 và 28', '41; 82 và 93', '41 và 82', '42 và 81', '41 và 82', null::jsonb, 'Hàng chục phải chia hết cho 4: 4 : 4 = 1 (số 41), 8 : 4 = 2 (số 82).', 'cau_tao_so', 56::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 3 + 6 = 30. y = ___', null, null, null, null, '8', null::jsonb, 'y x 3 = 24 nên y = 8.', 'tim_x', 57::int),
    (3::smallint, 'number', 'Tìm y, biết: 50 - y x 3 = 23. y = ___', null, null, null, null, '9', null::jsonb, 'y x 3 = 50 - 23 = 27 nên y = 9.', 'tim_x', 57::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 3 + y x 2 = 40. y = ___', null, null, null, null, '8', null::jsonb, 'y x 3 + y x 2 = y x 5 = 40 nên y = 8.', 'tim_x', 57::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 5 - y = 36. y = ___', null, null, null, null, '9', null::jsonb, 'y x 5 - y = y x 4 = 36 nên y = 9.', 'tim_x', 57::int),
    (3::smallint, 'number', 'Bà có một số bánh, chia cho 6 cháu thì mỗi cháu được 5 chiếc. Nếu chia cho 3 cháu thì mỗi cháu được ___ chiếc.', null, null, null, null, '10', null::jsonb, 'Bà có 6 x 5 = 30 chiếc; 30 : 3 = 10 (chiếc).', 'bai_toan_hai_buoc', 58::int),
    (3::smallint, 'number', 'Một phép nhân có tích là số tròn chục nhỏ nhất lớn hơn 10 và một thừa số bằng 1/4 tích. Thừa số còn lại là ___.', null, null, null, null, '4', null::jsonb, 'Tích là 20, một thừa số là 20 : 4 = 5; thừa số còn lại: 20 : 5 = 4.', 'tim_thua_so', 58::int),
    (3::smallint, 'number', 'Một đàn trâu bò có 45 con. Số con trâu bằng 1/5 số con cả đàn. Đàn có ___ con bò.', null, null, null, null, '36', null::jsonb, 'Số trâu: 45 : 5 = 9 con; số bò: 45 - 9 = 36 (con).', 'mot_phan_nam', 59::int),
    (3::smallint, 'number', 'Bà cho Nam 1/5 số táo của bà là 5 quả, sau đó bà cho Bắc 1/4 số táo còn lại. Bà còn lại ___ quả táo.', null, null, null, null, '15', null::jsonb, 'Bà có 25 quả, cho Nam 5 còn 20; cho Bắc 5 quả; còn 15 quả.', 'mot_phan_tu', 59::int),
    (3::smallint, 'number', 'Tìm b, biết: 51 - b x 4 = 19. b = ___', null, null, null, null, '8', null::jsonb, 'b x 4 = 51 - 19 = 32 nên b = 8.', 'tim_x', 59::int),
    (3::smallint, 'number', 'Cô thư viện cho lớp 2A mượn 1/5 số sách ở ngăn trên thì lớp 2A được 8 quyển. Ngăn trên có ___ quyển sách.', null, null, null, null, '40', null::jsonb, '8 x 5 = 40 (quyển).', 'mot_phan_nam', 60::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 24 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 25: Đơn vị đo lường. Giờ, phút. Ngày, tháng (46 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 25, 100, 'Archimes: Đơn vị đo lường. Giờ, phút. Ngày, tháng', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 25', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '1 giờ = ___ phút', null, null, null, null, '60', null::jsonb, '1 giờ có 60 phút.', 'don_vi_thoi_gian', 61::int),
    (1::smallint, 'number', '1 ngày = ___ giờ', null, null, null, null, '24', null::jsonb, '1 ngày có 24 giờ.', 'don_vi_thoi_gian', 61::int),
    (1::smallint, 'number', '1 năm = ___ tháng', null, null, null, null, '12', null::jsonb, '1 năm có 12 tháng.', 'don_vi_thoi_gian', 61::int),
    (1::smallint, 'number', '24 giờ + 36 giờ = ___ giờ', null, null, null, null, '60', null::jsonb, '24 + 36 = 60 (giờ).', 'don_vi_thoi_gian', 64::int),
    (1::smallint, 'number', '12 phút + 59 phút = ___ phút', null, null, null, null, '71', null::jsonb, '12 + 59 = 71 (phút).', 'don_vi_thoi_gian', 64::int),
    (1::smallint, 'number', '26 ngày - 18 ngày = ___ ngày', null, null, null, null, '8', null::jsonb, '26 - 18 = 8 (ngày).', 'don_vi_thoi_gian', 64::int),
    (1::smallint, 'number', '65 kg - 27 kg = ___ kg', null, null, null, null, '38', null::jsonb, '65 - 27 = 38 (kg).', 'don_vi_khoi_luong', 68::int),
    (1::smallint, 'multiple_choice', 'Đồng hồ có kim ngắn chỉ số 10, kim dài chỉ số 12. Đồng hồ chỉ:', '12 giờ 10 phút', '10 giờ', '2 giờ', '10 giờ 30 phút', '10 giờ', null::jsonb, 'Kim dài chỉ số 12 là giờ đúng, kim ngắn chỉ số 10 nên là 10 giờ.', 'xem_dong_ho', 62::int),
    (1::smallint, 'multiple_choice', 'Đồng hồ có kim ngắn chỉ giữa số 1 và số 2, kim dài chỉ số 6. Đồng hồ chỉ:', '6 giờ 1 phút', '2 giờ 30 phút', '1 giờ 30 phút', '1 giờ 6 phút', '1 giờ 30 phút', null::jsonb, 'Kim dài chỉ số 6 là 30 phút; kim ngắn đã qua số 1 nên là 1 giờ 30 phút.', 'xem_dong_ho', 62::int),
    (1::smallint, 'multiple_choice', 'Đồng hồ có kim ngắn chỉ hơi quá số 3, kim dài chỉ số 3. Đồng hồ chỉ:', '3 giờ 3 phút', '3 giờ 30 phút', '15 giờ 3 phút', '3 giờ 15 phút', '3 giờ 15 phút', null::jsonb, 'Kim dài chỉ số 3 là 15 phút; kim ngắn quá số 3 nên là 3 giờ 15 phút.', 'xem_dong_ho', 62::int),
    (1::smallint, 'multiple_choice', 'Đơn vị nào dưới đây dùng để đo thời gian?', 'Phút', 'Ki-lô-gam', 'Mét', 'Lít', 'Phút', null::jsonb, 'Phút là đơn vị đo thời gian.', 'don_vi_do', 61::int),
    (1::smallint, 'text', 'Điền tên đơn vị thích hợp: 1 giờ = 60 ___', null, null, null, null, 'phút', null::jsonb, '1 giờ có 60 phút.', 'don_vi_thoi_gian', 61::int),
    (1::smallint, 'text', 'Điền tên đơn vị thích hợp: Túi gạo nặng 5 ___', null, null, null, null, 'kg', '["ki-lô-gam","ki lô gam","kilogam"]'::jsonb, 'Ki-lô-gam (kg) là đơn vị đo khối lượng.', 'don_vi_do', 61::int),
    (1::smallint, 'multiple_choice', 'An đến trường lúc 7 giờ 15 phút, Hà đến trường lúc 7 giờ 30 phút. Bạn nào đến trường muộn hơn?', 'An', 'Hai bạn đến cùng lúc', 'Hà', null, 'Hà', null::jsonb, '7 giờ 30 phút muộn hơn 7 giờ 15 phút nên Hà đến muộn hơn.', 'xem_dong_ho', 68::int),
    (2::smallint, 'number', 'Khoảng thời gian từ 10 giờ 15 phút đến 10 giờ 30 phút là ___ phút.', null, null, null, null, '15', null::jsonb, '30 - 15 = 15 (phút).', 'tinh_thoi_gian', 63::int),
    (2::smallint, 'number', 'Khoảng thời gian từ 9 giờ 15 phút đến 11 giờ 15 phút là ___ giờ.', null, null, null, null, '2', null::jsonb, '11 - 9 = 2 (giờ).', 'tinh_thoi_gian', 63::int),
    (2::smallint, 'number', 'Chi đến trường lúc 7 giờ, Bình đến trường lúc 7 giờ 15 phút. Chi đến sớm hơn Bình ___ phút.', null, null, null, null, '15', null::jsonb, 'Từ 7 giờ đến 7 giờ 15 phút là 15 phút.', 'tinh_thoi_gian', 63::int),
    (2::smallint, 'number', 'Bình đi ngủ lúc 21 giờ, Minh đi ngủ lúc 21 giờ 30 phút. Minh đi ngủ muộn hơn Bình ___ phút.', null, null, null, null, '30', null::jsonb, 'Từ 21 giờ đến 21 giờ 30 phút là 30 phút.', 'tinh_thoi_gian', 63::int),
    (2::smallint, 'number', 'Nam ra khỏi nhà lúc 7 giờ 15 phút, đi đến trường mất 15 phút. Nam đến trường lúc 7 giờ ___ phút.', null, null, null, null, '30', null::jsonb, '15 phút + 15 phút = 30 phút, nên là 7 giờ 30 phút.', 'tinh_thoi_gian', 63::int),
    (2::smallint, 'number', '2 tuần + 4 ngày = ___ ngày', null, null, null, null, '18', null::jsonb, '2 tuần = 14 ngày; 14 + 4 = 18 (ngày).', 'don_vi_thoi_gian', 64::int),
    (2::smallint, 'number', '1 năm + 2 tháng = ___ tháng', null, null, null, null, '14', null::jsonb, '1 năm = 12 tháng; 12 + 2 = 14 (tháng).', 'don_vi_thoi_gian', 64::int),
    (2::smallint, 'number', '1 ngày + 6 giờ = ___ giờ', null, null, null, null, '30', null::jsonb, '1 ngày = 24 giờ; 24 + 6 = 30 (giờ).', 'don_vi_thoi_gian', 64::int),
    (2::smallint, 'number', '1 giờ 15 phút = ___ phút', null, null, null, null, '75', null::jsonb, '1 giờ = 60 phút; 60 + 15 = 75 (phút).', 'don_vi_thoi_gian', 68::int),
    (2::smallint, 'number', '1 ngày 8 giờ = ___ giờ', null, null, null, null, '32', null::jsonb, '1 ngày = 24 giờ; 24 + 8 = 32 (giờ).', 'don_vi_thoi_gian', 68::int),
    (2::smallint, 'number', '4 x 8 - 25 : 5 = ___', null, null, null, null, '27', null::jsonb, '4 x 8 = 32, 25 : 5 = 5, 32 - 5 = 27.', 'thu_tu_phep_tinh', 68::int),
    (2::smallint, 'number', '38 + 35 : 5 = ___', null, null, null, null, '45', null::jsonb, '35 : 5 = 7, 38 + 7 = 45.', 'thu_tu_phep_tinh', 69::int),
    (3::smallint, 'number', 'Lan bắt đầu học bài lúc 8 giờ tối. Lan học toán 45 phút, tập đàn thêm 15 phút nữa. Lan tập đàn xong lúc ___ giờ tối.', null, null, null, null, '9', null::jsonb, '45 phút + 15 phút = 60 phút = 1 giờ; 8 giờ + 1 giờ = 9 giờ tối.', 'tinh_thoi_gian', 63::int),
    (3::smallint, 'number', 'Bình đi ngủ lúc 10 giờ tối và ngủ trong 8 tiếng. Bình ngủ dậy lúc ___ giờ sáng.', null, null, null, null, '6', null::jsonb, 'Từ 10 giờ tối đến 12 giờ đêm là 2 tiếng, thêm 6 tiếng nữa là 6 giờ sáng.', 'tinh_thoi_gian', 63::int),
    (3::smallint, 'number', 'Thứ Bảy tuần này là ngày 20 tháng 3. Thứ Hai của tuần tiếp theo là ngày ___ tháng 3.', null, null, null, null, '22', null::jsonb, 'Thứ Bảy 20, Chủ nhật 21, thứ Hai 22.', 'ngay_thang', 64::int),
    (3::smallint, 'number', 'Thứ Năm tuần này là ngày 14 tháng 5. Thứ Tư của tuần sau là ngày ___ tháng 5.', null, null, null, null, '20', null::jsonb, 'Thứ Tư tuần sau cách thứ Năm tuần này 6 ngày: 14 + 6 = 20.', 'ngay_thang', 64::int),
    (3::smallint, 'multiple_choice', 'Ngày 7 tháng 6 là thứ Ba. Sinh nhật Hồng ngày 15 tháng 6 vào thứ mấy?', 'Thứ Ba', 'Thứ Năm', 'Thứ Hai', 'Thứ Tư', 'Thứ Tư', null::jsonb, 'Ngày 14 cũng là thứ Ba (7 + 7), nên ngày 15 là thứ Tư.', 'ngay_thang', 64::int),
    (3::smallint, 'multiple_choice', 'Hôm nay là Chủ nhật, ngày 31. Chủ nhật tuần tiếp theo là ngày nào?', 'Ngày 7 tháng sau', 'Ngày 38', 'Ngày 6 tháng sau', 'Ngày 24', 'Ngày 7 tháng sau', null::jsonb, 'Tháng có 31 ngày thì sau ngày 31 là ngày 1 tháng sau; Chủ nhật tiếp theo là ngày 7.', 'ngay_thang', 65::int),
    (3::smallint, 'multiple_choice', 'Nếu thứ Ba tuần đầu tiên của tháng là ngày chẵn thì thứ Ba tuần sau là ngày chẵn hay ngày lẻ?', 'Ngày chẵn', 'Ngày lẻ', 'Không biết được', null, 'Ngày lẻ', null::jsonb, 'Thứ Ba tuần sau hơn 7 ngày; số chẵn cộng 7 được số lẻ.', 'ngay_thang', 65::int),
    (3::smallint, 'multiple_choice', 'Thứ Tư đầu tiên của tháng là ngày 2 (tháng có 30 ngày). Các ngày thứ Tư trong tháng là:', '2; 9; 16; 23', '2; 9; 16; 23; 30', '2; 8; 14; 20; 26', '2; 10; 18; 26', '2; 9; 16; 23; 30', null::jsonb, 'Cứ thêm 7 ngày: 2, 9, 16, 23, 30.', 'ngay_thang', 65::int),
    (3::smallint, 'number', 'Thứ Bảy cuối cùng trong tháng là ngày 25. Thứ Bảy đầu tiên của tháng đó là ngày ___.', null, null, null, null, '4', null::jsonb, 'Lùi 7 ngày mỗi lần: 25, 18, 11, 4.', 'ngay_thang', 65::int),
    (3::smallint, 'number', 'Một khúc gỗ dài 3 m 6 dm được cưa thành các khúc ngắn dài 4 dm. Cưa được ___ khúc gỗ như vậy.', null, null, null, null, '9', null::jsonb, '3 m 6 dm = 36 dm; 36 : 4 = 9 (khúc).', 'bai_toan_phep_chia', 66::int),
    (3::smallint, 'number', 'Mẹ chia cam vào 7 giỏ, mỗi giỏ 5 quả thì còn thừa 4 quả. Mẹ có tất cả ___ quả cam.', null, null, null, null, '39', null::jsonb, '5 x 7 = 35, thêm 4 quả thừa: 39 (quả).', 'bai_toan_hai_buoc', 66::int),
    (3::smallint, 'number', 'Mai chia kẹo vào 6 túi nhỏ, mỗi túi 4 chiếc thì còn thừa 2 chiếc. Mai có tất cả ___ chiếc kẹo.', null, null, null, null, '26', null::jsonb, '4 x 6 = 24, thêm 2 chiếc thừa: 26 (chiếc).', 'bai_toan_hai_buoc', 66::int),
    (3::smallint, 'number', 'Nếu thêm 3 kg gạo nữa thì số gạo trong bao vừa đủ chia vào 9 túi, mỗi túi 5 kg. Bao gạo ban đầu có ___ kg.', null, null, null, null, '42', null::jsonb, '9 x 5 = 45 kg; ban đầu: 45 - 3 = 42 (kg).', 'bai_toan_hai_buoc', 66::int),
    (3::smallint, 'number', 'Hai túi đựng tất cả 32 kg ngô, số ngô ở túi thứ nhất bằng 1/4 số ngô cả hai túi. Túi thứ hai có ___ kg ngô.', null, null, null, null, '24', null::jsonb, 'Túi thứ nhất: 32 : 4 = 8 kg; túi thứ hai: 32 - 8 = 24 (kg).', 'mot_phan_tu', 67::int),
    (3::smallint, 'number', 'Túi có 36 chiếc kẹo xanh, đỏ, vàng. Kẹo xanh bằng 1/4 số kẹo trong túi, kẹo đỏ bằng 1/3 số kẹo còn lại. Có ___ chiếc kẹo vàng.', null, null, null, null, '18', null::jsonb, 'Xanh 9 chiếc, còn 27; đỏ 27 : 3 = 9 chiếc; vàng 27 - 9 = 18 chiếc.', 'mot_phan_ba', 67::int),
    (3::smallint, 'number', 'Một khúc gỗ dài 12 m được cưa thành các khúc ngắn gồm cả hai loại 2 m và 3 m, không thừa gỗ. Cưa được tất cả ___ khúc gỗ.', null, null, null, null, '5', null::jsonb, 'Chỉ có cách 3 khúc 2 m và 2 khúc 3 m (6 + 6 = 12), tất cả 5 khúc.', 'suy_luan', 67::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 5 + 36 = 81. y = ___', null, null, null, null, '9', null::jsonb, 'y x 5 = 45 nên y = 9.', 'tim_x', 68::int),
    (3::smallint, 'number', 'Một đội văn nghệ có 7 bạn nữ, số bạn nữ bằng 1/3 số bạn nam. Đội văn nghệ có ___ bạn.', null, null, null, null, '28', null::jsonb, 'Số bạn nam: 7 x 3 = 21; cả đội: 7 + 21 = 28.', 'mot_phan_ba', 68::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó cộng với 17 rồi chia cho 5 thì được thương là số chẵn lớn nhất có một chữ số. Số đó là ___.', null, null, null, null, '23', null::jsonb, 'Thương là 8 nên trước khi chia là 8 x 5 = 40; số đó là 40 - 17 = 23.', 'tim_so', 68::int),
    (3::smallint, 'number', 'Đoạn đường AC dài 35 km, đoạn BC bằng 1/5 đoạn AC. Đi từ A tới C phải qua B. Đoạn đường AB dài ___ km.', null, null, null, null, '28', null::jsonb, 'BC = 35 : 5 = 7 km; AB = 35 - 7 = 28 (km).', 'mot_phan_nam', 68::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 25 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 26: Chu vi hình tam giác, chu vi hình tứ giác. Tìm số bị chia (46 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 26, 100, 'Archimes: Chu vi hình tam giác, chu vi hình tứ giác. Tìm số bị chia', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 26', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Hình tam giác ABC có các cạnh 3 cm, 4 cm, 5 cm. Chu vi hình tam giác ABC là ___ cm.', null, null, null, null, '12', null::jsonb, '3 + 4 + 5 = 12 (cm).', 'chu_vi_tam_giac', 70::int),
    (1::smallint, 'number', 'Hình tứ giác MNPQ có các cạnh 3 cm, 4 cm, 6 cm, 4 cm. Chu vi hình tứ giác MNPQ là ___ cm.', null, null, null, null, '17', null::jsonb, '3 + 4 + 6 + 4 = 17 (cm).', 'chu_vi_tu_giac', 70::int),
    (1::smallint, 'multiple_choice', 'Chu vi của một hình tam giác bằng:', 'Độ dài cạnh dài nhất', 'Tổng độ dài hai cạnh', 'Tổng độ dài ba cạnh', 'Hiệu độ dài các cạnh', 'Tổng độ dài ba cạnh', null::jsonb, 'Tổng độ dài các cạnh của hình tam giác là chu vi của hình đó.', 'chu_vi_tam_giac', 70::int),
    (1::smallint, 'multiple_choice', 'Muốn tìm số bị chia, ta lấy:', 'Thương chia cho số chia', 'Số chia chia cho thương', 'Thương cộng với số chia', 'Thương nhân với số chia', 'Thương nhân với số chia', null::jsonb, 'Muốn tìm số bị chia ta lấy thương nhân với số chia.', 'tim_so_bi_chia', 70::int),
    (1::smallint, 'number', 'Hình tam giác có các cạnh 6 dm, 8 dm, 9 dm. Chu vi hình tam giác đó là ___ dm.', null, null, null, null, '23', null::jsonb, '6 + 8 + 9 = 23 (dm).', 'chu_vi_tam_giac', 71::int),
    (1::smallint, 'number', 'Hình tứ giác có các cạnh 8 dm, 13 dm, 9 dm, 7 dm. Chu vi hình tứ giác đó là ___ dm.', null, null, null, null, '37', null::jsonb, '8 + 13 + 9 + 7 = 37 (dm).', 'chu_vi_tu_giac', 71::int),
    (1::smallint, 'number', 'Hình tam giác có ba cạnh đều bằng 8 cm. Chu vi hình tam giác đó là ___ cm.', null, null, null, null, '24', null::jsonb, '8 x 3 = 24 (cm).', 'chu_vi_tam_giac', 77::int),
    (1::smallint, 'number', 'Hình tứ giác có bốn cạnh đều bằng 5 cm. Chu vi hình tứ giác đó là ___ cm.', null, null, null, null, '20', null::jsonb, '5 x 4 = 20 (cm).', 'chu_vi_tu_giac', 77::int),
    (1::smallint, 'number', 'Hình tam giác có các cạnh 3 cm, 8 cm, 6 cm. Chu vi hình tam giác đó là ___ cm.', null, null, null, null, '17', null::jsonb, '3 + 8 + 6 = 17 (cm).', 'chu_vi_tam_giac', 71::int),
    (1::smallint, 'multiple_choice', 'Trong phép chia 10 : 2 = 5, số 10 được gọi là:', 'Số bị chia', 'Số chia', 'Thương', 'Tích', 'Số bị chia', null::jsonb, '10 là số bị chia, 2 là số chia, 5 là thương.', 'thanh_phan_phep_chia', 70::int),
    (1::smallint, 'number', 'Hình tứ giác có các cạnh 9 dm, 6 dm, 5 dm, 10 dm. Chu vi hình tứ giác đó là ___ dm.', null, null, null, null, '30', null::jsonb, '9 + 6 + 5 + 10 = 30 (dm).', 'chu_vi_tu_giac', 71::int),
    (1::smallint, 'text', 'Tổng độ dài các cạnh của hình tam giác gọi là ___ của hình tam giác đó.', null, null, null, null, 'chu vi', null::jsonb, 'Tổng độ dài các cạnh của một hình là chu vi của hình đó.', 'chu_vi_tam_giac', 70::int),
    (2::smallint, 'multiple_choice', 'Chu vi tam giác có các cạnh 5 cm, 6 cm, 7 cm ___ chu vi tứ giác có bốn cạnh đều bằng 4 cm', '<', '>', '=', null, '>', null::jsonb, 'Chu vi tam giác 5 + 6 + 7 = 18 cm, chu vi tứ giác 4 x 4 = 16 cm; 18 > 16.', 'chu_vi', 71::int),
    (2::smallint, 'multiple_choice', 'Tìm y, biết: y : 4 = 5. Giá trị của y là:', '9', '1', '20', '24', '20', null::jsonb, 'y = 5 x 4 = 20.', 'tim_so_bi_chia', 75::int),
    (2::smallint, 'multiple_choice', 'Hình tam giác có hai cạnh 4 dm, 3 dm và chu vi 12 dm. Cạnh còn lại dài:', '7 dm', '19 dm', '9 dm', '5 dm', '5 dm', null::jsonb, '12 - 4 - 3 = 5 (dm).', 'chu_vi_tam_giac', 71::int),
    (2::smallint, 'number', 'Tìm y, biết: y : 3 = 4. y = ___', null, null, null, null, '12', null::jsonb, 'y = 4 x 3 = 12.', 'tim_so_bi_chia', 75::int),
    (2::smallint, 'number', 'Tìm y, biết: y : 5 = 2. y = ___', null, null, null, null, '10', null::jsonb, 'y = 2 x 5 = 10.', 'tim_so_bi_chia', 75::int),
    (2::smallint, 'number', '12 : 2 x 3 = ___', null, null, null, null, '18', null::jsonb, '12 : 2 = 6, 6 x 3 = 18.', 'thu_tu_phep_tinh', 77::int),
    (2::smallint, 'number', '3 kg x 6 + 18 kg = ___ kg', null, null, null, null, '36', null::jsonb, '3 x 6 = 18, 18 + 18 = 36 (kg).', 'thu_tu_phep_tinh', 77::int),
    (2::smallint, 'number', 'Hình tam giác ABC có độ dài các cạnh là 27 cm, 3 dm, 22 cm. Chu vi hình tam giác ABC là ___ cm.', null, null, null, null, '79', null::jsonb, 'Đổi 3 dm = 30 cm; 27 + 30 + 22 = 79 (cm).', 'chu_vi_tam_giac', 78::int),
    (2::smallint, 'number', 'Hình tứ giác MNPQ có độ dài các cạnh là 20 cm, 4 dm, 5 dm, 30 cm. Chu vi hình tứ giác MNPQ là ___ dm.', null, null, null, null, '14', null::jsonb, 'Đổi 20 cm = 2 dm, 30 cm = 3 dm; 2 + 4 + 5 + 3 = 14 (dm).', 'chu_vi_tu_giac', 78::int),
    (2::smallint, 'number', 'Một tam giác có chu vi 27 cm, tổng độ dài hai cạnh là 18 cm. Cạnh còn lại dài ___ cm.', null, null, null, null, '9', null::jsonb, '27 - 18 = 9 (cm).', 'chu_vi_tam_giac', 71::int),
    (2::smallint, 'number', 'Hình tam giác có hai cạnh 17 cm và 21 cm, chu vi 56 cm. Cạnh thứ ba dài ___ cm.', null, null, null, null, '18', null::jsonb, '56 - 17 - 21 = 18 (cm).', 'chu_vi_tam_giac', 71::int),
    (2::smallint, 'number', 'Hình tứ giác có ba cạnh 3 cm, 8 cm, 6 cm và chu vi 27 cm. Cạnh thứ tư dài ___ cm.', null, null, null, null, '10', null::jsonb, '27 - 3 - 8 - 6 = 10 (cm).', 'chu_vi_tu_giac', 71::int),
    (2::smallint, 'number', 'Một tam giác có ba cạnh bằng nhau và chu vi 21 cm. Mỗi cạnh dài ___ cm.', null, null, null, null, '7', null::jsonb, '21 : 3 = 7 (cm).', 'chu_vi_tam_giac', 72::int),
    (2::smallint, 'number', 'Hoàng chia số bi của mình vào 3 hộp, mỗi hộp đều có 4 viên. Hoàng có tất cả ___ viên bi.', null, null, null, null, '12', null::jsonb, '4 x 3 = 12 (viên).', 'tim_so_bi_chia', 76::int),
    (2::smallint, 'number', 'Tam giác ABC có ba cạnh bằng nhau và chu vi 27 dm. Cạnh AB dài ___ dm.', null, null, null, null, '9', null::jsonb, '27 : 3 = 9 (dm).', 'chu_vi_tam_giac', 78::int),
    (3::smallint, 'number', 'Tìm x, biết: x : 3 = 73 - 68. x = ___', null, null, null, null, '15', null::jsonb, 'x : 3 = 5 nên x = 5 x 3 = 15.', 'tim_so_bi_chia', 77::int),
    (3::smallint, 'number', 'Hình tứ giác ABCD có bốn cạnh đều bằng 5 cm. Nếu mỗi cạnh tăng thêm 2 cm thì chu vi tăng thêm ___ cm.', null, null, null, null, '8', null::jsonb, 'Bốn cạnh, mỗi cạnh tăng 2 cm: 2 x 4 = 8 (cm).', 'chu_vi_tu_giac', 71::int),
    (3::smallint, 'number', 'Tứ giác ABCD có CD = 7 cm, BC = 9 cm, tổng AB và AD bằng 1/2 tổng CD và BC. Chu vi tứ giác ABCD là ___ cm.', null, null, null, null, '24', null::jsonb, 'CD + BC = 16 cm, AB + AD = 8 cm; chu vi: 16 + 8 = 24 (cm).', 'chu_vi_tu_giac', 72::int),
    (3::smallint, 'number', 'Đoạn MQ chia tam giác MNP thành tam giác MNQ và MQP (Q nằm trên NP). MQ = 7 cm, chu vi MNQ là 23 cm, chu vi MQP là 21 cm. Chu vi MNP là ___ cm.', null, null, null, null, '30', null::jsonb, 'Cộng hai chu vi thì MQ bị tính 2 lần: 23 + 21 - 14 = 30 (cm).', 'chu_vi_tam_giac', 72::int),
    (3::smallint, 'number', 'Tứ giác ABCD có chu vi 46 cm, AB + AD + CD = 28 cm, CD + BC = 28 cm. Cạnh CD dài ___ cm.', null, null, null, null, '10', null::jsonb, 'BC = 46 - 28 = 18 cm; CD = 28 - 18 = 10 (cm).', 'chu_vi_tu_giac', 73::int),
    (3::smallint, 'number', 'Các hình vuông cạnh 1 cm xếp thành 3 hàng chồng lên nhau, căn giữa: hàng dưới 5 ô, hàng giữa 3 ô, hàng trên 1 ô. Chu vi cả hình là ___ cm.', null, null, null, null, '16', null::jsonb, 'Tổng các cạnh ngang là 5 + 5 = 10 cm, các cạnh dọc là 3 + 3 = 6 cm; 10 + 6 = 16 (cm).', 'chu_vi', 73::int),
    (3::smallint, 'number', 'Hình vuông bé nằm giữa hình vuông lớn, mỗi cạnh cách cạnh hình vuông lớn 1 cm. Chu vi hình vuông lớn là 12 cm. Chu vi hình vuông bé là ___ cm.', null, null, null, null, '4', null::jsonb, 'Cạnh lớn 12 : 4 = 3 cm; cạnh bé 3 - 1 - 1 = 1 cm; chu vi bé 1 x 4 = 4 (cm).', 'chu_vi', 73::int),
    (3::smallint, 'number', 'Tìm y, biết: y : 4 + 14 = 24. y = ___', null, null, null, null, '40', null::jsonb, 'y : 4 = 10 nên y = 10 x 4 = 40.', 'tim_so_bi_chia', 75::int),
    (3::smallint, 'number', 'Tìm y, biết: 13 - y : 3 = 9. y = ___', null, null, null, null, '12', null::jsonb, 'y : 3 = 13 - 9 = 4 nên y = 12.', 'tim_so_bi_chia', 75::int),
    (3::smallint, 'number', 'Tìm y, biết: y : 5 - 2 = 3. y = ___', null, null, null, null, '25', null::jsonb, 'y : 5 = 5 nên y = 25.', 'tim_so_bi_chia', 75::int),
    (3::smallint, 'number', 'Tìm y, biết: 80 - y : 4 = 56 + 19. y = ___', null, null, null, null, '20', null::jsonb, '56 + 19 = 75, y : 4 = 80 - 75 = 5 nên y = 20.', 'tim_so_bi_chia', 75::int),
    (3::smallint, 'number', 'Tìm y, biết: 12 + y : 5 = 83 - 69. y = ___', null, null, null, null, '10', null::jsonb, '83 - 69 = 14, y : 5 = 14 - 12 = 2 nên y = 10.', 'tim_so_bi_chia', 75::int),
    (3::smallint, 'number', 'Bà chia cam cho 3 cháu trai và 2 cháu gái, mỗi cháu được 4 quả. Lúc đầu bà có ___ quả cam.', null, null, null, null, '20', null::jsonb, 'Có 3 + 2 = 5 cháu; 4 x 5 = 20 (quả).', 'tim_so_bi_chia', 76::int),
    (3::smallint, 'number', 'Tìm số bị chia, biết thương là số lớn nhất có một chữ số và số chia bằng 1/3 thương. Số bị chia là ___.', null, null, null, null, '27', null::jsonb, 'Thương là 9, số chia là 9 : 3 = 3; số bị chia: 9 x 3 = 27.', 'tim_so_bi_chia', 76::int),
    (3::smallint, 'number', 'Mẹ đổ đầy mật ong vào 8 can loại 3 l thì còn thừa 2 l. Lúc đầu mẹ có ___ l mật ong.', null, null, null, null, '26', null::jsonb, '3 x 8 = 24 l, thêm 2 l thừa: 26 (l).', 'bai_toan_hai_buoc', 77::int),
    (3::smallint, 'number', 'Số lớn nhất mà khi đem 4 nhân với số đó được kết quả vẫn nhỏ hơn 30 là ___.', null, null, null, null, '7', null::jsonb, '4 x 7 = 28 < 30, còn 4 x 8 = 32 > 30.', 'suy_luan', 77::int),
    (3::smallint, 'number', 'Trong một phép chia, thương là 3, số chia là số liền sau của thương. Số bị chia là ___.', null, null, null, null, '12', null::jsonb, 'Số chia là 4; số bị chia = 3 x 4 = 12.', 'tim_so_bi_chia', 77::int),
    (3::smallint, 'number', 'An lấy bi theo thứ tự: 1 viên đỏ, 1 viên xanh, 1 viên vàng, cứ tiếp tục như thế đến khi đủ 20 viên. An lấy được ___ viên bi vàng.', null, null, null, null, '6', null::jsonb, '20 viên gồm 6 lượt đủ 3 màu (18 viên) và thêm 1 đỏ, 1 xanh; có 6 viên vàng.', 'suy_luan', 77::int),
    (3::smallint, 'number', 'Tam giác ABC có AB = 12 cm, tổng hai cạnh BC và CA hơn AB 7 cm. Chu vi tam giác ABC là ___ cm.', null, null, null, null, '31', null::jsonb, 'BC + CA = 19 cm; chu vi: 12 + 19 = 31 (cm).', 'chu_vi_tam_giac', 78::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 26 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 27: Số 0 và số 1 trong phép nhân và phép chia (50 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 27, 100, 'Archimes: Số 0 và số 1 trong phép nhân và phép chia', 'Ngân hàng Archimes — Toán 2 - Quyển 3, tuần 27', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '7 x 1 = ___', null, null, null, null, '7', null::jsonb, 'Số nào nhân với 1 cũng bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '1 x 81 = ___', null, null, null, null, '81', null::jsonb, 'Số 1 nhân với số nào cũng bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '24 : 1 = ___', null, null, null, null, '24', null::jsonb, 'Số nào chia cho 1 cũng bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '56 : 1 = ___', null, null, null, null, '56', null::jsonb, 'Số nào chia cho 1 cũng bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '0 x 100 = ___', null, null, null, null, '0', null::jsonb, 'Số 0 nhân với số nào cũng bằng 0.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '0 : 8 = ___', null, null, null, null, '0', null::jsonb, 'Số 0 chia cho số nào khác 0 cũng bằng 0.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '1 : 1 = ___', null, null, null, null, '1', null::jsonb, 'Số nào chia cho 1 cũng bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'multiple_choice', 'Số nào chia cho 1 cũng bằng:', 'Chính số đó', 'Số 1', 'Số 0', null, 'Chính số đó', null::jsonb, 'a : 1 = a.', 'so_0_so_1', 79::int),
    (1::smallint, 'multiple_choice', 'Khẳng định nào dưới đây ĐÚNG?', 'Số nào nhân với 0 cũng bằng chính số đó', 'Số 0 chia cho số khác 0 thì bằng 0', 'Số nào chia cho 1 cũng bằng 1', 'Số nào nhân với 1 cũng bằng 1', 'Số 0 chia cho số khác 0 thì bằng 0', null::jsonb, '0 : a = 0 với a khác 0.', 'so_0_so_1', 80::int),
    (1::smallint, 'multiple_choice', 'Khẳng định nào dưới đây SAI?', 'Số nào nhân với 1 cũng bằng chính số đó', 'Số 0 chia cho số khác 0 thì bằng 0', 'Số nào nhân với 0 cũng bằng chính số đó', 'Số 0 nhân với số nào cũng bằng 0', 'Số nào nhân với 0 cũng bằng chính số đó', null::jsonb, 'Số nào nhân với 0 cũng bằng 0, không bằng chính số đó.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '___ x 1 = 2', null, null, null, null, '2', null::jsonb, 'Số nào nhân với 1 cũng bằng chính số đó nên số cần điền là 2.', 'so_0_so_1', 80::int),
    (1::smallint, 'number', '___ : 1 = 4', null, null, null, null, '4', null::jsonb, 'Số nào chia cho 1 cũng bằng chính số đó nên số cần điền là 4.', 'so_0_so_1', 80::int),
    (1::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): Bất cứ số nào chia cho 1 cũng bằng 1. ___', null, null, null, null, 'S', '["sai"]'::jsonb, 'Số nào chia cho 1 cũng bằng chính số đó, ví dụ 5 : 1 = 5.', 'so_0_so_1', 80::int),
    (1::smallint, 'text', 'Điền Đ (đúng) hoặc S (sai): Bất cứ số nào nhân với 1 cũng bằng chính số đó. ___', null, null, null, null, 'Đ', '["đúng"]'::jsonb, 'a x 1 = a, ví dụ 7 x 1 = 7.', 'so_0_so_1', 80::int),
    (2::smallint, 'number', '1 x 3 + 13 = ___', null, null, null, null, '16', null::jsonb, '1 x 3 = 3, 3 + 13 = 16.', 'thu_tu_phep_tinh', 80::int),
    (2::smallint, 'number', '60 x 1 + 0 x 98 = ___', null, null, null, null, '60', null::jsonb, '60 x 1 = 60, 0 x 98 = 0, 60 + 0 = 60.', 'so_0_so_1', 80::int),
    (2::smallint, 'number', '10 : 2 : 5 x 80 = ___', null, null, null, null, '80', null::jsonb, '10 : 2 = 5, 5 : 5 = 1, 1 x 80 = 80.', 'so_0_so_1', 81::int),
    (2::smallint, 'number', '1 x 1 + 3 x 1 + 5 x 2 + 7 x 1 + 9 x 1 = ___', null, null, null, null, '30', null::jsonb, '1 + 3 + 10 + 7 + 9 = 30.', 'so_0_so_1', 81::int),
    (2::smallint, 'number', '58 x 0 + 99 = ___', null, null, null, null, '99', null::jsonb, '58 x 0 = 0, 0 + 99 = 99.', 'so_0_so_1', 81::int),
    (2::smallint, 'number', '5 x 8 : 1 = ___', null, null, null, null, '40', null::jsonb, '5 x 8 = 40, 40 : 1 = 40.', 'so_0_so_1', 86::int),
    (2::smallint, 'number', '5 x ___ + 15 = 15', null, null, null, null, '0', null::jsonb, '5 x ___ = 0 nên số cần điền là 0.', 'so_0_so_1', 80::int),
    (2::smallint, 'number', '10 + ___ x 10 = 20', null, null, null, null, '1', null::jsonb, '___ x 10 = 10 nên số cần điền là 1.', 'so_0_so_1', 86::int),
    (2::smallint, 'number', 'Tìm a, biết: 3 x 0 + a = 21. a = ___', null, null, null, null, '21', null::jsonb, '3 x 0 = 0 nên a = 21.', 'so_0_so_1', 81::int),
    (2::smallint, 'number', 'Người ta cắm vào mỗi lọ 4 bông hoa thì được 8 lọ. Có tất cả ___ bông hoa.', null, null, null, null, '32', null::jsonb, '4 x 8 = 32 (bông).', 'bai_toan_phep_nhan', 86::int),
    (2::smallint, 'number', 'Có 40 kg gạo chia đều vào các túi, mỗi túi 5 kg. Chia được ___ túi gạo.', null, null, null, null, '8', null::jsonb, '40 : 5 = 8 (túi).', 'bai_toan_phep_chia', 86::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 17 : 1 + 4 x 9 ___ 0 : 7 + 4 x 9 + 17', '=', '>', '<', null, '=', null::jsonb, 'Vế trái: 17 + 36 = 53; vế phải: 0 + 36 + 17 = 53.', 'so_sanh', 86::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 8 : 4 : 2 ___ 1 x 1 x 2', '>', '<', '=', null, '<', null::jsonb, '8 : 4 : 2 = 1, 1 x 1 x 2 = 2, mà 1 < 2.', 'so_sanh', 87::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 12 : 3 x 6 ___ 9 x 2 + 3', '<', '=', '>', null, '>', null::jsonb, '12 : 3 x 6 = 24, 9 x 2 + 3 = 21, mà 24 > 21.', 'so_sanh', 87::int),
    (3::smallint, 'number', 'Tìm a, biết: 16 - a x 1 = 6. a = ___', null, null, null, null, '10', null::jsonb, 'a x 1 = 16 - 6 = 10 nên a = 10.', 'tim_x', 81::int),
    (3::smallint, 'number', 'Tìm a, biết: 16 : 2 x 0 = a x 5. a = ___', null, null, null, null, '0', null::jsonb, 'Vế trái bằng 0, nên a x 5 = 0, do đó a = 0.', 'tim_x', 81::int),
    (3::smallint, 'number', 'Tìm y, biết: y : 4 = 27 - 3 x 9. y = ___', null, null, null, null, '0', null::jsonb, '27 - 27 = 0, y : 4 = 0 nên y = 0 x 4 = 0.', 'tim_so_bi_chia', 82::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 2 = 5 x 2 + 8. y = ___', null, null, null, null, '9', null::jsonb, 'y x 2 = 18 nên y = 9.', 'tim_thua_so', 82::int),
    (3::smallint, 'number', 'Tìm y, biết: y + y + y + y - y = 31 - 7. y = ___', null, null, null, null, '8', null::jsonb, 'Vế trái là y x 3; y x 3 = 24 nên y = 8.', 'tim_x', 82::int),
    (3::smallint, 'number', 'Tìm y, biết: y : 5 = 31 - 9 x 3. y = ___', null, null, null, null, '20', null::jsonb, '31 - 27 = 4, y : 5 = 4 nên y = 20.', 'tim_so_bi_chia', 87::int),
    (3::smallint, 'number', 'Điền số: 60 x 1 - 42 = 6 x ___', null, null, null, null, '3', null::jsonb, '60 - 42 = 18 = 6 x 3.', 'so_0_so_1', 80::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 50 và thương bằng 50 là:', '25 và 2', '10 và 5', '50 và 0', '50 và 1', '50 và 1', null::jsonb, '50 x 1 = 50 và 50 : 1 = 50.', 'tim_hai_so', 82::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 0 và tổng bằng 79 là:', '79 và 1', '78 và 1', '40 và 39', '79 và 0', '79 và 0', null::jsonb, 'Tích bằng 0 thì có một số là 0; số kia là 79.', 'tim_hai_so', 82::int),
    (3::smallint, 'number', 'Số có hai chữ số, biết tổng hai chữ số bằng 4 và thương của hai chữ số bằng 0, là số ___.', null, null, null, null, '40', null::jsonb, 'Thương bằng 0 nên có chữ số 0 (đứng ở hàng đơn vị); chữ số kia là 4: số 40.', 'cau_tao_so', 83::int),
    (3::smallint, 'multiple_choice', 'Hai số có thương bằng 1 và tổng bằng 18 là:', '18 và 1', '10 và 8', '17 và 1', '9 và 9', '9 và 9', null::jsonb, 'Thương bằng 1 thì hai số bằng nhau; 9 + 9 = 18.', 'tim_hai_so', 83::int),
    (3::smallint, 'number', 'Số có hai chữ số, biết thương hai chữ số bằng 1 và số đó là số liền trước của một số tròn chục, là số ___.', null, null, null, null, '99', null::jsonb, 'Hai chữ số bằng nhau và tận cùng là 9: số 99.', 'cau_tao_so', 83::int),
    (3::smallint, 'number', 'Một phép chia có số bị chia bằng thương, tổng của số bị chia và số chia là 28. Số bị chia là ___.', null, null, null, null, '27', null::jsonb, 'Số bị chia bằng thương thì số chia là 1; số bị chia: 28 - 1 = 27.', 'suy_luan', 83::int),
    (3::smallint, 'number', 'Trường có 25 lớp. 2 lớp khối Hai được ghép thành 1 lớp, 3 lớp khối Một được tách thành 5 lớp. Bây giờ trường có ___ lớp.', null, null, null, null, '26', null::jsonb, 'Khối Hai bớt 1 lớp, khối Một thêm 2 lớp: 25 - 1 + 2 = 26.', 'suy_luan', 84::int),
    (3::smallint, 'number', 'Lồng ống A dài 35 cm và ống B dài 42 cm với nhau được ống C dài 70 cm. Đoạn ghép nối dài ___ cm.', null, null, null, null, '7', null::jsonb, '35 + 42 = 77 cm; đoạn nối: 77 - 70 = 7 (cm).', 'suy_luan', 84::int),
    (3::smallint, 'number', 'An đếm một viên bi đỏ rồi một viên bi xanh, cứ tiếp tục như thế đếm được 14 viên. An đếm được ___ viên bi đỏ.', null, null, null, null, '7', null::jsonb, 'Mỗi lượt 1 đỏ 1 xanh; 14 : 2 = 7 lượt nên có 7 viên đỏ.', 'suy_luan', 84::int),
    (3::smallint, 'number', 'Mỗi khay xếp 4 quả: cam xếp đủ 5 khay, táo đủ 6 khay, ổi đủ 5 khay và thừa 1 quả. Cả ba loại có ___ quả.', null, null, null, null, '65', null::jsonb, 'Cam 20, táo 24, ổi 21; 20 + 24 + 21 = 65 (quả).', 'bai_toan_hai_buoc', 85::int),
    (3::smallint, 'number', 'Mỗi hộp quà có 2 gói bánh, 5 gói kẹo, 3 gói mứt. Để xếp 9 hộp, mẹ còn thiếu 3 gói kẹo. Mẹ đã chuẩn bị ___ gói kẹo.', null, null, null, null, '42', null::jsonb, 'Cần 5 x 9 = 45 gói kẹo, thiếu 3: 45 - 3 = 42 (gói).', 'bai_toan_hai_buoc', 85::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích bằng 24 và tổng bằng 25 là:', '24 và 1', '12 và 2', '20 và 5', '6 và 4', '24 và 1', null::jsonb, '24 x 1 = 24 và 24 + 1 = 25.', 'tim_hai_so', 86::int),
    (3::smallint, 'multiple_choice', 'Hai số có tích và thương đều bằng 17 là:', '17 và 0', '17 và 1', '34 và 2', '17 và 17', '17 và 1', null::jsonb, '17 x 1 = 17 và 17 : 1 = 17.', 'tim_hai_so', 86::int),
    (3::smallint, 'number', 'Dung cắm đều hoa vào 8 lọ, mỗi lọ 5 bông thì còn thừa 2 bông. Dung có tất cả ___ bông hoa.', null, null, null, null, '42', null::jsonb, '5 x 8 = 40, thêm 2 bông thừa: 42 (bông).', 'bai_toan_hai_buoc', 87::int),
    (3::smallint, 'number', 'Một tứ giác có bốn cạnh bằng nhau và chu vi 40 cm. Mỗi cạnh dài ___ dm.', null, null, null, null, '1', null::jsonb, 'Mỗi cạnh: 40 : 4 = 10 cm = 1 dm.', 'chu_vi_tu_giac', 87::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 27 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 28: Số có ba chữ số. Số tròn chục, tròn trăm (41 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 28, 100, 'Archimes: Số có ba chữ số. Số tròn chục, tròn trăm', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 28', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số gồm 5 trăm, 3 chục và 2 đơn vị viết là ___', null, null, null, null, '532', null::jsonb, '5 trăm, 3 chục, 2 đơn vị viết là 532.', 'cau_tao_so', 5::int),
    (1::smallint, 'number', 'Số gồm 7 trăm và 2 chục viết là ___', null, null, null, null, '720', null::jsonb, '7 trăm là 700, 2 chục là 20, không có đơn vị nên viết 0 ở hàng đơn vị: 720.', 'cau_tao_so', 5::int),
    (1::smallint, 'number', 'Số gồm 4 trăm và 6 đơn vị viết là ___', null, null, null, null, '406', null::jsonb, 'Không có chục nên viết 0 ở hàng chục: 406.', 'cau_tao_so', 5::int),
    (1::smallint, 'multiple_choice', 'Số 725 đọc là:', 'Bảy trăm hai mươi lăm', 'Bảy trăm hai mươi năm', 'Bảy hai mươi lăm', 'Bảy trăm năm mươi hai', 'Bảy trăm hai mươi lăm', null::jsonb, '725 gồm 7 trăm, 2 chục, 5 đơn vị, đọc là bảy trăm hai mươi lăm.', 'doc_viet_so', 5::int),
    (1::smallint, 'multiple_choice', 'Số “Hai trăm chín mươi” viết là:', '209', '290', '2090', '219', '290', null::jsonb, 'Hai trăm chín mươi gồm 2 trăm, 9 chục, 0 đơn vị: 290.', 'doc_viet_so', 5::int),
    (1::smallint, 'number', 'Viết số thành tổng: 534 = 500 + ___ + 4', null, null, null, null, '30', null::jsonb, '534 gồm 5 trăm, 3 chục, 4 đơn vị nên 534 = 500 + 30 + 4.', 'phan_tich_so', 5::int),
    (1::smallint, 'number', 'Trong số 453, giá trị của chữ số 5 là ___', null, null, null, null, '50', null::jsonb, 'Chữ số 5 ở hàng chục nên có giá trị là 50.', 'gia_tri_chu_so', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 416 ___ 425', '>', '<', '=', null, '<', null::jsonb, 'Hàng trăm đều là 4, hàng chục 1 < 2 nên 416 < 425.', 'so_sanh_so', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 999 ___ 900 + 99', '>', '<', '=', null, '=', null::jsonb, '900 + 99 = 999 nên hai bên bằng nhau.', 'so_sanh_so', 6::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 178 ___ 187', '>', '<', '=', null, '<', null::jsonb, 'Hàng trăm đều là 1, hàng chục 7 < 8 nên 178 < 187.', 'so_sanh_so', 7::int),
    (1::smallint, 'text', 'Viết tiếp tiếng còn thiếu: số 115 đọc là “Một trăm mười ___”', null, null, null, null, 'lăm', null::jsonb, 'Hàng đơn vị là 5 đứng sau “mười” thì đọc là “lăm”.', 'doc_viet_so', 5::int),
    (1::smallint, 'text', 'Viết tiếp tiếng còn thiếu: số 204 đọc là “Hai trăm ___ tư”', null, null, null, null, 'linh', '["lẻ"]'::jsonb, 'Hàng chục là 0 thì đọc “linh” (hoặc “lẻ”): hai trăm linh tư.', 'doc_viet_so', 5::int),
    (1::smallint, 'number', 'Số liền sau số 915 là ___', null, null, null, null, '916', null::jsonb, 'Số liền sau thì hơn 1 đơn vị: 915 + 1 = 916.', 'so_lien_truoc_lien_sau', 8::int),
    (1::smallint, 'number', 'Số liền trước số 249 là ___', null, null, null, null, '248', null::jsonb, 'Số liền trước thì kém 1 đơn vị: 249 - 1 = 248.', 'so_lien_truoc_lien_sau', 8::int),
    (1::smallint, 'number', 'Số bé nhất có ba chữ số là ___', null, null, null, null, '100', null::jsonb, 'Số bé nhất có ba chữ số là 100.', 'cau_tao_so', 8::int),
    (1::smallint, 'number', 'Tính: 74 + 40 : 5 = ___', null, null, null, null, '82', null::jsonb, 'Chia trước, cộng sau: 40 : 5 = 8, 74 + 8 = 82.', 'tinh_gia_tri_bieu_thuc', 9::int),
    (1::smallint, 'number', 'Tính: 50 : 5 x 4 = ___', null, null, null, null, '40', null::jsonb, 'Tính từ trái sang phải: 50 : 5 = 10, 10 x 4 = 40.', 'tinh_gia_tri_bieu_thuc', 9::int),
    (2::smallint, 'multiple_choice', 'Dãy số nào được viết theo thứ tự từ lớn đến bé?', '170; 140; 150; 130; 110', '110; 130; 140; 150; 170', '170; 150; 140; 130; 110', '170; 150; 130; 140; 110', '170; 150; 140; 130; 110', null::jsonb, 'So sánh các số tròn chục rồi xếp từ số lớn nhất 170 đến số bé nhất 110.', 'sap_xep_so', 6::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 860 ___ 800 + 50 + 9', '>', '<', '=', null, '>', null::jsonb, '800 + 50 + 9 = 859, mà 860 > 859.', 'so_sanh_so', 6::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 244 ___ 200 + 44', '>', '<', '=', null, '=', null::jsonb, '200 + 44 = 244 nên hai bên bằng nhau.', 'so_sanh_so', 7::int),
    (2::smallint, 'number', 'Có ___ số tròn trăm lớn hơn 300 và bé hơn 700.', null, null, null, null, '3', null::jsonb, 'Đó là các số 400; 500; 600.', 'so_tron_tram', 7::int),
    (2::smallint, 'number', 'Có ___ số tròn chục lớn hơn 80 và bé hơn 130.', null, null, null, null, '4', null::jsonb, 'Đó là các số 90; 100; 110; 120.', 'so_tron_chuc', 7::int),
    (2::smallint, 'number', 'Số tròn trăm liền sau số 115 là ___', null, null, null, null, '200', null::jsonb, '115 nằm giữa 100 và 200, số tròn trăm liền sau là 200.', 'so_tron_tram', 8::int),
    (2::smallint, 'number', 'Số lớn nhất có ba chữ số khác nhau là ___', null, null, null, null, '987', null::jsonb, 'Chọn các chữ số lớn nhất, khác nhau: 9, 8, 7 → 987.', 'cau_tao_so', 8::int),
    (2::smallint, 'number', 'Số chẵn lớn nhất có ba chữ số khác nhau là ___', null, null, null, null, '986', null::jsonb, 'Hàng trăm 9, hàng chục 8, hàng đơn vị là số chẵn lớn nhất còn lại là 6: 986.', 'cau_tao_so', 8::int),
    (2::smallint, 'number', 'Số lẻ nhỏ nhất có ba chữ số khác nhau là ___', null, null, null, null, '103', null::jsonb, 'Hàng trăm 1, hàng chục 0, hàng đơn vị lẻ nhỏ nhất khác 1 là 3: 103.', 'cau_tao_so', 8::int),
    (2::smallint, 'number', 'Tính: 19 + 29 + 39 + 49 = ___', null, null, null, null, '136', null::jsonb, '19 + 29 = 48, 48 + 39 = 87, 87 + 49 = 136.', 'tinh_gia_tri_bieu_thuc', 9::int),
    (2::smallint, 'number', 'Tìm y, biết: y - 60 + 20 = 50. y = ___', null, null, null, null, '90', null::jsonb, 'y - 60 = 50 - 20 = 30, nên y = 30 + 60 = 90.', 'tim_thanh_phan', 10::int),
    (2::smallint, 'multiple_choice', 'Số gồm 5 trăm, 2 chục và 42 đơn vị là:', '5242', '542', '524', '562', '562', null::jsonb, '500 + 20 + 42 = 562.', 'cau_tao_so', 5::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 200 ___ 10 : 5 + 98', '>', '<', '=', null, '>', null::jsonb, '10 : 5 + 98 = 2 + 98 = 100, mà 200 > 100.', 'so_sanh_so', 11::int),
    (2::smallint, 'number', 'Hiệu của hai số bằng 37, số bị trừ là số tròn trăm bé nhất có ba chữ số. Số trừ là ___', null, null, null, null, '63', null::jsonb, 'Số bị trừ là 100. Số trừ = 100 - 37 = 63.', 'tim_thanh_phan', 11::int),
    (3::smallint, 'number', 'Tìm số có ba chữ số, biết chữ số hàng trăm là số liền sau số nhỏ nhất có một chữ số, chữ số hàng chục là số lẻ lớn nhất có một chữ số, chữ số hàng đơn vị là tích của 2 và 3. Số đó là ___', null, null, null, null, '196', null::jsonb, 'Hàng trăm: liền sau 0 là 1; hàng chục: 9; hàng đơn vị: 2 x 3 = 6. Số đó là 196.', 'cau_tao_so', 6::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 5 + y = 4 x 6. y = ___', null, null, null, null, '4', null::jsonb, 'y x 5 + y = y x 6 = 24, nên y = 24 : 6 = 4.', 'tim_thanh_phan', 9::int),
    (3::smallint, 'number', 'Tìm y, biết: y + y + y + y - 30 = 6. y = ___', null, null, null, null, '9', null::jsonb, 'y x 4 = 6 + 30 = 36, nên y = 36 : 4 = 9.', 'tim_thanh_phan', 10::int),
    (3::smallint, 'number', 'Bác An nhốt thỏ vào 8 chuồng, mỗi chuồng 4 con. Bác bán đi 2 con rồi chia đều số thỏ còn lại vào 5 chuồng. Lúc sau mỗi chuồng có ___ con thỏ.', null, null, null, null, '6', null::jsonb, 'Đàn thỏ có 8 x 4 = 32 con, bán 2 còn 30 con, 30 : 5 = 6 con.', 'bai_toan_hai_buoc', 10::int),
    (3::smallint, 'number', 'Một đường gấp khúc gồm ba đoạn thẳng: đoạn thứ nhất dài 7 cm, đoạn thứ hai dài 2 dm, đoạn thứ ba dài hơn đoạn thứ hai 12 cm. Đường gấp khúc dài ___ cm.', null, null, null, null, '59', null::jsonb, '2 dm = 20 cm; đoạn thứ ba 20 + 12 = 32 cm; độ dài: 7 + 20 + 32 = 59 cm.', 'duong_gap_khuc', 10::int),
    (3::smallint, 'number', 'Nam có 4 chục quyển vở và ít hơn Hưng 12 quyển. Cả hai bạn có tất cả ___ quyển vở.', null, null, null, null, '92', null::jsonb, 'Nam có 40 quyển, Hưng có 40 + 12 = 52 quyển, cả hai có 40 + 52 = 92 quyển.', 'bai_toan_hai_buoc', 11::int),
    (3::smallint, 'number', 'Tìm y, biết: y x 4 + y = 3 x 5. y = ___', null, null, null, null, '3', null::jsonb, 'y x 4 + y = y x 5 = 15, nên y = 15 : 5 = 3.', 'tim_thanh_phan', 11::int),
    (3::smallint, 'number', 'Linh xếp bánh vào 5 hộp, mỗi hộp 5 cái thì thừa 3 cái. Nếu xếp đều số bánh đó vào 4 hộp thì mỗi hộp có ___ cái bánh.', null, null, null, null, '7', null::jsonb, 'Số bánh là 5 x 5 + 3 = 28 cái, 28 : 4 = 7 cái.', 'bai_toan_hai_buoc', 11::int),
    (3::smallint, 'number', 'Mẹ cắm hoa vào 6 lọ, mỗi lọ 4 bông thì thừa 3 bông. Nếu cắm đều số hoa đó vào 3 lọ thì mỗi lọ có ___ bông.', null, null, null, null, '9', null::jsonb, 'Số hoa là 6 x 4 + 3 = 27 bông, 27 : 3 = 9 bông.', 'bai_toan_hai_buoc', 12::int),
    (3::smallint, 'number', 'Số gồm 20 chục và 20 đơn vị là ___', null, null, null, null, '220', null::jsonb, '20 chục = 200, thêm 20 đơn vị được 220.', 'cau_tao_so', 12::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 28 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 29: Số có ba chữ số (40 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 29, 100, 'Archimes: Số có ba chữ số', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 29', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số 639 gồm 6 trăm, ___ chục và 9 đơn vị.', null, null, null, null, '3', null::jsonb, '639 = 600 + 30 + 9, tức là 6 trăm, 3 chục, 9 đơn vị.', 'cau_tao_so', 13::int),
    (1::smallint, 'text', 'Viết tiếp tiếng còn thiếu: số 639 đọc là “Sáu trăm ba mươi ___”', null, null, null, null, 'chín', null::jsonb, '639 gồm 6 trăm, 3 chục, 9 đơn vị: sáu trăm ba mươi chín.', 'doc_viet_so', 13::int),
    (1::smallint, 'number', 'Viết số: 7 x 100 + 2 x 10 + 5 = ___', null, null, null, null, '725', null::jsonb, '7 trăm, 2 chục, 5 đơn vị là số 725.', 'cau_tao_so', 13::int),
    (1::smallint, 'multiple_choice', 'Chữ số a nào thích hợp để có 295 > 29a?', '3', '5', '6', '9', '3', null::jsonb, 'Hàng trăm, hàng chục bằng nhau nên cần a < 5; chỉ có 3 thỏa mãn.', 'so_sanh_so', 14::int),
    (1::smallint, 'multiple_choice', 'Chữ số a nào thích hợp để có a98 > 797?', '7', '8', '6', '5', '8', null::jsonb, 'Cần chữ số hàng trăm a lớn hơn 7, trong các lựa chọn chỉ có 8.', 'so_sanh_so', 14::int),
    (1::smallint, 'multiple_choice', 'Số nào là số tròn chục có ba chữ số bé hơn 200?', '175', '210', '170', '90', '170', null::jsonb, '170 có ba chữ số, tận cùng là 0 và bé hơn 200.', 'so_tron_chuc', 18::int),
    (1::smallint, 'number', 'Tính: 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = ___', null, null, null, null, '45', null::jsonb, 'Ghép cặp: (1 + 9) + (2 + 8) + (3 + 7) + (4 + 6) + 5 = 40 + 5 = 45.', 'tinh_nhanh', 19::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 1 m ___ 90 cm', '>', '<', '=', null, '>', null::jsonb, '1 m = 100 cm, mà 100 cm > 90 cm.', 'do_dai', 20::int),
    (1::smallint, 'number', '18 m : 3 + 35 m = ___ m', null, null, null, null, '41', null::jsonb, '18 : 3 = 6, 6 + 35 = 41 (m).', 'tinh_gia_tri_bieu_thuc', 20::int),
    (1::smallint, 'multiple_choice', 'Các số 687; 213; 900; 182; 620 xếp theo thứ tự từ lớn đến bé là:', '182; 213; 620; 687; 900', '900; 687; 620; 182; 213', '900; 620; 687; 213; 182', '900; 687; 620; 213; 182', '900; 687; 620; 213; 182', null::jsonb, 'So sánh hàng trăm trước: 9 > 6 > 2 > 1; 687 > 620 vì hàng chục 8 > 2.', 'sap_xep_so', 20::int),
    (1::smallint, 'number', 'Tính: 3 x 7 - 19 = ___', null, null, null, null, '2', null::jsonb, '3 x 7 = 21, 21 - 19 = 2.', 'tinh_gia_tri_bieu_thuc', 21::int),
    (1::smallint, 'number', 'Tính: 52 - 8 x 3 = ___', null, null, null, null, '28', null::jsonb, 'Nhân trước, trừ sau: 8 x 3 = 24, 52 - 24 = 28.', 'tinh_gia_tri_bieu_thuc', 21::int),
    (1::smallint, 'number', 'Tính: 18 + 27 - 6 = ___', null, null, null, null, '39', null::jsonb, '18 + 27 = 45, 45 - 6 = 39.', 'tinh_gia_tri_bieu_thuc', 21::int),
    (2::smallint, 'number', 'Tìm số có ba chữ số, biết chữ số hàng trăm là số chẵn lớn nhất có một chữ số, chữ số hàng chục là 0, chữ số hàng đơn vị là tích của 2 và 4. Số đó là ___', null, null, null, null, '808', null::jsonb, 'Hàng trăm: 8; hàng chục: 0; hàng đơn vị: 2 x 4 = 8. Số đó là 808.', 'cau_tao_so', 14::int),
    (2::smallint, 'number', 'Tìm số có ba chữ số, biết chữ số hàng trăm là số chẵn lớn nhất có một chữ số, chữ số hàng chục là số lẻ nhỏ nhất có một chữ số, chữ số hàng đơn vị là số liền trước số 5. Số đó là ___', null, null, null, null, '814', null::jsonb, 'Hàng trăm 8, hàng chục 1, hàng đơn vị 4. Số đó là 814.', 'cau_tao_so', 14::int),
    (2::smallint, 'number', 'Số tròn chục có ba chữ số, có chữ số hàng trăm là 9 và chữ số hàng chục là số liền trước chữ số hàng trăm. Số đó là ___', null, null, null, null, '980', null::jsonb, 'Hàng trăm 9, hàng chục 8, số tròn chục nên hàng đơn vị là 0: 980.', 'cau_tao_so', 15::int),
    (2::smallint, 'number', 'Có ___ số có hai chữ số mà tổng các chữ số bằng 13.', null, null, null, null, '6', null::jsonb, 'Đó là 49; 58; 67; 76; 85; 94.', 'lap_so', 16::int),
    (2::smallint, 'multiple_choice', 'Từ ba chữ số 1; 2; 4, số lớn nhất có ba chữ số khác nhau là:', '421', '412', '241', '124', '421', null::jsonb, 'Xếp chữ số lớn nhất ở hàng trăm, rồi đến hàng chục: 421.', 'lap_so', 16::int),
    (2::smallint, 'number', 'Từ ba chữ số 0; 7; 9 lập được ___ số có ba chữ số khác nhau.', null, null, null, null, '4', null::jsonb, 'Đó là 709; 790; 907; 970 (chữ số 0 không đứng ở hàng trăm).', 'lap_so', 17::int),
    (2::smallint, 'multiple_choice', 'Các số có ba chữ số khác nhau lập từ 0; 7; 9, xếp từ lớn đến bé là:', '970; 790; 907; 709', '970; 907; 790; 709', '709; 790; 907; 970', '970; 907; 709; 790', '970; 907; 790; 709', null::jsonb, 'Hàng trăm 9 lớn hơn 7; 970 > 907 và 790 > 709.', 'sap_xep_so', 17::int),
    (2::smallint, 'number', 'Tìm một số, biết số đó nhân với số liền sau số nhỏ nhất có một chữ số thì được 7. Số đó là ___', null, null, null, null, '7', null::jsonb, 'Số nhỏ nhất có một chữ số là 0, liền sau là 1. Số cần tìm: 7 : 1 = 7.', 'tim_thanh_phan', 17::int),
    (2::smallint, 'number', 'Cho a x 4 = 20 và b : 3 = 5. Tính a + b = ___', null, null, null, null, '20', null::jsonb, 'a = 20 : 4 = 5; b = 5 x 3 = 15; a + b = 20.', 'tim_thanh_phan', 20::int),
    (2::smallint, 'number', 'Hiệu của số liền sau số lớn nhất có hai chữ số với số nhỏ nhất có một chữ số là ___', null, null, null, null, '100', null::jsonb, 'Liền sau 99 là 100; số nhỏ nhất có một chữ số là 0; 100 - 0 = 100.', 'cau_tao_so', 20::int),
    (2::smallint, 'multiple_choice', 'Viết tiếp ba số để được dãy có quy luật: 987; 876; 765; ___', '654; 543; 423', '755; 745; 735', '654; 543; 432', '654; 553; 432', '654; 543; 432', null::jsonb, 'Mỗi số sau kém số trước 111: 765 - 111 = 654, 543, 432.', 'day_so', 20::int),
    (2::smallint, 'number', 'Một sợi dây dài 32 m được cắt thành 4 đoạn bằng nhau. Mỗi đoạn dài ___ m.', null, null, null, null, '8', null::jsonb, '32 : 4 = 8 (m).', 'bai_toan_chia', 20::int),
    (2::smallint, 'number', 'Tính: 2 + 5 + 8 + 11 + 14 + 17 = ___', null, null, null, null, '57', null::jsonb, 'Ghép cặp: (2 + 17) + (5 + 14) + (8 + 11) = 19 x 3 = 57.', 'tinh_nhanh', 19::int),
    (2::smallint, 'number', 'Ba số tự nhiên liên tiếp có tổng là 15. Số lớn nhất trong ba số đó là ___', null, null, null, null, '6', null::jsonb, 'Ba số đó là 4; 5; 6 (4 + 5 + 6 = 15).', 'suy_luan', 19::int),
    (2::smallint, 'number', 'Tính: 5 + 10 + 15 + 20 + 25 + 30 + 35 = ___', null, null, null, null, '140', null::jsonb, '(5 + 35) + (10 + 30) + (15 + 25) + 20 = 40 x 3 + 20 = 140.', 'tinh_nhanh', 19::int),
    (3::smallint, 'number', 'Tìm số có ba chữ số, biết chữ số hàng chục là số lẻ nhỏ nhất có một chữ số, chữ số hàng đơn vị là số liền sau số chẵn lớn nhất có một chữ số, chữ số hàng trăm là hiệu của chữ số hàng đơn vị và chữ số hàng chục. Số đó là ___', null, null, null, null, '819', null::jsonb, 'Hàng chục 1, hàng đơn vị 9, hàng trăm 9 - 1 = 8. Số đó là 819.', 'cau_tao_so', 15::int),
    (3::smallint, 'multiple_choice', 'Số nào có chữ số hàng trăm lớn hơn chữ số hàng chục 1 đơn vị và bằng một nửa chữ số hàng đơn vị?', '324', '236', '436', '326', '326', null::jsonb, '326: hàng trăm 3 = 2 + 1, và 3 là một nửa của 6.', 'cau_tao_so', 15::int),
    (3::smallint, 'number', 'Có ___ số có ba chữ số khác nhau mà tổng các chữ số bằng 5.', null, null, null, null, '8', null::jsonb, 'Đó là 104; 140; 401; 410; 203; 230; 302; 320.', 'lap_so', 16::int),
    (3::smallint, 'number', 'Từ bốn chữ số 0; 1; 2; 6 lập được ___ số có ba chữ số khác nhau nhỏ hơn 300.', null, null, null, null, '12', null::jsonb, 'Hàng trăm là 1 có 6 số (102; 106; 120; 126; 160; 162), hàng trăm là 2 cũng có 6 số.', 'lap_so', 16::int),
    (3::smallint, 'number', 'Khi làm phép trừ một số cho 82, bạn Nam chép nhầm số trừ thành 32 nên được kết quả là 59. Kết quả đúng là ___', null, null, null, null, '9', null::jsonb, 'Số bị trừ là 59 + 32 = 91. Kết quả đúng: 91 - 82 = 9.', 'suy_luan', 17::int),
    (3::smallint, 'number', 'Có ___ số có ba chữ số khác nhau mà chữ số hàng chục gấp 5 lần chữ số hàng đơn vị.', null, null, null, null, '7', null::jsonb, 'Hàng đơn vị 1, hàng chục 5; hàng trăm là 2, 3, 4, 6, 7, 8, 9 (7 số).', 'lap_so', 18::int),
    (3::smallint, 'number', 'Có ___ số có ba chữ số lớn hơn 900 mà tổng các chữ số bằng 15.', null, null, null, null, '7', null::jsonb, 'Đó là 906; 915; 924; 933; 942; 951; 960.', 'lap_so', 18::int),
    (3::smallint, 'number', 'Tìm y, biết: 99 < y x 4 + 64 < 101. y = ___', null, null, null, null, '9', null::jsonb, 'y x 4 + 64 = 100, nên y x 4 = 36, y = 9.', 'tim_thanh_phan', 20::int),
    (3::smallint, 'number', 'Tìm số có ba chữ số, biết hiệu của chữ số hàng trăm và chữ số hàng chục là 0, hiệu của chữ số hàng chục và chữ số hàng đơn vị là 9. Số đó là ___', null, null, null, null, '990', null::jsonb, 'Hiệu hai chữ số bằng 9 thì đó là 9 và 0: hàng chục 9, hàng đơn vị 0; hàng trăm bằng hàng chục là 9. Số 990.', 'cau_tao_so', 20::int),
    (3::smallint, 'number', 'Ba số chẵn liên tiếp có tổng là 36. Số bé nhất trong ba số đó là ___', null, null, null, null, '10', null::jsonb, 'Số ở giữa là 36 : 3 = 12. Ba số là 10; 12; 14.', 'suy_luan', 19::int),
    (3::smallint, 'number', 'Cắt sợi dây thành 4 đoạn bằng nhau (không gấp dây) thì cần ___ lần cắt.', null, null, null, null, '3', null::jsonb, 'Số lần cắt ít hơn số đoạn 1: 4 - 1 = 3 lần.', 'suy_luan', 20::int),
    (3::smallint, 'number', 'Từ bốn chữ số 0; 1; 3; 5 lập được ___ số có ba chữ số khác nhau lớn hơn 350.', null, null, null, null, '7', null::jsonb, 'Hàng trăm 3 chỉ có 351; hàng trăm 5 có 501; 503; 510; 513; 530; 531.', 'lap_so', 21::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 29 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 30: Mét. Ki-lô-mét. Mi-li-mét (42 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 30, 100, 'Archimes: Mét. Ki-lô-mét. Mi-li-mét', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 30', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '2 m = ___ cm', null, null, null, null, '200', null::jsonb, '1 m = 100 cm nên 2 m = 200 cm.', 'doi_don_vi_do_dai', 23::int),
    (1::smallint, 'number', '4 dm 4 cm = ___ cm', null, null, null, null, '44', null::jsonb, '4 dm = 40 cm, 40 cm + 4 cm = 44 cm.', 'doi_don_vi_do_dai', 23::int),
    (1::smallint, 'number', '3 dm = ___ mm', null, null, null, null, '300', null::jsonb, '1 dm = 100 mm nên 3 dm = 300 mm.', 'doi_don_vi_do_dai', 23::int),
    (1::smallint, 'number', '9 m 5 dm = ___ dm', null, null, null, null, '95', null::jsonb, '9 m = 90 dm, 90 dm + 5 dm = 95 dm.', 'doi_don_vi_do_dai', 23::int),
    (1::smallint, 'number', '2 cm 1 mm = ___ mm', null, null, null, null, '21', null::jsonb, '2 cm = 20 mm, 20 mm + 1 mm = 21 mm.', 'doi_don_vi_do_dai', 23::int),
    (1::smallint, 'number', '1 km = ___ m', null, null, null, null, '1000', null::jsonb, '1 km = 1000 m.', 'doi_don_vi_do_dai', 22::int),
    (1::smallint, 'text', 'Mi-li-mét viết tắt là ___', null, null, null, null, 'mm', null::jsonb, 'Mi-li-mét viết tắt là mm.', 'don_vi_do_dai', 22::int),
    (1::smallint, 'text', 'Ki-lô-mét viết tắt là ___', null, null, null, null, 'km', null::jsonb, 'Ki-lô-mét viết tắt là km.', 'don_vi_do_dai', 22::int),
    (1::smallint, 'number', '54 m + 12 m - 47 m = ___ m', null, null, null, null, '19', null::jsonb, '54 + 12 = 66, 66 - 47 = 19 (m).', 'tinh_so_do_do_dai', 23::int),
    (1::smallint, 'number', '5 km x 4 + 60 km = ___ km', null, null, null, null, '80', null::jsonb, '5 x 4 = 20, 20 + 60 = 80 (km).', 'tinh_so_do_do_dai', 23::int),
    (1::smallint, 'number', '102 km + 37 km = ___ km', null, null, null, null, '139', null::jsonb, '102 + 37 = 139 (km).', 'tinh_so_do_do_dai', 24::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 999 m ___ 1 km', '>', '<', '=', null, '<', null::jsonb, '1 km = 1000 m, mà 999 m < 1000 m.', 'doi_don_vi_do_dai', 29::int),
    (1::smallint, 'multiple_choice', 'Trong các số 987; 789; 978; 897, số nhỏ nhất là:', '789', '987', '978', '897', '789', null::jsonb, '789 có chữ số hàng trăm nhỏ nhất (7).', 'so_sanh_so', 29::int),
    (1::smallint, 'number', 'Tính: 234 + 162 = ___', null, null, null, null, '396', null::jsonb, 'Cộng từng hàng: 4 + 2 = 6, 3 + 6 = 9, 2 + 1 = 3 → 396.', 'cong_khong_nho', 29::int),
    (1::smallint, 'multiple_choice', 'Đơn vị nào thích hợp nhất để đo quãng đường giữa hai thành phố?', 'mi-li-mét', 'ki-lô-mét', 'xăng-ti-mét', 'đề-xi-mét', 'ki-lô-mét', null::jsonb, 'Quãng đường dài giữa hai thành phố thường đo bằng ki-lô-mét.', 'don_vi_do_dai', 22::int),
    (1::smallint, 'multiple_choice', 'Viết tiếp ba số để được dãy có quy luật: 222; 333; 444; ___', '455; 466; 477', '544; 644; 744', '555; 666; 777', '555; 665; 777', '555; 666; 777', null::jsonb, 'Mỗi số sau hơn số trước 111.', 'day_so', 29::int),
    (2::smallint, 'number', '2 dm 25 mm = ___ mm', null, null, null, null, '225', null::jsonb, '2 dm = 200 mm, 200 + 25 = 225 (mm).', 'doi_don_vi_do_dai', 23::int),
    (2::smallint, 'number', '40 cm - 32 cm : 4 = ___ cm', null, null, null, null, '32', null::jsonb, 'Chia trước: 32 : 4 = 8, rồi 40 - 8 = 32 (cm).', 'tinh_so_do_do_dai', 23::int),
    (2::smallint, 'number', '42 km - 5 km x 6 = ___ km', null, null, null, null, '12', null::jsonb, '5 x 6 = 30, 42 - 30 = 12 (km).', 'tinh_so_do_do_dai', 24::int),
    (2::smallint, 'number', '36 km : 4 x 2 = ___ km', null, null, null, null, '18', null::jsonb, '36 : 4 = 9, 9 x 2 = 18 (km).', 'tinh_so_do_do_dai', 24::int),
    (2::smallint, 'number', 'Hình tam giác có độ dài các cạnh là 18 mm, 4 cm, 35 mm. Chu vi hình tam giác là ___ mm.', null, null, null, null, '93', null::jsonb, '4 cm = 40 mm; chu vi: 18 + 40 + 35 = 93 (mm).', 'chu_vi', 24::int),
    (2::smallint, 'number', 'Một sợi dây đồng được uốn thành hình tứ giác có mỗi cạnh dài 3 m. Đoạn dây đồng dài ___ m.', null, null, null, null, '12', null::jsonb, 'Tứ giác có 4 cạnh: 3 x 4 = 12 (m).', 'chu_vi', 24::int),
    (2::smallint, 'number', 'Một người đi xe đạp trong 3 giờ được 27 km, mỗi giờ đi được như nhau. Mỗi giờ người đó đi được ___ km.', null, null, null, null, '9', null::jsonb, '27 : 3 = 9 (km).', 'bai_toan_chia', 25::int),
    (2::smallint, 'number', 'Trong một giờ, ô tô đi được 70 km, xe máy đi được 40 km. Xe máy đi chậm hơn ô tô ___ km mỗi giờ.', null, null, null, null, '30', null::jsonb, '70 - 40 = 30 (km).', 'bai_toan_it_hon', 25::int),
    (2::smallint, 'number', 'Một người đi 17 km để đến thị trấn, rồi đi tiếp 25 km để đến thành phố. Người đó đã đi ___ km.', null, null, null, null, '42', null::jsonb, '17 + 25 = 42 (km).', 'bai_toan_tong', 25::int),
    (2::smallint, 'number', 'Nhà Minh cách trường 6 km, nhà Bình cách trường 9 km. Bình đi đến nhà Minh phải đi qua trường. Quãng đường từ nhà Bình đến nhà Minh dài ___ km.', null, null, null, null, '15', null::jsonb, '9 + 6 = 15 (km).', 'bai_toan_tong', 26::int),
    (2::smallint, 'number', 'Tứ giác ABCD có các cạnh dài 20 cm, 3 dm, 50 cm, 6 dm. Chu vi tứ giác là ___ dm.', null, null, null, null, '16', null::jsonb, 'Đổi ra dm: 2 dm, 3 dm, 5 dm, 6 dm; chu vi 2 + 3 + 5 + 6 = 16 (dm).', 'chu_vi', 29::int),
    (2::smallint, 'number', 'Một hình tứ giác có bốn cạnh bằng nhau và chu vi là 40 mm. Mỗi cạnh dài ___ mm.', null, null, null, null, '10', null::jsonb, '40 : 4 = 10 (mm).', 'chu_vi', 29::int),
    (2::smallint, 'number', 'Tam giác ABC có AB = 2 cm, BC = 36 mm, CA = 1 cm 8 mm. Chu vi tam giác là ___ mm.', null, null, null, null, '74', null::jsonb, '2 cm = 20 mm, 1 cm 8 mm = 18 mm; chu vi 20 + 36 + 18 = 74 (mm).', 'chu_vi', 30::int),
    (3::smallint, 'number', 'Tìm y, biết: y - 102 = 532 + 4 x 5. y = ___', null, null, null, null, '654', null::jsonb, '532 + 20 = 552; y = 552 + 102 = 654.', 'tim_thanh_phan', 29::int),
    (3::smallint, 'number', 'Minh và Bình cách nhau 170 m, cùng lúc đi tới gặp nhau. Khi Minh đi được 40 m thì Bình đi được ít hơn Minh 10 m. Lúc đó hai bạn còn cách nhau ___ m.', null, null, null, null, '100', null::jsonb, 'Bình đi 40 - 10 = 30 m; còn cách: 170 - 40 - 30 = 100 (m).', 'bai_toan_hai_buoc', 24::int),
    (3::smallint, 'number', 'Một người đi xe đạp trong 3 giờ được 27 km, mỗi giờ đi được như nhau. Trong 2 giờ người đó đi được ___ km.', null, null, null, null, '18', null::jsonb, 'Mỗi giờ 27 : 3 = 9 km; 2 giờ: 9 x 2 = 18 (km).', 'bai_toan_hai_buoc', 25::int),
    (3::smallint, 'number', 'Tứ giác ABCD có AB = 8 cm và ngắn hơn BC 4 cm, BC dài hơn CD 5 cm, AD dài bằng số lớn nhất có một chữ số (cm). Chu vi tứ giác là ___ cm.', null, null, null, null, '36', null::jsonb, 'BC = 12 cm, CD = 7 cm, AD = 9 cm; chu vi 8 + 12 + 7 + 9 = 36 (cm).', 'chu_vi', 26::int),
    (3::smallint, 'number', 'Độ dài các cạnh của tứ giác ABCD là bốn số tự nhiên liên tiếp, cạnh ngắn nhất AB = 15 cm. Chu vi tứ giác là ___ cm.', null, null, null, null, '66', null::jsonb, 'Các cạnh là 15, 16, 17, 18 cm; chu vi 66 cm.', 'chu_vi', 26::int),
    (3::smallint, 'number', 'Sợi dây dài 4 m 5 dm được cắt thành các đoạn 5 dm. Không gấp dây thì phải cắt ___ lần.', null, null, null, null, '8', null::jsonb, '4 m 5 dm = 45 dm, được 45 : 5 = 9 đoạn, cần 9 - 1 = 8 lần cắt.', 'suy_luan', 27::int),
    (3::smallint, 'number', 'Bác thợ cưa khúc gỗ dài 2 m thành các đoạn dài 5 dm. Bác phải cưa ___ lần.', null, null, null, null, '3', null::jsonb, '2 m = 20 dm, được 20 : 5 = 4 đoạn, cần 4 - 1 = 3 lần cưa.', 'suy_luan', 27::int),
    (3::smallint, 'number', 'Đoạn đường có trồng 7 cây xanh thẳng hàng, hai cây liền nhau cách nhau 3 m. Cây thứ nhất và cây thứ bảy cách nhau ___ m.', null, null, null, null, '18', null::jsonb, '7 cây có 6 khoảng cách: 6 x 3 = 18 (m).', 'suy_luan', 27::int),
    (3::smallint, 'number', 'Lồng hai ống dài 20 cm và 30 cm vào nhau thì được một ống mới dài 35 cm. Đoạn lồng vào nhau dài ___ cm.', null, null, null, null, '15', null::jsonb, '20 + 30 = 50 cm, đoạn lồng: 50 - 35 = 15 (cm).', 'suy_luan', 28::int),
    (3::smallint, 'number', 'Chi xếp kẹo thành hình tam giác, mỗi đỉnh 1 viên, mỗi cạnh có 5 viên (kể cả hai đỉnh). Chi dùng tất cả ___ viên kẹo.', null, null, null, null, '12', null::jsonb, '3 cạnh x 5 viên = 15, mỗi đỉnh bị đếm 2 lần nên bớt 3: 12 viên.', 'suy_luan', 28::int),
    (3::smallint, 'number', 'Quãng đường AB dài 47 km và dài hơn quãng đường CD 9 km. Cả hai quãng đường dài ___ km.', null, null, null, null, '85', null::jsonb, 'CD = 47 - 9 = 38 km; cả hai: 47 + 38 = 85 (km).', 'bai_toan_hai_buoc', 29::int),
    (3::smallint, 'number', 'Khúc gỗ dài 3 m 5 dm được cưa thành các đoạn 5 dm. Cần ___ lần cưa.', null, null, null, null, '6', null::jsonb, '3 m 5 dm = 35 dm, được 7 đoạn, cần 7 - 1 = 6 lần cưa.', 'suy_luan', 30::int),
    (3::smallint, 'multiple_choice', 'Có 2 quả cân 1 kg, 2 quả cân 2 kg và 1 quả cân 5 kg. Mỗi lần đặt đúng 3 quả cân lên một đĩa thì cân được bao nhiêu túi cam có cân nặng khác nhau?', '6', '4', '7', '5', '5', null::jsonb, 'Các cách: 1+1+2 = 4, 1+2+2 = 5, 1+1+5 = 7, 1+2+5 = 8, 2+2+5 = 9 → 5 cân nặng.', 'suy_luan', 28::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 30 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 31: Phép cộng, phép trừ không nhớ trong phạm vi 1000 (47 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 31, 100, 'Archimes: Phép cộng, phép trừ không nhớ trong phạm vi 1000', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 31', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '222 + 145 = ___', null, null, null, null, '367', null::jsonb, 'Cộng từng hàng: 2 + 5 = 7, 2 + 4 = 6, 2 + 1 = 3 → 367.', 'cong_khong_nho', 32::int),
    (1::smallint, 'number', '307 + 512 = ___', null, null, null, null, '819', null::jsonb, '7 + 2 = 9, 0 + 1 = 1, 3 + 5 = 8 → 819.', 'cong_khong_nho', 32::int),
    (1::smallint, 'number', '589 - 145 = ___', null, null, null, null, '444', null::jsonb, '9 - 5 = 4, 8 - 4 = 4, 5 - 1 = 4 → 444.', 'tru_khong_nho', 34::int),
    (1::smallint, 'number', '789 - 45 = ___', null, null, null, null, '744', null::jsonb, '9 - 5 = 4, 8 - 4 = 4, hàng trăm 7 → 744.', 'tru_khong_nho', 34::int),
    (1::smallint, 'number', '999 - 781 = ___', null, null, null, null, '218', null::jsonb, '9 - 1 = 8, 9 - 8 = 1, 9 - 7 = 2 → 218.', 'tru_khong_nho', 34::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 635 + 344 ___ 344 + 635', '>', '<', '=', null, '=', null::jsonb, 'Đổi chỗ các số hạng thì tổng không đổi.', 'so_sanh_so', 38::int),
    (1::smallint, 'number', '253 + 316 = ___', null, null, null, null, '569', null::jsonb, '3 + 6 = 9, 5 + 1 = 6, 2 + 3 = 5 → 569.', 'cong_khong_nho', 39::int),
    (1::smallint, 'number', '865 - 751 = ___', null, null, null, null, '114', null::jsonb, '5 - 1 = 4, 6 - 5 = 1, 8 - 7 = 1 → 114.', 'tru_khong_nho', 39::int),
    (1::smallint, 'number', '673 + 25 = ___', null, null, null, null, '698', null::jsonb, '3 + 5 = 8, 7 + 2 = 9, hàng trăm 6 → 698.', 'cong_khong_nho', 39::int),
    (1::smallint, 'number', 'Tứ giác ABCD có AB = 4 cm, BC = 5 cm, CD = 7 cm, DA = 3 cm. Chu vi tứ giác là ___ cm.', null, null, null, null, '19', null::jsonb, 'Chu vi bằng tổng độ dài bốn cạnh: 4 + 5 + 7 + 3 = 19 (cm).', 'chu_vi', 38::int),
    (1::smallint, 'multiple_choice', 'Viết tiếp hai số để được dãy có quy luật: 894; 896; 898; ___', '900; 902', '899; 900', '900; 910', '902; 904', '900; 902', null::jsonb, 'Mỗi số sau hơn số trước 2 đơn vị: 900; 902.', 'day_so', 38::int),
    (1::smallint, 'text', 'Trong phép cộng 222 + 145 = 367, số 367 được gọi là ___', null, null, null, null, 'tổng', null::jsonb, 'Kết quả của phép cộng gọi là tổng.', 'thanh_phan_phep_tinh', 32::int),
    (2::smallint, 'multiple_choice', 'Cho số 322. Nếu đổi chỗ chữ số hàng chục và chữ số hàng đơn vị thì số đó:', 'tăng 9 đơn vị', 'không thay đổi', 'giảm 9 đơn vị', 'tăng 10 đơn vị', 'không thay đổi', null::jsonb, 'Hàng chục và hàng đơn vị đều là 2, đổi chỗ vẫn được 322.', 'cau_tao_so', 36::int),
    (2::smallint, 'multiple_choice', 'Phép cộng nào có hai số hạng đều là số có ba chữ số giống nhau và có tổng là 999?', '444 + 444', '555 + 555', '333 + 666', '333 + 555', '333 + 666', null::jsonb, '333 + 666 = 999.', 'cong_khong_nho', 33::int),
    (2::smallint, 'number', '124 + 41 + 123 = ___', null, null, null, null, '288', null::jsonb, '124 + 41 = 165, 165 + 123 = 288.', 'cong_khong_nho', 32::int),
    (2::smallint, 'number', '123 + 212 + 312 = ___', null, null, null, null, '647', null::jsonb, '123 + 212 = 335, 335 + 312 = 647.', 'cong_khong_nho', 32::int),
    (2::smallint, 'number', '594 - 41 - 123 = ___', null, null, null, null, '430', null::jsonb, '594 - 41 = 553, 553 - 123 = 430.', 'tru_khong_nho', 34::int),
    (2::smallint, 'number', '799 - 347 + 126 = ___', null, null, null, null, '578', null::jsonb, '799 - 347 = 452, 452 + 126 = 578.', 'tinh_gia_tri_bieu_thuc', 34::int),
    (2::smallint, 'number', '652 + 225 - 346 = ___', null, null, null, null, '531', null::jsonb, '652 + 225 = 877, 877 - 346 = 531.', 'tinh_gia_tri_bieu_thuc', 34::int),
    (2::smallint, 'number', 'Đội Một trồng được 810 cây, đội Hai trồng nhiều hơn đội Một 60 cây. Đội Hai trồng được ___ cây.', null, null, null, null, '870', null::jsonb, '810 + 60 = 870 (cây).', 'bai_toan_nhieu_hon', 32::int),
    (2::smallint, 'number', 'Hai giá sách có tất cả 415 quyển, giá thứ nhất có 202 quyển. Giá thứ hai có ___ quyển.', null, null, null, null, '213', null::jsonb, '415 - 202 = 213 (quyển).', 'bai_toan_tong', 35::int),
    (2::smallint, 'number', 'Bình cao 145 cm, Minh cao hơn Bình 14 cm. Minh cao ___ cm.', null, null, null, null, '159', null::jsonb, '145 + 14 = 159 (cm).', 'bai_toan_nhieu_hon', 35::int),
    (2::smallint, 'number', 'Bình cao 145 cm, Nam thấp hơn Bình 4 cm. Nam cao ___ cm.', null, null, null, null, '141', null::jsonb, '145 - 4 = 141 (cm).', 'bai_toan_it_hon', 35::int),
    (2::smallint, 'number', 'Một đàn gà có 547 con, trong đó có 312 con gà mái. Đàn gà có ___ con gà trống.', null, null, null, null, '235', null::jsonb, '547 - 312 = 235 (con).', 'bai_toan_tong', 38::int),
    (2::smallint, 'number', 'Quãng đường Hà Nội - Vinh dài 308 km, quãng đường Vinh - Huế dài 368 km. Quãng đường Hà Nội - Vinh ngắn hơn ___ km.', null, null, null, null, '60', null::jsonb, '368 - 308 = 60 (km).', 'bai_toan_it_hon', 38::int),
    (2::smallint, 'number', 'Số thứ nhất là số tròn trăm lớn nhất có ba chữ số, số thứ hai là số tròn chục lớn nhất có hai chữ số. Tổng hai số là ___', null, null, null, null, '990', null::jsonb, '900 + 90 = 990.', 'cong_khong_nho', 33::int),
    (2::smallint, 'number', 'Tổng của hai số hạng là 869, số hạng thứ nhất là 213. Số hạng thứ hai là ___', null, null, null, null, '656', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 869 - 213 = 656.', 'tim_so_hang', 36::int),
    (2::smallint, 'number', 'Hiệu của số lớn nhất có ba chữ số và số nhỏ nhất có ba chữ số là ___', null, null, null, null, '899', null::jsonb, '999 - 100 = 899.', 'tru_khong_nho', 36::int),
    (2::smallint, 'number', 'Tìm x, biết: 199 < x + 100 < 201. x = ___', null, null, null, null, '100', null::jsonb, 'x + 100 = 200 nên x = 100.', 'tim_thanh_phan', 38::int),
    (2::smallint, 'number', 'Hiệu của số lớn nhất có ba chữ số với số chẵn lớn nhất có một chữ số là ___', null, null, null, null, '991', null::jsonb, '999 - 8 = 991.', 'tru_khong_nho', 38::int),
    (2::smallint, 'number', 'Tú đến trường lúc 7 giờ 30 phút sáng, lúc 4 giờ 30 phút chiều Tú bắt đầu về nhà. Tú đã ở trường ___ giờ.', null, null, null, null, '9', null::jsonb, '4 giờ 30 phút chiều là 16 giờ 30 phút; từ 7 giờ 30 đến 16 giờ 30 là 9 giờ.', 'thoi_gian', 38::int),
    (3::smallint, 'number', 'Tìm a, biết: a + 314 = 650 + 35. a = ___', null, null, null, null, '371', null::jsonb, '650 + 35 = 685; a = 685 - 314 = 371.', 'tim_thanh_phan', 34::int),
    (3::smallint, 'number', 'Tìm a, biết: a - 315 = 689 - 326. a = ___', null, null, null, null, '678', null::jsonb, '689 - 326 = 363; a = 363 + 315 = 678.', 'tim_thanh_phan', 34::int),
    (3::smallint, 'number', 'Tìm a, biết: a x 5 = 895 - 855. a = ___', null, null, null, null, '8', null::jsonb, '895 - 855 = 40; a = 40 : 5 = 8.', 'tim_thanh_phan', 34::int),
    (3::smallint, 'number', 'Đổ thêm 46 l dầu vào can thứ nhất thì can thứ nhất có 178 l và nhiều hơn can thứ hai 32 l. Can thứ hai có ___ l dầu.', null, null, null, null, '146', null::jsonb, '178 - 32 = 146 (l).', 'bai_toan_it_hon', 35::int),
    (3::smallint, 'multiple_choice', 'Đổ thêm 46 l dầu vào can thứ nhất thì can đó có 178 l và nhiều hơn can thứ hai 32 l. Trước khi đổ thêm thì:', 'Can thứ nhất nhiều hơn 14 l', 'Can thứ hai nhiều hơn 32 l', 'Can thứ nhất nhiều hơn 46 l', 'Can thứ hai nhiều hơn 14 l', 'Can thứ hai nhiều hơn 14 l', null::jsonb, 'Lúc đầu can một có 178 - 46 = 132 l, can hai có 146 l; 146 - 132 = 14 l.', 'bai_toan_hai_buoc', 35::int),
    (3::smallint, 'number', 'Cho số 322. Nếu chữ số hàng trăm và chữ số hàng đơn vị đều tăng thêm 2 đơn vị thì số đó tăng ___ đơn vị.', null, null, null, null, '202', null::jsonb, 'Số mới là 524; 524 - 322 = 202.', 'cau_tao_so', 36::int),
    (3::smallint, 'number', 'Tổng của số lớn nhất có ba chữ số khác nhau bé hơn 145 và số bé nhất có ba chữ số khác nhau là ___', null, null, null, null, '245', null::jsonb, 'Số thứ nhất là 143 (144 có hai chữ số 4), số thứ hai là 102; 143 + 102 = 245.', 'cong_khong_nho', 33::int),
    (3::smallint, 'number', 'Tổng của số chẵn nhỏ nhất có ba chữ số khác nhau với số lẻ nhỏ nhất có ba chữ số là ___', null, null, null, null, '203', null::jsonb, '102 + 101 = 203.', 'cong_khong_nho', 37::int),
    (3::smallint, 'number', 'Hiệu của số tròn chục lớn nhất có ba chữ số với số nhỏ nhất có ba chữ số là ___', null, null, null, null, '890', null::jsonb, '990 - 100 = 890.', 'tru_khong_nho', 37::int),
    (3::smallint, 'number', 'Các số có ba chữ số khác nhau có tổng các chữ số bằng 3 là 102; 120; 201; 210. Tổng của số lớn nhất và số nhỏ nhất là ___', null, null, null, null, '312', null::jsonb, '210 + 102 = 312.', 'lap_so', 37::int),
    (3::smallint, 'multiple_choice', 'Phép cộng nào có ba số hạng khác nhau, đều là số có ba chữ số giống nhau và có tổng là 888?', '111 + 333 + 444', '222 + 222 + 444', '111 + 222 + 444', '222 + 333 + 444', '111 + 333 + 444', null::jsonb, '111 + 333 + 444 = 888 và ba số hạng khác nhau.', 'cong_khong_nho', 33::int),
    (3::smallint, 'number', 'Con bò nặng 203 kg và nhẹ hơn con trâu 32 kg. Cả bò và trâu nặng ___ kg.', null, null, null, null, '438', null::jsonb, 'Trâu nặng 203 + 32 = 235 kg; cả hai: 203 + 235 = 438 (kg).', 'bai_toan_hai_buoc', 38::int),
    (3::smallint, 'number', 'Tổng của các số có ba chữ số giống nhau và bé hơn 400 là ___', null, null, null, null, '666', null::jsonb, 'Các số đó là 111; 222; 333; tổng là 666.', 'cong_khong_nho', 38::int),
    (3::smallint, 'number', 'Tìm x, biết: 567 - x = 278 - 35. x = ___', null, null, null, null, '324', null::jsonb, '278 - 35 = 243; x = 567 - 243 = 324.', 'tim_thanh_phan', 39::int),
    (3::smallint, 'number', 'Tìm x, biết: 235 + x - 124 = 354. x = ___', null, null, null, null, '243', null::jsonb, '235 + x = 354 + 124 = 478; x = 478 - 235 = 243.', 'tim_thanh_phan', 39::int),
    (3::smallint, 'number', 'Một trường có 476 học sinh nam, số học sinh nam nhiều hơn số học sinh nữ 63 em. Trường có tất cả ___ học sinh.', null, null, null, null, '889', null::jsonb, 'Nữ: 476 - 63 = 413 em; tất cả: 476 + 413 = 889 em.', 'bai_toan_hai_buoc', 39::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 31 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 32: Luyện tập cộng, trừ trong phạm vi 1000 (52 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 32, 100, 'Archimes: Luyện tập cộng, trừ trong phạm vi 1000', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 32', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Số hạng là 560 và 238. Tổng là ___', null, null, null, null, '798', null::jsonb, '560 + 238 = 798.', 'cong_khong_nho', 41::int),
    (1::smallint, 'number', '112 + 777 = ___', null, null, null, null, '889', null::jsonb, '2 + 7 = 9, 1 + 7 = 8, 1 + 7 = 8 → 889.', 'cong_khong_nho', 41::int),
    (1::smallint, 'number', '552 + 46 = ___', null, null, null, null, '598', null::jsonb, '2 + 6 = 8, 5 + 4 = 9, hàng trăm 5 → 598.', 'cong_khong_nho', 41::int),
    (1::smallint, 'number', '567 - 102 = ___', null, null, null, null, '465', null::jsonb, '7 - 2 = 5, 6 - 0 = 6, 5 - 1 = 4 → 465.', 'tru_khong_nho', 43::int),
    (1::smallint, 'number', '947 - 602 = ___', null, null, null, null, '345', null::jsonb, '7 - 2 = 5, 4 - 0 = 4, 9 - 6 = 3 → 345.', 'tru_khong_nho', 43::int),
    (1::smallint, 'number', '378 - 243 = ___', null, null, null, null, '135', null::jsonb, '8 - 3 = 5, 7 - 4 = 3, 3 - 2 = 1 → 135.', 'tru_khong_nho', 43::int),
    (1::smallint, 'number', '1 cm 5 mm = ___ mm', null, null, null, null, '15', null::jsonb, '1 cm = 10 mm, 10 mm + 5 mm = 15 mm.', 'doi_don_vi_do_dai', 47::int),
    (1::smallint, 'number', '543 + 32 = ___', null, null, null, null, '575', null::jsonb, '3 + 2 = 5, 4 + 3 = 7, hàng trăm 5 → 575.', 'cong_khong_nho', 48::int),
    (1::smallint, 'number', '869 - 543 = ___', null, null, null, null, '326', null::jsonb, '9 - 3 = 6, 6 - 4 = 2, 8 - 5 = 3 → 326.', 'tru_khong_nho', 48::int),
    (1::smallint, 'number', '734 - 32 = ___', null, null, null, null, '702', null::jsonb, '4 - 2 = 2, 3 - 3 = 0, hàng trăm 7 → 702.', 'tru_khong_nho', 48::int),
    (1::smallint, 'number', '4 cm = ___ mm', null, null, null, null, '40', null::jsonb, '1 cm = 10 mm nên 4 cm = 40 mm.', 'doi_don_vi_do_dai', 48::int),
    (1::smallint, 'number', '9 m 22 cm = ___ cm', null, null, null, null, '922', null::jsonb, '9 m = 900 cm, 900 + 22 = 922 (cm).', 'doi_don_vi_do_dai', 48::int),
    (1::smallint, 'number', '300 cm = ___ dm', null, null, null, null, '30', null::jsonb, '10 cm = 1 dm nên 300 cm = 30 dm.', 'doi_don_vi_do_dai', 48::int),
    (1::smallint, 'text', 'Trong phép trừ 869 - 543 = 326, số 543 được gọi là ___', null, null, null, null, 'số trừ', null::jsonb, 'Trong phép trừ: số bị trừ - số trừ = hiệu; 543 là số trừ.', 'thanh_phan_phep_tinh', 48::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả bằng 345?', '777 - 432', '567 - 432', '978 - 513', '567 - 102', '777 - 432', null::jsonb, '777 - 432 = 345; các phép còn lại bằng 135, 465, 465.', 'tru_khong_nho', 43::int),
    (1::smallint, 'multiple_choice', 'Từ 300 đến 600, các số có ba chữ số giống nhau là:', '333; 444; 555; 666', '333; 444; 555', '300; 400; 500; 600', '444; 555', '333; 444; 555', null::jsonb, 'Các số có ba chữ số giống nhau trong khoảng đó là 333, 444, 555 (666 > 600).', 'cau_tao_so', 47::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 322 m + 466 m ___ 1 km', '>', '<', '=', null, '<', null::jsonb, '322 + 466 = 788 m, 1 km = 1000 m, mà 788 < 1000.', 'doi_don_vi_do_dai', 47::int),
    (2::smallint, 'number', 'Tìm số hạng còn thiếu: ___ + 344 = 979', null, null, null, null, '635', null::jsonb, 'Lấy tổng trừ số hạng đã biết: 979 - 344 = 635.', 'tim_so_hang', 41::int),
    (2::smallint, 'number', 'Tìm số hạng còn thiếu: 86 + ___ = 789', null, null, null, null, '703', null::jsonb, '789 - 86 = 703.', 'tim_so_hang', 41::int),
    (2::smallint, 'number', '442 + 321 - 132 = ___', null, null, null, null, '631', null::jsonb, '442 + 321 = 763, 763 - 132 = 631.', 'tinh_gia_tri_bieu_thuc', 41::int),
    (2::smallint, 'number', '985 - 234 + 111 = ___', null, null, null, null, '862', null::jsonb, '985 - 234 = 751, 751 + 111 = 862.', 'tinh_gia_tri_bieu_thuc', 41::int),
    (2::smallint, 'number', '756 - 56 + 189 = ___', null, null, null, null, '889', null::jsonb, '756 - 56 = 700, 700 + 189 = 889.', 'tinh_gia_tri_bieu_thuc', 41::int),
    (2::smallint, 'number', 'Tìm x, biết: x + 241 = 245 + 101. x = ___', null, null, null, null, '105', null::jsonb, '245 + 101 = 346; x = 346 - 241 = 105.', 'tim_thanh_phan', 41::int),
    (2::smallint, 'number', 'Tìm y, biết: 80 - y = 4 x 9. y = ___', null, null, null, null, '44', null::jsonb, '4 x 9 = 36; y = 80 - 36 = 44.', 'tim_thanh_phan', 42::int),
    (2::smallint, 'number', 'Kiện hàng thứ nhất nặng 230 kg, kiện thứ hai nặng hơn kiện thứ nhất 36 kg. Kiện thứ hai nặng ___ kg.', null, null, null, null, '266', null::jsonb, '230 + 36 = 266 (kg).', 'bai_toan_nhieu_hon', 42::int),
    (2::smallint, 'number', 'Quãng đường từ A đến C dài 25 km, đi từ A đến C phải qua B. Quãng đường BC dài 9 km. Quãng đường AB dài ___ km.', null, null, null, null, '16', null::jsonb, 'AB = AC - BC = 25 - 9 = 16 (km).', 'bai_toan_tong', 43::int),
    (2::smallint, 'number', 'Tổng của số lớn nhất và số nhỏ nhất trong bốn số 427; 324; 435; 321 là ___', null, null, null, null, '756', null::jsonb, 'Số lớn nhất 435, số nhỏ nhất 321; 435 + 321 = 756.', 'so_sanh_so', 47::int),
    (2::smallint, 'number', 'Đường gấp khúc ABCDE có AB = 10 cm, BC = 35 cm, CD = 11 cm, DE = 44 cm. Độ dài đường gấp khúc là ___ cm.', null, null, null, null, '100', null::jsonb, '10 + 35 + 11 + 44 = 100 (cm).', 'duong_gap_khuc', 47::int),
    (2::smallint, 'number', '12 cm : 2 + 38 cm = ___ cm', null, null, null, null, '44', null::jsonb, '12 : 2 = 6, 6 + 38 = 44 (cm).', 'tinh_so_do_do_dai', 48::int),
    (2::smallint, 'number', '5 dm 2 mm = ___ mm', null, null, null, null, '502', null::jsonb, '5 dm = 500 mm, 500 + 2 = 502 (mm).', 'doi_don_vi_do_dai', 48::int),
    (2::smallint, 'number', '436 cm = ___ dm 6 cm', null, null, null, null, '43', null::jsonb, '436 cm = 430 cm + 6 cm = 43 dm 6 cm.', 'doi_don_vi_do_dai', 48::int),
    (2::smallint, 'number', 'Thùng thứ nhất đựng 156 l dầu, thùng thứ hai đựng 140 l dầu. Cả hai thùng đựng ___ l dầu.', null, null, null, null, '296', null::jsonb, '156 + 140 = 296 (l).', 'bai_toan_tong', 48::int),
    (2::smallint, 'multiple_choice', 'Các số có ba chữ số khác nhau lập từ 1; 2; 4, xếp theo thứ tự từ lớn đến bé là:', '421; 412; 214; 241; 142; 124', '124; 142; 214; 241; 412; 421', '421; 412; 241; 214; 142; 124', '421; 412; 241; 214; 124; 142', '421; 412; 241; 214; 142; 124', null::jsonb, 'So sánh hàng trăm trước, rồi đến hàng chục: 421 > 412 > 241 > 214 > 142 > 124.', 'sap_xep_so', 46::int),
    (3::smallint, 'number', 'Tìm x, biết: x + 213 + 222 = 785. x = ___', null, null, null, null, '350', null::jsonb, 'x = 785 - 213 - 222 = 350.', 'tim_thanh_phan', 41::int),
    (3::smallint, 'number', 'Tìm x, biết: x - 32 + 410 = 721. x = ___', null, null, null, null, '343', null::jsonb, 'x - 32 = 721 - 410 = 311; x = 311 + 32 = 343.', 'tim_thanh_phan', 41::int),
    (3::smallint, 'number', 'Tìm y, biết: y + 124 = 5 x 9 + 253. y = ___', null, null, null, null, '174', null::jsonb, '5 x 9 + 253 = 298; y = 298 - 124 = 174.', 'tim_thanh_phan', 42::int),
    (3::smallint, 'number', 'Tìm y, biết: y : 2 + 264 = 268. y = ___', null, null, null, null, '8', null::jsonb, 'y : 2 = 268 - 264 = 4; y = 4 x 2 = 8.', 'tim_thanh_phan', 42::int),
    (3::smallint, 'number', 'Kiện hàng thứ nhất nặng 230 kg, kiện thứ hai nặng hơn kiện thứ nhất 36 kg. Cả hai kiện nặng ___ kg.', null, null, null, null, '496', null::jsonb, 'Kiện thứ hai 266 kg; cả hai: 230 + 266 = 496 (kg).', 'bai_toan_hai_buoc', 42::int),
    (3::smallint, 'number', 'Khu An Nam có 587 người và nhiều hơn khu Tân Tiến 185 người. Cả hai khu có ___ người.', null, null, null, null, '989', null::jsonb, 'Tân Tiến có 587 - 185 = 402 người; cả hai: 587 + 402 = 989 người.', 'bai_toan_hai_buoc', 43::int),
    (3::smallint, 'number', 'Bể thứ nhất chứa 321 l nước và chứa ít hơn bể thứ hai 12 l. Cả hai bể chứa ___ l nước.', null, null, null, null, '654', null::jsonb, 'Bể thứ hai chứa 321 + 12 = 333 l; cả hai: 321 + 333 = 654 (l).', 'bai_toan_hai_buoc', 44::int),
    (3::smallint, 'number', 'Hiệu của số chẵn lớn nhất có ba chữ số khác nhau với số lẻ nhỏ nhất có ba chữ số khác nhau là ___', null, null, null, null, '883', null::jsonb, '986 - 103 = 883.', 'tru_khong_nho', 44::int),
    (3::smallint, 'multiple_choice', 'Cho số 488. Nếu chữ số hàng trăm bớt 2, chữ số hàng chục bớt 6, hàng đơn vị giữ nguyên thì số đó:', 'giảm 8 đơn vị', 'giảm 26 đơn vị', 'tăng 260 đơn vị', 'giảm 260 đơn vị', 'giảm 260 đơn vị', null::jsonb, 'Số mới là 228; 488 - 228 = 260.', 'cau_tao_so', 45::int),
    (3::smallint, 'number', 'Hai số có cùng chữ số hàng trăm và hàng đơn vị, chữ số hàng chục kém nhau 4. Hai số đó hơn kém nhau ___ đơn vị.', null, null, null, null, '40', null::jsonb, '4 chục = 40 đơn vị.', 'cau_tao_so', 45::int),
    (3::smallint, 'number', 'Có ___ số có ba chữ số mà chữ số hàng trăm hơn chữ số hàng chục 2 đơn vị, chữ số hàng chục hơn chữ số hàng đơn vị 2 đơn vị.', null, null, null, null, '6', null::jsonb, 'Đó là 420; 531; 642; 753; 864; 975.', 'lap_so', 45::int),
    (3::smallint, 'number', 'Một số có ba chữ số, nếu chữ số hàng trăm tăng 1, chữ số hàng chục giảm 4, hàng đơn vị giữ nguyên thì được 555. Số đó là ___', null, null, null, null, '495', null::jsonb, 'Số ban đầu: hàng trăm 5 - 1 = 4, hàng chục 5 + 4 = 9, hàng đơn vị 5 → 495.', 'cau_tao_so', 45::int),
    (3::smallint, 'multiple_choice', 'Từ bốn chữ số 0; 3; 6; 9, số lớn nhất có ba chữ số khác nhau và có chữ số hàng đơn vị là 3 là:', '963', '993', '960', '903', '963', null::jsonb, 'Hàng đơn vị 3, hàng trăm lớn nhất 9, hàng chục lớn nhất còn lại 6: 963.', 'lap_so', 46::int),
    (3::smallint, 'number', 'Hiệu của số lớn nhất có ba chữ số khác nhau với số bé nhất có ba chữ số giống nhau là ___', null, null, null, null, '876', null::jsonb, '987 - 111 = 876.', 'tru_khong_nho', 46::int),
    (3::smallint, 'number', 'Số lớn là số lớn nhất có ba chữ số khác nhau có tổng các chữ số là 22; số bé là số nhỏ nhất có ba chữ số khác nhau có tổng các chữ số là 4. Hiệu hai số là ___', null, null, null, null, '882', null::jsonb, 'Số lớn là 985, số bé là 103; 985 - 103 = 882.', 'tru_khong_nho', 46::int),
    (3::smallint, 'number', 'Hiệu của số liền trước số 500 và số liền sau số 300 là ___', null, null, null, null, '198', null::jsonb, 'Số liền trước 500 là 499, số liền sau 300 là 301; 499 - 301 = 198.', 'tru_khong_nho', 47::int),
    (3::smallint, 'number', 'Tìm số có ba chữ số, biết chữ số hàng đơn vị gấp đôi chữ số hàng chục, chữ số hàng chục gấp đôi chữ số hàng trăm, và chữ số hàng đơn vị là số liền trước số 5. Số đó là ___', null, null, null, null, '124', null::jsonb, 'Hàng đơn vị 4, hàng chục 4 : 2 = 2, hàng trăm 2 : 2 = 1 → 124.', 'cau_tao_so', 47::int),
    (3::smallint, 'number', 'Thùng thứ nhất có 156 l dầu, thùng thứ hai có 140 l dầu. Phải chuyển ___ l từ thùng thứ nhất sang thùng thứ hai để hai thùng bằng nhau.', null, null, null, null, '8', null::jsonb, 'Hai thùng chênh 16 l, chuyển một nửa: 16 : 2 = 8 (l).', 'suy_luan', 48::int),
    (3::smallint, 'number', 'Tổng của số có ba chữ số giống nhau có chữ số hàng trăm là 6 và số nhỏ nhất có ba chữ số khác nhau là ___', null, null, null, null, '768', null::jsonb, '666 + 102 = 768.', 'cong_khong_nho', 47::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 32 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 33: Ôn tập về các số, các phép tính trong phạm vi 1000 (55 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 33, 100, 'Archimes: Ôn tập về các số, các phép tính trong phạm vi 1000', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 33', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '426 + 362 = ___', null, null, null, null, '788', null::jsonb, '6 + 2 = 8, 2 + 6 = 8, 4 + 3 = 7 → 788.', 'cong_khong_nho', 50::int),
    (1::smallint, 'number', '967 - 504 = ___', null, null, null, null, '463', null::jsonb, '7 - 4 = 3, 6 - 0 = 6, 9 - 5 = 4 → 463.', 'tru_khong_nho', 50::int),
    (1::smallint, 'number', '768 - 316 = ___', null, null, null, null, '452', null::jsonb, '8 - 6 = 2, 6 - 1 = 5, 7 - 3 = 4 → 452.', 'tru_khong_nho', 50::int),
    (1::smallint, 'number', '656 - 45 = ___', null, null, null, null, '611', null::jsonb, '6 - 5 = 1, 5 - 4 = 1, hàng trăm 6 → 611.', 'tru_khong_nho', 50::int),
    (1::smallint, 'number', '800 + 87 = ___', null, null, null, null, '887', null::jsonb, '8 trăm cộng 87 được 887.', 'cong_khong_nho', 50::int),
    (1::smallint, 'number', 'Tính: 27 + 53 - 39 = ___', null, null, null, null, '41', null::jsonb, '27 + 53 = 80, 80 - 39 = 41.', 'tinh_gia_tri_bieu_thuc', 56::int),
    (1::smallint, 'number', '315 + 252 = ___', null, null, null, null, '567', null::jsonb, '5 + 2 = 7, 1 + 5 = 6, 3 + 2 = 5 → 567.', 'cong_khong_nho', 57::int),
    (1::smallint, 'number', '346 - 42 = ___', null, null, null, null, '304', null::jsonb, '6 - 2 = 4, 4 - 4 = 0, hàng trăm 3 → 304.', 'tru_khong_nho', 57::int),
    (1::smallint, 'number', '2 x 10 + 835 = ___', null, null, null, null, '855', null::jsonb, '2 x 10 = 20, 20 + 835 = 855.', 'tinh_gia_tri_bieu_thuc', 52::int),
    (1::smallint, 'number', '45 : 5 + 900 = ___', null, null, null, null, '909', null::jsonb, '45 : 5 = 9, 9 + 900 = 909.', 'tinh_gia_tri_bieu_thuc', 52::int),
    (1::smallint, 'number', 'Tìm a, biết: a - 36 = 64. a = ___', null, null, null, null, '100', null::jsonb, 'Số bị trừ = hiệu + số trừ: 64 + 36 = 100.', 'tim_thanh_phan', 52::int),
    (1::smallint, 'number', 'Tìm a, biết: 99 + a = 999. a = ___', null, null, null, null, '900', null::jsonb, 'a = 999 - 99 = 900.', 'tim_so_hang', 52::int),
    (1::smallint, 'text', 'Trong phép trừ a - 36 = 64, a được gọi là ___', null, null, null, null, 'số bị trừ', null::jsonb, 'Trong phép trừ: số bị trừ - số trừ = hiệu; a là số bị trừ.', 'thanh_phan_phep_tinh', 52::int),
    (1::smallint, 'multiple_choice', 'Phép tính nào có kết quả là 989?', '287 + 702', '426 + 362', '800 + 87', '967 - 504', '287 + 702', null::jsonb, '287 + 702 = 989; các phép còn lại bằng 788, 887, 463.', 'cong_khong_nho', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 2 x 10 + 835 ___ 45 : 5 + 900', '>', '<', '=', null, '<', null::jsonb, 'Bên trái bằng 855, bên phải bằng 909, mà 855 < 909.', 'so_sanh_so', 52::int),
    (2::smallint, 'number', 'Tìm a, biết: a : 6 = 2 x 2. a = ___', null, null, null, null, '24', null::jsonb, '2 x 2 = 4; a = 4 x 6 = 24.', 'tim_thanh_phan', 52::int),
    (2::smallint, 'number', '204 + 182 + 313 = ___', null, null, null, null, '699', null::jsonb, '204 + 182 = 386, 386 + 313 = 699.', 'cong_khong_nho', 50::int),
    (2::smallint, 'number', '37 + 19 + 25 = ___', null, null, null, null, '81', null::jsonb, '37 + 19 = 56, 56 + 25 = 81.', 'cong_co_nho', 50::int),
    (2::smallint, 'number', '359 - 36 : 4 = ___', null, null, null, null, '350', null::jsonb, 'Chia trước: 36 : 4 = 9, rồi 359 - 9 = 350.', 'tinh_gia_tri_bieu_thuc', 52::int),
    (2::smallint, 'number', '435 - 3 x 7 = ___', null, null, null, null, '414', null::jsonb, '3 x 7 = 21, 435 - 21 = 414.', 'tinh_gia_tri_bieu_thuc', 52::int),
    (2::smallint, 'number', '675 - 315 + 102 = ___', null, null, null, null, '462', null::jsonb, '675 - 315 = 360, 360 + 102 = 462.', 'tinh_gia_tri_bieu_thuc', 52::int),
    (2::smallint, 'number', 'Tìm a, biết: 90 - a = 38. a = ___', null, null, null, null, '52', null::jsonb, 'Số trừ = số bị trừ - hiệu: 90 - 38 = 52.', 'tim_thanh_phan', 52::int),
    (2::smallint, 'number', 'Tìm a, biết: 5 x a = 74 - 39. a = ___', null, null, null, null, '7', null::jsonb, '74 - 39 = 35; a = 35 : 5 = 7.', 'tim_thanh_phan', 52::int),
    (2::smallint, 'number', 'Tìm a, biết: a : 9 = 31 - 26. a = ___', null, null, null, null, '45', null::jsonb, '31 - 26 = 5; a = 5 x 9 = 45.', 'tim_thanh_phan', 52::int),
    (2::smallint, 'number', 'Tìm y, biết: y : 3 = 16 : 4. y = ___', null, null, null, null, '12', null::jsonb, '16 : 4 = 4; y = 4 x 3 = 12.', 'tim_thanh_phan', 52::int),
    (2::smallint, 'number', 'Ngăn thứ nhất có 125 quyển sách và ít hơn ngăn thứ hai 20 quyển. Ngăn thứ hai có ___ quyển.', null, null, null, null, '145', null::jsonb, 'Ngăn thứ hai nhiều hơn: 125 + 20 = 145 (quyển).', 'bai_toan_nhieu_hon', 51::int),
    (2::smallint, 'number', 'Mẹ cao 162 cm và cao hơn con 31 cm. Con cao ___ cm.', null, null, null, null, '131', null::jsonb, '162 - 31 = 131 (cm).', 'bai_toan_it_hon', 56::int),
    (2::smallint, 'number', '4 giờ x 4 - 8 giờ = ___ giờ', null, null, null, null, '8', null::jsonb, '4 x 4 = 16, 16 - 8 = 8 (giờ).', 'tinh_so_do_dai_luong', 56::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu thích hợp: 5 dm x 8 + 2 dm ___ 40 dm + 4 cm x 5', '>', '<', '=', null, '=', null::jsonb, 'Bên trái: 40 + 2 = 42 dm. Bên phải: 4 cm x 5 = 20 cm = 2 dm, 40 + 2 = 42 dm.', 'tinh_so_do_do_dai', 56::int),
    (2::smallint, 'number', 'Xếp 24 cái ghế thành các hàng, mỗi hàng 4 cái. Xếp được ___ hàng.', null, null, null, null, '6', null::jsonb, '24 : 4 = 6 (hàng).', 'bai_toan_chia', 56::int),
    (2::smallint, 'number', 'Hình tứ giác có các cạnh dài 15 dm, 8 dm, 21 dm, 12 dm. Chu vi hình tứ giác là ___ dm.', null, null, null, null, '56', null::jsonb, '15 + 8 + 21 + 12 = 56 (dm).', 'chu_vi', 56::int),
    (2::smallint, 'number', 'Đường gấp khúc ABCD có AB = 25 cm, BC = 36 cm, CD = 39 cm. Đường gấp khúc dài ___ dm.', null, null, null, null, '10', null::jsonb, '25 + 36 + 39 = 100 cm = 10 dm.', 'duong_gap_khuc', 56::int),
    (2::smallint, 'number', 'Mẹ chia đều bánh vào 6 hộp, mỗi hộp 5 chiếc. Nếu chia đều số bánh đó vào 3 hộp thì mỗi hộp có ___ chiếc.', null, null, null, null, '10', null::jsonb, 'Có 6 x 5 = 30 chiếc; 30 : 3 = 10 chiếc.', 'bai_toan_hai_buoc', 53::int),
    (2::smallint, 'number', 'Minh có 29 viên bi, cho Bình 17 viên. Minh chia đều số bi còn lại vào 4 túi, mỗi túi có ___ viên.', null, null, null, null, '3', null::jsonb, 'Còn 29 - 17 = 12 viên; 12 : 4 = 3 viên.', 'bai_toan_hai_buoc', 53::int),
    (2::smallint, 'number', 'Bác Linh cưa khúc gỗ dài 32 dm thành 4 đoạn bằng nhau. Mỗi đoạn dài ___ dm.', null, null, null, null, '8', null::jsonb, '32 : 4 = 8 (dm).', 'bai_toan_chia', 57::int),
    (3::smallint, 'number', 'Bao ngô nặng 30 kg, bao gạo nặng hơn bao ngô 7 kg, bao lúa mì nhẹ hơn bao ngô 6 kg. Cả ba bao nặng ___ kg.', null, null, null, null, '91', null::jsonb, 'Gạo 37 kg, lúa mì 24 kg; cả ba: 30 + 37 + 24 = 91 (kg).', 'bai_toan_hai_buoc', 51::int),
    (3::smallint, 'number', 'Kiên, Mạnh, Thành có 38 viên bi. Kiên và Mạnh có 29 viên, Kiên và Thành có 28 viên. Thành có ___ viên bi.', null, null, null, null, '9', null::jsonb, 'Thành = cả ba - (Kiên + Mạnh) = 38 - 29 = 9 viên.', 'suy_luan', 51::int),
    (3::smallint, 'number', 'Kiên, Mạnh, Thành có 38 viên bi. Kiên và Mạnh có 29 viên, Kiên và Thành có 28 viên. Kiên có ___ viên bi.', null, null, null, null, '19', null::jsonb, 'Thành có 9 viên nên Kiên có 28 - 9 = 19 viên.', 'suy_luan', 51::int),
    (3::smallint, 'number', 'Tìm y, biết: 18 - y : 2 = 15. y = ___', null, null, null, null, '6', null::jsonb, 'y : 2 = 18 - 15 = 3; y = 3 x 2 = 6.', 'tim_thanh_phan', 52::int),
    (3::smallint, 'number', 'Tìm y, biết: 4 x y - 15 = 25. y = ___', null, null, null, null, '10', null::jsonb, '4 x y = 40; y = 40 : 4 = 10.', 'tim_thanh_phan', 52::int),
    (3::smallint, 'number', 'Tìm y, biết: 29 + y : 4 = 35. y = ___', null, null, null, null, '24', null::jsonb, 'y : 4 = 35 - 29 = 6; y = 6 x 4 = 24.', 'tim_thanh_phan', 52::int),
    (3::smallint, 'number', 'Bà cắm hoa vào 6 lọ, mỗi lọ 5 bông thì thừa 2 bông. Nếu cắm đều vào 4 lọ thì mỗi lọ có ___ bông.', null, null, null, null, '8', null::jsonb, 'Số hoa: 6 x 5 + 2 = 32 bông; 32 : 4 = 8 bông.', 'bai_toan_hai_buoc', 53::int),
    (3::smallint, 'number', 'Tìm a, biết: a x 2 + a + a + a = 45. a = ___', null, null, null, null, '9', null::jsonb, 'a x 2 + a + a + a = a x 5 = 45, nên a = 9.', 'tim_thanh_phan', 54::int),
    (3::smallint, 'number', 'Tìm a, biết: a + a + 2 + a + 4 + a + 6 = 52. a = ___', null, null, null, null, '10', null::jsonb, 'a x 4 + 12 = 52, a x 4 = 40, a = 10.', 'tim_thanh_phan', 54::int),
    (3::smallint, 'number', 'Tìm a, biết: a + 10 - 9 + 8 - 7 + 6 - 5 + 4 - 3 + 2 - 1 = 15. a = ___', null, null, null, null, '10', null::jsonb, '10 - 9 + 8 - 7 + 6 - 5 + 4 - 3 + 2 - 1 = 5, nên a + 5 = 15, a = 10.', 'tim_thanh_phan', 54::int),
    (3::smallint, 'number', 'Tìm a, biết: a x 2 x a = 8. a = ___', null, null, null, null, '2', null::jsonb, 'a x a = 8 : 2 = 4, mà 2 x 2 = 4 nên a = 2.', 'tim_thanh_phan', 54::int),
    (3::smallint, 'number', 'Hiệu của số chẵn lớn nhất có ba chữ số với số lẻ nhỏ nhất có hai chữ số khác nhau là ___', null, null, null, null, '985', null::jsonb, 'Số chẵn lớn nhất có ba chữ số là 998; số lẻ nhỏ nhất có hai chữ số khác nhau là 13; 998 - 13 = 985.', 'tru_khong_nho', 54::int),
    (3::smallint, 'multiple_choice', 'Tổng hai số hạng là 27, số hạng thứ nhất là số có hai chữ số và có chữ số hàng đơn vị là 9. Hai số đó là:', '9 và 18', '29 và 2', '17 và 10', '19 và 8', '19 và 8', null::jsonb, 'Số hạng thứ nhất chỉ có thể là 19 (29 > 27), số hạng thứ hai là 27 - 19 = 8.', 'suy_luan', 54::int),
    (3::smallint, 'number', 'Số hạng thứ nhất là 28, số hạng thứ hai lớn hơn số hạng thứ nhất nhưng bé hơn 30. Tổng hai số là ___', null, null, null, null, '57', null::jsonb, 'Số hạng thứ hai là 29; tổng 28 + 29 = 57.', 'suy_luan', 55::int),
    (3::smallint, 'number', 'Nếu thêm 3 kg gạo vào bao thì vừa đủ chia đều vào 8 túi, mỗi túi 5 kg. Lúc đầu bao có ___ kg gạo.', null, null, null, null, '37', null::jsonb, 'Sau khi thêm có 8 x 5 = 40 kg; lúc đầu 40 - 3 = 37 (kg).', 'tinh_nguoc', 55::int),
    (3::smallint, 'number', 'Có 6 gói bánh như nhau. Lấy ở mỗi gói ra 4 cái thì số bánh còn lại bằng số bánh của 2 gói nguyên. Mỗi gói có ___ cái bánh.', null, null, null, null, '6', null::jsonb, 'Lấy ra 6 x 4 = 24 cái, bằng số bánh của 6 - 2 = 4 gói; mỗi gói 24 : 4 = 6 cái.', 'suy_luan', 55::int),
    (3::smallint, 'number', 'Tìm a, biết: a x 5 - 18 = 27. a = ___', null, null, null, null, '9', null::jsonb, 'a x 5 = 27 + 18 = 45; a = 9.', 'tim_thanh_phan', 56::int),
    (3::smallint, 'number', 'Hai số có tổng bằng 72. Số thứ nhất có chữ số hàng đơn vị là 5, số thứ hai có chữ số hàng chục là 2. Số thứ nhất là ___', null, null, null, null, '45', null::jsonb, 'Số thứ hai là 2_ và 5 + _ phải tận cùng là 2 nên số thứ hai là 27; số thứ nhất 72 - 27 = 45.', 'suy_luan', 56::int),
    (3::smallint, 'number', 'Lập được ___ số chẵn có hai chữ số khác nhau từ năm chữ số 0; 1; 2; 6; 7.', null, null, null, null, '10', null::jsonb, 'Tận cùng 0: 4 số; tận cùng 2: 3 số (12, 62, 72); tận cùng 6: 3 số (16, 26, 76).', 'lap_so', 56::int),
    (3::smallint, 'number', 'Tìm một số, biết số đó chia cho 3 rồi cộng với 67 thì được 72. Số đó là ___', null, null, null, null, '15', null::jsonb, 'Tính ngược: 72 - 67 = 5, 5 x 3 = 15.', 'tinh_nguoc', 79::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 33 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 34: Ôn tập về đại lượng (52 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 34, 100, 'Archimes: Ôn tập về đại lượng', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 34', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', '4 kg x 9 + 55 kg = ___ kg', null, null, null, null, '91', null::jsonb, '4 x 9 = 36, 36 + 55 = 91 (kg).', 'tinh_so_do_dai_luong', 59::int),
    (1::smallint, 'number', '4 cm x 7 + 231 cm = ___ cm', null, null, null, null, '259', null::jsonb, '4 x 7 = 28, 28 + 231 = 259 (cm).', 'tinh_so_do_dai_luong', 59::int),
    (1::smallint, 'number', '654 m - 5 m x 10 = ___ m', null, null, null, null, '604', null::jsonb, '5 x 10 = 50, 654 - 50 = 604 (m).', 'tinh_so_do_dai_luong', 59::int),
    (1::smallint, 'number', '35 l : 5 + 33 l = ___ l', null, null, null, null, '40', null::jsonb, '35 : 5 = 7, 7 + 33 = 40 (l).', 'tinh_so_do_dai_luong', 59::int),
    (1::smallint, 'number', '27 kg + 24 kg : 2 = ___ kg', null, null, null, null, '39', null::jsonb, 'Chia trước: 24 : 2 = 12, rồi 27 + 12 = 39 (kg).', 'tinh_so_do_dai_luong', 59::int),
    (1::smallint, 'number', '100 cm - 53 cm + 241 cm = ___ cm', null, null, null, null, '288', null::jsonb, '100 - 53 = 47, 47 + 241 = 288 (cm).', 'tinh_so_do_dai_luong', 66::int),
    (1::smallint, 'number', '36 mm : 9 + 145 mm = ___ mm', null, null, null, null, '149', null::jsonb, '36 : 9 = 4, 4 + 145 = 149 (mm).', 'tinh_so_do_dai_luong', 66::int),
    (1::smallint, 'number', '4 m x 8 + 38 m = ___ m', null, null, null, null, '70', null::jsonb, '4 x 8 = 32, 32 + 38 = 70 (m).', 'tinh_so_do_dai_luong', 66::int),
    (1::smallint, 'multiple_choice', 'Số bé nhất trong các số 904; 494; 409; 449 là:', '409', '904', '494', '449', '409', null::jsonb, 'Hàng trăm 4 bé hơn 9; so sánh 494, 409, 449 thì 409 có hàng chục 0 bé nhất.', 'so_sanh_so', 65::int),
    (1::smallint, 'number', 'Tích của hai số là 45, thừa số thứ nhất là 5. Thừa số thứ hai là ___', null, null, null, null, '9', null::jsonb, '45 : 5 = 9.', 'tim_thua_so', 65::int),
    (1::smallint, 'number', '176 + 702 = ___', null, null, null, null, '878', null::jsonb, '6 + 2 = 8, 7 + 0 = 7, 1 + 7 = 8 → 878.', 'cong_khong_nho', 66::int),
    (1::smallint, 'number', '756 - 556 = ___', null, null, null, null, '200', null::jsonb, '6 - 6 = 0, 5 - 5 = 0, 7 - 5 = 2 → 200.', 'tru_khong_nho', 66::int),
    (1::smallint, 'multiple_choice', 'Đơn vị nào dùng để đo khối lượng (cân nặng)?', 'lít', 'ki-lô-gam', 'mét', 'giờ', 'ki-lô-gam', null::jsonb, 'Ki-lô-gam (kg) là đơn vị đo khối lượng.', 'don_vi_do', 58::int),
    (1::smallint, 'number', 'Lớp học có 30 học sinh, xếp mỗi hàng 3 bạn thì được ___ hàng.', null, null, null, null, '10', null::jsonb, '30 : 3 = 10 (hàng).', 'bai_toan_chia', 83::int),
    (1::smallint, 'text', 'Lít viết tắt là ___', null, null, null, null, 'l', null::jsonb, 'Lít là đơn vị đo dung tích, viết tắt là l.', 'don_vi_do', 58::int),
    (1::smallint, 'text', 'Đơn vị tiền Việt Nam là ___', null, null, null, null, 'đồng', '["đ"]'::jsonb, 'Tiền Việt Nam tính bằng đồng, viết tắt là đ.', 'don_vi_do', 58::int),
    (2::smallint, 'number', 'Tìm y, biết: y : 4 = 3 x 1. y = ___', null, null, null, null, '12', null::jsonb, '3 x 1 = 3; y = 3 x 4 = 12.', 'tim_thanh_phan', 65::int),
    (2::smallint, 'number', '21 giờ - 20 giờ : 4 = ___ giờ', null, null, null, null, '16', null::jsonb, '20 : 4 = 5, 21 - 5 = 16 (giờ).', 'tinh_so_do_dai_luong', 59::int),
    (2::smallint, 'number', '2 m : 4 + 29 dm = ___ dm', null, null, null, null, '34', null::jsonb, '2 m = 20 dm; 20 : 4 = 5, 5 + 29 = 34 (dm).', 'tinh_so_do_dai_luong', 59::int),
    (2::smallint, 'number', 'Ngày thứ hai bác Sơn bán được 135 kg dưa hấu, ngày thứ ba bán ít hơn ngày thứ hai 25 kg. Ngày thứ ba bán được ___ kg.', null, null, null, null, '110', null::jsonb, '135 - 25 = 110 (kg).', 'bai_toan_it_hon', 59::int),
    (2::smallint, 'number', 'Bao muối thứ nhất nặng 12 kg, bao thứ hai nặng 18 kg. Chia đều muối của cả hai bao vào 5 túi, mỗi túi có ___ kg.', null, null, null, null, '6', null::jsonb, '12 + 18 = 30 kg; 30 : 5 = 6 (kg).', 'bai_toan_hai_buoc', 61::int),
    (2::smallint, 'number', 'An có 12 chiếc kẹo, mẹ cho thêm 4 chiếc. An ăn hết số kẹo đó trong 4 ngày, mỗi ngày như nhau. Mỗi ngày An ăn ___ chiếc.', null, null, null, null, '4', null::jsonb, '12 + 4 = 16 chiếc; 16 : 4 = 4 chiếc.', 'bai_toan_hai_buoc', 61::int),
    (2::smallint, 'multiple_choice', 'Trạm bơm bắt đầu bơm nước lúc 9 giờ sáng và bơm trong 6 giờ. Trạm bơm xong lúc:', '3 giờ sáng', '2 giờ chiều', '3 giờ chiều', '4 giờ chiều', '3 giờ chiều', null::jsonb, '9 + 6 = 15 giờ, tức là 3 giờ chiều.', 'thoi_gian', 65::int),
    (2::smallint, 'number', 'Lớp 2A xếp 4 hàng: ba hàng đầu mỗi hàng 8 bạn, hàng thứ tư 9 bạn. Lớp 2A có ___ học sinh.', null, null, null, null, '33', null::jsonb, '3 x 8 = 24; 24 + 9 = 33 (học sinh).', 'bai_toan_hai_buoc', 65::int),
    (2::smallint, 'number', 'Quỳnh có 16 cái kẹo, Tuyết có 8 cái. Quỳnh phải cho Tuyết ___ cái kẹo để hai bạn có số kẹo bằng nhau.', null, null, null, null, '4', null::jsonb, 'Hai bạn chênh 8 cái, Quỳnh cho một nửa: 8 : 2 = 4 cái.', 'suy_luan', 65::int),
    (2::smallint, 'number', 'Vườn hoa hình tam giác có mỗi cạnh dài 5 m. Làm hàng rào quanh vườn cần ___ m hàng rào.', null, null, null, null, '15', null::jsonb, 'Chu vi tam giác: 5 x 3 = 15 (m).', 'chu_vi', 66::int),
    (2::smallint, 'number', 'Bác Mai có cuộn vải dài 25 m, mỗi bộ áo dài may hết 3 m. May xong 7 bộ thì còn thừa ___ m vải.', null, null, null, null, '4', null::jsonb, '7 bộ hết 3 x 7 = 21 m; còn 25 - 21 = 4 (m).', 'bai_toan_hai_buoc', 60::int),
    (2::smallint, 'multiple_choice', 'Tùng đi quãng đường 36 km mất 4 giờ, Bách mỗi giờ đi được 5 km (mỗi giờ đi như nhau). Ai đi nhanh hơn?', 'Tùng', 'Bách', 'Hai bạn nhanh như nhau', null, 'Tùng', null::jsonb, 'Mỗi giờ Tùng đi 36 : 4 = 9 km, nhiều hơn 5 km của Bách.', 'bai_toan_chia', 60::int),
    (2::smallint, 'number', 'Thứ Hai tuần này là ngày 8 tháng 4. Thứ Ba tuần sau là ngày ___ tháng 4.', null, null, null, null, '16', null::jsonb, 'Thứ Hai tuần sau là 8 + 7 = 15, thứ Ba là 16.', 'thoi_gian', 65::int),
    (2::smallint, 'number', 'Có 12 người qua sông, mỗi chuyến đò chở được 3 người (không kể người lái). Cần ít nhất ___ chuyến đò.', null, null, null, null, '4', null::jsonb, '12 : 3 = 4 (chuyến).', 'bai_toan_chia', 65::int),
    (2::smallint, 'number', 'Lớp học có 30 học sinh, xếp mỗi hàng 5 bạn thì được ___ hàng.', null, null, null, null, '6', null::jsonb, '30 : 5 = 6 (hàng).', 'bai_toan_chia', 83::int),
    (3::smallint, 'number', '11 mm - 1 cm 2 mm : 3 = ___ mm', null, null, null, null, '7', null::jsonb, '1 cm 2 mm = 12 mm; 12 : 3 = 4; 11 - 4 = 7 (mm).', 'tinh_so_do_dai_luong', 59::int),
    (3::smallint, 'number', '5 dm - 3 dm 5 cm : 5 = ___ cm', null, null, null, null, '43', null::jsonb, '5 dm = 50 cm, 3 dm 5 cm = 35 cm; 35 : 5 = 7; 50 - 7 = 43 (cm).', 'tinh_so_do_dai_luong', 59::int),
    (3::smallint, 'number', 'Bác Sơn bán dưa hấu: ngày đầu 154 kg, ngày thứ hai 135 kg, ngày thứ ba ít hơn ngày thứ hai 25 kg. Cả ba ngày bán được ___ kg.', null, null, null, null, '399', null::jsonb, 'Ngày thứ ba 110 kg; cả ba ngày: 154 + 135 + 110 = 399 (kg).', 'bai_toan_hai_buoc', 59::int),
    (3::smallint, 'number', 'Thùng thứ nhất đựng 134 l sơn. Thùng thứ hai đựng nhiều hơn thùng thứ nhất 32 l và ít hơn thùng thứ ba 12 l. Thùng thứ ba đựng ___ l.', null, null, null, null, '178', null::jsonb, 'Thùng hai: 134 + 32 = 166 l; thùng ba: 166 + 12 = 178 (l).', 'bai_toan_hai_buoc', 60::int),
    (3::smallint, 'number', 'Sợi dây dài 2 m, cắt đi 5 dm, phần còn lại chia thành các đoạn dài 3 dm. Được ___ đoạn 3 dm.', null, null, null, null, '5', null::jsonb, '2 m = 20 dm; còn 20 - 5 = 15 dm; 15 : 3 = 5 đoạn.', 'bai_toan_hai_buoc', 61::int),
    (3::smallint, 'number', 'Đựng dầu vào các can 4 l thì được 8 can và thừa 3 l. Nếu đổ đều số dầu đó vào 5 can thì mỗi can có ___ l.', null, null, null, null, '7', null::jsonb, 'Số dầu: 4 x 8 + 3 = 35 l; 35 : 5 = 7 (l).', 'bai_toan_hai_buoc', 62::int),
    (3::smallint, 'number', 'Hai con ốc sên bò từ hai đầu sợi dây dài 3 m về phía nhau. Con thứ nhất bò 9 dm, con thứ hai bò 12 dm. Lúc đó chúng cách nhau ___ dm.', null, null, null, null, '9', null::jsonb, '3 m = 30 dm; 30 - 9 - 12 = 9 (dm).', 'bai_toan_hai_buoc', 62::int),
    (3::smallint, 'number', 'Can thứ nhất có 4 l dầu, ít hơn can thứ hai 10 l. Chuyển dầu từ can thứ hai sang can thứ nhất cho hai can bằng nhau. Lúc đó mỗi can có ___ l.', null, null, null, null, '9', null::jsonb, 'Can hai có 14 l; cả hai 18 l; chia đều mỗi can 9 l.', 'suy_luan', 62::int),
    (3::smallint, 'number', 'Hai ngăn có 36 quyển sách, số sách ngăn thứ nhất bằng 1/4 số sách cả hai ngăn. Ngăn thứ hai có ___ quyển.', null, null, null, null, '27', null::jsonb, 'Ngăn thứ nhất: 36 : 4 = 9 quyển; ngăn thứ hai: 36 - 9 = 27 quyển.', 'bai_toan_phan_so', 63::int),
    (3::smallint, 'number', 'Đoạn đường AC dài 40 km, đoạn BC bằng 1/5 đoạn AC. Đi từ A tới C phải qua B. Đoạn AB dài ___ km.', null, null, null, null, '32', null::jsonb, 'BC = 40 : 5 = 8 km; AB = 40 - 8 = 32 (km).', 'bai_toan_phan_so', 63::int),
    (3::smallint, 'number', '1/5 số tuổi của An bằng 1/4 số tuổi của Bình. An 20 tuổi. An hơn Bình ___ tuổi.', null, null, null, null, '4', null::jsonb, '1/5 tuổi An là 20 : 5 = 4, nên Bình 4 x 4 = 16 tuổi; An hơn Bình 20 - 16 = 4 tuổi.', 'bai_toan_phan_so', 63::int),
    (3::smallint, 'number', 'Bà chia táo cho 5 cháu, mỗi cháu 4 quả thì thiếu 3 quả. Bà đã hái ___ quả táo.', null, null, null, null, '17', null::jsonb, 'Cần 5 x 4 = 20 quả mà thiếu 3 nên bà có 20 - 3 = 17 quả.', 'bai_toan_hai_buoc', 64::int),
    (3::smallint, 'number', 'Bà có 17 quả táo. Muốn chia cho 5 cháu, mỗi cháu 5 quả thì bà cần hái thêm ___ quả.', null, null, null, null, '8', null::jsonb, 'Cần 5 x 5 = 25 quả; 25 - 17 = 8 quả.', 'bai_toan_hai_buoc', 64::int),
    (3::smallint, 'number', 'Can to đựng 5 l nước mắm, can bé đựng 3 l. Có 66 l nước mắm, đổ đầy 10 can to. Cần ít nhất ___ can bé để đựng hết số còn lại.', null, null, null, null, '6', null::jsonb, 'Còn 66 - 50 = 16 l; 5 can bé đựng 15 l còn thừa 1 l nên cần 6 can bé.', 'suy_luan', 64::int),
    (3::smallint, 'multiple_choice', 'Hạnh ở nhà ông bà đúng 1 tuần và 6 ngày, trong đó chỉ có một ngày Chủ nhật. Hạnh về quê vào thứ mấy?', 'Chủ nhật', 'Thứ Bảy', 'Thứ Ba', 'Thứ Hai', 'Thứ Hai', null::jsonb, '13 ngày liên tiếp chỉ có 1 Chủ nhật khi ngày đầu là thứ Hai (Chủ nhật rơi vào ngày thứ 7).', 'thoi_gian', 65::int),
    (3::smallint, 'number', 'Đường gấp khúc gồm ba đoạn: đoạn thứ nhất dài 47 dm, đoạn thứ hai dài hơn đoạn thứ nhất 6 dm và ngắn hơn đoạn thứ ba 7 dm. Đường gấp khúc dài ___ dm.', null, null, null, null, '160', null::jsonb, 'Đoạn hai 53 dm, đoạn ba 60 dm; tổng 47 + 53 + 60 = 160 (dm).', 'duong_gap_khuc', 66::int),
    (3::smallint, 'number', 'Ba năm trước, tổng số tuổi của hai chị em là 34 tuổi. Bốn năm sau, tổng số tuổi của hai chị em là ___ tuổi.', null, null, null, null, '48', null::jsonb, 'Mỗi năm tổng tuổi hai chị em tăng 2: từ 3 năm trước đến 4 năm sau là 7 năm, tăng 14 tuổi: 34 + 14 = 48.', 'suy_luan_logic', 82::int),
    (3::smallint, 'multiple_choice', 'An nhiều tuổi hơn Hòa. Hòa ít tuổi hơn Mai nhưng nhiều tuổi hơn Hồng. Ai ít tuổi nhất?', 'Hòa', 'Hồng', 'Mai', 'An', 'Hồng', null::jsonb, 'Hòa ít tuổi hơn An và Mai, còn Hồng ít tuổi hơn Hòa nên Hồng ít tuổi nhất.', 'suy_luan_logic', 82::int),
    (3::smallint, 'multiple_choice', 'Bốn bạn Hòa, Bình, Hải, Tú có 2 điểm 10, 1 điểm 9, 1 điểm 7. Hòa cao điểm hơn Bình nhưng thấp hơn Hải. Hòa được mấy điểm?', '10 điểm', '7 điểm', '9 điểm', null, '9 điểm', null::jsonb, 'Hòa phải có điểm nằm giữa Bình và Hải nên Hòa được 9, Bình 7, Hải 10.', 'suy_luan_logic', 84::int),
    (3::smallint, 'multiple_choice', 'Hằng, Bình, An đội ba mũ khác màu: vàng, trắng, xanh. An không đội mũ vàng. Bình không đội mũ vàng, cũng không đội mũ trắng. Ai đội mũ trắng?', 'Bình', 'An', 'Hằng', null, 'An', null::jsonb, 'Bình đội mũ xanh. An không đội mũ vàng nên An đội mũ trắng, Hằng đội mũ vàng.', 'suy_luan_logic', 84::int),
    (3::smallint, 'number', 'Hộp có 5 bi xanh và 8 bi đỏ. Không nhìn, Hà lấy ra 8 viên. Chắc chắn trong đó có ít nhất ___ viên bi đỏ.', null, null, null, null, '3', null::jsonb, 'Dù lấy hết 5 bi xanh thì 8 - 5 = 3 viên còn lại phải là bi đỏ.', 'suy_luan_logic', 84::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 34 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Toán • Tuần 35: Ôn tập về hình học (46 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 35, 100, 'Archimes: Ôn tập về hình học', 'Ngân hàng Archimes — Toán 2 - Quyển 4, tuần 35', true, 'week' from public.subjects where code = 'toan'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'toan'
  cross join (values
    (1::smallint, 'number', 'Đường gấp khúc gồm hai đoạn thẳng dài 17 cm và 34 cm. Đường gấp khúc dài ___ cm.', null, null, null, null, '51', null::jsonb, '17 + 34 = 51 (cm).', 'duong_gap_khuc', 68::int),
    (1::smallint, 'number', 'Đường gấp khúc ABC có AB = 12 cm, BC = 15 cm. Đường gấp khúc dài ___ cm.', null, null, null, null, '27', null::jsonb, 'Độ dài đường gấp khúc bằng tổng các đoạn: 12 + 15 = 27 (cm).', 'duong_gap_khuc', 68::int),
    (1::smallint, 'number', 'Tam giác ABC có AB = AC = 10 cm, BC = 16 cm. Chu vi tam giác ABC là ___ cm.', null, null, null, null, '36', null::jsonb, '10 + 10 + 16 = 36 (cm).', 'chu_vi', 68::int),
    (1::smallint, 'multiple_choice', 'Số lớn nhất trong các số 908; 890; 898; 929 là:', '929', '908', '890', '898', '929', null::jsonb, '929 và 908 cùng hàng trăm 9, hàng chục 2 > 0 nên 929 lớn nhất.', 'so_sanh_so', 74::int),
    (1::smallint, 'number', 'Tính: 56 - 4 x 7 + 38 = ___', null, null, null, null, '66', null::jsonb, '4 x 7 = 28; 56 - 28 = 28; 28 + 38 = 66.', 'tinh_gia_tri_bieu_thuc', 74::int),
    (1::smallint, 'number', 'An bắt đầu học đàn lúc 19 giờ và học trong 2 giờ. Buổi học kết thúc lúc ___ giờ.', null, null, null, null, '21', null::jsonb, '19 + 2 = 21 giờ (9 giờ tối).', 'thoi_gian', 74::int),
    (1::smallint, 'number', '405 + 312 = ___', null, null, null, null, '717', null::jsonb, '5 + 2 = 7, 0 + 1 = 1, 4 + 3 = 7 → 717.', 'cong_khong_nho', 75::int),
    (1::smallint, 'number', '674 - 242 = ___', null, null, null, null, '432', null::jsonb, '4 - 2 = 2, 7 - 4 = 3, 6 - 2 = 4 → 432.', 'tru_khong_nho', 75::int),
    (1::smallint, 'number', '436 - 25 = ___', null, null, null, null, '411', null::jsonb, '6 - 5 = 1, 3 - 2 = 1, hàng trăm 4 → 411.', 'tru_khong_nho', 75::int),
    (1::smallint, 'number', '5 dm = ___ cm', null, null, null, null, '50', null::jsonb, '1 dm = 10 cm nên 5 dm = 50 cm.', 'doi_don_vi_do_dai', 75::int),
    (1::smallint, 'number', '3 m = ___ cm', null, null, null, null, '300', null::jsonb, '1 m = 100 cm nên 3 m = 300 cm.', 'doi_don_vi_do_dai', 75::int),
    (1::smallint, 'number', '80 dm = ___ m', null, null, null, null, '8', null::jsonb, '10 dm = 1 m nên 80 dm = 8 m.', 'doi_don_vi_do_dai', 75::int),
    (1::smallint, 'number', 'Tìm a, biết: a + 12 = 115. a = ___', null, null, null, null, '103', null::jsonb, 'a = 115 - 12 = 103.', 'tim_so_hang', 75::int),
    (1::smallint, 'multiple_choice', 'Hình tam giác có mấy cạnh?', '4 cạnh', '3 cạnh', '2 cạnh', '5 cạnh', '3 cạnh', null::jsonb, 'Hình tam giác có 3 cạnh và 3 đỉnh.', 'nhan_biet_hinh', 67::int),
    (1::smallint, 'multiple_choice', '32 cm = ?', '32 dm', '3 m 2 cm', '3 dm 2 cm', '3 dm 20 cm', '3 dm 2 cm', null::jsonb, '32 cm = 30 cm + 2 cm = 3 dm 2 cm.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'multiple_choice', '45 dm = ?', '45 m', '4 m 50 dm', '40 m 5 dm', '4 m 5 dm', '4 m 5 dm', null::jsonb, '45 dm = 40 dm + 5 dm = 4 m 5 dm.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'text', 'Ngày 19 tháng 5 là thứ Tư thì ngày 26 tháng 5 cùng năm là thứ ___', null, null, null, null, 'Tư', '["4","thứ Tư","thứ 4"]'::jsonb, 'Sau đúng 7 ngày (một tuần) thì lại là thứ Tư.', 'thoi_gian', 74::int),
    (2::smallint, 'number', 'Hình tứ giác có bốn cạnh bằng nhau và chu vi là 80 dm. Mỗi cạnh dài ___ dm.', null, null, null, null, '20', null::jsonb, '80 : 4 = 20 (dm).', 'chu_vi', 68::int),
    (2::smallint, 'number', 'Hình tam giác có ba cạnh bằng nhau, chu vi là 3 dm. Mỗi cạnh dài ___ cm.', null, null, null, null, '10', null::jsonb, '3 dm = 30 cm; 30 : 3 = 10 (cm).', 'chu_vi', 71::int),
    (2::smallint, 'number', 'Hình tứ giác có bốn cạnh bằng nhau, chu vi là 1 dm 2 cm. Mỗi cạnh dài ___ cm.', null, null, null, null, '3', null::jsonb, '1 dm 2 cm = 12 cm; 12 : 4 = 3 (cm).', 'chu_vi', 71::int),
    (2::smallint, 'number', 'Tứ giác ABCD có AB = 1 dm 8 cm, BC = 2 dm, CD = 24 cm, DA = 16 cm. Chu vi tứ giác là ___ cm.', null, null, null, null, '78', null::jsonb, 'Đổi ra cm: 18 + 20 + 24 + 16 = 78 (cm).', 'chu_vi', 69::int),
    (2::smallint, 'number', 'Một tứ giác có tổng cạnh thứ nhất và cạnh thứ ba là 23 cm, tổng cạnh thứ hai và cạnh thứ tư là 27 cm. Chu vi tứ giác là ___ cm.', null, null, null, null, '50', null::jsonb, 'Chu vi = tổng bốn cạnh = 23 + 27 = 50 (cm).', 'chu_vi', 70::int),
    (2::smallint, 'number', 'Một tam giác có chu vi 879 cm, cạnh thứ nhất dài 333 cm, cạnh thứ hai ngắn hơn cạnh thứ nhất 3 dm. Cạnh thứ hai dài ___ cm.', null, null, null, null, '303', null::jsonb, '3 dm = 30 cm; 333 - 30 = 303 (cm).', 'chu_vi', 69::int),
    (2::smallint, 'number', '2 m 40 cm = ___ dm', null, null, null, null, '24', null::jsonb, '2 m 40 cm = 240 cm = 24 dm.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'number', '6 dm 1 cm = ___ mm', null, null, null, null, '610', null::jsonb, '6 dm 1 cm = 61 cm = 610 mm.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'number', '512 cm = 5 m ___ cm', null, null, null, null, '12', null::jsonb, '5 m = 500 cm; 512 - 500 = 12.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'number', '603 mm = ___ cm 3 mm', null, null, null, null, '60', null::jsonb, '600 mm = 60 cm nên 603 mm = 60 cm 3 mm.', 'doi_don_vi_do_dai', 75::int),
    (2::smallint, 'number', 'Tìm a, biết: a x 4 = 8 x 2. a = ___', null, null, null, null, '4', null::jsonb, '8 x 2 = 16; a = 16 : 4 = 4.', 'tim_thua_so', 75::int),
    (2::smallint, 'number', 'Bà chia cam vào 4 túi, mỗi túi 5 quả thì còn thừa 3 quả. Bà có ___ quả cam.', null, null, null, null, '23', null::jsonb, '4 x 5 = 20; 20 + 3 = 23 (quả).', 'bai_toan_hai_buoc', 74::int),
    (2::smallint, 'number', 'Số lớn nhất có hai chữ số lớn hơn số Lan nghĩ 25 đơn vị. Lan nghĩ ra số ___', null, null, null, null, '74', null::jsonb, 'Số lớn nhất có hai chữ số là 99; 99 - 25 = 74.', 'tim_thanh_phan', 74::int),
    (2::smallint, 'multiple_choice', 'Sinh nhật Bác Hồ (ngày 19 tháng 5) năm nay là thứ Tư. Ngày 21 tháng 5 năm nay là thứ mấy?', 'Thứ Sáu', 'Thứ Năm', 'Thứ Bảy', 'Thứ Ba', 'Thứ Sáu', null::jsonb, '21 tháng 5 sau 19 tháng 5 hai ngày: thứ Tư → thứ Năm → thứ Sáu.', 'thoi_gian', 74::int),
    (3::smallint, 'number', 'Một tam giác có chu vi 879 cm, cạnh thứ nhất dài 333 cm, cạnh thứ hai ngắn hơn cạnh thứ nhất 3 dm. Cạnh thứ ba dài ___ cm.', null, null, null, null, '243', null::jsonb, 'Cạnh thứ hai 303 cm; cạnh thứ ba: 879 - 333 - 303 = 243 (cm).', 'chu_vi', 69::int),
    (3::smallint, 'number', 'Tam giác ABC có AB = 18 cm và dài hơn BC 6 cm, AC bằng 1/2 AB. Chu vi tam giác ABC là ___ cm.', null, null, null, null, '39', null::jsonb, 'BC = 12 cm, AC = 9 cm; chu vi 18 + 12 + 9 = 39 (cm).', 'chu_vi', 69::int),
    (3::smallint, 'number', 'Đường gấp khúc ABCD dài 2 dm. AB = 7 cm và ngắn hơn CD 3 cm. Đoạn BC dài ___ cm.', null, null, null, null, '3', null::jsonb, '2 dm = 20 cm; CD = 10 cm; BC = 20 - 7 - 10 = 3 (cm).', 'duong_gap_khuc', 70::int),
    (3::smallint, 'number', 'Tứ giác ABCD có AB = 15 cm, AD = 8 cm và AD bằng 1/2 tổng hai cạnh BC và CD. Chu vi tứ giác là ___ cm.', null, null, null, null, '39', null::jsonb, 'BC + CD = 8 x 2 = 16 cm; chu vi 15 + 8 + 16 = 39 (cm).', 'chu_vi', 70::int),
    (3::smallint, 'number', 'Tứ giác MNPQ có MN + NP = 21 cm, PQ ngắn hơn MN + NP là 9 cm, chu vi là 4 dm. Cạnh QM dài ___ cm.', null, null, null, null, '7', null::jsonb, 'PQ = 12 cm; 4 dm = 40 cm; QM = 40 - 21 - 12 = 7 (cm).', 'chu_vi', 71::int),
    (3::smallint, 'number', 'Tứ giác MNPQ có chu vi 42 cm, MN + NP + PQ = 34 cm, PQ + QM = 21 cm. Cạnh PQ dài ___ cm.', null, null, null, null, '13', null::jsonb, 'QM = 42 - 34 = 8 cm; PQ = 21 - 8 = 13 (cm).', 'chu_vi', 72::int),
    (3::smallint, 'number', 'Tam giác ABC có điểm D nằm trên cạnh BC, AD = 13 cm. Chu vi tam giác ABD là 33 cm, chu vi tam giác ADC là 35 cm. Chu vi tam giác ABC là ___ cm.', null, null, null, null, '42', null::jsonb, 'Cộng hai chu vi thì AD bị tính 2 lần: 33 + 35 - 13 x 2 = 42 (cm).', 'chu_vi', 72::int),
    (3::smallint, 'number', 'Tứ giác ABCD có đoạn AC = 10 cm chia nó thành tam giác ABC (chu vi 24 cm) và tam giác ACD (chu vi 32 cm). Chu vi tứ giác ABCD là ___ cm.', null, null, null, null, '36', null::jsonb, 'Cộng hai chu vi rồi bớt AC hai lần: 24 + 32 - 20 = 36 (cm).', 'chu_vi', 72::int),
    (3::smallint, 'number', 'Tam giác ABC có điểm H trên cạnh BC. Chu vi tam giác ABC là 32 cm, chu vi tam giác ABH và ACH đều là 24 cm. Đoạn AH dài ___ cm.', null, null, null, null, '8', null::jsonb, '24 + 24 = 48 gồm chu vi ABC và 2 lần AH; AH = (48 - 32) : 2 = 8 (cm).', 'chu_vi', 73::int),
    (3::smallint, 'multiple_choice', 'Hình vuông ABCD cạnh 4 cm được chia thành 16 ô vuông cạnh 1 cm. So sánh chu vi hình vuông ABCD với tổng chu vi 4 ô vuông nhỏ:', 'Chu vi ABCD lớn hơn', 'Chu vi ABCD bé hơn', 'Bằng nhau', null, 'Bằng nhau', null::jsonb, 'Chu vi ABCD: 4 x 4 = 16 cm; mỗi ô nhỏ có chu vi 4 cm, 4 ô: 16 cm.', 'chu_vi', 73::int),
    (3::smallint, 'number', 'Tìm a, biết: 2 x a + 200 = 240. a = ___', null, null, null, null, '20', null::jsonb, '2 x a = 40; a = 20.', 'tim_thanh_phan', 75::int),
    (3::smallint, 'number', 'Năm mẹ 40 tuổi thì con gái 15 tuổi. Năm nay mẹ 30 tuổi. Năm nay con gái ___ tuổi.', null, null, null, null, '5', null::jsonb, 'Mẹ hơn con 40 - 15 = 25 tuổi; năm nay con 30 - 25 = 5 tuổi.', 'suy_luan', 74::int),
    (3::smallint, 'number', 'Hiệu của 98 với số lớn nhất có hai chữ số mà tổng hai chữ số của nó là 11 là ___', null, null, null, null, '6', null::jsonb, 'Số lớn nhất có hai chữ số, tổng hai chữ số bằng 11 là 92; 98 - 92 = 6.', 'suy_luan', 74::int),
    (3::smallint, 'number', 'Tuấn cho em 12 quả bóng bay thì số bóng còn lại bằng 1/3 số bóng đã cho. Lúc đầu Tuấn có ___ quả bóng.', null, null, null, null, '16', null::jsonb, 'Còn lại 12 : 3 = 4 quả; lúc đầu 12 + 4 = 16 quả.', 'bai_toan_phan_so', 74::int),
    (3::smallint, 'number', '1/3 số táo Linh hái bằng 1/2 số táo Tú hái. Linh hái được 15 quả. Tú hái được ___ quả.', null, null, null, null, '10', null::jsonb, '1/3 số táo của Linh là 5 quả, bằng 1/2 số táo của Tú, nên Tú hái 5 x 2 = 10 quả.', 'bai_toan_phan_so', 75::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 35 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 1: Em là học sinh – Từ và câu, quy tắc c/k, phân biệt l/n, an/ang (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 1, 100, 'Archimes: Em là học sinh – Từ và câu, quy tắc c/k, phân biệt l/n, an/ang', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 1', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền c hay k: ___ày sâu cuốc bẫm', null, null, null, null, 'c', null::jsonb, 'Viết c trước a: cày sâu cuốc bẫm.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền c hay k: ___én cá chọn canh', null, null, null, null, 'k', null::jsonb, 'Viết k trước e, ê, i: kén cá chọn canh.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền c hay k: ___ề vai sát cánh', null, null, null, null, 'k', null::jsonb, 'Viết k trước ê: kề vai sát cánh.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'dòng cẻ', 'kon tôm', 'cần kù', 'dòng kẻ', 'dòng kẻ', null::jsonb, 'Viết k trước e nên "dòng kẻ" đúng; viết c trước o, u: con tôm, cần cù.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền l hay n: Mặt trời ___ên cao.', null, null, null, null, 'l', null::jsonb, 'Mặt trời lên cao.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'text', 'Điền l hay n: Có chí thì ___ên.', null, null, null, null, 'n', null::jsonb, 'Có chí thì nên.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'multiple_choice', 'Chọn từ đúng điền vào chỗ trống: "Ánh sáng ___ linh."', 'nung', 'lung', 'lúng', null, 'lung', null::jsonb, 'Ánh sáng lung linh.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG thuộc nhóm đồ dùng học tập?', 'bút chì', 'thước kẻ', 'cái quạt', 'cặp sách', 'cái quạt', null::jsonb, 'Cái quạt không phải đồ dùng học tập.', 'tu_chi_su_vat', 5::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ hoạt động của học sinh?', 'xây nhà', 'đọc', 'viết', 'nghe giảng', 'xây nhà', null::jsonb, 'Xây nhà là việc của người thợ, không phải hoạt động học của học sinh.', 'tu_chi_hoat_dong', 5::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ tính nết tốt đẹp của học sinh?', 'chăm chỉ', 'siêng năng', 'lười biếng', 'ngoan ngoãn', 'lười biếng', null::jsonb, 'Lười biếng là tính nết xấu.', 'tu_chi_dac_diem', 5::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ người?', 'hát', 'ngoan ngoãn', 'cần cù', 'cô giáo', 'cô giáo', null::jsonb, 'Cô giáo là từ chỉ người.', 'tu_chi_su_vat', 5::int),
    (1::smallint, 'text', 'Đồ vật dài và thẳng, dùng để đo chiều dài là cái ___.', null, null, null, null, 'thước', '["thước kẻ"]'::jsonb, 'Cái thước (thước kẻ) dùng để đo độ dài.', 'tu_chi_su_vat', 5::int),
    (1::smallint, 'multiple_choice', 'Tập giấy được đóng lại để viết, thường có bìa bọc ngoài là gì?', 'cặp sách', 'quyển vở', 'thước kẻ', 'hộp bút', 'quyển vở', null::jsonb, 'Quyển vở là tập giấy đóng lại để viết.', 'tu_chi_su_vat', 5::int),
    (1::smallint, 'text', 'Điền c hoặc k: Mẹ vừa mua cho Lan một chiếc ___ính cận mới.', null, null, null, null, 'k', null::jsonb, 'Viết k trước i: kính cận.', 'chinh_ta_c_k', 9::int),
    (1::smallint, 'text', 'Điền l hoặc n: Dưới ___ắng hè, cây phượng rực lửa với những chùm hoa tươi rói.', null, null, null, null, 'n', null::jsonb, 'Dưới nắng hè.', 'chinh_ta_l_n', 9::int),
    (2::smallint, 'multiple_choice', 'Đồ vật thường có hình chữ nhật, có nhiều ngăn, dùng để đựng đồ dùng học tập là gì?', 'cặp sách', 'quyển vở', 'bảng con', 'thước kẻ', 'cặp sách', null::jsonb, 'Cặp sách có nhiều ngăn để đựng sách vở, bút thước.', 'tu_chi_su_vat', 5::int),
    (2::smallint, 'multiple_choice', 'Hà xếp tên các bạn: Hà, Chi, Mai, An. Thứ tự đúng theo bảng chữ cái là:', 'Hà, Chi, Mai, An', 'Chi, An, Hà, Mai', 'An, Hà, Chi, Mai', 'An, Chi, Hà, Mai', 'An, Chi, Hà, Mai', null::jsonb, 'Theo bảng chữ cái: a đứng trước c, c trước h, h trước m.', 'thu_tu_chu_cai', 4::int),
    (2::smallint, 'text', 'Điền an hay ang: Mấy chú ngan con đã dàn hàng ng___ đi kiếm mồi.', null, null, null, null, 'ang', null::jsonb, 'Dàn hàng ngang.', 'chinh_ta_an_ang', 4::int),
    (2::smallint, 'text', 'Điền an hay ang (thêm dấu thanh nếu cần): Mấy đứa nhỏ đi lang thang trong sân trường để tìm quả b___ rơi.', null, null, null, null, 'àng', null::jsonb, 'Quả bàng.', 'chinh_ta_an_ang', 4::int),
    (2::smallint, 'text', 'Điền an hay ang (thêm dấu thanh nếu cần): Trời vừa s___, Linh đã đến nhà Hà để học chơi đàn.', null, null, null, null, 'áng', null::jsonb, 'Trời vừa sáng.', 'chinh_ta_an_ang', 4::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Em cầm tờ lịch cũ:
- Ngày hôm qua đâu rồi?
Ra ngoài sân hỏi bố
Xoa đầu em, bố cười."
(Bế Kiến Quốc)
Bạn nhỏ hỏi bố điều gì?', 'Tờ lịch cũ ở đâu?', 'Điểm 10 của con đâu rồi?', 'Ngày hôm qua đâu rồi?', 'Bố ơi, bố cười gì thế?', 'Ngày hôm qua đâu rồi?', null::jsonb, 'Bạn nhỏ cầm tờ lịch cũ và hỏi bố: "Ngày hôm qua đâu rồi?"', 'doc_hieu', 8::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngày hôm qua ở lại
Trên cành hoa trong vườn
...
Ngày hôm qua ở lại
Trong hạt lúa mẹ trồng
...
Ngày hôm qua ở lại
Trong vở hồng của con"
Ngày hôm qua ở lại trong những sự vật nào?', 'cành hoa, hạt lúa, vở hồng', 'cành hoa, nụ hồng, tỏa hương', 'hạt lúa, cánh đồng', 'tờ lịch, sân nhà, bố', 'cành hoa, hạt lúa, vở hồng', null::jsonb, 'Ngày hôm qua ở lại trên cành hoa, trong hạt lúa và trong vở hồng.', 'doc_hieu', 8::int),
    (2::smallint, 'multiple_choice', 'Sắp xếp các từ thành câu: bố mẹ / một / chiếc cặp sách / tặng / em / mới. Câu nào đúng?', 'Bố mẹ một tặng em chiếc cặp sách mới.', 'Bố mẹ tặng em một chiếc cặp sách mới.', 'Em tặng mới bố mẹ một chiếc cặp sách.', 'Chiếc cặp sách mới tặng em bố mẹ một.', 'Bố mẹ tặng em một chiếc cặp sách mới.', null::jsonb, 'Câu đúng: Bố mẹ tặng em một chiếc cặp sách mới.', 'sap_xep_cau', 9::int),
    (2::smallint, 'multiple_choice', 'Sắp xếp các từ thành câu: năm nay / lớp / em / học / hai. Câu nào đúng?', 'Năm nay học lớp em hai.', 'Em lớp hai học năm nay.', 'Năm nay, em học lớp hai.', 'Lớp hai năm nay em học.', 'Năm nay, em học lớp hai.', null::jsonb, 'Câu đúng: Năm nay, em học lớp hai.', 'sap_xep_cau', 9::int),
    (2::smallint, 'multiple_choice', 'Điền vào chỗ trống: "Trên cành cây, những giọt sương ___."', 'nong nanh', 'long nanh', 'nong lanh', 'long lanh', 'long lanh', null::jsonb, 'Viết đúng là "long lanh".', 'chinh_ta_l_n', 9::int),
    (2::smallint, 'multiple_choice', 'Chữ cái nào đứng ngay sau chữ c trong bảng chữ cái Tiếng Việt?', 'd', 'đ', 'b', 'e', 'd', null::jsonb, 'Thứ tự: a, ă, â, b, c, d, đ, e, ...', 'bang_chu_cai', 3::int),
    (3::smallint, 'multiple_choice', 'Khổ thơ: "Ngày hôm qua ở lại / Trong vở hồng của con / Con học hành chăm chỉ / Là ngày qua vẫn còn." Đoạn thơ muốn khuyên em điều gì?', 'Giữ gìn tờ lịch cũ thật cẩn thận', 'Học hành chăm chỉ, không để phí thời gian', 'Chăm tưới hoa trong vườn', 'Ra đồng gặt lúa cùng mẹ', 'Học hành chăm chỉ, không để phí thời gian', null::jsonb, 'Chăm chỉ học hành thì thời gian không mất đi mà còn đọng lại trong vở.', 'doc_hieu', 8::int),
    (3::smallint, 'multiple_choice', 'Cho ba từ: "bé", "bà", "yêu". Cặp câu nào là hai câu khác nhau, đều đúng?', 'Bé yêu bà. / Yêu bà bé.', 'Bé yêu bà. / Bà yêu bé.', 'Bà yêu bé. / Bé bà yêu.', 'Yêu bé bà. / Bà yêu bé.', 'Bé yêu bà. / Bà yêu bé.', null::jsonb, 'Hai câu đúng: "Bé yêu bà." và "Bà yêu bé."', 'sap_xep_cau', 6::int),
    (3::smallint, 'number', 'Dãy từ: bút chì, bút mực, thước kẻ, cái quạt, sách vở, cặp sách. Có ___ từ chỉ đồ dùng học tập.', null, null, null, null, '5', null::jsonb, 'Chỉ có "cái quạt" không phải đồ dùng học tập, còn lại 5 từ.', 'tu_chi_su_vat', 5::int),
    (3::smallint, 'number', 'Các từ: học sinh, hát, múa, bạn bè, ngoan ngoãn, cần cù, đọc, viết, cô giáo, chăm chỉ. Có ___ từ chỉ hoạt động.', null, null, null, null, '4', null::jsonb, 'Các từ chỉ hoạt động: hát, múa, đọc, viết.', 'tu_chi_hoat_dong', 5::int),
    (3::smallint, 'multiple_choice', 'Nhóm nào gồm toàn từ chỉ tính nết của học sinh?', 'học sinh, cô giáo, bạn bè', 'hát, múa, đọc, viết', 'ngoan ngoãn, cần cù, chăm chỉ', 'ngoan ngoãn, hát, cô giáo', 'ngoan ngoãn, cần cù, chăm chỉ', null::jsonb, 'Ngoan ngoãn, cần cù, chăm chỉ đều chỉ tính nết.', 'tu_chi_dac_diem', 5::int),
    (3::smallint, 'text', 'Xếp tên 4 bạn Hà, Chi, Mai, An theo thứ tự bảng chữ cái. Bạn đứng thứ ba là bạn ___.', null, null, null, null, 'Hà', null::jsonb, 'Thứ tự đúng: An, Chi, Hà, Mai nên bạn thứ ba là Hà.', 'thu_tu_chu_cai', 4::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 1 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 2: Em là học sinh – Từ ngữ về học tập, dấu chấm hỏi, s/x, g/gh, ăn/ăng (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 2, 100, 'Archimes: Em là học sinh – Từ ngữ về học tập, dấu chấm hỏi, s/x, g/gh, ăn/ăng', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 2', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền g hay gh: nhà ___a', null, null, null, null, 'g', null::jsonb, 'Viết g trước a: nhà ga.', 'chinh_ta_g_gh', 11::int),
    (1::smallint, 'text', 'Điền g hay gh: bàn ___ế', null, null, null, null, 'gh', null::jsonb, 'Viết gh trước ê: bàn ghế.', 'chinh_ta_g_gh', 11::int),
    (1::smallint, 'text', 'Điền g hay gh: ___i nhớ', null, null, null, null, 'gh', null::jsonb, 'Viết gh trước i: ghi nhớ.', 'chinh_ta_g_gh', 11::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ghập gềnh', 'gập gềnh', 'ghập ghềnh', 'gập ghềnh', 'gập ghềnh', null::jsonb, 'g trước â (gập), gh trước ê (ghềnh).', 'chinh_ta_g_gh', 11::int),
    (1::smallint, 'text', 'Điền s hay x: Dế Mèn đứng trên bục, cúi đầu, ___õa tóc rồi bất thần ngẩng phắt lên.', null, null, null, null, 'x', null::jsonb, 'Xõa tóc.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền s hay x: "Trong rừng ___anh sâu thẳm"', null, null, null, null, 'x', null::jsonb, 'Rừng xanh sâu thẳm.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền s hay x: "Đôi bạn ___ống bên nhau / Bê Vàng và Dê Trắng"', null, null, null, null, 's', null::jsonb, 'Đôi bạn sống bên nhau.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền ăn hay ăng (thêm dấu thanh nếu cần): Chiếc kh___ trắng tinh.', null, null, null, null, 'ăn', null::jsonb, 'Chiếc khăn trắng tinh.', 'chinh_ta_an_ang', 11::int),
    (1::smallint, 'text', 'Điền ăn hay ăng (thêm dấu thanh nếu cần): Mặt tr___ sắp lặn.', null, null, null, null, 'ăng', null::jsonb, 'Mặt trăng sắp lặn.', 'chinh_ta_an_ang', 11::int),
    (1::smallint, 'multiple_choice', 'Câu nào dùng đúng dấu câu?', 'Trường học của em ở đâu.', 'Cô giáo lớp một của em tên là gì.', 'Em học lớp mấy?', 'Em đã làm xong bài tập chưa.', 'Em học lớp mấy?', null::jsonb, 'Câu hỏi phải kết thúc bằng dấu chấm hỏi.', 'dau_cau', 13::int),
    (1::smallint, 'multiple_choice', 'Cuối câu "Các bạn của em học có giỏi không" cần đặt dấu gì?', 'dấu chấm hỏi', 'dấu chấm', 'dấu phẩy', null, 'dấu chấm hỏi', null::jsonb, 'Đây là câu hỏi nên dùng dấu chấm hỏi.', 'dau_cau', 13::int),
    (1::smallint, 'multiple_choice', 'Cuối câu "Em rất yêu ngôi trường của mình" cần đặt dấu gì?', 'dấu chấm hỏi', 'dấu chấm', 'dấu phẩy', null, 'dấu chấm', null::jsonb, 'Đây là câu kể nên dùng dấu chấm.', 'dau_cau', 13::int),
    (1::smallint, 'multiple_choice', 'Hoạt động nào em thường làm khi học môn Tiếng Việt?', 'tính toán', 'đếm số', 'tập đọc', 'vẽ bản đồ', 'tập đọc', null::jsonb, 'Tập đọc là hoạt động của môn Tiếng Việt.', 'tu_ngu_hoc_tap', 12::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ ngữ về học tập?', 'nhà ga', 'gỗ xoan', 'dòng sông', 'bài tập', 'bài tập', null::jsonb, 'Bài tập là từ ngữ về học tập.', 'tu_ngu_hoc_tap', 11::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'thiếu xót', 'ngôi sao', 'sản xuất', 'sinh sống', 'thiếu xót', null::jsonb, 'Viết đúng là "thiếu sót".', 'chinh_ta_s_x', 11::int),
    (2::smallint, 'text', 'Sửa từ viết sai cho đúng: "xử dụng" → ___', null, null, null, null, 'sử dụng', null::jsonb, 'Viết đúng là "sử dụng".', 'chinh_ta_s_x', 11::int),
    (2::smallint, 'text', 'Sửa từ viết sai cho đúng: "suất sắc" → ___', null, null, null, null, 'xuất sắc', null::jsonb, 'Viết đúng là "xuất sắc".', 'chinh_ta_s_x', 11::int),
    (2::smallint, 'multiple_choice', 'Câu nào cần đặt dấu chấm hỏi ở cuối?', 'Tớ ước trở thành cô tiên trong truyện cổ tích', 'Khi nào chúng mình được nghỉ hè nhỉ', 'Em rất yêu ngôi trường của mình', 'Mẹ em tên là Ngọc', 'Khi nào chúng mình được nghỉ hè nhỉ', null::jsonb, 'Câu "Khi nào chúng mình được nghỉ hè nhỉ" là câu hỏi.', 'dau_cau', 13::int),
    (2::smallint, 'multiple_choice', 'Câu nào cần đặt dấu chấm ở cuối?', 'Có phải mùa xuân là mùa đẹp nhất không', 'Tớ ước trở thành cô tiên trong truyện cổ tích', 'Quyển sách này giá bao nhiêu ạ', 'Các bạn của em học có giỏi không', 'Tớ ước trở thành cô tiên trong truyện cổ tích', null::jsonb, 'Câu kể về mong ước của bạn nhỏ nên dùng dấu chấm.', 'dau_cau', 13::int),
    (2::smallint, 'multiple_choice', 'Ghép hai tiếng nào dưới đây thành một từ về học tập?', 'bạn + kì', 'hỏi + trường', 'học + hỏi', 'kì + bài', 'học + hỏi', null::jsonb, 'Ghép "học" và "hỏi" được từ "học hỏi".', 'tu_ngu_hoc_tap', 11::int),
    (2::smallint, 'multiple_choice', 'Chọn từ điền vào chỗ trống: "Mình là Nguyễn Quang Anh, học sinh lớp 2A1. Mình rất yêu ___ của mình."', 'bóng đá', 'phim hoạt hình', 'truyện cổ tích', 'ngôi trường', 'ngôi trường', null::jsonb, 'Mình rất yêu ngôi trường của mình.', 'tu_ngu_hoc_tap', 14::int),
    (2::smallint, 'multiple_choice', 'Chọn từ điền vào chỗ trống: "Mình thích đọc ___, thích chơi bóng đá và xem phim hoạt hình."', 'truyện cổ tích', 'ngôi trường', 'bóng đá', 'phim hoạt hình', 'truyện cổ tích', null::jsonb, 'Thứ để đọc là truyện cổ tích.', 'tu_ngu_hoc_tap', 14::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Giờ Tập làm văn miệng, cô giáo ra đề: Kể về ước mơ của em. Long muốn trở thành nhà du hành vũ trụ. Tiến mơ ước trở thành phi công. Trang muốn thành cô giáo... Cả lớp hào hứng, ai cũng mơ ước lớn lên làm một nghề thật oách."
Đề văn yêu cầu học sinh làm gì?', 'Kể về ước mơ của mình', 'Kể về gia đình Vân', 'Kể về người con hiếu thảo', null, 'Kể về ước mơ của mình', null::jsonb, 'Cô giáo ra đề: Kể về ước mơ của em.', 'doc_hieu', 15::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Giờ Tập làm văn miệng, cô giáo ra đề: Kể về ước mơ của em. Long muốn trở thành nhà du hành vũ trụ. Tiến mơ ước trở thành phi công. Trang muốn thành cô giáo... Cả lớp hào hứng, ai cũng mơ ước lớn lên làm một nghề thật oách."
Trước đề văn đó, thái độ của cả lớp thế nào?', 'Các bạn ỉu xìu.', 'Các bạn rất hào hứng.', 'Các bạn chẳng nói gì.', null, 'Các bạn rất hào hứng.', null::jsonb, 'Bài viết: "Cả lớp hào hứng".', 'doc_hieu', 15::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Riêng Vân ỉu xìu, chẳng nói gì. Cô giáo ngạc nhiên:
- Sao em không nói ước mơ của mình?
- Thưa cô, em chỉ ước mẹ em chóng khỏi bệnh. - Vân nói khẽ."
Vân mơ ước điều gì?', 'Học thật giỏi', 'Trở thành cô giáo', 'Mẹ chóng khỏi bệnh', 'Trở thành phi công', 'Mẹ chóng khỏi bệnh', null::jsonb, 'Vân nói: "Em chỉ ước mẹ em chóng khỏi bệnh."', 'doc_hieu', 15::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mẹ Vân bị bệnh. Vân phải giúp ba chăm sóc mẹ, trông em mà vẫn học giỏi. Vân chỉ ước mẹ chóng khỏi bệnh."
Ước mơ của Vân cho thấy Vân là người con thế nào?', 'lớn lao', 'nghịch ngợm', 'nhút nhát', 'hiếu thảo', 'hiếu thảo', null::jsonb, 'Cô giáo khen: ước mơ của Vân cho thấy em rất hiếu thảo.', 'doc_hieu', 15::int),
    (3::smallint, 'multiple_choice', 'Câu nào có chữ viết sai chính tả?', 'Minh sắp xếp sách vở vào cặp.', 'Em rất yêu ngôi trường của mình.', 'Bạn Bình luôn chú ý lắng nge cô giáo giảng bài.', 'Mặt trăng sắp lặn.', 'Bạn Bình luôn chú ý lắng nge cô giáo giảng bài.', null::jsonb, '"lắng nge" phải viết là "lắng nghe" (ngh trước e).', 'chinh_ta', 16::int),
    (3::smallint, 'text', 'Tìm và sửa từ viết sai trong câu: "Minh xắp xếp sách vở vào cặp để mang đến trường." Từ đúng là ___', null, null, null, null, 'sắp xếp', null::jsonb, '"xắp xếp" phải viết là "sắp xếp".', 'chinh_ta_s_x', 16::int),
    (3::smallint, 'multiple_choice', 'Xếp các từ "chị / rất / em bé / yêu" thành câu. Câu nào đúng?', 'Chị em bé rất yêu.', 'Rất yêu chị em bé.', 'Yêu chị rất em bé.', 'Chị rất yêu em bé.', 'Chị rất yêu em bé.', null::jsonb, 'Câu đúng: Chị rất yêu em bé.', 'sap_xep_cau', 16::int),
    (3::smallint, 'multiple_choice', 'Đổi thứ tự các từ trong câu "Mai học cùng lớp 2A4 với Đào." để được câu mới. Câu nào đúng?', 'Mai với Đào lớp học cùng 2A4.', 'Đào học cùng lớp 2A4 với Mai.', 'Lớp 2A4 học cùng Mai Đào với.', 'Học cùng Mai lớp 2A4 Đào với.', 'Đào học cùng lớp 2A4 với Mai.', null::jsonb, 'Đổi chỗ Mai và Đào: Đào học cùng lớp 2A4 với Mai.', 'sap_xep_cau', 12::int),
    (3::smallint, 'multiple_choice', 'Xếp các từ "Tiếng Việt / môn học / là / yêu thích / em" thành câu đúng:', 'Tiếng Việt là môn học em yêu thích.', 'Môn học là Tiếng Việt em yêu thích.', 'Em là môn học yêu thích Tiếng Việt.', 'Yêu thích em là môn học Tiếng Việt.', 'Tiếng Việt là môn học em yêu thích.', null::jsonb, 'Câu đúng: Tiếng Việt là môn học em yêu thích.', 'sap_xep_cau', 16::int),
    (3::smallint, 'number', 'Có ___ câu dùng đúng dấu câu trong các câu sau:
a. Em học lớp mấy?
b. Trường học của em ở đâu.
c. Mẹ em tên là Ngọc.
d. Em đã làm xong bài tập về nhà chưa?
e. Cô giáo dạy lớp một của em tên là gì.', null, null, null, null, '3', null::jsonb, 'Câu a, c, d đúng; câu b và e là câu hỏi nhưng lại dùng dấu chấm.', 'dau_cau', 13::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 2 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 3: Bạn bè – Từ chỉ sự vật, câu Ai là gì?, ng/ngh, ch/tr, dấu hỏi/dấu ngã (30 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 3, 100, 'Archimes: Bạn bè – Từ chỉ sự vật, câu Ai là gì?, ng/ngh, ch/tr, dấu hỏi/dấu ngã', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 3', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ng hay ngh: "Dù ai nói ngả nói ___iêng / Lòng ta vẫn vững như kiềng ba chân."', null, null, null, null, 'ngh', null::jsonb, 'Viết ngh trước i: nghiêng.', 'chinh_ta_ng_ngh', 17::int),
    (1::smallint, 'text', 'Điền ch hay tr: "Quả gấc nào mà ___ín / Còn bưởi cam ngọt ngào"', null, null, null, null, 'ch', null::jsonb, 'Quả gấc chín.', 'chinh_ta_ch_tr', 17::int),
    (1::smallint, 'text', 'Điền ch hay tr: "Cũng gặp được mặt ___ời"', null, null, null, null, 'tr', null::jsonb, 'Mặt trời.', 'chinh_ta_ch_tr', 17::int),
    (1::smallint, 'text', 'Điền ch hay tr: "Có thêm cả ___ái thị / Cho đông đủ mùa thu"', null, null, null, null, 'tr', null::jsonb, 'Trái thị.', 'chinh_ta_ch_tr', 17::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng điền vào chỗ trống: "buổi ___"', 'triều', 'chiều', 'chìu', null, 'chiều', null::jsonb, 'Buổi chiều.', 'chinh_ta_ch_tr', 18::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "con ___" (con vật kéo cày)', 'châu', 'trầu', 'trâu', null, 'trâu', null::jsonb, 'Con trâu.', 'chinh_ta_ch_tr', 18::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'nghĩ ngơi', 'ngỉ ngơi', 'nghỉ nghơi', 'nghỉ ngơi', 'nghỉ ngơi', null::jsonb, '"nghỉ ngơi": ngh trước i, dấu hỏi.', 'dau_hoi_nga', 18::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ sự vật?', 'bút mực', 'dễ thương', 'yêu quý', 'chào hỏi', 'bút mực', null::jsonb, 'Bút mực là đồ vật nên là từ chỉ sự vật.', 'tu_chi_su_vat', 20::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG phải từ chỉ sự vật?', 'thầy cô', 'y tá', 'giày dép', 'xanh tươi', 'xanh tươi', null::jsonb, '"xanh tươi" chỉ đặc điểm, không chỉ sự vật.', 'tu_chi_su_vat', 20::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ cây cối?', 'con ngan', 'cây nhãn', 'búp bê', 'cái trống', 'cây nhãn', null::jsonb, 'Cây nhãn là cây cối.', 'tu_chi_su_vat', 19::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ con vật?', 'ghế đá', 'em bé', 'chim én', 'cây vải', 'chim én', null::jsonb, 'Chim én là con vật.', 'tu_chi_su_vat', 19::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai là gì?', 'Hương là bạn thân của em.', 'Chả là hôm qua nó bị ốm.', 'Người ta gọi chàng là Sơn Tinh.', 'Thế là trong lớp chỉ còn Lan viết bút chì.', 'Hương là bạn thân của em.', null::jsonb, 'Câu "Hương là bạn thân của em" giới thiệu Hương là ai.', 'cau_ai_la_gi', 20::int),
    (2::smallint, 'multiple_choice', 'Trong câu "Bạn Chi là con ngoan, trò giỏi.", bộ phận trả lời câu hỏi "Là gì?" là:', 'Bạn Chi', 'Bạn Chi là', 'con ngoan, trò giỏi', null, 'con ngoan, trò giỏi', null::jsonb, 'Bộ phận đứng sau từ "là": con ngoan, trò giỏi.', 'cau_ai_la_gi', 20::int),
    (2::smallint, 'multiple_choice', 'Trong câu "Hoa Mơ là cô gà mái đẹp nhất trong đàn gà nhà em.", bộ phận trả lời câu hỏi "Con gì?" là:', 'cô gà mái', 'đàn gà nhà em', 'đẹp nhất', 'Hoa Mơ', 'Hoa Mơ', null::jsonb, 'Bộ phận đứng trước từ "là": Hoa Mơ.', 'cau_ai_la_gi', 20::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho đúng: "quả nhan" → quả ___', null, null, null, null, 'nhãn', null::jsonb, 'Quả nhãn (dấu ngã).', 'dau_hoi_nga', 18::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho đúng: "khuyên nhu" → khuyên ___', null, null, null, null, 'nhủ', null::jsonb, 'Khuyên nhủ (dấu hỏi).', 'dau_hoi_nga', 18::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho đúng: "ngoan ngoan" → ___', null, null, null, null, 'ngoan ngoãn', null::jsonb, 'Ngoan ngoãn (dấu ngã).', 'dau_hoi_nga', 18::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng điền vào chỗ trống: "phá cỗ ___ thu"', 'chung', 'trung', 'truông', null, 'trung', null::jsonb, 'Tết Trung thu.', 'chinh_ta_ch_tr', 18::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng điền vào chỗ trống: "chim bay ___ cành"', 'chuyền', 'truyền', 'chiền', null, 'chuyền', null::jsonb, 'Chim bay chuyền cành.', 'chinh_ta_ch_tr', 18::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Trong khu vườn nọ có Kiến, Ong, Bướm, Chuồn Chuồn, Chim Sâu chơi với nhau rất thân. Sẻ cũng sống ở đó nhưng nó tự cho mình là thông minh, tài giỏi, hiểu biết hơn cả nên không muốn làm bạn với ai trong vườn mà chỉ kết bạn với Quạ."
Sẻ tự cho mình là người như thế nào?', 'thông minh, nhanh nhẹn, giỏi giang', 'thông minh, tài giỏi, hiểu biết', 'thông minh, hiểu biết, chăm chỉ', null, 'thông minh, tài giỏi, hiểu biết', null::jsonb, 'Sẻ tự cho mình là thông minh, tài giỏi, hiểu biết.', 'doc_hieu', 22::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một hôm, đôi bạn đang đứng ở cây đa đầu làng thì bỗng một viên đạn bay trúng Sẻ. Sẻ hoảng hốt kêu la đau đớn. Sợ quá, Quạ vội bay đi mất."
Khi Sẻ bị thương, Quạ đã làm gì?', 'Quạ giúp đỡ Sẻ.', 'Quạ gọi các bạn đến giúp Sẻ.', 'Quạ vội bay đi mất.', null, 'Quạ vội bay đi mất.', null::jsonb, 'Sợ quá, Quạ vội bay đi mất.', 'doc_hieu', 22::int),
    (2::smallint, 'multiple_choice', 'Nhóm từ nào chỉ gồm những từ chỉ sự vật?', 'Quạ, Chim Sẻ, Chim Sâu, Ong', 'nhà, Chuồn Chuồn, Kiến, tốt bụng', 'ngoan ngoãn, Quạ, Chim Sẻ, xinh đẹp', null, 'Quạ, Chim Sẻ, Chim Sâu, Ong', null::jsonb, '"tốt bụng", "ngoan ngoãn", "xinh đẹp" không phải từ chỉ sự vật.', 'tu_chi_su_vat', 22::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chuồn Chuồn thấy Sẻ bị thương liền gọi Ong, Bướm đi tìm thuốc, còn Kiến và Chim Sâu đi tìm thức ăn cho Sẻ. Khi tỉnh dậy, Sẻ ngạc nhiên thấy bên cạnh mình không phải là Quạ mà là các bạn trong vườn. Sẻ xấu hổ nói lời xin lỗi và cảm ơn các bạn."
Theo em, vì sao Sẻ thấy xấu hổ?', 'Vì Sẻ không cẩn thận nên bị trúng đạn', 'Vì Sẻ từng coi thường các bạn đã hết lòng giúp mình', 'Vì Sẻ đã kết bạn với Quạ', null, 'Vì Sẻ từng coi thường các bạn đã hết lòng giúp mình', null::jsonb, 'Sẻ không chịu kết bạn với các bạn trong vườn, vậy mà các bạn vẫn hết lòng cứu Sẻ.', 'doc_hieu', 22::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp các câu tả con ngan nhỏ:
a. Nó có bộ lông vàng óng.
b. Con ngan nhỏ mới nở được ba hôm, trông chỉ to hơn quả trứng một tí.
c. Nhưng đẹp nhất là đôi mắt với cái mỏ.
d. Đôi mắt chỉ bằng hột cườm, đen nhánh hạt huyền.
Thứ tự đúng là:', 'a, b, c, d', 'b, c, a, d', 'a, c, b, d', 'b, a, c, d', 'b, a, c, d', null::jsonb, 'Giới thiệu con ngan (b), tả bộ lông (a), rồi nói đẹp nhất là mắt (c) và tả đôi mắt (d).', 'sap_xep_cau', 21::int),
    (3::smallint, 'multiple_choice', 'Các câu của câu chuyện "Cò và Vạc" bị xáo trộn:
- Cò ngoan ngoãn, chăm chỉ học tập, được thầy yêu bạn mến.
- Còn Vạc đành chịu dốt.
- Sợ chúng bạn chê cười, đêm đến Vạc mới dám bay đi kiếm ăn.
- Cò và Vạc là hai anh em nhưng tính nết rất khác nhau.
- Cò khuyên bảo em nhiều lần nhưng Vạc chẳng nghe.
Câu nào nên đặt ĐẦU TIÊN?', 'Còn Vạc đành chịu dốt.', 'Cò khuyên bảo em nhiều lần nhưng Vạc chẳng nghe.', 'Cò ngoan ngoãn, chăm chỉ học tập, được thầy yêu bạn mến.', 'Cò và Vạc là hai anh em nhưng tính nết rất khác nhau.', 'Cò và Vạc là hai anh em nhưng tính nết rất khác nhau.', null::jsonb, 'Câu mở đầu giới thiệu hai nhân vật Cò và Vạc.', 'sap_xep_cau', 23::int),
    (3::smallint, 'multiple_choice', 'Các câu của câu chuyện "Cò và Vạc" bị xáo trộn:
- Cò ngoan ngoãn, chăm chỉ học tập, được thầy yêu bạn mến.
- Còn Vạc đành chịu dốt.
- Sợ chúng bạn chê cười, đêm đến Vạc mới dám bay đi kiếm ăn.
- Cò và Vạc là hai anh em nhưng tính nết rất khác nhau.
- Cò khuyên bảo em nhiều lần nhưng Vạc chẳng nghe.
Câu nào nên đặt CUỐI CÙNG?', 'Cò ngoan ngoãn, chăm chỉ học tập, được thầy yêu bạn mến.', 'Cò và Vạc là hai anh em nhưng tính nết rất khác nhau.', 'Sợ chúng bạn chê cười, đêm đến Vạc mới dám bay đi kiếm ăn.', 'Cò khuyên bảo em nhiều lần nhưng Vạc chẳng nghe.', 'Sợ chúng bạn chê cười, đêm đến Vạc mới dám bay đi kiếm ăn.', null::jsonb, 'Vạc chịu dốt, sợ bạn chê cười nên đêm mới dám đi kiếm ăn: đó là kết thúc câu chuyện.', 'sap_xep_cau', 23::int),
    (3::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'che trở', 'châu báu', 'nghe ngóng', 'ngơ ngác', 'che trở', null::jsonb, 'Viết đúng là "che chở".', 'chinh_ta_ch_tr', 23::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "Con trâu" trong câu "Con trâu là đầu cơ nghiệp."', 'Con trâu là gì?', 'Con gì là đầu cơ nghiệp?', 'Con trâu làm gì?', 'Con trâu thế nào?', 'Con gì là đầu cơ nghiệp?', null::jsonb, 'Hỏi cho con vật đứng trước "là" dùng "Con gì?".', 'cau_ai_la_gi', 23::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "ngọn gió của con suốt đời" trong câu "Mẹ là ngọn gió của con suốt đời."', 'Ai là ngọn gió của con suốt đời?', 'Mẹ làm gì?', 'Mẹ là gì?', 'Mẹ thế nào?', 'Mẹ là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 23::int),
    (3::smallint, 'multiple_choice', 'Hai dòng thơ: "Cửa sổ là mắt của nhà / Nhìn lên trời rộng, nhìn ra sông dài." Dòng nào gồm các từ chỉ sự vật trong hai dòng thơ?', 'cửa sổ, nhìn, rộng, dài', 'mắt, nhìn lên, sông dài', 'nhà, trời, rộng, dài', 'cửa sổ, mắt, nhà, trời, sông', 'cửa sổ, mắt, nhà, trời, sông', null::jsonb, '"nhìn" là hoạt động; "rộng", "dài" là đặc điểm.', 'tu_chi_su_vat', 23::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 3 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 4: Bạn bè – Từ chỉ sự vật, từ ngữ về ngày tháng năm, r/d/gi, iên/yên, ân/âng (35 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 4, 100, 'Archimes: Bạn bè – Từ chỉ sự vật, từ ngữ về ngày tháng năm, r/d/gi, iên/yên, ân/âng', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 4', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền r, d hay gi: ___ễ cây', null, null, null, null, 'r', null::jsonb, 'Rễ cây.', 'chinh_ta_r_d_gi', 24::int),
    (1::smallint, 'text', 'Điền r, d hay gi: ___ảng bài', null, null, null, null, 'gi', null::jsonb, 'Giảng bài.', 'chinh_ta_r_d_gi', 24::int),
    (1::smallint, 'text', 'Điền r, d hay gi: ___ạy học', null, null, null, null, 'd', null::jsonb, 'Dạy học.', 'chinh_ta_r_d_gi', 24::int),
    (1::smallint, 'text', 'Điền r, d hay gi: tôm ___ang', null, null, null, null, 'r', null::jsonb, 'Tôm rang.', 'chinh_ta_r_d_gi', 24::int),
    (1::smallint, 'text', 'Điền iên hay yên (thêm dấu thanh nếu cần): "Giữ ___ hải đảo"', null, null, null, null, 'yên', null::jsonb, 'Giữ yên hải đảo: đứng đầu tiếng viết "yên".', 'chinh_ta_ien_yen', 24::int),
    (1::smallint, 'text', 'Điền iên hay yên (thêm dấu thanh nếu cần): "B___ khơi xanh thẳm"', null, null, null, null, 'iển', null::jsonb, 'Biển khơi: có âm đầu b nên viết "iên", thêm dấu hỏi.', 'chinh_ta_ien_yen', 24::int),
    (1::smallint, 'text', 'Điền ân hay âng (thêm dấu thanh nếu cần): v___ trăng', null, null, null, null, 'ầng', null::jsonb, 'Vầng trăng.', 'chinh_ta_an_ang', 25::int),
    (1::smallint, 'text', 'Điền ân hay âng (thêm dấu thanh nếu cần): kiên nh___', null, null, null, null, 'ẫn', null::jsonb, 'Kiên nhẫn.', 'chinh_ta_an_ang', 25::int),
    (1::smallint, 'number', 'Một năm có ___ tháng.', null, null, null, null, '12', null::jsonb, 'Một năm có 12 tháng.', 'ngay_thang_nam', 26::int),
    (1::smallint, 'number', 'Một tuần có ___ ngày.', null, null, null, null, '7', null::jsonb, 'Một tuần có 7 ngày: từ thứ Hai đến Chủ nhật.', 'ngay_thang_nam', 26::int),
    (1::smallint, 'multiple_choice', 'Ngày nào là ngày Quốc tế Thiếu nhi?', 'ngày 8 tháng 3', 'ngày 20 tháng 11', 'ngày 1 tháng 6', 'ngày 2 tháng 9', 'ngày 1 tháng 6', null::jsonb, 'Ngày 1 tháng 6 là ngày Quốc tế Thiếu nhi.', 'ngay_thang_nam', 28::int),
    (1::smallint, 'multiple_choice', 'Giải câu đố: "Con gì sống ở trong hang / Hai càng, tám cẳng bò ngang suốt đời?"', 'con tôm', 'con ốc', 'con cá', 'con cua', 'con cua', null::jsonb, 'Con cua có hai càng, tám cẳng, bò ngang.', 'cau_do', 28::int),
    (1::smallint, 'text', 'Điền l hay n: "___ong lanh đáy nước in trời"', null, null, null, null, 'l', null::jsonb, 'Long lanh.', 'chinh_ta_l_n', 33::int),
    (1::smallint, 'text', 'Điền s hay x: "Bầu trời ___ám xịt như sà xuống sát tận chân trời."', null, null, null, null, 'x', null::jsonb, 'Xám xịt.', 'chinh_ta_s_x', 33::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Hoa gì chỉ nở vào hè / Từng chùm đỏ thắm, gọi ve hát mừng?"', 'hoa sen', 'hoa phượng', 'hoa đào', 'hoa mai', 'hoa phượng', null::jsonb, 'Hoa phượng nở đỏ thắm vào mùa hè, khi ve kêu.', 'cau_do', 28::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Chẳng ai biết mặt ra sao / Chỉ nghe tiếng thét trên cao ầm ầm."', 'sấm', 'mưa', 'gió', 'mây', 'sấm', null::jsonb, 'Sấm kêu ầm ầm trên trời.', 'cau_do', 28::int),
    (2::smallint, 'multiple_choice', 'Ngày Quốc tế Phụ nữ là ngày nào?', 'ngày 1 tháng 6', 'ngày 20 tháng 11', 'ngày 2 tháng 9', 'ngày 8 tháng 3', 'ngày 8 tháng 3', null::jsonb, 'Ngày 8 tháng 3 là ngày Quốc tế Phụ nữ.', 'ngay_thang_nam', 27::int),
    (2::smallint, 'text', 'Sửa từ viết sai chính tả: "sai sưa" → ___', null, null, null, null, 'say sưa', null::jsonb, 'Viết đúng là "say sưa".', 'chinh_ta', 25::int),
    (2::smallint, 'text', 'Sửa từ viết sai chính tả: "chia xẻ" → ___', null, null, null, null, 'chia sẻ', null::jsonb, 'Viết đúng là "chia sẻ".', 'chinh_ta_s_x', 25::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'chí nhớ', 'hát du', 'trí nhớ', 'rám sát', 'trí nhớ', null::jsonb, 'Viết đúng: trí nhớ, hát ru, giám sát.', 'chinh_ta', 25::int),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ người (nghề nghiệp)?', 'bác sĩ', 'chim sâu', 'cây táo', 'thước kẻ', 'bác sĩ', null::jsonb, 'Bác sĩ là từ chỉ người.', 'tu_chi_su_vat', 26::int),
    (2::smallint, 'multiple_choice', 'Dãy từ: máy giặt, bóng điện, hoa cúc, quạt trần, ấm điện, tủ lạnh. Từ nào không cùng nhóm?', 'bóng điện', 'hoa cúc', 'quạt trần', 'tủ lạnh', 'hoa cúc', null::jsonb, 'Hoa cúc là cây cối; các từ còn lại là đồ vật.', 'tu_chi_su_vat', 31::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một hôm, Kiến khát quá bèn bò xuống suối uống nước. Chẳng may trượt chân ngã, Kiến bị dòng nước cuốn đi. Chim Gáy đậu trên cây, thấy Kiến bị nạn liền bay đi cắp một cành cây khô thả xuống dòng nước để cứu. Kiến bám vào cành cây, thoát chết."
Kiến bị dòng suối cuốn đi vì lí do gì?', 'Kiến đi kiếm ăn, bị trượt ngã xuống suối.', 'Kiến bị gió thổi ngã xuống suối.', 'Kiến xuống suối uống nước, bị trượt ngã.', null, 'Kiến xuống suối uống nước, bị trượt ngã.', null::jsonb, 'Kiến khát nước, bò xuống suối uống và bị trượt chân.', 'doc_hieu', 30::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một hôm, Kiến khát quá bèn bò xuống suối uống nước. Chẳng may trượt chân ngã, Kiến bị dòng nước cuốn đi. Chim Gáy đậu trên cây, thấy Kiến bị nạn liền bay đi cắp một cành cây khô thả xuống dòng nước để cứu. Kiến bám vào cành cây, thoát chết."
Thấy Kiến gặp nạn, Chim Gáy đã làm gì?', 'Bay đi gọi người đến cứu Kiến', 'Cắp cành cây khô thả xuống suối để cứu Kiến', 'Sà xuống dòng suối để cứu Kiến', null, 'Cắp cành cây khô thả xuống suối để cứu Kiến', null::jsonb, 'Chim Gáy cắp cành cây khô thả xuống dòng nước.', 'doc_hieu', 30::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ít lâu sau, Chim Gáy đang đậu trên cây rỉa lông, không trông thấy người đi săn nấp trong bụi cây. Người đi săn giương cung, lắp tên... Kiến thấy Chim Gáy gặp nguy, vội vàng đến đốt thật đau vào chân người đi săn."
Thấy Chim Gáy sắp gặp nguy hiểm, Kiến đã làm gì?', 'Đốt thật đau vào chân người đi săn', 'Đốt vào tay người bắn chim', 'Kêu thật to cho người đi săn giật mình', null, 'Đốt thật đau vào chân người đi săn', null::jsonb, 'Kiến đốt thật đau vào chân người đi săn.', 'doc_hieu', 30::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mải chơi, Ve Sầu đến lớp trễ, thầy giáo đã dạy đến chữ e. Vừa ghi xong chữ e, nó hí hửng chạy ra sân. Dế Mèn vào lớp, thầy đang dạy chữ i, nó ghi chữ i vào vở rồi lao ra. Từ đấy, chúng bỏ học, đi chơi. Vì vậy, cả đời chúng chỉ biết mỗi một chữ."
Tại sao Ve Sầu đến lớp trễ?', 'Vì mải chơi', 'Vì ngủ dậy muộn', 'Vì đi lạc đường', null, 'Vì mải chơi', null::jsonb, 'Bài đọc: "Mải chơi, Ve Sầu đến lớp trễ".', 'doc_hieu', 32::int),
    (2::smallint, 'multiple_choice', 'Câu nào được viết theo kiểu Ai là gì?', 'Thầy giáo đã dạy đến chữ e.', 'Ve Sầu và Dế Mèn là học sinh mới.', 'Ve Sầu ra rả đọc mãi một chữ e.', null, 'Ve Sầu và Dế Mèn là học sinh mới.', null::jsonb, 'Câu giới thiệu "Ve Sầu và Dế Mèn là học sinh mới".', 'cau_ai_la_gi', 32::int),
    (2::smallint, 'multiple_choice', 'Có thể thay từ "ghi" trong câu "Nó ghi chữ i vào vở rồi lao ra." bằng từ nào?', 'tô', 'vẽ', 'viết', null, 'viết', null::jsonb, '"ghi" chữ vào vở cũng là "viết".', 'tu_cung_nghia', 32::int),
    (3::smallint, 'multiple_choice', 'Từ nào có thể thay cho từ "nấp" trong câu "Người đi săn nấp trong bụi cây."?', 'tránh', 'núp', 'chạy', null, 'núp', null::jsonb, '"nấp" và "núp" cùng nghĩa: ẩn mình để người khác không thấy.', 'tu_cung_nghia', 30::int),
    (3::smallint, 'multiple_choice', 'Trong truyện "Kiến và Chim Gáy", Chim Gáy cứu Kiến khỏi dòng suối, sau đó Kiến cứu Chim Gáy khỏi người đi săn. Chim Gáy và Kiến đều có điểm gì tốt?', 'Biết tự vượt qua nguy hiểm', 'Đoàn kết chống lại kẻ thù', 'Biết giúp đỡ bạn khi bạn gặp nạn', null, 'Biết giúp đỡ bạn khi bạn gặp nạn', null::jsonb, 'Cả hai đều ra tay cứu bạn khi bạn gặp nạn.', 'doc_hieu', 30::int),
    (3::smallint, 'multiple_choice', 'Dãy từ: bằng lăng, hồng xiêm, phượng vĩ, cá chép, xoan đào, sầu riêng. Bỏ từ không cùng nhóm, các từ còn lại chỉ gì?', 'con vật', 'đồ vật', 'người', 'cây cối', 'cây cối', null::jsonb, 'Bỏ "cá chép", còn lại đều là tên cây.', 'tu_chi_su_vat', 31::int),
    (3::smallint, 'multiple_choice', 'Ngắt đoạn sau thành 3 câu: "Long bị ốm và không đi học được bạn bè trong lớp đến thăm Long và chép bài giúp bạn ai cũng mong Long mau khoẻ để đến lớp học". Câu thứ hai bắt đầu bằng từ nào?', 'Trong lớp', 'Ai cũng', 'Long', 'Bạn bè', 'Bạn bè', null::jsonb, 'Ba câu: Long bị ốm và không đi học được. Bạn bè trong lớp đến thăm... Ai cũng mong...', 'dau_cau', 31::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mải chơi, Ve Sầu đến lớp trễ, thầy giáo đã dạy đến chữ e. Vừa ghi xong chữ e, nó hí hửng chạy ra sân. Dế Mèn vào lớp, thầy đang dạy chữ i, nó ghi chữ i vào vở rồi lao ra. Từ đấy, chúng bỏ học, đi chơi. Vì vậy, cả đời chúng chỉ biết mỗi một chữ."
Câu chuyện khuyên em điều gì?', 'Phải chăm chỉ, học đến nơi đến chốn', 'Nên đến lớp muộn một chút', 'Chỉ cần biết một chữ là đủ', null, 'Phải chăm chỉ, học đến nơi đến chốn', null::jsonb, 'Ve Sầu và Dế Mèn bỏ học nên cả đời chỉ biết một chữ.', 'doc_hieu', 32::int),
    (3::smallint, 'multiple_choice', 'Đoạn văn: "Ngày xưa có đôi bạn là Diệc và Cò (1) chúng thường cùng ở (2) cùng ăn (3) cùng làm việc và đi chơi cùng nhau."
Ô trống (1) cần điền dấu gì?', 'dấu phẩy', 'dấu chấm', 'dấu chấm hỏi', null, 'dấu chấm', null::jsonb, 'Sau "Diệc và Cò" là hết một câu kể, câu sau bắt đầu "Chúng thường...".', 'dau_cau', 33::int),
    (3::smallint, 'multiple_choice', 'Đoạn văn: "Ngày xưa có đôi bạn là Diệc và Cò (1) chúng thường cùng ở (2) cùng ăn (3) cùng làm việc và đi chơi cùng nhau."
Ô trống (2) cần điền dấu gì?', 'dấu chấm', 'dấu chấm hỏi', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách các từ ngữ cùng loại: cùng ở, cùng ăn, cùng làm việc.', 'dau_phay', 33::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 4 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 5: Trường học – Viết hoa tên riêng, câu Ai là gì?, mục lục sách, l/n, ia/ya, en/eng, i/iê (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 5, 100, 'Archimes: Trường học – Viết hoa tên riêng, câu Ai là gì?, mục lục sách, l/n, ia/ya, en/eng, i/iê', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 5', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Một người ___ mặt đi với một người đeo mặt nạ."', 'nạ', 'lã', 'lạ', null, 'lạ', null::jsonb, 'Người lạ mặt.', 'chinh_ta_l_n', 34::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Mẹ mong sao con lớn ___ mạnh khỏe."', 'nên', 'lên', 'lến', null, 'lên', null::jsonb, 'Lớn lên.', 'chinh_ta_l_n', 34::int),
    (1::smallint, 'text', 'Điền ia hay ya (thêm dấu thanh nếu cần): đêm khu___', null, null, null, null, 'ya', null::jsonb, 'Đêm khuya: sau u viết "ya".', 'chinh_ta_ia_ya', 34::int),
    (1::smallint, 'text', 'Điền ia hay ya (thêm dấu thanh nếu cần): cây m___', null, null, null, null, 'ía', null::jsonb, 'Cây mía.', 'chinh_ta_ia_ya', 34::int),
    (1::smallint, 'text', 'Điền ia hay ya (thêm dấu thanh nếu cần): phép ch___', null, null, null, null, 'ia', null::jsonb, 'Phép chia.', 'chinh_ta_ia_ya', 34::int),
    (1::smallint, 'text', 'Điền en hay eng (thêm dấu thanh nếu cần): hoa s___', null, null, null, null, 'en', null::jsonb, 'Hoa sen.', 'chinh_ta_en_eng', 34::int),
    (1::smallint, 'text', 'Điền en hay eng (thêm dấu thanh nếu cần): cái x___', null, null, null, null, 'ẻng', null::jsonb, 'Cái xẻng.', 'chinh_ta_en_eng', 34::int),
    (1::smallint, 'text', 'Điền i hay iê (thêm dấu thanh nếu cần): mực t___m', null, null, null, null, 'í', null::jsonb, 'Mực tím.', 'chinh_ta_i_ie', 34::int),
    (1::smallint, 'text', 'Điền i hay iê (thêm dấu thanh nếu cần): con k___n', null, null, null, null, 'iế', null::jsonb, 'Con kiến.', 'chinh_ta_i_ie', 34::int),
    (1::smallint, 'multiple_choice', 'Viết tên "sông cửu long" cho đúng thì cần viết hoa những tiếng nào?', 'cửu, long', 'sông, cửu, long', 'chỉ tiếng sông', 'chỉ tiếng cửu', 'cửu, long', null::jsonb, '"sông" là tên chung; "Cửu Long" là tên riêng nên viết hoa: sông Cửu Long.', 'ten_rieng', 35::int),
    (1::smallint, 'multiple_choice', 'Trong câu "Việt Nam có nhiều loài hoa đẹp: lan, huệ, hồng, đào, mai.", từ nào là tên riêng?', 'lan', 'huệ', 'hoa', 'Việt Nam', 'Việt Nam', null::jsonb, 'Việt Nam là tên riêng của đất nước nên viết hoa.', 'ten_rieng', 35::int),
    (1::smallint, 'multiple_choice', 'Viết tên người "cao bá quát" cho đúng thì cần viết hoa những tiếng nào?', 'chỉ tiếng cao', 'cả ba tiếng: cao, bá, quát', 'chỉ tiếng cao và quát', 'không viết hoa tiếng nào', 'cả ba tiếng: cao, bá, quát', null::jsonb, 'Tên người viết hoa chữ cái đầu của mỗi tiếng: Cao Bá Quát.', 'ten_rieng', 36::int),
    (2::smallint, 'multiple_choice', 'Viết "thủ đô hà nội" cho đúng thì cần viết hoa những tiếng nào?', 'thủ, đô, hà, nội', 'chỉ tiếng thủ', 'hà, nội', 'chỉ tiếng hà', 'hà, nội', null::jsonb, '"thủ đô" là tên chung; "Hà Nội" là tên riêng: thủ đô Hà Nội.', 'ten_rieng', 36::int),
    (2::smallint, 'multiple_choice', 'Viết tên "động phong nha kẻ bàng" cho đúng thì cần viết hoa những tiếng nào?', 'động, phong, nha, kẻ, bàng', 'chỉ tiếng phong', 'chỉ tiếng động và phong', 'phong, nha, kẻ, bàng', 'phong, nha, kẻ, bàng', null::jsonb, '"động" là tên chung; tên riêng là Phong Nha - Kẻ Bàng.', 'ten_rieng', 36::int),
    (2::smallint, 'multiple_choice', 'Câu ca dao "Rủ nhau xem cảnh Kiếm Hồ, / Xem cầu Thê Húc, xem chùa Ngọc Sơn" nói về cảnh đẹp ở đâu?', 'Hà Nội', 'Huế', 'Đà Nẵng', 'Hải Phòng', 'Hà Nội', null::jsonb, 'Hồ Gươm (Kiếm Hồ), cầu Thê Húc, đền Ngọc Sơn đều ở Hà Nội.', 'ten_rieng', 35::int),
    (2::smallint, 'multiple_choice', 'Đoạn văn: "Nhà tôi ở hà nội, cách Hồ Gươm không xa. Cầu Thê húc màu son dẫn vào đền ngọc sơn." Tên riêng nào đã viết đúng?', 'hà nội', 'Thê húc', 'ngọc sơn', 'Hồ Gươm', 'Hồ Gươm', null::jsonb, 'Phải sửa: Hà Nội, Thê Húc, Ngọc Sơn. Chỉ "Hồ Gươm" viết đúng.', 'ten_rieng', 36::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "Cô giáo" trong câu "Cô giáo là người mẹ thứ hai của em."', 'Cô giáo là ai?', 'Ai là người mẹ thứ hai của em?', 'Cô giáo làm gì?', 'Cô giáo thế nào?', 'Ai là người mẹ thứ hai của em?', null::jsonb, 'Hỏi cho người đứng trước "là" dùng "Ai?".', 'cau_ai_la_gi', 37::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "món ăn em yêu thích" trong câu "Gà rán là món ăn em yêu thích."', 'Cái gì là món ăn em yêu thích?', 'Gà rán thế nào?', 'Gà rán là gì?', 'Gà rán làm gì?', 'Gà rán là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 37::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai là gì?', 'Thỏ và Gấu là đôi bạn thân.', 'Thỏ và Gấu chơi trốn tìm.', 'Thỏ và Gấu rất vui vẻ.', 'Thỏ và Gấu chạy nhảy trong rừng.', 'Thỏ và Gấu là đôi bạn thân.', null::jsonb, 'Câu có từ "là" nối hai bộ phận, giới thiệu Thỏ và Gấu.', 'cau_ai_la_gi', 37::int),
    (2::smallint, 'multiple_choice', 'Mục lục sách gồm hai phần chính nào?', 'tên tác giả và ảnh', 'lời nói đầu và bìa sách', 'tên bài và số trang', 'nhà xuất bản và giá tiền', 'tên bài và số trang', null::jsonb, 'Mục lục gồm tên bài và số trang tương ứng.', 'muc_luc_sach', 37::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Hôm nay, một ngày cuối thu đầy nắng. Gió chạy khắp sân trường gọi lá bàng háo hức. Nắng nhảy nhót trên những tán lá bàng xanh, làm tươi lên cái áo vôi vàng của ngôi trường."
Đoạn văn tả gió và nắng thế nào?', 'Gió chạy khắp sân trường; nắng nhảy nhót trên lá bàng', 'Gió gọi lá bàng; nắng chạy khắp sân trường', 'Gió nhảy nhót; nắng gọi lá bàng háo hức', null, 'Gió chạy khắp sân trường; nắng nhảy nhót trên lá bàng', null::jsonb, 'Gió chạy khắp sân trường, nắng nhảy nhót trên những tán lá bàng.', 'doc_hieu', 39::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Tùng! Tùng! Tùng... Tiếng gọi đầm ấm của bác trống già vang lên. Học sinh dồn cả về phía sân trường. Tiếng hát cất lên, dồn dập trong tiếng vỗ tay. Kết thúc bài hát, giọng cô giáo ngân vang."
Đoạn văn tả những âm thanh nào?', 'tiếng trống, tiếng hát, tiếng chân đi, tiếng vỗ tay', 'tiếng trống, tiếng hát, tiếng vỗ tay, tiếng cô giáo', 'tiếng trống, tiếng cô giáo, tiếng chim hót', null, 'tiếng trống, tiếng hát, tiếng vỗ tay, tiếng cô giáo', null::jsonb, 'Có tiếng trống, tiếng hát, tiếng vỗ tay và giọng cô giáo.', 'doc_hieu', 39::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Cây gì không lá không hoa / Sáng ngày sinh nhật, cả nhà vây quanh."', 'cây thông', 'cây hoa', 'cây cảnh', 'cây nến', 'cây nến', null::jsonb, 'Cây nến cắm trên bánh sinh nhật.', 'cau_do', 40::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'nung tung', 'lung nấu', 'nung linh', 'lung tung', 'lung tung', null::jsonb, 'Viết đúng: lung tung, lung linh, nung nấu.', 'chinh_ta_l_n', 40::int),
    (2::smallint, 'text', 'Điền i hay iê (thêm dấu thanh nếu cần): "V___t Nam đất nước ta ơi!"', null, null, null, null, 'iệ', null::jsonb, 'Việt Nam.', 'chinh_ta_i_ie', 34::int),
    (2::smallint, 'number', 'Các bài tập đọc tuần 4 nói về "Bạn bè": trang 31 có bài "Bím tóc đuôi sam", bài "Trên chiếc bè" ở trang 34, còn trang 36 có bài "Mít làm thơ". Bài "Trên chiếc bè" ở trang ___.', null, null, null, null, '34', null::jsonb, 'Bài "Trên chiếc bè" ở trang 34.', 'muc_luc_sach', 38::int),
    (3::smallint, 'multiple_choice', 'Đoạn trích "Đón ngày khai trường" kết thúc bằng lời cô giáo: "Ngày mai, chúng ta sẽ khai trường, bắt đầu một năm học mới!". Đoạn trích miêu tả cảnh gì?', 'Học sinh vui chơi trong ngày khai trường', 'Sân trường đầy nắng, gió', 'Học sinh vui chơi, háo hức chờ đón ngày khai trường', null, 'Học sinh vui chơi, háo hức chờ đón ngày khai trường', null::jsonb, 'Ngày mai mới khai trường, nên đây là cảnh háo hức chuẩn bị đón ngày khai trường.', 'doc_hieu', 39::int),
    (3::smallint, 'multiple_choice', 'Đoạn văn: "Tên của mình là Nguyễn Hà Phương Chi. Mình sinh ra tại Hải Phòng. Mình còn say mê vẽ tranh." Câu nào thuộc kiểu câu Ai là gì?', 'Tên của mình là Nguyễn Hà Phương Chi.', 'Mình sinh ra tại Hải Phòng.', 'Mình còn say mê vẽ tranh.', null, 'Tên của mình là Nguyễn Hà Phương Chi.', null::jsonb, 'Câu có từ "là" giới thiệu tên của bạn.', 'cau_ai_la_gi', 40::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp tiếng đúng: "Thanh ___ lẽ bê bao gạo rất ___."', 'nặng – lặng', 'lặng – nặng', 'lặng – lặng', 'nặng – nặng', 'lặng – nặng', null::jsonb, 'Thanh lặng lẽ bê bao gạo rất nặng.', 'chinh_ta_l_n', 34::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp tiếng đúng: "Tôi uống ngon ___ một cốc sữa đậu ___."', 'nành – lành', 'lành – lành', 'lành – nành', 'nành – nành', 'lành – nành', null::jsonb, 'Tôi uống ngon lành một cốc sữa đậu nành.', 'chinh_ta_l_n', 34::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "Hải Anh" trong câu "Hải Anh là người hát hay nhất lớp em."', 'Hải Anh là ai?', 'Hải Anh làm gì?', 'Hải Anh hát thế nào?', 'Ai là người hát hay nhất lớp em?', 'Ai là người hát hay nhất lớp em?', null::jsonb, 'Hỏi cho người đứng trước "là" dùng "Ai?".', 'cau_ai_la_gi', 37::int),
    (3::smallint, 'multiple_choice', 'Câu "Việt Nam có nhiều loài hoa đẹp: lan, huệ, hồng, đào, mai." Vì sao "lan", "huệ" không viết hoa?', 'Vì đó là tên chung của loài hoa', 'Vì đó là tên riêng của người', 'Vì đó là tên thành phố', null, 'Vì đó là tên chung của loài hoa', null::jsonb, 'Tên chung của loài hoa không viết hoa; khi là tên người (bạn Lan, bạn Huệ) mới viết hoa.', 'ten_rieng', 35::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 5 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 6: Trường học – Câu Ai là gì?, từ ngữ về đồ dùng học tập, s/x, ai/ay, dấu hỏi/dấu ngã (35 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 6, 100, 'Archimes: Trường học – Câu Ai là gì?, từ ngữ về đồ dùng học tập, s/x, ai/ay, dấu hỏi/dấu ngã', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 6', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền s hay x: "Bé quét nhà cửa ___ạch sẽ quá!"', null, null, null, null, 's', null::jsonb, 'Sạch sẽ.', 'chinh_ta_s_x', 41::int),
    (1::smallint, 'text', 'Điền s hay x: "Mùi ___oài thơm dịu dàng, vị ngọt đậm đà."', null, null, null, null, 'x', null::jsonb, 'Quả xoài.', 'chinh_ta_s_x', 41::int),
    (1::smallint, 'text', 'Điền ai hay ay (thêm dấu thanh nếu cần): bàn t___', null, null, null, null, 'ay', null::jsonb, 'Bàn tay.', 'chinh_ta_ai_ay', 41::int),
    (1::smallint, 'text', 'Điền ai hay ay (thêm dấu thanh nếu cần): mười h___', null, null, null, null, 'ai', null::jsonb, 'Mười hai.', 'chinh_ta_ai_ay', 41::int),
    (1::smallint, 'text', 'Điền ai hay ay (thêm dấu thanh nếu cần): ngày m___', null, null, null, null, 'ai', null::jsonb, 'Ngày mai.', 'chinh_ta_ai_ay', 41::int),
    (1::smallint, 'text', 'Điền ai hay ay (thêm dấu thanh nếu cần): chê b___', null, null, null, null, 'ai', null::jsonb, 'Chê bai.', 'chinh_ta_ai_ay', 41::int),
    (1::smallint, 'text', 'Điền ai hay ay (thêm dấu thanh nếu cần): "Nụ hồng lớn lên m___ / Đợi đến ngày tỏa hương."', null, null, null, null, 'ãi', null::jsonb, 'Lớn lên mãi.', 'chinh_ta_ai_ay', 41::int),
    (1::smallint, 'multiple_choice', 'Giải câu đố: "Vừa mềm vừa bé bỏng thôi / Mà làm sạch vết mực rơi mới tài."', 'cái bút', 'thước kẻ', 'quyển vở', 'cục tẩy', 'cục tẩy', null::jsonb, 'Cục tẩy mềm, nhỏ, dùng để tẩy sạch vết bẩn.', 'cau_do', 43::int),
    (1::smallint, 'multiple_choice', 'Giải câu đố: "Suốt đời đi với học sinh / Sách vở bút thước trong mình tôi mang."', 'hộp bút', 'cặp sách', 'bảng con', 'quyển sách', 'cặp sách', null::jsonb, 'Cặp sách đựng sách vở, bút thước.', 'cau_do', 43::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ đồ dùng học tập?', 'bạn học', 'học kì', 'bảng con', 'học phí', 'bảng con', null::jsonb, 'Bảng con là đồ dùng học tập.', 'tu_ngu_do_dung_hoc_tap', 48::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ đồ dùng học tập?', 'năm học', 'bút chì', 'thước kẻ', 'hộp màu', 'năm học', null::jsonb, '"năm học" chỉ thời gian, không phải đồ dùng.', 'tu_ngu_do_dung_hoc_tap', 48::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngày đầu tiên đi học
Mẹ dắt tay đến trường
Em vừa đi vừa khóc
Mẹ dỗ dành yêu thương."
Ngày đầu tiên đi học, ai đưa bạn nhỏ tới trường?', 'bố và mẹ', 'mẹ và cô giáo', 'mẹ', null, 'mẹ', null::jsonb, '"Mẹ dắt tay đến trường."', 'doc_hieu', 45::int),
    (1::smallint, 'multiple_choice', 'Chọn từ đúng: "___ xắn"', 'xinh', 'sinh', 'xin', null, 'xinh', null::jsonb, 'Xinh xắn.', 'chinh_ta_s_x', 48::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Cái gì dài một gang tay / Bé vẽ, bé viết hằng ngày ngắn đi?"', 'thước kẻ', 'bút chì', 'cục tẩy', 'bút mực', 'bút chì', null::jsonb, 'Bút chì càng viết, càng gọt thì càng ngắn đi.', 'cau_do', 43::int),
    (2::smallint, 'text', 'Điền dấu hỏi hoặc dấu ngã: "Mở hộp thịt ra chỉ thấy toàn mơ." → toàn ___', null, null, null, null, 'mỡ', null::jsonb, 'Toàn mỡ (dấu ngã).', 'dau_hoi_nga', 41::int),
    (2::smallint, 'text', 'Điền dấu hỏi hoặc dấu ngã: "Anh phải nghi đến chuyện nghỉ ngơi." → Anh phải ___ đến chuyện nghỉ ngơi.', null, null, null, null, 'nghĩ', null::jsonb, 'Suy nghĩ (dấu ngã), khác với nghỉ ngơi (dấu hỏi).', 'dau_hoi_nga', 41::int),
    (2::smallint, 'text', 'Điền dấu hỏi hoặc dấu ngã: "Ngôi nhà nho trên thảo nguyên." → Ngôi nhà ___ trên thảo nguyên.', null, null, null, null, 'nhỏ', null::jsonb, 'Nhỏ (dấu hỏi).', 'dau_hoi_nga', 41::int),
    (2::smallint, 'text', 'Sửa từ viết sai: "Tường vôi chẳng, cánh cửa xanh." → Tường vôi ___', null, null, null, null, 'trắng', null::jsonb, 'Tường vôi trắng.', 'chinh_ta_ch_tr', 42::int),
    (2::smallint, 'text', 'Sửa từ viết sai: "bàn ghế ghỗ xoan đào" → bàn ghế ___ xoan đào', null, null, null, null, 'gỗ', null::jsonb, 'Viết g trước ô: gỗ.', 'chinh_ta_g_gh', 42::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "đôi bạn thân" trong câu "Chim Sẻ và Sáo Nâu là đôi bạn thân."', 'Ai là đôi bạn thân?', 'Chim Sẻ và Sáo Nâu làm gì?', 'Chim Sẻ và Sáo Nâu thế nào?', 'Chim Sẻ và Sáo Nâu là gì?', 'Chim Sẻ và Sáo Nâu là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 42::int),
    (2::smallint, 'multiple_choice', 'Trong câu "Ông tôi là một bác sĩ đã về hưu.", bộ phận trả lời câu hỏi "Là gì?" là:', 'Ông tôi', 'đã về hưu', 'Ông tôi là', 'một bác sĩ đã về hưu', 'một bác sĩ đã về hưu', null::jsonb, 'Bộ phận đứng sau từ "là".', 'cau_ai_la_gi', 42::int),
    (2::smallint, 'multiple_choice', 'Trong câu "Sông Hồng và sông Cửu Long là hai con sông lớn của nước ta.", bộ phận trả lời câu hỏi "Cái gì?" là:', 'hai con sông lớn', 'nước ta', 'Sông Hồng và sông Cửu Long', 'hai con sông lớn của nước ta', 'Sông Hồng và sông Cửu Long', null::jsonb, 'Bộ phận đứng trước từ "là".', 'cau_ai_la_gi', 42::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngày đầu tiên đi học
Mẹ dắt tay đến trường
Em vừa đi vừa khóc
Mẹ dỗ dành yêu thương."
Hình ảnh bạn nhỏ ngày đầu tiên đi học như thế nào?', 'vừa đi vừa khóc', 'tươi vui, phấn khởi', 'rụt rè nép sau lưng mẹ', null, 'vừa đi vừa khóc', null::jsonb, '"Em vừa đi vừa khóc."', 'doc_hieu', 45::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngày đầu tiên đi học
Em mắt ướt nhạt nhòa
Cô vỗ về an ủi
Chao ôi! Sao thiết tha."
Cô giáo đã làm gì khi thấy bạn nhỏ khóc?', 'dỗ dành yêu thương', 'vỗ về an ủi', 'dắt tay vào lớp', null, 'vỗ về an ủi', null::jsonb, '"Cô vỗ về an ủi."', 'doc_hieu', 45::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngày đầu như thế đó
Cô giáo như mẹ hiền
Em bây giờ cứ ngỡ
Cô giáo là cô tiên."
Cô giáo được so sánh với ai?', 'người mẹ thứ hai', 'bà tiên', 'mẹ hiền, cô tiên', null, 'mẹ hiền, cô tiên', null::jsonb, 'Cô giáo như mẹ hiền, em ngỡ cô giáo là cô tiên.', 'doc_hieu', 45::int),
    (2::smallint, 'multiple_choice', 'Dòng nào gồm các từ chỉ sự vật?', 'đi học, bàn, ghế, viết bài', 'trường, cô giáo, sách, bút, thước kẻ', 'ngoan ngoãn, thông minh, chăm chỉ', null, 'trường, cô giáo, sách, bút, thước kẻ', null::jsonb, 'Trường, cô giáo, sách, bút, thước kẻ đều là sự vật.', 'tu_chi_su_vat', 45::int),
    (2::smallint, 'text', 'Điền tr hay ch: "Những con tàu sơn ___ắng đậu san sát."', null, null, null, null, 'tr', null::jsonb, 'Màu trắng.', 'chinh_ta_ch_tr', 47::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "Chim trĩ" trong câu "Chim trĩ là nghệ sĩ múa tài ba."', 'Con gì là nghệ sĩ múa tài ba?', 'Chim trĩ là gì?', 'Chim trĩ làm gì?', 'Chim trĩ múa thế nào?', 'Con gì là nghệ sĩ múa tài ba?', null::jsonb, 'Hỏi cho con vật đứng trước "là" dùng "Con gì?".', 'cau_ai_la_gi', 48::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Áo em có đủ các màu / Thân em trắng muốt như nhau thẳng hàng / Mỏng dày là ở số trang / Lời thầy cô, kiến thức vàng trong em."', 'cái bút', 'cặp sách', 'bảng con', 'quyển vở', 'quyển vở', null::jsonb, 'Quyển vở có bìa nhiều màu, trang giấy trắng, ghi lời thầy cô giảng.', 'cau_do', 46::int),
    (3::smallint, 'multiple_choice', 'Mục lục (tên truyện – tác giả – trang):
1. Ông Trạng thả diều – Hà Ân – 5
2. Chuyện về một người thầy – Hà Ân – 14
3. Cậu bé xấu xí – Hà Ân – 22
4. Chuyện về một giấc mơ – Hà Ân – 30
5. Đôi guốc bỏ quên – Văn Biển – 39
6. Trước lăng mộ vua Quang Trung – An Cương – 66
7. Nàng tiên đảo Ngọc – Lý Biên Cương – 75
Nhà văn nào có 4 truyện trong đoạn mục lục trên?', 'Văn Biển', 'Hà Ân', 'Vũ Cao', 'Lý Biên Cương', 'Hà Ân', null::jsonb, 'Truyện 1, 2, 3, 4 đều của Hà Ân.', 'muc_luc_sach', 44::int),
    (3::smallint, 'number', 'Mục lục (tên truyện – tác giả – trang):
1. Ông Trạng thả diều – Hà Ân – 5
2. Chuyện về một người thầy – Hà Ân – 14
3. Cậu bé xấu xí – Hà Ân – 22
4. Chuyện về một giấc mơ – Hà Ân – 30
5. Đôi guốc bỏ quên – Văn Biển – 39
6. Trước lăng mộ vua Quang Trung – An Cương – 66
7. Nàng tiên đảo Ngọc – Lý Biên Cương – 75
Truyện "Trước lăng mộ vua Quang Trung" in ở trang ___.', null, null, null, null, '66', null::jsonb, 'Xem dòng số 6 của mục lục: trang 66.', 'muc_luc_sach', 44::int),
    (3::smallint, 'multiple_choice', 'Mục lục (tên truyện – tác giả – trang):
1. Ông Trạng thả diều – Hà Ân – 5
2. Chuyện về một người thầy – Hà Ân – 14
3. Cậu bé xấu xí – Hà Ân – 22
4. Chuyện về một giấc mơ – Hà Ân – 30
5. Đôi guốc bỏ quên – Văn Biển – 39
6. Trước lăng mộ vua Quang Trung – An Cương – 66
7. Nàng tiên đảo Ngọc – Lý Biên Cương – 75
Truyện in ở trang 75 là truyện nào?', 'Đôi guốc bỏ quên', 'Cậu bé xấu xí', 'Nàng tiên đảo Ngọc', 'Chuyện về một giấc mơ', 'Nàng tiên đảo Ngọc', null::jsonb, 'Dòng số 7: Nàng tiên đảo Ngọc – trang 75.', 'muc_luc_sach', 44::int),
    (3::smallint, 'multiple_choice', 'Đọc câu chuyện:
"Một chú bé đang chăn cừu bỗng giả vờ kêu toáng lên: - Sói! Sói! Cứu tôi với! Các bác nông dân tức tốc chạy tới nhưng chẳng thấy sói đâu. Chú bé còn nói dối như vậy mấy lần nữa. Cuối cùng, sói đến thật. Chú bé hoảng hốt gào xin cứu giúp. Các bác nông dân nghĩ chú nói dối như mọi lần nên vẫn thản nhiên làm việc."
Vì sao khi sói đến thật, không ai đến cứu chú bé?', 'Vì chú bé đã nói dối nhiều lần', 'Vì các bác nông dân ở quá xa', 'Vì chú bé kêu quá nhỏ', null, 'Vì chú bé đã nói dối nhiều lần', null::jsonb, 'Các bác nghĩ chú lại nói dối như mọi lần.', 'doc_hieu', 47::int),
    (3::smallint, 'multiple_choice', 'Đọc câu chuyện:
"Một chú bé đang chăn cừu bỗng giả vờ kêu toáng lên: - Sói! Sói! Cứu tôi với! Các bác nông dân tức tốc chạy tới nhưng chẳng thấy sói đâu. Chú bé còn nói dối như vậy mấy lần nữa. Cuối cùng, sói đến thật. Chú bé hoảng hốt gào xin cứu giúp. Các bác nông dân nghĩ chú nói dối như mọi lần nên vẫn thản nhiên làm việc."
Câu chuyện khuyên em điều gì?', 'Phải chăn cừu thật giỏi', 'Phải chạy thật nhanh khi thấy sói', 'Không được nói dối', null, 'Không được nói dối', null::jsonb, 'Nói dối nhiều lần thì khi nói thật cũng không ai tin.', 'doc_hieu', 47::int),
    (3::smallint, 'multiple_choice', 'Điền dấu câu: "Cò và Vạc là hai anh em nhưng tính nết rất khác nhau (1) Cò thì ngoan ngoãn (2) chăm chỉ học tập." Hai dấu cần điền lần lượt là:', 'dấu phẩy, dấu chấm', 'dấu phẩy, dấu phẩy', 'dấu chấm, dấu chấm', 'dấu chấm, dấu phẩy', 'dấu chấm, dấu phẩy', null::jsonb, 'Ô (1) kết thúc câu nên dùng dấu chấm; ô (2) ngăn cách "ngoan ngoãn" và "chăm chỉ học tập" nên dùng dấu phẩy.', 'dau_cau', 48::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 6 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 7: Thầy cô – Từ ngữ về môn học, từ chỉ hoạt động, tr/ch, iên/iêng, ui/uy (35 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 7, 100, 'Archimes: Thầy cô – Từ ngữ về môn học, từ chỉ hoạt động, tr/ch, iên/iêng, ui/uy', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 7', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền tr hay ch: "___ưa đến trưa mà trời đã nắng chang chang."', null, null, null, null, 'ch', null::jsonb, 'Chưa đến trưa.', 'chinh_ta_ch_tr', 49::int),
    (1::smallint, 'text', 'Điền tr hay ch: "Đó là một chàng ___ai nghèo nhưng rất tốt bụng."', null, null, null, null, 'tr', null::jsonb, 'Chàng trai.', 'chinh_ta_ch_tr', 49::int),
    (1::smallint, 'text', 'Điền tr hay ch: "Các bạn đang chơi chong chóng ___ong nhà."', null, null, null, null, 'tr', null::jsonb, 'Trong nhà.', 'chinh_ta_ch_tr', 49::int),
    (1::smallint, 'text', 'Điền iên hay iêng (thêm dấu thanh nếu cần): s___ năng', null, null, null, null, 'iêng', null::jsonb, 'Siêng năng.', 'chinh_ta_ien_ieng', 49::int),
    (1::smallint, 'text', 'Điền iên hay iêng (thêm dấu thanh nếu cần): bà t___', null, null, null, null, 'iên', null::jsonb, 'Bà tiên.', 'chinh_ta_ien_ieng', 49::int),
    (1::smallint, 'text', 'Điền iên hay iêng (thêm dấu thanh nếu cần): sầu r___', null, null, null, null, 'iêng', null::jsonb, 'Sầu riêng.', 'chinh_ta_ien_ieng', 49::int),
    (1::smallint, 'text', 'Điền ui hay uy (thêm dấu thanh nếu cần): lau ch___', null, null, null, null, 'ùi', null::jsonb, 'Lau chùi.', 'chinh_ta_ui_uy', 49::int),
    (1::smallint, 'text', 'Điền ui hay uy (thêm dấu thanh nếu cần): v___ vẻ', null, null, null, null, 'ui', null::jsonb, 'Vui vẻ.', 'chinh_ta_ui_uy', 49::int),
    (1::smallint, 'text', 'Điền ui hay uy (thêm dấu thanh nếu cần): kh___ áo', null, null, null, null, 'uy', null::jsonb, 'Khuy áo.', 'chinh_ta_ui_uy', 49::int),
    (1::smallint, 'multiple_choice', 'Từ nào gọi tên một môn học?', 'tô màu', 'tranh vẽ', 'cắt dán', 'Đạo đức', 'Đạo đức', null::jsonb, 'Đạo đức là tên một môn học.', 'tu_ngu_mon_hoc', 50::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ hoạt động?', 'quyển vở', 'xinh đẹp', 'chạy nhảy', 'cái bàn', 'chạy nhảy', null::jsonb, 'Chạy nhảy là hoạt động.', 'tu_chi_hoat_dong', 50::int),
    (1::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp (theo bài "Kể việc"): "Trâu ___ cỏ"', 'gặm', 'đâm', 'hái', 'gặt', 'gặm', null::jsonb, 'Trâu gặm cỏ.', 'tu_chi_hoat_dong', 50::int),
    (1::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp (theo bài "Kể việc"): "Tre ___ măng"', 'gặm', 'đâm', 'nhai', 'khóc', 'đâm', null::jsonb, 'Tre đâm măng.', 'tu_chi_hoat_dong', 50::int),
    (1::smallint, 'multiple_choice', 'Môn học dạy em biết làm phép tính, tính toán là môn nào?', 'Tiếng Việt', 'Mĩ thuật', 'Toán', 'Tự nhiên và Xã hội', 'Toán', null::jsonb, 'Môn Toán dạy tính toán.', 'tu_ngu_mon_hoc', 54::int),
    (1::smallint, 'multiple_choice', 'Chọn từ điền vào chỗ trống: "Đến trường học, em cần ___ thầy cô dạy bảo."', 'chạy', 'ngủ', 'hát', 'nghe', 'nghe', null::jsonb, 'Em cần nghe thầy cô dạy bảo.', 'tu_chi_hoat_dong', 51::int),
    (2::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp (theo bài "Kể việc"): "Bố ___ lúa"', 'gặt', 'gặm', 'ngậm', 'đâm', 'gặt', null::jsonb, 'Bố gặt lúa.', 'tu_chi_hoat_dong', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp (theo bài "Kể việc"): "Trai ___ ngọc"', 'nghiến', 'ngậm', 'gặt', 'hái', 'ngậm', null::jsonb, 'Trai ngậm ngọc.', 'tu_chi_hoat_dong', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp (theo bài "Kể việc"): "Cóc ___ răng"', 'ngậm', 'nghiến', 'hái', 'gặm', 'nghiến', null::jsonb, 'Cóc nghiến răng.', 'tu_chi_hoat_dong', 50::int),
    (2::smallint, 'multiple_choice', 'Nhờ môn học nào, em hiểu biết về thế giới tự nhiên?', 'Toán', 'Tiếng Việt', 'Tự nhiên và Xã hội', 'Âm nhạc', 'Tự nhiên và Xã hội', null::jsonb, 'Môn Tự nhiên và Xã hội giúp em hiểu về thế giới tự nhiên.', 'tu_ngu_mon_hoc', 54::int),
    (2::smallint, 'multiple_choice', 'Môn học giúp em thể hiện sự vật bằng nét vẽ và màu sắc là môn nào?', 'Âm nhạc', 'Đạo đức', 'Toán', 'Mĩ thuật', 'Mĩ thuật', null::jsonb, 'Môn Mĩ thuật dạy vẽ, tô màu.', 'tu_ngu_mon_hoc', 54::int),
    (2::smallint, 'text', 'Chuyển động ở trên không (như chim, máy bay) gọi là ___.', null, null, null, null, 'bay', null::jsonb, 'Chim, máy bay chuyển động trên không gọi là bay.', 'tu_chi_hoat_dong', 54::int),
    (2::smallint, 'text', 'Chuyển động trong nước hoặc trên mặt nước bằng cử động của cơ thể gọi là ___.', null, null, null, null, 'bơi', null::jsonb, 'Chuyển động trong nước là bơi.', 'tu_chi_hoat_dong', 54::int),
    (2::smallint, 'text', 'Tạo ra hình ảnh sự vật bằng đường nét, màu sắc gọi là ___.', null, null, null, null, 'vẽ', null::jsonb, 'Dùng nét và màu để tạo hình ảnh là vẽ.', 'tu_chi_hoat_dong', 54::int),
    (2::smallint, 'multiple_choice', 'Từ nào là từ chỉ hoạt động trong câu ca dao "Con mèo mà trèo cây cau"?', 'trèo', 'con mèo', 'cây cau', 'mà', 'trèo', null::jsonb, 'Trèo là hoạt động của con mèo.', 'tu_chi_hoat_dong', 51::int),
    (2::smallint, 'text', 'Sửa từ viết sai chính tả: "Chên nương, mỗi người một việc." → ___ nương', null, null, null, null, 'Trên', null::jsonb, 'Viết đúng là "Trên nương".', 'chinh_ta_ch_tr', 49::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chuồn Chuồn, Ong và Bướm là ba người bạn cùng sống trong một khu vườn. Trong khi Ong suốt ngày tìm hoa làm mật thì Chuồn Chuồn và Bướm cứ mải miết rong chơi. Chuồn Chuồn chế nhạo: - Cậu thật ngốc! Bướm chê bai: - Siêng năng thì ai khen đâu chứ!"
Câu chuyện kể về những con vật nào?', 'Chuồn Chuồn, Ong, Bướm', 'Ong và Bướm', 'Ong và Chuồn Chuồn', null, 'Chuồn Chuồn, Ong, Bướm', null::jsonb, 'Ba người bạn là Chuồn Chuồn, Ong và Bướm.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chuồn Chuồn, Ong và Bướm là ba người bạn cùng sống trong một khu vườn. Trong khi Ong suốt ngày tìm hoa làm mật thì Chuồn Chuồn và Bướm cứ mải miết rong chơi. Chuồn Chuồn chế nhạo: - Cậu thật ngốc! Bướm chê bai: - Siêng năng thì ai khen đâu chứ!"
Thấy Ong chăm chỉ, Chuồn Chuồn và Bướm có thái độ gì?', 'khen ngợi', 'chế nhạo, chê bai', 'cảm động, ân hận', null, 'chế nhạo, chê bai', null::jsonb, 'Chuồn Chuồn chế nhạo, Bướm chê bai.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ngày nọ, một cơn bão ập đến. Cây cỏ trong vườn bị tan hoang. Chuồn Chuồn và Bướm chẳng còn gì để ăn cả. Ong rủ: - Các cậu cùng về sống chung với tớ đi! Chuồn Chuồn rất cảm động: - Cảm ơn cậu! Chúng tớ ân hận lắm. Từ giờ chúng tớ sẽ chăm chỉ làm việc."
Khi cơn bão ập đến, Ong đã đối xử với hai bạn thế nào?', 'Bỏ mặc hai bạn', 'Cười nhạo, chê bai hai bạn', 'Rủ hai bạn về sống chung với mình', null, 'Rủ hai bạn về sống chung với mình', null::jsonb, 'Ong rủ: "Các cậu cùng về sống chung với tớ đi!"', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố: "Mặt em bóng nhẵn màu đen / Ngày ngày tô điểm mấy hàng chữ xinh."', 'quyển vở', 'cục tẩy', 'bút chì', 'bảng đen', 'bảng đen', null::jsonb, 'Bảng đen màu đen, ngày ngày cô viết chữ lên.', 'cau_do', 54::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ngày nọ, một cơn bão ập đến. Cây cỏ trong vườn bị tan hoang. Chuồn Chuồn và Bướm chẳng còn gì để ăn cả. Ong rủ: - Các cậu cùng về sống chung với tớ đi! Chuồn Chuồn rất cảm động: - Cảm ơn cậu! Chúng tớ ân hận lắm. Từ giờ chúng tớ sẽ chăm chỉ làm việc."
Được Ong giúp đỡ trong cơn hoạn nạn, Chuồn Chuồn thế nào?', 'thờ ơ, lạnh lùng', 'vui vẻ, chế nhạo', 'cảm động, ân hận', null, 'cảm động, ân hận', null::jsonb, 'Chuồn Chuồn rất cảm động và nói "Chúng tớ ân hận lắm".', 'doc_hieu', 53::int),
    (3::smallint, 'multiple_choice', 'Truyện "Ba người bạn": Ong chăm chỉ làm mật, bị Chuồn Chuồn và Bướm chê bai; khi bão đến, Ong vẫn rủ hai bạn về sống chung. Câu chuyện khuyên em điều gì?', 'Chăm chỉ làm việc và giúp đỡ bạn bè', 'Chỉ nên rong chơi cho vui', 'Không cần làm việc khi còn nhỏ', null, 'Chăm chỉ làm việc và giúp đỡ bạn bè', null::jsonb, 'Ong chăm chỉ nên có cái ăn, lại tốt bụng giúp bạn.', 'doc_hieu', 53::int),
    (3::smallint, 'multiple_choice', 'Câu: "Bỗng một em gái đứng dậy, tiến tới chỗ mẩu giấy, nhặt lên rồi mang bỏ vào sọt rác." Dòng nào gồm các từ chỉ hoạt động?', 'em gái, mẩu giấy, sọt rác', 'đứng dậy, tiến tới, nhặt, bỏ', 'đứng dậy, mẩu giấy, nhặt', 'em gái, tiến tới, sọt rác', 'đứng dậy, tiến tới, nhặt, bỏ', null::jsonb, 'Em gái, mẩu giấy, sọt rác là sự vật; đứng dậy, tiến tới, nhặt, bỏ là hoạt động.', 'tu_chi_hoat_dong', 51::int),
    (3::smallint, 'multiple_choice', 'Bài ca dao: "Con mèo mà trèo cây cau / Hỏi thăm chú chuột đi đâu vắng nhà? / Chú chuột đi chợ đằng xa / Mua mắm mua muối giỗ cha chú mèo." Dòng nào gồm toàn từ chỉ hoạt động?', 'con mèo, cây cau, chú chuột', 'mắm, muối, chợ, nhà', 'trèo, cây cau, mua, mắm', 'trèo, hỏi thăm, đi chợ, mua', 'trèo, hỏi thăm, đi chợ, mua', null::jsonb, 'Trèo, hỏi thăm, đi chợ, mua đều là hoạt động.', 'tu_chi_hoat_dong', 51::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "loài vật rất thông minh" trong câu "Con chó là loài vật rất thông minh."', 'Con gì là loài vật rất thông minh?', 'Con chó làm gì?', 'Con chó thế nào?', 'Con chó là gì?', 'Con chó là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 51::int),
    (3::smallint, 'multiple_choice', 'Giải câu đố: "Tất cả các môn học / Xếp hàng trong từng ô / Giúp cho bạn biết được / Sách vở cho mỗi giờ."', 'mục lục sách', 'quyển vở', 'thời khóa biểu', 'cặp sách', 'thời khóa biểu', null::jsonb, 'Thời khóa biểu ghi các môn học theo từng ô, giúp em biết mang sách vở gì.', 'cau_do', 54::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 7 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 8: Thầy cô – Từ chỉ hoạt động, trạng thái, dấu phẩy, r/d/gi, ao/au, uôn/uông (37 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 8, 100, 'Archimes: Thầy cô – Từ chỉ hoạt động, trạng thái, dấu phẩy, r/d/gi, ao/au, uôn/uông', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 8', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền r, d hoặc gi: ___a đình', null, null, null, null, 'gi', null::jsonb, 'Gia đình.', 'chinh_ta_r_d_gi', 55::int),
    (1::smallint, 'text', 'Điền r, d hoặc gi: ___ọt sương', null, null, null, null, 'gi', null::jsonb, 'Giọt sương.', 'chinh_ta_r_d_gi', 55::int),
    (1::smallint, 'text', 'Điền r, d hoặc gi: ___ản dị', null, null, null, null, 'gi', null::jsonb, 'Giản dị.', 'chinh_ta_r_d_gi', 55::int),
    (1::smallint, 'text', 'Điền r, d hoặc gi: cá ___ô', null, null, null, null, 'r', null::jsonb, 'Cá rô.', 'chinh_ta_r_d_gi', 55::int),
    (1::smallint, 'text', 'Điền uôn hay uông (thêm dấu thanh nếu cần): "Cây có cội, nước có ng___"', null, null, null, null, 'uồn', null::jsonb, 'Nước có nguồn.', 'chinh_ta_uon_uong', 55::int),
    (1::smallint, 'text', 'Điền tiếng có vần uôn hay uông (thêm dấu thanh nếu cần): "___ nước nhớ nguồn"', null, null, null, null, 'uống', null::jsonb, 'Uống nước nhớ nguồn.', 'chinh_ta_uon_uong', 55::int),
    (1::smallint, 'text', 'Điền ao hay au (thêm dấu thanh nếu cần): lời ch___', null, null, null, null, 'ào', null::jsonb, 'Lời chào.', 'chinh_ta_ao_au', 55::int),
    (1::smallint, 'text', 'Điền ao hay au (thêm dấu thanh nếu cần): m___ sắc', null, null, null, null, 'àu', null::jsonb, 'Màu sắc.', 'chinh_ta_ao_au', 55::int),
    (1::smallint, 'multiple_choice', 'Chọn từ đúng: "chim ___"', 'sáu', 'sáo', 'sau', null, 'sáo', null::jsonb, 'Chim sáo.', 'chinh_ta_ao_au', 55::int),
    (1::smallint, 'multiple_choice', 'Chọn từ đúng: "số ___"', 'sáo', 'sào', 'sáu', null, 'sáu', null::jsonb, 'Số sáu.', 'chinh_ta_ao_au', 55::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ trạng thái (tâm trạng, cảm xúc)?', 'chạy', 'quyển vở', 'cái bàn', 'vui', 'vui', null::jsonb, '"vui" nêu cảm xúc của người.', 'tu_chi_trang_thai', 56::int),
    (1::smallint, 'multiple_choice', 'Dấu phẩy dùng để làm gì?', 'Ngăn cách các từ ngữ cùng vai trò trong câu', 'Kết thúc một câu hỏi', 'Kết thúc một câu kể', null, 'Ngăn cách các từ ngữ cùng vai trò trong câu', null::jsonb, 'Dấu phẩy ngăn cách các từ ngữ cùng một vai trò trong câu.', 'dau_phay', 56::int),
    (1::smallint, 'text', 'Điền ng hay ngh: "Chú ___é con nghiêng đầu lắng nghe."', null, null, null, null, 'ngh', null::jsonb, 'Viết ngh trước e: nghé.', 'chinh_ta_ng_ngh', 62::int),
    (2::smallint, 'multiple_choice', 'Chọn từ đúng: "con ___" (con vật nhỏ hay bò trong bếp)', 'gián', 'dán', 'rán', null, 'gián', null::jsonb, 'Con gián.', 'chinh_ta_r_d_gi', 55::int),
    (2::smallint, 'multiple_choice', 'Chọn từ đúng: "bánh ___"', 'dán', 'rán', 'gián', null, 'rán', null::jsonb, 'Bánh rán.', 'chinh_ta_r_d_gi', 55::int),
    (2::smallint, 'text', 'Sửa lỗi chính tả trong câu thơ: "Em yêu giòng kênh nhỏ" → Em yêu ___ kênh nhỏ', null, null, null, null, 'dòng', null::jsonb, 'Dòng kênh.', 'chinh_ta_r_d_gi', 55::int),
    (2::smallint, 'text', 'Sửa lỗi chính tả trong câu thơ: "Chảy giữa hai dặng cây" → Chảy giữa hai ___ cây', null, null, null, null, 'rặng', null::jsonb, 'Rặng cây.', 'chinh_ta_r_d_gi', 55::int),
    (2::smallint, 'text', 'Sửa lỗi chính tả trong câu thơ: "Gương nước in chời mây" → Gương nước in ___ mây', null, null, null, null, 'trời', null::jsonb, 'Trời mây.', 'chinh_ta_ch_tr', 55::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Con gà con vịt, con ngan đều là gia cầm.', 'Con gà, con vịt con ngan, đều là gia cầm.', 'Con gà, con vịt, con ngan đều là gia cầm.', 'Con, gà con vịt con ngan đều là gia cầm.', 'Con gà, con vịt, con ngan đều là gia cầm.', null::jsonb, 'Dấu phẩy ngăn cách các con vật cùng vai trò: con gà, con vịt, con ngan.', 'dau_phay', 56::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Hoa, hồng hoa lan đều đẹp và thơm.', 'Hoa hồng hoa, lan đều đẹp và thơm.', 'Hoa hồng hoa lan đều, đẹp và thơm.', 'Hoa hồng, hoa lan đều đẹp và thơm.', 'Hoa hồng, hoa lan đều đẹp và thơm.', null::jsonb, 'Dấu phẩy đặt giữa "hoa hồng" và "hoa lan".', 'dau_phay', 60::int),
    (2::smallint, 'multiple_choice', 'Đoạn thơ "Cái trống trường em": "Cái trống trường em / Mùa hè cũng ___ / Suốt ba tháng liền / Trống nằm ___." (chọn trong các từ: buồn, đi vắng, nghỉ, ngẫm nghĩ)
Từ điền vào chỗ trống thứ nhất là:', 'buồn', 'đi vắng', 'nghỉ', 'ngẫm nghĩ', 'nghỉ', null::jsonb, '"Mùa hè cũng nghỉ."', 'tu_chi_trang_thai', 57::int),
    (2::smallint, 'multiple_choice', 'Đoạn thơ "Cái trống trường em": "Cái trống trường em / Mùa hè cũng ___ / Suốt ba tháng liền / Trống nằm ___." (chọn trong các từ: buồn, đi vắng, nghỉ, ngẫm nghĩ)
Từ điền vào chỗ trống thứ hai là:', 'nghỉ', 'đi vắng', 'buồn', 'ngẫm nghĩ', 'ngẫm nghĩ', null::jsonb, '"Trống nằm ngẫm nghĩ."', 'tu_chi_trang_thai', 57::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Giờ học vẽ, cô giáo bảo mỗi học sinh vẽ một bức tranh thể hiện lòng biết ơn của các em. Nhận tranh của học sinh, cô rất ngạc nhiên thấy tranh của Đức chỉ có hình một bàn tay được vẽ rất đơn giản, ngây ngô."
Câu chuyện xảy ra trong giờ học nào?', 'Âm nhạc', 'Mĩ thuật', 'Tiếng Việt', null, 'Mĩ thuật', null::jsonb, 'Giờ học vẽ là giờ Mĩ thuật.', 'doc_hieu', 59::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Giờ học vẽ, cô giáo bảo mỗi học sinh vẽ một bức tranh thể hiện lòng biết ơn của các em. Nhận tranh của học sinh, cô rất ngạc nhiên thấy tranh của Đức chỉ có hình một bàn tay được vẽ rất đơn giản, ngây ngô."
Khi nhận tranh của Đức, thái độ của cô giáo thế nào?', 'ngạc nhiên', 'vui vẻ', 'giận dữ', null, 'ngạc nhiên', null::jsonb, '"Cô rất ngạc nhiên..."', 'doc_hieu', 59::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"- Vì sao em vẽ bàn tay? Bàn tay đó của ai? - Cô giáo hỏi.
- Đó là bàn tay của cô đấy ạ. - Cậu bé thì thầm.
Cô giáo nhớ lại: Trong giờ giải lao, cô thường nắm tay Đức. Với Đức, một cậu bé cô độc, ít nói, điều này rất có ý nghĩa."
Bức tranh "bàn tay" của Đức vẽ về ai?', 'chính bản thân Đức', 'cô giáo của Đức', 'bạn cùng lớp với Đức', null, 'cô giáo của Đức', null::jsonb, 'Đức nói: "Đó là bàn tay của cô đấy ạ."', 'doc_hieu', 59::int),
    (2::smallint, 'multiple_choice', 'Câu nào viết theo mẫu Ai là gì?', 'Đức rất biết ơn cô giáo.', 'Đức vẽ bức tranh bàn tay.', 'Bức tranh là món quà tặng cô giáo.', null, 'Bức tranh là món quà tặng cô giáo.', null::jsonb, 'Câu có từ "là" giới thiệu bức tranh là món quà.', 'cau_ai_la_gi', 59::int),
    (2::smallint, 'multiple_choice', 'Từ nào không cùng nhóm với các từ còn lại: thức dậy, sách vở, ăn sáng, đi học?', 'thức dậy', 'ăn sáng', 'đi học', 'sách vở', 'sách vở', null::jsonb, '"sách vở" là sự vật, các từ còn lại chỉ hoạt động.', 'tu_chi_hoat_dong', 60::int),
    (2::smallint, 'multiple_choice', 'Đọc câu chuyện:
"Có một cậu bé được bà sai đi chợ. Bà đưa cho cậu hai đồng và hai cái bát, dặn: - Cháu mua một đồng tương, một đồng mắm nhé! Cậu bé vâng dạ, đi ngay. Gần tới chợ, cậu bỗng hớt hải chạy về, hỏi bà: - Bà ơi, bát nào đựng tương, bát nào đựng mắm?"
Cậu bé được bà sai đi chợ mua gì?', 'mắm và tương', 'chỉ mua mắm', 'chỉ mua tương', null, 'mắm và tương', null::jsonb, 'Bà dặn mua một đồng tương, một đồng mắm.', 'doc_hieu', 61::int),
    (2::smallint, 'multiple_choice', 'Đọc câu chuyện:
"Có một cậu bé được bà sai đi chợ. Bà đưa cho cậu hai đồng và hai cái bát, dặn: - Cháu mua một đồng tương, một đồng mắm nhé! Cậu bé vâng dạ, đi ngay. Gần tới chợ, cậu bỗng hớt hải chạy về, hỏi bà: - Bà ơi, bát nào đựng tương, bát nào đựng mắm?"
Vì sao gần tới chợ cậu bé lại quay về?', 'Vì cậu quên tiền', 'Vì cậu quên mang bát', 'Vì không biết bát nào đựng mắm, bát nào đựng tương', null, 'Vì không biết bát nào đựng mắm, bát nào đựng tương', null::jsonb, 'Cậu chạy về hỏi bà bát nào đựng tương, bát nào đựng mắm.', 'doc_hieu', 61::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"- Vì sao em vẽ bàn tay? Bàn tay đó của ai? - Cô giáo hỏi.
- Đó là bàn tay của cô đấy ạ. - Cậu bé thì thầm.
Cô giáo nhớ lại: Trong giờ giải lao, cô thường nắm tay Đức. Với Đức, một cậu bé cô độc, ít nói, điều này rất có ý nghĩa."
Bức tranh bàn tay của Đức nói lên điều gì?', 'Đức muốn khoe mình vẽ đẹp', 'Đức biết ơn cô vì cô hay nắm tay, quan tâm em', 'Đức không thích học vẽ', null, 'Đức biết ơn cô vì cô hay nắm tay, quan tâm em', null::jsonb, 'Cô thường nắm tay Đức, cậu bé cô độc ít nói, nên Đức vẽ bàn tay cô để tỏ lòng biết ơn.', 'doc_hieu', 59::int),
    (3::smallint, 'multiple_choice', 'Từ nào không cùng nhóm với các từ còn lại: phát biểu, hăng hái, thảo luận, ra chơi?', 'hăng hái', 'phát biểu', 'thảo luận', 'ra chơi', 'hăng hái', null::jsonb, '"hăng hái" chỉ đặc điểm, các từ còn lại chỉ hoạt động.', 'tu_chi_hoat_dong', 60::int),
    (3::smallint, 'multiple_choice', 'Từ nào không cùng nhóm với các từ còn lại: tắm rửa, chăm chỉ, lau dọn, học tập?', 'tắm rửa', 'lau dọn', 'học tập', 'chăm chỉ', 'chăm chỉ', null::jsonb, '"chăm chỉ" chỉ tính nết, các từ còn lại chỉ hoạt động.', 'tu_chi_hoat_dong', 60::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Buổi sáng bố mẹ, đi làm em đi học.', 'Buổi sáng, bố mẹ đi làm, em đi học.', 'Buổi, sáng bố mẹ đi làm em đi học.', 'Buổi sáng bố mẹ đi, làm, em đi học.', 'Buổi sáng, bố mẹ đi làm, em đi học.', null::jsonb, 'Phẩy sau "Buổi sáng" và giữa hai ý "bố mẹ đi làm", "em đi học".', 'dau_phay', 60::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Sáng dậy em, đánh răng rửa mặt, ăn sáng rồi đi học.', 'Sáng dậy, em đánh răng rửa, mặt ăn sáng rồi đi học.', 'Sáng dậy, em đánh răng, rửa mặt, ăn sáng rồi đi học.', 'Sáng, dậy em đánh răng, rửa mặt ăn sáng, rồi đi học.', 'Sáng dậy, em đánh răng, rửa mặt, ăn sáng rồi đi học.', null::jsonb, 'Phẩy sau "Sáng dậy" và ngăn cách các hoạt động: đánh răng, rửa mặt, ăn sáng.', 'dau_phay', 56::int),
    (3::smallint, 'multiple_choice', 'Đọc câu chuyện:
"Có một cậu bé được bà sai đi chợ. Bà đưa cho cậu hai đồng và hai cái bát, dặn: - Cháu mua một đồng tương, một đồng mắm nhé! Cậu bé vâng dạ, đi ngay. Gần tới chợ, cậu bỗng hớt hải chạy về, hỏi bà: - Bà ơi, bát nào đựng tương, bát nào đựng mắm?"
Câu chuyện có mấy nhân vật?', 'Hai nhân vật: bà và cậu bé', 'Một nhân vật: cậu bé', 'Ba nhân vật: bà, cậu bé, người bán hàng', null, 'Hai nhân vật: bà và cậu bé', null::jsonb, 'Câu chuyện chỉ có bà và cậu bé.', 'doc_hieu', 61::int),
    (3::smallint, 'multiple_choice', 'Từ nào không cùng nhóm với các từ còn lại: học sinh, giáo viên, đọc sách, nhà trường, bàn ghế?', 'học sinh', 'nhà trường', 'bàn ghế', 'đọc sách', 'đọc sách', null::jsonb, '"đọc sách" là hoạt động, các từ còn lại là sự vật.', 'tu_chi_hoat_dong', 62::int),
    (3::smallint, 'multiple_choice', 'Đoạn thơ: "Chị mây vừa kéo đến / Trăng sao trốn cả rồi / Đất nóng lòng chờ đợi / Xuống đi nào, mưa ơi!" Dòng nào gồm các từ chỉ hoạt động, trạng thái?', 'kéo đến, trốn, chờ đợi, xuống', 'chị mây, trăng sao, đất', 'trăng, sao, mưa, đất', null, 'kéo đến, trốn, chờ đợi, xuống', null::jsonb, 'Kéo đến, trốn, chờ đợi, xuống là hoạt động, trạng thái; mây, trăng, sao, đất, mưa là sự vật.', 'tu_chi_hoat_dong', 62::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 8 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 9: Ôn tập giữa học kì I – Đọc hiểu, từ chỉ sự vật, hoạt động, câu Ai là gì?, dấu câu (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 9, 100, 'Archimes: Ôn tập giữa học kì I – Đọc hiểu, từ chỉ sự vật, hoạt động, câu Ai là gì?, dấu câu', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 1, tuần 9', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Hoa cánh kiến có màu gì?', 'trắng', 'đỏ', 'vàng', 'tím', 'vàng', null::jsonb, '"Hoa cánh kiến nở vàng trên rừng."', 'doc_hieu', 63::int),
    (1::smallint, 'text', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Hoa sở và hoa kim anh có màu ___.', null, null, null, null, 'trắng', '["trắng xóa"]'::jsonb, '"Hoa sở và hoa kim anh trắng xóa."', 'doc_hieu', 63::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Những anh chuồn chuồn ớt đỏ thắm như ngọn lửa. Các anh sáo đá kêu rối rít, vút lên cao rồi lại sà xuống thấp. Các chú bọ ngựa vung gươm tập múa võ trên những chiếc lá to. Các ả cánh cam diêm dúa, các chị cào cào xòe áo lụa đơm dáng..."
Loài vật nào "vung gươm tập múa võ"?', 'cào cào', 'chuồn chuồn ớt', 'sáo đá', 'bọ ngựa', 'bọ ngựa', null::jsonb, '"Các chú bọ ngựa vung gươm tập múa võ."', 'doc_hieu', 63::int),
    (1::smallint, 'text', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Điền từ còn thiếu: "Ban mai nắng dịu, chim hót ___."', null, null, null, null, 'líu lo', null::jsonb, 'Bài đọc: "Ban mai nắng dịu, chim hót líu lo."', 'doc_hieu', 63::int),
    (1::smallint, 'multiple_choice', 'Nối bộ phận cơ thể với hoạt động: mắt dùng để làm gì?', 'nghe', 'nhìn', 'nói', 'cầm', 'nhìn', null::jsonb, 'Mắt dùng để nhìn.', 'tu_chi_hoat_dong', 64::int),
    (1::smallint, 'multiple_choice', 'Nối bộ phận cơ thể với hoạt động: tai dùng để làm gì?', 'nghe', 'nhìn', 'đi', 'cầm', 'nghe', null::jsonb, 'Tai dùng để nghe.', 'tu_chi_hoat_dong', 64::int),
    (1::smallint, 'multiple_choice', 'Bộ phận nào của cơ thể dùng để cầm?', 'chân', 'mắt', 'tai', 'tay', 'tay', null::jsonb, 'Tay dùng để cầm.', 'tu_chi_hoat_dong', 64::int),
    (1::smallint, 'text', 'Chọn trong các từ: cầm, nói, nhìn, đi, nghe. Chân dùng để ___.', null, null, null, null, 'đi', null::jsonb, 'Chân dùng để đi.', 'tu_chi_hoat_dong', 64::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Sư Tử chỉ kết bạn với các con vật to khỏe như mình và cho rằng những con vật bé nhỏ chẳng có ích gì. Một lần, Kiến Càng đến xin kết bạn với Sư Tử liền bị Sư Tử xua đuổi."
Sư Tử chỉ kết bạn với loài vật nào?', 'loài vật có ích', 'loài vật nhanh nhẹn, thông minh', 'loài vật to khỏe', null, 'loài vật to khỏe', null::jsonb, 'Sư Tử chỉ kết bạn với các con vật to khỏe như mình.', 'doc_hieu', 66::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Sư Tử chỉ kết bạn với các con vật to khỏe như mình và cho rằng những con vật bé nhỏ chẳng có ích gì. Một lần, Kiến Càng đến xin kết bạn với Sư Tử liền bị Sư Tử xua đuổi."
Sư Tử cho rằng những con vật bé nhỏ thế nào?', 'chẳng có ích gì', 'yếu ớt', 'không tốt bụng', null, 'chẳng có ích gì', null::jsonb, 'Sư Tử cho rằng những con vật bé nhỏ chẳng có ích gì.', 'doc_hieu', 66::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Nghe tin Sư Tử đau tai, Kiến Càng không để bụng chuyện cũ, vào tận hang thăm Sư Tử. Kiến Càng bò vào tai Sư Tử và lôi ra một con rệp. Sư Tử khỏi đau, hối hận vì đã đối xử không tốt với Kiến."
Ai đã giúp Sư Tử khỏi đau?', 'thầy thuốc', 'Kiến Càng', 'Voi, Hổ, Gấu', null, 'Kiến Càng', null::jsonb, 'Kiến Càng lôi con rệp ra khỏi tai Sư Tử.', 'doc_hieu', 66::int),
    (1::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai là gì?', 'Hà Nội có nhiều hồ đẹp.', 'Hà Nội rất đông vui.', 'Hà Nội là thủ đô của nước ta.', 'Hà Nội mùa thu thật đẹp.', 'Hà Nội là thủ đô của nước ta.', null::jsonb, 'Câu có từ "là" giới thiệu Hà Nội là thủ đô.', 'cau_ai_la_gi', 67::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ hoạt động trong câu "Từng đoàn thuyền đánh cá giong buồm, thả lưới trắng xóa cả mặt sông."?', 'thuyền', 'lưới', 'mặt sông', 'thả', 'thả', null::jsonb, '"thả" (lưới) là hoạt động.', 'tu_chi_hoat_dong', 64::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Buổi chiều về nghe mát
Bò ra sông uống nước
Thấy bóng mình ngỡ ai
Bò chào: Kìa anh bạn
Lại gặp anh ở đây."
(Phạm Hổ)
Từ nào là từ chỉ sự vật?', 'sông', 'uống', 'chào', 'gặp', 'sông', null::jsonb, '"sông" là sự vật; uống, chào, gặp là hoạt động.', 'tu_chi_su_vat', 67::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Đoạn văn có những màu sắc nào?', 'đỏ, tím, hồng', 'vàng, trắng, xanh', 'vàng, đỏ, đen', 'trắng, tím, nâu', 'vàng, trắng, xanh', null::jsonb, 'Hoa nở vàng, hoa trắng xóa, cỏ xanh nõn.', 'doc_hieu', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Gió ngào ngạt mùi thơm của những gì?', 'hoa sở và hoa kim anh', 'cỏ và phấn hoa', 'lúa chín', 'bầy ong', 'cỏ và phấn hoa', null::jsonb, '"Gió ngào ngạt mùi thơm của cỏ và phấn hoa."', 'doc_hieu', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Những anh chuồn chuồn ớt đỏ thắm như ngọn lửa. Các anh sáo đá kêu rối rít, vút lên cao rồi lại sà xuống thấp. Các chú bọ ngựa vung gươm tập múa võ trên những chiếc lá to. Các ả cánh cam diêm dúa, các chị cào cào xòe áo lụa đơm dáng..."
Loài vật nào "xòe áo lụa đơm dáng"?', 'cánh cam', 'bọ ngựa', 'cào cào', 'sáo đá', 'cào cào', null::jsonb, '"Các chị cào cào xòe áo lụa đơm dáng."', 'doc_hieu', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Những anh chuồn chuồn ớt đỏ thắm như ngọn lửa. Các anh sáo đá kêu rối rít, vút lên cao rồi lại sà xuống thấp. Các chú bọ ngựa vung gươm tập múa võ trên những chiếc lá to. Các ả cánh cam diêm dúa, các chị cào cào xòe áo lụa đơm dáng..."
Chuồn chuồn ớt được so sánh với gì?', 'áo lụa', 'đám mây', 'chiếc lá', 'ngọn lửa', 'ngọn lửa', null::jsonb, '"Chuồn chuồn ớt đỏ thắm như ngọn lửa."', 'doc_hieu', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mùa xuân đã về trên cánh đồng. Hoa cánh kiến nở vàng trên rừng, hoa sở và hoa kim anh trắng xóa. Những bầy ong từ rừng bay xuống đồng. Cỏ gà, cỏ mật, cỏ tương tư xanh nõn. Ban mai nắng dịu, chim hót líu lo. Gió ngào ngạt mùi thơm của cỏ và phấn hoa."
Nhóm nào gồm 3 từ chỉ sự vật có trong đoạn văn?', 'cánh đồng, bầy ong, cỏ gà', 'bay, hót, nở', 'vàng, trắng, xanh nõn', 'ngào ngạt, líu lo, dịu', 'cánh đồng, bầy ong, cỏ gà', null::jsonb, 'Cánh đồng, bầy ong, cỏ gà là sự vật.', 'tu_chi_su_vat', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Những anh chuồn chuồn ớt đỏ thắm như ngọn lửa. Các anh sáo đá kêu rối rít, vút lên cao rồi lại sà xuống thấp. Các chú bọ ngựa vung gươm tập múa võ trên những chiếc lá to. Các ả cánh cam diêm dúa, các chị cào cào xòe áo lụa đơm dáng..."
Nhóm nào gồm 3 từ chỉ hoạt động có trong đoạn văn?', 'sáo đá, bọ ngựa, cào cào', 'đỏ thắm, diêm dúa, to', 'ngọn lửa, gươm, lá', 'kêu, vung, múa', 'kêu, vung, múa', null::jsonb, 'Kêu, vung (gươm), múa (võ) là hoạt động.', 'tu_chi_hoat_dong', 63::int),
    (2::smallint, 'multiple_choice', 'Đổi trật tự các từ trong câu "Cô Hà làm cùng cơ quan với mẹ em." để được câu mới. Câu nào đúng?', 'Cơ quan làm cùng cô Hà với mẹ em.', 'Mẹ em làm cùng cơ quan với cô Hà.', 'Mẹ em cô Hà làm với cùng cơ quan.', 'Làm cùng mẹ em cơ quan với cô Hà.', 'Mẹ em làm cùng cơ quan với cô Hà.', null::jsonb, 'Đổi chỗ "Cô Hà" và "mẹ em".', 'sap_xep_cau', 64::int),
    (2::smallint, 'multiple_choice', 'Đổi trật tự các từ trong câu "Tiếng Việt là môn học em yêu thích." để được câu mới. Câu nào đúng?', 'Môn học là Tiếng Việt em yêu thích.', 'Em là môn học yêu thích Tiếng Việt.', 'Môn học em yêu thích là Tiếng Việt.', 'Yêu thích là môn học em Tiếng Việt.', 'Môn học em yêu thích là Tiếng Việt.', null::jsonb, 'Đổi chỗ hai bộ phận hai bên từ "là".', 'sap_xep_cau', 64::int),
    (2::smallint, 'multiple_choice', 'Đoạn văn chưa có dấu câu: "Biết bạn của con khỏe mạnh (1) thông minh (2) nhanh nhẹn (3) cha Nai Nhỏ vẫn lo (4) biết bạn của con dám liều mình cứu người khác, cha Nai Nhỏ mới yên lòng."
Ô trống (1) cần điền dấu gì?', 'dấu phẩy', 'dấu chấm', 'dấu chấm hỏi', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách các từ cùng loại: khỏe mạnh, thông minh, nhanh nhẹn.', 'dau_phay', 63::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một hôm, Sư Tử cảm thấy đau nhức trong tai, không thể ra khỏi hang được. Bạn bè của Sư Tử đến thăm, Sư Tử nhờ các bạn chữa chạy giúp. Nhưng Voi, Hổ, Gấu... đều từ chối, mặc cho Sư Tử đau đớn."
Khi Sư Tử bị đau tai, bạn bè đối xử với Sư Tử thế nào?', 'không đến thăm hỏi', 'đến thăm và chữa chạy cho Sư Tử', 'đến thăm nhưng không giúp chữa chạy', null, 'đến thăm nhưng không giúp chữa chạy', null::jsonb, 'Voi, Hổ, Gấu đến thăm nhưng đều từ chối chữa chạy.', 'doc_hieu', 66::int),
    (2::smallint, 'multiple_choice', 'Trong câu "Các bà, các chị xã viên đã ra ruộng tỉa bắp, hái dâu.", nhóm nào gồm các từ chỉ hoạt động?', 'ra, tỉa, hái', 'bà, chị, xã viên', 'ruộng, bắp, dâu', null, 'ra, tỉa, hái', null::jsonb, 'Ra (ruộng), tỉa (bắp), hái (dâu) là hoạt động.', 'tu_chi_hoat_dong', 64::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Buổi chiều về nghe mát
Bò ra sông uống nước
Thấy bóng mình ngỡ ai
Bò chào: Kìa anh bạn
Lại gặp anh ở đây."
(Phạm Hổ)
Dòng nào gồm toàn từ chỉ hoạt động?', 'bò, sông, nước', 'uống, chào, gặp', 'buổi chiều, bóng, anh bạn', null, 'uống, chào, gặp', null::jsonb, 'Uống, chào, gặp là hoạt động của con bò.', 'tu_chi_hoat_dong', 67::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "gà rán" trong câu "Món ăn được nhiều bạn trẻ yêu thích là gà rán."', 'Cái gì là gà rán?', 'Gà rán thế nào?', 'Ai yêu thích gà rán?', 'Món ăn được nhiều bạn trẻ yêu thích là gì?', 'Món ăn được nhiều bạn trẻ yêu thích là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 64::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận "ba người bạn cùng sống với nhau" trong câu "Chuồn Chuồn, Ong và Bướm là ba người bạn cùng sống với nhau."', 'Chuồn Chuồn, Ong và Bướm làm gì?', 'Chuồn Chuồn, Ong và Bướm là gì?', 'Chuồn Chuồn, Ong và Bướm thế nào?', null, 'Chuồn Chuồn, Ong và Bướm là gì?', null::jsonb, 'Bộ phận đứng sau "là" trả lời câu hỏi "Là gì?".', 'cau_ai_la_gi', 64::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp các câu thành đoạn truyện:
1. Bình minh, tia nắng đầu tiên gõ cửa nhà chim sâu.
2. Mùa này, chồi non nảy ra mơn mởn, nhưng cũng là lúc sâu bọ phá hoại nhiều.
3. Chú lao ngay tới rặng ổi quen thuộc để làm việc.
4. Chim sâu nhanh nhẹn trở dậy.
Thứ tự đúng là:', '1, 2, 3, 4', '4, 1, 2, 3', '1, 4, 2, 3', '2, 1, 4, 3', '1, 4, 2, 3', null::jsonb, 'Nắng gõ cửa (1), chim sâu dậy (4), mùa này sâu bọ nhiều (2), nên chú lao tới rặng ổi (3).', 'sap_xep_cau', 65::int),
    (3::smallint, 'multiple_choice', 'Đoạn văn chưa có dấu câu: "Biết bạn của con khỏe mạnh (1) thông minh (2) nhanh nhẹn (3) cha Nai Nhỏ vẫn lo (4) biết bạn của con dám liều mình cứu người khác, cha Nai Nhỏ mới yên lòng."
Ô trống (4) cần điền dấu gì?', 'dấu chấm', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu chấm', null::jsonb, 'Sau "cha Nai Nhỏ vẫn lo" là hết một câu; câu sau bắt đầu "Biết bạn của con dám liều mình...".', 'dau_cau', 63::int),
    (3::smallint, 'multiple_choice', 'Truyện "Sư Tử và Kiến Càng": Sư Tử xua đuổi Kiến Càng vì Kiến bé nhỏ; khi Sư Tử đau tai, Voi, Hổ, Gấu từ chối giúp, còn Kiến Càng vào tận hang chữa cho Sư Tử. Ai mới thật sự là người bạn tốt của Sư Tử?', 'Voi, Hổ, Gấu', 'Kiến Càng', 'những con vật to khỏe', null, 'Kiến Càng', null::jsonb, 'Người bạn tốt là người giúp mình lúc khó khăn: Kiến Càng.', 'doc_hieu', 66::int),
    (3::smallint, 'multiple_choice', 'Tách đoạn sau thành 4 câu: "Mặt trăng tròn nhô lên từ phía đằng đông ánh trăng trong xanh tỏa khắp khu rừng thỏ mẹ cùng đàn con nắm tay nhau nhảy múa chân thỏ nhịp nhàng lướt theo nhịp trống". Câu thứ ba bắt đầu bằng từ ngữ nào?', 'Ánh trăng', 'Chân thỏ', 'Khu rừng', 'Thỏ mẹ', 'Thỏ mẹ', null::jsonb, 'Bốn câu bắt đầu bằng: Mặt trăng / Ánh trăng / Thỏ mẹ / Chân thỏ.', 'dau_cau', 67::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 9 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 10: Ông bà – Từ ngữ về họ hàng, dấu chấm, dấu chấm hỏi (29 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 10, 100, 'Archimes: Ông bà – Từ ngữ về họ hàng, dấu chấm, dấu chấm hỏi', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 10', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền c hay k: “___on kiến mà leo cành đa”', null, null, null, null, 'c', null::jsonb, 'Viết c trước o: con kiến.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền c hay k: “Con ___iến mà leo cành đào”', null, null, null, null, 'k', null::jsonb, 'Viết k trước i, e, ê: con kiến.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền c hay k: “Ở lớp cũng như ở nhà, bé Hà được coi là một ___ây sáng kiến.”', null, null, null, null, 'c', null::jsonb, 'Viết c trước â: cây sáng kiến.', 'chinh_ta_c_k', 3::int),
    (1::smallint, 'text', 'Điền l hay n: “Ngày 8 tháng 3 hằng ___ăm là ngày Quốc tế Phụ nữ.”', null, null, null, null, 'n', null::jsonb, 'Viết đúng là: hằng năm.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'text', 'Điền l hay n: “Nhớ bà, An ngồi ___ặng lẽ.”', null, null, null, null, 'l', null::jsonb, 'Viết đúng là: lặng lẽ.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'text', 'Điền d, r hay gi: “Suối chảy ___óc rách.”', null, null, null, null, 'r', null::jsonb, 'Viết đúng là: róc rách.', 'chinh_ta_r_d_gi', 3::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết ĐÚNG chính tả?', 'cần cù', 'nưu luyến', 'lơm nớp', 'leo lúi', 'cần cù', null::jsonb, '“Cần cù” viết đúng; các từ kia phải là: leo núi, lưu luyến, nơm nớp.', 'chinh_ta_l_n', 3::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết SAI chính tả?', 'kết tóc', 'non lớt', 'nô nức', 'cái kéo', 'non lớt', null::jsonb, '“Non lớt” viết sai, phải viết là “non nớt”.', 'chinh_ta_l_n', 3::int),
    (2::smallint, 'text', 'Sửa từ viết sai chính tả cho đúng: “nưu luyến” → ___', null, null, null, null, 'lưu luyến', null::jsonb, 'Viết đúng là “lưu luyến” (l, không phải n).', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: “– Đã đi được chưa con ___”', 'dấu chấm hỏi', 'dấu phẩy', 'dấu chấm', null, 'dấu chấm hỏi', null::jsonb, 'Đây là câu hỏi nên cuối câu dùng dấu chấm hỏi.', 'dau_cau', 4::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: “– Ông đúng là một con người kiên nhẫn ___ – Người phụ nữ nói.”', 'dấu phẩy', 'dấu chấm', 'dấu chấm hỏi', null, 'dấu chấm', null::jsonb, 'Đây là câu kể nên cuối câu dùng dấu chấm.', 'dau_cau', 4::int),
    (2::smallint, 'multiple_choice', 'Câu nào cần đặt dấu chấm hỏi ở cuối câu?', 'Chúng em đang học môn Tiếng Việt', 'Em rất yêu bà nội', 'Bà kể chuyện cổ tích cho em nghe', 'Cuối tuần này, cậu có ở nhà không', 'Cuối tuần này, cậu có ở nhà không', null::jsonb, 'Câu có “có… không” là câu hỏi nên cuối câu dùng dấu chấm hỏi.', 'dau_cau', 4::int),
    (2::smallint, 'multiple_choice', '“Trong khu vườn nọ có các bạn Kiến ___ Ong ___ Bướm ___ Chuồn Chuồn chơi với nhau rất thân.” Dấu cần điền vào các chỗ trống là:', 'dấu chấm hỏi', 'dấu chấm', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy dùng để ngăn cách các từ cùng loại đứng liền nhau.', 'dau_cau', 4::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ người trong gia đình, họ hàng?', 'giáo sư', 'công nhân', 'ông ngoại', 'bác sĩ', 'ông ngoại', null::jsonb, 'Ông ngoại là người trong họ hàng; các từ kia chỉ nghề nghiệp.', 'tu_ngu_ho_hang', 4::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ người trong gia đình, họ hàng?', 'nông dân', 'em trai', 'dì', 'bà nội', 'nông dân', null::jsonb, '“Nông dân” chỉ nghề nghiệp, không chỉ người trong họ hàng.', 'tu_ngu_ho_hang', 4::int),
    (2::smallint, 'text', 'Điền từ thích hợp: Em gọi em trai của mẹ là ___.', null, null, null, null, 'cậu', null::jsonb, 'Em trai của mẹ, em gọi là cậu.', 'tu_ngu_ho_hang', 4::int),
    (2::smallint, 'text', 'Điền từ thích hợp: Em gọi em trai của bố là ___.', null, null, null, null, 'chú', null::jsonb, 'Em trai của bố, em gọi là chú.', 'tu_ngu_ho_hang', 4::int),
    (2::smallint, 'multiple_choice', 'Em gọi anh trai của bố là gì?', 'dượng', 'bác', 'chú', 'cậu', 'bác', null::jsonb, 'Anh trai của bố, em gọi là bác.', 'tu_ngu_ho_hang', 4::int),
    (3::smallint, 'multiple_choice', 'Em gọi vợ của em trai bố (vợ của chú) là gì?', 'mợ', 'cô', 'dì', 'thím', 'thím', null::jsonb, 'Vợ của chú, em gọi là thím.', 'tu_ngu_ho_hang', 7::int),
    (3::smallint, 'multiple_choice', 'Em gọi vợ của em trai mẹ (vợ của cậu) là gì?', 'cô', 'bác', 'mợ', 'thím', 'mợ', null::jsonb, 'Vợ của cậu, em gọi là mợ.', 'tu_ngu_ho_hang', 7::int),
    (3::smallint, 'text', 'Điền từ thích hợp: Em gái của bố, em gọi là ___.', null, null, null, null, 'cô', null::jsonb, 'Em gái của bố, em gọi là cô.', 'tu_ngu_ho_hang', 7::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn trích:
“Cũng như bao đứa trẻ khác cùng làng, tôi lớn lên với hương lúa chín của làng quê nhỏ bé miền trung du. Tuổi thơ của tôi là bà nội, là những bông hoa gạo rực lửa…”
Bạn nhỏ lớn lên ở vùng nào?', 'miền biển', 'miền núi cao', 'miền trung du', 'miền đồng bằng', 'miền trung du', null::jsonb, 'Bạn nhỏ lớn lên ở làng quê nhỏ bé miền trung du.', 'doc_hieu', 6::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn trích:
“Những tối hè nằm trên chiếc chõng tre, tiếng ru của bà cùng tiếng gió từ chiếc quạt nan đưa tôi vào giấc ngủ.”
Điều gì đưa bạn nhỏ vào giấc ngủ?', 'tiếng mưa rơi ngoài hiên', 'câu chuyện cổ tích của ông', 'tiếng xào xạc của rừng lau', 'tiếng ru của bà và gió từ chiếc quạt nan', 'tiếng ru của bà và gió từ chiếc quạt nan', null::jsonb, 'Tiếng ru của bà cùng tiếng gió từ chiếc quạt nan đưa bạn vào giấc ngủ.', 'doc_hieu', 6::int),
    (3::smallint, 'multiple_choice', 'Trong bài “Bà nội”: “…chẳng có gì đáng ngạc nhiên khi trong trí óc non nớt của tôi, bà là tất cả.”
Trong trí óc non nớt của bạn nhỏ, bà là gì?', 'Bà là tất cả.', 'Bà là người ít nói.', 'Bà là người rất nghiêm khắc.', 'Bà là người ở rất xa.', 'Bà là tất cả.', null::jsonb, 'Bạn nhỏ nói: trong trí óc non nớt của tôi, bà là tất cả.', 'doc_hieu', 6::int),
    (3::smallint, 'multiple_choice', 'Qua bài “Bà nội” (bà ru cháu ngủ, kể chuyện cổ tích, bà là tất cả với cháu), em thấy tình cảm hai bà cháu thế nào?', 'Bà rất nghiêm khắc với cháu', 'Hai bà cháu rất yêu thương, gắn bó', 'Cháu rất sợ bà', 'Hai bà cháu ít khi gặp nhau', 'Hai bà cháu rất yêu thương, gắn bó', null::jsonb, 'Bà chăm sóc, ru cháu ngủ; với cháu, bà là tất cả – hai bà cháu rất gắn bó.', 'doc_hieu', 6::int),
    (1::smallint, 'multiple_choice', 'Từ nào thuộc nhóm “Đồ dùng học tập”?', 'thước kẻ', 'nô đùa', 'thân thiết', 'dạy dỗ', 'thước kẻ', null::jsonb, 'Thước kẻ là đồ dùng học tập.', 'tu_chi_su_vat', 7::int),
    (2::smallint, 'multiple_choice', 'Từ nào nói về công việc của thầy cô?', 'nô đùa', 'giảng bài', 'bút chì', 'cặp sách', 'giảng bài', null::jsonb, 'Thầy cô giảng bài cho học sinh.', 'mo_rong_von_tu', 7::int),
    (3::smallint, 'multiple_choice', 'Nhóm từ nào chỉ gồm các từ nói về bạn bè?', 'sách vở, bút chì, cặp sách', 'dạy dỗ, bảo ban, giảng bài', 'thân thiết, đoàn kết, nô đùa', 'thân thiết, thước kẻ, học bài', 'thân thiết, đoàn kết, nô đùa', null::jsonb, 'Bạn bè thì thân thiết, đoàn kết, cùng nô đùa.', 'mo_rong_von_tu', 7::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai là gì?', 'Bạn Lan rất chăm chỉ.', 'Bạn Lan đang đọc sách.', 'Bạn Lan chạy ra sân.', 'Bạn Lan là bạn thân của em.', 'Bạn Lan là bạn thân của em.', null::jsonb, 'Câu “Bạn Lan là bạn thân của em.” trả lời câu hỏi Ai là gì?', 'cau_ai_la_gi', 5::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 10 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 11: Ông bà – Từ ngữ về đồ dùng và công việc trong nhà (31 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 11, 100, 'Archimes: Ông bà – Từ ngữ về đồ dùng và công việc trong nhà', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 11', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền g hay gh: ___i nhớ', null, null, null, null, 'gh', null::jsonb, 'Viết gh trước i, e, ê: ghi nhớ.', 'chinh_ta_g_gh', 8::int),
    (1::smallint, 'text', 'Điền g hay gh: con ___à', null, null, null, null, 'g', null::jsonb, 'Viết g trước a: con gà.', 'chinh_ta_g_gh', 8::int),
    (1::smallint, 'text', 'Điền g hay gh: ___é thăm', null, null, null, null, 'gh', null::jsonb, 'Viết gh trước e: ghé thăm.', 'chinh_ta_g_gh', 8::int),
    (1::smallint, 'text', 'Điền g hay gh: ___ọng kính', null, null, null, null, 'g', null::jsonb, 'Viết g trước o: gọng kính.', 'chinh_ta_g_gh', 8::int),
    (1::smallint, 'text', 'Điền g hay gh: xôi ___ấc', null, null, null, null, 'g', null::jsonb, 'Viết g trước â: xôi gấc.', 'chinh_ta_g_gh', 8::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'ghồ ghề', 'gồ ghề', 'gồ gề', 'ghồ gề', 'gồ ghề', null::jsonb, 'Gh đứng trước ê, g đứng trước ô: gồ ghề.', 'chinh_ta_g_gh', 8::int),
    (1::smallint, 'multiple_choice', 'Chọn từ viết đúng (nơi trồng cây quanh nhà):', 'khu vường', 'khu vươn', 'khu vườn', null, 'khu vườn', null::jsonb, 'Viết đúng là “khu vườn” (vần ươn, dấu huyền).', 'chinh_ta_uon_uong', 8::int),
    (2::smallint, 'multiple_choice', 'Chọn từ viết đúng (con vật sống dưới bùn, mình dài và trơn):', 'con lườn', 'con lươn', 'con lương', null, 'con lươn', null::jsonb, 'Con lươn viết với vần ươn.', 'chinh_ta_uon_uong', 8::int),
    (2::smallint, 'multiple_choice', 'Chọn cách viết đúng tên dãy núi:', 'Trường Sơn', 'Trườn Sơn', 'Chường Sơn', null, 'Trường Sơn', null::jsonb, 'Viết đúng là Trường Sơn (tr, vần ương).', 'chinh_ta_uon_uong', 8::int),
    (2::smallint, 'multiple_choice', 'Chọn từ viết đúng:', 'ngang bướng', 'ngang bướn', 'ngang bứơng', null, 'ngang bướng', null::jsonb, 'Viết đúng là “ngang bướng” (vần ương).', 'chinh_ta_uon_uong', 8::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng thích hợp điền vào chỗ trống: “___ miện” (mũ của vua)', 'vương', 'lượn', 'lượng', 'vươn', 'vương', null::jsonb, 'Mũ của vua là vương miện.', 'chinh_ta_uon_uong', 8::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng thích hợp: “Mấy chú chim bay ___ vòng trên bầu trời.”', 'vươn', 'vương', 'lượng', 'lượn', 'lượn', null::jsonb, 'Chim bay lượn vòng.', 'chinh_ta_uon_uong', 8::int),
    (3::smallint, 'multiple_choice', 'Chọn tiếng thích hợp: “Cây non ___ mình lên đón nắng.”', 'lượn', 'lượng', 'vươn', 'vương', 'vươn', null::jsonb, '“Vươn mình” là vươn cao lên.', 'chinh_ta_uon_uong', 8::int),
    (3::smallint, 'multiple_choice', 'Từ nào chứa tiếng có vần “ươn” và chỉ con vật?', 'con vượn', 'con chuột', 'con gà', 'con hươu', 'con vượn', null::jsonb, '“Vượn” có vần ươn và là tên con vật.', 'chinh_ta_uon_uong', 8::int),
    (3::smallint, 'multiple_choice', 'Từ nào chứa tiếng có vần “ương” và chỉ hành động?', 'quê hương', 'nướng bánh', 'cái giường', 'con đường', 'nướng bánh', null::jsonb, '“Nướng” có vần ương và chỉ hành động.', 'chinh_ta_uon_uong', 8::int),
    (1::smallint, 'multiple_choice', 'Từ ngữ nào chỉ công việc gia đình?', 'nghe nhạc', 'tặng hoa', 'quét nhà', 'xem phim', 'quét nhà', null::jsonb, 'Quét nhà là công việc gia đình.', 'tu_ngu_viec_nha', 9::int),
    (1::smallint, 'multiple_choice', 'Từ ngữ nào KHÔNG chỉ công việc gia đình?', 'rửa bát', 'nấu cơm', 'trông em', 'cưỡi ngựa', 'cưỡi ngựa', null::jsonb, 'Cưỡi ngựa không phải việc nhà.', 'tu_ngu_viec_nha', 9::int),
    (2::smallint, 'multiple_choice', 'Nhóm nào chỉ gồm các công việc gia đình?', 'tưới cây, nấu cơm, đi chợ', 'xem phim, rửa bát, quét nhà', 'trông em, cưỡi ngựa, học bài', 'đọc truyện, nghe nhạc, tặng hoa', 'tưới cây, nấu cơm, đi chợ', null::jsonb, 'Tưới cây, nấu cơm, đi chợ đều là việc nhà.', 'tu_ngu_viec_nha', 9::int),
    (2::smallint, 'multiple_choice', '“Bé ngồi luồn chỉ / Cho bà ngồi khâu.”
Bạn nhỏ đã làm việc gì giúp bà?', 'khâu áo', 'quét nhà', 'luồn chỉ', 'nấu cơm', 'luồn chỉ', null::jsonb, 'Bé luồn chỉ để bà ngồi khâu.', 'tu_ngu_viec_nha', 9::int),
    (3::smallint, 'multiple_choice', '“Khi mẹ vắng nhà, em luộc khoai / … em cùng chị giã gạo / … em thổi cơm / … em nhổ cỏ vườn / … em quét sân và quét cổng.”
Việc nào KHÔNG có trong đoạn thơ?', 'nhổ cỏ vườn', 'rửa bát', 'luộc khoai', 'giã gạo', 'rửa bát', null::jsonb, 'Đoạn thơ không nhắc đến việc rửa bát.', 'tu_ngu_viec_nha', 10::int),
    (2::smallint, 'multiple_choice', 'Bạn nhỏ trong đoạn thơ “Khi mẹ vắng nhà” (luộc khoai, giã gạo, thổi cơm, quét sân…) có đức tính gì đáng quý?', 'nhút nhát', 'lười biếng', 'hay nghịch ngợm', 'chăm chỉ, thương mẹ', 'chăm chỉ, thương mẹ', null::jsonb, 'Bạn tự làm nhiều việc nhà giúp mẹ: chăm chỉ và thương mẹ.', 'doc_hieu', 10::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: “Có một cậu bé lười học nên không biết chữ ___”', 'dấu phẩy', 'dấu chấm hỏi', 'dấu chấm', null, 'dấu chấm', null::jsonb, 'Đây là câu kể nên cuối câu dùng dấu chấm.', 'dau_cau', 9::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: Bác bán kính hỏi: “Hay là cháu không biết đọc ___”', 'dấu phẩy', 'dấu chấm hỏi', 'dấu chấm', null, 'dấu chấm hỏi', null::jsonb, 'Bác hỏi cậu bé nên cuối câu dùng dấu chấm hỏi.', 'dau_cau', 9::int),
    (3::smallint, 'multiple_choice', '“Một hôm ___ cậu vào một cửa hàng để mua kính.” Chỗ trống cần điền dấu gì?', 'dấu chấm hỏi', 'dấu chấm', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách “Một hôm” với phần còn lại của câu.', 'dau_cau', 9::int),
    (2::smallint, 'multiple_choice', 'Truyện “Hòn đá nhẵn”: “Tôi bắt đầu tìm những viên đá, chọn kĩ lưỡng, tìm được một viên cuội tuyệt đẹp, nhẵn bóng như một viên bi.”
Bạn nhỏ tìm thấy gì bên bờ suối?', 'một viên cuội đẹp, nhẵn bóng như viên bi', 'một viên bi thủy tinh', 'một con cá nhỏ', 'một chiếc lá vàng', 'một viên cuội đẹp, nhẵn bóng như viên bi', null::jsonb, 'Bạn tìm được một viên cuội tuyệt đẹp, nhẵn bóng như một viên bi.', 'doc_hieu', 11::int),
    (2::smallint, 'multiple_choice', 'Truyện “Hòn đá nhẵn”: “– Sao con không nhặt đá ở bờ suối mà lại mất công tìm dưới nước? – Vì đá trên bờ đều thô ráp ạ.”
Vì sao bạn nhỏ không nhặt đá trên bờ?', 'Vì trên bờ không có đá.', 'Vì đá trên bờ đều thô ráp.', 'Vì đá trên bờ quá nặng.', 'Vì bà không cho nhặt.', 'Vì đá trên bờ đều thô ráp.', null::jsonb, 'Bạn nói: đá trên bờ đều thô ráp.', 'doc_hieu', 11::int),
    (3::smallint, 'multiple_choice', 'Truyện “Hòn đá nhẵn”: Vì sao viên cuội ở dòng suối lại nhẵn bóng?', 'Vì viên cuội còn rất nhỏ', 'Vì có người mài viên cuội', 'Nước và đá cọ xát làm mất chỗ gồ ghề', 'Vì viên cuội nằm phơi nắng', 'Nước và đá cọ xát làm mất chỗ gồ ghề', null::jsonb, 'Nhờ nước và viên đá cọ xát vào nhau mà chỗ gồ ghề, thô ráp biến mất.', 'doc_hieu', 11::int),
    (3::smallint, 'multiple_choice', 'Trong truyện “Hòn đá nhẵn”, bà nội bảo cháu hãy nghĩ ba mẹ giống như cái gì?', 'bờ suối', 'viên bi', 'viên cuội', 'dòng nước', 'dòng nước', null::jsonb, 'Bà nói: “Hãy nghĩ ba mẹ con giống như dòng nước.”', 'doc_hieu', 11::int),
    (3::smallint, 'multiple_choice', 'Câu chuyện “Hòn đá nhẵn” cho em bài học gì?', 'Phải được rèn luyện mới trưởng thành.', 'Không nên chơi gần bờ suối.', 'Muốn tìm đá đẹp phải lội xuống suối.', 'Đá muốn đẹp cần nhiều thời gian.', 'Phải được rèn luyện mới trưởng thành.', null::jsonb, 'Như viên đá được nước mài nhẵn, con người cần được rèn luyện mới trưởng thành.', 'doc_hieu', 12::int),
    (1::smallint, 'multiple_choice', 'Đồ vật nào dùng để ủi phẳng quần áo?', 'máy giặt', 'bàn là', 'tủ lạnh', 'lọ hoa', 'bàn là', null::jsonb, 'Bàn là dùng để ủi phẳng quần áo.', 'tu_ngu_do_dung', 12::int),
    (1::smallint, 'multiple_choice', 'Đồ vật nào giữ thực phẩm luôn tươi ngon?', 'bàn là', 'cái chổi', 'lọ hoa', 'tủ lạnh', 'tủ lạnh', null::jsonb, 'Tủ lạnh giữ thực phẩm tươi ngon.', 'tu_ngu_do_dung', 12::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 11 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 12: Cha mẹ – Từ ngữ về tình cảm, dấu phẩy (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 12, 100, 'Archimes: Cha mẹ – Từ ngữ về tình cảm, dấu phẩy', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 12', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ch hay tr: ___ẻ tre', null, null, null, null, 'ch', null::jsonb, 'Viết đúng là: chẻ tre.', 'chinh_ta_ch_tr', 13::int),
    (1::smallint, 'text', 'Điền ch hay tr: ___ung thủy', null, null, null, null, 'ch', null::jsonb, 'Viết đúng là: chung thủy.', 'chinh_ta_ch_tr', 13::int),
    (1::smallint, 'text', 'Điền ch hay tr: ___ách nhiệm', null, null, null, null, 'tr', null::jsonb, 'Viết đúng là: trách nhiệm.', 'chinh_ta_ch_tr', 13::int),
    (1::smallint, 'text', 'Điền ng hay ngh: ___ênh ngang', null, null, null, null, 'ngh', null::jsonb, 'Viết ngh trước i, e, ê: nghênh ngang.', 'chinh_ta_ng_ngh', 13::int),
    (1::smallint, 'text', 'Điền ng hay ngh: con ___ỗng', null, null, null, null, 'ng', null::jsonb, 'Viết ng trước a, o, ô, ơ, u, ư: con ngỗng.', 'chinh_ta_ng_ngh', 13::int),
    (1::smallint, 'text', 'Điền ng hay ngh: ___ỉ hè', null, null, null, null, 'ngh', null::jsonb, 'Viết ngh trước i: nghỉ hè.', 'chinh_ta_ng_ngh', 13::int),
    (2::smallint, 'text', 'Điền ng hay ngh: ___ẫm nghĩ', null, null, null, null, 'ng', null::jsonb, 'Trước â viết ng: ngẫm nghĩ.', 'chinh_ta_ng_ngh', 13::int),
    (2::smallint, 'multiple_choice', 'Chọn cách viết đúng của thành ngữ:', 'giây mơ rễ má', 'dây mơ dễ má', 'dây mơ rễ má', 'rây mơ giễ má', 'dây mơ rễ má', null::jsonb, 'Viết đúng là “dây mơ rễ má”.', 'chinh_ta_r_d_gi', 13::int),
    (2::smallint, 'multiple_choice', 'Chọn cách viết đúng của thành ngữ:', 'reo gió gặt bão', 'gieo dó gặt bão', 'gieo gió gặt bão', 'deo dó gặt bão', 'gieo gió gặt bão', null::jsonb, 'Viết đúng là “gieo gió gặt bão”.', 'chinh_ta_r_d_gi', 13::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Con gà ___ dưới gốc cây ngô.”', 'nghủ', 'ngủ', 'ngũ', null, 'ngủ', null::jsonb, 'Viết ng trước u; “ngủ” mang dấu hỏi.', 'chinh_ta_ng_ngh', 13::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “___ gần rơm lâu ngày cũng bén.”', 'Lửa', 'Nửa', 'Lữa', null, 'Lửa', null::jsonb, 'Viết đúng là “Lửa” (l, dấu hỏi).', 'chinh_ta_hoi_nga', 13::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: “___ điệu thục nữ”', 'Yểu', 'Yễu', 'Iểu', null, 'Yểu', null::jsonb, 'Viết đúng là “yểu điệu thục nữ”.', 'chinh_ta_hoi_nga', 13::int),
    (2::smallint, 'multiple_choice', 'Nhóm nào chỉ gồm các từ chỉ tình cảm?', 'tươi vui, yêu thương, nhìn ngắm', 'yêu thương, kính trọng, mến yêu', 'yêu thương, kính trọng, che chắn', 'hạnh phúc, mừng rỡ, vui chơi', 'yêu thương, kính trọng, mến yêu', null::jsonb, 'Yêu thương, kính trọng, mến yêu đều là từ chỉ tình cảm.', 'tu_ngu_tinh_cam', 14::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ tình cảm?', 'che chắn', 'vui chơi', 'nhìn ngắm', 'quý mến', 'quý mến', null::jsonb, '“Quý mến” là từ chỉ tình cảm.', 'tu_ngu_tinh_cam', 14::int),
    (1::smallint, 'multiple_choice', '“Chúng em luôn kính trọng thầy cô giáo.” Từ chỉ tình cảm trong câu là:', 'kính trọng', 'luôn', 'chúng em', 'thầy cô', 'kính trọng', null::jsonb, '“Kính trọng” là từ chỉ tình cảm.', 'tu_ngu_tinh_cam', 14::int),
    (2::smallint, 'text', 'Điền từ còn thiếu vào thành ngữ: “Trên ___ dưới nhường.”', null, null, null, null, 'kính', null::jsonb, 'Thành ngữ: Trên kính dưới nhường.', 'thanh_ngu', 14::int),
    (2::smallint, 'text', 'Điền từ còn thiếu vào thành ngữ: “Chị ngã em ___.”', null, null, null, null, 'nâng', null::jsonb, 'Thành ngữ: Chị ngã em nâng.', 'thanh_ngu', 14::int),
    (2::smallint, 'text', 'Điền từ còn thiếu vào thành ngữ: “Con ___ cháu thảo.”', null, null, null, null, 'hiền', null::jsonb, 'Thành ngữ: Con hiền cháu thảo.', 'thanh_ngu', 14::int),
    (2::smallint, 'text', 'Điền từ còn thiếu vào ca dao: “Anh ___ như thể tay chân / Rách lành đùm bọc dở hay đỡ đần.”', null, null, null, null, 'em', null::jsonb, 'Ca dao: Anh em như thể tay chân.', 'thanh_ngu', 14::int),
    (2::smallint, 'text', 'Điền từ còn thiếu: “___ người như thể thương thân.”', null, null, null, null, 'thương', null::jsonb, 'Tục ngữ: Thương người như thể thương thân.', 'thanh_ngu', 17::int),
    (3::smallint, 'multiple_choice', 'Chọn từ thích hợp: “Cha mẹ ___ con bằng trời, bằng bể.”', 'hiền', 'kính', 'thảo', 'thương', 'thương', null::jsonb, 'Cha mẹ thương con bằng trời, bằng bể.', 'thanh_ngu', 17::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy ĐÚNG?', 'Thưa cô giấy không nói, được đâu ạ!', 'Thưa cô, giấy không nói được đâu ạ!', 'Thưa, cô giấy không nói được đâu ạ!', 'Thưa cô giấy, không nói được đâu ạ!', 'Thưa cô, giấy không nói được đâu ạ!', null::jsonb, 'Dấu phẩy đặt sau lời gọi “Thưa cô”.', 'dau_phay', 14::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy ĐÚNG?', 'Ngày xưa ở làng, kia có hai em bé ở với bà.', 'Ngày xưa ở, làng kia có hai em bé ở với bà.', 'Ngày xưa, ở làng kia, có hai em bé ở với bà.', 'Ngày, xưa ở làng kia, có hai em bé ở với bà.', 'Ngày xưa, ở làng kia, có hai em bé ở với bà.', null::jsonb, 'Dấu phẩy ngăn cách “Ngày xưa”, “ở làng kia” với phần chính của câu.', 'dau_phay', 14::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Hoa, đào hoa mai là hai loài hoa nở vào mùa xuân.', 'Hoa đào hoa mai, là hai loài hoa nở vào mùa xuân.', 'Hoa đào, hoa mai là hai loài hoa nở vào mùa xuân.', null, 'Hoa đào, hoa mai là hai loài hoa nở vào mùa xuân.', null::jsonb, 'Dấu phẩy ngăn cách hai từ cùng loại “hoa đào”, “hoa mai”.', 'dau_phay', 17::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Ông bà rất kính mến các cháu.”, từ nào dùng CHƯA phù hợp?', 'kính mến', 'rất', 'ông bà', 'các cháu', 'kính mến', null::jsonb, 'Ông bà “yêu thương” các cháu; “kính mến” dùng cho người trên.', 'tu_ngu_tinh_cam', 17::int),
    (3::smallint, 'multiple_choice', '“Em rất kính trọng bạn bè.” Nên thay từ “kính trọng” bằng từ nào?', 'hiếu thảo', 'quý mến', 'kính yêu', 'phụng dưỡng', 'quý mến', null::jsonb, 'Với bạn bè, ta dùng “quý mến”.', 'tu_ngu_tinh_cam', 17::int),
    (2::smallint, 'multiple_choice', 'Truyện “Câu chuyện về quả cam”: quả cam do người cha hái lần lượt được tặng cho ai?', 'cậu con trai, người mẹ, người cha, người chị', 'cậu con trai, người chị, người mẹ, người cha', 'cậu con trai, người mẹ, người chị, người cha', null, 'cậu con trai, người chị, người mẹ, người cha', null::jsonb, 'Cha cho cậu con trai, cậu tặng chị, chị tặng mẹ, mẹ để phần cha.', 'doc_hieu', 16::int),
    (2::smallint, 'multiple_choice', '“Cậu bé cầm quả cam thích thú… Bỗng cậu nhớ đến chị: “Chị ấy đang làm cỏ, chắc rất mệt”.”
Vì sao cậu con trai không ăn quả cam?', 'Vì cậu không thích ăn cam.', 'Vì cậu nghĩ mẹ đang cuốc đất, rất khát.', 'Vì cậu nghĩ chị đang làm cỏ, chắc rất mệt.', 'Vì quả cam còn xanh.', 'Vì cậu nghĩ chị đang làm cỏ, chắc rất mệt.', null::jsonb, 'Cậu nhớ đến chị đang làm cỏ, chắc rất mệt nên tặng chị.', 'doc_hieu', 16::int),
    (2::smallint, 'multiple_choice', '“Buổi tối, nhìn quả cam trên bàn, người cha xoa đầu các con âu yếm. Sau đó, ông bổ quả cam thành bốn phần…”
Người cha đã làm gì với quả cam?', 'Bổ thành bốn phần để cả nhà cùng ăn', 'Đem cho hàng xóm', 'Ăn hết quả cam', 'Để nguyên trên bàn', 'Bổ thành bốn phần để cả nhà cùng ăn', null::jsonb, 'Người cha bổ quả cam thành bốn phần để cả nhà cùng ăn.', 'doc_hieu', 16::int),
    (3::smallint, 'multiple_choice', '“Câu chuyện về quả cam” khuyên chúng ta điều gì?', 'Nên để phần quà cho bố', 'Nên ăn nhiều cam cho chóng lớn', 'Nên trồng nhiều cây ăn quả', 'Biết quan tâm, chia sẻ, yêu thương người thân', 'Biết quan tâm, chia sẻ, yêu thương người thân', null::jsonb, 'Mỗi người đều nghĩ đến người thân: biết quan tâm, chia sẻ, yêu thương.', 'doc_hieu', 16::int),
    (1::smallint, 'multiple_choice', 'Trong dãy “thổi cơm, luộc rau, quét sân, vẽ tranh”, từ nào KHÔNG chỉ công việc gia đình?', 'vẽ tranh', 'luộc rau', 'thổi cơm', 'quét sân', 'vẽ tranh', null::jsonb, 'Vẽ tranh không phải công việc gia đình.', 'tu_ngu_viec_nha', 19::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai làm gì?', 'Chú Sơn là người xây bể nước cho nhà em.', 'Chiếc áo này là món quà mẹ tặng em.', 'Em là học sinh lớp 2.', 'Bác sĩ khám bệnh cho bệnh nhân.', 'Bác sĩ khám bệnh cho bệnh nhân.', null::jsonb, 'Câu “Bác sĩ khám bệnh cho bệnh nhân.” nói về hoạt động: Ai làm gì?', 'cau_ai_lam_gi', 19::int),
    (1::smallint, 'multiple_choice', 'Chọn từ chỉ hoạt động thích hợp: “Khi em bé khóc, anh phải ___ em bé.”', 'đánh', 'dỗ dành', 'mắng', 'trêu chọc', 'dỗ dành', null::jsonb, 'Khi em khóc, anh phải dỗ dành em.', 'tu_chi_hoat_dong', 19::int),
    (2::smallint, 'multiple_choice', 'Đoạn “Cơn giông”: “Một lúc sau gió dịu dần, mưa tạnh hẳn… Nắng vàng màu da chanh phủ lên cây một thứ ánh sáng dịu mát.”
Khi mưa tạnh, nắng có màu gì?', 'vàng óng', 'vàng tươi', 'vàng da chanh', 'vàng rực', 'vàng da chanh', null::jsonb, 'Nắng vàng màu da chanh.', 'doc_hieu', 18::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 12 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 13: Cha mẹ – Từ ngữ về công việc gia đình, câu Ai làm gì? (30 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 13, 100, 'Archimes: Cha mẹ – Từ ngữ về công việc gia đình, câu Ai làm gì?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 13', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền iê hay yê (không cần dấu thanh): “Con thu___n trôi trên sông.”', null, null, null, null, 'yê', '["yề"]'::jsonb, 'Sau âm đệm u viết yê: thuyền.', 'chinh_ta_ie_ye', 20::int),
    (1::smallint, 'text', 'Điền iê hay yê (không cần dấu thanh): “Em gọi đ___n rủ Hoa đi sinh nhật Lan.”', null, null, null, null, 'iê', '["iệ"]'::jsonb, 'Có âm đầu đ, không có âm đệm nên viết iê: điện.', 'chinh_ta_ie_ye', 20::int),
    (2::smallint, 'text', 'Điền iê hay yê (không cần dấu thanh): “Em thích đọc quyển tru___n tranh.”', null, null, null, null, 'yê', '["yệ"]'::jsonb, 'Sau âm đệm u viết yê: truyện.', 'chinh_ta_ie_ye', 20::int),
    (1::smallint, 'text', 'Điền r, d hay gi: “Chưa ___à mà đã có râu”', null, null, null, null, 'gi', null::jsonb, 'Viết đúng là: chưa già.', 'chinh_ta_r_d_gi', 20::int),
    (1::smallint, 'text', 'Điền r, d hay gi: “Cái con ___ế suốt đêm thâu hát gì”', null, null, null, null, 'd', null::jsonb, 'Viết đúng là: con dế.', 'chinh_ta_r_d_gi', 20::int),
    (1::smallint, 'text', 'Điền r, d hay gi: “Không chân con ___ắn vẫn đi”', null, null, null, null, 'r', null::jsonb, 'Viết đúng là: con rắn.', 'chinh_ta_r_d_gi', 20::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Dế Mèn và Dế Trũi ___ nhau đi ngao du thiên hạ.”', 'rủ', 'dủ', 'giủ', null, 'rủ', null::jsonb, 'Viết đúng là “rủ nhau”.', 'chinh_ta_r_d_gi', 20::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Chị tôi ___ được giải Nhất trong cuộc thi Viết chữ đẹp.”', 'dành', 'rành', 'giành', null, 'giành', null::jsonb, '“Giành” nghĩa là cố gắng để đạt được (giành giải).', 'chinh_ta_r_d_gi', 20::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Chiếc ví ___ này rất đẹp!”', 'ra', 'da', 'gia', null, 'da', null::jsonb, 'Ví làm bằng da: ví da.', 'chinh_ta_r_d_gi', 20::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Bạn Hoa đọc bài to, rõ ___.”', 'ràng', 'dàng', 'giàng', null, 'ràng', null::jsonb, 'Viết đúng là “rõ ràng”.', 'chinh_ta_r_d_gi', 20::int),
    (2::smallint, 'text', '“Cõng nước làm mưa rào / Cho xanh tươi đồng giuộng.” Từ “giuộng” viết sai. Viết lại cho đúng: đồng ___', null, null, null, null, 'ruộng', null::jsonb, 'Viết đúng là “đồng ruộng”.', 'chinh_ta_r_d_gi', 20::int),
    (2::smallint, 'multiple_choice', 'Trong câu thơ “Vượt sông rài biển rộng”, tiếng nào viết SAI chính tả?', 'rộng', 'rài', 'sông', 'vượt', 'rài', null::jsonb, '“Rài” phải viết là “dài”: vượt sông dài biển rộng.', 'chinh_ta_r_d_gi', 20::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Cá heo sinh con và nuôi con bằng ___.”', 'sửa', 'xữa', 'sữa', null, 'sữa', null::jsonb, '“Sữa” viết với s và dấu ngã.', 'chinh_ta_hoi_nga', 21::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Những ___ mây màu tro kết đặc quánh lách qua lưng núi.”', 'tãng', 'tảng', 'táng', null, 'tảng', null::jsonb, '“Tảng mây” viết với dấu hỏi.', 'chinh_ta_hoi_nga', 21::int),
    (1::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai làm gì?', 'Cả nhà gấu đi bẻ măng.', 'Hoa cải vàng xuộm trên đất bãi.', 'Sách vở là người bạn đồng hành của em.', null, 'Cả nhà gấu đi bẻ măng.', null::jsonb, '“Cả nhà gấu đi bẻ măng” nói về hoạt động: Ai làm gì?', 'cau_ai_lam_gi', 21::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Bà chia quà cho các cháu.”, bộ phận trả lời câu hỏi “Làm gì?” là:', 'Bà', 'các cháu', 'chia quà cho các cháu', 'Bà chia quà', 'chia quà cho các cháu', null::jsonb, 'Bà làm gì? – chia quà cho các cháu.', 'cau_ai_lam_gi', 22::int),
    (2::smallint, 'multiple_choice', 'Trong câu “An và Bình đang chơi cờ.”, bộ phận trả lời câu hỏi “Ai?” là:', 'An và Bình', 'An', 'đang chơi cờ', 'chơi cờ', 'An và Bình', null::jsonb, 'Ai đang chơi cờ? – An và Bình.', 'cau_ai_lam_gi', 22::int),
    (3::smallint, 'multiple_choice', 'Cách tách nào ĐÚNG hai bộ phận “Ai? / Làm gì?” của câu?', 'Bác nông dân khẩn trương / thu hoạch lúa.', 'Bác nông dân khẩn trương thu hoạch / lúa.', 'Bác / nông dân khẩn trương thu hoạch lúa.', 'Bác nông dân / khẩn trương thu hoạch lúa.', 'Bác nông dân / khẩn trương thu hoạch lúa.', null::jsonb, 'Ai? – Bác nông dân. Làm gì? – khẩn trương thu hoạch lúa.', 'cau_ai_lam_gi', 22::int),
    (3::smallint, 'multiple_choice', 'Cách tách nào ĐÚNG hai bộ phận “Cái gì? / Làm gì?” của câu?', 'Ông / mặt trời xuống núi đi ngủ.', 'Ông mặt trời xuống núi / đi ngủ.', 'Ông mặt trời / xuống núi đi ngủ.', null, 'Ông mặt trời / xuống núi đi ngủ.', null::jsonb, 'Cái gì? – Ông mặt trời. Làm gì? – xuống núi đi ngủ.', 'cau_ai_lam_gi', 22::int),
    (2::smallint, 'multiple_choice', '“Em làm dần từng việc: quét nhà, thả gà, cho lợn ăn… em phơi quần áo, rải rơm ra sân phơi… em vào nhóm bếp, nấu cháo cho bà.”
Việc nào bạn nhỏ KHÔNG làm?', 'rửa bát', 'quét nhà', 'thả gà', 'nấu cháo', 'rửa bát', null::jsonb, 'Đoạn văn không nhắc đến việc rửa bát.', 'tu_ngu_viec_nha', 22::int),
    (2::smallint, 'multiple_choice', 'Truyện “Sinh nhật mẹ”: “Cậu bé lấy một bìa cứng, gấp thành hình dạng tấm thiệp… cắt một tờ giấy màu vàng thành hình chiếc lẵng hoa, dán trên mặt tấm thiệp.”
Hoàng tự làm món quà gì tặng mẹ?', 'một tấm thiệp khổng lồ', 'một lẵng hoa tươi', 'một tấm thiệp có lẵng hoa', 'một bức tranh vẽ mẹ', 'một tấm thiệp có lẵng hoa', null::jsonb, 'Hoàng làm một tấm thiệp có lẵng hoa.', 'doc_hieu', 24::int),
    (2::smallint, 'multiple_choice', 'Món quà sinh nhật Hoàng tự tay làm tặng mẹ thể hiện tình cảm gì của Hoàng với mẹ?', 'nhớ thương', 'yêu thương', 'tôn trọng', null, 'yêu thương', null::jsonb, 'Hoàng tự tay làm quà và chúc mẹ – thể hiện tình yêu thương mẹ.', 'doc_hieu', 24::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp “đang / bố mẹ / chuẩn bị / em / bữa cơm tối” thành câu đúng:', 'Bữa cơm tối đang chuẩn bị bố mẹ em.', 'Em bố mẹ đang chuẩn bị bữa cơm tối.', 'Bố mẹ đang em chuẩn bị bữa cơm tối.', 'Bố mẹ em đang chuẩn bị bữa cơm tối.', 'Bố mẹ em đang chuẩn bị bữa cơm tối.', null::jsonb, 'Câu đúng: Bố mẹ em / đang chuẩn bị bữa cơm tối.', 'sap_xep_cau', 25::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp “vắt vẻo / các em bé / trên / ngồi / lưng trâu” thành câu đúng:', 'Các em bé vắt vẻo lưng trâu trên ngồi.', 'Các em bé ngồi vắt vẻo trên lưng trâu.', 'Trên các em bé ngồi vắt vẻo lưng trâu.', 'Lưng trâu ngồi vắt vẻo trên các em bé.', 'Các em bé ngồi vắt vẻo trên lưng trâu.', null::jsonb, 'Câu đúng: Các em bé / ngồi vắt vẻo trên lưng trâu.', 'sap_xep_cau', 25::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Sáng sớm, bà con nông dân đã kéo nhau ra đồng gặt lúa.”, bộ phận trả lời câu hỏi “Ai?” là:', 'đã kéo nhau', 'Sáng sớm', 'ra đồng gặt lúa', 'bà con nông dân', 'bà con nông dân', null::jsonb, 'Ai kéo nhau ra đồng gặt lúa? – bà con nông dân.', 'cau_ai_lam_gi', 25::int),
    (1::smallint, 'text', 'Điền d, r hay gi: “Cô ___áo em tre trẻ”', null, null, null, null, 'gi', null::jsonb, 'Viết đúng là: cô giáo.', 'chinh_ta_r_d_gi', 26::int),
    (1::smallint, 'text', 'Điền d, r hay gi: “___ạy em hát rất hay”', null, null, null, null, 'd', null::jsonb, 'Viết đúng là: dạy em.', 'chinh_ta_r_d_gi', 26::int),
    (3::smallint, 'multiple_choice', 'Câu thơ “Mùa hè cung nghi” (chữ in đậm chưa có dấu) viết đúng là:', 'Mùa hè cũng nghỉ', 'Mùa hè củng nghỉ', 'Mùa hè củng nghĩ', 'Mùa hè cũng nghĩ', 'Mùa hè cũng nghỉ', null::jsonb, '“Cũng” mang dấu ngã; “nghỉ” (nghỉ ngơi) mang dấu hỏi.', 'chinh_ta_hoi_nga', 26::int),
    (2::smallint, 'multiple_choice', 'Chọn bộ phận thích hợp để được câu kiểu Ai làm gì?: “Cô giáo ___”', 'rất hiền và xinh.', 'giảng bài cho cả lớp.', 'là một bông hoa.', null, 'giảng bài cho cả lớp.', null::jsonb, '“Cô giáo giảng bài cho cả lớp.” nói về hoạt động.', 'cau_ai_lam_gi', 26::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp các câu thành đoạn văn:
(a) Tuấn khuyên bạn không nên hái hoa bẻ cành.
(b) Thấy một bông hoa đẹp, Lan đưa tay định hái.
(c) Lan và các bạn cùng vào vườn hoa chơi.
(d) Lan nghe lời bạn, không bao giờ hái hoa nữa.', 'c – a – b – d', 'c – b – a – d', 'b – c – a – d', 'a – b – c – d', 'c – b – a – d', null::jsonb, 'Vào vườn (c) → định hái hoa (b) → Tuấn khuyên (a) → Lan nghe lời (d).', 'sap_xep_cau', 27::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 13 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 14: Anh em – Từ ngữ về tình cảm gia đình, câu Ai làm gì? (29 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 14, 100, 'Archimes: Anh em – Từ ngữ về tình cảm gia đình, câu Ai làm gì?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 14', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (2::smallint, 'text', '“Huy học tập rất tín bộ.” Tiếng “tín” viết sai. Viết lại cho đúng: rất ___ bộ', null, null, null, null, 'tiến', null::jsonb, 'Viết đúng là “tiến bộ” (vần iên).', 'chinh_ta_i_ie', 28::int),
    (2::smallint, 'text', '“Các bạn đã có nhiều kỉ nịm đẹp với nhau.” Viết lại cho đúng: kỉ ___', null, null, null, null, 'niệm', null::jsonb, 'Viết đúng là “kỉ niệm” (vần iêm).', 'chinh_ta_i_ie', 28::int),
    (2::smallint, 'text', '“Bệnh vịn là nơi khám chữa bệnh.” Viết lại cho đúng: bệnh ___', null, null, null, null, 'viện', null::jsonb, 'Viết đúng là “bệnh viện” (vần iên).', 'chinh_ta_i_ie', 28::int),
    (1::smallint, 'text', 'Điền ăt hay ăc (không cần dấu thanh): “Lúa thu nhuộm s___ vàng”', null, null, null, null, 'ăc', '["ắc"]'::jsonb, 'Viết đúng là: sắc vàng.', 'chinh_ta_at_ac', 28::int),
    (1::smallint, 'text', 'Điền ăt hay ăc (không cần dấu thanh): “Đón mùa g___ mới sang”', null, null, null, null, 'ăt', '["ặt"]'::jsonb, 'Viết đúng là: mùa gặt.', 'chinh_ta_at_ac', 28::int),
    (1::smallint, 'text', 'Điền i hay iê (không cần dấu thanh): “Vì sao khi quả ch___n / Lại ngạt ngào hương thơm”', null, null, null, null, 'i', '["í"]'::jsonb, 'Viết đúng là: quả chín.', 'chinh_ta_i_ie', 28::int),
    (1::smallint, 'text', 'Điền i hay iê (không cần dấu thanh): “Quả đánh t___ng mười phương”', null, null, null, null, 'iê', '["iế"]'::jsonb, 'Viết đúng là: đánh tiếng.', 'chinh_ta_i_ie', 28::int),
    (1::smallint, 'text', 'Điền i hay iê: “Mời ch___m về múa hát”', null, null, null, null, 'i', null::jsonb, 'Viết đúng là: chim.', 'chinh_ta_i_ie', 28::int),
    (1::smallint, 'text', 'Điền l hay n: “___ăm nay, Mai lên tám tuổi.”', null, null, null, null, 'n', null::jsonb, 'Viết đúng là: năm nay.', 'chinh_ta_l_n', 28::int),
    (1::smallint, 'text', 'Điền l hay n: “Mai chăm ___o luyện chữ.”', null, null, null, null, 'l', null::jsonb, 'Viết đúng là: chăm lo.', 'chinh_ta_l_n', 28::int),
    (1::smallint, 'text', 'Điền l hay n: “Cả lớp im ___ặng lắng nghe.”', null, null, null, null, 'l', null::jsonb, 'Viết đúng là: im lặng.', 'chinh_ta_l_n', 28::int),
    (2::smallint, 'multiple_choice', 'Chọn câu tục ngữ viết đúng chính tả:', 'Một cây nàm chẳng lên non', 'Một cây nàm chẳng nên non', 'Một cây làm chẳng nên non', 'Một cây làm chẳng lên lon', 'Một cây làm chẳng nên non', null::jsonb, 'Viết đúng: “Một cây làm chẳng nên non”.', 'chinh_ta_l_n', 28::int),
    (1::smallint, 'multiple_choice', 'Từ nào nói về tình cảm yêu thương giữa anh chị em?', 'giặt quần áo', 'quét nhà', 'hòa thuận', 'thổi cơm', 'hòa thuận', null::jsonb, 'Anh chị em hòa thuận, yêu thương nhau.', 'tu_ngu_tinh_cam', 33::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG nói về tình cảm giữa anh chị em?', 'chăm sóc', 'nhặt rau', 'yêu quý', 'bảo ban', 'nhặt rau', null::jsonb, '“Nhặt rau” là công việc nhà, không chỉ tình cảm.', 'tu_ngu_tinh_cam', 33::int),
    (2::smallint, 'multiple_choice', '“Lan yêu quý bà lắm… Bà ôm Lan vào lòng mỉm cười, âu yếm nói: “Cháu của bà ngoan quá!””
Từ nào chỉ tình cảm bà cháu?', 'âu yếm', 'ngoan', 'mỉm cười', 'ôm', 'âu yếm', null::jsonb, '“Âu yếm” là từ chỉ tình cảm yêu thương.', 'tu_ngu_tinh_cam', 29::int),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ tình cảm của cháu đối với ông bà?', 'bảo ban', 'chiều chuộng', 'nuôi nấng', 'kính yêu', 'kính yêu', null::jsonb, 'Cháu kính yêu ông bà.', 'tu_ngu_tinh_cam', 29::int),
    (3::smallint, 'multiple_choice', 'Từ nào chỉ tình cảm của bố mẹ đối với con cái?', 'vâng lời', 'hiếu thảo', 'yêu thương', 'kính trọng', 'yêu thương', null::jsonb, 'Bố mẹ yêu thương con; hiếu thảo, vâng lời, kính trọng là của con với bố mẹ.', 'tu_ngu_tinh_cam', 29::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Mẹ ôm bé Hoa vào lòng.”, bộ phận trả lời câu hỏi “Làm gì?” là:', 'vào lòng', 'Mẹ', 'bé Hoa', 'ôm bé Hoa vào lòng', 'ôm bé Hoa vào lòng', null::jsonb, 'Mẹ làm gì? – ôm bé Hoa vào lòng.', 'cau_ai_lam_gi', 30::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai làm gì?', 'Lớp 2A4 rất đoàn kết.', 'Lớp 2A4 là lớp của em.', 'Lớp 2A4 đang tập thể dục buổi sáng.', null, 'Lớp 2A4 đang tập thể dục buổi sáng.', null::jsonb, 'Câu nói về hoạt động “tập thể dục” – kiểu Ai làm gì?', 'cau_ai_lam_gi', 33::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Buổi sáng, bố mẹ đưa bé tới trường.”, bộ phận trả lời câu hỏi “Ai?” là:', 'bố mẹ', 'tới trường', 'Buổi sáng', 'bé', 'bố mẹ', null::jsonb, 'Ai đưa bé tới trường? – bố mẹ.', 'cau_ai_lam_gi', 33::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Hằng ngày, bé giúp mẹ dọn dẹp nhà cửa.”, bộ phận trả lời câu hỏi “Làm gì?” là:', 'nhà cửa', 'giúp mẹ dọn dẹp nhà cửa', 'Hằng ngày', 'bé giúp mẹ', 'giúp mẹ dọn dẹp nhà cửa', null::jsonb, 'Bé làm gì? – giúp mẹ dọn dẹp nhà cửa.', 'cau_ai_lam_gi', 33::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: “– Chị Gió đi đâu mà vội thế ___”', 'dấu chấm hỏi', 'dấu chấm', 'dấu phẩy', null, 'dấu chấm hỏi', null::jsonb, 'Đây là câu hỏi nên dùng dấu chấm hỏi.', 'dau_cau', 33::int),
    (2::smallint, 'multiple_choice', '“Cô Mây suốt ngày bay nhởn nhơ ___ rong chơi.” Chỗ trống cần điền dấu gì?', 'dấu phẩy', 'dấu chấm hỏi', 'dấu chấm', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách hai hoạt động “bay nhởn nhơ”, “rong chơi”.', 'dau_cau', 33::int),
    (3::smallint, 'multiple_choice', '“– Tôi đang đi rủ các bạn Mây về làm mưa đây ___ Cô có muốn làm mưa không ___”
Hai chỗ trống lần lượt điền dấu gì?', 'dấu chấm hỏi; dấu chấm hỏi', 'dấu phẩy; dấu chấm', 'dấu chấm hỏi; dấu chấm', 'dấu chấm; dấu chấm hỏi', 'dấu chấm; dấu chấm hỏi', null::jsonb, 'Câu đầu là câu kể (dấu chấm), câu sau là câu hỏi (dấu chấm hỏi).', 'dau_cau', 33::int),
    (2::smallint, 'multiple_choice', 'Khi viết tin nhắn, cuối lời nhắn em cần ghi gì?', 'tên trường học', 'địa chỉ nhà', 'tên của mình', 'ngày sinh của mình', 'tên của mình', null::jsonb, 'Tin nhắn cần xưng tên người viết ở cuối.', 'viet_tin_nhan', 30::int),
    (2::smallint, 'multiple_choice', 'Truyện “Một người anh như thế”: “Tôi được tặng một chiếc xe đạp rất đẹp nhân dịp sinh nhật của mình.”
Bạn nhỏ được anh trai tặng gì?', 'một chiếc ô tô', 'một chiếc xe lăn', 'một chiếc xe đạp', null, 'một chiếc xe đạp', null::jsonb, 'Anh trai tặng bạn nhỏ một chiếc xe đạp.', 'doc_hieu', 32::int),
    (3::smallint, 'multiple_choice', '“– Ước gì tớ có thể trở thành một người anh như thế! – Cậu ấy nói chậm rãi…”
Cậu bé ở công viên ước điều gì?', 'Có một chiếc xe đạp thật đẹp', 'Trở thành một người anh như thế', 'Được đi chơi công viên', 'Có một người anh tặng mình xe', 'Trở thành một người anh như thế', null::jsonb, 'Cậu ước trở thành một người anh tốt như anh của bạn nhỏ.', 'doc_hieu', 32::int),
    (2::smallint, 'multiple_choice', 'Truyện “Một người anh như thế”: cậu bé hứa sẽ mua tặng em trai nhỏ tàn tật món quà gì?', 'chiếc xe lăn', 'quả bóng', 'chiếc xe đạp', 'chiếc ô tô đồ chơi', 'chiếc xe lăn', null::jsonb, 'Cậu nói: “…anh sẽ mua tặng em chiếc xe lăn, em nhé!”', 'doc_hieu', 32::int),
    (3::smallint, 'multiple_choice', 'Câu chuyện “Một người anh như thế” nói về tình cảm của ai với ai?', 'của anh với em', 'của mẹ với con', 'của hai người bạn', 'của em với anh', 'của anh với em', null::jsonb, 'Câu chuyện nói về tình thương của người anh dành cho em.', 'doc_hieu', 32::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 14 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 15: Anh em – Từ chỉ đặc điểm, câu Ai thế nào? (28 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 15, 100, 'Archimes: Anh em – Từ chỉ đặc điểm, câu Ai thế nào?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 15', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ai hay ay (không cần dấu thanh): “Mẹ c___ khăn cho bé”', null, null, null, null, 'ai', '["ài"]'::jsonb, 'Viết đúng là: mẹ cài khăn.', 'chinh_ta_ai_ay', 34::int),
    (1::smallint, 'text', 'Điền ai hay ay: “Gió thổi khăn b___ bay”', null, null, null, null, 'ay', null::jsonb, 'Viết đúng là: bay bay.', 'chinh_ta_ai_ay', 34::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Mưa phùn gió ___”', 'bắc', 'bấc', 'bất', null, 'bấc', null::jsonb, 'Thành ngữ: Mưa phùn gió bấc.', 'chinh_ta_at_ac', 34::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Đội trời đạp ___”', 'đất', 'đắt', 'đấc', null, 'đất', null::jsonb, 'Thành ngữ: Đội trời đạp đất.', 'chinh_ta_at_ac', 34::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: “Ngủ gà ngủ ___”', 'gặc', 'gấc', 'gật', null, 'gật', null::jsonb, 'Thành ngữ: Ngủ gà ngủ gật.', 'chinh_ta_at_ac', 34::int),
    (2::smallint, 'text', 'Điền ât hay âc (không cần dấu thanh): “Gió mát, chú chìm vào gi___ ngủ.”', null, null, null, null, 'âc', '["ấc"]'::jsonb, 'Viết đúng là: giấc ngủ.', 'chinh_ta_at_ac', 34::int),
    (1::smallint, 'text', 'Điền s hay x: “Những cành ___oan khẳng khiu đương trổ lá.”', null, null, null, null, 'x', null::jsonb, 'Viết đúng là: cành xoan.', 'chinh_ta_s_x', 34::int),
    (1::smallint, 'text', 'Điền s hay x: “Rặng râm bụt cũng ___ắp có nụ.”', null, null, null, null, 's', null::jsonb, 'Viết đúng là: sắp có nụ.', 'chinh_ta_s_x', 34::int),
    (1::smallint, 'text', 'Điền s hay x: “Chim bay về bầu trời ___anh thẳm.”', null, null, null, null, 'x', null::jsonb, 'Viết đúng là: xanh thẳm.', 'chinh_ta_s_x', 34::int),
    (1::smallint, 'text', 'Điền s hay x: “Một chú ___ơn ca sà xuống.”', null, null, null, null, 's', null::jsonb, 'Viết đúng là: sơn ca.', 'chinh_ta_s_x', 34::int),
    (2::smallint, 'multiple_choice', 'Chọn cách viết đúng: “Cúc ơi! Cúc ___ làm sao!”', 'sinh sắn', 'sinh xắn', 'xinh sắn', 'xinh xắn', 'xinh xắn', null::jsonb, 'Viết đúng là “xinh xắn” (cả hai tiếng đều viết x).', 'chinh_ta_s_x', 34::int),
    (1::smallint, 'multiple_choice', 'Từ nào là từ chỉ đặc điểm?', 'trung thu', 'xanh biếc', 'hoa đào', 'mùa xuân', 'xanh biếc', null::jsonb, '“Xanh biếc” nêu màu sắc – là từ chỉ đặc điểm.', 'tu_chi_dac_diem', 36::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG phải từ chỉ đặc điểm?', 'đỏ rực', 'vàng ươm', 'hoa phượng vĩ', 'mát mẻ', 'hoa phượng vĩ', null::jsonb, '“Hoa phượng vĩ” là từ chỉ sự vật.', 'tu_chi_dac_diem', 36::int),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm trong câu “Hoa sen đỏ, nhị sen vàng tỏa hương thơm lừng.”?', 'tỏa', 'nhị sen', 'hoa sen', 'thơm lừng', 'thơm lừng', null::jsonb, '“Thơm lừng” nêu đặc điểm của hương sen.', 'tu_chi_dac_diem', 35::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Những tán lá phượng xanh um, mát rượi.”, bộ phận trả lời câu hỏi “Thế nào?” là:', 'xanh um, mát rượi', 'Những tán lá phượng', 'tán lá', 'phượng xanh um', 'xanh um, mát rượi', null::jsonb, 'Những tán lá phượng thế nào? – xanh um, mát rượi.', 'cau_ai_the_nao', 36::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Hoa sữa nhỏ li ti, trắng ngà, thơm ngát.”, bộ phận trả lời câu hỏi “Cái gì?” là:', 'trắng ngà, thơm ngát', 'Hoa sữa', 'nhỏ li ti', 'Hoa sữa nhỏ', 'Hoa sữa', null::jsonb, 'Cái gì nhỏ li ti, trắng ngà, thơm ngát? – Hoa sữa.', 'cau_ai_the_nao', 36::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Trong khu rừng nhỏ, Thỏ và Sóc đều rất thông minh, nhanh nhẹn.”, bộ phận trả lời câu hỏi “Con gì?” là:', 'Thỏ', 'khu rừng nhỏ', 'Thỏ và Sóc', 'thông minh, nhanh nhẹn', 'Thỏ và Sóc', null::jsonb, 'Con gì thông minh, nhanh nhẹn? – Thỏ và Sóc.', 'cau_ai_the_nao', 36::int),
    (3::smallint, 'multiple_choice', 'Trong câu “Càng về sáng, tiết trời càng lạnh giá.”, bộ phận trả lời câu hỏi “Thế nào?” là:', 'về sáng', 'tiết trời', 'Càng về sáng', 'càng lạnh giá', 'càng lạnh giá', null::jsonb, 'Tiết trời thế nào? – càng lạnh giá.', 'cau_ai_the_nao', 36::int),
    (3::smallint, 'multiple_choice', 'Câu nào viết theo mẫu Ai là gì?', 'Tất cả đều lóng lánh, lung linh trong nắng.', 'Hàng ngàn bông hoa là hàng ngàn ngọn lửa hồng tươi.', 'Mùa xuân, cây gạo gọi đến bao nhiêu là chim.', null, 'Hàng ngàn bông hoa là hàng ngàn ngọn lửa hồng tươi.', null::jsonb, 'Câu có “là” giới thiệu: Hàng ngàn bông hoa là hàng ngàn ngọn lửa hồng tươi.', 'kieu_cau', 36::int),
    (3::smallint, 'multiple_choice', 'Câu “Mùa xuân, cây gạo gọi đến bao nhiêu là chim.” thuộc kiểu câu nào?', 'Ai thế nào?', 'Ai là gì?', 'Ai làm gì?', null, 'Ai làm gì?', null::jsonb, 'Cây gạo làm gì? – gọi đến bao nhiêu là chim.', 'kieu_cau', 36::int),
    (2::smallint, 'multiple_choice', 'Câu “Tất cả đều lóng lánh, lung linh trong nắng.” thuộc kiểu câu nào?', 'Ai thế nào?', 'Ai là gì?', 'Ai làm gì?', null, 'Ai thế nào?', null::jsonb, 'Tất cả thế nào? – lóng lánh, lung linh.', 'kieu_cau', 36::int),
    (2::smallint, 'multiple_choice', 'Truyện “Tôi có em rồi”: “Tôi là một chú chuột túi bé con. Cả ngày tôi ở trong cái túi ấm áp của mẹ.”
Khi còn bé, chú chuột túi thường ở đâu?', 'trong hang', 'trong chiếc túi ấm áp của mẹ', 'dưới gốc cây', 'trong vòng tay của bố', 'trong chiếc túi ấm áp của mẹ', null::jsonb, 'Chuột túi ở trong cái túi ấm áp của mẹ.', 'doc_hieu', 39::int),
    (3::smallint, 'multiple_choice', '“– Nhưng túi của mẹ chỉ đủ cho một đứa, vậy em bé sẽ ngủ ở đâu hả bố?… Chẳng lẽ từ nay trở đi, tôi sẽ phải nhảy lóc cóc theo mẹ?”
Vì sao chuột túi không vui khi nghe tin sắp có em?', 'Vì sẽ không được nằm trong túi của mẹ nữa', 'Vì bố mắng nó', 'Vì không thích trở thành chàng trai', 'Vì không thích có em gái', 'Vì sẽ không được nằm trong túi của mẹ nữa', null::jsonb, 'Chuột túi biết sẽ phải nhường túi của mẹ cho em.', 'doc_hieu', 39::int),
    (2::smallint, 'multiple_choice', '“Thế rồi em của tôi ra đời… Tôi hãnh diện vì mình có một cô em gái. Đi đâu, gặp ai tôi cũng hớn hở khoe.”
Chuột túi cảm thấy thế nào khi em bé ra đời?', 'không khoái tí nào', 'buồn và giận bố', 'rất hãnh diện, gặp ai cũng khoe', 'cảm thấy tủi thân', 'rất hãnh diện, gặp ai cũng khoe', null::jsonb, 'Chuột túi hãnh diện, đi đâu cũng khoe có em.', 'doc_hieu', 39::int),
    (3::smallint, 'multiple_choice', 'Nhóm nào chỉ gồm những từ chỉ đặc điểm?', 'chuột túi, nhỏ xíu, xinh, dễ thương', 'ấm áp, nhỏ xíu, xinh, dễ thương', 'ấm áp, nhỏ xíu, xinh, em bé', null, 'ấm áp, nhỏ xíu, xinh, dễ thương', null::jsonb, '“Chuột túi”, “em bé” là từ chỉ sự vật nên loại hai nhóm kia.', 'tu_chi_dac_diem', 39::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai thế nào?', 'Tôi là một chú chuột túi bé con.', 'Bố ôm tôi vào lòng.', 'Em nhỏ xíu và rất xinh.', null, 'Em nhỏ xíu và rất xinh.', null::jsonb, 'Em thế nào? – nhỏ xíu và rất xinh.', 'cau_ai_the_nao', 40::int),
    (1::smallint, 'multiple_choice', 'Điền dấu sắc hay dấu nặng: “T___c bay phơ phất” – chữ viết đúng là:', 'Toc', 'Tóc', 'Tọc', null, 'Tóc', null::jsonb, 'Viết đúng là “Tóc” (dấu sắc).', 'chinh_ta_dau_thanh', 40::int),
    (2::smallint, 'multiple_choice', 'Câu thơ “Lăn lôi bờ sông” (chưa có dấu ở chữ in đậm) viết đúng là:', 'Lặn lối bờ sông', 'Lắn lội bờ sông', 'Lặn lội bờ sông', 'Lắn lối bờ sông', 'Lặn lội bờ sông', null::jsonb, 'Viết đúng là “lặn lội” (cả hai tiếng dấu nặng).', 'chinh_ta_dau_thanh', 40::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 15 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 16: Bạn trong nhà – Từ chỉ tính chất, câu Ai thế nào? (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 16, 100, 'Archimes: Bạn trong nhà – Từ chỉ tính chất, câu Ai thế nào?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 16', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền tr hay ch: “Nhà em ___eo ảnh Bác Hồ”', null, null, null, null, 'tr', null::jsonb, 'Viết đúng là: treo ảnh.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'text', 'Điền tr hay ch: “Bên ___ên là một lá cờ đỏ tươi”', null, null, null, null, 'tr', null::jsonb, 'Viết đúng là: bên trên.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'text', 'Điền tr hay ch: “Bác nhìn ___úng cháu vui chơi”', null, null, null, null, 'ch', null::jsonb, 'Viết đúng là: chúng cháu.', 'chinh_ta_ch_tr', 41::int),
    (2::smallint, 'text', 'Điền tr hay ch: “___ồng rau, quét bếp, đuổi gà”', null, null, null, null, 'tr', null::jsonb, 'Viết đúng là: trồng rau.', 'chinh_ta_ch_tr', 41::int),
    (2::smallint, 'multiple_choice', 'Câu đố: “Cây gì không quả, không hoa / Không cành, không lá, xông pha ___?” Chọn cách viết đúng:', 'chiến trường', 'triến trường', 'chiến chường', 'triến chường', 'chiến trường', null::jsonb, 'Viết đúng là “chiến trường”.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'text', 'Điền ui hay uy: nội q___', null, null, null, null, 'uy', null::jsonb, 'Viết đúng là: nội quy.', 'chinh_ta_ui_uy', 41::int),
    (1::smallint, 'text', 'Điền ui hay uy: niềm v___', null, null, null, null, 'ui', null::jsonb, 'Viết đúng là: niềm vui.', 'chinh_ta_ui_uy', 41::int),
    (2::smallint, 'text', 'Điền ui hay uy (không cần dấu thanh): phá h___', null, null, null, null, 'uy', '["ủy"]'::jsonb, 'Viết đúng là: phá hủy.', 'chinh_ta_ui_uy', 41::int),
    (2::smallint, 'multiple_choice', 'Chọn từ viết đúng chính tả:', 'hắt hủi', 'hắt hủy', 'hắt hỉu', null, 'hắt hủi', null::jsonb, 'Viết đúng là “hắt hủi” (vần ui).', 'chinh_ta_ui_uy', 41::int),
    (2::smallint, 'multiple_choice', 'Câu thơ “Bao nhiêu tay toa rộng ra” (chữ in đậm chưa có dấu) viết đúng là:', 'Bao nhiêu tay tỏa rộng ra', 'Bao nhiêu tay tõa rộng ra', 'Bao nhiêu tay tóa rộng ra', null, 'Bao nhiêu tay tỏa rộng ra', null::jsonb, '“Tỏa” mang dấu hỏi.', 'chinh_ta_hoi_nga', 41::int),
    (3::smallint, 'multiple_choice', 'Giải câu đố: “Hè về áo đỏ như son / Hè đi thay lá xanh non mượt mà / Bao nhiêu tay tỏa rộng ra / Như vẫy như đón bạn ta đến trường.” Là cây gì?', 'cây dừa', 'cây phượng', 'cây lúa', 'cây tre', 'cây phượng', null::jsonb, 'Mùa hè hoa phượng đỏ rực như son – đó là cây phượng.', 'cau_do', 41::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ tính chất (phẩm chất bên trong của người)?', 'nhảy dây', 'chạy', 'quyển vở', 'ngoan', 'ngoan', null::jsonb, '“Ngoan” nói về phẩm chất bên trong.', 'tu_chi_tinh_chat', 42::int),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp: “Cô bé rất ___, vâng lời bố mẹ và thầy cô.”', 'hiền từ', 'ngoan', 'cao lớn', null, 'ngoan', null::jsonb, 'Cô bé vâng lời bố mẹ và thầy cô là cô bé ngoan.', 'tu_chi_tinh_chat', 42::int),
    (3::smallint, 'multiple_choice', 'Chọn từ thích hợp: “Người bà ___ hiện ra, dang tay ôm hai đứa cháu hiếu thảo vào lòng.”', 'hiếu thảo', 'ngoan', 'hiền từ', null, 'hiền từ', null::jsonb, '“Hiền từ” thường dùng để nói về người già; “ngoan”, “hiếu thảo” dùng cho con cháu.', 'tu_chi_tinh_chat', 42::int),
    (1::smallint, 'multiple_choice', 'Chọn từ chỉ đặc điểm phù hợp: “bộ lông của gà trống ___”', 'hồng hồng', 'dài ngoằng', 'rất thính', 'sặc sỡ', 'sặc sỡ', null::jsonb, 'Bộ lông gà trống nhiều màu sặc sỡ.', 'tu_chi_dac_diem', 42::int),
    (2::smallint, 'multiple_choice', 'Chọn từ chỉ đặc điểm phù hợp: “tai chó ___”', 'rất thính', 'sặc sỡ', 'hồng hồng', 'dài ngoằng', 'rất thính', null::jsonb, 'Tai chó nghe rất thính.', 'tu_chi_dac_diem', 42::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm, tính chất?', 'cày cấy', 'chiến đấu', 'cần cù', 'lao động', 'cần cù', null::jsonb, '“Cần cù” chỉ tính chất; các từ kia chỉ hoạt động.', 'tu_chi_tinh_chat', 43::int),
    (3::smallint, 'multiple_choice', 'Nhóm nào chỉ gồm từ chỉ đặc điểm, tính chất?', 'nghiên cứu, tận tụy, nhanh nhẹn', 'tháo vát, khéo tay, thông minh', 'sản xuất, cày cấy, trồng trọt', 'khiêm tốn, chăn nuôi, dịu dàng', 'tháo vát, khéo tay, thông minh', null::jsonb, 'Tháo vát, khéo tay, thông minh đều chỉ tính chất; các nhóm kia lẫn từ chỉ hoạt động.', 'tu_chi_tinh_chat', 43::int),
    (2::smallint, 'multiple_choice', '“Em Nụ môi đỏ hồng, trông yêu lắm… Có lúc, mắt em mở to, tròn và đen láy.”
Từ nào chỉ đặc điểm của đôi mắt em Nụ?', 'đỏ hồng', 'mở', 'đen láy', 'lớn lên', 'đen láy', null::jsonb, 'Mắt em Nụ tròn và đen láy.', 'tu_chi_dac_diem', 43::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Dũng không nói gì, chỉ nhìn em cười cười.”, từ nào chỉ hoạt động?', 'đỏ', 'nhìn', 'thơm phức', 'ngon lành', 'nhìn', null::jsonb, '“Nhìn” là từ chỉ hoạt động.', 'tu_chi_hoat_dong', 43::int),
    (2::smallint, 'multiple_choice', 'Chọn bộ phận thích hợp để được câu kiểu Ai thế nào?: “Bộ lông của gà trống ___”', 'sặc sỡ như bộ áo hoa.', 'đang gáy vang.', 'là của con gà.', 'chạy khắp sân.', 'sặc sỡ như bộ áo hoa.', null::jsonb, 'Bộ phận “sặc sỡ như bộ áo hoa” trả lời câu hỏi Thế nào?', 'cau_ai_the_nao', 43::int),
    (2::smallint, 'multiple_choice', 'Câu nào là câu tỏ ý khen?', 'Hãy đến xem ngôi nhà mới.', 'Ngôi nhà mới xây ở đâu?', 'Ngôi nhà mới xây xong.', 'Ngôi nhà mới cao quá!', 'Ngôi nhà mới cao quá!', null::jsonb, '“Ngôi nhà mới cao quá!” bày tỏ lời khen.', 'khen_ngoi', 44::int),
    (2::smallint, 'multiple_choice', 'Bài “Bầy voi”: “Trước đây, trên những cánh rừng Trường Sơn, voi sống thành từng bầy rất đông. Các thành viên trong bầy voi luôn quan tâm, chăm sóc nhau.”
Voi sống như thế nào?', 'một mình trong rừng', 'gia đình nhỏ: voi bố, voi mẹ, voi con', 'thành từng bầy rất đông', 'gia đình nhỏ: voi mẹ và voi con', 'thành từng bầy rất đông', null::jsonb, 'Voi sống thành từng bầy rất đông.', 'doc_hieu', 45::int),
    (2::smallint, 'number', 'Bài “Bầy voi”: “Voi rất thông minh. Với khối lượng gần 5kg, não của voi lớn hơn bất kì loài nào khác.”
Não của voi nặng gần ___ kg.', null, null, null, null, '5', null::jsonb, 'Não voi nặng gần 5 kg.', 'doc_hieu', 45::int),
    (3::smallint, 'multiple_choice', 'Theo bài “Bầy voi”, từ nào chỉ đặc điểm của loài voi?', 'chăm sóc', 'biểu diễn', 'kéo gỗ', 'khéo léo', 'khéo léo', null::jsonb, '“Khéo léo” là từ chỉ đặc điểm; các từ kia chỉ hoạt động.', 'tu_chi_dac_diem', 46::int),
    (3::smallint, 'multiple_choice', 'Câu nào viết theo kiểu câu Ai thế nào?', 'Voi rất thông minh.', 'Voi là vật nuôi có ích.', 'Voi kéo gỗ giúp người.', 'Voi là loài vật có nghĩa.', 'Voi rất thông minh.', null::jsonb, 'Voi thế nào? – rất thông minh.', 'cau_ai_the_nao', 46::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'dịu dàng', 'đạp xe', 'rộng', 'béo', 'đạp xe', null::jsonb, '“Đạp xe” là hoạt động; các từ kia chỉ đặc điểm.', 'tu_chi_hoat_dong', 46::int),
    (2::smallint, 'multiple_choice', 'Truyện “Chó cứu hỏa”: “Cứu các em rất khó vì khi lửa bùng lên, các em sợ hãi nên thường nấp vào chỗ kín.”
Vì sao rất khó cứu các em nhỏ khi hỏa hoạn?', 'Các em lo cứu búp bê', 'Không có lính cứu hỏa', 'Các em không chạy được', 'Các em sợ hãi, thường nấp vào chỗ kín', 'Các em sợ hãi, thường nấp vào chỗ kín', null::jsonb, 'Các em sợ hãi nên thường nấp vào chỗ kín.', 'doc_hieu', 47::int),
    (1::smallint, 'number', 'Truyện “Chó cứu hỏa”: “Bốp là một chú chó nổi tiếng vì đã cứu được 12 em nhỏ trong đám cháy.”
Bốp đã cứu được ___ em nhỏ.', null, null, null, null, '12', null::jsonb, 'Bốp đã cứu được 12 em nhỏ.', 'doc_hieu', 47::int),
    (3::smallint, 'multiple_choice', 'Truyện “Chó cứu hỏa”: lần thứ hai phóng vào nhà cháy, Bốp lôi ra một con búp bê. Điều gì thú vị ở chú chó Bốp?', 'Bốp tưởng cô bé là búp bê', 'Bốp rất sợ lửa', 'Bốp tưởng búp bê cũng là người cần cứu', 'Bốp không chịu vào nhà', 'Bốp tưởng búp bê cũng là người cần cứu', null::jsonb, 'Bốp tưởng búp bê cũng là người nên lôi ra cứu.', 'doc_hieu', 47::int),
    (1::smallint, 'multiple_choice', 'Chọn từ để tạo hình ảnh so sánh: “chua như ___”', 'nghệ', 'giấm', 'son', 'núi', 'giấm', null::jsonb, 'Giấm có vị chua: chua như giấm.', 'so_sanh', 48::int),
    (2::smallint, 'multiple_choice', 'Chọn từ để tạo hình ảnh so sánh: “tinh ranh như ___”', 'cáo', 'lừa', 'nghệ', 'son', 'cáo', null::jsonb, 'Thành ngữ: tinh ranh như cáo.', 'so_sanh', 48::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 16 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 17: Bạn trong nhà – Từ ngữ về vật nuôi, câu Ai thế nào?, so sánh (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 17, 100, 'Archimes: Bạn trong nhà – Từ ngữ về vật nuôi, câu Ai thế nào?, so sánh', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 17', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền r, d hay gi: “Tiếng mưa trong ___ừng cọ”', null, null, null, null, 'r', null::jsonb, 'Viết đúng là: rừng cọ.', 'chinh_ta_r_d_gi', 49::int),
    (1::smallint, 'text', 'Điền r, d hay gi: “Như tiếng thác ___ội về”', null, null, null, null, 'd', null::jsonb, 'Viết đúng là: dội về.', 'chinh_ta_r_d_gi', 49::int),
    (1::smallint, 'text', 'Điền r, d hay gi: “Như ào ào trận ___ó”', null, null, null, null, 'gi', null::jsonb, 'Viết đúng là: trận gió.', 'chinh_ta_r_d_gi', 49::int),
    (2::smallint, 'text', 'Điền r, d hay gi: “Lá xoè từng tia nắng / ___ống hệt như mặt trời.”', null, null, null, null, 'gi', null::jsonb, 'Viết đúng là: giống hệt.', 'chinh_ta_r_d_gi', 49::int),
    (1::smallint, 'text', 'Điền et hay ec (không cần dấu thanh): “Lợn kêu eng ___”', null, null, null, null, 'ec', '["éc"]'::jsonb, 'Viết đúng là: eng éc.', 'chinh_ta_et_ec', 49::int),
    (1::smallint, 'text', 'Điền et hay ec (không cần dấu thanh): “Sấm s___ vang trời”', null, null, null, null, 'et', '["ét"]'::jsonb, 'Viết đúng là: sấm sét.', 'chinh_ta_et_ec', 49::int),
    (2::smallint, 'text', 'Điền ao hay au (không cần dấu thanh): “Những anh ch___ m___ đỏm dáng.” (hai chỗ trống điền giống nhau)', null, null, null, null, 'ao', '["ào"]'::jsonb, 'Viết đúng là: chào mào.', 'chinh_ta_ao_au', 49::int),
    (1::smallint, 'text', 'Điền ui hay uy (không cần dấu thanh): tàu th___', null, null, null, null, 'uy', '["ủy"]'::jsonb, 'Viết đúng là: tàu thủy.', 'chinh_ta_ui_uy', 49::int),
    (1::smallint, 'text', 'Điền ui hay uy: ngọn n___', null, null, null, null, 'ui', '["úi"]'::jsonb, 'Viết đúng là: ngọn núi.', 'chinh_ta_ui_uy', 49::int),
    (2::smallint, 'multiple_choice', 'Chọn từ viết đúng chính tả:', 'huy hiệu', 'huy hiêu', 'hui hiệu', null, 'huy hiệu', null::jsonb, 'Viết đúng là “huy hiệu” (vần uy).', 'chinh_ta_ui_uy', 49::int),
    (2::smallint, 'text', 'Tìm từ có tiếng bắt đầu bằng r, d hay gi: “Làm dính lại bằng hồ” → ___', null, null, null, null, 'dán', null::jsonb, 'Làm dính lại bằng hồ là “dán”.', 'chinh_ta_r_d_gi', 49::int),
    (3::smallint, 'text', 'Tìm từ có tiếng bắt đầu bằng r, d hay gi: “Chỉ những người tuổi cao, sức yếu” → người ___', null, null, null, null, 'già', '["già yếu"]'::jsonb, 'Người tuổi cao, sức yếu là người già.', 'chinh_ta_r_d_gi', 49::int),
    (1::smallint, 'multiple_choice', 'Con vật nào là vật nuôi trong nhà?', 'gà mái', 'hổ', 'cá mập', 'hươu cao cổ', 'gà mái', null::jsonb, 'Gà mái được nuôi trong nhà.', 'tu_ngu_vat_nuoi', 50::int),
    (1::smallint, 'multiple_choice', 'Trong bài “Vè vật nuôi”, con vật nào “bắt chuột tài tình”?', 'trống choai', 'gà mái', 'lợn sề', 'mèo mướp', 'mèo mướp', null::jsonb, 'Anh em mèo mướp bắt chuột tài tình.', 'tu_ngu_vat_nuoi', 50::int),
    (2::smallint, 'multiple_choice', 'Trong bài “Vè vật nuôi”, con vật nào “giúp người dậy sớm”?', 'lợn sề', 'mèo mướp', 'trống choai', 'gà mái', 'trống choai', null::jsonb, 'Gà trống gáy vang giúp người dậy sớm.', 'tu_ngu_vat_nuoi', 50::int),
    (1::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai thế nào?', 'Chi cùng bố đến trường cảm ơn cô giáo.', 'Em Nụ cứ nhìn Hoa mãi.', 'Bầu trời cao và xanh trong.', null, 'Bầu trời cao và xanh trong.', null::jsonb, 'Bầu trời thế nào? – cao và xanh trong.', 'cau_ai_the_nao', 50::int),
    (2::smallint, 'multiple_choice', 'Câu nào thuộc kiểu câu Ai thế nào?', 'Chích bông là một con chim bé xinh đẹp.', 'Hai chiếc cánh nhỏ xíu.', 'Búp bê làm việc suốt ngày.', null, 'Hai chiếc cánh nhỏ xíu.', null::jsonb, 'Hai chiếc cánh thế nào? – nhỏ xíu.', 'cau_ai_the_nao', 50::int),
    (3::smallint, 'multiple_choice', 'Câu nào KHÔNG thuộc kiểu câu Ai thế nào?', 'Cái mào đỏ tươi, xinh xắn.', 'Em Nụ ngoan lắm.', 'Nhà em nuôi một cô gà mái.', null, 'Nhà em nuôi một cô gà mái.', null::jsonb, '“Nhà em nuôi một cô gà mái.” nói về hoạt động nuôi – không phải Ai thế nào?', 'cau_ai_the_nao', 51::int),
    (2::smallint, 'multiple_choice', 'Trong câu “Bộ lông của chú màu xám pha xanh lục.”, bộ phận trả lời câu hỏi “Thế nào?” là:', 'bộ lông', 'màu xám pha xanh lục', 'Bộ lông của chú', 'xanh lục', 'màu xám pha xanh lục', null::jsonb, 'Bộ lông của chú thế nào? – màu xám pha xanh lục.', 'cau_ai_the_nao', 51::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “cao chót vót” trong câu “Ngọn núi cao chót vót.”', 'Cái gì cao chót vót?', 'Ngọn núi là gì?', 'Ngọn núi thế nào?', 'Ngọn núi làm gì?', 'Ngọn núi thế nào?', null::jsonb, '“Cao chót vót” chỉ đặc điểm nên hỏi bằng “thế nào?”.', 'dat_cau_hoi', 51::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “Trời mùa thu” trong câu “Trời mùa thu mát mẻ.”', 'Trời mùa thu là gì?', 'Trời mùa thu thế nào?', 'Trời mùa thu làm gì?', 'Cái gì mát mẻ?', 'Cái gì mát mẻ?', null::jsonb, '“Trời mùa thu” là sự vật nên hỏi bằng “Cái gì?”.', 'dat_cau_hoi', 51::int),
    (1::smallint, 'multiple_choice', 'Chọn từ để tạo hình ảnh so sánh: “trắng như ___”', 'son', 'tuyết', 'nghệ', 'voi', 'tuyết', null::jsonb, 'Tuyết rất trắng: trắng như tuyết.', 'so_sanh', 51::int),
    (1::smallint, 'multiple_choice', 'Chọn tên con vật thích hợp: “khỏe như ___”', 'voi', 'sóc', 'mèo', 'thỏ', 'voi', null::jsonb, 'Voi rất khỏe: khỏe như voi.', 'so_sanh', 54::int),
    (1::smallint, 'multiple_choice', 'Chọn tên con vật thích hợp: “nhanh như ___”', 'voi', 'sóc', 'ốc sên', 'rùa', 'sóc', null::jsonb, 'Sóc rất nhanh nhẹn: nhanh như sóc.', 'so_sanh', 54::int),
    (2::smallint, 'multiple_choice', 'Chọn tên con vật thích hợp: “chậm như ___”', 'ngựa', 'thỏ', 'sóc', 'rùa', 'rùa', null::jsonb, 'Rùa bò rất chậm: chậm như rùa.', 'so_sanh', 54::int),
    (2::smallint, 'multiple_choice', 'Chọn bộ phận thích hợp để có câu so sánh: “Hai mắt của mèo ___”', 'mềm và mượt như nhung.', 'vểnh lên như hai dấu hỏi.', 'tròn xoe như hai hòn bi ve.', 'đỏ như bông hoa mười giờ.', 'tròn xoe như hai hòn bi ve.', null::jsonb, 'Mắt mèo tròn xoe như hai hòn bi ve.', 'so_sanh', 55::int),
    (2::smallint, 'multiple_choice', 'Bài “Con mèo Hung”: “Chà, nó có bộ lông mới đẹp làm sao! Màu lông hung hung có sắc vằn đo đỏ…”
Bộ lông mèo Hung được tả thế nào?', 'rất đẹp, màu hung hung có vằn đo đỏ', 'đen tuyền, óng ả', 'lông mịn, trắng như bông', 'mượt mà và sặc sỡ', 'rất đẹp, màu hung hung có vằn đo đỏ', null::jsonb, 'Bộ lông rất đẹp, màu hung hung có sắc vằn đo đỏ.', 'doc_hieu', 54::int),
    (2::smallint, 'multiple_choice', 'Câu “Đôi mắt mèo Hung hiền lành.” thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai thế nào?', 'Ai là gì?', null, 'Ai thế nào?', null::jsonb, 'Đôi mắt mèo Hung thế nào? – hiền lành.', 'kieu_cau', 54::int),
    (3::smallint, 'multiple_choice', 'Cách tách nào ĐÚNG hai bộ phận “Cái gì? / Thế nào?” của câu?', 'Bộ lông của chú / vàng óng, mượt như tơ.', 'Bộ lông của chú vàng óng / mượt như tơ.', 'Bộ lông / của chú vàng óng, mượt như tơ.', null, 'Bộ lông của chú / vàng óng, mượt như tơ.', null::jsonb, 'Cái gì? – Bộ lông của chú. Thế nào? – vàng óng, mượt như tơ.', 'cau_ai_the_nao', 55::int),
    (2::smallint, 'multiple_choice', 'Câu nào thể hiện sự ngạc nhiên, thích thú?', 'Con cất sách vào cặp.', 'Ôi, quyển sách mới đẹp quá!', 'Mẹ mua sách ở đâu?', 'Quyển sách này của mẹ.', 'Ôi, quyển sách mới đẹp quá!', null::jsonb, 'Câu có “Ôi… quá!” thể hiện sự ngạc nhiên, thích thú.', 'ngac_nhien_thich_thu', 52::int),
    (3::smallint, 'multiple_choice', 'Thư dậy lúc 6 giờ 30 phút. 15 phút sau, em vào bếp ăn sáng. Thư ăn sáng lúc mấy giờ?', '7 giờ 15 phút', '6 giờ 15 phút', '7 giờ', '6 giờ 45 phút', '6 giờ 45 phút', null::jsonb, '6 giờ 30 phút thêm 15 phút là 6 giờ 45 phút.', 'thoi_gian_bieu', 53::int),
    (3::smallint, 'multiple_choice', 'Thư thay quần áo lúc 7 giờ, sau đó mẹ chở em đến trường mất 15 phút. Thư đến trường lúc mấy giờ?', '7 giờ 15 phút', '7 giờ 30 phút', '8 giờ', '6 giờ 45 phút', '7 giờ 15 phút', null::jsonb, '7 giờ thêm 15 phút là 7 giờ 15 phút.', 'thoi_gian_bieu', 53::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 17 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 18: Ôn tập cuối học kì I – Ba kiểu câu, dấu câu, từ loại (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 18, 100, 'Archimes: Ôn tập cuối học kì I – Ba kiểu câu, dấu câu, từ loại', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 2, tuần 18', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (2::smallint, 'multiple_choice', 'Bài “Chim chích bông”: “Hai chân chích bông xinh xinh bằng hai chiếc tăm. Thế mà hai cái chân tăm ấy rất nhanh nhẹn, được việc, nhảy cứ liên liến.”
Hai chân chích bông có đặc điểm gì?', 'dài ngoằng', 'ngắn và chậm chạp', 'xinh xinh bằng hai chiếc tăm, rất nhanh nhẹn', 'to và khỏe', 'xinh xinh bằng hai chiếc tăm, rất nhanh nhẹn', null::jsonb, 'Hai chân xinh xinh bằng hai chiếc tăm mà rất nhanh nhẹn.', 'doc_hieu', 56::int),
    (2::smallint, 'multiple_choice', '“Cặp mỏ tí hon ấy gắp sâu trên lá nhanh thoăn thoắt.”
Thức ăn của chim chích bông được nhắc đến là gì?', 'hạt dẻ', 'cá nhỏ', 'sâu', 'thóc', 'sâu', null::jsonb, 'Chích bông gắp sâu trên lá.', 'doc_hieu', 56::int),
    (3::smallint, 'multiple_choice', '“Chích bông xinh đẹp chẳng những là bạn của trẻ em mà còn là bạn của bà con nông dân.”
Chích bông là bạn của những ai?', 'trẻ em và bà con nông dân', 'chỉ trẻ em', 'chỉ bà con nông dân', 'các loài chim khác', 'trẻ em và bà con nông dân', null::jsonb, 'Chích bông là bạn của cả trẻ em và bà con nông dân.', 'doc_hieu', 56::int),
    (3::smallint, 'multiple_choice', 'Câu nào trong bài “Chim chích bông” thuộc kiểu câu Ai là gì?', 'Cặp mỏ tí hon ấy gắp sâu trên lá nhanh thoăn thoắt.', 'Chích bông là con chim bé xinh đẹp trong thế giới loài chim.', 'Hai chiếc cánh nhỏ xíu.', null, 'Chích bông là con chim bé xinh đẹp trong thế giới loài chim.', null::jsonb, 'Câu giới thiệu “Chích bông là con chim bé xinh đẹp…” – kiểu Ai là gì?', 'kieu_cau', 56::int),
    (1::smallint, 'multiple_choice', 'Bài “Bác đưa thư”: “Bác đưa thư trao cho Minh một bức thư. Đúng là thư của bố rồi. Minh mừng quýnh.”
Minh nhận được thư của ai?', 'của bác đưa thư', 'của mẹ', 'của ông', 'của bố', 'của bố', null::jsonb, 'Đúng là thư của bố rồi.', 'doc_hieu', 57::int),
    (2::smallint, 'multiple_choice', '“Nhưng em chợt thấy bác đưa thư mồ hôi nhễ nhại. Minh chạy vội vào nhà. Em rót một cốc nước mát lạnh…”
Thấy bác đưa thư mồ hôi nhễ nhại, Minh đã làm gì?', 'chạy vào đọc thư với mẹ', 'rót cốc nước mát mời bác uống', 'mời bác vào nhà nghỉ', 'lấy quạt quạt cho bác', 'rót cốc nước mát mời bác uống', null::jsonb, 'Minh rót một cốc nước mát lạnh, lễ phép mời bác uống.', 'doc_hieu', 57::int),
    (2::smallint, 'multiple_choice', 'Câu “Bác đưa thư trao cho Minh một bức thư.” thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai là gì?', 'Ai thế nào?', null, 'Ai làm gì?', null::jsonb, 'Bác đưa thư làm gì? – trao cho Minh một bức thư.', 'kieu_cau', 57::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động trong câu “Em rót một cốc nước mát lạnh.”?', 'rót', 'nước', 'mát lạnh', 'cốc', 'rót', null::jsonb, '“Rót” là từ chỉ hoạt động.', 'tu_chi_hoat_dong', 57::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “bác sĩ của bệnh viện thành phố” trong câu “Cô An là bác sĩ của bệnh viện thành phố.”', 'Cô An thế nào?', 'Ai là bác sĩ của bệnh viện thành phố?', 'Cô An là gì?', 'Cô An làm gì?', 'Cô An là gì?', null::jsonb, 'Bộ phận này trả lời câu hỏi “là gì?”.', 'dat_cau_hoi', 57::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “thật đẹp” trong câu “Chiếc cặp sách của Lan thật đẹp.”', 'Chiếc cặp sách của Lan là gì?', 'Chiếc cặp sách của Lan thế nào?', 'Cái gì thật đẹp?', 'Chiếc cặp sách của Lan làm gì?', 'Chiếc cặp sách của Lan thế nào?', null::jsonb, '“Thật đẹp” chỉ đặc điểm nên hỏi “thế nào?”.', 'dat_cau_hoi', 57::int),
    (2::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “đang giúp mẹ nấu cơm” trong câu “Lan đang giúp mẹ nấu cơm.”', 'Lan thế nào?', 'Lan là ai?', 'Ai đang giúp mẹ nấu cơm?', 'Lan đang làm gì?', 'Lan đang làm gì?', null::jsonb, 'Bộ phận chỉ hoạt động nên hỏi “làm gì?”.', 'dat_cau_hoi', 57::int),
    (3::smallint, 'multiple_choice', 'Sắp xếp “rất / vui / Na / bạn bè / khi / giúp đỡ / trong học tập / được” thành câu đúng:', 'Bạn bè rất vui khi Na trong học tập được giúp đỡ.', 'Rất vui Na khi bạn bè được trong học tập giúp đỡ.', 'Na rất vui khi được giúp đỡ bạn bè trong học tập.', 'Na được giúp đỡ rất vui khi bạn bè trong học tập.', 'Na rất vui khi được giúp đỡ bạn bè trong học tập.', null::jsonb, 'Câu đúng: Na rất vui khi được giúp đỡ bạn bè trong học tập.', 'sap_xep_cau', 57::int),
    (1::smallint, 'multiple_choice', '“Ở một cánh đồng nọ ___ có hai anh em cày chung một đám ruộng.” Chỗ trống cần điền dấu gì?', 'dấu chấm', 'dấu chấm hỏi', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách “Ở một cánh đồng nọ” với phần chính của câu.', 'dau_cau', 58::int),
    (3::smallint, 'multiple_choice', 'Câu nào dùng dấu phẩy ĐÚNG?', 'Cuối mùa đông, hoa xoài nở trắng cành.', 'Cuối mùa đông hoa, xoài nở trắng cành.', 'Cuối mùa, đông hoa xoài nở trắng cành.', 'Cuối mùa đông hoa xoài, nở trắng cành.', 'Cuối mùa đông, hoa xoài nở trắng cành.', null::jsonb, 'Dấu phẩy đặt sau “Cuối mùa đông” (chỉ thời gian).', 'dau_phay', 58::int),
    (3::smallint, 'multiple_choice', 'Câu nào dùng dấu phẩy ĐÚNG?', 'Mùi xoài thơm, dịu dàng, vị ngọt, đậm đà.', 'Mùi xoài thơm dịu dàng, vị ngọt đậm đà.', 'Mùi xoài, thơm dịu dàng vị, ngọt đậm đà.', 'Mùi, xoài thơm dịu dàng vị ngọt đậm đà.', 'Mùi xoài thơm dịu dàng, vị ngọt đậm đà.', null::jsonb, 'Dấu phẩy ngăn cách hai ý: “mùi xoài thơm dịu dàng” và “vị ngọt đậm đà”.', 'dau_phay', 58::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ tính cách, phẩm chất?', 'múa hát', 'chạy', 'leo trèo', 'chăm chỉ', 'chăm chỉ', null::jsonb, '“Chăm chỉ” chỉ phẩm chất; các từ kia chỉ hoạt động.', 'tu_chi_tinh_chat', 58::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động?', 'hiền', 'lười biếng', 'khiêm tốn', 'đọc', 'đọc', null::jsonb, '“Đọc” là hoạt động.', 'tu_chi_hoat_dong', 58::int),
    (2::smallint, 'multiple_choice', 'Nhóm nào chỉ gồm các từ chỉ tính cách, phẩm chất?', 'hiền, viết, vẽ', 'kiêu căng, ăn, uống', 'siêng năng, cần cù, ngoan', 'chịu khó, lăn, bò', 'siêng năng, cần cù, ngoan', null::jsonb, 'Siêng năng, cần cù, ngoan đều chỉ phẩm chất.', 'tu_chi_tinh_chat', 58::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ tình cảm?', 'yêu thương', 'giặt giũ', 'quét dọn', 'ông bà', 'yêu thương', null::jsonb, '“Yêu thương” là từ chỉ tình cảm.', 'tu_ngu_tinh_cam', 58::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ họ hàng?', 'sẻ chia', 'cô chú', 'nấu nướng', 'kính trọng', 'cô chú', null::jsonb, '“Cô chú” là người trong họ hàng.', 'tu_ngu_ho_hang', 58::int),
    (2::smallint, 'multiple_choice', 'Câu “Hươu thật thông minh và nhanh nhẹn.” thuộc kiểu câu nào?', 'Ai là gì?', 'Ai làm gì?', 'Ai thế nào?', null, 'Ai thế nào?', null::jsonb, 'Hươu thế nào? – thật thông minh và nhanh nhẹn.', 'kieu_cau', 59::int),
    (2::smallint, 'multiple_choice', 'Câu “Cây vạn tuế là cây mà ông Hân thích nhất trong vườn.” thuộc kiểu câu nào?', 'Ai thế nào?', 'Ai là gì?', 'Ai làm gì?', null, 'Ai là gì?', null::jsonb, 'Cây vạn tuế là gì? – là cây ông Hân thích nhất.', 'kieu_cau', 59::int),
    (1::smallint, 'multiple_choice', 'Câu “Bác Hồng đang chăm sóc vườn rau.” thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai thế nào?', 'Ai là gì?', null, 'Ai làm gì?', null::jsonb, 'Bác Hồng làm gì? – đang chăm sóc vườn rau.', 'kieu_cau', 59::int),
    (3::smallint, 'multiple_choice', 'Câu “Mẹ của Hà là một người hiền lành, tốt bụng.” thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai thế nào?', 'Ai là gì?', null, 'Ai là gì?', null::jsonb, 'Câu có “là một người…” giới thiệu mẹ của Hà – kiểu Ai là gì? (dù có từ chỉ tính chất).', 'kieu_cau', 59::int),
    (3::smallint, 'multiple_choice', 'Đoạn “Con chuồn chuồn nước”: câu nào KHÔNG phải kiểu câu Ai thế nào?', 'Bốn cái cánh mỏng như giấy bóng.', 'Chú đậu trên một cành lộc vừng ngả dài trên mặt hồ.', 'Màu vàng trên lưng chú lấp lánh.', null, 'Chú đậu trên một cành lộc vừng ngả dài trên mặt hồ.', null::jsonb, '“Chú đậu trên cành lộc vừng” nói về hoạt động – kiểu Ai làm gì?', 'cau_ai_the_nao', 59::int),
    (2::smallint, 'multiple_choice', 'Bài “Chú Trống Choai”: “Chú ta đang ngất ngưởng trên đống củi trước sân kia kìa.”
Trống Choai đứng ở đâu để cất tiếng gáy?', 'trên cành chanh', 'trên mái nhà', 'ngất ngưởng trên đống củi trước sân', 'trên cây chuối ở góc sân', 'ngất ngưởng trên đống củi trước sân', null::jsonb, 'Trống Choai đứng ngất ngưởng trên đống củi trước sân.', 'doc_hieu', 61::int),
    (3::smallint, 'multiple_choice', '“Bây giờ đuôi chú đã có dáng cong cong chứ không đuồn đuột như hồi nhỏ nữa. Bộ cánh cũng có duyên lắm rồi.”
Trống Choai bây giờ khác hồi nhỏ ở điểm nào?', 'Đuôi cong cong, bộ cánh có duyên', 'Đôi chân cao, lông đỏ hơn', 'Mào to hơn, đuôi dài hơn', 'Đôi cánh thẳng, mỏ cứng hơn', 'Đuôi cong cong, bộ cánh có duyên', null::jsonb, 'Đuôi đã cong cong, không đuồn đuột; bộ cánh có duyên lắm rồi.', 'doc_hieu', 61::int),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm trong câu “Bây giờ đuôi chú đã có dáng cong cong.”?', 'đuôi', 'cong cong', 'dáng', 'bây giờ', 'cong cong', null::jsonb, '“Cong cong” chỉ hình dáng – từ chỉ đặc điểm.', 'tu_chi_dac_diem', 61::int),
    (1::smallint, 'text', 'Điền l hay n: “Cũng từ ___úa nếp sinh ra”', null, null, null, null, 'l', null::jsonb, 'Viết đúng là: lúa nếp.', 'chinh_ta_l_n', 62::int),
    (1::smallint, 'text', 'Điền ui hay uy: “t___ nhiên”', null, null, null, null, 'uy', null::jsonb, 'Viết đúng là: tuy nhiên.', 'chinh_ta_ui_uy', 62::int),
    (1::smallint, 'text', 'Điền ui hay uy (không cần dấu thanh): “m___ thuyền”', null, null, null, null, 'ui', '["ũi"]'::jsonb, 'Viết đúng là: mũi thuyền.', 'chinh_ta_ui_uy', 62::int),
    (1::smallint, 'multiple_choice', 'Chọn dấu câu thích hợp điền vào chỗ trống: “– Có chuyện gì thế con ___”', 'dấu chấm', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu chấm hỏi', null::jsonb, 'Mẹ hỏi Tũn nên cuối câu dùng dấu chấm hỏi.', 'dau_cau', 62::int),
    (2::smallint, 'multiple_choice', '“Thấy vẻ mặt buồn rầu của Tũn ___ mẹ hỏi:” Chỗ trống cần điền dấu gì?', 'dấu chấm hỏi', 'dấu phẩy', 'dấu chấm', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách phần đầu câu với “mẹ hỏi”.', 'dau_cau', 62::int),
    (3::smallint, 'multiple_choice', 'Đặt câu hỏi cho bộ phận “Họa mi” trong câu “Họa mi là loài chim có tiếng hót rất hay.”', 'Họa mi là gì?', 'Họa mi thế nào?', 'Họa mi làm gì?', 'Con gì là loài chim có tiếng hót rất hay?', 'Con gì là loài chim có tiếng hót rất hay?', null::jsonb, '“Họa mi” là con vật nên hỏi bằng “Con gì?”.', 'dat_cau_hoi', 62::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 18 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 19: Bốn mùa – Từ ngữ về các mùa, câu hỏi Khi nào? (32 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 19, 100, 'Archimes: Bốn mùa – Từ ngữ về các mùa, câu hỏi Khi nào?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 19', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền l hay n: quả ___a', null, null, null, null, 'n', null::jsonb, 'Quả na viết với n.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'text', 'Điền l hay n: ___á cờ', null, null, null, null, 'l', null::jsonb, 'Lá cờ viết với l.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng điền vào chỗ trống: ___ thực (gạo, ngô, khoai…)', 'lương', 'nương', 'lượng', null, 'lương', null::jsonb, 'Lương thực là các loại thức ăn chính như gạo, ngô, khoai.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'lông nghiệp', 'nông nghiệp', 'nông ngiệp', null, 'nông nghiệp', null::jsonb, 'Nông nghiệp: viết n ở tiếng nông, ngh trước i.', 'chinh_ta_l_n', 3::int),
    (1::smallint, 'text', 'Điền l hay n: Mùi hoa hồng, hoa huệ sực ___ức.', null, null, null, null, 'n', null::jsonb, 'Sực nức (thơm lan tỏa mạnh) viết với n.', 'chinh_ta_l_n', 4::int),
    (1::smallint, 'text', 'Điền l hay n: Cong như trăng ___ưỡi liềm', null, null, null, null, 'l', null::jsonb, 'Lưỡi liềm viết với l.', 'chinh_ta_l_n', 4::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ thời tiết mùa hè?', 'nóng nực', 'oi nồng', 'lạnh buốt', 'mưa rào', 'lạnh buốt', null::jsonb, 'Lạnh buốt là thời tiết mùa đông, không phải mùa hè.', 'tu_ngu_cac_mua', 5::int),
    (1::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ thời tiết mùa đông?', 'giá buốt', 'lạnh cóng', 'rét cắt da cắt thịt', 'ấm áp', 'ấm áp', null::jsonb, 'Ấm áp là thời tiết mùa xuân.', 'tu_ngu_cac_mua', 5::int),
    (1::smallint, 'multiple_choice', 'Phượng vĩ nở đỏ rực, học sinh được nghỉ hè vào mùa nào?', 'mùa hạ', 'mùa xuân', 'mùa thu', 'mùa đông', 'mùa hạ', null::jsonb, 'Hoa phượng nở, nghỉ hè là vào mùa hạ (mùa hè).', 'tu_ngu_cac_mua', 5::int),
    (1::smallint, 'multiple_choice', '"Trẻ em rước đèn vào dịp Trung thu." Đó là hoạt động của mùa nào?', 'mùa xuân', 'mùa thu', 'mùa hạ', 'mùa đông', 'mùa thu', null::jsonb, 'Tết Trung thu diễn ra vào mùa thu.', 'tu_ngu_cac_mua', 5::int),
    (1::smallint, 'multiple_choice', 'Câu hỏi "Khi nào?" dùng để hỏi về điều gì?', 'địa điểm', 'nguyên nhân', 'thời gian', 'đặc điểm', 'thời gian', null::jsonb, '"Khi nào?" hỏi về thời gian, thời điểm xảy ra sự việc.', 'cau_hoi_khi_nao', 4::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Tôi yêu những con đường Hà Nội
Cuối năm cây cơm nguội lá vàng
Những ngọn đèn thắp sáng lúc hoàng hôn
Mái phố cũ nhấp nhô trong khói nhạt."
(Theo Xuân Quỳnh)
Tác giả nhớ đến những con đường ở đâu?', 'thành phố Hồ Chí Minh', 'Hà Nội', 'ven hồ', null, 'Hà Nội', null::jsonb, 'Câu thơ đầu: "Tôi yêu những con đường Hà Nội".', 'doc_hieu', 7::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn thơ:
"Ngã năm rộng, cỏ ven hồ xanh mướt
Năm nay đào nở sớm, tháng giêng sang
Tháng giêng bỡ ngỡ búp bàng non
Nhiều trẻ con và nhiều chim sẻ."
Những sự vật nào được nhắc đến khi tháng giêng sang?', 'cỏ, xe cộ, cây đào, chim sẻ, mùa xuân', 'cây đào, búp bàng, trẻ con, chim sẻ', 'cỏ, cây đào, búp bàng, trẻ con, chim sẻ', null, 'cỏ, cây đào, búp bàng, trẻ con, chim sẻ', null::jsonb, 'Đoạn thơ nhắc đủ: cỏ, cây đào, búp bàng, trẻ con, chim sẻ.', 'doc_hieu', 7::int),
    (2::smallint, 'multiple_choice', 'Tháng giêng thuộc mùa nào trong năm?', 'mùa thu', 'mùa hạ', 'mùa đông', 'mùa xuân', 'mùa xuân', null::jsonb, 'Mùa xuân bắt đầu từ tháng giêng.', 'tu_ngu_cac_mua', 7::int),
    (2::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Khi nào?" trong câu "Những ngọn đèn thắp sáng lúc hoàng hôn." là:', 'lúc hoàng hôn', 'những ngọn đèn', 'thắp sáng', null, 'lúc hoàng hôn', null::jsonb, '"Lúc hoàng hôn" chỉ thời gian.', 'cau_hoi_khi_nao', 7::int),
    (2::smallint, 'multiple_choice', 'Dòng nào dưới đây gồm toàn từ chỉ đặc điểm, tính chất?', 'lá vàng, sáng, cũ, nhạt, xanh mướt', 'phố cũ, sáng, vàng, nhạt, xanh mướt', 'cũ, sáng, vàng, nhạt, xanh mướt', null, 'cũ, sáng, vàng, nhạt, xanh mướt', null::jsonb, '"Lá vàng", "phố cũ" có từ chỉ sự vật; chỉ dòng đầu toàn từ chỉ đặc điểm.', 'tu_chi_dac_diem', 8::int),
    (2::smallint, 'multiple_choice', '"Chủ nhật hằng tuần, em cùng bố mẹ về quê thăm ông bà." Bộ phận "Chủ nhật hằng tuần" trả lời cho câu hỏi nào?', 'Ở đâu?', 'Làm gì?', 'Vì sao?', 'Khi nào?', 'Khi nào?', null::jsonb, '"Chủ nhật hằng tuần" chỉ thời gian.', 'cau_hoi_khi_nao', 6::int),
    (2::smallint, 'multiple_choice', '"Chú gà trống cất tiếng gáy vào lúc sáng sớm." Câu hỏi nào hỏi về thời gian trong câu trên?', 'Chú gà trống cất tiếng gáy ở đâu?', 'Chú gà trống cất tiếng gáy khi nào?', 'Chú gà trống làm gì?', 'Vì sao chú gà trống gáy?', 'Chú gà trống cất tiếng gáy khi nào?', null::jsonb, 'Hỏi về thời gian dùng "khi nào".', 'cau_hoi_khi_nao', 6::int),
    (2::smallint, 'text', 'Điền xuân, hạ, thu hay đông: Hoa cúc nở vàng tươi, quả hồng đỏ mọng, quả thị thơm lừng vào mùa ___.', null, null, null, null, 'thu', null::jsonb, 'Hoa cúc, quả hồng, quả thị là cảnh vật mùa thu.', 'tu_ngu_cac_mua', 5::int),
    (1::smallint, 'text', 'Điền xuân, hạ, thu hay đông: Gió bấc lạnh cắt da cắt thịt tràn về vào mùa ___.', null, null, null, null, 'đông', null::jsonb, 'Gió bấc lạnh buốt là của mùa đông.', 'tu_ngu_cac_mua', 5::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Mùa gì ấm áp
Mưa phùn nhẹ bay
Khắp chốn cỏ cây
Đâm chồi nảy lộc?"', 'mùa hạ', 'mùa thu', 'mùa đông', 'mùa xuân', 'mùa xuân', null::jsonb, 'Ấm áp, mưa phùn, cây đâm chồi nảy lộc là mùa xuân.', 'tu_ngu_cac_mua', 5::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Mùa gì se lạnh
Mây nhẹ nhàng bay
Gió khẽ rung cây
Lá vàng rơi rụng?"', 'mùa thu', 'mùa xuân', 'mùa hạ', 'mùa đông', 'mùa thu', null::jsonb, 'Se lạnh, lá vàng rơi là mùa thu.', 'tu_ngu_cac_mua', 6::int),
    (2::smallint, 'text', 'Tìm từ có tiếng bắt đầu bằng l hoặc n, trái nghĩa với "nhẹ".', null, null, null, null, 'nặng', null::jsonb, 'Trái nghĩa với nhẹ là nặng.', 'chinh_ta_l_n', 3::int),
    (2::smallint, 'multiple_choice', 'Trong đoạn văn "Mặt trời tỏa những tia nắng chói chang như muốn đốt cháy cỏ cây", từ nào chỉ đặc điểm của mùa hè?', 'chói chang', 'se se lạnh', 'mưa phùn', 'giá buốt', 'chói chang', null::jsonb, 'Nắng chói chang là đặc điểm mùa hè.', 'tu_ngu_cac_mua', 8::int),
    (3::smallint, 'text', 'Giải câu đố:
"Cũng từ lúa nếp sinh ra
Xanh xanh từng hạt, đậm đà quê hương
Lúc làm bánh, khi nấu chè
Lá sen ủ ngát đi về cùng theo."
Là gì?', null, null, null, null, 'cốm', '["hạt cốm","cốm xanh"]'::jsonb, 'Cốm làm từ lúa nếp non, hạt xanh, gói trong lá sen.', 'giai_do', 4::int),
    (3::smallint, 'text', 'Giải câu đố:
"Có chân mà chẳng biết đi
Quanh năm suốt tháng đứng ì một nơi
Bạn bè với chiếu chăn thôi
Đỡ người nằm ngủ thảnh thơi đêm ngày."
Là cái gì?', null, null, null, null, 'cái giường', '["giường","chiếc giường"]'::jsonb, 'Cái giường có chân, trải chiếu chăn để người nằm ngủ.', 'giai_do', 4::int),
    (3::smallint, 'multiple_choice', 'Từ nào viết đúng dấu thanh?', 'thãnh thơi', 'thảnh thơi', 'thảnh thởi', 'thãnh thỡi', 'thảnh thơi', null::jsonb, 'Viết đúng là "thảnh thơi" (dấu hỏi ở tiếng thảnh).', 'dau_hoi_nga', 4::int),
    (3::smallint, 'multiple_choice', 'Câu nào là thành ngữ, tục ngữ nói về thời tiết?', 'Non xanh nước biếc.', 'Đất lành chim đậu.', 'Trăng quầng thì hạn, trăng tán thì mưa.', 'Uống nước nhớ nguồn.', 'Trăng quầng thì hạn, trăng tán thì mưa.', null::jsonb, 'Câu này cho biết dựa vào trăng để đoán nắng hạn hay mưa.', 'tu_ngu_thoi_tiet', 8::int),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ thời tiết mùa xuân?', 'ấm áp', 'ẩm ướt', 'mưa bụi lây rây', 'oi ả', 'oi ả', null::jsonb, 'Oi ả là thời tiết nóng bức của mùa hè.', 'tu_ngu_cac_mua', 5::int),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ thời tiết mùa thu?', 'mưa phùn gió bấc', 'se se lạnh', 'mát mẻ', 'gió heo may', 'mưa phùn gió bấc', null::jsonb, 'Mưa phùn gió bấc là thời tiết mùa đông.', 'tu_ngu_cac_mua', 5::int),
    (3::smallint, 'multiple_choice', '"Mọi người thường đi du lịch vào mùa hè." Câu hỏi đúng cho bộ phận "vào mùa hè" là:', 'Mọi người thường đi du lịch ở đâu?', 'Mọi người thường đi du lịch khi nào?', 'Mọi người thường làm gì vào mùa hè?', 'Vì sao mọi người đi du lịch?', 'Mọi người thường đi du lịch khi nào?', null::jsonb, '"Vào mùa hè" chỉ thời gian nên hỏi bằng "khi nào".', 'cau_hoi_khi_nao', 8::int),
    (3::smallint, 'multiple_choice', 'Trong câu "Mẹ ơi, khi nào nhà mình đi du lịch ạ?", có thể thay "khi nào" bằng từ nào mà nghĩa không đổi?', 'ở đâu', 'vì sao', 'bao giờ', 'thế nào', 'bao giờ', null::jsonb, '"Bao giờ", "lúc nào" cũng dùng để hỏi thời gian như "khi nào".', 'cau_hoi_khi_nao', 4::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 19 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 20: Bốn mùa – Từ ngữ về thời tiết, dấu chấm và dấu chấm than (30 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 20, 100, 'Archimes: Bốn mùa – Từ ngữ về thời tiết, dấu chấm và dấu chấm than', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 20', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền s hay x: Em vẽ làng ___óm', null, null, null, null, 'x', null::jsonb, 'Làng xóm viết với x.', 'chinh_ta_s_x', 9::int),
    (1::smallint, 'text', 'Điền s hay x: ___ông máng lượn quanh', null, null, null, null, 's', null::jsonb, 'Sông máng viết với s.', 'chinh_ta_s_x', 9::int),
    (1::smallint, 'text', 'Điền iêt hay iêc (thêm dấu thanh nếu cần): dự báo thời t___', null, null, null, null, 'iết', '["tiết"]'::jsonb, 'Thời tiết viết là "tiết".', 'chinh_ta_iet_iec', 9::int),
    (1::smallint, 'text', 'Điền iêt hay iêc (thêm dấu thanh nếu cần): một công đôi v___', null, null, null, null, 'iệc', '["việc"]'::jsonb, 'Một công đôi việc: "việc" có vần iêc.', 'chinh_ta_iet_iec', 9::int),
    (2::smallint, 'text', 'Điền iêt hay iêc (thêm dấu thanh nếu cần): dòng sông chảy x___', null, null, null, null, 'iết', '["xiết"]'::jsonb, 'Chảy xiết (chảy rất mạnh) có vần iêt.', 'chinh_ta_iet_iec', 9::int),
    (2::smallint, 'text', 'Điền iêt hay iêc (thêm dấu thanh nếu cần): hàng cây xanh b___', null, null, null, null, 'iếc', '["biếc"]'::jsonb, 'Xanh biếc có vần iêc.', 'chinh_ta_iet_iec', 9::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'xong xuôi', 'song xuôi', 'xong suôi', null, 'xong xuôi', null::jsonb, 'Viết đúng là "xong xuôi" (cả hai tiếng đều có x).', 'chinh_ta_s_x', 9::int),
    (1::smallint, 'multiple_choice', 'Dấu chấm than (!) thường đặt ở cuối câu nào?', 'câu kể một sự việc bình thường', 'câu bộc lộ cảm xúc, lời gọi, lời đề nghị', 'câu dùng để hỏi', null, 'câu bộc lộ cảm xúc, lời gọi, lời đề nghị', null::jsonb, 'Dấu chấm than dùng cho câu cảm, lời gọi, lời yêu cầu, đề nghị.', 'dau_cau', 10::int),
    (1::smallint, 'multiple_choice', 'Mưa có hạt đông cứng lại thành nước đá gọi là gì?', 'mưa phùn', 'mưa dầm', 'mưa đá', 'mưa bóng mây', 'mưa đá', null::jsonb, 'Hạt mưa đông cứng thành đá gọi là mưa đá.', 'tu_ngu_thoi_tiet', 10::int),
    (1::smallint, 'multiple_choice', 'Theo cách tính bốn mùa trong bài học, mùa xuân bắt đầu từ tháng nào?', 'tháng tư', 'tháng bảy', 'tháng mười', 'tháng giêng', 'tháng giêng', null::jsonb, 'Mùa xuân bắt đầu từ tháng giêng, kết thúc vào tháng ba.', 'tu_ngu_cac_mua', 12::int),
    (1::smallint, 'multiple_choice', '"Minh tan học lúc 4 giờ chiều." Để hỏi về "4 giờ chiều", ta dùng từ ngữ nào?', 'mấy giờ', 'tháng mấy', 'năm nào', 'ngày nào', 'mấy giờ', null::jsonb, 'Hỏi giờ thì dùng "mấy giờ": Minh tan học lúc mấy giờ?', 'cau_hoi_khi_nao', 11::int),
    (1::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Khi nào?" trong câu "Sau trận mưa rào, mọi vật đều sáng và tươi." là:', 'mọi vật', 'đều sáng và tươi', 'Sau trận mưa rào', null, 'Sau trận mưa rào', null::jsonb, '"Sau trận mưa rào" chỉ thời gian.', 'cau_hoi_khi_nao', 11::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Bốn mùa trong năm thì mùa thu êm ái, nhẹ nhàng nhất. Thời tiết thật khoan khoái dễ chịu. Nắng, gió, mưa, sương đều khác ba mùa kia."
(Mùa thu trong tôi)
Đoạn văn chủ yếu viết về mùa nào?', 'mùa đông', 'mùa thu', 'mùa xuân', null, 'mùa thu', null::jsonb, 'Đoạn văn nói về mùa thu êm ái, nhẹ nhàng.', 'doc_hieu', 14::int),
    (2::smallint, 'multiple_choice', '"Mưa kéo dài nhiều ngày, thường trên một diện tích rộng" là:', 'mưa phùn', 'mưa bóng mây', 'mưa đá', 'mưa dầm', 'mưa dầm', null::jsonb, 'Mưa dầm là mưa kéo dài nhiều ngày.', 'tu_ngu_thoi_tiet', 10::int),
    (2::smallint, 'multiple_choice', '"Mưa ngắn và thưa hạt do một đám mây nhỏ đưa đến, một thoáng rồi lại tạnh" là:', 'mưa bóng mây', 'mưa dầm', 'mưa phùn', 'mưa đá', 'mưa bóng mây', null::jsonb, 'Mưa bóng mây chỉ thoáng qua rồi tạnh.', 'tu_ngu_thoi_tiet', 10::int),
    (2::smallint, 'multiple_choice', '"Mưa rất nhỏ nhưng dày hạt, thường có ở miền Bắc vào cuối mùa đông, đầu mùa xuân" là:', 'mưa rào', 'mưa phùn', 'mưa đá', 'mưa bóng mây', 'mưa phùn', null::jsonb, 'Mưa phùn nhỏ, dày hạt, có vào cuối đông đầu xuân.', 'tu_ngu_thoi_tiet', 11::int),
    (2::smallint, 'multiple_choice', '"Năm 2019, em cùng cả nhà đi du lịch tại Nha Trang." Câu hỏi đúng cho bộ phận "Năm 2019" là:', 'Em cùng cả nhà đi du lịch ở đâu?', 'Tháng mấy em đi du lịch?', 'Năm nào em cùng cả nhà đi du lịch?', 'Em đi du lịch với ai?', 'Năm nào em cùng cả nhà đi du lịch?', null::jsonb, '"Năm 2019" chỉ năm nên hỏi bằng "năm nào".', 'cau_hoi_khi_nao', 11::int),
    (2::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Khi nào?" trong câu "Đoàn thuyền đánh cá lại ra khơi khi hoàng hôn buông xuống." là:', 'Đoàn thuyền đánh cá', 'lại ra khơi', 'khi hoàng hôn buông xuống', null, 'khi hoàng hôn buông xuống', null::jsonb, '"Khi hoàng hôn buông xuống" chỉ thời gian.', 'cau_hoi_khi_nao', 11::int),
    (2::smallint, 'multiple_choice', 'Từ ngữ nào chỉ đặc điểm của thời tiết trong câu thơ "Con ve cũng mệt vì hè nắng oi."?', 'con ve', 'mệt', 'cũng', 'nắng oi', 'nắng oi', null::jsonb, '"Nắng oi" tả thời tiết nóng bức của mùa hè.', 'tu_ngu_thoi_tiet', 11::int),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp: "Lại có những ngày thu ___ hiu hiu gió thổi."', 'nóng nực', 'mát mẻ', 'rét mướt', 'cắt da cắt thịt', 'mát mẻ', null::jsonb, 'Mùa thu có những ngày mát mẻ, gió hiu hiu.', 'tu_ngu_thoi_tiet', 13::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Thời tiết thật khoan khoái dễ chịu. Không chói chang gay gắt như mùa hè, không yếu ớt le lói như mùa đông, nắng thu vàng rực rỡ. Gió mùa thu cũng khác. Se se lạnh."
Thời tiết mùa thu thế nào?', 'khoan khoái, dễ chịu, nắng vàng, se se lạnh', 'oi bức, nóng nực, nắng chói chang', 'nắng yếu ớt, không khí ẩm ướt', null, 'khoan khoái, dễ chịu, nắng vàng, se se lạnh', null::jsonb, 'Đoạn văn tả mùa thu khoan khoái, nắng vàng rực rỡ, gió se se lạnh.', 'doc_hieu', 14::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Đi trong rừng thu, ngắm những sợi nắng vàng tơ xuyên qua kẽ lá, nghe từng tiếng lá vàng rơi, thoang thoảng tiếng chim gù…"
Đi trong rừng thu, tác giả nghe thấy những âm thanh gì?', 'tiếng lá vàng rơi, tiếng chim gù', 'tiếng lá vàng rơi, sợi nắng vàng tơ', 'sợi nắng vàng tơ, tiếng chim gù', null, 'tiếng lá vàng rơi, tiếng chim gù', null::jsonb, 'Sợi nắng là thứ nhìn thấy; tiếng lá rơi và tiếng chim gù mới là âm thanh.', 'doc_hieu', 14::int),
    (2::smallint, 'multiple_choice', '"Vào một sáng đẹp trời, các bạn rủ nhau đi cắm trại." Câu hỏi đúng cho bộ phận "Vào một sáng đẹp trời" là:', 'Các bạn rủ nhau đi cắm trại ở đâu?', 'Các bạn rủ nhau làm gì?', 'Vì sao các bạn đi cắm trại?', 'Khi nào các bạn rủ nhau đi cắm trại?', 'Khi nào các bạn rủ nhau đi cắm trại?', null::jsonb, 'Bộ phận này chỉ thời gian nên hỏi "Khi nào?".', 'cau_hoi_khi_nao', 15::int),
    (3::smallint, 'multiple_choice', 'Câu "Thời tiết thật khoan khoái dễ chịu." thuộc kiểu câu nào?', 'Ai là gì?', 'Ai làm gì?', 'Ai thế nào?', null, 'Ai thế nào?', null::jsonb, 'Câu nêu đặc điểm của thời tiết (khoan khoái dễ chịu) nên là kiểu Ai thế nào?', 'kieu_cau', 14::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Gió mùa thu cũng khác. Se se lạnh. Man mác buồn. Không vồ vập hồ hởi như gió hạ; không tái tê, buốt giá như gió đông… Gió thu nhè nhẹ, thoang thoảng, như có, như không."
Gió thu có những nét riêng nào?', 'tái tê, buốt giá, man mác buồn', 'se lạnh, nhè nhẹ, thoang thoảng, man mác buồn', 'vồ vập, hồ hởi, nhè nhẹ', null, 'se lạnh, nhè nhẹ, thoang thoảng, man mác buồn', null::jsonb, 'Vồ vập là gió hạ, tái tê buốt giá là gió đông.', 'doc_hieu', 14::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): Bác Đào già nói với dòng Suối nhỏ: "Bạn Suối ơi ( ) Bạn hãy nhắn với cả khu rừng nhé!"', 'dấu chấm', 'dấu chấm hỏi', 'dấu phẩy', 'dấu chấm than', 'dấu chấm than', null::jsonb, '"Bạn Suối ơi" là lời gọi nên dùng dấu chấm than.', 'dau_cau', 15::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Suối nhỏ đã nhanh chóng chuyển lời nhắn của bác Đào ( ) Chẳng mấy chốc, cả khu rừng đã biết tin vui này."', 'dấu chấm', 'dấu chấm than', 'dấu chấm hỏi', 'dấu phẩy', 'dấu chấm', null::jsonb, 'Đây là câu kể bình thường, kết thúc bằng dấu chấm.', 'dau_cau', 15::int),
    (3::smallint, 'multiple_choice', 'Câu nào nói ĐÚNG về đặc điểm của mùa hè?', 'Những cành cây trụi lá, gầy khẳng khiu.', 'Những cơn mưa rào xối xả.', 'Hoa cúc nở vàng tươi.', 'Học sinh được nghỉ để đón Tết.', 'Những cơn mưa rào xối xả.', null::jsonb, 'Mùa hè có mưa rào xối xả; cây trụi lá, đón Tết là mùa đông, hoa cúc là mùa thu.', 'tu_ngu_cac_mua', 13::int),
    (3::smallint, 'multiple_choice', 'Câu nào KHÔNG nói về mùa hè?', 'Nắng chói chang, gay gắt.', 'Không khí ngột ngạt, oi nồng.', 'Không khí ấm áp lạ thường.', 'Hoa phượng nở đỏ rực, rộn rã tiếng ve.', 'Không khí ấm áp lạ thường.', null::jsonb, 'Ấm áp là đặc điểm của mùa xuân.', 'tu_ngu_cac_mua', 13::int),
    (2::smallint, 'multiple_choice', 'Câu nào cần đặt dấu chấm than ở cuối?', 'Nhà em ở gần hồ', 'Hôm qua trời mưa', 'Ôi, hoa đào nở đẹp quá', null, 'Ôi, hoa đào nở đẹp quá', null::jsonb, 'Câu bộc lộ cảm xúc (Ôi, … quá) dùng dấu chấm than.', 'dau_cau', 10::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 20 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 21: Chim chóc – Từ ngữ về chim chóc, câu hỏi Ở đâu? (30 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 21, 100, 'Archimes: Chim chóc – Từ ngữ về chim chóc, câu hỏi Ở đâu?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 21', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ch hay tr: ___im sẻ', null, null, null, null, 'ch', null::jsonb, 'Chim sẻ viết với ch.', 'chinh_ta_ch_tr', 16::int),
    (1::smallint, 'text', 'Điền ch hay tr: cây ___e', null, null, null, null, 'tr', null::jsonb, 'Cây tre viết với tr.', 'chinh_ta_ch_tr', 16::int),
    (1::smallint, 'text', 'Điền ch hay tr: ___ụp ảnh', null, null, null, null, 'ch', null::jsonb, 'Chụp ảnh viết với ch.', 'chinh_ta_ch_tr', 16::int),
    (1::smallint, 'text', 'Điền ch hay tr: ___ao đổi', null, null, null, null, 'tr', null::jsonb, 'Trao đổi viết với tr.', 'chinh_ta_ch_tr', 16::int),
    (1::smallint, 'text', 'Điền uôt hay uôc (thêm dấu thanh nếu cần): trắng m___', null, null, null, null, 'uốt', '["muốt"]'::jsonb, 'Trắng muốt có vần uôt.', 'chinh_ta_uot_uoc', 16::int),
    (1::smallint, 'text', 'Điền uôt hay uôc (thêm dấu thanh nếu cần): rau l___', null, null, null, null, 'uộc', '["luộc"]'::jsonb, 'Rau luộc có vần uôc.', 'chinh_ta_uot_uoc', 16::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: con ___', 'chuột', 'chuộc', 'truột', null, 'chuột', null::jsonb, 'Con chuột viết với ch, vần uôt.', 'chinh_ta_uot_uoc', 16::int),
    (1::smallint, 'multiple_choice', '"Bay ngang, bay dọc, báo mùa xuân về" là chim gì?', 'chim sâu', 'chim én', 'chim cuốc', 'chim sáo', 'chim én', null::jsonb, 'Chim én bay về báo hiệu mùa xuân.', 'tu_ngu_chim_choc', 17::int),
    (1::smallint, 'multiple_choice', '"Luôn chân nhảy nhót, vạch lá tìm sâu" là chú chim gì?', 'chim én', 'chim cuốc', 'chim sâu', 'chim sáo', 'chim sâu', null::jsonb, 'Chim sâu chuyên tìm bắt sâu trên lá.', 'tu_ngu_chim_choc', 17::int),
    (1::smallint, 'multiple_choice', 'Câu hỏi "Ở đâu?" dùng để hỏi về điều gì?', 'thời gian', 'nguyên nhân', 'đặc điểm', 'địa điểm', 'địa điểm', null::jsonb, '"Ở đâu?" hỏi về địa điểm xảy ra sự việc.', 'cau_hoi_o_dau', 17::int),
    (1::smallint, 'multiple_choice', 'Chọn từ thích hợp: "Tiếng chim ___ ngân vang khắp bầu trời xanh."', 'kêu', 'hót', 'gáy', null, 'hót', null::jsonb, 'Chim sơn ca hót, tiếng hót ngân vang.', 'tu_ngu_chim_choc', 17::int),
    (2::smallint, 'multiple_choice', '"Tiếng kêu da diết, ở bụi ở bờ, báo mùa hè tới" là con chim gì?', 'chim én', 'chim sâu', 'chim cuốc', 'chim sáo', 'chim cuốc', null::jsonb, 'Chim cuốc kêu "cuốc cuốc" vào mùa hè.', 'tu_ngu_chim_choc', 17::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chim ác là có tới mấy ngàn con ríu rít là là trên mặt ruộng. Chim tu hú ở đâu không thấy mặt, mà chỉ nghe tiếng kêu vòng vọng. Con chim te te kêu hoành hoạch."
Tiếng kêu của chim tu hú được tả bằng từ nào?', 'ríu rít', 'hoành hoạch', 'là là', 'vòng vọng', 'vòng vọng', null::jsonb, 'Chim tu hú "chỉ nghe tiếng kêu vòng vọng".', 'doc_hieu', 18::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chim ác là có tới mấy ngàn con ríu rít là là trên mặt ruộng. Chim tu hú ở đâu không thấy mặt, mà chỉ nghe tiếng kêu vòng vọng. Con chim te te kêu hoành hoạch."
Từ nào tả tiếng kêu của chim te te?', 'hoành hoạch', 'vòng vọng', 'ríu rít', 'là là', 'hoành hoạch', null::jsonb, '"Con chim te te kêu hoành hoạch."', 'doc_hieu', 18::int),
    (2::smallint, 'multiple_choice', '"Đàn gà đang kiếm ăn trong khu vườn." Bộ phận "trong khu vườn" trả lời cho câu hỏi nào?', 'Ở đâu?', 'Khi nào?', 'Làm gì?', 'Như thế nào?', 'Ở đâu?', null::jsonb, '"Trong khu vườn" chỉ địa điểm.', 'cau_hoi_o_dau', 18::int),
    (2::smallint, 'multiple_choice', '"Chú mèo đang đùa nghịch ở góc nhà." Câu hỏi đúng cho bộ phận "ở góc nhà" là:', 'Chú mèo đang làm gì?', 'Chú mèo đang đùa nghịch ở đâu?', 'Khi nào chú mèo đùa nghịch?', 'Chú mèo đùa nghịch thế nào?', 'Chú mèo đang đùa nghịch ở đâu?', null::jsonb, 'Bộ phận chỉ địa điểm nên hỏi "ở đâu?".', 'cau_hoi_o_dau', 18::int),
    (2::smallint, 'multiple_choice', 'Dòng nào gồm toàn tên các loài chim?', 'chìa vôi, mèo, sáo, liếu điếu', 'sáo, chèo bẻo, sóc, khách', 'chìa vôi, sáo, chèo bẻo, liếu điếu', null, 'chìa vôi, sáo, chèo bẻo, liếu điếu', null::jsonb, 'Mèo, sóc là thú, không phải chim.', 'tu_ngu_chim_choc', 17::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Hải âu là bạn của người đi biển. Chúng báo trước cho họ những cơn bão."
(Theo Vũ Hùng)
Vì sao người ta gọi hải âu là bạn của người đi biển?', 'Hải âu báo cho họ nơi có nhiều cá.', 'Hải âu luôn bay sát theo thuyền.', 'Hải âu báo trước những cơn bão sắp đến.', null, 'Hải âu báo trước những cơn bão sắp đến.', null::jsonb, 'Hải âu báo trước bão cho người đi biển.', 'doc_hieu', 20::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Lúc trời sắp nổi bão, chúng càng bay nhiều, vờn sát ngọn sóng hơn và về ổ muộn hơn, chúng cần kiếm mồi sẵn cho lũ con ăn trong nhiều ngày, chờ khi biển lặng."
Lúc trời sắp nổi bão, hải âu thường làm gì?', 'Chăm chỉ kiếm sẵn mồi cho con ăn nhiều ngày.', 'Kêu vang khắp mặt biển.', 'Sửa lại tổ cho lũ con tránh bão.', null, 'Chăm chỉ kiếm sẵn mồi cho con ăn nhiều ngày.', null::jsonb, 'Chúng kiếm mồi sẵn cho con ăn trong nhiều ngày, chờ biển lặng.', 'doc_hieu', 20::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Người dân chài ghé bến sau chuyến lưới đêm lại tung cá và mực xuống đãi chúng bữa ăn buổi sáng."
Người dân chài làm gì để cảm ơn hải âu?', 'Lấy cơm đãi hải âu bữa sáng.', 'Tung cá và mực đãi hải âu bữa sáng.', 'Hát bài hát kéo lưới.', null, 'Tung cá và mực đãi hải âu bữa sáng.', null::jsonb, 'Họ tung cá và mực xuống đãi hải âu.', 'doc_hieu', 20::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ai đã từng lênh đênh trên biển cả dài ngày mà thấy những cánh hải âu, lòng lại không cháy bùng hi vọng? Chúng báo hiệu đất liền, báo hiệu sự bình an, báo trước sự sum họp gia đình."
Vì sao người đi biển thấy hải âu lại bùng cháy hi vọng?', 'Hải âu báo hiệu bão sắp tan.', 'Hải âu báo hiệu trời sắp mưa lớn.', 'Hải âu báo hiệu đất liền, bình an, sum họp.', null, 'Hải âu báo hiệu đất liền, bình an, sum họp.', null::jsonb, 'Thấy hải âu là biết sắp tới đất liền, được bình an, sum họp gia đình.', 'doc_hieu', 20::int),
    (2::smallint, 'text', 'Giải câu đố:
"Chim gì có cánh không bay
Chỉ bơi với lặn suốt ngày dưới băng?"', null, null, null, null, 'chim cánh cụt', '["cánh cụt"]'::jsonb, 'Chim cánh cụt không bay được, sống ở xứ băng giá.', 'giai_do', 21::int),
    (2::smallint, 'text', 'Giải câu đố:
"Chim gì biểu tượng hòa bình
Cả nhân loại lẫn chúng mình đều yêu?"', null, null, null, null, 'chim bồ câu', '["bồ câu"]'::jsonb, 'Chim bồ câu trắng là biểu tượng của hòa bình.', 'giai_do', 21::int),
    (2::smallint, 'text', 'Điền uôt hay uôc (thêm dấu thanh nếu cần): Thầy th___ như mẹ hiền.', null, null, null, null, 'uốc', '["thuốc"]'::jsonb, 'Thầy thuốc có vần uôc.', 'chinh_ta_uot_uoc', 21::int),
    (3::smallint, 'text', 'Điền uôt hay uôc (thêm dấu thanh nếu cần): Con mèo luôn sẵn sàng móng v___ để vồ mồi.', null, null, null, null, 'uốt', '["vuốt"]'::jsonb, 'Móng vuốt có vần uôt.', 'chinh_ta_uot_uoc', 21::int),
    (3::smallint, 'text', 'Điền ch hay tr: Đó là một cậu bé ___ạc mười ba tuổi.', null, null, null, null, 'ch', null::jsonb, '"Chạc mười ba tuổi" nghĩa là khoảng mười ba tuổi, viết với ch.', 'chinh_ta_ch_tr', 21::int),
    (3::smallint, 'text', 'Điền ch hay tr: Mỗi chiếc nấm là một lâu đài kiến ___úc tân kì.', null, null, null, null, 'tr', null::jsonb, 'Kiến trúc viết với tr.', 'chinh_ta_ch_tr', 21::int),
    (3::smallint, 'multiple_choice', 'Chọn tiếng đúng: ___ lỗi (làm việc tốt để bù lại lỗi lầm)', 'chuộc', 'chuột', 'truộc', null, 'chuộc', null::jsonb, 'Chuộc lỗi viết với ch, vần uôc.', 'chinh_ta_uot_uoc', 16::int),
    (3::smallint, 'multiple_choice', 'Câu nào có bộ phận trả lời câu hỏi "Ở đâu?"', 'Khỉ con rất nghịch ngợm.', 'Khỉ con đánh đu trên cành cây.', 'Sáng nay, khỉ con dậy sớm.', null, 'Khỉ con đánh đu trên cành cây.', null::jsonb, '"Trên cành cây" chỉ địa điểm.', 'cau_hoi_o_dau', 21::int),
    (3::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Ở đâu?" trong câu "Con giun đất suốt ngày hì hục đào đất dưới gốc cây." là:', 'Con giun đất', 'suốt ngày', 'hì hục đào đất', 'dưới gốc cây', 'dưới gốc cây', null::jsonb, '"Suốt ngày" chỉ thời gian, "dưới gốc cây" mới chỉ địa điểm.', 'cau_hoi_o_dau', 21::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 21 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 22: Chim chóc – Từ ngữ về loài chim, dấu chấm và dấu phẩy (37 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 22, 100, 'Archimes: Chim chóc – Từ ngữ về loài chim, dấu chấm và dấu phẩy', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 22', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Mẹ dỗ ___ yêu thương."', 'dành', 'rành', 'giành', null, 'dành', null::jsonb, 'Dỗ dành viết với d.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Mẹ mua bánh ___ cho em ăn sáng."', 'dò', 'giò', 'rò', null, 'giò', null::jsonb, 'Bánh giò viết với gi.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Cá heo sinh con và nuôi con bằng ___."', 'sửa', 'xữa', 'sữa', null, 'sữa', null::jsonb, 'Sữa (để uống) có dấu ngã.', 'dau_hoi_nga', 22::int),
    (1::smallint, 'text', 'Điền r, d hay gi: Tiếng ___ừa làm dịu nắng trưa', null, null, null, null, 'd', null::jsonb, 'Cây dừa viết với d.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'text', 'Điền r, d hay gi: Gọi đàn ___ó đến cùng dừa múa reo', null, null, null, null, 'gi', null::jsonb, 'Gió viết với gi.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'text', 'Điền r, d hay gi: Trời trong đầy tiếng ___ì rào', null, null, null, null, 'r', null::jsonb, 'Rì rào viết với r.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'text', 'Điền r, d hay gi: Mưa ___ăng trên đồng', null, null, null, null, 'gi', null::jsonb, 'Mưa giăng (giăng khắp) viết với gi.', 'chinh_ta_d_r_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Loài chim ăn thịt, có cặp mắt to tròn, thường kiếm ăn vào ban đêm là:', 'gõ kiến', 'bồ câu', 'chim sâu', 'cú mèo', 'cú mèo', null::jsonb, 'Cú mèo kiếm ăn ban đêm, mắt to tròn.', 'tu_ngu_chim_choc', 23::int),
    (1::smallint, 'multiple_choice', 'Loài chim nhỏ, màu sặc sỡ, dùng mỏ gõ vào thân cây để bắt sâu, kiến là:', 'gõ kiến', 'cú mèo', 'bói cá', 'vàng anh', 'gõ kiến', null::jsonb, 'Chim gõ kiến gõ mỏ vào thân cây bắt kiến.', 'tu_ngu_chim_choc', 23::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chiếc tổ Vành Khuyên nhỏ xíu nằm lọt giữa hai chiếc lá bưởi. Đêm đêm, mùi lá bưởi thơm cả vào những giấc mơ."
(Theo Trần Đức Tiến)
Chiếc tổ của Vành Khuyên ở đâu?', 'trong hốc cây', 'trên ban công', 'nằm lọt giữa hai chiếc lá bưởi', null, 'nằm lọt giữa hai chiếc lá bưởi', null::jsonb, 'Tổ nằm lọt giữa hai chiếc lá bưởi.', 'doc_hieu', 26::int),
    (1::smallint, 'multiple_choice', 'Hưng làm rơi vở của Dũng và xin lỗi: "Xin lỗi, tớ vô ý quá!" Dũng đáp lời nào lịch sự nhất?', 'Làm bẩn vở của tớ rồi còn xin lỗi gì.', 'Không sao đâu. Lần sau bạn nhớ cẩn thận nhé!', 'Cậu đừng vô ý như vậy nữa.', null, 'Không sao đâu. Lần sau bạn nhớ cẩn thận nhé!', null::jsonb, 'Đáp lời xin lỗi cần lịch sự, biết thông cảm.', 'dap_loi_xin_loi', 25::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Các chú ong thợ lần lượt rời khỏi hang lấy giọt sáp dưới bụng do mình tiết ra trộn với nước bọt thành một chất đặc biệt để xây thành tổ."
Ong nào tiết ra những giọt sáp?', 'ong chúa', 'ong thợ', 'ong non', null, 'ong thợ', null::jsonb, 'Ong thợ lấy giọt sáp dưới bụng do mình tiết ra.', 'doc_hieu', 28::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Ong Thợ (phai) bay xa tìm hoa."', null, null, null, null, 'phải', null::jsonb, 'Viết đúng là "phải" (dấu hỏi).', 'dau_hoi_nga', 22::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "tìm những bông hoa vừa (nơ)"', null, null, null, null, 'nở', null::jsonb, 'Hoa nở có dấu hỏi.', 'dau_hoi_nga', 22::int),
    (3::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Nụ cười của ông hôm nay càng rạng (rơ)."', null, null, null, null, 'rỡ', null::jsonb, 'Rạng rỡ có dấu ngã.', 'dau_hoi_nga', 22::int),
    (2::smallint, 'text', 'Sửa lỗi chính tả: "Ba cậu bé dủ nhau vào rừng chơi." Từ "dủ" viết đúng là ___', null, null, null, null, 'rủ', null::jsonb, 'Rủ nhau viết với r.', 'chinh_ta_d_r_gi', 23::int),
    (3::smallint, 'text', 'Sửa lỗi chính tả: "Lại có đủ thứ thật hấp rẫn." Từ "rẫn" viết đúng là ___', null, null, null, null, 'dẫn', null::jsonb, 'Hấp dẫn viết với d.', 'chinh_ta_d_r_gi', 23::int),
    (2::smallint, 'multiple_choice', 'Các loài chim "gõ kiến, bói cá, chim sâu" được gọi tên theo đặc điểm gì?', 'hình dáng', 'tiếng kêu', 'cách kiếm ăn', null, 'cách kiếm ăn', null::jsonb, 'Gõ kiến, bói cá, chim sâu được đặt tên theo cách chúng kiếm ăn.', 'tu_ngu_chim_choc', 23::int),
    (3::smallint, 'multiple_choice', 'Các loài chim "tu hú, cuốc, quạ" được gọi tên theo đặc điểm gì?', 'tiếng kêu', 'hình dáng', 'cách kiếm ăn', null, 'tiếng kêu', null::jsonb, 'Tu hú, cuốc, quạ được gọi theo tiếng kêu của chúng.', 'tu_ngu_chim_choc', 23::int),
    (3::smallint, 'multiple_choice', 'Các loài chim "cú mèo, vàng anh, cánh cụt" được gọi tên theo đặc điểm gì?', 'tiếng kêu', 'hình dáng', 'cách kiếm ăn', null, 'hình dáng', null::jsonb, 'Cú mèo, vàng anh, cánh cụt được gọi theo hình dáng, màu sắc.', 'tu_ngu_chim_choc', 23::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Lượn bay biển lớn sớm trưa
Sóng gió chẳng quản nắng mưa chẳng sờn."', 'chim sâu', 'cú mèo', 'chim sẻ', 'hải âu', 'hải âu', null::jsonb, 'Hải âu bay lượn trên biển cả.', 'giai_do', 24::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Chim gì dang cánh lượn bay
Cắp nàng công chúa truyện ngày cổ xưa?"', 'bồ câu', 'chim sâu', 'hải âu', 'đại bàng', 'đại bàng', null::jsonb, 'Trong truyện cổ Thạch Sanh, đại bàng cắp công chúa.', 'giai_do', 24::int),
    (2::smallint, 'text', 'Giải câu đố:
"Chim gì nho nhỏ
Cái mỏ xinh xinh
Chăm nhặt, chăm tìm
Bắt sâu cho lá?"', null, null, null, null, 'chim sâu', null::jsonb, 'Chim sâu nhỏ bé, chăm bắt sâu cho lá.', 'giai_do', 24::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Ếch con, ngoan ngoãn chăm chỉ và thông minh.', 'Ếch con ngoan ngoãn chăm chỉ, và thông minh.', 'Ếch con ngoan ngoãn, chăm chỉ và thông minh.', null, 'Ếch con ngoan ngoãn, chăm chỉ và thông minh.', null::jsonb, 'Dấu phẩy ngăn cách các từ cùng chỉ đặc điểm: ngoan ngoãn, chăm chỉ.', 'dau_phay', 24::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Hươu sợ bóng tối, sợ thú dữ, sợ cả tiếng động lạ.', 'Hươu, sợ bóng tối sợ thú dữ, sợ cả tiếng động lạ.', 'Hươu sợ bóng tối sợ thú dữ sợ, cả tiếng động lạ.', null, 'Hươu sợ bóng tối, sợ thú dữ, sợ cả tiếng động lạ.', null::jsonb, 'Dấu phẩy ngăn cách các bộ phận giống nhau: sợ bóng tối, sợ thú dữ, sợ cả…', 'dau_phay', 24::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Ngoài giờ học, chúng tôi tha thẩn ở bờ sông bắt bướm.', 'Ngoài giờ, học chúng tôi tha thẩn ở bờ sông bắt bướm.', 'Ngoài giờ học chúng tôi, tha thẩn ở bờ sông bắt bướm.', null, 'Ngoài giờ học, chúng tôi tha thẩn ở bờ sông bắt bướm.', null::jsonb, 'Dấu phẩy đặt sau bộ phận chỉ thời gian "Ngoài giờ học".', 'dau_phay', 24::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Ngày xưa ( ) Gà Trống có thể bay cao và bay xa nhất trong họ nhà chim."', 'dấu chấm', 'dấu phẩy', 'dấu chấm than', null, 'dấu phẩy', null::jsonb, 'Sau bộ phận chỉ thời gian ở đầu câu dùng dấu phẩy.', 'dau_cau', 24::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "…được trao tặng một chiếc mũ miện đỏ chót ( ) Gà Trống kiêu hãnh lắm."', 'dấu phẩy', 'dấu chấm hỏi', 'dấu chấm', null, 'dấu chấm', null::jsonb, 'Hết một câu kể, chữ sau viết hoa nên dùng dấu chấm.', 'dau_cau', 24::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Mấy anh em Vành Khuyên nằm gối đầu lên nhau, mơ một ngày khôn lớn sải cánh bay ra trời rộng."
Khi còn nhỏ, Vành Khuyên mơ ước điều gì?', 'Khôn lớn, sải cánh bay ra trời rộng.', 'Được gặp nhiều nhân vật lí thú.', 'Được ở mãi trong tổ lá bưởi.', null, 'Khôn lớn, sải cánh bay ra trời rộng.', null::jsonb, 'Vành Khuyên mơ một ngày khôn lớn sải cánh bay ra trời rộng.', 'doc_hieu', 26::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ai cũng chào đón nó. Vùng đất nào cũng tươi đẹp. Đôi cánh cứng cáp lên, Vành Khuyên bay mãi, bay mãi…"
Đôi cánh của Vành Khuyên thế nào sau khi đến nhiều vùng đất?', 'non mềm', 'cứng cáp lên', 'yếu ớt hơn', null, 'cứng cáp lên', null::jsonb, '"Đôi cánh cứng cáp lên."', 'doc_hieu', 26::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Nó lại nhìn thấy tít trên ngọn tre cao, anh Chích Chòe đang rỉa lông, tắm nắng:
– Chào em. Nhớ khi bay chỉ nhìn về phía trước thôi nhé!"
Anh Chích Chòe dặn Vành Khuyên điều gì?', 'Khi bay phải nhìn lại phía sau.', 'Đừng bay ra khỏi tổ.', 'Khi bay chỉ nhìn về phía trước.', null, 'Khi bay chỉ nhìn về phía trước.', null::jsonb, 'Anh Chích Chòe dặn: khi bay chỉ nhìn về phía trước.', 'doc_hieu', 26::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Hết sáp, chú tự rút lui về sau để những chú khác tiến lên xây tiếp."
(Ong xây tổ)
Hết sáp, ong thợ làm gì?', 'Rút lui về sau để các chú khác xây tiếp.', 'Dùng sức nóng sưởi ấm giọt sáp.', 'Tiến lên xây tổ tiếp.', null, 'Rút lui về sau để các chú khác xây tiếp.', null::jsonb, 'Hết sáp, ong thợ rút lui về sau nhường chỗ cho ong khác.', 'doc_hieu', 28::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chỉ vài ba tháng sau, một tổ ong đã được xây xong. Đó là một tòa nhà vững chãi, ngăn nắp, trật tự, có hàng ngàn căn phòng giống hệt nhau."
Tổ ong được miêu tả là tòa nhà thế nào?', 'nguy nga, lộng lẫy, đầy màu sắc', 'vững chãi, ngăn nắp, trật tự', 'nhỏ nhắn, giản dị, nhiều cửa sổ', null, 'vững chãi, ngăn nắp, trật tự', null::jsonb, 'Tổ ong vững chãi, ngăn nắp, trật tự, có hàng ngàn căn phòng.', 'doc_hieu', 28::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: vấp ___', 'ngả', 'ngạ', 'ngã', null, 'ngã', null::jsonb, 'Vấp ngã (té ngã) có dấu ngã.', 'dau_hoi_nga', 27::int),
    (3::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Hàng cây ___ nghiêng trong gió."', 'ngả', 'ngã', 'ngà', null, 'ngả', null::jsonb, 'Ngả nghiêng (nghiêng qua nghiêng lại) viết dấu hỏi.', 'dau_hoi_nga', 27::int),
    (3::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Bà khuyên ___ em chăm học."', 'nhũ', 'nhủ', 'nhụ', null, 'nhủ', null::jsonb, 'Khuyên nhủ, nhắn nhủ có dấu hỏi.', 'dau_hoi_nga', 27::int),
    (3::smallint, 'multiple_choice', 'Trong truyện "Sư Tử, Lừa và Cáo", Lừa chia mồi làm ba phần đều nhau. Chuyện gì xảy ra sau đó?', 'Sư Tử khen Lừa chia khéo.', 'Cáo giành hết phần mồi.', 'Sư Tử tức giận, nhảy xổ tới xé xác Lừa.', null, 'Sư Tử tức giận, nhảy xổ tới xé xác Lừa.', null::jsonb, 'Sư Tử muốn phần hơn nên tức giận khi Lừa chia đều.', 'sap_xep_cau', 29::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 22 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 23: Muông thú – Từ ngữ về muông thú, câu hỏi Như thế nào? (38 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 23, 100, 'Archimes: Muông thú – Từ ngữ về muông thú, câu hỏi Như thế nào?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 23', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền l hay n: "Hoa gì không ___ở ban ngày"', null, null, null, null, 'n', null::jsonb, 'Nở (hoa nở) viết với n.', 'chinh_ta_l_n', 30::int),
    (1::smallint, 'text', 'Điền l hay n: "Gió ___ên vườn cải tốt tươi"', null, null, null, null, 'l', null::jsonb, 'Lên viết với l.', 'chinh_ta_l_n', 30::int),
    (1::smallint, 'text', 'Điền l hay n: "Em đi múc ___ước dưới ao"', null, null, null, null, 'n', null::jsonb, 'Nước viết với n.', 'chinh_ta_l_n', 30::int),
    (1::smallint, 'text', 'Điền l hay n: liên ___ạc', null, null, null, null, 'l', null::jsonb, 'Liên lạc viết với l.', 'chinh_ta_l_n', 35::int),
    (1::smallint, 'text', 'Điền l hay n: ___ườm nượp', null, null, null, null, 'n', null::jsonb, 'Nườm nượp viết với n.', 'chinh_ta_l_n', 35::int),
    (1::smallint, 'text', 'Điền ươc hay ươt (thêm dấu thanh nếu cần): xanh m___', null, null, null, null, 'ướt', '["mướt"]'::jsonb, 'Xanh mướt có vần ươt.', 'chinh_ta_uoc_uot', 30::int),
    (1::smallint, 'text', 'Điền ươc hay ươt (thêm dấu thanh nếu cần): r___ đèn', null, null, null, null, 'ước', '["rước"]'::jsonb, 'Rước đèn có vần ươc.', 'chinh_ta_uoc_uot', 30::int),
    (1::smallint, 'multiple_choice', 'Câu hỏi "Như thế nào?" dùng để hỏi về điều gì?', 'đặc điểm, tính chất, mức độ', 'địa điểm', 'thời gian', 'nguyên nhân', 'đặc điểm, tính chất, mức độ', null::jsonb, '"Như thế nào?" hỏi về đặc điểm, tính chất, mức độ của hoạt động, trạng thái.', 'cau_hoi_nhu_the_nao', 31::int),
    (1::smallint, 'multiple_choice', 'Con vật nào "là thú dữ, to lớn, lông màu vàng có vằn đen"?', 'voi', 'hổ', 'nai', 'sóc', 'hổ', null::jsonb, 'Hổ là thú dữ, lông vàng có vằn đen.', 'tu_ngu_muong_thu', 31::int),
    (1::smallint, 'multiple_choice', 'Con vật nào "láu lỉnh, hay bắt chước, leo trèo giỏi"?', 'voi', 'cáo', 'khỉ', 'nai', 'khỉ', null::jsonb, 'Khỉ leo trèo giỏi và hay bắt chước.', 'tu_ngu_muong_thu', 31::int),
    (1::smallint, 'multiple_choice', 'Tên con vật nào thuộc nhóm loài chim?', 'hươu sao', 'gấu', 'sóc', 'chích chòe', 'chích chòe', null::jsonb, 'Chích chòe là chim; hươu sao, gấu, sóc là thú.', 'tu_ngu_muong_thu', 31::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Trong rừng xanh sâu thẳm, Thỏ Trắng đang rong chơi, bất ngờ Chó Xồm từ phía sau nhảy bổ ra."
(Thỏ và Bò)
Thỏ Trắng, Bò và Chó Xồm sống ở đâu?', 'ở sở thú', 'trong rừng xanh sâu thẳm', 'trong một ngôi nhà', null, 'trong rừng xanh sâu thẳm', null::jsonb, 'Câu chuyện diễn ra trong rừng xanh sâu thẳm.', 'doc_hieu', 34::int),
    (2::smallint, 'multiple_choice', 'Con vật nào "có vóc dáng nhỏ bé, nhanh nhẹn, ăn các loại hạt và quả"?', 'nai', 'hổ', 'sóc', 'cáo', 'sóc', null::jsonb, 'Sóc nhỏ bé, nhanh nhẹn, thích ăn hạt.', 'tu_ngu_muong_thu', 31::int),
    (2::smallint, 'multiple_choice', 'Con vật nào "sống trong rừng, thường xuất hiện trong truyện với vẻ ranh mãnh, gian ác"?', 'voi', 'nai', 'sóc', 'cáo', 'cáo', null::jsonb, 'Cáo thường là nhân vật ranh mãnh trong truyện.', 'tu_ngu_muong_thu', 31::int),
    (2::smallint, 'multiple_choice', 'Dòng nào gồm toàn tên các loài thú?', 'hổ, báo, nai, gấu', 'hổ, vẹt, nai, gấu', 'voi, sóc, họa mi, báo', null, 'hổ, báo, nai, gấu', null::jsonb, 'Vẹt, họa mi là chim.', 'tu_ngu_muong_thu', 31::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "Nhát như ___ đế."', 'thỏ', 'voi', 'cọp', 'ngựa', 'thỏ', null::jsonb, 'Thỏ rất nhút nhát: nhát như thỏ đế.', 'thanh_ngu', 32::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "Khỏe như ___."', 'thỏ', 'voi', 'sáo', 'gà', 'voi', null::jsonb, 'Voi rất khỏe: khỏe như voi.', 'thanh_ngu', 32::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "Dữ như ___."', 'thỏ', 'bò', 'cọp', 'sáo', 'cọp', null::jsonb, 'Cọp (hổ) rất dữ: dữ như cọp.', 'thanh_ngu', 32::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "___ cùng một mẹ chớ hoài đá nhau."', 'Chó', 'Thỏ', 'Ngựa', 'Gà', 'Gà', null::jsonb, 'Câu đầy đủ: Gà cùng một mẹ chớ hoài đá nhau.', 'thanh_ngu', 32::int),
    (3::smallint, 'multiple_choice', 'Điền tên con vật: "Một con ___ đau, cả tàu bỏ cỏ."', 'ngựa', 'bò', 'voi', 'gà', 'ngựa', null::jsonb, 'Tàu là chuồng ngựa: một con ngựa đau, cả tàu bỏ cỏ.', 'thanh_ngu', 32::int),
    (3::smallint, 'multiple_choice', 'Điền tên con vật: "Mất ___ mới lo làm chuồng."', 'gà', 'bò', 'chó', 'ong', 'bò', null::jsonb, 'Câu tục ngữ: Mất bò mới lo làm chuồng.', 'thanh_ngu', 32::int),
    (3::smallint, 'multiple_choice', 'Điền tên con vật: "___ tắm thì ráo, sáo tắm thì mưa."', 'Gà', 'Ong', 'Quạ', 'Chó', 'Quạ', null::jsonb, 'Câu tục ngữ về thời tiết: Quạ tắm thì ráo, sáo tắm thì mưa.', 'thanh_ngu', 32::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Con gì nhảy nhót leo trèo
Mình đầy lông lá nhăn nheo làm trò?"', 'con sóc', 'con hổ', 'con thỏ', 'con khỉ', 'con khỉ', null::jsonb, 'Khỉ leo trèo, nhăn nhó làm trò.', 'giai_do', 32::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Lông vằn, lông vện, mắt xanh
Dáng đi uyển chuyển, nhe nanh tìm mồi
Thỏ, nai gặp phải, hỡi ôi!
Muông thú khiếp sợ tôn ngôi chúa rừng."', 'con hổ', 'con mèo', 'con cáo', 'con gấu', 'con hổ', null::jsonb, 'Hổ lông vằn, được gọi là chúa rừng xanh.', 'giai_do', 32::int),
    (3::smallint, 'text', 'Giải câu đố:
"Đầu nhỏ mà có bốn chân
Lưng đầy tên nhọn, khi cần bắn ngay."
Là con gì?', null, null, null, null, 'con nhím', '["nhím"]'::jsonb, 'Nhím có lông cứng nhọn như tên trên lưng.', 'giai_do', 32::int),
    (2::smallint, 'multiple_choice', '"Hổ gầm vang vách núi." Bộ phận "vang vách núi" trả lời cho câu hỏi nào?', 'Ở đâu?', 'Như thế nào?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', null::jsonb, '"Vang vách núi" cho biết hổ gầm như thế nào (mức độ).', 'cau_hoi_nhu_the_nao', 32::int),
    (2::smallint, 'multiple_choice', '"Vượn trèo nhanh thoăn thoắt." Câu hỏi đúng cho bộ phận "nhanh thoăn thoắt" là:', 'Vượn trèo ở đâu?', 'Vượn làm gì?', 'Vượn trèo như thế nào?', 'Khi nào vượn trèo?', 'Vượn trèo như thế nào?', null::jsonb, 'Bộ phận chỉ đặc điểm của hoạt động nên hỏi "như thế nào?".', 'cau_hoi_nhu_the_nao', 33::int),
    (3::smallint, 'multiple_choice', '"Đàn voi đi đủng đỉnh trong rừng." Bộ phận trả lời câu hỏi "Như thế nào?" là:', 'Đàn voi', 'trong rừng', 'đi', 'đủng đỉnh', 'đủng đỉnh', null::jsonb, '"Đủng đỉnh" tả dáng đi; "trong rừng" trả lời câu hỏi Ở đâu?', 'cau_hoi_nhu_the_nao', 33::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Thỏ Trắng bị Chó Xồm rượt đuổi đến lúc không làm sao trốn đi được nữa. Bỗng Thỏ Trắng thấy Bò đang đứng gặm cỏ, Thỏ Trắng liền vừa chạy vừa kêu cứu."
Khi bị Chó Xồm rượt đuổi, Thỏ Trắng đã làm gì?', 'Về nhà khóc, nhờ bố mẹ giúp.', 'Trốn trong một bụi cây.', 'Chạy đến chỗ Bò và kêu cứu.', null, 'Chạy đến chỗ Bò và kêu cứu.', null::jsonb, 'Thỏ Trắng vừa chạy vừa kêu cứu Bò.', 'doc_hieu', 34::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Bò bèn đứng chắn ngang đường, lớn giọng "phì, phì" một cách hung hăng khiến Chó Xồm sợ quá cúp đuôi bỏ chạy."
Bò đã làm gì để cứu Thỏ Trắng?', 'Đứng chắn đường, "phì, phì" thật hung hăng.', 'Húc Chó Xồm ngã lăn ra.', 'Cõng Thỏ Trắng chạy trốn.', null, 'Đứng chắn đường, "phì, phì" thật hung hăng.', null::jsonb, 'Bò chắn đường và phì phì hung hăng dọa Chó Xồm.', 'doc_hieu', 34::int),
    (3::smallint, 'multiple_choice', 'Thỏ Trắng nói với Bò: "Khi cái chết đã đến sau lưng thì người xa lạ trước mặt cũng tin là bạn, huống hồ gì chúng mình đã quen nhau." Câu chuyện muốn nói điều gì?', 'Thỏ Trắng và Bò là đôi bạn rất thân.', 'Bạn bè tin tưởng, giúp nhau lúc gặp nạn.', 'Thỏ Trắng rất tốt bụng.', null, 'Bạn bè tin tưởng, giúp nhau lúc gặp nạn.', null::jsonb, 'Câu chuyện khuyên bạn bè tin tưởng, giúp đỡ nhau khi gặp nạn.', 'doc_hieu', 34::int),
    (2::smallint, 'text', 'Tìm từ có vần ươc hoặc ươt: "Đồ dùng để chải tóc, có nhiều răng liền nhau" là cái ___', null, null, null, null, 'lược', '["cái lược","chiếc lược"]'::jsonb, 'Cái lược dùng để chải tóc.', 'chinh_ta_uoc_uot', 30::int),
    (3::smallint, 'text', 'Tìm từ có vần ươc hoặc ươt: "Làm theo kiểu của người khác một cách máy móc" là ___', null, null, null, null, 'bắt chước', null::jsonb, 'Bắt chước: làm theo người khác, vần ươc.', 'chinh_ta_uoc_uot', 30::int),
    (3::smallint, 'text', 'Tìm từ có vần ươc hoặc ươt: Đồ chơi có đường máng dốc, nhẵn để trẻ em trượt từ trên xuống là cầu ___', null, null, null, null, 'trượt', '["cầu trượt"]'::jsonb, 'Cầu trượt có vần ươt.', 'chinh_ta_uoc_uot', 30::int),
    (2::smallint, 'text', 'Điền ươc hay ươt (thêm dấu thanh nếu cần): Dù khó khăn không lùi b___', null, null, null, null, 'ước', '["bước"]'::jsonb, 'Lùi bước có vần ươc.', 'chinh_ta_uoc_uot', 30::int),
    (3::smallint, 'text', 'Điền ươc hay ươt (thêm dấu thanh nếu cần): Trống đánh xuôi, kèn thổi ng___', null, null, null, null, 'ược', '["ngược"]'::jsonb, 'Ngược có vần ươc.', 'chinh_ta_uoc_uot', 30::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Con chim bói cá đang rình mồi ( ) đậu im phăng phắc trên cái cọc tre."', 'dấu chấm', 'dấu chấm than', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Câu chưa kết thúc, hai bộ phận cùng tả chim bói cá nên dùng dấu phẩy.', 'dau_cau', 35::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "…mỏ to, đầu nhỏ, đuôi ngắn cũn ( ) Nó có bộ lông xanh biếc."', 'dấu chấm', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu chấm', null::jsonb, 'Hết câu, chữ "Nó" viết hoa nên dùng dấu chấm.', 'dau_cau', 35::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 23 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 24: Muông thú – Từ ngữ về loài thú, dấu chấm và dấu phẩy (36 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 24, 100, 'Archimes: Muông thú – Từ ngữ về loài thú, dấu chấm và dấu phẩy', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 24', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền s hay x: cây ___oan', null, null, null, null, 'x', null::jsonb, 'Cây xoan viết với x.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hay x: dòng ___uối', null, null, null, null, 's', null::jsonb, 'Dòng suối viết với s.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hay x: ___oắn lại', null, null, null, null, 'x', null::jsonb, 'Xoắn lại viết với x.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): hao h___', null, null, null, null, 'ụt', '["hụt"]'::jsonb, 'Hao hụt có vần ut.', 'chinh_ta_uc_ut', 36::int),
    (1::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): s___ bóng', null, null, null, null, 'út', '["sút"]'::jsonb, 'Sút bóng có vần ut.', 'chinh_ta_uc_ut', 36::int),
    (1::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): x___ động', null, null, null, null, 'úc', '["xúc"]'::jsonb, 'Xúc động có vần uc.', 'chinh_ta_uc_ut', 36::int),
    (1::smallint, 'text', 'Tìm từ có vần uc hoặc ut: "Hoa màu vàng, có những cánh nhỏ, nở nhiều vào mùa thu" là hoa ___', null, null, null, null, 'cúc', '["hoa cúc"]'::jsonb, 'Hoa cúc nở vào mùa thu.', 'chinh_ta_uc_ut', 36::int),
    (1::smallint, 'text', 'Tìm từ có vần uc hoặc ut: "Đồ dùng học tập để viết hoặc vẽ lên giấy" là cái ___', null, null, null, null, 'bút', '["cái bút","chiếc bút"]'::jsonb, 'Cái bút dùng để viết, vẽ.', 'chinh_ta_uc_ut', 36::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm của con thỏ?', 'nhút nhát', 'dữ tợn', 'tinh ranh', 'hay bắt chước', 'nhút nhát', null::jsonb, 'Thỏ nhút nhát.', 'tu_ngu_muong_thu', 37::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm của con cáo?', 'hiền lành', 'tinh ranh', 'nhút nhát', 'nhanh nhẹn', 'tinh ranh', null::jsonb, 'Cáo tinh ranh.', 'tu_ngu_muong_thu', 37::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Trong khu rừng nọ có một chú Thỏ con thông minh sống cùng mẹ. Ngày ngày, Thỏ con thường tung tăng chạy ra bờ sông uống nước."
Thỏ con thường ra bờ sông làm gì?', 'chơi đùa', 'hái hoa và nấm', 'uống nước', null, 'uống nước', null::jsonb, 'Thỏ con ra bờ sông uống nước.', 'doc_hieu', 39::int),
    (1::smallint, 'multiple_choice', 'Chọn từ chỉ đặc điểm điền vào chỗ trống: "Con rùa đi ___."', 'chậm chạp', 'nhanh nhẹn', 'thoăn thoắt', null, 'chậm chạp', null::jsonb, 'Rùa đi rất chậm: chậm chạp.', 'tu_chi_dac_diem', 38::int),
    (2::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm của sư tử?', 'hiền lành', 'nhút nhát', 'hay bắt chước', 'dữ tợn', 'dữ tợn', null::jsonb, 'Sư tử là thú dữ: dữ tợn.', 'tu_ngu_muong_thu', 37::int),
    (2::smallint, 'multiple_choice', 'Tên con vật nào không cùng loại trong nhóm: hổ, báo, nai, gà, sóc?', 'hổ', 'gà', 'nai', 'sóc', 'gà', null::jsonb, 'Gà là loài gia cầm (có cánh), các con còn lại là thú rừng.', 'tu_ngu_muong_thu', 40::int),
    (2::smallint, 'multiple_choice', 'Tên con vật nào không cùng loại trong nhóm: hươu, nai, sư tử, thỏ, chồn?', 'hươu', 'thỏ', 'sư tử', 'chồn', 'sư tử', null::jsonb, 'Sư tử là thú dữ, các con còn lại hiền lành.', 'tu_ngu_muong_thu', 40::int),
    (3::smallint, 'multiple_choice', 'Tên con vật nào không cùng loại trong nhóm: nai, chó sói, báo, sư tử?', 'chó sói', 'báo', 'sư tử', 'nai', 'nai', null::jsonb, 'Nai hiền lành, ăn cỏ; chó sói, báo, sư tử là thú dữ ăn thịt.', 'tu_ngu_muong_thu', 40::int),
    (3::smallint, 'multiple_choice', 'Tên con vật nào không cùng loại trong nhóm: khỉ, vượn, gấu, đười ươi?', 'gấu', 'khỉ', 'vượn', 'đười ươi', 'gấu', null::jsonb, 'Khỉ, vượn, đười ươi cùng họ nhà khỉ; gấu thì không.', 'tu_ngu_muong_thu', 40::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "___ lững thững kéo gỗ về bản."', 'Sóc', 'Voi', 'Hổ', 'Thỏ', 'Voi', null::jsonb, 'Voi to khỏe, kéo gỗ giúp người.', 'tu_ngu_muong_thu', 40::int),
    (2::smallint, 'multiple_choice', 'Điền tên con vật: "___ tung bờm phi nước đại."', 'Voi', 'Gấu', 'Ngựa', 'Khỉ', 'Ngựa', null::jsonb, 'Ngựa có bờm, phi nước đại.', 'tu_ngu_muong_thu', 40::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Mùa, xuân phượng ra lá.', 'Mùa xuân phượng, ra lá.', 'Mùa xuân, phượng ra lá.', null, 'Mùa xuân, phượng ra lá.', null::jsonb, 'Dấu phẩy đặt sau bộ phận chỉ thời gian "Mùa xuân".', 'dau_phay', 38::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Mẹ mua cho tôi sách giáo khoa, vở ô li, hộp bút.', 'Mẹ mua cho tôi, sách giáo khoa vở ô li hộp bút.', 'Mẹ mua cho tôi sách, giáo khoa vở ô li, hộp bút.', null, 'Mẹ mua cho tôi sách giáo khoa, vở ô li, hộp bút.', null::jsonb, 'Dấu phẩy ngăn cách các đồ vật được kể ra: sách giáo khoa, vở ô li, hộp bút.', 'dau_phay', 38::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Một ngày, đầu năm bốn nàng tiên gặp nhau.', 'Một ngày đầu năm, bốn nàng tiên gặp nhau.', 'Một ngày đầu năm bốn nàng tiên, gặp nhau.', null, 'Một ngày đầu năm, bốn nàng tiên gặp nhau.', null::jsonb, 'Dấu phẩy đặt sau bộ phận chỉ thời gian "Một ngày đầu năm".', 'dau_phay', 38::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Từ trong quả bầu ( ) những con người bé nhỏ nhảy ra."', 'dấu chấm', 'dấu chấm than', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách bộ phận chỉ nơi chốn ở đầu câu.', 'dau_cau', 38::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Người Khơ-mú nhanh nhảu ra trước ( ) Tiếp đến, người Thái, người Tày…"', 'dấu chấm', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu chấm', null::jsonb, 'Hết câu, chữ "Tiếp" viết hoa nên dùng dấu chấm.', 'dau_cau', 38::int),
    (2::smallint, 'multiple_choice', 'An muốn đi xem phim vào Chủ nhật nhưng mẹ bận. An nên đáp thế nào cho lịch sự?', 'Không chịu đâu! Con thích đi cơ.', 'Vâng mẹ, hôm khác mẹ cho con đi cũng được ạ.', 'Cả tuần có mỗi Chủ nhật mà mẹ cũng bận.', null, 'Vâng mẹ, hôm khác mẹ cho con đi cũng được ạ.', null::jsonb, 'Đáp lời phủ định cần thông cảm, lễ phép.', 'dap_loi_phu_dinh', 38::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Trước khi đi, bao giờ Thỏ mẹ cũng nhắc:
– Con phải cẩn thận nhé vì Cáo và Chó Sói cũng hay ra sông dạo chơi lắm đấy!"
Thỏ mẹ thường nhắc Thỏ con điều gì?', 'Mặc áo ấm vì bên ngoài rất lạnh.', 'Cẩn thận kẻo ngã xuống sông.', 'Cẩn thận vì Cáo, Chó Sói hay ra bờ sông.', null, 'Cẩn thận vì Cáo, Chó Sói hay ra bờ sông.', null::jsonb, 'Thỏ mẹ dặn cẩn thận vì Cáo và Chó Sói hay ra sông.', 'doc_hieu', 39::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Chợt nhớ lời mẹ dặn, Thỏ con hồ hởi, tươi cười nói:
– Em thích lắm nhưng anh Cáo ơi, chờ em về nhà lấy nón đội che nắng đã nhé!
Nói rồi Thỏ con nhanh nhẹn chạy ào về nhà."
Khi Cáo rủ đi chơi, Thỏ con đã làm gì?', 'Giả vờ về lấy nón rồi chạy ào về nhà.', 'Trèo lên lưng để Cáo cõng vào rừng.', 'Vui vẻ đi chơi cùng Cáo.', null, 'Giả vờ về lấy nón rồi chạy ào về nhà.', null::jsonb, 'Thỏ con nhanh trí lấy cớ về lấy nón để thoát khỏi Cáo.', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', 'Trong truyện "Thỏ con thông minh", Thỏ mẹ khen Thỏ con điều gì?', 'chạy nhanh khiến Cáo không đuổi kịp', 'thông minh, nhanh trí', 'biết chào hỏi lễ phép', null, 'thông minh, nhanh trí', null::jsonb, 'Thỏ mẹ khen con thông minh và nhanh trí.', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', 'Từ nào là từ chỉ đặc điểm, tính chất?', 'uống nước', 'bờ sông', 'hái nấm', 'gian ác', 'gian ác', null::jsonb, '"Gian ác" chỉ tính chất (con Cáo gian ác).', 'tu_chi_dac_diem', 40::int),
    (2::smallint, 'text', 'Điền s hay x: "Chuồn chuồn diện bộ cánh ___ặc sỡ."', null, null, null, null, 's', null::jsonb, 'Sặc sỡ viết với s.', 'chinh_ta_s_x', 36::int),
    (2::smallint, 'text', 'Điền s hay x: "Ếch ta khoác bộ áo ___anh."', null, null, null, null, 'x', null::jsonb, 'Màu xanh viết với x.', 'chinh_ta_s_x', 36::int),
    (2::smallint, 'text', 'Điền s hay x: "Nhạc vang ___a, náo nhiệt cả khu vườn."', null, null, null, null, 'x', null::jsonb, 'Vang xa viết với x.', 'chinh_ta_s_x', 36::int),
    (3::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): "Sông có khúc, người có l___."', null, null, null, null, 'úc', '["lúc"]'::jsonb, 'Người có lúc: "lúc" có vần uc.', 'chinh_ta_uc_ut', 36::int),
    (3::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): "Hiền như b___."', null, null, null, null, 'ụt', '["bụt"]'::jsonb, 'Hiền như bụt: "bụt" có vần ut.', 'chinh_ta_uc_ut', 36::int),
    (3::smallint, 'text', 'Điền uc hay ut (thêm dấu thanh nếu cần): "Đ___ nước béo cò."', null, null, null, null, 'ục', '["đục"]'::jsonb, 'Đục nước béo cò: "đục" có vần uc.', 'chinh_ta_uc_ut', 36::int),
    (3::smallint, 'multiple_choice', 'Câu nào viết đúng dấu câu?', 'Buổi chiều, nắng vừa tắt, lũ chim đã bay về vườn.', 'Buổi chiều nắng, vừa tắt lũ chim đã bay về vườn.', 'Buổi chiều nắng vừa tắt lũ chim. Đã bay về vườn.', null, 'Buổi chiều, nắng vừa tắt, lũ chim đã bay về vườn.', null::jsonb, 'Dấu phẩy ngăn cách các bộ phận chỉ thời gian ở đầu câu.', 'dau_cau', 40::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 24 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 25: Sông biển – Từ ngữ về sông biển, câu hỏi Vì sao? (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 25, 100, 'Archimes: Sông biển – Từ ngữ về sông biển, câu hỏi Vì sao?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 25', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ch hay tr: "Em nhìn trăng ___ở dậy"', null, null, null, null, 'tr', null::jsonb, 'Trở dậy viết với tr.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'text', 'Điền ch hay tr: "Từ xóm ___ài dào dạt"', null, null, null, null, 'ch', null::jsonb, 'Xóm chài viết với ch.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: ___ cây', 'trèo', 'chèo', 'chéo', null, 'trèo', null::jsonb, 'Trèo cây viết với tr.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: ___ đò', 'trèo', 'chèo', 'chẻo', null, 'chèo', null::jsonb, 'Chèo đò viết với ch.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: ___ mừng', 'trào', 'chạo', 'chào', null, 'chào', null::jsonb, 'Chào mừng viết với ch.', 'chinh_ta_ch_tr', 41::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: ___ quân', 'hải', 'hãi', 'hại', null, 'hải', null::jsonb, 'Hải quân (bộ đội trên biển) có dấu hỏi.', 'dau_hoi_nga', 41::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng: sợ ___', 'hải', 'hãi', 'hai', null, 'hãi', null::jsonb, 'Sợ hãi có dấu ngã.', 'dau_hoi_nga', 41::int),
    (1::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Sóng yên (biên) lặng."', null, null, null, null, 'biển', null::jsonb, 'Biển có dấu hỏi.', 'dau_hoi_nga', 41::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ sông suối?', 'đảo', 'vịnh', 'bãi biển', 'kênh rạch', 'kênh rạch', null::jsonb, 'Kênh rạch thuộc nhóm sông suối.', 'tu_ngu_song_bien', 42::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ biển cả?', 'suối', 'kênh', 'quần đảo', 'dòng thác', 'quần đảo', null::jsonb, 'Quần đảo là các đảo trên biển.', 'tu_ngu_song_bien', 42::int),
    (1::smallint, 'multiple_choice', 'Con vật nào sống dưới nước?', 'voi', 'hươu', 'chích chòe', 'cá chép', 'cá chép', null::jsonb, 'Cá chép sống dưới nước.', 'tu_ngu_song_bien', 42::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Giữa trưa, nắng như đổ lửa, cá chuối mẹ càng bơi lên gần mặt ao càng thấy nước nóng."
(Theo Xuân Quỳnh)
Cá chuối mẹ bơi lên mặt ao vào lúc nào?', 'đêm tối mù mịt', 'buổi chiều mát mẻ', 'giữa trưa, nắng như đổ lửa', null, 'giữa trưa, nắng như đổ lửa', null::jsonb, 'Cá chuối mẹ bơi lên vào giữa trưa nắng như đổ lửa.', 'doc_hieu', 45::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Dòng sông qua trước (cưa)"', null, null, null, null, 'cửa', null::jsonb, 'Cửa có dấu hỏi.', 'dau_hoi_nga', 41::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "(Gô) nứa từ trên ngàn"', null, null, null, null, 'Gỗ', null::jsonb, 'Gỗ có dấu ngã.', 'dau_hoi_nga', 41::int),
    (2::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Tình sâu (nghia) nặng."', null, null, null, null, 'nghĩa', null::jsonb, 'Nghĩa có dấu ngã.', 'dau_hoi_nga', 41::int),
    (3::smallint, 'text', 'Thêm dấu hỏi hoặc dấu ngã cho chữ trong ngoặc rồi viết lại chữ đó: "Mượn gió (be) măng."', null, null, null, null, 'bẻ', null::jsonb, 'Bẻ măng có dấu hỏi.', 'dau_hoi_nga', 41::int),
    (2::smallint, 'multiple_choice', 'Chọn tiếng đúng: "Nước ___ dâng lên bờ."', 'trào', 'chào', 'tràu', null, 'trào', null::jsonb, 'Trào dâng viết với tr.', 'chinh_ta_ch_tr', 41::int),
    (2::smallint, 'multiple_choice', '"Vì tò mò, Giọt Nước theo Thuyền đi vào đất liền." Bộ phận "Vì tò mò" trả lời cho câu hỏi nào?', 'Khi nào?', 'Ở đâu?', 'Như thế nào?', 'Vì sao?', 'Vì sao?', null::jsonb, '"Vì tò mò" nêu nguyên nhân.', 'cau_hoi_vi_sao', 43::int),
    (2::smallint, 'multiple_choice', '"Giọt Nước rất vui sướng vì thấy mẹ." Câu hỏi đúng cho bộ phận "vì thấy mẹ" là:', 'Giọt Nước vui sướng khi nào?', 'Vì sao Giọt Nước rất vui sướng?', 'Giọt Nước thế nào?', 'Giọt Nước ở đâu?', 'Vì sao Giọt Nước rất vui sướng?', null::jsonb, 'Bộ phận nêu nguyên nhân nên hỏi "Vì sao?".', 'cau_hoi_vi_sao', 43::int),
    (2::smallint, 'multiple_choice', 'Bộ phận chỉ nguyên nhân trong câu "Lá cây thường có màu xanh vì chứa chất diệp lục." là:', 'vì chứa chất diệp lục', 'Lá cây', 'thường có màu xanh', null, 'vì chứa chất diệp lục', null::jsonb, '"Vì chứa chất diệp lục" nêu lí do lá có màu xanh.', 'cau_hoi_vi_sao', 43::int),
    (3::smallint, 'multiple_choice', 'Bộ phận chỉ nguyên nhân trong câu "Nhờ các bác lao công, sân trường lúc nào cũng sạch đẹp." là:', 'sân trường', 'Nhờ các bác lao công', 'lúc nào cũng sạch đẹp', null, 'Nhờ các bác lao công', null::jsonb, '"Nhờ…" cũng nêu nguyên nhân (nguyên nhân tốt).', 'cau_hoi_vi_sao', 43::int),
    (3::smallint, 'multiple_choice', '"Cá trên sông Nhuệ chết nhiều vì nước sông bị ô nhiễm nặng." Câu hỏi đúng cho bộ phận "vì nước sông bị ô nhiễm nặng" là:', 'Cá chết nhiều ở đâu?', 'Khi nào cá chết nhiều?', 'Vì sao cá trên sông Nhuệ chết nhiều?', 'Cá trên sông Nhuệ thế nào?', 'Vì sao cá trên sông Nhuệ chết nhiều?', null::jsonb, 'Bộ phận nêu nguyên nhân nên hỏi "Vì sao?".', 'cau_hoi_vi_sao', 43::int),
    (2::smallint, 'multiple_choice', 'Vì sao chim hải âu được gọi là bạn của người đi biển?', 'Vì hải âu báo trước bão cho người đi biển.', 'Vì hải âu biết bắt cá rất giỏi.', 'Vì hải âu có bộ lông trắng đẹp.', null, 'Vì hải âu báo trước bão cho người đi biển.', null::jsonb, 'Hải âu báo bão, báo đất liền cho người đi biển.', 'cau_hoi_vi_sao', 43::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Bơi sát mép nước, chuối mẹ rạch lên chân khóm tre. Tìm một chỗ đoán chắc là có tổ kiến gần đó, chuối mẹ giả vờ chết, nằm im không động đậy."
Vì sao cá chuối mẹ rạch lên chân khóm tre?', 'Để tìm măng tre cho con ăn.', 'Để tìm tổ kiến, nhử kiến cho con ăn.', 'Để tìm chỗ mát tránh nắng.', null, 'Để tìm tổ kiến, nhử kiến cho con ăn.', null::jsonb, 'Cá chuối mẹ tìm chỗ có tổ kiến để nhử kiến về cho đàn con.', 'doc_hieu', 45::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Hơi nước, hơi lá ải, cùng với mùi tanh trên mình chuối mẹ bốc ra làm bọn kiến lửa gần đó thèm thuồng."
Điều gì làm bọn kiến lửa thèm thuồng?', 'chỉ có hơi nước, hơi lá ải', 'chỉ có mùi tanh trên mình cá', 'cả hơi nước, hơi lá ải và mùi tanh', null, 'cả hơi nước, hơi lá ải và mùi tanh', null::jsonb, 'Cả hơi nước, hơi lá ải và mùi tanh đều làm kiến thèm.', 'doc_hieu', 45::int),
    (3::smallint, 'multiple_choice', 'Trong bài "Mẹ con cá chuối", cá mẹ chịu kiến đốt đau nhói để kiếm mồi cho đàn con. Đoạn trích nói lên điều gì?', 'Cá chuối mẹ thương con, hi sinh vì con.', 'Cá chuối sống được cả trên cạn.', 'Đàn cá chuối con rất thương mẹ.', null, 'Cá chuối mẹ thương con, hi sinh vì con.', null::jsonb, 'Cá mẹ chịu đau để con được no: tình mẹ thương con.', 'doc_hieu', 46::int),
    (3::smallint, 'multiple_choice', 'Câu "Chúng nối đuôi nhau, vừa bò loằng ngoằng vừa dò dẫm về phía có mùi cá." thuộc kiểu câu nào?', 'Ai là gì?', 'Ai làm gì?', 'Ai thế nào?', null, 'Ai làm gì?', null::jsonb, 'Câu kể hoạt động của bọn kiến (bò, dò dẫm) nên là kiểu Ai làm gì?', 'kieu_cau', 46::int),
    (2::smallint, 'multiple_choice', 'Ghép để tạo câu kiểu "Ai thế nào?": "Ngọn đèn biển ___"', 'trắng bạc đầu.', 'tối sầm, đen kịt.', 'sáng rực một góc trời.', null, 'sáng rực một góc trời.', null::jsonb, 'Ngọn đèn biển sáng rực một góc trời.', 'cau_ai_the_nao', 46::int),
    (2::smallint, 'multiple_choice', 'Ghép để tạo câu kiểu "Ai thế nào?": "Sóng ___"', 'trắng bạc đầu.', 'sáng rực một góc trời.', 'tối sầm, đen kịt.', null, 'trắng bạc đầu.', null::jsonb, 'Sóng trắng bạc đầu.', 'cau_ai_the_nao', 46::int),
    (3::smallint, 'multiple_choice', '"Chú Đỗ Con ngủ khì suốt năm trong cái chum khô ráo, tối om." Bộ phận "trong cái chum khô ráo, tối om" trả lời cho câu hỏi nào?', 'Khi nào?', 'Như thế nào?', 'Vì sao?', 'Ở đâu?', 'Ở đâu?', null::jsonb, 'Bộ phận này chỉ nơi chốn.', 'cau_hoi_o_dau', 46::int),
    (2::smallint, 'multiple_choice', '"Chim công có vẻ sẽ được nhiều phiếu vì có bộ lông lộng lẫy." Bộ phận "vì có bộ lông lộng lẫy" trả lời cho câu hỏi nào?', 'Khi nào?', 'Ở đâu?', 'Như thế nào?', 'Vì sao?', 'Vì sao?', null::jsonb, 'Bộ phận bắt đầu bằng "vì" nêu nguyên nhân.', 'cau_hoi_vi_sao', 46::int),
    (3::smallint, 'multiple_choice', 'Chọn từ ngữ thích hợp: "Xa xa, từng đàn hải âu ___."', 'nhô lên', 'đỏ rực', 'cuồn cuộn xô bờ', 'nghiêng mình chao liệng', 'nghiêng mình chao liệng', null::jsonb, 'Hải âu bay: nghiêng mình chao liệng.', 'tu_ngu_song_bien', 42::int),
    (2::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'bờ biễn', 'bờ biển', 'bờ bển', null, 'bờ biển', null::jsonb, 'Biển có dấu hỏi.', 'dau_hoi_nga', 46::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 25 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 26: Sông biển – Từ ngữ về các loài cá, ôn câu hỏi Vì sao? (38 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 26, 100, 'Archimes: Sông biển – Từ ngữ về các loài cá, ôn câu hỏi Vì sao?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 26', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền r, d hay gi: "Đi hỏi ___à, về nhà hỏi trẻ."', null, null, null, null, 'gi', null::jsonb, 'Người già viết với gi.', 'chinh_ta_d_r_gi', 47::int),
    (1::smallint, 'text', 'Điền r, d hay gi: "Én bay cao, mưa ___ào lại tạnh."', null, null, null, null, 'r', null::jsonb, 'Mưa rào viết với r.', 'chinh_ta_d_r_gi', 47::int),
    (1::smallint, 'text', 'Điền r, d hay gi: "___eo gió gặt bão."', null, null, null, null, 'gi', null::jsonb, 'Gieo viết với gi.', 'chinh_ta_d_r_gi', 47::int),
    (2::smallint, 'text', 'Điền r, d hay gi: "Tránh vỏ ___ưa, gặp vỏ dừa."', null, null, null, null, 'd', null::jsonb, 'Quả dưa viết với d.', 'chinh_ta_d_r_gi', 47::int),
    (2::smallint, 'text', 'Điền r, d hay gi: "___uột để ngoài da."', null, null, null, null, 'r', null::jsonb, 'Ruột viết với r.', 'chinh_ta_d_r_gi', 47::int),
    (1::smallint, 'text', 'Điền ưt hay ưc (thêm dấu thanh nếu cần): cá m___', null, null, null, null, 'ực', '["mực"]'::jsonb, 'Cá mực có vần ưc.', 'chinh_ta_ut_uc', 47::int),
    (1::smallint, 'text', 'Điền ưt hay ưc (thêm dấu thanh nếu cần): n___ nẻ', null, null, null, null, 'ứt', '["nứt"]'::jsonb, 'Nứt nẻ có vần ưt.', 'chinh_ta_ut_uc', 47::int),
    (2::smallint, 'text', 'Điền ưt hay ưc (thêm dấu thanh nếu cần): thơm ph___', null, null, null, null, 'ức', '["phức"]'::jsonb, 'Thơm phức có vần ưc.', 'chinh_ta_ut_uc', 47::int),
    (2::smallint, 'text', 'Điền ưt hay ưc (thêm dấu thanh nếu cần): b___ phá', null, null, null, null, 'ứt', '["bứt"]'::jsonb, 'Bứt phá có vần ưt.', 'chinh_ta_ut_uc', 47::int),
    (1::smallint, 'multiple_choice', 'Chọn từ đúng: "Tết đến, mẹ làm ___ sen."', 'mứt', 'mức', 'mựt', null, 'mứt', null::jsonb, 'Mứt sen (món ăn ngày Tết) có vần ưt.', 'chinh_ta_ut_uc', 47::int),
    (2::smallint, 'multiple_choice', 'Chọn từ đúng: "Ngày khai giảng, học sinh nô ___ đến trường."', 'nứt', 'nức', 'nực', null, 'nức', null::jsonb, 'Nô nức có vần ưc.', 'chinh_ta_ut_uc', 47::int),
    (2::smallint, 'multiple_choice', 'Chọn từ đúng: "Chiếc bình cổ đã có vết ___."', 'sức', 'xứt', 'sứt', null, 'sứt', null::jsonb, 'Vết sứt (bị mẻ) có vần ưt.', 'chinh_ta_ut_uc', 47::int),
    (1::smallint, 'multiple_choice', 'Loại cá nào là cá nước ngọt?', 'cá thu', 'cá ngừ', 'cá mập', 'cá chép', 'cá chép', null::jsonb, 'Cá chép sống ở ao, hồ, sông (nước ngọt).', 'tu_ngu_song_bien', 47::int),
    (1::smallint, 'multiple_choice', 'Loại cá nào là cá nước mặn?', 'cá thu', 'cá chép', 'cá trê', 'cá mè', 'cá thu', null::jsonb, 'Cá thu sống ở biển (nước mặn).', 'tu_ngu_song_bien', 47::int),
    (3::smallint, 'multiple_choice', 'Dòng nào gồm toàn cá nước mặn?', 'cá thu, cá chép, cá nục, cá mập', 'cá trê, cá mè, cá ngừ, cá chuồn', 'cá thu, cá chuồn, cá nục, cá ngừ', null, 'cá thu, cá chuồn, cá nục, cá ngừ', null::jsonb, 'Cá chép, cá trê, cá mè là cá nước ngọt.', 'tu_ngu_song_bien', 47::int),
    (2::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Vì sao?" trong câu "Vì không lấy được Mị Nương, Thủy Tinh đùng đùng nổi giận." là:', 'Thủy Tinh', 'Vì không lấy được Mị Nương', 'đùng đùng nổi giận', null, 'Vì không lấy được Mị Nương', null::jsonb, 'Bộ phận này nêu nguyên nhân Thủy Tinh nổi giận.', 'cau_hoi_vi_sao', 48::int),
    (2::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Vì sao?" trong câu "Cá ngoi lên đầy mặt ao vì thời tiết thay đổi." là:', 'Cá', 'vì thời tiết thay đổi', 'ngoi lên đầy mặt ao', null, 'vì thời tiết thay đổi', null::jsonb, '"Vì thời tiết thay đổi" nêu nguyên nhân.', 'cau_hoi_vi_sao', 48::int),
    (3::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Vì sao?" trong câu "Nhờ mưa thuận gió hòa, vụ mùa năm nay bội thu." là:', 'vụ mùa năm nay', 'bội thu', 'Nhờ mưa thuận gió hòa', null, 'Nhờ mưa thuận gió hòa', null::jsonb, '"Nhờ…" nêu nguyên nhân khiến vụ mùa bội thu.', 'cau_hoi_vi_sao', 48::int),
    (2::smallint, 'multiple_choice', '"Ruột măng cụt trắng muốt như hoa bưởi." Câu hỏi đúng cho bộ phận "trắng muốt như hoa bưởi" là:', 'Ruột măng cụt ở đâu?', 'Ruột măng cụt là gì?', 'Vì sao ruột măng cụt trắng?', 'Ruột măng cụt thế nào?', 'Ruột măng cụt thế nào?', null::jsonb, 'Bộ phận chỉ đặc điểm nên hỏi "thế nào?".', 'cau_hoi_nhu_the_nao', 48::int),
    (2::smallint, 'multiple_choice', '"Trong vườn, hoa hồng tỏa hương ngào ngạt." Bộ phận "Trong vườn" trả lời cho câu hỏi nào?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', 'Ở đâu?', 'Ở đâu?', null::jsonb, '"Trong vườn" chỉ nơi chốn.', 'cau_hoi_o_dau', 48::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Từ trong khe đá chảy ra, suối khúc khích, nhí nhảnh. Thoạt tiên chỉ là cái lạch nhỏ, mỏng manh, trong veo.
Róc rách! Róc rách!"
(Theo Phong Thu)
Âm thanh của tiếng suối được gợi tả bằng từ nào?', 'róc rách', 'mỏng manh', 'trong veo', null, 'róc rách', null::jsonb, '"Róc rách" là từ gợi tả tiếng nước suối chảy.', 'doc_hieu', 49::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Suối rất hay cười. Vừa đi vừa cười. Vừa chạy vừa cười. Cả lúc nhảy cũng cười."
Theo đoạn văn, suối cười khi nào?', 'khi đi, khi chạy, cả lúc nhảy', 'khi nằm, khi chạy, cả lúc nhảy', 'khi đi, khi đùa, cả lúc nhảy', null, 'khi đi, khi chạy, cả lúc nhảy', null::jsonb, 'Suối vừa đi vừa cười, vừa chạy vừa cười, cả lúc nhảy cũng cười.', 'doc_hieu', 49::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Từ trong khe đá chảy ra, suối khúc khích, nhí nhảnh. Thoạt tiên chỉ là cái lạch nhỏ, mỏng manh, trong veo."
Thoạt tiên, suối chỉ là gì?', 'một vũng nước nhỏ', 'một lạch nước nhỏ trong veo', 'một đoạn của dòng sông', null, 'một lạch nước nhỏ trong veo', null::jsonb, '"Thoạt tiên chỉ là cái lạch nhỏ, mỏng manh, trong veo."', 'doc_hieu', 49::int),
    (2::smallint, 'multiple_choice', 'Chọn cặp từ điền vào thành ngữ: "Rừng ___, biển ___"', 'thác – ghềnh', 'cội – nguồn', 'vàng – bạc', 'buồm – gió', 'vàng – bạc', null::jsonb, 'Rừng vàng, biển bạc: rừng và biển rất giàu có.', 'thanh_ngu', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn cặp từ điền vào thành ngữ: "Lên ___, xuống ___"', 'vàng – bạc', 'sông – biển', 'cội – nguồn', 'thác – ghềnh', 'thác – ghềnh', null::jsonb, 'Lên thác xuống ghềnh: vượt qua nhiều gian nan.', 'thanh_ngu', 50::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp từ điền vào câu: "Trăm ___ đều đổ về một ___"', 'sông – biển', 'thác – ghềnh', 'buồm – gió', 'vàng – bạc', 'sông – biển', null::jsonb, 'Trăm sông đều đổ về một biển.', 'thanh_ngu', 50::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp từ điền vào thành ngữ: "Thuận ___, xuôi ___"', 'sông – biển', 'buồm – gió', 'cội – nguồn', 'thác – ghềnh', 'buồm – gió', null::jsonb, 'Thuận buồm xuôi gió: mọi việc suôn sẻ.', 'thanh_ngu', 50::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp từ điền vào câu: "Cây có ___, nước có ___"', 'vàng – bạc', 'buồm – gió', 'cội – nguồn', 'sông – biển', 'cội – nguồn', null::jsonb, 'Cây có cội, nước có nguồn: nhắc nhớ về tổ tiên, cội nguồn.', 'thanh_ngu', 50::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Buổi sáng từng đoàn, thuyền đánh cá trở về.', 'Buổi sáng, từng đoàn thuyền đánh cá trở về.', 'Buổi sáng từng đoàn thuyền, đánh cá trở về.', null, 'Buổi sáng, từng đoàn thuyền đánh cá trở về.', null::jsonb, 'Dấu phẩy đặt sau bộ phận chỉ thời gian "Buổi sáng".', 'dau_phay', 50::int),
    (3::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Thuyền nào, cũng tôm cá cua ghẹ đầy khoang.', 'Thuyền nào cũng tôm cá, cua ghẹ, đầy khoang.', 'Thuyền nào cũng tôm, cá, cua, ghẹ đầy khoang.', null, 'Thuyền nào cũng tôm, cá, cua, ghẹ đầy khoang.', null::jsonb, 'Dấu phẩy ngăn cách các sự vật được kể: tôm, cá, cua, ghẹ.', 'dau_phay', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp (san hô, sóng, đảo): "Được che chắn bởi 19 ___ lớn nhỏ, vịnh Nha Trang rộng, khá kín gió."', 'đảo', 'sóng', 'san hô', null, 'đảo', null::jsonb, 'Vịnh Nha Trang được che chắn bởi 19 hòn đảo.', 'tu_ngu_song_bien', 50::int),
    (2::smallint, 'multiple_choice', 'Chọn từ thích hợp (san hô, sóng, đảo): "Dưới mặt vịnh Nha Trang có một thế giới kì thú của nhiều loài ___, cá, cỏ biển."', 'sóng', 'san hô', 'đảo', null, 'san hô', null::jsonb, 'San hô sống dưới biển cùng cá, cỏ biển.', 'tu_ngu_song_bien', 50::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Ở giữa biển khơi có tòa lâu đài của vua Thủy Tề đứng sừng sững nơi đáy biển sâu nhất. Tường bằng san hô đủ màu sắc, cửa sổ cao vút bằng hổ phách trong suốt, mái lợp toàn bằng trai ngọc."
Tường lâu đài của vua Thủy Tề làm bằng gì?', 'hổ phách trong suốt', 'trai ngọc', 'san hô đủ màu sắc', null, 'san hô đủ màu sắc', null::jsonb, '"Tường bằng san hô đủ màu sắc."', 'doc_hieu', 51::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Nước ở đây xanh hơn đài hoa xanh biếc nhất, trong vắt như pha lê và sâu thăm thẳm đến nỗi neo đã phải nối thêm dây mà vẫn không chạm đáy."
Nước biển ở thủy cung được tả thế nào?', 'xanh biếc, trong vắt như pha lê, sâu thẳm', 'đục ngầu, nông, đầy cát', 'đỏ ửng tựa than hồng', null, 'xanh biếc, trong vắt như pha lê, sâu thẳm', null::jsonb, 'Nước xanh hơn đài hoa xanh biếc, trong vắt như pha lê, sâu thăm thẳm.', 'doc_hieu', 51::int),
    (1::smallint, 'multiple_choice', 'Câu "Hải âu là bạn của người đi biển." thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai là gì?', 'Ai thế nào?', null, 'Ai là gì?', null::jsonb, 'Câu giới thiệu hải âu là gì nên thuộc kiểu Ai là gì?', 'kieu_cau', 52::int),
    (2::smallint, 'multiple_choice', 'Câu "Cánh hoa mịn như nhung." thuộc kiểu câu nào?', 'Ai là gì?', 'Ai làm gì?', 'Ai thế nào?', null, 'Ai thế nào?', null::jsonb, 'Câu nêu đặc điểm của cánh hoa (mịn như nhung).', 'kieu_cau', 52::int),
    (2::smallint, 'multiple_choice', 'Câu "Đàn chim bay theo con thuyền." thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai là gì?', 'Ai thế nào?', null, 'Ai làm gì?', null::jsonb, 'Câu nêu hoạt động của đàn chim (bay theo).', 'kieu_cau', 52::int),
    (3::smallint, 'multiple_choice', '"Vì bão đến, đoàn thuyền không ra khơi đánh cá." Câu hỏi đúng cho bộ phận "Vì bão đến" là:', 'Khi nào đoàn thuyền ra khơi?', 'Đoàn thuyền đánh cá ở đâu?', 'Đoàn thuyền thế nào?', 'Vì sao đoàn thuyền không ra khơi đánh cá?', 'Vì sao đoàn thuyền không ra khơi đánh cá?', null::jsonb, 'Bộ phận nêu nguyên nhân nên hỏi "Vì sao?".', 'cau_hoi_vi_sao', 52::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 26 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 27: Ôn tập giữa học kì II – Đọc hiểu, đặt câu hỏi, dấu câu (33 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 27, 100, 'Archimes: Ôn tập giữa học kì II – Đọc hiểu, đặt câu hỏi, dấu câu', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 3, tuần 27', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một lần, tôi gặp một chú voi non bị thụt bùn dưới đầm lầy. Tôi nhờ năm người quản tượng khác đến giúp sức, kéo nó lên bờ. Nó còn nhỏ, chưa làm được việc. Tôi cho nó mấy miếng đường rồi xua nó quay trở lại rừng."
(Voi trả nghĩa – Theo Vũ Hùng)
Chú voi non đã gặp phải chuyện gì?', 'bị thụt bùn dưới đầm lầy', 'bị trúng đạn', 'bị bỏ đói', null, 'bị thụt bùn dưới đầm lầy', null::jsonb, 'Voi non bị thụt bùn dưới đầm lầy.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một lần, tôi gặp một chú voi non bị thụt bùn dưới đầm lầy. Tôi nhờ năm người quản tượng khác đến giúp sức, kéo nó lên bờ. Nó còn nhỏ, chưa làm được việc. Tôi cho nó mấy miếng đường rồi xua nó quay trở lại rừng."
(Voi trả nghĩa – Theo Vũ Hùng)
Nhân vật "tôi" đã làm gì để giúp chú voi non?', 'bỏ đi và không làm gì hết', 'nhờ năm người quản tượng kéo voi lên bờ', 'gọi voi mẹ đến cứu voi con', null, 'nhờ năm người quản tượng kéo voi lên bờ', null::jsonb, '"Tôi" nhờ năm người quản tượng giúp sức kéo voi lên.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Một lần, tôi gặp một chú voi non bị thụt bùn dưới đầm lầy. Tôi nhờ năm người quản tượng khác đến giúp sức, kéo nó lên bờ. Nó còn nhỏ, chưa làm được việc. Tôi cho nó mấy miếng đường rồi xua nó quay trở lại rừng."
(Voi trả nghĩa – Theo Vũ Hùng)
Sau khi cứu được voi non, nhân vật "tôi" đã làm gì?', 'bắt voi về kéo gỗ giúp mình', 'bán voi non lấy tiền', 'cho voi mấy miếng đường rồi xua về rừng', null, 'cho voi mấy miếng đường rồi xua về rừng', null::jsonb, '"Tôi cho nó mấy miếng đường rồi xua nó quay trở lại rừng."', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Tôi ra rình, thấy có hai con voi lễ mễ khiêng gỗ đến. Tôi nhận ra chú voi non ngày trước… Mấy đêm sau, hai mẹ con nhà voi ấy đã chuyển hết số gỗ của tôi về bản."
Chú voi non đã làm gì để trả ơn?', 'chuyển hết số gỗ từ trong rừng về bản', 'kiếm củi cho người đó', 'cứu người đó thoát chết', null, 'chuyển hết số gỗ từ trong rừng về bản', null::jsonb, 'Hai mẹ con voi chuyển hết gỗ về bản.', 'doc_hieu', 53::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Đặt gỗ xuống, voi non tung vòi hít hít. Nó kêu lên khe khẽ rồi tiến lên, huơ vòi chạm vào mặt tôi."
Hình ảnh nào cho thấy voi non rất vui khi gặp lại người đã cứu mình?', 'Chỉ có việc voi tung vòi hít hít', 'Cả tung vòi hít hít và huơ vòi chạm mặt', 'Chỉ có việc voi kêu khe khẽ', null, 'Cả tung vòi hít hít và huơ vòi chạm mặt', null::jsonb, 'Cả hai hình ảnh đều thể hiện voi non vui mừng nhận ra người quen.', 'doc_hieu', 53::int),
    (1::smallint, 'multiple_choice', '"Mỗi mùa hè tới, hoa phượng vĩ nở đỏ rực hai bên bờ sông." Bộ phận "Mỗi mùa hè tới" trả lời cho câu hỏi nào?', 'Ở đâu?', 'Vì sao?', 'Như thế nào?', 'Khi nào?', 'Khi nào?', null::jsonb, '"Mỗi mùa hè tới" chỉ thời gian.', 'cau_hoi_khi_nao', 54::int),
    (2::smallint, 'multiple_choice', '"Mỗi mùa hè tới, hoa phượng vĩ nở đỏ rực hai bên bờ sông." Bộ phận "hai bên bờ sông" trả lời cho câu hỏi nào?', 'Khi nào?', 'Vì sao?', 'Ở đâu?', 'Như thế nào?', 'Ở đâu?', null::jsonb, '"Hai bên bờ sông" chỉ nơi chốn.', 'cau_hoi_o_dau', 54::int),
    (1::smallint, 'multiple_choice', '"Đàn ong xây tổ nhanh vì chúng biết tuân thủ kỉ luật." Bộ phận "vì chúng biết tuân thủ kỉ luật" trả lời cho câu hỏi nào?', 'Khi nào?', 'Ở đâu?', 'Như thế nào?', 'Vì sao?', 'Vì sao?', null::jsonb, 'Bộ phận bắt đầu bằng "vì" nêu nguyên nhân.', 'cau_hoi_vi_sao', 54::int),
    (2::smallint, 'multiple_choice', '"Từ tít trên cao, mùi hoa sữa tỏa xuống ngào ngạt." Bộ phận "Từ tít trên cao" trả lời cho câu hỏi nào?', 'Ở đâu?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', 'Ở đâu?', null::jsonb, '"Từ tít trên cao" chỉ nơi chốn.', 'cau_hoi_o_dau', 54::int),
    (3::smallint, 'multiple_choice', '"Các bạn nhỏ đều ngoan ngoãn, vâng lời ông bà cha mẹ." Câu hỏi đúng cho bộ phận "ngoan ngoãn, vâng lời ông bà cha mẹ" là:', 'Các bạn nhỏ là ai?', 'Các bạn nhỏ thế nào?', 'Các bạn nhỏ làm gì?', 'Vì sao các bạn nhỏ ngoan?', 'Các bạn nhỏ thế nào?', null::jsonb, 'Bộ phận chỉ đặc điểm, tính nết nên hỏi "thế nào?".', 'cau_hoi_nhu_the_nao', 54::int),
    (3::smallint, 'multiple_choice', 'Cần đặt dấu chấm ở đâu để tách câu cho đúng: "Bây giờ, không còn ai buồn và lẻ loi một mình nữa chim hót líu lo trên cỏ mới"?', 'sau chữ "buồn"', 'sau chữ "chim"', 'sau chữ "nữa"', 'sau chữ "hót"', 'sau chữ "nữa"', null::jsonb, 'Câu 1 kết thúc ở "…một mình nữa.", câu sau bắt đầu "Chim hót líu lo…".', 'dau_cau', 54::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Người khách du lịch tiến lại gần và hỏi bà lão:
– Bà ơi, bà có muốn con cõng bà vượt suối không?
Bà lão lẳng lặng gật đầu đồng ý."
(Vị khách tốt bụng)
Người khách du lịch đã giúp bà cụ làm gì?', 'giúp bà cụ băng qua đường', 'giúp bà cụ đi tới vùng núi', 'cõng bà cụ vượt qua dòng suối', null, 'cõng bà cụ vượt qua dòng suối', null::jsonb, 'Anh cõng bà cụ vượt suối.', 'doc_hieu', 55::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Sau khi sang bờ bên kia, bà lão vội vội vàng vàng rời đi mà không nói lời cảm ơn nào."
Ngay sau khi được giúp, bà cụ đã cư xử thế nào?', 'vội vàng rời đi, không nói lời cảm ơn', 'nói lời cảm ơn vị khách', 'đưa cho vị khách ít thức ăn', null, 'vội vàng rời đi, không nói lời cảm ơn', null::jsonb, 'Bà vội vàng rời đi mà không cảm ơn.', 'doc_hieu', 55::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Vài giờ sau, du khách này đi tới vùng núi. Đó là một hành trình đầy gian nan với anh, chân của anh bị côn trùng cắn sưng tấy."
Vị du khách gặp chuyện gì khi đi tới vùng núi?', 'Anh kiệt sức vì phải băng qua suối.', 'Chân anh bị côn trùng cắn sưng tấy.', 'Anh bị đói vì thiếu thức ăn.', null, 'Chân anh bị côn trùng cắn sưng tấy.', null::jsonb, 'Chân anh bị côn trùng cắn sưng tấy.', 'doc_hieu', 56::int),
    (3::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Người thanh niên nói tiếp: "Bà của tôi không nói được cho nên bà muốn tôi thay mặt bà cảm ơn anh!""
Vì sao lúc trước bà cụ không nói lời cảm ơn?', 'Vì bà không thích người khách.', 'Vì bà quên mất.', 'Vì bà không nói được.', null, 'Vì bà không nói được.', null::jsonb, 'Người cháu cho biết bà không nói được.', 'doc_hieu', 55::int),
    (3::smallint, 'multiple_choice', 'Trong câu "Một du khách nhìn thấy một bà cụ đang đứng bên bờ suối sau một trận mưa lớn.", bộ phận "sau một trận mưa lớn" trả lời cho câu hỏi nào?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', null, 'Khi nào?', null::jsonb, '"Sau một trận mưa lớn" chỉ thời gian.', 'cau_hoi_khi_nao', 56::int),
    (3::smallint, 'multiple_choice', '"Sông mùa xuân êm đềm, xanh trong trôi đi trong nắng vàng." Bộ phận "êm đềm, xanh trong" trả lời cho câu hỏi nào?', 'Khi nào?', 'Ở đâu?', 'Vì sao?', 'Như thế nào?', 'Như thế nào?', null::jsonb, 'Bộ phận này tả đặc điểm của dòng sông.', 'cau_hoi_nhu_the_nao', 56::int),
    (2::smallint, 'multiple_choice', '"Trên những bụi cây ven hồ, đủ các loại họ nhà chim ríu rít bay." Câu hỏi đúng cho bộ phận "Trên những bụi cây ven hồ" là:', 'Khi nào các loại chim ríu rít bay?', 'Các loại chim bay thế nào?', 'Vì sao chim ríu rít bay?', 'Các loại chim ríu rít bay ở đâu?', 'Các loại chim ríu rít bay ở đâu?', null::jsonb, 'Bộ phận chỉ nơi chốn nên hỏi "ở đâu?".', 'cau_hoi_o_dau', 56::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ đặc điểm trong câu "Vầng trăng vàng thắm đang từ từ nhô lên sau lũy tre làng."?', 'vầng trăng', 'nhô lên', 'lũy tre', 'vàng thắm', 'vàng thắm', null::jsonb, '"Vàng thắm" chỉ màu sắc (đặc điểm) của vầng trăng.', 'tu_chi_dac_diem', 56::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ hoạt động trong câu "Trăng ôm ấp mái tóc bạc của các cụ già."?', 'mái tóc', 'ôm ấp', 'bạc', 'cụ già', 'ôm ấp', null::jsonb, '"Ôm ấp" là từ chỉ hoạt động.', 'tu_chi_hoat_dong', 56::int),
    (2::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): "Tối đấy ( ) Hằng đặt chiếc vòng vào tay mẹ."', 'dấu chấm', 'dấu chấm than', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy đặt sau bộ phận chỉ thời gian "Tối đấy".', 'dau_cau', 56::int),
    (3::smallint, 'multiple_choice', 'Chọn dấu câu điền vào ( ): Hằng mếu máo: "– Mẹ tha lỗi cho con nhé ( )"', 'dấu chấm than', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu chấm than', null::jsonb, 'Lời xin lỗi, đề nghị với cảm xúc mạnh dùng dấu chấm than.', 'dau_cau', 56::int),
    (1::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Thân chú nhỏ và thon vàng như màu vàng của nắng mùa thu. Chú đậu trên một cành lộc vừng ngả dài trên mặt hồ."
(Con chuồn chuồn nước)
Chú chuồn chuồn nước đang đậu ở đâu?', 'trên lá sen', 'trên một cành lộc vừng', 'trên mặt ao', null, 'trên một cành lộc vừng', null::jsonb, 'Chú đậu trên một cành lộc vừng.', 'doc_hieu', 57::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Bốn cái cánh mỏng như giấy bóng. Cái đầu tròn và hai con mắt long lanh như thủy tinh. Thân chú nhỏ và thon vàng như màu vàng của nắng mùa thu."
Thân chú chuồn chuồn được miêu tả thế nào?', 'mỏng như giấy bóng', 'long lanh như thủy tinh', 'nhỏ và thon vàng như nắng mùa thu', null, 'nhỏ và thon vàng như nắng mùa thu', null::jsonb, 'Mỏng như giấy bóng là cánh, long lanh là mắt.', 'doc_hieu', 57::int),
    (2::smallint, 'multiple_choice', 'Đọc đoạn văn:
"Cái bóng chú nhỏ xíu lướt nhanh trên mặt hồ. Mặt hồ trải rộng mênh mông và lặng sóng."
Mặt hồ có đặc điểm gì?', 'trải rộng mênh mông và lặng sóng', 'rung rung và phân vân', 'rộng mênh mông, gợn sóng lăn tăn', null, 'trải rộng mênh mông và lặng sóng', null::jsonb, '"Mặt hồ trải rộng mênh mông và lặng sóng."', 'doc_hieu', 57::int),
    (3::smallint, 'multiple_choice', 'Câu "Rồi đột nhiên, chú chuồn chuồn nước tung cánh bay vọt lên." thuộc kiểu câu nào?', 'Ai là gì?', 'Ai làm gì?', 'Ai thế nào?', null, 'Ai làm gì?', null::jsonb, 'Câu kể hoạt động (tung cánh bay vọt lên) của chuồn chuồn.', 'kieu_cau', 57::int),
    (1::smallint, 'text', 'Điền x hay s: ___a xôi', null, null, null, null, 'x', null::jsonb, 'Xa xôi viết với x.', 'chinh_ta_s_x', 58::int),
    (1::smallint, 'text', 'Điền x hay s: ___inh sôi', null, null, null, null, 's', null::jsonb, 'Sinh sôi viết với s.', 'chinh_ta_s_x', 58::int),
    (1::smallint, 'text', 'Điền x hay s: ___ắc sảo', null, null, null, null, 's', null::jsonb, 'Sắc sảo viết với s (cả hai tiếng).', 'chinh_ta_s_x', 58::int),
    (2::smallint, 'text', 'Điền iêc hay iêt (thêm dấu thanh nếu cần): t___ nuối', null, null, null, null, 'iếc', '["tiếc"]'::jsonb, 'Tiếc nuối có vần iêc.', 'chinh_ta_iet_iec', 58::int),
    (1::smallint, 'text', 'Điền iêc hay iêt (thêm dấu thanh nếu cần): hiểu b___', null, null, null, null, 'iết', '["biết"]'::jsonb, 'Hiểu biết có vần iêt.', 'chinh_ta_iet_iec', 58::int),
    (2::smallint, 'multiple_choice', '"Cặp mỏ của chích bông gắp sâu trên lá nhanh thoăn thoắt." Câu hỏi đúng cho bộ phận "nhanh thoăn thoắt" là:', 'Cặp mỏ chích bông gắp sâu ở đâu?', 'Cặp mỏ chích bông làm gì?', 'Vì sao chích bông gắp sâu?', 'Cặp mỏ chích bông gắp sâu thế nào?', 'Cặp mỏ chích bông gắp sâu thế nào?', null::jsonb, 'Bộ phận chỉ đặc điểm của hoạt động nên hỏi "thế nào?".', 'cau_hoi_nhu_the_nao', 58::int),
    (3::smallint, 'multiple_choice', '"Bông cúc héo lả đi vì thương xót sơn ca." Câu hỏi đúng cho bộ phận "vì thương xót sơn ca" là:', 'Bông cúc héo lả đi khi nào?', 'Bông cúc thế nào?', 'Bông cúc héo ở đâu?', 'Vì sao bông cúc héo lả đi?', 'Vì sao bông cúc héo lả đi?', null::jsonb, 'Bộ phận nêu nguyên nhân nên hỏi "Vì sao?".', 'cau_hoi_vi_sao', 58::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 27 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 28: Cây cối – Từ ngữ về cây cối, câu hỏi Để làm gì?, dấu chấm, dấu phẩy (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 28, 100, 'Archimes: Cây cối – Từ ngữ về cây cối, câu hỏi Để làm gì?, dấu chấm, dấu phẩy', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 28', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ua hoặc uơ (thêm dấu thanh nếu cần):
Các bạn học sinh đang nô đ___ dưới sân trường.', null, null, null, null, 'ùa', '["đùa"]'::jsonb, 'Nô đùa: vui chơi, chạy nhảy cùng nhau.', 'chinh_ta_ua_uo', 3::int),
    (1::smallint, 'text', 'Điền ua hoặc uơ (thêm dấu thanh nếu cần):
Vua nào th___ bé chăn trâu
Trường Yên một ngọn cờ lau tập tành?', null, null, null, null, 'uở', '["thuở"]'::jsonb, '"Thuở bé" nghĩa là hồi còn nhỏ, viết vần uơ.', 'chinh_ta_ua_uo', 3::int),
    (1::smallint, 'text', 'Điền ua hoặc uơ (thêm dấu thanh nếu cần):
Cánh đồng l___ mênh mông, bát ngát.', null, null, null, null, 'úa', '["lúa"]'::jsonb, 'Cánh đồng lúa: l + úa.', 'chinh_ta_ua_uo', 3::int),
    (1::smallint, 'text', 'Điền ên hoặc ênh (thêm dấu thanh nếu cần):
Đường núi gập gh___.', null, null, null, null, 'ềnh', '["ghềnh"]'::jsonb, 'Gập ghềnh: không bằng phẳng, lồi lõm.', 'chinh_ta_en_enh', 3::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng điền vào chỗ trống:
Ăn chắc mặc ___.', 'bền', 'bềnh', 'bến', null, 'bền', null::jsonb, 'Ăn chắc mặc bền: ăn no chắc bụng, mặc quần áo bền.', 'chinh_ta_en_enh', 3::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Một nắng hai ___ương.', null, null, null, null, 's', null::jsonb, 'Sương (giọt sương) viết s.', 'chinh_ta_s_x', 3::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Lên thác ___uống ghềnh.', null, null, null, null, 'x', null::jsonb, 'Lên thác xuống ghềnh: "xuống" viết x.', 'chinh_ta_s_x', 3::int),
    (1::smallint, 'multiple_choice', 'Thành ngữ nào viết đúng chính tả?', 'Sa mặt cách lòng', 'Xa mặt cách lòng', 'Xa mặc cách lòng', null, 'Xa mặt cách lòng', null::jsonb, '"Xa" (không gần) viết x; "mặt" có vần ăt.', 'chinh_ta_s_x', 3::int),
    (1::smallint, 'text', 'Điền in hoặc inh (thêm dấu thanh nếu cần):
An sử dụng thành thạo máy vi t___.', null, null, null, null, 'ính', '["tính"]'::jsonb, 'Máy vi tính: vần inh, dấu sắc.', 'chinh_ta_in_inh', 3::int),
    (1::smallint, 'text', 'Điền in hoặc inh (thêm dấu thanh nếu cần):
Lễ duyệt b___ thường được tổ chức vào ngày Quốc khánh.', null, null, null, null, 'inh', '["binh"]'::jsonb, 'Duyệt binh: vần inh.', 'chinh_ta_in_inh', 3::int),
    (1::smallint, 'multiple_choice', 'Lúa, ngô, khoai, sắn cho ta thức ăn có nhiều chất bột. Đó là nhóm cây gì?', 'cây bóng mát', 'cây công nghiệp', 'cây lương thực', 'cây lấy gỗ', 'cây lương thực', null::jsonb, 'Cây cho nhiều chất bột để ăn là cây lương thực.', 'tu_ngu_cay_coi', 4::int),
    (1::smallint, 'multiple_choice', 'Xoan, lim, lát, gụ được trồng để làm nhà, đóng bàn ghế. Đó là nhóm cây gì?', 'cây lương thực', 'cây ăn quả', 'cây hoa', 'cây lấy gỗ', 'cây lấy gỗ', null::jsonb, 'Cây trồng để lấy gỗ làm nhà, đóng đồ là cây lấy gỗ.', 'tu_ngu_cay_coi', 4::int),
    (1::smallint, 'multiple_choice', 'Cây nào dưới đây là cây ăn quả?', 'nho', 'xà cừ', 'lim', 'phong lan', 'nho', null::jsonb, 'Nho cho quả để ăn; xà cừ, lim, phong lan thì không.', 'tu_ngu_cay_coi', 4::int),
    (1::smallint, 'text', 'Điền l hoặc n:
tia ___ắng', null, null, null, null, 'n', null::jsonb, 'Tia nắng viết n.', 'chinh_ta_l_n', 9::int),
    (1::smallint, 'multiple_choice', 'Từ nào viết đúng chính tả?', 'lồng nàn', 'nồng nàn', 'nồng làn', 'lồng làn', 'nồng nàn', null::jsonb, 'Nồng nàn: cả hai tiếng đều viết n.', 'chinh_ta_l_n', 9::int),
    (2::smallint, 'multiple_choice', 'Bông, đay, chè, cói, cao su, cà phê là nhóm cây gì?', 'cây lương thực', 'cây bóng mát', 'cây công nghiệp', 'cây lấy gỗ', 'cây công nghiệp', null::jsonb, 'Các cây này cung cấp nguyên liệu cho công nghiệp.', 'tu_ngu_cay_coi', 4::int),
    (2::smallint, 'multiple_choice', 'Dãy nào gồm toàn cây bóng mát?', 'vải, cam, nho', 'sen, huệ, phong lan', 'ngô, khoai, sắn', 'đa, xà cừ, phượng vĩ', 'đa, xà cừ, phượng vĩ', null::jsonb, 'Đa, xà cừ, phượng vĩ có tán rộng, che mát.', 'tu_ngu_cay_coi', 4::int),
    (2::smallint, 'multiple_choice', '"Dưới tán lá xanh um, những cành bàng xoè ra bốn phía như những gọng ô lớn vậy. Thân bàng to gần một vòng tay em nhưng xù xì, lồi lõm."
Đoạn văn nhắc đến những bộ phận nào của cây bàng?', 'tán lá, cành, thân', 'lá, hoa, quả', 'rễ, thân, quả', 'cành, hoa, rễ', 'tán lá, cành, thân', null::jsonb, 'Đoạn văn có các từ: tán lá, cành bàng, thân bàng.', 'bo_phan_cua_cay', 5::int),
    (2::smallint, 'multiple_choice', '"Căng tròn, bóng mịn như chứa nắng ở bên trong, bên ngoài phủ lớp áo xanh ngọc bích" là tả bộ phận nào của cây vú sữa?', 'lá', 'quả', 'hoa', 'thân', 'quả', null::jsonb, 'Căng tròn, bóng mịn, có lớp vỏ xanh là quả vú sữa.', 'bo_phan_cua_cay', 5::int),
    (2::smallint, 'multiple_choice', '"Có một mặt thì xanh mơn mởn, một mặt lại có màu nâu đỏ" là tả bộ phận nào của cây vú sữa?', 'quả', 'thân', 'lá', 'hoa', 'lá', null::jsonb, 'Lá vú sữa có hai mặt: mặt trên xanh, mặt dưới nâu đỏ.', 'bo_phan_cua_cay', 5::int),
    (2::smallint, 'multiple_choice', 'Bộ phận nào trả lời câu hỏi "Để làm gì?" trong câu: "Tôi thường giúp mẹ quét nhà để ngôi nhà luôn sạch đẹp."', 'Tôi thường giúp mẹ', 'quét nhà', 'luôn sạch đẹp', 'để ngôi nhà luôn sạch đẹp', 'để ngôi nhà luôn sạch đẹp', null::jsonb, 'Phần bắt đầu bằng "để…" nêu mục đích của việc quét nhà.', 'cau_hoi_de_lam_gi', 5::int),
    (2::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "để tưới cây" trong câu "Sáng nào ông cũng dậy sớm để tưới cây." là:', 'Sáng nào ông cũng dậy sớm để làm gì?', 'Vì sao sáng nào ông cũng dậy sớm?', 'Sáng nào ông cũng dậy sớm như thế nào?', 'Khi nào ông dậy sớm?', 'Sáng nào ông cũng dậy sớm để làm gì?', null::jsonb, '"Để tưới cây" chỉ mục đích nên hỏi bằng "để làm gì?".', 'cau_hoi_de_lam_gi', 6::int),
    (2::smallint, 'multiple_choice', 'Câu nào đặt dấu phẩy đúng?', 'Cô giáo em, xinh đẹp dịu dàng trong tà áo dài.', 'Cô giáo em xinh đẹp, dịu dàng trong tà áo dài.', 'Cô giáo, em xinh đẹp dịu dàng trong tà áo dài.', null, 'Cô giáo em xinh đẹp, dịu dàng trong tà áo dài.', null::jsonb, 'Dấu phẩy ngăn cách hai từ cùng tả cô giáo: xinh đẹp, dịu dàng.', 'dau_phay', 6::int),
    (2::smallint, 'multiple_choice', '"Đằng sau nhà Lan có một vườn cải. Để đề phòng sự tàn phá của bọn gà vịt, Lan đã rào bốn phía, chỉ làm một cái cửa nhỏ. Bốn luống cải chạy đều một hàng."
Khoảng đất nhỏ sau nhà Lan được dùng để làm gì?', 'nuôi gà', 'trồng hoa lan', 'trồng rau cải', null, 'trồng rau cải', null::jsonb, 'Đó là vườn cải có bốn luống cải.', 'doc_hieu', 8::int),
    (2::smallint, 'multiple_choice', '"Vườn cải chỉ đẹp nhất khi đã nở hoa vàng. Lúc ấy có không biết bao nhiêu là bướm rủ nhau đến chơi ở vườn cải."
Vườn cải đẹp nhất khi nào?', 'khi cải đã nở hoa vàng', 'khi cải vừa bén rễ', 'khi những tàu lá cải vồng cao', null, 'khi cải đã nở hoa vàng', null::jsonb, 'Bài viết: "Vườn cải chỉ đẹp nhất khi đã nở hoa vàng."', 'doc_hieu', 8::int),
    (2::smallint, 'multiple_choice', 'Câu nào dưới đây có bộ phận trả lời câu hỏi "Để làm gì?"', 'Ông em trồng cây cúc vạn thọ ở góc vườn.', 'Cây cúc vạn thọ nở hoa vàng rực.', 'Vì trời nắng, cây cúc vạn thọ héo rũ.', 'Ông em trồng cây cúc vạn thọ để lấy hoa ướp trà.', 'Ông em trồng cây cúc vạn thọ để lấy hoa ướp trà.', null::jsonb, '"Để lấy hoa ướp trà" nêu mục đích trồng cây.', 'cau_hoi_de_lam_gi', 9::int),
    (2::smallint, 'multiple_choice', '"Trâu dừng lại vểnh tai nghe ngóng ( ) Bỗng Nai hớt hải chạy qua báo tin có Hổ đến."
Dấu câu cần điền vào ( ) là:', 'dấu phẩy', 'dấu chấm hỏi', 'dấu chấm', null, 'dấu chấm', null::jsonb, 'Câu kể đã trọn ý, chữ "Bỗng" sau đó viết hoa nên dùng dấu chấm.', 'dau_cham_dau_phay', 9::int),
    (3::smallint, 'multiple_choice', '"Để đề phòng sự tàn phá của bọn gà vịt, Lan đã rào bốn phía, chỉ làm một cái cửa nhỏ."
Bộ phận trả lời câu hỏi "Để làm gì?" là:', 'Để đề phòng sự tàn phá', 'Để đề phòng', 'Lan đã rào bốn phía', 'Để đề phòng sự tàn phá của bọn gà vịt', 'Để đề phòng sự tàn phá của bọn gà vịt', null::jsonb, 'Phải lấy trọn cụm nêu mục đích, đến trước dấu phẩy.', 'cau_hoi_de_lam_gi', 8::int),
    (3::smallint, 'multiple_choice', 'Bài "Vườn cải" tả: luống cải mới bén rễ, tàu lá xanh rờn, thân dài bụ bẫm, chùm hoa vàng li ti. Tác giả đã tả những bộ phận nào của cây cải?', 'rễ, thân, hoa, quả', 'rễ, lá, thân, hoa', 'rễ, lá, hoa, quả', null, 'rễ, lá, thân, hoa', null::jsonb, 'Có rễ (bén rễ), lá (tàu lá), thân, hoa; không nói đến quả.', 'doc_hieu', 8::int),
    (3::smallint, 'multiple_choice', '"Nghĩ là Hổ đuổi thật ( ) Trâu cuống cuồng phóng thẳng ( ) đâm vào gốc cây."
Cần điền dấu gì vào hai chỗ ( )?', 'dấu phẩy, dấu phẩy', 'dấu chấm, dấu phẩy', 'dấu phẩy, dấu chấm', 'dấu chấm, dấu chấm', 'dấu phẩy, dấu phẩy', null::jsonb, 'Cả câu chưa hết ý nên hai chỗ đều dùng dấu phẩy.', 'dau_cham_dau_phay', 9::int),
    (3::smallint, 'multiple_choice', 'Câu "Quả dưa hấu có vỏ màu xanh thẫm ruột đỏ hạt đen nhánh." cần đặt dấu phẩy ở đâu?', 'sau "dưa hấu" và sau "ruột đỏ"', 'sau "xanh thẫm" và sau "ruột đỏ"', 'sau "vỏ màu" và sau "hạt"', 'chỉ sau "xanh thẫm"', 'sau "xanh thẫm" và sau "ruột đỏ"', null::jsonb, 'Dấu phẩy ngăn cách các bộ phận cùng tả quả dưa: vỏ…, ruột…, hạt….', 'dau_phay', 6::int),
    (3::smallint, 'multiple_choice', 'Câu "Sau những cơn mưa xuân nắng lên chói chang hơn vải thiều kết quả." cần đặt dấu phẩy ở đâu?', 'sau "cơn mưa" và sau "nắng lên"', 'chỉ sau "vải thiều"', 'sau "mưa xuân" và sau "chói chang hơn"', 'sau "nắng lên" và sau "vải thiều"', 'sau "mưa xuân" và sau "chói chang hơn"', null::jsonb, 'Sau những cơn mưa xuân, nắng lên chói chang hơn, vải thiều kết quả.', 'dau_phay', 6::int),
    (3::smallint, 'multiple_choice', '"Mấy bông hoa vàng tươi như những đốm nắng đã nở sáng trưng trên giàn mướp xanh mát."
Dãy nào gồm toàn từ chỉ đặc điểm?', 'bông hoa, đốm nắng, giàn mướp', 'vàng tươi, giàn mướp, nở', 'đốm nắng, sáng trưng, xanh mát', 'vàng tươi, sáng trưng, xanh mát', 'vàng tươi, sáng trưng, xanh mát', null::jsonb, 'Vàng tươi, sáng trưng, xanh mát tả màu sắc, vẻ sáng của sự vật.', 'tu_chi_dac_diem', 9::int),
    (3::smallint, 'multiple_choice', '"Rễ bàng lan rộng gần bằng tán bàng. Nhiều cái rễ rộp lên to bằng thân cây luồng, uốn lượn trên mặt đất."
Từ nào dưới đây KHÔNG chỉ bộ phận của cây?', 'uốn lượn', 'rễ', 'tán', 'thân', 'uốn lượn', null::jsonb, '"Uốn lượn" tả hình dáng, không phải bộ phận của cây.', 'bo_phan_cua_cay', 5::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 28 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 29: Cây cối – Bộ phận của cây, câu hỏi Để làm gì? (29 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 29, 100, 'Archimes: Cây cối – Bộ phận của cây, câu hỏi Để làm gì?', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 29', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền s hoặc x:
ngôi ___ao', null, null, null, null, 's', null::jsonb, 'Ngôi sao trên trời viết s.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền s hoặc x:
lao ___ao', null, null, null, null, 'x', null::jsonb, 'Lao xao: cả hai tiếng viết x.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền in hoặc inh (thêm dấu thanh nếu cần):
t___ cách', null, null, null, null, 'ính', '["tính"]'::jsonb, 'Tính cách: vần inh, dấu sắc.', 'chinh_ta_in_inh', 10::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'xinh lỗi, xin đẹp', 'xin lỗi, xinh đẹp', 'xin lỗi, xin đẹp', 'xinh lỗi, xinh đẹp', 'xin lỗi, xinh đẹp', null::jsonb, 'Xin lỗi (vần in), xinh đẹp (vần inh).', 'chinh_ta_in_inh', 10::int),
    (1::smallint, 'text', 'Điền in hoặc inh (thêm dấu thanh nếu cần):
Cây xấu hổ
Vì chẳng tự t___', null, null, null, null, 'in', '["tin"]'::jsonb, 'Tự tin: vần in.', 'chinh_ta_in_inh', 10::int),
    (1::smallint, 'text', 'Điền in hoặc inh (thêm dấu thanh nếu cần):
Cây đứng một m___
Suốt đời lặng thinh.', null, null, null, null, 'ình', '["mình"]'::jsonb, 'Một mình: vần inh, dấu huyền.', 'chinh_ta_in_inh', 10::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Riêng em ưa cây ___ấu', null, null, null, null, 's', null::jsonb, 'Cây sấu viết s.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Trời nắng rát, sấu ___anh', null, null, null, null, 'x', null::jsonb, 'Màu xanh viết x.', 'chinh_ta_s_x', 10::int),
    (1::smallint, 'multiple_choice', 'Trong câu đồng dao "Trồng đậu trồng cà / Hoa hoè hoa khế", cây nào là cây hoa?', 'đậu', 'cà', 'hoè', null, 'hoè', null::jsonb, 'Hoa hoè là cây hoa; đậu, cà là cây rau, cây lương thực.', 'tu_ngu_cay_coi', 11::int),
    (1::smallint, 'multiple_choice', 'Nhóm nào gồm toàn cây ăn quả?', 'đậu, cà, khoai', 'đa, hoè, phượng', 'lim, xoan, gụ', 'cam, quýt, mít, nhãn', 'cam, quýt, mít, nhãn', null::jsonb, 'Cam, quýt, mít, nhãn đều cho quả ăn.', 'tu_ngu_cay_coi', 11::int),
    (1::smallint, 'multiple_choice', '"Cô ___ trắng muốt, thơm ngào ngạt, dáng mảnh mai, kiêu kì."
Chọn từ thích hợp:', 'Huệ', 'Hồng Nhung', 'Râm Bụt', null, 'Huệ', null::jsonb, 'Hoa huệ màu trắng, rất thơm.', 'tu_ngu_cay_coi', 11::int),
    (1::smallint, 'multiple_choice', '"Lá xanh, quả xanh / Lặng im trên cành" (Cây thị). Dòng nào nêu đúng các từ chỉ bộ phận của cây?', 'xanh, lặng im', 'lá, xanh, trên', 'lá, quả, cành', null, 'lá, quả, cành', null::jsonb, 'Lá, quả, cành là bộ phận của cây.', 'bo_phan_cua_cay', 12::int),
    (2::smallint, 'multiple_choice', '"Cô ___ đơm dáng một cách kín đáo, áo của cô đỏ thắm óng ánh những giọt sương."
Chọn từ thích hợp:', 'Hồng Nhung', 'Huệ', 'Râm Bụt', null, 'Hồng Nhung', null::jsonb, 'Hoa hồng nhung có màu đỏ thắm.', 'tu_ngu_cay_coi', 11::int),
    (2::smallint, 'multiple_choice', 'Các từ "khẳng khiu, cong queo, ngoắn ngoèo, uốn lượn" thường dùng để tả bộ phận nào của cây?', 'lá cây', 'hoa', 'rễ cây', 'cành cây', 'cành cây', null::jsonb, 'Cành cây thường khẳng khiu, cong queo, uốn lượn.', 'bo_phan_cua_cay', 12::int),
    (2::smallint, 'multiple_choice', 'Các từ "xanh mướt, xanh um, xanh biếc, xanh non, úa vàng" thường dùng để tả bộ phận nào của cây?', 'thân cây', 'lá cây', 'rễ cây', 'cành cây', 'lá cây', null::jsonb, 'Đây là các từ tả màu của lá.', 'bo_phan_cua_cay', 12::int),
    (2::smallint, 'multiple_choice', 'Các từ "gồ ghề, cắm sâu vào lòng đất, nổi lên quanh gốc" thường dùng để tả bộ phận nào của cây?', 'hoa', 'rễ cây', 'lá cây', 'quả', 'rễ cây', null::jsonb, 'Rễ cây cắm sâu vào đất, có khi nổi lên quanh gốc.', 'bo_phan_cua_cay', 12::int),
    (2::smallint, 'multiple_choice', 'Bộ phận trả lời câu hỏi "Để làm gì?" trong câu "Liên cất chậu cây vào chỗ râm để cây không bị khô héo." là:', 'vào chỗ râm', 'Liên cất chậu cây', 'để cây không bị khô héo', 'không bị khô héo', 'để cây không bị khô héo', null::jsonb, 'Phần "để…" nêu mục đích của việc cất chậu cây.', 'cau_hoi_de_lam_gi', 12::int),
    (2::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "để lấy hạt làm đồ uống" trong câu "Người ta trồng cây cà phê để lấy hạt làm đồ uống." là:', 'Người ta trồng cây cà phê ở đâu?', 'Vì sao người ta trồng cây cà phê?', 'Cây cà phê như thế nào?', 'Người ta trồng cây cà phê để làm gì?', 'Người ta trồng cây cà phê để làm gì?', null::jsonb, 'Bộ phận chỉ mục đích thì hỏi "để làm gì?".', 'cau_hoi_de_lam_gi', 13::int),
    (2::smallint, 'multiple_choice', '"Để tỏ lòng biết ơn, bông cúc nở đẹp rực rỡ, cánh thon nhỏ xíu như những cái kim vàng."
Để tỏ lòng biết ơn đất, mặt trời, gió và chim, bông cúc đã làm gì?', 'nở hoa đẹp rực rỡ', 'hát líu lo', 'bay theo đàn bướm', 'rời bãi đất bồi', 'nở hoa đẹp rực rỡ', null::jsonb, 'Bông cúc nở đẹp rực rỡ để tỏ lòng biết ơn.', 'doc_hieu', 14::int),
    (2::smallint, 'multiple_choice', '"Cây lan, cây huệ nói chuyện bằng hương, bằng hoa. Cây mơ, cây cải nói chuyện bằng lá. Cây bầu, cây bí nói bằng quả."
Cây nào nói chuyện bằng hương, bằng hoa?', 'cây bầu, cây bí', 'cây lan, cây huệ', 'cây mơ, cây cải', null, 'cây lan, cây huệ', null::jsonb, 'Bài viết: cây lan, cây huệ nói chuyện bằng hương, bằng hoa.', 'doc_hieu', 15::int),
    (2::smallint, 'multiple_choice', '"Cũng trên một mảnh vườn, sao lời cây ớt cay, lời cây sung chát, lời cây cam ngọt, lời cây chanh chua…"
Lời cây nào chát?', 'cây ớt', 'cây cam', 'cây sung', 'cây chanh', 'cây sung', null::jsonb, 'Bài viết: "lời cây sung chát".', 'doc_hieu', 15::int),
    (2::smallint, 'multiple_choice', '"Trăm cây trong vườn đều sinh ra từ đất. Đất nuôi dưỡng cây bằng sữa của mình. Chính đất là mẹ của các loài cây."
Cây được nuôi dưỡng bằng gì?', 'sữa của đất', 'hơi mát của gió', 'hơi ấm của nắng', null, 'sữa của đất', null::jsonb, 'Đất nuôi dưỡng cây bằng sữa của mình.', 'doc_hieu', 15::int),
    (3::smallint, 'multiple_choice', 'Theo bài "Cây trong vườn", đất được gọi là gì?', 'cha của các loài cây', 'mẹ của các loài cây', 'bà tiên', null, 'mẹ của các loài cây', null::jsonb, 'Câu cuối bài: "Chính đất là mẹ của các loài cây."', 'doc_hieu', 15::int),
    (3::smallint, 'multiple_choice', '"Ngày nọ, có đàn bướm bay qua, chúng sửng sốt: – Bông cúc đẹp như vậy mà ở nơi hẻo lánh này, thật phí!"
Đàn bướm sửng sốt vì điều gì?', 'bông cúc không có hương thơm', 'bông cúc mọc giữa dòng sông', 'bông cúc đã héo úa', 'bông cúc rất đẹp mà lại mọc ở nơi hẻo lánh', 'bông cúc rất đẹp mà lại mọc ở nơi hẻo lánh', null::jsonb, 'Bướm tiếc vì hoa đẹp mà ở nơi vắng vẻ.', 'doc_hieu', 14::int),
    (3::smallint, 'multiple_choice', '"– Con có vô ích không? – Ồ không! Nhờ con mà nơi đây đẹp lên bội phần."
Vì sao cây cho rằng bông cúc không sống vô ích?', 'vì bông cúc có nhiều bướm đến chơi', 'vì bông cúc cho nhiều mật ngọt', 'vì nhờ bông cúc mà nơi đây đẹp hơn rất nhiều', 'vì bông cúc sống ở nơi hẻo lánh', 'vì nhờ bông cúc mà nơi đây đẹp hơn rất nhiều', null::jsonb, 'Cây nói: "Nhờ con mà nơi đây đẹp lên bội phần."', 'doc_hieu', 14::int),
    (3::smallint, 'multiple_choice', '"Thân dừa bạc phếch tháng năm / Quả dừa – đàn lợn con nằm trên cao. / Đêm hè hoa nở cùng sao / Tàu dừa – chiếc lược chải vào mây xanh."
Dòng nào nêu đủ các từ chỉ bộ phận của cây dừa?', 'thân, quả, sao, mây', 'quả, hoa, lược, mây', 'thân, lợn con, hoa, tàu', 'thân, quả, hoa, tàu (lá)', 'thân, quả, hoa, tàu (lá)', null::jsonb, 'Thân, quả, hoa, tàu dừa là các bộ phận của cây dừa.', 'bo_phan_cua_cay', 15::int),
    (3::smallint, 'multiple_choice', 'Giải câu đố:
"Mỗi cây một quả mới vui
Trên đầu vài sợi tóc thời răng cưa.
Quả đầy những mắt lạ chưa
Gọt ra bỏ mắt ăn vừa ngọt thơm."
Đó là quả gì?', 'quả dứa', 'quả na', 'quả mít', 'quả bưởi', 'quả dứa', null::jsonb, 'Quả dứa có chùm lá như tóc răng cưa, vỏ nhiều mắt.', 'giai_do', 16::int),
    (3::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "để làm ra những giọt mật thơm ngon" trong câu "Ong hút nhụy hoa để làm ra những giọt mật thơm ngon." là:', 'Ong hút gì để làm mật?', 'Ong hút nhụy hoa để làm gì?', 'Vì sao ong hút nhụy hoa?', 'Ong hút nhụy hoa ở đâu?', 'Ong hút nhụy hoa để làm gì?', null::jsonb, 'Bộ phận chỉ mục đích nên hỏi "để làm gì?".', 'cau_hoi_de_lam_gi', 16::int),
    (3::smallint, 'multiple_choice', 'Câu nào dưới đây trả lời đúng câu hỏi "Đối với cây non mới trồng, người ta buộc cây vào que chống để làm gì?"', 'Người ta buộc cây vào que chống vào buổi sáng.', 'Người ta buộc cây vào que chống ở ngoài vườn.', 'Người ta buộc cây vào que chống để cây không bị đổ.', 'Người ta buộc cây vào que chống vì cây đã lớn.', 'Người ta buộc cây vào que chống để cây không bị đổ.', null::jsonb, 'Câu trả lời phải nêu mục đích: để cây không bị đổ.', 'cau_hoi_de_lam_gi', 13::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 29 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 30: Bác Hồ – Từ ngữ về Bác Hồ, chính tả tr/ch, êt/êch (26 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 30, 100, 'Archimes: Bác Hồ – Từ ngữ về Bác Hồ, chính tả tr/ch, êt/êch', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 30', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền tr hoặc ch:
Ngoài xa Bác có thấu lòng ___áu không', null, null, null, null, 'ch', null::jsonb, 'Cháu (con của con) viết ch.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
Nhìn vầng ___án rộng, nhìn đầu bạc phơ.', null, null, null, null, 'tr', null::jsonb, 'Vầng trán viết tr.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
Nhìn mắt sáng, nhìn ___òm râu', null, null, null, null, 'ch', null::jsonb, 'Chòm râu viết ch.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'text', 'Điền êt hoặc êch (thêm dấu thanh nếu cần):
___ ngồi đáy giếng.', null, null, null, null, 'Ếch', null::jsonb, 'Con ếch: vần êch, dấu sắc.', 'chinh_ta_et_ech', 17::int),
    (1::smallint, 'text', 'Điền êt hoặc êch (thêm dấu thanh nếu cần):
Mùa xuân là T___ trồng cây.', null, null, null, null, 'ết', '["Tết"]'::jsonb, 'Tết trồng cây: vần êt, dấu sắc.', 'chinh_ta_et_ech', 17::int),
    (1::smallint, 'text', 'Điền êt hoặc êch (thêm dấu thanh nếu cần):
Chị Thảo là một cô gái n___ na.', null, null, null, null, 'ết', '["nết"]'::jsonb, 'Nết na: vần êt, dấu sắc.', 'chinh_ta_et_ech', 17::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
bàn ___ải đánh răng', null, null, null, null, 'ch', null::jsonb, 'Bàn chải dùng để chải răng, viết ch.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
___ải chiếu ra sân', null, null, null, null, 'tr', null::jsonb, 'Trải chiếu: mở tấm chiếu ra trên mặt sân, viết tr.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'vô tuyến chuyền hình, thi đấu truyền bóng', 'vô tuyến truyền hình, thi đấu truyền bóng', 'vô tuyến chuyền hình, thi đấu chuyền bóng', 'vô tuyến truyền hình, thi đấu chuyền bóng', 'vô tuyến truyền hình, thi đấu chuyền bóng', null::jsonb, 'Truyền hình viết tr; chuyền bóng (đưa bóng qua lại) viết ch.', 'chinh_ta_tr_ch', 17::int),
    (1::smallint, 'multiple_choice', 'Từ nào tả mái tóc của Bác Hồ?', 'bạc phơ', 'hồng hào', 'rộng', 'sáng ngời', 'bạc phơ', null::jsonb, 'Tóc Bác bạc phơ.', 'tu_ngu_ve_bac_ho', 19::int),
    (1::smallint, 'multiple_choice', '"Bác Hồ là một ___ / Thanh tao, liêm khiết, yêu thương mọi người."
Chọn từ thích hợp:', 'cứu nước', 'tấm gương', 'danh lợi', 'dịu dàng', 'tấm gương', null::jsonb, 'Bác Hồ là tấm gương sáng cho mọi người noi theo.', 'tu_ngu_ve_bac_ho', 18::int),
    (2::smallint, 'multiple_choice', '"Bôn ba từng trải bao nơi / Tìm đường ___ xứ người gian truân."
Chọn từ thích hợp:', 'danh lợi', 'tấm gương', 'cứu nước', 'dân', 'cứu nước', null::jsonb, 'Bác ra nước ngoài để tìm đường cứu nước.', 'tu_ngu_ve_bac_ho', 18::int),
    (2::smallint, 'multiple_choice', '"Không màng ___ cá nhân / Nâng niu tất cả vì dân trọn đời."
Chọn từ thích hợp:', 'cứu nước', 'dịu dàng', 'liêm khiết', 'danh lợi', 'danh lợi', null::jsonb, 'Bác không màng tiếng tăm, lợi ích cho riêng mình.', 'tu_ngu_ve_bac_ho', 18::int),
    (2::smallint, 'multiple_choice', 'Trong đoạn thơ "Bác xoa đầu cháu Bác hôn, / Bác thương em cháu xúc cơm vụng về.", từ nào nói lên tình cảm của Bác với các cháu?', 'thương', 'vụng về', 'xúc cơm', 'đầu', 'thương', null::jsonb, '"Thương" nói lên tình yêu của Bác với các cháu.', 'tu_ngu_ve_bac_ho', 18::int),
    (2::smallint, 'multiple_choice', 'Từ ngữ nào thích hợp để tả đôi mắt của Bác Hồ?', 'bạc phơ', 'hiền và sáng', 'cao rộng', 'thưa dài', 'hiền và sáng', null::jsonb, 'Mắt Bác hiền, sáng như sao.', 'tu_ngu_ve_bac_ho', 19::int),
    (2::smallint, 'multiple_choice', '"Bác Hồ đã đề nghị các đồng chí xây cho Bác một hàng ghế xi măng bao quanh để các cháu thiếu nhi đến thăm có chỗ ngồi."
Hàng ghế xi măng được xây để làm gì?', 'để Bác ngồi nghỉ', 'để khách đến thăm có chỗ ngồi nghỉ', 'để các cháu thiếu nhi đến thăm có chỗ ngồi', null, 'để các cháu thiếu nhi đến thăm có chỗ ngồi', null::jsonb, 'Bác muốn các cháu thiếu nhi đến thăm có chỗ ngồi.', 'doc_hieu', 20::int),
    (2::smallint, 'multiple_choice', '"Thấy các cháu có chỗ ngồi nhưng lại không có gì để chơi, Bác lại đề nghị kiếm một bể cá để nuôi cá vàng cho các cháu đến thăm có cá để xem."
Bác đề nghị kiếm bể cá vàng để làm gì?', 'để làm đẹp thêm cho cảnh vật', 'để các cháu thiếu nhi đến thăm có cá để xem', 'để Bác ngắm cá sau giờ làm việc', null, 'để các cháu thiếu nhi đến thăm có cá để xem', null::jsonb, 'Bác muốn các cháu có cá để xem.', 'doc_hieu', 20::int),
    (2::smallint, 'multiple_choice', '"Thấy các cháu xúm xít xem cá trong bể, Bác rất vui."
Khi thấy các cháu xem cá, Bác cảm thấy thế nào?', 'rất buồn', 'rất lo lắng', 'rất vui', null, 'rất vui', null::jsonb, 'Bài viết: "Bác rất vui."', 'doc_hieu', 20::int),
    (2::smallint, 'multiple_choice', '"Bác Hồ sống rất ___. Hồi còn ở chiến khu Việt Bắc, Bác sống và làm việc trong một căn nhà sàn mái tranh vách nứa."
Chọn từ thích hợp:', 'vườn cây', 'ao cá', 'chiến khu', 'giản dị', 'giản dị', null::jsonb, 'Bác sống giản dị, không cầu kì.', 'tu_ngu_ve_bac_ho', 21::int),
    (3::smallint, 'multiple_choice', 'Câu chuyện "Bể cá vàng dành cho các cháu" cho thấy Bác Hồ là người thế nào?', 'rất yêu thương, quan tâm thiếu nhi', 'rất thích nuôi cá vàng', 'thích ngồi ghế xi măng', 'không thích khách đến thăm', 'rất yêu thương, quan tâm thiếu nhi', null::jsonb, 'Bác lo chỗ ngồi, cá để xem cho các cháu vì Bác yêu thiếu nhi.', 'doc_hieu', 20::int),
    (3::smallint, 'multiple_choice', '"Mùa đông trời lạnh, Bác nhờ mấy chú làm một chiếc nắp đậy bể để bảo đảm độ ấm cho cá."
Bộ phận trả lời câu hỏi "Để làm gì?" trong câu trên là:', 'Mùa đông trời lạnh', 'làm một chiếc nắp đậy bể', 'Bác nhờ mấy chú', 'để bảo đảm độ ấm cho cá', 'để bảo đảm độ ấm cho cá', null::jsonb, 'Phần "để…" nêu mục đích làm nắp đậy bể.', 'cau_hoi_de_lam_gi', 20::int),
    (3::smallint, 'multiple_choice', '"Hồ Chí Minh đã thổi vào hồn nhân dân Việt Nam sự khiêm nhường, lòng quả cảm và chủ nghĩa anh hùng."
Dãy nào gồm các từ nói về phẩm chất của Bác?', 'khiêm nhường, quả cảm, anh hùng', 'nhân dân, Việt Nam, hồn', 'thổi, hồn, chủ nghĩa', 'khiêm nhường, nhân dân, thổi', 'khiêm nhường, quả cảm, anh hùng', null::jsonb, 'Khiêm nhường, quả cảm, anh hùng là những đức tính tốt đẹp.', 'tu_ngu_ve_bac_ho', 21::int),
    (3::smallint, 'multiple_choice', '"Những ngày làm bồi tàu ( ) anh Ba đã phải nếm trải khá nhiều công việc nặng nhọc ( ) quá sức ( ) Ngày ngày, anh phải dậy từ rất sớm."
Dấu câu lần lượt điền vào ba chỗ ( ) là:', 'dấu chấm, dấu phẩy, dấu chấm', 'dấu phẩy, dấu phẩy, dấu chấm', 'dấu phẩy, dấu chấm, dấu phẩy', 'dấu phẩy, dấu phẩy, dấu phẩy', 'dấu phẩy, dấu phẩy, dấu chấm', null::jsonb, 'Sau "Ngày ngày" là câu mới (viết hoa) nên chỗ thứ ba là dấu chấm.', 'dau_cham_dau_phay', 21::int),
    (3::smallint, 'multiple_choice', '"Anh phải dậy từ rất sớm để lau chảo ( ) xúc than ( ) nhóm lò ( ) gọt măng."
Cần điền dấu gì vào các chỗ ( )?', 'dấu chấm', 'dấu chấm hỏi', 'dấu phẩy', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách các việc làm được kể liên tiếp.', 'dau_phay', 21::int),
    (3::smallint, 'multiple_choice', 'Câu nào dưới đây viết đúng chính tả?', 'Chếch vinh còn hơn sống nhục.', 'Trết vinh còn hơn sống nhục.', 'Chết vinh còn hơn xống nhục.', 'Chết vinh còn hơn sống nhục.', 'Chết vinh còn hơn sống nhục.', null::jsonb, '"Chết" viết ch, vần êt; "sống" viết s.', 'chinh_ta_et_ech', 17::int),
    (3::smallint, 'multiple_choice', 'Dãy nào gồm các từ viết đúng chính tả?', 'bạc phếch, mũi hếch, nết na', 'bạc phết, mũi hếch, nếch na', 'bạc phếch, mũi hết, nết na', 'bạc phết, mũi hết, nếch na', 'bạc phếch, mũi hếch, nết na', null::jsonb, 'Bạc phếch, mũi hếch (vần êch); nết na (vần êt).', 'chinh_ta_et_ech', 17::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 30 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 31: Bác Hồ – Từ ngữ về Bác Hồ, dấu chấm, dấu phẩy, đáp lời khen ngợi (29 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 31, 100, 'Archimes: Bác Hồ – Từ ngữ về Bác Hồ, dấu chấm, dấu phẩy, đáp lời khen ngợi', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 31', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng (dang/giang/rang): ___ lạc', 'dang', 'giang', 'rang', null, 'rang', null::jsonb, 'Rang lạc: đảo lạc trên chảo nóng cho chín.', 'chinh_ta_r_d_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng (dang/giang/rang): ___ sơn', 'giang', 'dang', 'rang', null, 'giang', null::jsonb, 'Giang sơn: sông núi, đất nước.', 'chinh_ta_r_d_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng (dao/giao/rao): con ___', 'giao', 'dao', 'rao', null, 'dao', null::jsonb, 'Con dao dùng để cắt, thái.', 'chinh_ta_r_d_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Chọn tiếng đúng (dao/giao/rao): tiếng ___', 'dao', 'giao', 'rao', null, 'rao', null::jsonb, 'Tiếng rao của người bán hàng viết r.', 'chinh_ta_r_d_gi', 22::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'thước kẽ, kẻ hở', 'thước kẻ, kẻ hở', 'thước kẽ, kẽ hở', 'thước kẻ, kẽ hở', 'thước kẻ, kẽ hở', null::jsonb, 'Thước kẻ (dấu hỏi), kẽ hở (dấu ngã).', 'chinh_ta_hoi_nga', 22::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'mưa bảo, bão vệ', 'mưa bảo, bảo vệ', 'mưa bão, bão vệ', 'mưa bão, bảo vệ', 'mưa bão, bảo vệ', null::jsonb, 'Mưa bão (dấu ngã), bảo vệ (dấu hỏi).', 'chinh_ta_hoi_nga', 22::int),
    (1::smallint, 'text', 'Viết lại chữ in hoa cho đúng dấu hỏi hoặc dấu ngã:
"Ta đi trên QUANG trường"', null, null, null, null, 'quảng', null::jsonb, 'Quảng trường: dấu hỏi.', 'chinh_ta_hoi_nga', 22::int),
    (1::smallint, 'text', 'Viết lại chữ in hoa cho đúng dấu hỏi hoặc dấu ngã:
"Nắng reo trên LÊ đài"', null, null, null, null, 'lễ', null::jsonb, 'Lễ đài: dấu ngã.', 'chinh_ta_hoi_nga', 22::int),
    (1::smallint, 'multiple_choice', '"Bác Hồ là người sống rất ___. Ở chiến khu hay ở Hà Nội, Người đều sống ở một ngôi nhà sàn lộng gió."
Chọn từ thích hợp:', 'giản dị', 'thơm ngát', 'râm bụt', 'mát mẻ', 'giản dị', null::jsonb, 'Bác Hồ sống rất giản dị.', 'tu_ngu_ve_bac_ho', 23::int),
    (1::smallint, 'multiple_choice', '"Bác rất yêu hoa huệ, loài hoa có mùi hương ___."
Chọn từ thích hợp:', 'giản dị', 'thơm ngát', 'mát mẻ', 'chăm sóc', 'thơm ngát', null::jsonb, 'Hoa huệ có mùi hương thơm ngát.', 'tu_ngu_ve_bac_ho', 23::int),
    (1::smallint, 'multiple_choice', '"Hôm ấy, toà Thị chính Pa-ri (thủ đô nước Pháp) mở tiệc lớn đón mừng Bác."
Câu chuyện "Quả táo của Bác Hồ" diễn ra ở nước nào?', 'Việt Nam', 'Pháp', 'Nhật Bản', null, 'Pháp', null::jsonb, 'Pa-ri là thủ đô nước Pháp.', 'doc_hieu', 26::int),
    (2::smallint, 'multiple_choice', '"Một nhà sàn đơn sơ vách nứa / Bốn bên suối chảy cá bơi vui."
Những từ ngữ nào cho thấy ở chiến khu Bác Hồ sống rất giản dị?', 'suối chảy', 'cá bơi vui', 'nhà sàn đơn sơ vách nứa', 'bốn bên', 'nhà sàn đơn sơ vách nứa', null::jsonb, 'Nhà sàn đơn sơ, vách nứa cho thấy cuộc sống giản dị.', 'doc_hieu', 23::int),
    (2::smallint, 'multiple_choice', 'Trong câu thơ "Người không con mà có triệu con", từ "triệu con" chỉ ai?', 'các chú bộ đội', 'con ruột của Bác', 'các bạn nhỏ nước ngoài', 'nhân dân Việt Nam', 'nhân dân Việt Nam', null::jsonb, 'Bác coi tất cả nhân dân Việt Nam như con của mình.', 'doc_hieu', 23::int),
    (2::smallint, 'multiple_choice', '"Tiệc tan, mọi người mời Bác ra phòng lớn uống nước và nói chuyện. Bác vui vẻ đứng dậy, cầm trên tay một quả táo đỏ."
Trước khi ra phòng lớn, Bác đã làm gì?', 'cầm lấy một quả táo trong bữa tiệc', 'cầm lấy một chiếc bánh', 'đứng dậy cảm ơn mọi người', null, 'cầm lấy một quả táo trong bữa tiệc', null::jsonb, 'Bác cầm trên tay một quả táo đỏ.', 'doc_hieu', 26::int),
    (2::smallint, 'multiple_choice', '"Bác ra đến ngoài thì có một đám thiếu nhi ríu rít chạy tới chào. Bác tươi cười bế em gái nhỏ nhất lên và cho em quả táo."
Khi các em thiếu nhi chạy tới chào, Bác đã làm gì?', 'khen các em ngoan ngoãn, lễ phép', 'xoa đầu em bé lớn nhất', 'bế em gái nhỏ nhất và cho em quả táo', null, 'bế em gái nhỏ nhất và cho em quả táo', null::jsonb, 'Bác bế em gái nhỏ nhất và cho em quả táo.', 'doc_hieu', 26::int),
    (2::smallint, 'multiple_choice', 'Câu "Tiệc tan, mọi người mời Bác ra phòng lớn uống nước và nói chuyện." thuộc kiểu câu nào?', 'Ai làm gì?', 'Ai là gì?', 'Ai thế nào?', null, 'Ai làm gì?', null::jsonb, 'Câu kể hoạt động của mọi người: mời Bác ra phòng lớn.', 'kieu_cau', 26::int),
    (2::smallint, 'multiple_choice', '"Bác Hồ sống rất giản dị nhưng rất có ___."
Chọn từ thích hợp:', 'leo núi', 'chịu đựng', 'dọn dẹp', 'nền nếp', 'nền nếp', null::jsonb, 'Bác sống có nền nếp: giờ nào việc nấy đều đặn.', 'tu_ngu_ve_bac_ho', 27::int),
    (2::smallint, 'multiple_choice', 'Đoạn hội thoại nào thể hiện phép lịch sự khi đáp lời khen?', '– Bạn giỏi thật! – Tớ lúc nào chả giỏi.', '– Bạn viết chữ đẹp quá! – Thế à, cảm ơn cậu.', '– Cho mượn bút nhé. – Cứ việc.', null, '– Bạn viết chữ đẹp quá! – Thế à, cảm ơn cậu.', null::jsonb, 'Khi được khen cần đáp lại vui vẻ và nói lời cảm ơn.', 'dap_loi_khen', 24::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Mùa gì dịu nắng
Mây nhẹ nhàng bay
Gió khẽ rung cây
Lá vàng rơi rụng?"', 'mùa hạ', 'mùa thu', 'mùa đông', 'mùa xuân', 'mùa thu', null::jsonb, 'Mùa thu nắng dịu, lá vàng rơi.', 'giai_do', 28::int),
    (2::smallint, 'text', 'Điền r, d hoặc gi:
"Mùa gì ___ịu nắng / Mây nhẹ nhàng bay"', null, null, null, null, 'd', null::jsonb, 'Dịu nắng: nắng êm, không gắt, viết d.', 'chinh_ta_r_d_gi', 28::int),
    (2::smallint, 'multiple_choice', '"Bác gọi mang ra một bát, một thìa con. Rồi Bác đem bát chè đậu đen đường phèn mà anh em phục vụ vừa mang lên, sẻ một nửa cho đồng chí liên lạc."
Bác mời đồng chí liên lạc ăn món gì?', 'cháo đậu đen', 'cơm', 'chè đậu đen đường phèn', null, 'chè đậu đen đường phèn', null::jsonb, 'Bác sẻ nửa bát chè đậu đen đường phèn.', 'doc_hieu', 28::int),
    (3::smallint, 'multiple_choice', '"Thấy đồng chí liên lạc ngần ngại, Bác giục: – Ăn đi, Bác cùng ăn…"
Bác đã làm gì khi thấy đồng chí liên lạc ngần ngại?', 'Bác cùng ăn với anh.', 'Bác bảo nếu không ăn thì Bác sẽ giận.', 'Bác bảo nếu không ăn thì Bác cũng không ăn.', null, 'Bác cùng ăn với anh.', null::jsonb, 'Bác giục: "Ăn đi, Bác cùng ăn…"', 'doc_hieu', 28::int),
    (3::smallint, 'multiple_choice', '"Thương Bác, em vừa ăn vừa rớt nước mắt, nhưng không ăn lại sợ Bác không vui…"
Vì sao anh lính thông tin vẫn cùng Bác ăn chè?', 'Vì anh sợ Bác không vui.', 'Vì bát chè do chính Bác nấu.', 'Vì khi đó anh đang rất đói.', null, 'Vì anh sợ Bác không vui.', null::jsonb, 'Anh nói: "không ăn lại sợ Bác không vui".', 'doc_hieu', 29::int),
    (3::smallint, 'multiple_choice', 'Truyện "Bát chè sẻ đôi" có Bác Hồ, đồng chí liên lạc (anh lính thông tin) và đồng chí cấp dưỡng. Câu chuyện cho em hiểu điều gì về Bác?', 'Bác rất thích ăn chè', 'Bác thường ăn đêm một mình', 'Bác không thích đồng chí liên lạc', 'Bác luôn quan tâm, chia sẻ với mọi người', 'Bác luôn quan tâm, chia sẻ với mọi người', null::jsonb, 'Bác sẻ nửa bát chè cho người liên lạc vì thương mọi người.', 'doc_hieu', 29::int),
    (3::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "vì Bác muốn các cháu thiếu nhi đến thăm có cá để xem" trong câu "Bác đề nghị các đồng chí kiếm một bể cá vì Bác muốn các cháu thiếu nhi đến thăm có cá để xem." là:', 'Bác đề nghị các đồng chí kiếm một bể cá để làm gì?', 'Bác đề nghị các đồng chí kiếm cái gì?', 'Vì sao Bác đề nghị các đồng chí kiếm một bể cá?', 'Khi nào Bác đề nghị kiếm một bể cá?', 'Vì sao Bác đề nghị các đồng chí kiếm một bể cá?', null::jsonb, 'Bộ phận bắt đầu bằng "vì" chỉ nguyên nhân, hỏi bằng "Vì sao?".', 'cau_hoi_vi_sao', 29::int),
    (3::smallint, 'multiple_choice', '"Khi mọi thứ đã được phân ra cho vào ba chiếc ba lô rồi, Bác mở cả ba chiếc ba lô ra xem thì thấy ba lô của Bác nhẹ nhất, chỉ có chăn màn."
Lúc dừng chân, Bác phát hiện ra điều gì?', 'Ba lô của Bác không có gì.', 'Ba lô của Bác nhẹ nhất, chỉ có chăn màn.', 'Ba lô của Bác nặng nhất.', null, 'Ba lô của Bác nhẹ nhất, chỉ có chăn màn.', null::jsonb, 'Bác thấy ba lô của mình nhẹ nhất.', 'doc_hieu', 30::int),
    (3::smallint, 'multiple_choice', 'Câu nói của Bác "Chỉ có lao động thật sự mới đem lại hạnh phúc cho con người." cho thấy điều gì?', 'Bác muốn mang ít đồ đạc hơn', 'Bác không thích đi công tác', 'Bác muốn hai đồng chí mang hết đồ', 'Bác coi trọng lao động, không muốn hơn người khác', 'Bác coi trọng lao động, không muốn hơn người khác', null::jsonb, 'Bác muốn mọi người cùng lao động như nhau, kể cả Bác.', 'doc_hieu', 31::int),
    (3::smallint, 'multiple_choice', '"Ngoài việc dạy văn hoá ( ) thầy Nguyễn Tất Thành còn dạy học sinh luyện tập thể dục ( ) mỗi buổi lên lớp, học trò thường chăm chú lắng nghe."
Dấu câu điền vào hai chỗ ( ) lần lượt là:', 'dấu chấm, dấu phẩy', 'dấu phẩy, dấu chấm', 'dấu phẩy, dấu phẩy', 'dấu chấm, dấu chấm', 'dấu phẩy, dấu chấm', null::jsonb, 'Chỗ thứ hai kết thúc một câu, câu sau bắt đầu "Mỗi buổi lên lớp".', 'dau_cham_dau_phay', 27::int),
    (3::smallint, 'multiple_choice', '"Bác trọ trong một khách sạn ___ tiền ở xóm lao động."
Chọn từ viết đúng:', 'rẻ', 'rẽ', 'dẻ', null, 'rẻ', null::jsonb, 'Rẻ tiền: giá thấp, viết r, dấu hỏi.', 'chinh_ta_hoi_nga', 22::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 31 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 32: Nhân dân – Từ trái nghĩa, chính tả l/n, v/d, it/ich (34 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 32, 100, 'Archimes: Nhân dân – Từ trái nghĩa, chính tả l/n, v/d, it/ich', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 32', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền l hoặc n:
Người có chí thì ___ên, nhà có nền thì vững.', null, null, null, null, 'n', null::jsonb, '"Nên" (thành công) viết n.', 'chinh_ta_l_n', 32::int),
    (1::smallint, 'text', 'Điền l hoặc n:
___ời nói chẳng mất tiền mua', null, null, null, null, 'l', null::jsonb, '"Lời nói" viết l.', 'chinh_ta_l_n', 32::int),
    (1::smallint, 'text', 'Điền l hoặc n:
___uôi con mới biết công lao mẹ thầy.', null, null, null, null, 'n', null::jsonb, '"Nuôi" viết n.', 'chinh_ta_l_n', 32::int),
    (1::smallint, 'text', 'Điền v hoặc d:
___âng lời', null, null, null, null, 'v', null::jsonb, 'Vâng lời viết v.', 'chinh_ta_v_d', 32::int),
    (1::smallint, 'text', 'Điền v hoặc d:
___ân tộc', null, null, null, null, 'd', null::jsonb, 'Dân tộc viết d.', 'chinh_ta_v_d', 32::int),
    (1::smallint, 'text', 'Điền it hoặc ich (thêm dấu thanh nếu cần):
Chim ch___ là một loài chim nhỏ, thường ăn sâu bọ.', null, null, null, null, 'ích', '["chích"]'::jsonb, 'Chim chích: vần ich, dấu sắc.', 'chinh_ta_it_ich', 32::int),
    (1::smallint, 'text', 'Điền it hoặc ich (thêm dấu thanh nếu cần):
Mùa hè đến, những quả m___ bắt đầu chín thơm lừng.', null, null, null, null, 'ít', '["mít"]'::jsonb, 'Quả mít: vần it, dấu sắc.', 'chinh_ta_it_ich', 32::int),
    (1::smallint, 'multiple_choice', 'Cặp từ trái nghĩa trong câu "Tuổi nhỏ chí lớn." là:', 'tuổi – chí', 'nhỏ – lớn', 'tuổi – lớn', null, 'nhỏ – lớn', null::jsonb, '"Nhỏ" và "lớn" có nghĩa trái ngược nhau.', 'tu_trai_nghia', 33::int),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "nhanh nhẹn" là:', 'chậm chạp', 'khéo léo', 'nhanh nhảu', 'chăm chỉ', 'chậm chạp', null::jsonb, 'Nhanh nhẹn trái với chậm chạp.', 'tu_trai_nghia', 33::int),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "sạch sẽ" là:', 'gọn gàng', 'sạch bong', 'bẩn thỉu', 'ngăn nắp', 'bẩn thỉu', null::jsonb, 'Sạch sẽ trái với bẩn thỉu.', 'tu_trai_nghia', 33::int),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "chăm chỉ" là:', 'siêng năng', 'cần cù', 'chịu khó', 'lười biếng', 'lười biếng', null::jsonb, 'Siêng năng, cần cù, chịu khó cùng nghĩa với chăm chỉ; trái nghĩa là lười biếng.', 'tu_trai_nghia', 35::int),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "chìm" là:', 'lặn', 'sâu', 'trôi', 'nổi', 'nổi', null::jsonb, 'Chìm (xuống dưới nước) trái với nổi (lên mặt nước).', 'tu_trai_nghia', 35::int),
    (1::smallint, 'text', 'Điền từ trái nghĩa với từ "cao":
Chuồn chuồn bay ___ thì mưa, bay cao thì nắng, bay vừa thì râm.', null, null, null, null, 'thấp', null::jsonb, 'Cao trái nghĩa với thấp.', 'tu_trai_nghia', 33::int),
    (1::smallint, 'number', 'Việt Nam có ___ dân tộc cùng chung sống.', null, null, null, null, '54', null::jsonb, 'Đoạn văn viết: "Việt Nam có 54 dân tộc cùng chung sống".', 'doc_hieu', 33::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "già":
Đi hỏi già, về nhà hỏi ___.', null, null, null, null, 'trẻ', null::jsonb, 'Già trái nghĩa với trẻ.', 'tu_trai_nghia', 33::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "no":
Một miếng khi ___ bằng một gói khi no.', null, null, null, null, 'đói', null::jsonb, 'No trái nghĩa với đói.', 'tu_trai_nghia', 33::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "xa":
Bán anh em xa, mua láng giềng ___.', null, null, null, null, 'gần', null::jsonb, 'Xa trái nghĩa với gần.', 'tu_trai_nghia', 33::int),
    (2::smallint, 'multiple_choice', 'Thành ngữ nào có cặp từ trái nghĩa "trên – dưới"?', 'Làng trên xóm dưới', 'Chân cứng đá mềm', 'Xấu người đẹp nết', 'Gạn đục khơi trong', 'Làng trên xóm dưới', null::jsonb, 'Làng trên xóm dưới: "trên" trái nghĩa với "dưới".', 'tu_trai_nghia', 33::int),
    (2::smallint, 'multiple_choice', 'Từ trái nghĩa với "rộng rãi" là:', 'thênh thang', 'chật hẹp', 'bao la', 'rộng lớn', 'chật hẹp', null::jsonb, 'Rộng rãi trái với chật hẹp.', 'tu_trai_nghia', 33::int),
    (2::smallint, 'multiple_choice', 'Từ trái nghĩa với "bận rộn" là:', 'vất vả', 'tất bật', 'nhàn rỗi', 'chăm chỉ', 'nhàn rỗi', null::jsonb, 'Bận rộn trái với nhàn rỗi (rảnh rỗi).', 'tu_trai_nghia', 33::int),
    (2::smallint, 'text', 'Điền it hoặc ich (thêm dấu thanh nếu cần):
Ngoài đường, xe cộ đi lại đông nghìn ngh___.', null, null, null, null, 'ịt', '["nghịt"]'::jsonb, 'Đông nghìn nghịt: vần it, dấu nặng.', 'chinh_ta_it_ich', 32::int),
    (2::smallint, 'multiple_choice', '"Những bông lúa vàng mới cắt xong đều xếp rải rác từng hàng trên bờ ruộng. Tiếng hái cứa vào gốc lúa xoàn xoạt như tiếng trâu bò ăn cỏ."
Đoạn trích "Gặt lúa" miêu tả cảnh gì?', 'cảnh gặt lúa trên cánh đồng', 'cảnh cấy lúa trên cánh đồng', 'cảnh gặt lúa trên nương', null, 'cảnh gặt lúa trên cánh đồng', null::jsonb, 'Người thợ cắt lúa trên ruộng, bờ ruộng: đó là cảnh gặt lúa trên cánh đồng.', 'doc_hieu', 34::int),
    (2::smallint, 'multiple_choice', '"Tiếng hái cứa vào gốc lúa xoàn xoạt như tiếng trâu bò ăn cỏ. Mọi người vừa gặt vừa nói chuyện rôm rả."
Trong khung cảnh lao động có những âm thanh nào?', 'tiếng người trò chuyện, tiếng trâu bò ăn cỏ', 'tiếng hái cứa vào gốc lúa, tiếng người trò chuyện', 'tiếng người trò chuyện, tiếng gió xào xạc', null, 'tiếng hái cứa vào gốc lúa, tiếng người trò chuyện', null::jsonb, 'Tiếng trâu bò ăn cỏ chỉ là hình ảnh so sánh, không có thật.', 'doc_hieu', 34::int),
    (2::smallint, 'multiple_choice', '"Bài hát gửi gắm thông điệp về một thế giới không có chiến tranh, yêu chuộng hoà bình."
Cặp từ trái nghĩa trong câu là:', 'thế giới – hoà bình', 'gửi gắm – yêu chuộng', 'chiến tranh – hoà bình', null, 'chiến tranh – hoà bình', null::jsonb, 'Chiến tranh trái nghĩa với hoà bình.', 'tu_trai_nghia', 35::int),
    (2::smallint, 'multiple_choice', '"Những cây mùng tơi trước đây còi cọc, giờ đã ra bao nhiêu ngọn mập mạp."
Cặp từ trái nghĩa trong câu là:', 'còi cọc – mập mạp', 'mùng tơi – ngọn', 'ra – ngọn', null, 'còi cọc – mập mạp', null::jsonb, 'Còi cọc (gầy yếu) trái nghĩa với mập mạp.', 'tu_trai_nghia', 35::int),
    (2::smallint, 'multiple_choice', 'Chọn cặp từ trái nghĩa điền vào chỗ trống:
Trước ___ sau ___.', 'quen – lạ', 'lạ – quen', 'dễ – khó', null, 'lạ – quen', null::jsonb, 'Trước lạ sau quen: lúc đầu còn lạ, về sau thân quen.', 'tu_trai_nghia', 33::int),
    (3::smallint, 'multiple_choice', '"Chăm chú vào công việc làm, Tân không để ý gì đến cảnh vật chung quanh. Anh cũng không thấy mệt nữa. Mỗi lần bông lúa chạm vào người, mùi lúa chín thơm làm cho lòng anh càng say sưa hơn."
Vì sao Tân không thấy mệt?', 'Vì anh vừa làm vừa nói chuyện rôm rả', 'Vì công việc đã gần xong', 'Vì anh chăm chú làm, mùi lúa chín làm anh say sưa', null, 'Vì anh chăm chú làm, mùi lúa chín làm anh say sưa', null::jsonb, 'Tân mải mê làm việc và say sưa với mùi lúa chín nên quên mệt.', 'doc_hieu', 34::int),
    (3::smallint, 'multiple_choice', 'Nội dung chính của đoạn trích "Gặt lúa" (Thạch Lam) là gì?', 'Vẻ đẹp cánh đồng mùa gặt và niềm vui lao động', 'Chỉ tả tiếng hái cắt lúa', 'Nỗi buồn của người nông dân', null, 'Vẻ đẹp cánh đồng mùa gặt và niềm vui lao động', null::jsonb, 'Bài vừa tả cánh đồng lúa chín đẹp, vừa nói niềm say sưa lao động.', 'doc_hieu', 35::int),
    (3::smallint, 'multiple_choice', '"Ấm áp trong chiếc áo len dày, em nghĩ thương các bạn nhỏ vùng cao chỉ có một tấm áo mỏng khi đến lớp học ngày đông."
Cặp từ trái nghĩa trong câu là:', 'ấm áp – thương', 'dày – mỏng', 'nhỏ – cao', null, 'dày – mỏng', null::jsonb, 'Áo len dày trái với tấm áo mỏng.', 'tu_trai_nghia', 35::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp từ trái nghĩa điền vào chỗ trống:
___ là sống, ___ là chết.', 'dễ – khó', 'lạ – quen', 'chết – sống', 'đoàn kết – chia rẽ', 'đoàn kết – chia rẽ', null::jsonb, 'Đoàn kết là sống, chia rẽ là chết.', 'tu_trai_nghia', 33::int),
    (3::smallint, 'multiple_choice', 'Chọn cặp từ trái nghĩa điền vào chỗ trống:
Nói thì ___, làm thì ___.', 'khó – dễ', 'lạ – quen', 'sống – chết', 'dễ – khó', 'dễ – khó', null::jsonb, 'Nói thì dễ, làm thì khó: làm khó hơn nói.', 'tu_trai_nghia', 33::int),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG trái nghĩa với "hiền lành"?', 'độc ác', 'hung dữ', 'hiền hậu', null, 'hiền hậu', null::jsonb, 'Hiền hậu cùng nghĩa với hiền lành.', 'tu_trai_nghia', 35::int),
    (3::smallint, 'multiple_choice', '"Mỗi dân tộc có những nét văn hoá riêng ( ) thể hiện trong ngôn ngữ ( ) trang phục ( ) phong tục tập quán của mỗi dân tộc ( ) Điều đó làm cho nền văn hoá Việt Nam thêm phong phú."
Dấu câu lần lượt điền vào các chỗ ( ) là:', 'chấm, phẩy, phẩy, chấm', 'phẩy, phẩy, chấm, chấm', 'phẩy, chấm, phẩy, phẩy', 'phẩy, phẩy, phẩy, chấm', 'phẩy, phẩy, phẩy, chấm', null::jsonb, 'Ba chỗ đầu ngăn cách các ý trong câu; chỗ cuối kết thúc câu vì "Điều đó" viết hoa.', 'dau_cham_dau_phay', 33::int),
    (3::smallint, 'multiple_choice', '"Muốn có thu hoạch ( ) người nông dân phải làm rất nhiều việc ( ) họ phải cày bừa, gieo hạt và ươm mầm."
Dấu câu lần lượt điền vào hai chỗ ( ) là (chữ sau dấu chấm phải viết hoa):', 'dấu chấm, dấu phẩy', 'dấu phẩy, dấu phẩy', 'dấu chấm, dấu chấm', 'dấu phẩy, dấu chấm', 'dấu phẩy, dấu chấm', null::jsonb, 'Muốn có thu hoạch, người nông dân phải làm rất nhiều việc. Họ phải cày bừa…', 'dau_cham_dau_phay', 35::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 32 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 33: Nhân dân – Từ ngữ chỉ nghề nghiệp, chính tả s/x, i/iê (31 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 33, 100, 'Archimes: Nhân dân – Từ ngữ chỉ nghề nghiệp, chính tả s/x, i/iê', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 33', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền s hoặc x:
Em bé đã biết dùng thìa ___úc cơm ăn.', null, null, null, null, 'x', null::jsonb, 'Xúc cơm viết x.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Người ta thường ___úc miệng bằng nước muối.', null, null, null, null, 's', null::jsonb, 'Súc miệng viết s.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Sáng sớm, những giọt ___ương đọng long lanh trên cỏ.', null, null, null, null, 's', null::jsonb, 'Giọt sương viết s.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Cây ___ương rồng có thể sống được ở sa mạc.', null, null, null, null, 'x', null::jsonb, 'Cây xương rồng viết x.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Trồng cây ở đồi trọc để chống ___ói mòn.', null, null, null, null, 'x', null::jsonb, 'Xói mòn viết x.', 'chinh_ta_s_x', 36::int),
    (1::smallint, 'text', 'Điền s hoặc x:
Nhỏ xinh một ___ợi mỏng manh', null, null, null, null, 's', null::jsonb, 'Sợi chỉ viết s.', 'chinh_ta_s_x', 37::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'báo tin, đầu tiên', 'báo tiên, đầu tin', 'báo tin, đầu tin', 'báo tiên, đầu tiên', 'báo tin, đầu tiên', null::jsonb, 'Báo tin (vần in), đầu tiên (vần iên).', 'chinh_ta_i_ie', 36::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'trái tiêm, kim tim', 'trái tim, kim tiêm', 'trái tim, kim tim', 'trái tiêm, kim tiêm', 'trái tim, kim tiêm', null::jsonb, 'Trái tim (vần im), kim tiêm (vần iêm).', 'chinh_ta_i_ie', 36::int),
    (1::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'số chiến, chín thắng', 'số chín, chín thắng', 'số chín, chiến thắng', 'số chiến, chiến thắng', 'số chín, chiến thắng', null::jsonb, 'Số chín (vần in), chiến thắng (vần iên).', 'chinh_ta_i_ie', 36::int),
    (1::smallint, 'multiple_choice', 'Từ nào dưới đây chỉ nghề nghiệp?', 'sĩ số', 'dũng cảm', 'chăm chỉ', 'ca sĩ', 'ca sĩ', null::jsonb, 'Ca sĩ là người làm nghề hát.', 'tu_chi_nghe_nghiep', 37::int),
    (1::smallint, 'multiple_choice', 'Từ nào chỉ nghề nghiệp có tiếng "viên"?', 'giáo viên', 'viên phấn', 'viên kẹo', 'công viên', 'giáo viên', null::jsonb, 'Giáo viên là người làm nghề dạy học.', 'tu_chi_nghe_nghiep', 37::int),
    (1::smallint, 'multiple_choice', 'Giải câu đố:
"Nghề gì chăm sóc bệnh nhân
Cho ta khoẻ mạnh, vui chơi học hành?"', 'thợ xây', 'bác sĩ', 'giáo viên', 'nông dân', 'bác sĩ', null::jsonb, 'Bác sĩ khám, chữa bệnh cho mọi người.', 'giai_do', 38::int),
    (1::smallint, 'multiple_choice', '"– Đẹp quá! Mẹ vá đường cũng khéo như vá áo ấy!"
Thư thấy mẹ vá đường như thế nào?', 'khéo như may áo', 'khéo như thêu áo', 'khéo như vá áo', null, 'khéo như vá áo', null::jsonb, 'Thư nói: "Mẹ vá đường cũng khéo như vá áo ấy!"', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', 'Dãy nào viết đúng chính tả?', 'ý kín, kiến đáo', 'ý kiến, kiến đáo', 'ý kín, kín đáo', 'ý kiến, kín đáo', 'ý kiến, kín đáo', null::jsonb, 'Ý kiến (vần iên), kín đáo (vần in).', 'chinh_ta_i_ie', 36::int),
    (2::smallint, 'multiple_choice', 'Giải câu đố:
"Nghề gì bạn với vữa vôi
Xây nhà cao đẹp, bạn, tôi đều cần?"', 'thợ xây', 'thợ may', 'thợ mộc', 'thợ điện', 'thợ xây', null::jsonb, 'Thợ xây dùng vữa vôi để xây nhà.', 'giai_do', 38::int),
    (2::smallint, 'multiple_choice', '___ là người dạy dỗ, truyền đạt kiến thức cho học sinh.', 'Nha sĩ', 'Giáo viên', 'Kĩ sư cầu đường', 'Công nhân xây dựng', 'Giáo viên', null::jsonb, 'Giáo viên dạy học sinh.', 'tu_chi_nghe_nghiep', 38::int),
    (2::smallint, 'multiple_choice', 'Nha sĩ là người ___', 'thiết kế và xây dựng cầu đường', 'dạy dỗ, truyền đạt kiến thức', 'chăm sóc, khám và chữa bệnh răng miệng', 'thi công xây dựng nhà cửa', 'chăm sóc, khám và chữa bệnh răng miệng', null::jsonb, 'Nha sĩ là bác sĩ chữa răng.', 'tu_chi_nghe_nghiep', 38::int),
    (2::smallint, 'multiple_choice', 'Kĩ sư cầu đường là người ___', 'khám và chữa bệnh răng miệng', 'dạy dỗ học sinh', 'may quần áo cho mọi người', 'chuyên thiết kế và xây dựng cầu đường', 'chuyên thiết kế và xây dựng cầu đường', null::jsonb, 'Kĩ sư cầu đường thiết kế, xây dựng cầu và đường.', 'tu_chi_nghe_nghiep', 38::int),
    (2::smallint, 'multiple_choice', '"– Minh ơi, mình để quên thước kẻ ở nhà.
– Tiếc quá! Hôm nay tớ cũng không mang thước."
Lời đáp nào lịch sự?', 'Thế thì còn nói làm gì, tớ mượn bạn khác vậy.', 'Thế à? Không sao đâu, để tớ hỏi mượn bạn khác vậy.', 'Sao chán thế!', null, 'Thế à? Không sao đâu, để tớ hỏi mượn bạn khác vậy.', null::jsonb, 'Đáp lời từ chối cần vui vẻ, lịch sự.', 'dap_loi_tu_choi', 39::int),
    (2::smallint, 'multiple_choice', '"– Hoà ơi, cậu sang đây chơi với tớ!
– Bây giờ thì không được, tớ đang chuẩn bị sang nhà bà ngoại với mẹ."
Lời đáp nào lịch sự?', 'Thế à, chán nhỉ!', 'Thôi, tớ cũng chẳng cần cậu.', 'Vậy à? Thế thì khi nào về, cậu sang chơi với tớ nhé!', null, 'Vậy à? Thế thì khi nào về, cậu sang chơi với tớ nhé!', null::jsonb, 'Lời đáp lịch sự thể hiện sự thông cảm và mong muốn gặp lại.', 'dap_loi_tu_choi', 39::int),
    (2::smallint, 'multiple_choice', '"Bác Tâm, mẹ của Thư, đang chăm chú làm việc. Tay trái bác xếp rất khéo những viên đá bọc nhựa đường đen nhánh vào chỗ trũng."
Bác Tâm làm nghề gì?', 'công nhân sửa đường', 'thợ xây', 'công nhân may mặc', null, 'công nhân sửa đường', null::jsonb, 'Bác xếp đá bọc nhựa đường vá chỗ trũng: đó là công nhân sửa đường.', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', '"Bác đi một đôi găng tay bằng vải rất dày. Vì thế, tay bác y như tay một người khổng lồ."
Vì sao tay bác Tâm y như tay người khổng lồ?', 'Vì tay bác bị sưng to.', 'Vì bác đi đôi găng tay bằng vải rất dày.', 'Vì tay bác làm việc nhiều nên to ra.', null, 'Vì bác đi đôi găng tay bằng vải rất dày.', null::jsonb, 'Đôi găng dày làm bàn tay trông rất to.', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', '"Bác đập búa đều đều xuống những viên đá để chúng ken chắc vào nhau. Hai tay bác đưa lên hạ xuống nhịp nhàng."
Động tác đập búa của bác Tâm thế nào?', 'nhẹ nhàng, khéo léo', 'liên hồi, nhanh thoăn thoắt', 'đều đều, đưa lên hạ xuống nhịp nhàng', null, 'đều đều, đưa lên hạ xuống nhịp nhàng', null::jsonb, 'Bài viết: đập búa đều đều, tay đưa lên hạ xuống nhịp nhàng.', 'doc_hieu', 40::int),
    (2::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ nghề nghiệp trong dãy: diễn viên, đạo diễn, ca sĩ, anh dũng, phi công?', 'đạo diễn', 'ca sĩ', 'phi công', 'anh dũng', 'anh dũng', null::jsonb, 'Anh dũng chỉ đức tính, không phải nghề.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Chi tiết nào cho thấy công việc vá đường của bác Tâm rất vất vả?', 'Mảnh áo ướt đẫm mồ hôi ở lưng bác cứ loang ra mãi.', 'Tay phải bác cầm một chiếc búa.', 'Bác Tâm đứng lên, vươn vai mấy cái liền.', null, 'Mảnh áo ướt đẫm mồ hôi ở lưng bác cứ loang ra mãi.', null::jsonb, 'Áo ướt đẫm mồ hôi cho thấy bác làm việc rất nặng nhọc.', 'doc_hieu', 40::int),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ nghề nghiệp trong dãy: thợ nề, thợ xây, xây nhà, giáo viên?', 'thợ nề', 'thợ xây', 'giáo viên', 'xây nhà', 'xây nhà', null::jsonb, '"Xây nhà" chỉ một việc làm, không phải tên nghề.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Từ nào KHÔNG chỉ nghề nghiệp trong dãy: đầu bếp, lao công, lao động, nhà báo, nhà thơ?', 'lao động', 'lao công', 'đầu bếp', 'nhà báo', 'lao động', null::jsonb, '"Lao động" là làm việc nói chung, không phải tên một nghề; lao công là người làm vệ sinh.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Nghề nào được nhắc đến trong đoạn thơ?
"Mặc áo màu lửa
Kêu vang trên đường
Khẩn trương dũng cảm
Coi thường hiểm nguy."', 'thợ gốm', 'lính cứu hoả', 'công an giao thông', 'bác sĩ', 'lính cứu hoả', null::jsonb, 'Xe cứu hoả màu đỏ, kêu vang, người lính dũng cảm dập lửa.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Nghề nào được nhắc đến trong đoạn thơ?
"Từ bùn đất sét
Qua bàn tay cha
Qua bàn tay mẹ
Thành cái bát hoa."', 'thợ xây', 'thợ may', 'thợ gốm', 'thợ mộc', 'thợ gốm', null::jsonb, 'Thợ gốm nặn đất sét thành bát, đĩa.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Dãy nào gồm toàn từ chỉ nghề nghiệp có tiếng "nhà"?', 'nhà cửa, nhà báo, nhà thơ', 'nhà văn, nhà sàn, nhà khoa học', 'nhà ga, nhà thơ, nhà văn', 'nhà báo, nhà thơ, nhà văn', 'nhà báo, nhà thơ, nhà văn', null::jsonb, 'Nhà cửa, nhà sàn, nhà ga không phải nghề nghiệp.', 'tu_chi_nghe_nghiep', 41::int),
    (3::smallint, 'multiple_choice', 'Giải câu đố:
"Nhỏ xinh một sợi mỏng manh
Xâu kim, xếp vải, khâu thành áo luôn.
Ngược xuôi trăm nẻo chẳng buồn
Giúp người mặc đẹp, tôi luôn ẩn mình."', 'sợi chỉ', 'cây kim', 'cái kéo', 'sợi len', 'sợi chỉ', null::jsonb, 'Sợi chỉ xâu vào kim để khâu áo, nằm ẩn trong đường may.', 'giai_do', 37::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 33 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 34: Nhân dân – Từ ngữ chỉ nghề nghiệp, từ trái nghĩa, chính tả tr/ch, ong/ông (39 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 34, 100, 'Archimes: Nhân dân – Từ ngữ chỉ nghề nghiệp, từ trái nghĩa, chính tả tr/ch, ong/ông', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 34', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Điền ong hoặc ông (thêm dấu thanh nếu cần):
v___ tròn', null, null, null, null, 'òng', '["vòng"]'::jsonb, 'Vòng tròn: vần ong, dấu huyền.', 'chinh_ta_ong_ong', 42::int),
    (1::smallint, 'text', 'Điền ong hoặc ông (thêm dấu thanh nếu cần):
tr___ trọt', null, null, null, null, 'ồng', '["trồng"]'::jsonb, 'Trồng trọt: vần ông, dấu huyền.', 'chinh_ta_ong_ong', 42::int),
    (1::smallint, 'text', 'Điền ong hoặc ông (thêm dấu thanh nếu cần):
căn ph___', null, null, null, null, 'òng', '["phòng"]'::jsonb, 'Căn phòng: vần ong, dấu huyền.', 'chinh_ta_ong_ong', 42::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
Ông ___ăng tròn sáng quá', null, null, null, null, 'tr', null::jsonb, 'Ông trăng viết tr.', 'chinh_ta_tr_ch', 42::int),
    (1::smallint, 'text', 'Điền tr hoặc ch:
Trăng còn ___ú Cuội', null, null, null, null, 'ch', null::jsonb, 'Chú Cuội viết ch.', 'chinh_ta_tr_ch', 42::int),
    (1::smallint, 'multiple_choice', 'Đồ dùng bằng vải, len, dạ… may thành tấm để đắp cho ấm là gì?', 'trăn', 'chăn', 'chai', 'trai', 'chăn', null::jsonb, 'Cái chăn dùng để đắp cho ấm.', 'chinh_ta_tr_ch', 42::int),
    (1::smallint, 'multiple_choice', 'Côn trùng có ngòi đốt ở đuôi, sống thành đàn, hút mật hoa để làm mật là con gì?', 'con bướm', 'con muỗi', 'con ong', 'con kiến', 'con ong', null::jsonb, 'Con ong hút mật hoa làm mật.', 'chinh_ta_ong_ong', 43::int),
    (1::smallint, 'multiple_choice', 'Loài chim cùng họ với gà, có lông đuôi dài nhiều màu sắc, xoè múa rất đẹp là con gì?', 'con cò', 'con vẹt', 'con sáo', 'con công', 'con công', null::jsonb, 'Con công xoè đuôi múa rất đẹp.', 'chinh_ta_ong_ong', 43::int),
    (1::smallint, 'multiple_choice', 'Giải câu đố:
"Tay cầm cái chổi / Chăm chỉ miệt mài / Quét dọn hằng ngày / Phố phường sạch sẽ / Người đó là ai?"', 'công nhân vệ sinh (lao công)', 'thợ xây', 'bác sĩ', 'thợ may', 'công nhân vệ sinh (lao công)', null::jsonb, 'Người lao công quét dọn cho phố phường sạch sẽ.', 'tu_chi_nghe_nghiep', 44::int),
    (1::smallint, 'multiple_choice', '"Bé chơi làm ___ / Chữa bệnh cho mọi người."
Chọn từ thích hợp:', 'thợ mỏ', 'thầy thuốc', 'cô nuôi', 'thợ nề', 'thầy thuốc', null::jsonb, 'Thầy thuốc chữa bệnh cho mọi người.', 'tu_chi_nghe_nghiep', 44::int),
    (1::smallint, 'text', 'Từ trái nghĩa với "giàu" là ___.', null, null, null, null, 'nghèo', null::jsonb, 'Giàu trái nghĩa với nghèo.', 'tu_trai_nghia', 44::int),
    (1::smallint, 'text', 'Điền từ trái nghĩa với "lành":
Lá lành đùm lá ___.', null, null, null, null, 'rách', null::jsonb, 'Lành trái nghĩa với rách.', 'tu_trai_nghia', 44::int),
    (1::smallint, 'multiple_choice', 'Từ trái nghĩa với "ồn ào" là:', 'nhộn nhịp', 'ầm ĩ', 'yên lặng', 'náo nhiệt', 'yên lặng', null::jsonb, 'Ồn ào trái với yên lặng.', 'tu_trai_nghia', 44::int),
    (1::smallint, 'multiple_choice', '"– Bố tớ là ___. Bố tớ dạy học."
Chọn từ chỉ nghề nghiệp thích hợp:', 'nha sĩ', 'bác sĩ', 'kĩ sư', 'giáo viên', 'giáo viên', null::jsonb, 'Người dạy học là giáo viên.', 'tu_chi_nghe_nghiep', 47::int),
    (2::smallint, 'multiple_choice', 'Loài rắn lớn sống ở rừng nhiệt đới, không có nọc độc, có thể bắt ăn cả thú khá lớn là con gì?', 'con trăn', 'con chạch', 'con rắn lục', 'con trai', 'con trăn', null::jsonb, 'Con trăn là loài rắn lớn không có nọc độc.', 'chinh_ta_tr_ch', 42::int),
    (2::smallint, 'multiple_choice', 'Động vật thân mềm có vỏ cứng hai mảnh, sống ở đáy nước, một số loài tạo ra ngọc là con gì?', 'con chai', 'con trai', 'con ốc', 'con tôm', 'con trai', null::jsonb, 'Con trai có hai mảnh vỏ, có loài tạo ra ngọc trai.', 'chinh_ta_tr_ch', 42::int),
    (2::smallint, 'multiple_choice', 'Hiện tượng mặt nước dao động, dâng lên, hạ xuống, chủ yếu do gió gây ra gọi là gì?', 'mưa', 'bão', 'sóng', 'lũ', 'sóng', null::jsonb, 'Mặt nước nhấp nhô lên xuống do gió là sóng.', 'chinh_ta_ong_ong', 43::int),
    (2::smallint, 'text', 'Điền ong hoặc ông (thêm dấu thanh nếu cần):
Đi xuôi thì có, ngược kh___ bao giờ?', null, null, null, null, 'ông', '["không"]'::jsonb, 'Không: vần ông.', 'chinh_ta_ong_ong', 43::int),
    (2::smallint, 'multiple_choice', '"Bé chơi làm ___ / Đào lên thật nhiều than."
Chọn từ thích hợp:', 'thợ nề', 'thợ hàn', 'thầy thuốc', 'thợ mỏ', 'thợ mỏ', null::jsonb, 'Thợ mỏ đào than dưới lòng đất.', 'tu_chi_nghe_nghiep', 44::int),
    (2::smallint, 'multiple_choice', '"Bé chơi làm ___ / Xúc cơm cho cháu bé."
Chọn từ thích hợp:', 'cô nuôi', 'thợ hàn', 'thợ mỏ', 'thợ nề', 'cô nuôi', null::jsonb, 'Cô nuôi chăm sóc, cho các cháu bé ăn.', 'tu_chi_nghe_nghiep', 44::int),
    (2::smallint, 'multiple_choice', 'Từ trái nghĩa với "hèn nhát" là:', 'nhút nhát', 'dũng cảm', 'sợ hãi', 'e thẹn', 'dũng cảm', null::jsonb, 'Hèn nhát trái với dũng cảm.', 'tu_trai_nghia', 44::int),
    (2::smallint, 'multiple_choice', 'Cặp từ trái nghĩa trong thành ngữ "Ba chìm bảy nổi" là:', 'chìm – nổi', 'ba – bảy', 'ba – chìm', null, 'chìm – nổi', null::jsonb, 'Chìm trái nghĩa với nổi.', 'tu_trai_nghia', 44::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "vụng":
Áo rách ___ vá hơn lành vụng may.', null, null, null, null, 'khéo', null::jsonb, 'Vụng trái nghĩa với khéo.', 'tu_trai_nghia', 45::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "muộn":
Đi ___ về muộn.', null, null, null, null, 'sớm', null::jsonb, 'Muộn trái nghĩa với sớm.', 'tu_trai_nghia', 45::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "dài":
Bóc ___ cắn dài.', null, null, null, null, 'ngắn', null::jsonb, 'Dài trái nghĩa với ngắn.', 'tu_trai_nghia', 45::int),
    (2::smallint, 'text', 'Điền từ trái nghĩa với từ "sướng":
___ trước sướng sau.', null, null, null, null, 'khổ', null::jsonb, 'Sướng trái nghĩa với khổ.', 'tu_trai_nghia', 45::int),
    (2::smallint, 'multiple_choice', '"Vũ Duệ là con nhà nghèo, hằng ngày phải trông em để cha mẹ đi làm đồng. Không được đến trường nhưng cậu rất ham học."
Vì sao Vũ Duệ không được đến trường?', 'Vì cậu lười học.', 'Vì cậu bị phạt.', 'Vì nhà cậu nghèo.', null, 'Vì nhà cậu nghèo.', null::jsonb, 'Nhà nghèo, cậu phải ở nhà trông em.', 'doc_hieu', 46::int),
    (2::smallint, 'multiple_choice', '"Ngày ngày, Duệ cõng em đứng ngoài lớp học chăm chú nghe thầy giảng."
Không được đến trường, Vũ Duệ đã làm gì?', 'tự học ở nhà', 'đi chơi cùng bọn trẻ trong làng', 'đứng ngoài lớp học nghe thầy giảng', null, 'đứng ngoài lớp học nghe thầy giảng', null::jsonb, 'Duệ cõng em đứng ngoài lớp nghe thầy giảng.', 'doc_hieu', 46::int),
    (2::smallint, 'multiple_choice', '"Lông quạ ___ quá thế / Còn cánh cò trắng phau?"
Chọn từ trái nghĩa thích hợp:', 'xa', 'hiện', 'ẩn', 'đen', 'đen', null::jsonb, 'Đen trái nghĩa với trắng.', 'tu_trai_nghia', 47::int),
    (2::smallint, 'text', 'Viết lại chữ in hoa cho đúng dấu hỏi hoặc dấu ngã:
"Những người lính cứu hoả lập tức mặc quần áo chữa cháy, đi UNG, đeo găng."', null, null, null, null, 'ủng', null::jsonb, 'Đôi ủng: dấu hỏi.', 'chinh_ta_hoi_nga', 48::int),
    (2::smallint, 'text', 'Viết lại chữ in hoa cho đúng dấu hỏi hoặc dấu ngã:
"…đeo găng, đội MU rồi lao ra xe."', null, null, null, null, 'mũ', null::jsonb, 'Cái mũ: dấu ngã.', 'chinh_ta_hoi_nga', 48::int),
    (3::smallint, 'multiple_choice', '"Thấy Duệ ham học và sáng dạ, thầy đến nhà Duệ, khuyên cha mẹ Duệ cho cậu đi học. Đến lớp vài tháng, Duệ đã đứng đầu lớp."
Vũ Duệ là cậu bé thế nào?', 'chăm chỉ, tốt bụng', 'ham học, thông minh', 'nhanh nhẹn, dũng cảm', null, 'ham học, thông minh', null::jsonb, '"Ham học và sáng dạ" nghĩa là ham học, thông minh.', 'doc_hieu', 46::int),
    (3::smallint, 'multiple_choice', 'Cặp từ nào là cặp từ trái nghĩa có trong câu chuyện "Cậu bé đứng ngoài lớp học"?', 'trong – ngoài', 'chăm chú – trôi chảy', 'giảng – khuyên', null, 'trong – ngoài', null::jsonb, 'Duệ đứng ngoài lớp; các trò trong lớp: "trong" trái nghĩa với "ngoài".', 'tu_trai_nghia', 46::int),
    (3::smallint, 'multiple_choice', '"– Bố tớ là ___. Bố tớ trồng răng.
– Lạ thật! Bố cậu trồng răng mà sao em cậu không có răng?"
Chọn từ chỉ nghề nghiệp thích hợp:', 'giáo viên', 'nông dân', 'thợ xây', 'nha sĩ', 'nha sĩ', null::jsonb, 'Nha sĩ là người chữa răng, trồng răng giả.', 'tu_chi_nghe_nghiep', 47::int),
    (3::smallint, 'multiple_choice', '"Đời ta gương vỡ lại lành / Cây khô cây lại đâm cành nở hoa."
Cặp từ trái nghĩa trong câu thơ đầu là:', 'gương – lành', 'vỡ – lành', 'đời – ta', null, 'vỡ – lành', null::jsonb, 'Gương vỡ trái với gương lành.', 'tu_trai_nghia', 48::int),
    (3::smallint, 'multiple_choice', '"Ở cấp thứ ba có bốn cửa theo hướng Đông, Tây, Nam, Bắc. Trừ cửa hướng Bắc, các cửa khác đều có tên riêng: cửa hướng Đông tên là Nghênh Húc, cửa hướng Tây tên là Hồi Quang, cửa hướng Nam tên là Hướng Minh."
Cửa hướng nào của Cột cờ Hà Nội không có tên?', 'cửa hướng Nam', 'cửa hướng Tây', 'cửa hướng Bắc', 'cửa hướng Đông', 'cửa hướng Bắc', null::jsonb, '"Trừ cửa hướng Bắc, các cửa khác đều có tên riêng."', 'doc_hieu', 49::int),
    (3::smallint, 'multiple_choice', '"Rễ cây nổi lên mặt đất thành những hình thù quái lạ, như những con rắn hổ mang giận dữ."
Bộ phận nào của cây đa được so sánh với những con rắn hổ mang?', 'rễ cây', 'cành cây', 'ngọn cây', null, 'rễ cây', null::jsonb, 'Rễ cây đa nổi lên như những con rắn hổ mang.', 'doc_hieu', 50::int),
    (3::smallint, 'multiple_choice', '"Loại quả này lúc còn xanh thì rất chát nhưng khi chín lại giòn và ngọt."
Cặp từ trái nghĩa trong câu là:', 'xanh – giòn', 'chát – ngọt', 'còn – lại', null, 'chát – ngọt', null::jsonb, 'Vị chát trái với vị ngọt.', 'tu_trai_nghia', 51::int),
    (3::smallint, 'multiple_choice', 'Bộ phận "róc rách" trong câu "Nước chảy róc rách trong khe núi." trả lời cho câu hỏi nào?', 'Ở đâu?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', 'Như thế nào?', null::jsonb, '"Róc rách" tả tiếng nước chảy, hỏi bằng "Như thế nào?".', 'cau_hoi_nhu_the_nao', 51::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 34 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');

-- Tiếng Việt • Tuần 35: Ôn tập cuối học kì II – Đọc hiểu, chính tả, dấu câu, đặt câu hỏi (31 câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, 35, 100, 'Archimes: Ôn tập cuối học kì II – Đọc hiểu, chính tả, dấu câu, đặt câu hỏi', 'Ngân hàng Archimes — Tiếng Việt 2 - Quyển 4, tuần 35', true, 'week' from public.subjects where code = 'tieng_viet'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, 'Archimes', v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = 'tieng_viet'
  cross join (values
    (1::smallint, 'text', 'Tìm chữ viết sai chính tả và viết lại cho đúng:
"Mặt xông vẫn bập bềnh sóng vỗ."', null, null, null, null, 'sông', null::jsonb, '"Mặt sông" viết s.', 'chinh_ta_sua_loi', 53::int),
    (1::smallint, 'text', 'Tìm chữ viết sai chính tả và viết lại cho đúng:
"Đến rờ đua, ba hồi trống vang lên dõng dạc."', null, null, null, null, 'giờ', null::jsonb, '"Giờ đua" viết gi.', 'chinh_ta_sua_loi', 53::int),
    (1::smallint, 'text', 'Tìm chữ viết sai chính tả và viết lại cho đúng:
"Bên bờ sông, chống thúc tiếp, người ta la hét, cổ vũ."', null, null, null, null, 'trống', null::jsonb, '"Tiếng trống" viết tr.', 'chinh_ta_sua_loi', 53::int),
    (1::smallint, 'text', 'Tìm chữ viết sai chính tả và viết lại cho đúng:
"Các em nhỏ cũng hò gieo vui mừng."', null, null, null, null, 'reo', null::jsonb, '"Hò reo" viết r.', 'chinh_ta_sua_loi', 53::int),
    (1::smallint, 'multiple_choice', 'Trong truyện "Loài chim học làm tổ", loài chim nào trở thành loài xây tổ đẹp nhất?', 'Sẻ', 'Quạ', 'Én', 'Cú', 'Én', null::jsonb, 'Nhờ chăm chỉ học đến cùng, Én xây tổ đẹp nhất.', 'doc_hieu', 53::int),
    (1::smallint, 'multiple_choice', '"Gấu bố ( ) gấu mẹ ( ) gấu con cùng béo rung rinh."
Cần điền dấu gì vào các chỗ ( )?', 'dấu chấm', 'dấu phẩy', 'dấu chấm hỏi', null, 'dấu phẩy', null::jsonb, 'Dấu phẩy ngăn cách các từ cùng loại đứng liền nhau.', 'dau_phay', 54::int),
    (1::smallint, 'multiple_choice', 'Bộ phận "Khi có nắng" trong câu "Khi có nắng, những bông hoa hướng dương càng ánh lên sắc vàng tươi." trả lời cho câu hỏi nào?', 'Khi nào?', 'Ở đâu?', 'Vì sao?', 'Để làm gì?', 'Khi nào?', null::jsonb, '"Khi có nắng" chỉ thời gian.', 'cau_hoi_khi_nao', 56::int),
    (1::smallint, 'multiple_choice', 'Bộ phận "trong một lùm cây" trong câu "Đôi chim cần mẫn tha rơm rác về làm tổ trong một lùm cây." trả lời cho câu hỏi nào?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', 'Ở đâu?', 'Ở đâu?', null::jsonb, '"Trong một lùm cây" chỉ nơi chốn.', 'cau_hoi_o_dau', 56::int),
    (1::smallint, 'text', 'Điền s hoặc x:
"Lông cánh nó ___anh biếc"', null, null, null, null, 'x', null::jsonb, 'Màu xanh viết x.', 'chinh_ta_s_x', 58::int),
    (1::smallint, 'text', 'Điền s hoặc x:
"Nó thu mình trên cành tre, đầu cúi xuống như kiểu ___oi gương."', null, null, null, null, 's', null::jsonb, 'Soi gương viết s.', 'chinh_ta_s_x', 58::int),
    (1::smallint, 'multiple_choice', '"Mưa đá. Một cục nước đá trắng tinh rơi bộp xuống đất. Dòng nước dang rộng tay nói: – Chào bạn! Mời bạn nhập vào với chúng tôi!"
Lúc đầu, trông thấy cục nước đá, dòng nước đã làm gì?', 'cười xoà rồi chảy ra sông, ra biển', 'dang tay, mời cục nước đá nhập dòng chảy', 'lạnh lùng chào rồi chảy đi', null, 'dang tay, mời cục nước đá nhập dòng chảy', null::jsonb, 'Dòng nước dang rộng tay mời cục nước đá nhập vào.', 'doc_hieu', 55::int),
    (2::smallint, 'multiple_choice', 'Cách viết đúng của cụm từ "dập rềnh chên mặt nước" là:', 'giập giềnh trên mặt nước', 'dập dềnh chên mặt nước', 'dập rềnh trên mặt nước', 'dập dềnh trên mặt nước', 'dập dềnh trên mặt nước', null::jsonb, 'Dập dềnh (d – d), trên (tr).', 'chinh_ta_sua_loi', 53::int),
    (2::smallint, 'text', 'Tìm chữ viết sai chính tả và viết lại cho đúng:
"Các em nhỏ được bố công cênh trên vai."', null, null, null, null, 'kênh', null::jsonb, '"Công kênh" viết k vì đứng trước ê.', 'chinh_ta_sua_loi', 53::int),
    (2::smallint, 'multiple_choice', '"Phượng Hoàng giảng: – Trước hết phải tìm trên cây chỗ nào có chạc ba… Sau đó lấy mỏ quặp những cành khoẻ, uốn cong lại, đan thành một cái khung… Sau khi bện xong khung, rải bên trong một ít rơm rác mịn, sạch."
Bài giảng của Phượng Hoàng như thế nào?', 'chính xác, từng bước mạch lạc, dễ học', 'dài dòng, rắc rối, rất khó học', 'không đúng phương pháp làm tổ', null, 'chính xác, từng bước mạch lạc, dễ học', null::jsonb, 'Phượng Hoàng dạy lần lượt từng bước rõ ràng.', 'doc_hieu', 52::int),
    (2::smallint, 'multiple_choice', '"Gà mới nghe thế đã bắt đầu gật gà gật gù, sau đó ngủ khò khò luôn."
Kết quả của Gà là gì?', 'trở thành loài xây tổ đẹp nhất', 'phải sống nhờ những hốc cây tăm tối', 'chả nhớ gì, loài người phải làm tổ sẵn cho', 'tổ xấu xí, luộm thuộm', 'chả nhớ gì, loài người phải làm tổ sẵn cho', null::jsonb, 'Gà ngủ gật nên chả nhớ gì, người phải làm tổ cho.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', '"Cú nghĩ cái anh chàng đẹp mã này thì dạy nổi ai việc gì nên cười rộ lên khinh bỉ rồi bay đi."
Vì không học, Cú phải chịu kết quả gì?', 'tổ xấu xí, luộm thuộm', 'loài người phải làm tổ sẵn cho', 'phải sống nhờ những hốc cây tăm tối', 'xây được tổ đẹp nhất', 'phải sống nhờ những hốc cây tăm tối', null::jsonb, 'Cú không biết làm tổ nên sống nhờ hốc cây.', 'doc_hieu', 53::int),
    (2::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "để dạy các loài chim về cách làm tổ" trong câu "Phượng Hoàng mở lớp học để dạy các loài chim về cách làm tổ." là:', 'Vì sao Phượng Hoàng mở lớp học?', 'Phượng Hoàng mở lớp học như thế nào?', 'Ai mở lớp học?', 'Phượng Hoàng mở lớp học để làm gì?', 'Phượng Hoàng mở lớp học để làm gì?', null::jsonb, 'Bộ phận chỉ mục đích hỏi bằng "để làm gì?".', 'cau_hoi_de_lam_gi', 54::int),
    (2::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "rất khéo" trong câu "Phượng Hoàng làm tổ rất khéo." là:', 'Phượng Hoàng làm tổ như thế nào?', 'Phượng Hoàng làm tổ để làm gì?', 'Vì sao Phượng Hoàng làm tổ?', 'Phượng Hoàng làm tổ ở đâu?', 'Phượng Hoàng làm tổ như thế nào?', null::jsonb, '"Rất khéo" tả đặc điểm, hỏi bằng "như thế nào?".', 'cau_hoi_nhu_the_nao', 54::int),
    (2::smallint, 'multiple_choice', '"Cục nước đá đáp lại lạnh lùng: – Các anh đục ngầu, bẩn thỉu như thế, tôi hoà nhập với các anh sao được? Trời cao kia mới là bạn của tôi!"
Vì sao cục nước đá không nhập vào dòng nước?', 'Vì nó chê dòng nước nhỏ bé', 'Vì nó chê dòng nước đục ngầu, bẩn thỉu', 'Vì nó sợ làm bẩn dòng nước', null, 'Vì nó chê dòng nước đục ngầu, bẩn thỉu', null::jsonb, 'Cục nước đá chê dòng nước đục ngầu, bẩn thỉu.', 'doc_hieu', 55::int),
    (2::smallint, 'multiple_choice', '"Dòng nước cười xoà rồi ào ào chảy ra sông, ra biển. Cục nước đá trơ lại một mình, lúc sau thì tan ra, ướt nhoẹt ở một góc sân."
Cuối cùng, cục nước đá thế nào?', 'trơ lại một mình, tan ra, ướt nhoẹt ở góc sân', 'tự chảy thành một dòng riêng', 'bị dòng nước cuốn ra sông, ra biển', null, 'trơ lại một mình, tan ra, ướt nhoẹt ở góc sân', null::jsonb, 'Cục nước đá cô đơn rồi tan ra ở góc sân.', 'doc_hieu', 55::int),
    (2::smallint, 'multiple_choice', 'Bộ phận "Vì có sải cánh lớn" trong câu "Vì có sải cánh lớn, hải âu có thể bay rất xa." trả lời cho câu hỏi nào?', 'Để làm gì?', 'Như thế nào?', 'Khi nào?', 'Vì sao?', 'Vì sao?', null::jsonb, 'Bộ phận bắt đầu bằng "Vì" chỉ nguyên nhân.', 'cau_hoi_vi_sao', 56::int),
    (2::smallint, 'multiple_choice', '"Cẩm chướng, huệ và hồng nhung thấy râm bụt thì coi thường."
Truyện "Hoa râm bụt" nhắc đến những loài hoa nào?', 'râm bụt, huệ, cẩm chướng, cúc', 'cẩm chướng, hồng nhung, râm bụt, lan', 'râm bụt, huệ, hồng nhung, cẩm chướng', null, 'râm bụt, huệ, hồng nhung, cẩm chướng', null::jsonb, 'Truyện có râm bụt, cẩm chướng, huệ và hồng nhung.', 'doc_hieu', 57::int),
    (2::smallint, 'multiple_choice', '"Chị ơi, chúng em tô điểm cho vườn của chị đẹp lộng lẫy. Còn râm bụt chẳng có sắc hương, vậy mà chị trồng lẫn với chúng em." Chủ vườn nghe vậy bèn chặt hết râm bụt.
Vì sao chủ vườn chặt hết râm bụt?', 'Vì hoa râm bụt bị héo, không đẹp', 'Vì các loài hoa khác chê râm bụt', 'Vì râm bụt làm xấu cả vườn hoa', null, 'Vì các loài hoa khác chê râm bụt', null::jsonb, 'Chủ vườn nghe lời chê của các loài hoa khác.', 'doc_hieu', 57::int),
    (3::smallint, 'multiple_choice', '"Quạ không nghe giảng đến đầu đến cuối nên tổ của nó xấu xí, luộm thuộm."
Vì sao tổ của Quạ xấu xí, luộm thuộm?', 'Vì Quạ ngủ gật trong giờ học.', 'Vì Quạ không nghe giảng đến đầu đến cuối.', 'Vì Quạ cười khinh bỉ rồi bay đi.', null, 'Vì Quạ không nghe giảng đến đầu đến cuối.', null::jsonb, 'Quạ chen ngang rồi bay đi, không học hết bài.', 'doc_hieu', 53::int),
    (3::smallint, 'multiple_choice', '"Nhà gấu ở trong rừng ( ) mùa xuân ( ) cả nhà gấu kéo nhau đi bẻ măng và uống mật ong."
Dấu câu lần lượt điền vào hai chỗ ( ) là (chữ sau dấu chấm phải viết hoa):', 'dấu phẩy, dấu chấm', 'dấu phẩy, dấu phẩy', 'dấu chấm, dấu chấm', 'dấu chấm, dấu phẩy', 'dấu chấm, dấu phẩy', null::jsonb, 'Nhà gấu ở trong rừng. Mùa xuân, cả nhà gấu kéo nhau đi bẻ măng…', 'dau_cham_dau_phay', 54::int),
    (3::smallint, 'multiple_choice', 'Bộ phận "lạnh lùng" trong câu "Cục nước đá đáp lại lạnh lùng." trả lời cho câu hỏi nào?', 'Như thế nào?', 'Vì sao?', 'Để làm gì?', null, 'Như thế nào?', null::jsonb, '"Lạnh lùng" tả cách cục nước đá đáp lại.', 'cau_hoi_nhu_the_nao', 55::int),
    (3::smallint, 'multiple_choice', 'Câu chuyện "Cục nước đá" khuyên chúng ta điều gì?', 'Nên chảy ra sông, ra biển', 'Không nên ra ngoài khi trời mưa đá', 'Không nên kiêu căng, coi thường người khác', null, 'Không nên kiêu căng, coi thường người khác', null::jsonb, 'Cục nước đá kiêu căng, chê bạn nên cuối cùng cô đơn và tan biến.', 'doc_hieu', 55::int),
    (3::smallint, 'multiple_choice', '"Vắng hàng râm bụt, gió tự do hoành hành. Hắn xô đẩy, đùa giỡn làm các loài hoa ngả nghiêng, run rẩy."
Điều gì xảy ra khi trong vườn không còn râm bụt?', 'Vườn hoa trở nên lộng lẫy hơn', 'Các loài hoa bị nắng làm héo úa', 'Gió xô đẩy làm các loài hoa ngả nghiêng, run rẩy', null, 'Gió xô đẩy làm các loài hoa ngả nghiêng, run rẩy', null::jsonb, 'Không có râm bụt che chắn, gió dập vùi hoa lá.', 'doc_hieu', 57::int),
    (3::smallint, 'multiple_choice', 'Câu chuyện "Hoa râm bụt" muốn nói lên điều gì?', 'Mỗi cây hoa đều có ích, không thể coi thường.', 'Không phải cây hoa nào cũng có ích.', 'Gió luôn là kẻ thù của các cây hoa.', null, 'Mỗi cây hoa đều có ích, không thể coi thường.', null::jsonb, 'Râm bụt không rực rỡ nhưng che chắn gió cho cả vườn.', 'doc_hieu', 58::int),
    (3::smallint, 'multiple_choice', 'Bộ phận "uy nghi mà gần gũi" trong câu "Trên quảng trường Ba Đình lịch sử, lăng Bác uy nghi mà gần gũi." trả lời cho câu hỏi nào?', 'Ở đâu?', 'Như thế nào?', 'Khi nào?', 'Vì sao?', 'Như thế nào?', null::jsonb, '"Uy nghi mà gần gũi" tả đặc điểm của lăng Bác.', 'cau_hoi_nhu_the_nao', 58::int),
    (3::smallint, 'multiple_choice', 'Câu hỏi đúng cho bộ phận "Vì động lòng thương các loài hoa trong vườn" trong câu "Vì động lòng thương các loài hoa trong vườn, những gốc râm bụt cố đâm chồi lên mặt đất." là:', 'Những gốc râm bụt cố đâm chồi để làm gì?', 'Những gốc râm bụt đâm chồi như thế nào?', 'Khi nào những gốc râm bụt đâm chồi?', 'Vì sao những gốc râm bụt cố đâm chồi lên mặt đất?', 'Vì sao những gốc râm bụt cố đâm chồi lên mặt đất?', null::jsonb, 'Bộ phận chỉ nguyên nhân hỏi bằng "Vì sao?".', 'cau_hoi_vi_sao', 58::int)
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = 35 and l.lesson_order = 100
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');
