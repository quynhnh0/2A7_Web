# Học Vui Lớp 2 🎒

Web làm bài tập cho học sinh lớp 2, **chạy miễn phí 100%** (Cloudflare Pages + Supabase free).

- Học sinh **không cần đăng nhập**: mở link → bấm chọn tên mình (hoặc gõ họ tên nếu là bạn mới) → làm bài.
- Mỗi bài có **Cơ bản** (nhiều câu dễ) và **Nâng cao** (nhiều câu khó).
- 3 dạng câu hỏi: **trắc nghiệm**, **điền số** (bàn phím số to cho tablet/điện thoại), **điền chữ**.
- **Bảng xếp hạng** theo ngày / tuần (thứ Hai – Chủ nhật) / tháng. Chỉ lần làm đầu tiên của mỗi bài được tính điểm, các lần sau là luyện tập → công bằng, không “cày điểm”.
- Chấm điểm **trên máy chủ**, đáp án không bao giờ gửi xuống trình duyệt trước khi nộp.
- **1 tài khoản admin** (thầy cô / phụ huynh) để: quản lý bài học & lịch mở bài theo tuần, ngân hàng câu hỏi, **nhập CSV/Excel**, **tự sinh câu hỏi** Toán & Tiếng Việt lớp 2, quản lý học sinh, xem kết quả, xuất CSV.
- Có sẵn **ngân hàng mẫu 807 câu** (27 bài, Toán tuần 1–10, Tiếng Việt tuần 1–4) theo chương trình lớp 2.
- Có sẵn **ngân hàng Archimes 2.545 câu** soạn theo bộ phiếu bài tập Archimedes School (Toán 2 và Tiếng Việt 2, quyển 1–4): **35 tuần × 2 môn = 70 bài**, mỗi bài 26–55 câu đủ 3 mức Dễ / Vừa / Nâng cao, có ghi trang sách nguồn.

---

## 1. Chạy thử ngay trên máy (chế độ demo)

Cần [Node.js 22+](https://nodejs.org).

```bash
cd hoc-vui-lop-2
npm install
npm run dev
```

Mở http://localhost:5173

Khi **chưa cấu hình Supabase**, web tự chạy **chế độ demo**: một cơ sở dữ liệu PostgreSQL thật (PGlite) chạy ngay trong trình duyệt, có sẵn 20 học sinh giả và kết quả làm bài mẫu.

- Trang học sinh: http://localhost:5173
- Trang thầy cô: http://localhost:5173/admin — tài khoản demo `admin@demo.vn` / `demo1234`

> Dữ liệu demo chỉ nằm trong trình duyệt đó. Muốn cả lớp dùng chung thì làm tiếp bước 2.

---

## 2. Đưa lên mạng miễn phí

> 📘 Hướng dẫn **chi tiết từng bước** (có 3 cách đăng web, xử lý sự cố, giữ Supabase không bị tạm dừng): [`HUONG_DAN_DEPLOY.md`](HUONG_DAN_DEPLOY.md). Đưa code lên GitHub (repo riêng tư): [`HUONG_DAN_GITHUB.md`](HUONG_DAN_GITHUB.md). Phần dưới đây là bản tóm tắt.

### Bước 2.1 — Tạo cơ sở dữ liệu Supabase (miễn phí)

1. Đăng ký tại https://supabase.com → **New project**. Chọn region **Singapore** cho nhanh. Ghi nhớ mật khẩu database.
2. Vào **SQL Editor** → **New query** → dán toàn bộ nội dung file [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql) → **Run**.
3. (Nên làm) Tạo query mới, dán file [`supabase/seed.sql`](supabase/seed.sql) → **Run** để có sẵn 807 câu hỏi mẫu. Chạy lại nhiều lần cũng không bị trùng.
   Làm tương tự với [`supabase/archimes.sql`](supabase/archimes.sql) để có **ngân hàng Archimes** (2.545 câu, tuần 1–35). File khá dài (~800 KB): nếu SQL Editor báo quá lớn, dùng cách nhập file CSV ở mục 3d.
4. **Tắt đăng ký tự do** (chỉ admin mới có tài khoản): **Authentication → Sign In / Providers** → tắt **Allow new users to sign up**.
5. **Tạo tài khoản admin**: **Authentication → Users → Add user → Create new user**, nhập email + mật khẩu, tick **Auto Confirm User**.
6. **Cấp quyền admin** cho tài khoản vừa tạo: vào **SQL Editor**, chạy (thay email):

   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'email-cua-ban@gmail.com';
   ```

7. Lấy 2 thông tin kết nối trong **Project Settings → API Keys / Data API**:
   - **Project URL**, dạng `https://xxxx.supabase.co`
   - **anon public key** (hoặc **publishable key**, dạng `sb_publishable_...`)

   > ⚠️ **Tuyệt đối không** dùng `service_role` / `secret` key cho web. Key anon/publishable an toàn vì mọi bảng đã bật RLS, học sinh chỉ gọi được các hàm làm bài.

### Bước 2.2 — Chạy thử với Supabase trên máy (không bắt buộc)

```bash
cp .env.example .env.local
# mở .env.local, điền VITE_SUPABASE_URL và VITE_SUPABASE_ANON_KEY
npm run dev
```

### Bước 2.3 — Đăng web lên Cloudflare Pages (miễn phí, không giới hạn lượt truy cập)

**Cách A — kết nối GitHub (tự cập nhật mỗi lần sửa code):**

1. Đưa thư mục dự án lên một repo GitHub.
2. Vào https://dash.cloudflare.com → **Workers & Pages → Create → Pages → Connect to Git**, chọn repo.
3. Cấu hình build:
   | Mục | Giá trị |
   |---|---|
   | Framework preset | `None` (hoặc `React (Vite)`) |
   | Root directory | `hoc-vui-lop-2` (nếu repo chứa thư mục này) |
   | Build command | `npm run build` |
   | Build output directory | `dist` |
4. **Environment variables** (Production): thêm `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` và `NODE_VERSION` = `22`.
5. **Save and Deploy**. Vài phút sau có link dạng `https://hoc-vui-lop-2.pages.dev`.

**Cách B — tải thẳng từ máy:**

```bash
# điền .env.local trước, rồi:
npm run build
npx wrangler pages deploy dist --project-name hoc-vui-lop-2
```

File `public/_redirects` đã cấu hình sẵn để các đường dẫn như `/home`, `/admin` hoạt động khi tải lại trang.

### Bước 2.4 — Bắt đầu dùng

1. Mở `https://<ten-web>.pages.dev/admin` → đăng nhập bằng tài khoản admin.
2. **Học sinh** → **Thêm học sinh** → dán danh sách lớp (mỗi dòng một tên) hoặc **Nhập danh sách** từ Excel.
3. **Tổng quan** → chỉnh **Tuần học hiện tại** cho đúng tuần của lớp. Bài đặt lịch “Mở theo tuần” sẽ tự hiện khi tới tuần.
4. **Cài đặt** → chép link học sinh, gửi vào nhóm Zalo của lớp.

---

## 3. Đưa bài tập vào hệ thống

Có 3 cách, dùng kết hợp được:

### a) Nhập file CSV / Excel (từ file có sẵn)

Trang **Nhập CSV / Excel** → kéo thả file → hệ thống kiểm tra từng dòng (thiếu đáp án, đáp án không nằm trong lựa chọn, độ khó sai, câu trùng…) → xem trước → bấm lưu. Bài học và môn học chưa có sẽ được **tạo tự động**.

Cột của file (dòng đầu là tiêu đề, tên cột tiếng Việt không dấu cũng được):

| Cột | Bắt buộc | Ý nghĩa / ví dụ |
|---|---|---|
| `subject` (`mon`) | ✔ | `toan`, `tieng_viet` hoặc tên môn (`Toán`, `Tự nhiên và Xã hội`…) |
| `week` (`tuan`) | ✔ | Tuần học 1–35 |
| `lesson` (`bai`) | ✔ | Số thứ tự bài |
| `lesson_name` (`ten_bai`) | khi bài chưa có | `Phép cộng có nhớ trong phạm vi 100` |
| `difficulty` (`do_kho`) | | `1`/`2`/`3` hoặc `dễ`/`vừa`/`khó` (mặc định dễ) |
| `type` (`dang`) | ✔ | `multiple_choice` / `number` / `text` (hoặc `trắc nghiệm` / `số` / `chữ`) |
| `question` (`cau_hoi`) | ✔ | Dùng `___` để tạo ô trống: `38 + ___ = 45` |
| `option_a` … `option_d` (`a`…`d`) | trắc nghiệm | Ít nhất 2 lựa chọn |
| `answer` (`dap_an`) | ✔ | Đáp án đúng. Trắc nghiệm ghi nội dung hoặc `A`/`B`/`C`/`D` |
| `accepted_answers` (`dap_an_khac`) | | Đáp án khác cũng đúng, cách nhau bởi `\|`: `bảy\|7` |
| `explanation` (`giai_thich`) | | Hiện cho học sinh sau khi trả lời |
| `source_page` (`trang`) | | Trang sách |

- File mẫu: [`data/ngan_hang_cau_hoi_mau.csv`](data/ngan_hang_cau_hoi_mau.csv) (807 câu), cũng tải được ngay trong trang Nhập.
- Excel: lưu file `.xlsx` bình thường, hệ thống đọc sheet đầu tiên.
- Chấm điền chữ/điền số tự bỏ qua khoảng trắng thừa, chữ hoa/thường, dấu chấm cuối câu. Với số, “1.000”, “1 000” và “1000” được coi là như nhau.

### b) Sinh câu hỏi tự động

Trang **Sinh câu hỏi tự động** có 28 dạng bài theo chương trình lớp 2:

- **Toán** (20 dạng): số đến 100/1000, liền trước – liền sau, so sánh, dãy số, thành phần phép tính, hơn kém, cộng/trừ có nhớ và không nhớ, bài toán có lời văn, kg – lít, đo độ dài, nhân/chia 2 và 5, xem giờ…
- **Tiếng Việt** (8 dạng): bảng chữ cái, chính tả c/k – g/gh – ng/ngh, từ chỉ sự vật/hoạt động/đặc điểm, dấu câu, từ trái nghĩa, chọn từ điền vào câu.

Chọn dạng bài → chọn số câu dễ/vừa/khó → **Sinh** → xem trước, bỏ câu không ưng → **Lưu** vào bài có sẵn hoặc bài mới. Câu trùng với câu đã có sẽ được bỏ qua.

### c) Soạn tay

Trang **Ngân hàng câu hỏi → Thêm câu hỏi**, có khung xem trước giống màn hình học sinh.

### d) Ngân hàng Archimes (theo bộ sách có sẵn)

Ngân hàng câu hỏi riêng tên **Archimes**, soạn từ 8 quyển phiếu bài tập Archimedes School trong thư mục `sách/`
(Toán 2 quyển 1–4, Tiếng Việt 2 quyển 1–4), bám theo từng tuần của sách:

- **Toán** (1.406 câu): số và phép tính, cộng/trừ có nhớ, tìm thành phần chưa biết, nhân/chia bảng 2–5, đơn vị đo, xem giờ – lịch, chu vi, số có ba chữ số, bài toán có lời văn và các bài tư duy của phiếu cuối tuần.
- **Tiếng Việt** (1.139 câu): đọc hiểu (trích bài đọc của tuần), chính tả (c/k, g/gh, ng/ngh, ch/tr, s/x, r/d/gi, dấu hỏi/ngã, các vần khó), từ ngữ theo chủ điểm, kiểu câu Ai là gì? / Ai làm gì? / Ai thế nào?, đặt câu hỏi Khi nào? / Ở đâu? / Vì sao? / Để làm gì?, dấu câu, từ trái nghĩa.
- Mỗi tuần, mỗi môn là một bài **“Archimes: …”** (số bài 100), mở theo tuần hiện tại giống các bài khác. Học sinh thấy nhãn **Archimes** trên thẻ bài.
- Trang **Ngân hàng câu hỏi** có bộ lọc **Ngân hàng → Archimes**; mỗi câu có nhãn tím “Archimes · tr.N” (N = trang sách) để thầy cô đối chiếu.
- Đưa lên Supabase: chạy `supabase/archimes.sql` (bước 2.1), **hoặc** vào trang **Nhập CSV / Excel** và chọn file `data/archimes.csv` (tên file có chữ “archimes” nên câu hỏi được gắn đúng ngân hàng Archimes).
- Chế độ demo tự nạp sẵn ngân hàng này.

Sửa hoặc thêm câu: sửa file nguồn `data/archimes/<quyển>.json` (toan1…toan4, tv1…tv4), rồi chạy `npm run archimes:build`. Lệnh này kiểm tra toàn bộ dữ liệu (đáp án trắc nghiệm phải nằm trong lựa chọn, câu điền số phải khớp phép tính kiểm chứng, không trùng câu, mỗi tuần đủ câu Dễ / Vừa / Nâng cao) rồi sinh lại `supabase/archimes.sql` và `data/archimes.csv`. Có thể sửa trực tiếp từng câu trong trang quản trị như câu hỏi bình thường.

> File `data/archimes.csv` có đáp án nên **không** đặt trong thư mục `public/` (không cho học sinh tải về).

---

## 4. Cách tính điểm & xếp hạng

- Mỗi lượt làm lấy ngẫu nhiên câu hỏi theo tỉ lệ (sửa được trong **Cài đặt**), ưu tiên câu bạn đó **chưa gặp**:
  - Cơ bản: 6 dễ + 3 vừa + 1 khó.
  - Nâng cao: 2 dễ + 3 vừa + 5 khó.
- Điểm mỗi câu đúng: dễ 10, vừa 15, khó 25 (sửa được; từng câu có thể đặt điểm riêng).
- **Chỉ lần làm đầu tiên** của mỗi (bài, loại cơ bản/nâng cao) được cộng vào bảng xếp hạng. Làm lại thoải mái để luyện tập.
- Đang làm dở mà thoát ra: mở lại trong 3 giờ sẽ làm tiếp đúng chỗ cũ.
- Thời gian tính theo giờ Việt Nam; tuần tính từ thứ Hai đến Chủ nhật.

---

## 5. Giới hạn của gói miễn phí (đủ dư cho 1 lớp)

| Dịch vụ | Giới hạn free | Một lớp 40 bạn dùng khoảng |
|---|---|---|
| Supabase database | 500 MB | < 20 MB/năm |
| Supabase API | Không giới hạn số request | vài nghìn/ngày |
| Cloudflare Pages | Không giới hạn băng thông, 500 lần build/tháng | — |

⚠️ **Supabase tạm dừng project miễn phí nếu 7 ngày liền không có ai truy cập** (ví dụ nghỉ hè). Khi đó vào dashboard Supabase bấm **Restore project**, dữ liệu vẫn còn nguyên.

Nên sao lưu định kỳ: trang **Ngân hàng câu hỏi / Học sinh / Kết quả** đều có nút **Xuất CSV**.

---

## 6. Bảo mật

- Mọi bảng bật **Row Level Security**. Chỉ tài khoản có trong bảng `admins` mới đọc/ghi được dữ liệu quản trị.
- Học sinh (khách) chỉ gọi được các hàm: xem danh sách tên, bắt đầu bài, nộp từng câu, xem kết quả, xem xếp hạng. Không đọc được bảng câu hỏi/đáp án.
- Đáp án chỉ được trả về **sau khi** học sinh nộp câu đó, và không sửa được câu đã nộp.
- Vì không có mật khẩu học sinh, về lý thuyết một bạn có thể chọn nhầm tên bạn khác. Thầy cô xem được lịch sử từng bạn và có thể tạm khoá tên trong trang **Học sinh**. Nếu đã nhập đủ danh sách lớp, nên tắt “Cho phép học sinh tự thêm tên” trong **Cài đặt**.

---

## 7. Dành cho người sửa code

```
hoc-vui-lop-2/
├── supabase/
│   ├── migrations/0001_init.sql   # Toàn bộ bảng, RLS, hàm chấm điểm & xếp hạng
│   ├── seed.sql                   # Ngân hàng câu hỏi mẫu (sinh tự động)
│   ├── archimes.sql               # Ngân hàng Archimes (sinh từ data/archimes/*.json)
│   └── demo/                      # Chỉ dùng cho chế độ demo
├── data/
│   ├── archimes/*.json            # Nguồn ngân hàng Archimes, mỗi file 1 quyển sách
│   └── archimes.csv               # Ngân hàng Archimes dạng CSV để nhập qua trang quản trị
├── scripts/
│   ├── generate-seed.ts           # Sinh seed.sql + file CSV mẫu từ bộ sinh câu hỏi
│   ├── build-archimes.ts          # Kiểm tra + sinh archimes.sql / archimes.csv
│   └── test-sql.mjs               # Kiểm thử SQL bằng PGlite (không cần cài Postgres)
├── src/
│   ├── lib/backend/               # Supabase / Demo (PGlite) dùng chung 1 interface
│   ├── lib/generators/            # Bộ sinh câu hỏi Toán & Tiếng Việt
│   ├── lib/importer.ts            # Đọc & kiểm tra file CSV/Excel
│   ├── pages/student/             # Chọn tên, trang chủ, làm bài, kết quả, xếp hạng
│   └── pages/admin/               # Khu vực thầy cô
└── public/_redirects              # Cấu hình SPA cho Cloudflare Pages
```

| Lệnh | Tác dụng |
|---|---|
| `npm run dev` | Chạy máy chủ phát triển |
| `npm run build` | Kiểm tra kiểu TypeScript + đóng gói vào `dist/` |
| `npm run test:sql` | Chạy 16 nhóm kiểm thử cho SQL (chấm điểm, xếp hạng, quyền truy cập, ngân hàng Archimes…) |
| `npm run seed:generate` | Sinh lại `supabase/seed.sql`, dữ liệu demo và file CSV mẫu |
| `npm run archimes:check` | Chỉ kiểm tra dữ liệu ngân hàng Archimes (thêm tên quyển để kiểm 1 file, VD `-- tv2`) |
| `npm run archimes:build` | Kiểm tra + sinh lại `supabase/archimes.sql` và `data/archimes.csv` |

Khi sửa file SQL: chạy `npm run test:sql`, rồi dán lại file vào SQL Editor của Supabase. File viết theo kiểu `create or replace` / `if not exists` nên chạy lại an toàn.
