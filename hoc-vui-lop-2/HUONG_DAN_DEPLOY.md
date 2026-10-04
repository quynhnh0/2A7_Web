# Hướng dẫn đưa web “Học Vui Lớp 2” lên mạng — miễn phí 100%

Tài liệu này hướng dẫn từng bước, dành cho người **không chuyên lập trình**. Làm lần đầu mất khoảng **30–45 phút**.

---

## 0. Tổng quan

Web gồm 2 phần, mỗi phần dùng một dịch vụ miễn phí:

| Phần | Dịch vụ | Vai trò | Chi phí |
|---|---|---|---|
| **Server + Database** | [Supabase](https://supabase.com) (gói Free) | Lưu học sinh, bài học, câu hỏi, điểm; chấm điểm; đăng nhập admin | 0 đ, không cần thẻ |
| **Host (trang web)** | [Cloudflare Pages](https://pages.cloudflare.com) (gói Free) | Đưa giao diện web lên mạng, có link `https://….pages.dev` | 0 đ, không cần thẻ |

```
Học sinh / thầy cô ──► https://hoc-vui-lop-2.pages.dev  (Cloudflare Pages: giao diện)
                                   │
                                   ▼
                        https://xxxx.supabase.co     (Supabase: dữ liệu + chấm điểm)
```

**Thứ tự làm:** (1) Supabase → (2) build web trên máy → (3) đưa lên Cloudflare → (4) kiểm tra và bắt đầu dùng.

### Chuẩn bị

- Máy tính có **Node.js 22 trở lên**: tải bản LTS tại https://nodejs.org rồi cài như phần mềm bình thường.
  Kiểm tra: mở **Terminal** (macOS) hoặc **PowerShell** (Windows), gõ `node -v`, thấy `v22…` trở lên là được.
- Một email (Gmail là được) để đăng ký Supabase và Cloudflare.
- Thư mục dự án `hoc-vui-lop-2` (thư mục chứa file này).

Mở Terminal tại thư mục dự án và cài thư viện **một lần**:

```bash
cd đường-dẫn-tới/hoc-vui-lop-2
npm install
```

> Mẹo macOS: gõ `cd ` (có dấu cách) rồi kéo thả thư mục `hoc-vui-lop-2` vào cửa sổ Terminal, bấm Enter.

---

## 1. Tạo server + database trên Supabase

### 1.1. Tạo tài khoản và project

1. Vào https://supabase.com → **Start your project** → đăng nhập bằng GitHub hoặc email.
2. Bấm **New project**:
   - **Name**: `hoc-vui-lop-2`
   - **Database Password**: bấm **Generate a password**, rồi **lưu lại** mật khẩu này (ít khi dùng nhưng đừng làm mất).
   - **Region**: chọn **Southeast Asia (Singapore)** cho nhanh nhất ở Việt Nam.
   - **Plan**: Free.
3. Bấm **Create new project**, đợi 1–2 phút cho project khởi tạo xong.

### 1.2. Tạo bảng và hàm (bắt buộc)

1. Menu trái → **SQL Editor** → **New query** (dấu `+`).
2. Mở file `supabase/migrations/0001_init.sql` bằng trình soạn thảo bất kỳ (TextEdit, Notepad, VS Code…),
   **chọn tất cả** (Cmd/Ctrl + A), **copy**, rồi **dán** vào SQL Editor.
3. Bấm **Run** (hoặc Cmd/Ctrl + Enter). Thấy dòng **Success. No rows returned** là xong.

4. Làm tương tự, lần lượt với các file còn lại trong `supabase/migrations/` **theo thứ tự số**:
   - `0002_fix_dau_cau.sql`: sửa lỗi bài “Chọn dấu câu” chọn đúng vẫn bị chấm sai, và chấm lại các lượt đã làm (cài mới chạy cũng không sao).
   - `0003_student_birthday.sql`: **xác nhận ngày sinh** khi bé chọn tên (bắt buộc từ phiên bản này, web mới cần file này mới chạy được).
   - `0004_subject_stats.sql`: **bảng xếp hạng theo từng môn** và trang admin **Thống kê theo môn**.
   - `0005_guest_students.sql`: **bạn khách** — học sinh có dấu “-” trong họ tên; các bạn trong lớp không thấy bạn ấy trên bảng xếp hạng.
   - `0006_learning_rules.sql`: **luật học tập mới** — điểm 1/2/3 (nâng cao 1/3/4), câu sai trừ 1 điểm, bài làm lại chỉ cộng sao, sao & kim cương, huy chương tuần (bạn khách không tham gia), tối đa 3 đề/môn/ngày, giờ làm bài, cài đặt riêng từng môn, gợi ý độ khó. Tất cả chỉnh được trong trang **Cài đặt** của admin.
   - `0007_guest_sees_all.sql`: **bạn khách thấy bảng xếp hạng của tất cả mọi người** (cả lớp và các bạn khách khác); các bạn trong lớp vẫn chỉ thấy các bạn trong lớp.
   - `0008_weekly_limit.sql`: **giới hạn số đề mỗi môn mỗi tuần** (thứ Hai → Chủ nhật). Mặc định 0 = không giới hạn; chỉnh ở **Cài đặt → Lượng bài mỗi ngày / mỗi tuần** hoặc riêng từng môn ở **Bài học → Cài đặt môn**.

   > ⚠️ **Lần đầu chạy `0006`, điểm cũ được tính lại theo thang mới** (VD 1 bài trước đây 120 điểm nay còn khoảng 13 điểm) để bảng xếp hạng không bị lẫn 2 thang điểm. Việc tính lại chỉ làm **đúng 1 lần**: chạy lại `0006` sau đó không đụng tới điểm và không ghi đè điểm thầy cô đã sửa trong Cài đặt.
   > Nên **Xuất CSV** trang Kết quả trước khi chạy nếu muốn giữ bản điểm cũ.

   Các file đều chạy lại nhiều lần an toàn. File tiếp theo (nếu có) sẽ là `0009_…`, chỉ cần chạy thêm file đó.
   Nếu lỡ chạy lại `0001_init.sql` thì chạy lại luôn các file `0003` → `0008` để cấp lại quyền và khôi phục các hàm mới. Lỡ chạy lại `0006` thì chạy lại `0008`.
   **Không chạy lại `0002_fix_dau_cau.sql` sau khi đã có `0006`**: file 0002 tính điểm theo cách cũ (không trừ câu sai) nên sẽ làm lệch điểm các lượt có câu dấu câu.

> Nếu Supabase hỏi xác nhận vì câu lệnh có `drop`/`revoke`… → bấm **Run this query**. File được viết để chạy lại nhiều lần vẫn an toàn.

### 1.3. Nạp ngân hàng câu hỏi (nên làm)

Làm giống bước 1.2, **mỗi file một query mới**, theo đúng thứ tự:

| Thứ tự | File | Nội dung |
|---|---|---|
| 1 | `supabase/seed.sql` | 807 câu mẫu (Toán tuần 1–10, Tiếng Việt tuần 1–4) |
| 2 | `supabase/archimes.sql` | **Ngân hàng Archimes** 2.545 câu, 70 bài (Toán + Tiếng Việt, tuần 1–35) |
| 3 | `supabase/ky_nang_khoa_hoc.sql` | 2 môn mới **Kỹ năng sống** và **Khoa học**: mỗi môn 20 bài × 25 câu = 500 câu (bài N mở ở tuần N) |

Cả 3 file đều chạy lại được nhiều lần mà không tạo câu trùng.

> `archimes.sql` khá dài (~800 KB). Nếu SQL Editor báo lỗi vì file quá lớn hoặc bị treo, **bỏ qua** và nạp bằng file CSV sau khi web đã lên mạng (xem [mục 4.3](#43-nạp-ngân-hàng-archimes-bằng-csv-nếu-bước-13-lỗi)).

### 1.4. Chặn người lạ tự đăng ký tài khoản

Học sinh **không cần tài khoản**; chỉ admin mới có. Vì vậy phải tắt đăng ký tự do:

1. Menu trái → **Authentication** → **Sign In / Providers** (có bản giao diện ghi **Providers** hoặc **Settings**).
2. Tìm mục **Allow new users to sign up** → **tắt** → **Save**.

### 1.5. Tạo tài khoản admin

1. **Authentication** → **Users** → **Add user** → **Create new user**.
2. Nhập **email** và **mật khẩu** bạn muốn dùng để đăng nhập trang quản trị.
3. Tick **Auto Confirm User** → **Create user**.
4. Vào **SQL Editor** → **New query**, dán lệnh sau (**thay email** cho đúng), bấm **Run**:

   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'email-cua-ban@gmail.com';
   ```

   Thấy **Success. 1 row affected** (hoặc tương tự) là tài khoản đã có quyền admin.

> Muốn thêm admin thứ 2 (ví dụ cô giáo chủ nhiệm): lặp lại bước 1–4 với email khác.

### 1.6. Lấy 2 thông tin kết nối

Bấm nút **Connect** ở đầu trang project, hoặc vào **Project Settings → API Keys**:

| Cần lấy | Trông như thế nào |
|---|---|
| **Project URL** | `https://abcdefghijkl.supabase.co` (chỉ đến `.supabase.co`, **không** kèm `/rest/v1/` hay dấu `/` ở cuối) |
| **Publishable key** | `sb_publishable_xxxxxxxxxxxx` (project cũ có thể là **anon public key**, chuỗi dài bắt đầu bằng `eyJ…`; dùng loại nào cũng được) |

> ⚠️ **TUYỆT ĐỐI KHÔNG** dùng **Secret key** (`sb_secret_…`) hay **service_role key**. Key này có toàn quyền, nếu đưa lên web thì ai cũng xem/sửa/xoá được dữ liệu.
> Publishable/anon key thì an toàn để đưa lên web, vì mọi bảng đã bật bảo mật (RLS): học sinh chỉ gọi được các hàm làm bài và không đọc được đáp án.

---

## 2. Build web trên máy (gắn thông tin Supabase vào web)

Web được “đóng gói” sẵn cùng địa chỉ Supabase, nên cần tạo file cấu hình trước khi build.

1. Trong thư mục `hoc-vui-lop-2`, **copy** file `.env.example` thành file mới tên **`.env.local`**:

   ```bash
   cp .env.example .env.local
   ```

   (Windows PowerShell: `copy .env.example .env.local`)

   > File bắt đầu bằng dấu chấm bị ẩn trên macOS: trong Finder bấm **Cmd + Shift + .** để hiện.

2. Mở `.env.local`, điền 2 dòng (không có dấu cách, không có ngoặc kép):

   ```env
   VITE_SUPABASE_URL=https://abcdefghijkl.supabase.co
   VITE_SUPABASE_ANON_KEY=sb_publishable_xxxxxxxxxxxx
   ```

3. **Chạy thử trên máy** (nên làm để chắc chắn kết nối đúng):

   ```bash
   npm run dev
   ```

   Mở http://localhost:5173/admin → đăng nhập bằng tài khoản admin ở bước 1.5.
   ✅ Đúng: **không còn** dải vàng “Đang chạy bản demo”, và đăng nhập được.
   Bấm **Ctrl + C** trong Terminal để tắt.

4. **Build** ra bản chính thức:

   ```bash
   npm run build
   ```

   Xong sẽ có thư mục **`dist/`**: đây chính là toàn bộ trang web để đưa lên host.

> File `.env.local` chỉ nằm trên máy bạn, đã được loại khỏi Git (`.gitignore`), không bị đưa lên mạng.

---

## 3. Đưa web lên Cloudflare Pages (host miễn phí)

Đăng ký tài khoản miễn phí tại https://dash.cloudflare.com/sign-up (xác nhận email).

Chọn **một** trong 3 cách:

| Cách | Độ khó | Khi nào dùng |
|---|---|---|
| **A. Kéo thả thư mục** | ⭐ Dễ nhất | Ít khi sửa code. Mỗi lần cập nhật thì build lại rồi kéo thả lại. |
| **B. Kết nối GitHub** | ⭐⭐ | Muốn sửa code xong là web **tự cập nhật**. |
| **C. Lệnh `wrangler`** | ⭐⭐ | Quen dùng Terminal, muốn cập nhật bằng 1 lệnh. |

> 🔎 **Không thấy chữ “Pages”?** Cloudflare đã giấu mục này. Nút xanh **Create application** giờ mặc định mở trang tạo **Worker** (tiêu đề kiểu *“Ship something new”*, có nút *Connect GitHub* / *Import a repository*). **Đừng bấm các nút đó**, vì chúng tạo Worker chứ không phải Pages.
>
> Cách vào đúng trang tạo Pages:
> - Kéo xuống **cuối** trang đó, tìm dòng chữ nhỏ **“Looking to deploy Pages? Get started”** → bấm **Get started**; hoặc
> - Đăng nhập Cloudflare rồi mở thẳng link: https://dash.cloudflare.com/?to=/:account/workers-and-pages/create/pages
>
> Trang đúng có 2 lựa chọn: **Import an existing Git repository** (Cách B) và **Drag and drop your files** (Cách A).
>
> Menu **Workers & Pages** nằm ở cột trái, thường trong nhóm **Build → Compute**. Không thấy thì gõ “Workers” vào ô tìm kiếm trên cùng của dashboard.

### Cách A — Kéo thả (khuyên dùng cho lần đầu)

1. Đã làm xong **mục 2** (có thư mục `dist/`, build **sau khi** đã điền `.env.local`).
2. Vào https://dash.cloudflare.com → menu trái **Compute → Workers & Pages** → **Create application**.
3. Kéo xuống cuối trang → **Looking to deploy Pages? Get started** (hoặc mở thẳng link ở khung 🔎 phía trên) → cạnh **Drag and drop your files** bấm **Get started**.
4. **Project name**: `hoc-vui-lop-2` (tên này thành link `https://hoc-vui-lop-2.pages.dev`; nếu bị trùng, Cloudflare tự thêm vài ký tự) → **Create project**.
5. **Kéo thả thư mục `dist`** (cả thư mục) vào khung upload → đợi upload xong → **Deploy site**.
6. Đợi khoảng 1 phút → bấm link `https://hoc-vui-lop-2.pages.dev` để mở web. 🎉

**Cập nhật lần sau:** sửa code (hoặc câu hỏi) → `npm run build` → vào project trên Cloudflare → **Create deployment** / **Upload** → kéo thả lại thư mục `dist` mới.

> Lưu ý: project tạo bằng kéo thả **không chuyển sang** kết nối GitHub được. Nếu sau này muốn dùng cách B, tạo project mới (tên khác), rồi xoá project cũ.

### Cách B — Kết nối GitHub (tự động cập nhật)

**B1. Đưa code lên GitHub (repo riêng tư)**

> 📘 Hướng dẫn chi tiết từng bước (3 cách, cách tạo token, xử lý lỗi khi push): [HUONG_DAN_GITHUB.md](HUONG_DAN_GITHUB.md). Dưới đây là bản tóm tắt.

> ⚠️ Chọn **Private** (riêng tư). Repo có chứa ngân hàng câu hỏi **kèm đáp án** (`data/`, `supabase/*.sql`). Để công khai thì học sinh có thể tìm ra đáp án.
> Chỉ đưa thư mục **`hoc-vui-lop-2`** lên. **Không** đưa thư mục `sách/` (file PDF sách, rất nặng và có bản quyền).

1. Tạo tài khoản https://github.com → **New repository** → tên `hoc-vui-lop-2` → chọn **Private** → **Create repository** (không tick thêm README).
2. Trong Terminal, tại thư mục `hoc-vui-lop-2`:

   ```bash
   git init
   git add .
   git commit -m "Hoc Vui Lop 2"
   git branch -M main
   git remote add origin https://github.com/TEN-TAI-KHOAN/hoc-vui-lop-2.git
   git push -u origin main
   ```

   (Nếu máy chưa có `git`: macOS gõ `xcode-select --install`; Windows tải tại https://git-scm.com. Hoặc dùng [GitHub Desktop](https://desktop.github.com) nếu thích bấm chuột.)

**B2. Tạo project trên Cloudflare**

1. https://dash.cloudflare.com → menu trái **Compute → Workers & Pages** → **Create application** → kéo xuống cuối trang → **Looking to deploy Pages? Get started** (hoặc mở thẳng https://dash.cloudflare.com/?to=/:account/workers-and-pages/create/pages).
   ⚠️ Không bấm nút *Connect GitHub* ở trang đầu tiên, vì nút đó tạo **Worker**, không phải Pages.
2. Cạnh **Import an existing Git repository** bấm **Get started** → tab **GitHub** → **Connect GitHub** (hoặc **+ Add account**).
3. Cửa sổ GitHub mở ra → chọn tài khoản của bạn → **Only select repositories** → chọn `hoc-vui-lop-2` → **Install & Authorize**.
4. Quay lại Cloudflare (không thấy repo thì tải lại trang) → chọn repo `hoc-vui-lop-2` → **Begin setup**.
5. Cấu hình build:

   | Mục | Giá trị |
   |---|---|
   | Project name | `hoc-vui-lop-2` |
   | Production branch | `main` |
   | Framework preset | `None` (hoặc `React (Vite)`) |
   | Build command | `npm run build` |
   | Build output directory | `dist` |
   | Root directory | để trống (vì repo chính là thư mục `hoc-vui-lop-2`) |

6. Mở **Environment variables (advanced)** → thêm 3 biến:

   | Variable name | Value |
   |---|---|
   | `VITE_SUPABASE_URL` | `https://abcdefghijkl.supabase.co` |
   | `VITE_SUPABASE_ANON_KEY` | `sb_publishable_xxxxxxxxxxxx` |
   | `NODE_VERSION` | `22` |

7. **Save and Deploy** → đợi 2–3 phút → có link `https://hoc-vui-lop-2.pages.dev`.

**Cập nhật lần sau:** sửa code → `git add . && git commit -m "cap nhat" && git push` → Cloudflare tự build lại sau vài phút.

> Đổi biến môi trường (ví dụ đổi key) trong **Settings → Variables and Secrets / Environment variables** xong phải vào **Deployments** → **Retry deployment** thì mới có hiệu lực.

### Cách C — Lệnh `wrangler`

```bash
npm run build
npx wrangler login                                              # mở trình duyệt để đăng nhập Cloudflare (1 lần)
npx wrangler pages project create hoc-vui-lop-2 --production-branch main   # chỉ lần đầu
npx wrangler pages deploy dist --project-name hoc-vui-lop-2
```

Cập nhật lần sau chỉ cần: `npm run build && npx wrangler pages deploy dist --project-name hoc-vui-lop-2`.

---

## 4. Kiểm tra và bắt đầu dùng

### 4.1. Danh sách kiểm tra sau khi lên mạng

- [ ] Mở `https://<tên-web>.pages.dev` → thấy trang **chọn tên học sinh**, **không có** dải vàng “bản demo”.
- [ ] Mở `https://<tên-web>.pages.dev/admin` → đăng nhập bằng tài khoản admin → vào được **Tổng quan**.
- [ ] Tải lại trang (F5) khi đang ở `/admin` hoặc `/home` → **không** bị lỗi 404.
- [ ] **Ngân hàng câu hỏi** → lọc **Ngân hàng: Archimes** → thấy khoảng 2.545 câu (nếu đã nạp).
- [ ] Trang chủ học sinh có nút lọc **🌱 Kỹ năng sống** và **🔬 Khoa học** (nếu đã nạp `ky_nang_khoa_hoc.sql`).
- [ ] Mở web trên **điện thoại**, thử làm 1 bài.

### 4.2. Thiết lập lớp học

1. **Học sinh** → **Thêm học sinh** → dán danh sách lớp (mỗi dòng một họ tên) → **Lưu**. Hoặc **Nhập danh sách** từ file Excel.
2. **Tổng quan** → chỉnh **Tuần học hiện tại** cho đúng tuần của lớp (bài Archimes, bài mẫu, Kỹ năng sống và Khoa học đều mở theo tuần).
3. **Cài đặt**:
   - Sửa **tên lớp**, **năm học**.
   - Khi đã nhập đủ danh sách lớp, nên **tắt “Cho phép học sinh tự thêm tên”**.
   - Chép **Link cho học sinh** → gửi vào nhóm Zalo của lớp. **Chỉ cần gửi 1 lần**: bài mới sẽ tự hiện trong link đó.

### 4.3. Nạp ngân hàng Archimes bằng CSV (nếu bước 1.3 lỗi)

1. Đăng nhập trang admin trên web → **Nhập CSV / Excel**.
2. Kéo thả file **`data/archimes.csv`** (nằm trong thư mục dự án trên máy bạn).
3. Tick **Tự tạo bài học chưa có** và **Công bố bài mới (mở theo tuần)** → kiểm tra số dòng hợp lệ → **Lưu**.
4. Đợi thanh tiến trình chạy hết (khoảng 1 phút). Tên file có chữ “archimes” nên câu hỏi được gắn đúng nhãn **Archimes**.

> Chỉ nạp **một** trong hai cách (SQL **hoặc** CSV). Nếu lỡ nạp cả hai, trang Nhập sẽ báo các dòng **trùng** và tự bỏ qua.

---

## 5. Tên miền riêng (không bắt buộc)

Link `https://….pages.dev` là **miễn phí vĩnh viễn**, dùng cho lớp học là đủ.
Nếu muốn link đẹp như `https://lop2a1.vn` (phải mua tên miền, khoảng 200.000–800.000 đ/năm):
Cloudflare → project → **Custom domains** → **Set up a custom domain** → làm theo hướng dẫn trỏ DNS.

---

## 6. Giữ Supabase luôn chạy (quan trọng khi nghỉ lễ, nghỉ hè)

Gói Free của Supabase **tự tạm dừng project nếu khoảng 7 ngày gần như không có ai dùng**. Trước khi dừng, Supabase gửi email cảnh báo.

- **Khi bị tạm dừng:** vào https://supabase.com/dashboard → chọn project → **Restore project**. Đợi vài phút là chạy lại, **dữ liệu vẫn còn nguyên**.
- **Trong năm học:** học sinh vào làm bài hằng ngày là đủ hoạt động, thường không bị dừng.
- **Tránh bị dừng khi nghỉ dài (tuỳ chọn, cần dùng Cách B có GitHub):** trong repo, tạo file `.github/workflows/keep-alive.yml`:

  ```yaml
  name: Giu Supabase hoat dong
  on:
    schedule:
      - cron: "0 1 */2 * *"   # 8h sáng (giờ VN), 2 ngày một lần
    workflow_dispatch:
  jobs:
    ping:
      runs-on: ubuntu-latest
      steps:
        - run: |
            curl -sf -X POST "${{ secrets.SUPABASE_URL }}/rest/v1/rpc/get_public_config" \
              -H "apikey: ${{ secrets.SUPABASE_KEY }}" \
              -H "Content-Type: application/json" -d '{}'
  ```

  Rồi vào GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**, thêm
  `SUPABASE_URL` (Project URL) và `SUPABASE_KEY` (publishable key). Vào tab **Actions** bấm **Run workflow** để thử.
  (Lệnh chỉ đọc cấu hình lớp, không thay đổi dữ liệu.)

---

## 7. Sao lưu dữ liệu

Gói Free không có sao lưu tự động dài ngày. Nên định kỳ (ví dụ cuối mỗi tháng) vào trang admin bấm **Xuất CSV** ở:
**Ngân hàng câu hỏi**, **Học sinh**, **Kết quả làm bài** và lưu các file vào Google Drive.

---

## 8. Giới hạn miễn phí (đủ dư cho 1 lớp)

| Dịch vụ | Giới hạn gói Free | Một lớp ~40 học sinh dùng khoảng |
|---|---|---|
| Supabase database | 500 MB | dưới 20 MB/năm (kể cả ngân hàng Archimes) |
| Supabase băng thông | 5 GB/tháng | vài chục MB/tháng |
| Cloudflare Pages | Không giới hạn lượt truy cập và băng thông; 500 lần build/tháng | — |

---

## 9. Xử lý sự cố thường gặp

| Hiện tượng | Nguyên nhân | Cách sửa |
|---|---|---|
| Web trên mạng vẫn hiện dải vàng **“bản demo”** | Lúc build chưa có thông tin Supabase | Cách A/C: kiểm tra `.env.local` → `npm run build` lại → upload lại `dist`. Cách B: kiểm tra 2 biến `VITE_…` trong Cloudflare → **Retry deployment**. |
| Đăng nhập báo **“Sai email hoặc mật khẩu”** | Sai thông tin, hoặc user chưa được xác nhận | Supabase → **Authentication → Users**: kiểm tra email; nếu cột xác nhận trống thì xoá user, tạo lại và tick **Auto Confirm User**. Quên mật khẩu: chọn user → đặt lại mật khẩu. |
| Đăng nhập được nhưng báo **chưa có quyền admin** | Chưa chạy lệnh cấp quyền | Chạy lại lệnh `insert into public.admins …` ở bước 1.5 (đúng email). |
| Báo lỗi **Invalid API key** / không tải được dữ liệu | Dán nhầm key, thiếu ký tự, hoặc dùng secret key | Copy lại **Publishable key** ở **Project Settings → API Keys**, build/deploy lại. |
| Tải lại trang `/admin` bị **404** | Thiếu file `_redirects` | Kéo thả **cả thư mục `dist`** (trong đó có file `_redirects`), không kéo từng file lẻ. |
| Cloudflare **build lỗi** (cách B) | Sai thư mục gốc hoặc phiên bản Node | Kiểm tra **Root directory** (để trống nếu repo là thư mục `hoc-vui-lop-2`), **Build output** = `dist`, biến `NODE_VERSION` = `22`. Xem chi tiết trong log build. |
| Học sinh **không thấy bài** | Bài chưa công bố, hoặc tuần hiện tại chưa tới | Admin → **Tổng quan**: chỉnh **Tuần học hiện tại**. **Bài học & lịch mở**: bật công bố. |
| Nút làm bài hiện **“Chưa đến giờ”** / **“Mai làm tiếp”** / **“Tuần sau làm tiếp”** | Ngoài giờ làm bài, hoặc đã làm đủ số đề của môn hôm nay / tuần này | Admin → **Cài đặt** → **Giờ làm bài** / **Lượng bài mỗi ngày / mỗi tuần** (tắt hoặc nới ra). Môn có cài đặt riêng: **Bài học → Cài đặt môn**. |
| Admin báo **“Database chưa chạy 0006”**, không thấy các mục điểm/sao/giờ làm bài trong Cài đặt | Chưa chạy `0006_learning_rules.sql` | Chạy file đó trong SQL Editor (bước 1.2), tải lại trang. |
| Web báo lỗi kết nối, tất cả đều không chạy | Supabase bị tạm dừng do lâu không dùng | Supabase dashboard → **Restore project** (xem mục 6). |
| SQL Editor báo lỗi khi chạy `archimes.sql` | File lớn | Dùng cách nạp CSV ở mục 4.3. |

---

## 10. Nhắc lại về bảo mật

- ✅ Chỉ dùng **Publishable/anon key** cho web. Không bao giờ dán **Secret/service_role key** vào `.env.local` hay Cloudflare.
- ✅ Đã **tắt đăng ký tự do** (bước 1.4); chỉ tài khoản có trong bảng `admins` mới vào được trang quản trị.
- ✅ Repo GitHub để **Private**. **Không** đặt file đáp án (`data/archimes.csv`…) vào thư mục `public/`.
- ✅ Đáp án được chấm trên Supabase, trình duyệt của học sinh không nhận đáp án trước khi nộp.
- ✅ Mật khẩu admin nên dài, khác mật khẩu email.
