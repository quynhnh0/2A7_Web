# CLASS 2 LEARNING WEB — PRODUCT & TECHNICAL SPEC

## 1. Mục tiêu sản phẩm

Xây dựng một website học tập đơn giản cho học sinh lớp 2, phục vụ một lớp học khoảng 30–50 học sinh.

Mục tiêu chính:

- Học sinh có thể vào website và làm bài nhanh, không cần tạo tài khoản/phải nhớ mật khẩu.
- Nội dung bài tập bám theo bộ sách lớp 2 có sẵn.
- Question Bank được tổ chức theo:
  - Môn học
  - Tuần học
  - Buổi học / bài học
  - Độ khó
- Có bài cơ bản và bài nâng cao.
- Hỗ trợ các dạng câu hỏi:
  - Trắc nghiệm
  - Điền số
  - Điền chữ
- Có bảng xếp hạng:
  - Theo ngày
  - Theo tuần
  - Theo tháng
- Có một tài khoản Admin để:
  - Quản lý học sinh
  - Quản lý bài học
  - Quản lý Question Bank
  - Import câu hỏi từ CSV/Excel
  - Publish / Unpublish bài
  - Chọn tuần hiện tại
  - Có thể schedule bài theo ngày nếu cần
  - Theo dõi kết quả học sinh
- Ưu tiên:
  - Chi phí gần 0
  - Không phải vận hành VPS/server riêng
  - Dễ code bằng Cursor/Claude Code
  - Dễ mở rộng sau này
  - UX cực đơn giản cho học sinh lớp 2

---

# 2. Quy mô dự kiến

Quy mô ban đầu:

- 1 lớp
- Khoảng 30–50 học sinh
- 1–3 Admin
- Khoảng 10–30 câu/học sinh/ngày
- Khoảng vài chục nghìn lượt trả lời/tháng

Hệ thống phải được thiết kế đủ tốt để sau này có thể mở rộng lên:

- Nhiều lớp
- Nhiều môn
- Nhiều năm học
- Hàng trăm học sinh

Nhưng MVP không được over-engineer.

---

# 3. Kiến trúc đề xuất

## 3.1 Stack

### Frontend

- React
- TypeScript
- Vite
- Tailwind CSS

### Hosting

- Cloudflare Pages
- Free tier

### Backend

- Supabase Edge Functions

### Database

- Supabase PostgreSQL

### Authentication

Admin:

- Supabase Auth
- Email + Password

Student:

- Không cần tài khoản/password

### Storage

- Supabase Storage
- Chỉ dùng nếu sau này cần:
  - ảnh câu hỏi
  - file import
  - hình minh họa

### Source Control

- GitHub hoặc GitLab

---

# 4. Kiến trúc tổng thể

```text
                        ┌─────────────────────┐
                        │   Cloudflare Pages  │
                        │ React / Vite / TS   │
                        │        FREE         │
                        └──────────┬──────────┘
                                   │
                 ┌─────────────────┴──────────────────┐
                 │                                    │
              STUDENT                               ADMIN
                 │                                    │
         Không cần login                       Email + Password
                 │                                    │
                 └───────────────┬────────────────────┘
                                 │
                         Supabase Edge Functions
                                 │
                     ┌───────────┼───────────┐
                     │           │           │
                  Scoring     Security    Ranking
                     │           │           │
                     └───────────┼───────────┘
                                 │
                         Supabase PostgreSQL
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
     Students                Curriculum               Attempts
        │                        │                        │
        └────────────── Question Bank ────────────────┘
                                 │
                           Leaderboards
                       Day / Week / Month
```

---

# 5. Nguyên tắc UX

Đối tượng chính là học sinh lớp 2.

UI phải:

- chữ lớn
- nút lớn
- ít text
- ít menu
- không có nhiều setting
- mỗi màn hình tập trung vào một hành động chính
- tránh thiết kế giống LMS phức tạp
- ưu tiên mobile/tablet nhưng vẫn chạy tốt trên desktop

Nguyên tắc:

```text
1 màn hình
=
1 việc cần làm
```

---

# 6. Student Identity — không đăng nhập

## 6.1 Không cho học sinh tự tạo account

Không yêu cầu:

- Email
- Password
- Số điện thoại

## 6.2 Không nên cho nhập tên tự do mỗi lần

Admin import danh sách học sinh trước.

Ví dụ:

```text
STT | Họ tên
1   | Nguyễn Minh Anh
2   | Trần Gia Huy
3   | Lê Hà My
```

Lần đầu học sinh vào website:

```text
Nhập họ tên:
[ Nguyễn Minh Anh ]
```

Hệ thống search trong danh sách.

Học sinh chọn đúng tên.

Sau khi chọn:

```text
student_id
device_token
```

được lưu vào LocalStorage.

Lần sau mở website:

```text
Xin chào Minh Anh
```

Không cần chọn lại.

## 6.3 Lý do

Nếu cho nhập tên tự do:

```text
Nguyễn Minh Anh
nguyen minh anh
Minh Anh
Nguyễn Minh Anh 
```

có thể bị hiểu thành nhiều user khác nhau.

Roster cố định giúp:

- tránh duplicate
- leaderboard chính xác hơn
- dễ tracking tiến bộ
- dễ thống kê

---

# 7. Student Home

Ví dụ:

```text
────────────────────────────

           LỚP 2A1

       Xin chào Minh Anh

HÔM NAY

🟢 Toán cơ bản
10 câu

[ LÀM BÀI ]

🔥 Thử thách nâng cao
5 câu

[ THỬ SỨC ]

────────────────────────────

🏆 XẾP HẠNG

[ Ngày ] [ Tuần ] [ Tháng ]

1. Minh Anh      950
2. Gia Huy       900
3. Hà My         850

────────────────────────────
```

Ngoài phần "Hôm nay", có thể có:

```text
BÀI CỦA TUẦN
```

và list bài được Admin publish.

---

# 8. Curriculum Structure

Question Bank không tổ chức đơn thuần theo môn + độ khó.

Cấu trúc chuẩn:

```text
BOOK
└── SUBJECT
    └── WEEK
        └── LESSON
            ├── EASY
            ├── NORMAL
            └── ADVANCED
```

Ví dụ:

```text
Toán lớp 2

├── Tuần 1
│   ├── Bài 1: Ôn tập các số đến 100
│   ├── Bài 2: Tia số
│   └── Bài 3: Số liền trước, số liền sau
│
├── Tuần 2
│   ├── Bài 4: Phép cộng
│   ├── Bài 5: Phép trừ
│   └── Bài 6: Luyện tập
│
└── ...
```

---

# 9. Tách Curriculum và Schedule

Không gắn Question trực tiếp với ngày học.

Kiến trúc:

```text
BOOK
↓
CURRICULUM
↓
LESSON
↓
QUESTION BANK
↓
SCHEDULE / PUBLISH
```

Lợi ích:

Một bài trong sách là dữ liệu cố định.

Ví dụ:

```text
Bài 15
Phép cộng có tổng bằng 10
```

Năm học này có thể học ngày:

```text
17/10
```

Năm sau:

```text
15/10
```

Question Bank không phải tạo lại.

Chỉ đổi schedule.

---

# 10. Question Types

MVP hỗ trợ 3 loại.

## 10.1 Multiple Choice

Ví dụ:

```text
12 + 8 = ?

○ 18
○ 19
○ 20
○ 21
```

Data:

```json
{
  "type": "multiple_choice",
  "question": "12 + 8 = ?",
  "options": ["18", "19", "20", "21"],
  "answer": "20"
}
```

---

## 10.2 Number Input

```text
17 + ___ = 25

[       ]
```

Data:

```json
{
  "type": "number",
  "question": "17 + ___ = 25",
  "answer": "8"
}
```

---

## 10.3 Text Input

```text
Điền từ thích hợp:

Con mèo đang ____ trên ghế.

[           ]
```

Data:

```json
{
  "type": "text",
  "question": "Con mèo đang ____ trên ghế.",
  "answer": "nằm"
}
```

Text answer cần normalize:

- trim whitespace
- lowercase
- optional Vietnamese normalization rule nếu cần
- có thể hỗ trợ nhiều đáp án hợp lệ

Ví dụ:

```json
{
  "accepted_answers": [
    "nằm",
    "đang nằm"
  ]
}
```

---

# 11. Difficulty

Mỗi câu có difficulty:

```text
1 = EASY
2 = NORMAL
3 = ADVANCED
```

Không cần tạo hệ thống riêng cho bài dễ và bài khó.

Ví dụ:

```json
{
  "difficulty": 2
}
```

---

# 12. Question Bank

Mỗi Lesson có Question Bank riêng.

Ví dụ:

```text
Bài 12 - Phép cộng có nhớ

Easy       30 câu
Normal     30 câu
Advanced   20 câu

TOTAL      80 câu
```

Khi học sinh làm một bài 10 câu:

```text
6 Easy
3 Normal
1 Advanced
```

Nếu chọn:

```text
THỬ THÁCH NÂNG CAO
```

có thể dùng:

```text
2 Easy
3 Normal
5 Advanced
```

Tỷ lệ này phải configurable.

---

# 13. Question Schema

Đề xuất bảng:

```text
questions
```

Fields:

```text
id
subject_id
lesson_id
grade

difficulty
question_type

question_text

option_a
option_b
option_c
option_d

correct_answer
accepted_answers_json

explanation
points

source_book
source_page

is_active

created_at
updated_at
```

Có thể bổ sung:

```text
skill_tag
topic_tag
generator_type
```

---

# 14. Metadata cho Question sinh từ sách

Ví dụ:

```json
{
  "subject": "math",
  "grade": 2,

  "week": 3,
  "lesson_order": 2,

  "lesson_id": "math_w3_l2",
  "lesson_name": "Phép cộng có nhớ trong phạm vi 100",

  "difficulty": 2,

  "question_type": "number",

  "question": "27 + 18 = ?",

  "answer": "45",

  "source_page": 37
}
```

---

# 15. Tạo Question Bank từ bộ sách

Input:

- PDF
- ảnh
- scan
- file Word
- file Excel

Pipeline:

```text
BOOK
↓
Extract structure
↓
Subject
↓
Week
↓
Lesson
↓
Learning Objective / Skill
↓
Question Templates
↓
Generate Questions
↓
Quality Check
↓
Question Bank
```

---

# 16. Không nên copy nguyên câu hỏi sách

Mục tiêu là đọc nội dung sách để hiểu:

- kiến thức
- dạng bài
- learning objective
- độ khó
- skill

Sau đó sinh câu hỏi mới cùng dạng.

Ví dụ sách có:

```text
7 + 3 = ?
6 + 4 = ?
8 + 2 = ?
```

Hệ thống xác định skill:

```text
Hai số có tổng bằng 10
```

Sau đó sinh thêm:

```text
4 + 6 = ?
3 + 7 = ?
2 + 8 = ?
5 + 5 = ?
1 + 9 = ?
```

Nâng cao hơn:

```text
4 + ? = 10
? + 7 = 10
```

Word problem:

```text
Lan có 4 quả táo.
Mẹ cho thêm một số quả.
Lan có tất cả 10 quả.

Mẹ đã cho Lan bao nhiêu quả?
```

---

# 17. Không cần AI cho toàn bộ Question Generator

Đặc biệt với Toán lớp 2, nên ưu tiên deterministic generator.

Ví dụ:

```python
a = random.randint(1, 50)
b = random.randint(1, 50-a)

question = f"{a} + {b} = ?"
answer = a + b
```

Ưu điểm:

- không tốn API
- đáp án chắc chắn đúng
- kiểm soát difficulty chính xác
- sinh được số lượng lớn

Ví dụ rule:

```text
EASY:
a + b <= 20

NORMAL:
a + b <= 100

ADVANCED:
a + ? = c
```

AI chỉ nên dùng khi thật sự cần:

- Tiếng Việt
- câu đọc hiểu
- câu diễn đạt
- tạo biến thể ngôn ngữ

---

# 18. Lesson

Schema đề xuất:

```text
lessons

id
subject_id
week_number
lesson_order

name
description

is_published

available_from
available_until

created_at
updated_at
```

Ví dụ:

```text
week_number = 5
lesson_order = 3
name = Phép cộng có nhớ
```

---

# 19. Publish Model

Version đầu ưu tiên:

```text
Week
→ Lesson
→ Publish / Unpublish
```

Admin có thể:

```text
✓ Bài 1
✓ Bài 2
○ Bài 3
```

Học sinh chỉ nhìn thấy bài được publish.

---

# 20. Schedule

Không bắt buộc ở MVP nhưng database phải support ngay từ đầu.

Fields:

```text
available_from
available_until
```

Admin có thể chọn:

```text
Publish Mode:

○ Luôn hiển thị
● Theo tuần
○ Theo ngày
```

Ví dụ:

```text
available_from = 2026-10-05 00:00
available_until = 2026-10-06 23:59
```

---

# 21. Week Mode

Admin có một setting:

```text
Current Week = 5
```

Website tự hiển thị:

```text
TUẦN 5

Bài 18
Bài 19
Bài 20
Bài 21
```

Đây là mode ưu tiên cho MVP vì đơn giản.

---

# 22. Exercise Generation

Một Lesson không nhất thiết tương ứng với một bộ câu cố định.

Có thể generate exercise động từ Question Bank.

Ví dụ:

```text
Lesson Question Bank
80 questions
↓
Student starts
↓
Random selection
↓
10 questions
```

Rule:

```text
6 Easy
3 Normal
1 Advanced
```

Nên random theo:

- difficulty
- skill
- chưa gặp gần đây nếu có thể

---

# 23. Exercise Attempts

Bảng:

```text
attempts
```

Fields:

```text
id
student_id
lesson_id
exercise_type

score
correct_count
wrong_count
total_questions

duration_seconds

started_at
completed_at

is_ranked
```

---

# 24. Answer Detail

Bảng:

```text
attempt_answers
```

Fields:

```text
id
attempt_id
question_id

student_answer
is_correct

score_awarded

answered_at
```

Lợi ích:

- biết câu nào sai nhiều
- phân tích skill yếu
- tạo adaptive learning sau này

---

# 25. Server-side Scoring

Không cho frontend tự gửi score.

SAI:

```json
POST /score

{
  "student": "Minh Anh",
  "score": 999999
}
```

ĐÚNG:

Frontend gửi:

```json
{
  "attempt_id": "...",
  "question_id": "...",
  "answer": "45"
}
```

Backend:

```text
Receive answer
↓
Fetch correct answer from DB
↓
Check answer
↓
Calculate score
↓
Save result
↓
Return result
```

Student client không được phép tự ghi:

```text
score
ranking
correct_answer
```

---

# 26. Leaderboard

Có 3 tab:

```text
Ngày
Tuần
Tháng
```

---

# 27. Leaderboard Scoring

Không nên dùng:

```text
Ai làm nhiều bài nhất = đứng đầu
```

vì sẽ khuyến khích spam.

Đề xuất:

```text
Easy     +10
Normal   +15
Advanced +25

Wrong     +0
```

Có thể thêm:

```text
Completion bonus
Streak bonus
Accuracy bonus
```

nhưng MVP chưa cần.

---

# 28. Chống spam leaderboard

Mỗi lesson/exercise chỉ tính **attempt đầu tiên** vào ranking.

Ví dụ:

```text
Attempt #1
→ ranked

Attempt #2
→ practice only

Attempt #3
→ practice only
```

Học sinh vẫn được làm lại để luyện tập.

Nhưng không farm leaderboard.

---

# 29. Leaderboard Query

Không cần lưu bảng:

```text
daily_rank
weekly_rank
monthly_rank
```

Có thể tính từ Attempt.

Ví dụ:

```sql
SELECT
  student_id,
  SUM(score)
FROM attempts
WHERE
  is_ranked = true
  AND completed_at >= :start
  AND completed_at < :end
GROUP BY student_id
ORDER BY SUM(score) DESC;
```

---

# 30. Timezone

Hệ thống dùng timezone:

```text
Asia/Bangkok
```

hoặc configurable.

Ranking ngày phải reset theo local timezone.

Tuần:

```text
Monday → Sunday
```

Tháng:

```text
Ngày 1 → ngày cuối tháng
```

---

# 31. Student Result

Sau khi hoàn thành:

```text
HOÀN THÀNH!

8 / 10 câu đúng

Điểm:
95

[ Xem câu sai ]

[ Làm lại ]
```

Không cần UI phức tạp.

---

# 32. Admin Authentication

Admin bắt buộc đăng nhập.

```text
/admin/login

Email
Password
```

Dùng:

```text
Supabase Auth
```

Student không dùng Supabase Auth.

---

# 33. Admin Dashboard

Menu:

```text
Dashboard

├── Students
├── Subjects
├── Curriculum
├── Lessons
├── Question Bank
├── Import Questions
├── Publish / Schedule
├── Results
├── Leaderboard
└── Settings
```

---

# 34. Admin — Students

Chức năng:

- Add student
- Edit student
- Disable student
- Import CSV
- Import Excel
- Search
- Sort

Schema:

```text
students

id
class_id
full_name
display_name
is_active

created_at
updated_at
```

---

# 35. Admin — Curriculum UI

Ví dụ:

```text
CURRICULUM

Toán lớp 2

▼ Tuần 1

   ✓ Bài 1: Ôn tập các số đến 100
   ✓ Bài 2: Tia số
   ✓ Bài 3: Số liền trước

▼ Tuần 2

   ✓ Bài 4: Phép cộng
   ○ Bài 5: Phép trừ
   ○ Bài 6: Luyện tập
```

Legend:

```text
✓ Published
○ Unpublished
```

---

# 36. Lesson Admin

Click một bài:

```text
Bài 4: Phép cộng
────────────────────

Question Bank: 73 câu

Easy       30
Normal     28
Advanced   15

[ Preview Questions ]

Publish:

○ Always Visible
● By Week
○ By Date

Week:
2

[ SAVE ]
```

---

# 37. Question Bank Admin

Admin cần:

- list questions
- filter
- search
- edit
- delete
- disable
- preview

Filter:

```text
Subject
Week
Lesson
Difficulty
Question Type
Skill Tag
```

---

# 38. Import Question Bank

Hỗ trợ CSV trước.

Excel có thể convert/import sau.

Format:

```text
subject
week
lesson
lesson_name
difficulty
type
question
option_a
option_b
option_c
option_d
answer
explanation
source_page
```

Ví dụ:

```text
math,1,1,Ôn tập,1,multiple_choice,8+7=?,13,14,15,16,15,,12
```

---

# 39. Import Validation

Khi import:

```text
Upload
↓
Parse
↓
Validate
↓
Preview
↓
Confirm
↓
Insert
```

Validation:

- lesson tồn tại
- type hợp lệ
- difficulty hợp lệ
- answer không rỗng
- MCQ phải có options
- answer phải nằm trong options nếu là MCQ
- duplicate detection

---

# 40. Dashboard Analytics

MVP Admin Dashboard:

```text
Today

Students active:
28 / 35

Exercises completed:
45

Average accuracy:
82%

Questions answered:
420
```

---

# 41. Lesson Analytics

Ví dụ:

```text
Bài 15 — Phép cộng có nhớ

32 học sinh đã làm

Điểm trung bình:
8.2 / 10

Accuracy:
82%
```

---

# 42. Hardest Questions

Admin có thể xem:

```text
Câu sai nhiều nhất

27 + 18 = ?

11 / 32 học sinh sai
```

Query từ:

```text
attempt_answers
```

---

# 43. Student Progress

Có thể thống kê:

```text
Student: Minh Anh

7 ngày gần nhất

Accuracy:
82%

Lessons completed:
8

Strong:
- Addition

Needs practice:
- Carry addition
```

MVP có thể chỉ hiển thị:

- số bài đã làm
- điểm trung bình
- accuracy

---

# 44. Adaptive Learning — Future

Không cần làm MVP.

Sau này:

```text
Student repeatedly fails skill X
↓
System detects
↓
Next exercise adds more questions from skill X
```

Ví dụ:

```text
Mai sai nhiều phép cộng có nhớ
↓
Ngày hôm sau
↓
Thêm 2 câu phép cộng có nhớ
```

---

# 45. Database Entities

Core entities:

```text
classes
students

subjects
books
lessons

questions

attempts
attempt_answers

app_settings
```

Optional later:

```text
skills
question_tags
achievements
student_badges
```

---

# 46. Suggested Database Schema

## classes

```text
id UUID PK
name TEXT
grade INT
school_year TEXT
is_active BOOLEAN
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## students

```text
id UUID PK
class_id UUID FK
full_name TEXT
display_name TEXT
is_active BOOLEAN
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## subjects

```text
id UUID PK
name TEXT
code TEXT
grade INT
created_at TIMESTAMP
```

---

## books

```text
id UUID PK
subject_id UUID FK
name TEXT
publisher TEXT
school_year TEXT
created_at TIMESTAMP
```

---

## lessons

```text
id UUID PK

book_id UUID FK
subject_id UUID FK

week_number INT
lesson_order INT

name TEXT
description TEXT

is_published BOOLEAN

available_from TIMESTAMP NULL
available_until TIMESTAMP NULL

created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## questions

```text
id UUID PK

lesson_id UUID FK
subject_id UUID FK

difficulty SMALLINT

question_type TEXT

question_text TEXT

option_a TEXT NULL
option_b TEXT NULL
option_c TEXT NULL
option_d TEXT NULL

correct_answer TEXT

accepted_answers JSONB NULL

explanation TEXT NULL

points INT

skill_tag TEXT NULL

source_book TEXT NULL
source_page INT NULL

is_active BOOLEAN

created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## attempts

```text
id UUID PK

student_id UUID FK
lesson_id UUID FK

exercise_type TEXT

score INT

correct_count INT
wrong_count INT
total_questions INT

duration_seconds INT

is_ranked BOOLEAN

started_at TIMESTAMP
completed_at TIMESTAMP
```

---

## attempt_answers

```text
id UUID PK

attempt_id UUID FK
question_id UUID FK

student_answer TEXT

is_correct BOOLEAN

score_awarded INT

answered_at TIMESTAMP
```

---

## app_settings

```text
id UUID PK

current_week INT

timezone TEXT

leaderboard_enabled BOOLEAN

created_at TIMESTAMP
updated_at TIMESTAMP
```

---

# 47. Row Level Security

Supabase RLS phải bật.

Student browser:

- không được quyền trực tiếp UPDATE score
- không được trực tiếp INSERT attempt result nếu bypass server
- không được đọc correct_answer trước khi submit

Admin:

- authenticated
- role admin

Sensitive action phải thông qua:

```text
Edge Function
```

---

# 48. API / Edge Functions

Đề xuất endpoints:

```text
GET /student/home

GET /lessons

GET /lessons/:id/start

POST /attempts/start

POST /attempts/:id/answer

POST /attempts/:id/finish

GET /leaderboard?period=daily

GET /leaderboard?period=weekly

GET /leaderboard?period=monthly
```

Admin:

```text
POST /admin/import/questions

POST /admin/lessons

PATCH /admin/lessons/:id

POST /admin/questions

PATCH /admin/questions/:id

DELETE /admin/questions/:id
```

---

# 49. Không gửi correct_answer xuống client

Khi start exercise:

Frontend chỉ nhận:

```json
{
  "question_id": "...",
  "question_text": "27 + 18 = ?",
  "type": "number"
}
```

Không nhận:

```text
correct_answer
```

Sau khi submit mới trả:

```json
{
  "is_correct": true,
  "correct_answer": "45"
}
```

nếu product muốn hiển thị đáp án.

---

# 50. Student Device Identity

LocalStorage:

```text
student_id
device_token
```

Có thể generate random UUID:

```text
device_token
```

Mục đích:

- nhớ học sinh
- hạn chế nhầm user
- hỗ trợ debug

Không coi đây là authentication mạnh.

---

# 51. Multiple Device

Một học sinh vẫn có thể dùng nhiều device.

Không cần block.

Attempt vẫn gắn:

```text
student_id
```

Leaderboard tính theo student.

---

# 52. Duplicate Attempt Logic

Khi student bắt đầu lesson:

Backend check:

```text
SELECT ranked attempt
WHERE
student_id = X
lesson_id = Y
```

Nếu chưa có:

```text
is_ranked = true
```

Nếu đã có:

```text
is_ranked = false
```

---

# 53. Ranking Score

MVP:

```text
Easy:
10 points

Normal:
15 points

Advanced:
25 points
```

Không dùng time bonus ở version đầu.

Lý do:

- tránh tạo áp lực
- học sinh nhỏ tuổi
- ưu tiên đúng hơn nhanh

---

# 54. Gamification — Phase 3

Chưa cần ở MVP.

Có thể thêm:

```text
🔥 Streak
⭐ Level
🏅 Achievement
🎁 Badge
👑 Weekly Champion
```

Không nên build sớm trước khi chứng minh học sinh dùng website thường xuyên.

---

# 55. Phase 1 — MVP

Phải hoàn thành:

### Student

- Chọn học sinh
- Remember student
- Xem list bài
- Làm Multiple Choice
- Làm Number Input
- Làm Text Input
- Chấm điểm server-side
- Result screen
- Daily leaderboard
- Weekly leaderboard
- Monthly leaderboard

### Admin

- Login
- CRUD student
- CRUD lesson
- CRUD question
- Publish lesson
- Current week
- Basic results

---

# 56. Phase 2 — Content Automation

Thêm:

- Import CSV
- Import Excel
- Bulk Question Bank
- Question templates
- Deterministic Math Generator
- Schedule by date
- Analytics
- Hardest questions
- Student progress

---

# 57. Phase 3 — Personalization

Thêm sau:

- Adaptive learning
- Skill tracking
- Weak skill detection
- Auto practice
- Badge
- Achievement
- Streak
- Parent report

---

# 58. UI Pages

Frontend routes:

```text
/

/select-student

/home

/lesson/:lessonId

/result/:attemptId

/leaderboard
```

Admin:

```text
/admin/login

/admin

/admin/students

/admin/curriculum

/admin/lessons/:lessonId

/admin/questions

/admin/import

/admin/results

/admin/settings
```

---

# 59. Responsive

Ưu tiên:

```text
Mobile
Tablet
Desktop
```

Target:

- Android tablet
- iPad
- điện thoại phụ huynh
- PC

---

# 60. Visual Style

Student UI:

- bright
- friendly
- clean
- colorful
- large buttons
- minimal text

Không dùng quá nhiều:

- table
- tiny icon
- dropdown phức tạp
- nested menus

Admin UI có thể desktop-first.

---

# 61. Performance

Target:

```text
First Load < 2s
```

Trang student phải nhẹ.

Không dùng:

- animation nặng
- large framework không cần thiết
- video background
- asset lớn

---

# 62. Cost Target

Mục tiêu:

```text
Hosting:
$0

Database:
$0

Backend:
$0

Auth:
$0

Storage:
$0

Total:
~$0/month
```

Ngoại trừ:

- custom domain nếu mua
- AI API nếu sau này dùng

---

# 63. Không dùng VPS

Không triển khai:

```text
Ubuntu VPS
Docker server
Nginx server
self-host PostgreSQL
```

nếu không cần thiết.

Mục tiêu:

```text
git push
↓
auto deploy
```

---

# 64. Deployment

Frontend:

```text
Git
↓
Cloudflare Pages
↓
Auto Deploy
```

Backend:

```text
Supabase
```

Environment variables:

```text
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY
```

Secrets backend không được expose frontend.

---

# 65. Suggested Project Structure

```text
src/

  components/

  pages/

    student/
      SelectStudentPage
      HomePage
      LessonPage
      ResultPage
      LeaderboardPage

    admin/
      LoginPage
      DashboardPage
      StudentsPage
      CurriculumPage
      LessonDetailPage
      QuestionBankPage
      ImportPage
      ResultsPage
      SettingsPage

  services/
    supabase
    student
    lesson
    leaderboard
    admin

  hooks/

  types/

  utils/

supabase/

  migrations/

  functions/

    start-attempt/
    submit-answer/
    finish-attempt/
    leaderboard/
    import-questions/
```

---

# 66. Coding Principles

Cursor phải ưu tiên:

- simple
- explicit
- maintainable
- minimal dependency
- typed TypeScript
- reusable components
- no premature abstraction

Không tạo:

- microservices
- event bus
- Redis
- message queue
- Kubernetes

---

# 67. Security Checklist

Phải đảm bảo:

- RLS enabled
- Admin route protected
- scoring server-side
- correct answer không gửi trước
- service role key chỉ backend
- validate tất cả input
- rate limit nếu cần
- sanitize text
- validate imports

---

# 68. Logging

Tối thiểu log:

```text
attempt_started
answer_submitted
attempt_finished

admin_login
question_import
lesson_publish
```

Không cần analytics SDK ở MVP.

---

# 69. Error Handling

Student-facing error phải đơn giản:

```text
Có lỗi xảy ra.
Hãy thử lại.
```

Không show:

```text
SQL error
stack trace
Supabase error
```

Admin có thể thấy error chi tiết hơn.

---

# 70. Backup / Data Safety

Database là Supabase PostgreSQL.

Question Bank nên luôn có khả năng export CSV.

Admin cần chức năng:

```text
Export Question Bank
```

để tránh lock-in.

Có thể thêm:

```text
Export Results
```

sau.

---

# 71. Book Import Workflow

Khi có bộ sách:

```text
Book
↓
Extract TOC
↓
Map Week
↓
Map Lesson
↓
Identify Learning Objectives
↓
Identify Question Patterns
↓
Generate Question Templates
↓
Generate Question Bank
↓
Review
↓
Import
```

---

# 72. Question Quality Rules

Question generated phải:

- đúng kiến thức bài
- không vượt quá phạm vi lớp 2
- không dùng từ quá khó
- câu ngắn
- đáp án rõ ràng
- không ambiguous
- difficulty hợp lý
- không duplicate quá nhiều

---

# 73. Math Generator

Nên xây rule-based generator.

Ví dụ skill:

```text
addition_under_20
addition_under_100
subtraction_under_20
missing_number
compare_number
number_sequence
word_problem_addition
```

Question có:

```text
generator_type
generator_params
```

Optional future enhancement.

---

# 74. Example Math Generator

```typescript
function generateAdditionUnder20() {
  const a = randomInt(1, 19)
  const b = randomInt(1, 20 - a)

  return {
    question: `${a} + ${b} = ?`,
    answer: String(a + b)
  }
}
```

---

# 75. Future AI Usage

AI không nằm trong critical path.

Có thể dùng sau cho:

- Vietnamese Question Generation
- Reading Comprehension
- Word Problems
- Explanation Generation

Nhưng output AI phải review hoặc validate trước khi publish.

---

# 76. Product Principle

Giá trị chính của sản phẩm không phải leaderboard.

Giá trị chính:

```text
Bộ sách
↓
Question Bank chất lượng
↓
Bám tiến độ lớp
↓
Luyện tập đều
↓
Biết học sinh yếu ở đâu
```

Leaderboard chỉ là gamification giúp học sinh muốn quay lại.

---

# 77. MVP Priority

Priority:

```text
P0

Student
Question Bank
Lesson
Scoring
Leaderboard
Admin Publish

P1

Import
Analytics
Schedule

P2

Adaptive Learning
Gamification
AI
```

---

# 78. Definition of Done — MVP

MVP được coi là hoàn thành khi:

1. Admin tạo được lớp.
2. Admin import được danh sách học sinh.
3. Admin tạo được môn.
4. Admin tạo được tuần/bài.
5. Admin tạo được câu hỏi.
6. Admin publish được bài.
7. Student chọn tên.
8. Student nhìn thấy bài.
9. Student làm được 3 dạng câu hỏi.
10. Backend tự chấm.
11. Lưu attempt.
12. Lưu answer detail.
13. Student xem kết quả.
14. Có leaderboard ngày.
15. Có leaderboard tuần.
16. Có leaderboard tháng.
17. Attempt thứ hai không farm ranking.
18. Admin xem được kết quả cơ bản.
19. Website deploy Cloudflare Pages.
20. Database/backend chạy Supabase Free.

---

# 79. Yêu cầu cho Cursor khi triển khai

Không code toàn bộ hệ thống một lần.

Triển khai theo từng milestone.

## Milestone 1

```text
Project setup
Supabase
DB migrations
Admin Auth
```

## Milestone 2

```text
Students
Subjects
Lessons
Questions
```

## Milestone 3

```text
Student selection
Student home
Lesson list
```

## Milestone 4

```text
Attempt system
Answer submit
Server-side scoring
Result
```

## Milestone 5

```text
Leaderboard
Daily
Weekly
Monthly
```

## Milestone 6

```text
Admin curriculum
Publish
Current Week
```

## Milestone 7

```text
CSV import
Analytics
Polish
```

Sau mỗi milestone:

- test
- commit
- không tiếp tục nếu flow chính chưa chạy ổn

---

# 80. Final Architecture Decision

Sử dụng:

```text
React
TypeScript
Vite
Tailwind

Cloudflare Pages

Supabase
├── PostgreSQL
├── Auth
├── Edge Functions
└── Storage
```

Không dùng server/VPS riêng.

Không yêu cầu student login/password.

Question Bank tổ chức:

```text
Subject
→ Week
→ Lesson
→ Difficulty
→ Question
```

Admin kiểm soát:

```text
Publish
Current Week
Schedule
```

Leaderboard:

```text
Daily
Weekly
Monthly
```

Scoring:

```text
Server-side
```

Question generation:

```text
Book
→ Skill
→ Templates
→ Question Bank
```

Đây là kiến trúc ưu tiên:

- cực ít chi phí
- ít vận hành
- phù hợp 1 lớp học
- dễ làm bằng AI coding
- đủ sạch để mở rộng về sau
