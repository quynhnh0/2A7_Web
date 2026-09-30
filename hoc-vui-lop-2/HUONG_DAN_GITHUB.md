# Hướng dẫn đưa code “Học Vui Lớp 2” lên GitHub

GitHub là nơi cất code miễn phí, có lịch sử từng lần sửa. Đưa code lên GitHub giúp bạn:

- Không mất code khi hỏng máy.
- Cho Cloudflare Pages **tự build lại web** mỗi lần bạn sửa code (Cách B trong [HUONG_DAN_DEPLOY.md](HUONG_DAN_DEPLOY.md)).
- Chạy GitHub Action “giữ Supabase không bị tạm dừng” (mục 6 trong [HUONG_DAN_DEPLOY.md](HUONG_DAN_DEPLOY.md)).

Có 3 cách, chọn **một** cách:

| Cách | Hợp với ai | Độ khó |
|---|---|---|
| **A. GitHub CLI (`gh`)** — khuyên dùng trên máy Mac này | Quen gõ vài lệnh trong Terminal | ⭐ (ít bước nhất) |
| **B. Tạo repo trên web + lệnh `git`** | Muốn hiểu từng bước | ⭐⭐ |
| **C. GitHub Desktop** | Chỉ muốn bấm chuột | ⭐ |

---

## 0. Ba điều phải nhớ trước khi bắt đầu

> ⚠️ **1. Repo phải để Private (riêng tư).**
> Code có chứa ngân hàng câu hỏi **kèm đáp án** (`data/`, `supabase/*.sql`). Để Public thì ai cũng xem được đáp án.

> ⚠️ **2. Chỉ đưa thư mục `hoc-vui-lop-2` lên, không đưa thư mục cha.**
> Mọi lệnh bên dưới đều chạy **bên trong** `hoc-vui-lop-2`. Tuyệt đối không chạy `git init` ở thư mục `stitch_web_b_i_t_p_l_p_2`, vì như vậy sẽ kéo theo thư mục `sách/` (PDF có bản quyền, rất nặng) và các bản thiết kế.

> ⚠️ **3. Không đưa file bí mật lên.**
> File `.gitignore` đã chặn sẵn: `.env.local`, `.env`, `node_modules/`, `dist/`, `.DS_Store`. Đừng xoá các dòng này.

---

## 1. Chuẩn bị (làm 1 lần)

### 1.1. Tạo tài khoản GitHub

Vào https://github.com → **Sign up** → làm theo hướng dẫn (email, mật khẩu, tên tài khoản). Ghi nhớ **tên tài khoản** (username), ví dụ `quangminh-dev`.

### 1.2. Kiểm tra máy đã có `git`

Mở **Terminal** (nhấn `⌘ + Space` → gõ `Terminal` → Enter), gõ:

```bash
git --version
```

- Thấy `git version 2.x.x` là được.
- Nếu hiện hộp thoại đòi cài “command line developer tools” → bấm **Install**, đợi xong rồi gõ lại.

### 1.3. Khai báo tên và email (máy này đã khai báo sẵn, có thể bỏ qua)

```bash
git config --global user.name "Quang Minh"
git config --global user.email "email-cua-ban@gmail.com"
```

Tên/email này sẽ hiện ở mỗi lần lưu (commit). Muốn giấu email thật, dùng email dạng `ID+username@users.noreply.github.com` lấy trong GitHub → **Settings → Emails**.

### 1.4. Di chuyển vào thư mục dự án

```bash
cd ~/Downloads/stitch_web_b_i_t_p_l_p_2/hoc-vui-lop-2
```

Kiểm tra đúng chỗ: gõ `ls`, phải thấy `package.json`, `src`, `supabase`, `README.md`.

---

## 2. Cách A — GitHub CLI (khuyên dùng)

`gh` là công cụ dòng lệnh chính chủ của GitHub. Nó tự lo phần đăng nhập, tạo repo và đẩy code, không cần tạo token bằng tay.

**A1. Cài `gh`** (máy đã có Homebrew):

```bash
brew install gh
```

**A2. Đăng nhập GitHub** (kèm quyền `workflow` để sau này đẩy được file GitHub Action giữ Supabase chạy):

```bash
gh auth login --scopes workflow
```

Trả lời lần lượt:

| Câu hỏi | Chọn |
|---|---|
| Where do you use GitHub? | `GitHub.com` |
| What is your preferred protocol for Git operations on this host? | `HTTPS` |
| Authenticate Git with your GitHub credentials? | `Yes` |
| How would you like to authenticate GitHub CLI? | `Login with a web browser` |

Terminal hiện một **mã 8 ký tự** (ví dụ `ABCD-1234`) → nhấn Enter → trình duyệt mở ra → dán mã → **Authorize**. Quay lại Terminal thấy `✓ Logged in as ...` là xong.

**A3. Lưu code lần đầu (commit):**

```bash
git init -b main
git add .
git status
```

Xem kỹ danh sách `git status` in ra (xem [mục 5](#5-kiểm-tra-trước-khi-đẩy-lên)): **không được** có `node_modules/`, `dist/`, `.env.local`. Nếu ổn:

```bash
git commit -m "Hoc Vui Lop 2 - ban dau"
```

**A4. Tạo repo Private và đẩy code lên — 1 lệnh:**

```bash
gh repo create hoc-vui-lop-2 --private --source=. --remote=origin --push
```

Thấy dòng `✓ Created repository .../hoc-vui-lop-2 on GitHub` và `✓ Pushed commits` là xong. Mở xem trên web:

```bash
gh repo view --web
```

Trên trang repo phải thấy nhãn **Private** cạnh tên repo.

---

## 3. Cách B — Tạo repo trên web + lệnh `git`

**B1. Tạo repo trống trên GitHub**

1. Đăng nhập https://github.com → bấm dấu **+** góc trên phải → **New repository**.
2. Điền:
   - **Repository name:** `hoc-vui-lop-2`
   - Chọn **Private** ⚠️
   - **Không** tick *Add a README file*, để *.gitignore* và *license* là **None**. (Repo phải trống hoàn toàn, nếu không lúc đẩy sẽ bị lỗi `rejected`.)
3. Bấm **Create repository**. GitHub hiện trang hướng dẫn có đường dẫn dạng `https://github.com/TEN-TAI-KHOAN/hoc-vui-lop-2.git` → copy lại.

**B2. Tạo mã truy cập (Personal Access Token)**

GitHub **không nhận mật khẩu tài khoản** khi đẩy code bằng Terminal. Phải dùng token thay mật khẩu.

1. GitHub → ảnh đại diện góc trên phải → **Settings** → cuối menu trái chọn **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**.
2. Điền:
   - **Token name:** `mac-hoc-vui-lop-2`
   - **Expiration:** 90 ngày (hoặc 1 năm)
   - **Repository access:** *Only select repositories* → chọn `hoc-vui-lop-2`
   - **Permissions → Repository permissions:**
     - **Contents:** `Read and write` (bắt buộc — để đẩy code)
     - **Workflows:** `Read and write` (nếu sẽ dùng GitHub Action giữ Supabase chạy)
3. **Generate token** → **copy ngay** chuỗi `github_pat_...` (đóng trang là không xem lại được). Cất vào nơi an toàn, **không** dán vào file nào trong dự án.

**B3. Lưu code và đẩy lên**

Trong Terminal, tại thư mục `hoc-vui-lop-2`:

```bash
git init -b main
git add .
git status
```

Kiểm tra theo [mục 5](#5-kiểm-tra-trước-khi-đẩy-lên), ổn thì:

```bash
git commit -m "Hoc Vui Lop 2 - ban dau"
git remote add origin https://github.com/TEN-TAI-KHOAN/hoc-vui-lop-2.git
git push -u origin main
```

Khi Terminal hỏi:

- `Username for 'https://github.com':` → gõ **tên tài khoản** GitHub.
- `Password for '...':` → **dán token** `github_pat_...` (không phải mật khẩu GitHub). Lúc dán sẽ không thấy ký tự nào hiện ra, cứ nhấn Enter.

macOS sẽ lưu token vào **Keychain**, lần sau không hỏi lại. Khi token hết hạn: tạo token mới, mở ứng dụng **Keychain Access** → tìm `github.com` → xoá mục cũ → `git push` lại và dán token mới.

---

## 4. Cách C — GitHub Desktop (bấm chuột)

1. Tải và cài https://desktop.github.com → mở lên → **Sign in to GitHub.com** → đăng nhập trên trình duyệt → quay lại app.
2. Menu **File → Add Local Repository…** → **Choose…** → chọn thư mục `hoc-vui-lop-2` → **Add Repository**.
3. App báo *“This directory does not appear to be a Git repository”* → bấm **create a repository** (dòng chữ xanh):
   - **Name:** `hoc-vui-lop-2`
   - **Git ignore:** để **None** (dự án đã có sẵn `.gitignore`)
   - **License:** None
   - **Create Repository**.
4. Cột trái **Changes**: xem danh sách file theo [mục 5](#5-kiểm-tra-trước-khi-đẩy-lên). Ô **Summary** gõ `Hoc Vui Lop 2 - ban dau` → **Commit to main**.
5. Bấm **Publish repository** (thanh trên cùng) → **giữ nguyên tick “Keep this code private”** ⚠️ → **Publish Repository**.

Lần sau sửa code: mở GitHub Desktop → gõ Summary → **Commit to main** → **Push origin**.

---

## 5. Kiểm tra trước khi đẩy lên

Sau `git add .`, chạy lệnh sau. **Không in ra gì** nghĩa là an toàn:

```bash
git ls-files --cached | grep -E '^node_modules/|^dist/|\.env$|\.env\.local$|\.pdf$'
```

Nếu in ra file nào → **dừng lại**, đừng commit, xem [mục 8](#8-xử-lý-sự-cố).

Danh sách file **nên có** trên GitHub:

| Có | Không có |
|---|---|
| `src/`, `public/`, `scripts/`, `supabase/`, `data/` | `node_modules/` (tự cài lại bằng `npm install`) |
| `package.json`, `package-lock.json` | `dist/` (Cloudflare tự build) |
| `.env.example` (file mẫu, không có key thật) | `.env.local` (chứa key thật) |
| `.gitignore`, `.node-version`, `README.md`, `HUONG_DAN_*.md` | PDF sách, `.DS_Store` |
| `vite.config.ts`, `tsconfig*.json`, `index.html` | |

Cả dự án chỉ khoảng 4 MB, đẩy lên mất vài giây.

---

## 6. Công việc hằng ngày sau khi đã lên GitHub

Mỗi lần sửa code xong, trong thư mục `hoc-vui-lop-2`:

```bash
git status                           # xem file nào đã đổi
git add .
git commit -m "Them cau hoi tuan 5"  # mô tả ngắn điều đã sửa
git push
```

- Nếu Cloudflare Pages đã nối với repo, **2–3 phút sau web tự cập nhật**.
- Sửa trên máy khác (hoặc sửa trực tiếp trên web GitHub) thì trước khi làm tiếp trên máy này, chạy `git pull` để lấy bản mới nhất về.
- Xem lịch sử: `git log --oneline` hoặc tab **Commits** trên trang repo.
- Lỡ sửa hỏng 1 file mà **chưa commit**, muốn quay về bản đã lưu gần nhất: `git restore ten-file`.

### Lấy code về máy khác

```bash
gh repo clone TEN-TAI-KHOAN/hoc-vui-lop-2     # hoặc: git clone https://github.com/TEN-TAI-KHOAN/hoc-vui-lop-2.git
cd hoc-vui-lop-2
npm install
cp .env.example .env.local                    # rồi điền lại 2 biến Supabase
npm run dev
```

### Cho người khác cùng sửa (ví dụ cô giáo chủ nhiệm)

Trang repo → **Settings** → **Collaborators** → **Add people** → nhập username/email của họ. Repo Private thì chỉ người được mời mới xem được.

---

## 7. Bước tiếp theo sau khi code đã lên GitHub

1. **Nối Cloudflare Pages với repo** để web tự cập nhật: làm theo **Cách B, bước B2** trong [HUONG_DAN_DEPLOY.md](HUONG_DAN_DEPLOY.md#cách-b--kết-nối-github-tự-động-cập-nhật).
   Lần đầu Cloudflare hỏi quyền truy cập GitHub → chọn **Only select repositories** → `hoc-vui-lop-2`.
2. **(Nên làm) Bật GitHub Action giữ Supabase chạy**: làm theo mục 6 trong [HUONG_DAN_DEPLOY.md](HUONG_DAN_DEPLOY.md#6-giữ-supabase-luôn-chạy-quan-trọng-khi-nghỉ-lễ-nghỉ-hè).
   Thêm 2 secret tại repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**: `SUPABASE_URL` và `SUPABASE_KEY` (publishable key).
   Repo Private trên gói Free có 2.000 phút Actions/tháng; job này chạy vài giây mỗi lần nên dư dùng.

---

## 8. Xử lý sự cố

| Lỗi / hiện tượng | Nguyên nhân | Cách sửa |
|---|---|---|
| `fatal: not a git repository` | Đang đứng sai thư mục | `cd ~/Downloads/stitch_web_b_i_t_p_l_p_2/hoc-vui-lop-2` rồi chạy lại |
| `Support for password authentication was removed` | Gõ mật khẩu GitHub thay vì token | Dùng token (Cách B, bước B2) hoặc chuyển sang Cách A |
| `remote: Repository not found` | Sai đường dẫn repo, hoặc token không được cấp quyền repo này | Kiểm tra `git remote -v`; tạo lại token chọn đúng repo `hoc-vui-lop-2` |
| `Permission denied` / `403` | Token thiếu quyền **Contents: Read and write**, hoặc đang đăng nhập nhầm tài khoản | Tạo token mới đủ quyền; xoá mục `github.com` cũ trong Keychain Access |
| `refusing to allow ... to create or update workflow ... without workflow scope` | Đẩy file `.github/workflows/...` nhưng thiếu quyền workflow | Cách A: `gh auth refresh -s workflow`. Cách B: token phải có **Workflows: Read and write** |
| `! [rejected] main -> main (fetch first)` | Lúc tạo repo đã tick *Add a README* nên repo không trống | Repo mới tạo, chưa có gì quan trọng: xoá repo trên GitHub (**Settings → Danger Zone → Delete this repository**) rồi tạo lại **không** tick README, sau đó `git push -u origin main` |
| `error: remote origin already exists` | Đã `git remote add` trước đó | `git remote set-url origin https://github.com/TEN-TAI-KHOAN/hoc-vui-lop-2.git` |
| `error: src refspec main does not match any` | Chưa commit lần nào | Chạy `git add .` và `git commit -m "..."` trước khi `push` |
| `git status` thấy `node_modules/` hoặc `dist/` | File `.gitignore` bị xoá/sửa | Khôi phục `.gitignore` (có các dòng `node_modules`, `dist`, `.env.local`), rồi `git rm -r --cached node_modules dist` |
| Lỡ commit `.env.local` | — | `git rm --cached .env.local` → `git commit -m "bo env"` → `git push`. File vẫn còn trong lịch sử cũ; nếu trong đó là **publishable key** thì không nguy hiểm (key này vốn nằm trong web). Nếu lỡ là **secret/service_role key** → vào Supabase **đổi key ngay** |
| Lỡ tạo repo **Public** | — | Repo → **Settings** → **General** → cuối trang **Danger Zone** → **Change repository visibility** → **Make private** |
| Lỡ `git init` ở thư mục cha (`stitch_web_b_i_t_p_l_p_2`) | — | **Chưa push:** xoá thư mục ẩn `.git` ở thư mục cha: `rm -rf ~/Downloads/stitch_web_b_i_t_p_l_p_2/.git` rồi làm lại từ mục 1.4. **Đã push:** xoá repo trên GitHub, xoá `.git` như trên, làm lại |

Xem thư mục/file ẩn trong Finder: nhấn `⌘ + Shift + .`
