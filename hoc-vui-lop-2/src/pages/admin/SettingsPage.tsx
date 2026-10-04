import { useEffect, useState, type FormEvent } from 'react';
import { AlertTriangle, Check, Copy, RotateCcw, Save } from 'lucide-react';
import { PageHeader } from '../../components/admin';
import { AdminError, LoadingBlock, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { isDemoMode } from '../../lib/backend';
import { RETAKE_LABEL, WEEKDAY_LABEL } from '../../lib/text';
import type { AppSettings, RetakeMode, WeekSchedule } from '../../types';

type NumKey =
  | 'current_week' | 'basic_easy' | 'basic_normal' | 'basic_advanced' | 'adv_easy' | 'adv_normal' | 'adv_advanced'
  | 'points_easy' | 'points_normal' | 'points_advanced' | 'adv_points_easy' | 'adv_points_normal' | 'adv_points_advanced'
  | 'wrong_penalty' | 'daily_max_lessons' | 'weekly_max_lessons' | 'stars_per_diamond' | 'medal_gold_pct' | 'medal_silver_pct' | 'medal_bronze_pct'
  | 'adapt_min_answers' | 'adapt_up_pct' | 'adapt_down_pct';

const LIMITS: Partial<Record<NumKey, [number, number]>> = {
  current_week: [1, 60],
  wrong_penalty: [0, 100],
  weekly_max_lessons: [0, 300],
  stars_per_diamond: [1, 100000],
  medal_gold_pct: [0, 100],
  medal_silver_pct: [0, 100],
  medal_bronze_pct: [0, 100],
  adapt_min_answers: [1, 10000],
  adapt_up_pct: [0, 100],
  adapt_down_pct: [0, 100],
};
const limitOf = (k: NumKey): [number, number] => LIMITS[k] ?? (k.includes('points') ? [0, 1000] : [0, 50]);

const DAYS = ['1', '2', '3', '4', '5', '6', '7'] as const;
const TIME_RE = /^([01]?\d|2[0-3]):[0-5]\d$|^24:00$/;

export default function SettingsPage() {
  const { data, error, loading, reload } = useAsync(() => adminApi.getSettings(), []);
  const [form, setForm] = useState<AppSettings | null>(null);
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState<unknown>(null);
  const [saved, setSaved] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (data) setForm(data);
  }, [data]);

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;
  if (!form) return null;

  // Database chưa chạy 0006 thì chưa có các cột mới => chỉ hiện/lưu cài đặt cũ.
  const hasRules = data != null && 'wrong_penalty' in data;
  const hasWeekly = data != null && 'weekly_max_lessons' in data;
  const studentLink = `${location.origin}/`;
  const setNum = (k: NumKey, v: string) => {
    const [min, max] = limitOf(k);
    setForm({ ...form, [k]: Math.max(min, Math.min(max, Number(v) || 0)) });
  };
  const schedule: WeekSchedule = form.schedule ?? {};
  const setDay = (d: (typeof DAYS)[number], value: [string, string] | null) => {
    const next = { ...schedule };
    if (value) next[d] = value;
    else delete next[d];
    setForm({ ...form, schedule: next });
  };
  const badDays = DAYS.filter((d) => {
    const w = schedule[d];
    return w && (!TIME_RE.test(w[0]) || !TIME_RE.test(w[1]) || w[0].padStart(5, '0') >= w[1].padStart(5, '0'));
  });
  const badMedals = hasRules && !(form.medal_gold_pct >= form.medal_silver_pct && form.medal_silver_pct >= form.medal_bronze_pct);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (badDays.length || badMedals) return;
    setBusy(true);
    setSaveError(null);
    setSaved(false);
    try {
      const patch: Partial<AppSettings> = {
        class_name: form.class_name.trim() || 'Lớp 2',
        school_year: form.school_year.trim(),
        current_week: Math.max(1, form.current_week),
        leaderboard_enabled: form.leaderboard_enabled,
        allow_self_register: form.allow_self_register,
        basic_easy: form.basic_easy,
        basic_normal: form.basic_normal,
        basic_advanced: form.basic_advanced,
        adv_easy: form.adv_easy,
        adv_normal: form.adv_normal,
        adv_advanced: form.adv_advanced,
        points_easy: Math.max(1, form.points_easy),
        points_normal: Math.max(1, form.points_normal),
        points_advanced: Math.max(1, form.points_advanced),
      };
      if (hasRules) {
        Object.assign(patch, {
          adv_points_easy: Math.max(1, form.adv_points_easy),
          adv_points_normal: Math.max(1, form.adv_points_normal),
          adv_points_advanced: Math.max(1, form.adv_points_advanced),
          wrong_penalty: form.wrong_penalty,
          score_floor_zero: form.score_floor_zero,
          retake_mode: form.retake_mode,
          daily_max_lessons: form.daily_max_lessons,
          stars_per_diamond: Math.max(1, form.stars_per_diamond),
          medal_gold_pct: form.medal_gold_pct,
          medal_silver_pct: form.medal_silver_pct,
          medal_bronze_pct: form.medal_bronze_pct,
          medal_include_advanced: form.medal_include_advanced,
          schedule_enabled: form.schedule_enabled,
          schedule: Object.fromEntries(Object.entries(schedule).map(([d, w]) => [d, [w![0].padStart(5, '0'), w![1].padStart(5, '0')]])),
          adapt_min_answers: form.adapt_min_answers,
          adapt_up_pct: form.adapt_up_pct,
          adapt_down_pct: form.adapt_down_pct,
        } satisfies Partial<AppSettings>);
      }
      if (hasWeekly) patch.weekly_max_lessons = form.weekly_max_lessons;
      await adminApi.updateSettings(patch);
      setSaved(true);
      reload();
    } catch (err) {
      setSaveError(err);
    } finally {
      setBusy(false);
    }
  };

  const copyLink = async () => {
    try {
      await navigator.clipboard.writeText(studentLink);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      prompt('Sao chép đường link này:', studentLink);
    }
  };

  const resetDemo = async () => {
    if (!confirm('Xoá toàn bộ dữ liệu demo trong trình duyệt này và tạo lại dữ liệu mẫu?')) return;
    const { resetDemoData } = await import('../../lib/backend/demoBackend');
    await resetDemoData();
    location.href = '/admin/login';
  };

  const basicTotal = form.basic_easy + form.basic_normal + form.basic_advanced;
  const advTotal = form.adv_easy + form.adv_normal + form.adv_advanced;
  const numInput = (k: NumKey, label: string, suffix?: string) => (
    <div>
      <label className="label" htmlFor={`set-${k}`}>{label}</label>
      <div className="flex items-center gap-2">
        <input id={`set-${k}`} type="number" min={limitOf(k)[0]} max={limitOf(k)[1]} className="input" value={form[k]} onChange={(e) => setNum(k, e.target.value)} />
        {suffix && <span className="text-sm whitespace-nowrap text-slate-500">{suffix}</span>}
      </div>
    </div>
  );
  const check = (k: 'allow_self_register' | 'leaderboard_enabled' | 'score_floor_zero' | 'medal_include_advanced' | 'schedule_enabled', title: string, hint: string) => (
    <label className="flex items-start gap-2 text-sm">
      <input type="checkbox" className="mt-1" checked={form[k]} onChange={(e) => setForm({ ...form, [k]: e.target.checked })} />
      <span><b>{title}</b><span className="block text-xs text-slate-500">{hint}</span></span>
    </label>
  );

  return (
    <form onSubmit={submit} className="space-y-5">
      <PageHeader
        title="Cài đặt"
        actions={
          <button type="submit" className="btn btn-primary" disabled={busy || badDays.length > 0 || badMedals}>
            {busy ? <Spinner className="h-4 w-4 text-white" /> : saved ? <Check className="h-4 w-4" /> : <Save className="h-4 w-4" />} {saved ? 'Đã lưu' : 'Lưu cài đặt'}
          </button>
        }
      />
      {saveError !== null && <AdminError error={saveError} />}
      {!hasRules && (
        <div className="flex items-start gap-3 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
          <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0" />
          <p>Database chưa chạy <code>0006_learning_rules.sql</code> nên chưa có các cài đặt mới (trừ điểm, giới hạn mỗi ngày, giờ làm bài, sao/kim cương, huy chương). Xem HUONG_DAN_DEPLOY.md.</p>
        </div>
      )}

      <section className="panel space-y-4 p-5">
        <h2 className="font-semibold text-slate-900">Lớp học</h2>
        <div className="grid gap-4 sm:grid-cols-3">
          <div>
            <label className="label" htmlFor="set-class">Tên lớp</label>
            <input id="set-class" className="input" maxLength={60} value={form.class_name} onChange={(e) => setForm({ ...form, class_name: e.target.value })} />
          </div>
          <div>
            <label className="label" htmlFor="set-year">Năm học</label>
            <input id="set-year" className="input" maxLength={30} value={form.school_year} onChange={(e) => setForm({ ...form, school_year: e.target.value })} />
          </div>
          {numInput('current_week', 'Tuần học hiện tại')}
        </div>
        <div>
          <span className="label">Link cho học sinh</span>
          <div className="flex gap-2">
            <input className="input font-mono text-sm" readOnly value={studentLink} aria-label="Link cho học sinh" onFocus={(e) => e.target.select()} />
            <button type="button" className="btn btn-secondary" onClick={copyLink}>{copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />} {copied ? 'Đã chép' : 'Chép'}</button>
          </div>
          <p className="mt-1 text-xs text-slate-500">Gửi link này vào nhóm Zalo của lớp. Học sinh chọn tên mình là vào học, không cần mật khẩu.</p>
        </div>
        {check('allow_self_register', 'Cho phép học sinh tự thêm tên', 'Tắt đi nếu thầy cô đã nhập đủ danh sách lớp và không muốn có tên lạ.')}
        {check('leaderboard_enabled', 'Hiện bảng xếp hạng cho học sinh', 'Xếp hạng theo ngày, tuần (thứ Hai – Chủ nhật) và tháng.')}
      </section>

      <section className="panel space-y-4 p-5">
        <div>
          <h2 className="font-semibold text-slate-900">Số câu mỗi đề</h2>
          <p className="text-sm text-slate-500">Mỗi lần làm, hệ thống chọn ngẫu nhiên câu hỏi theo tỉ lệ này (ưu tiên câu bạn đó chưa gặp). Mỗi môn có thể đặt riêng ở trang <b>Bài học → Cài đặt môn</b>.</p>
        </div>
        <div className="grid gap-5 lg:grid-cols-2">
          <div className="rounded-xl bg-sky-50 p-4">
            <p className="mb-3 font-medium text-slate-800">Bài cơ bản · {basicTotal} câu</p>
            <div className="grid grid-cols-3 gap-3">
              {numInput('basic_easy', 'Dễ')}
              {numInput('basic_normal', 'Vừa')}
              {numInput('basic_advanced', 'Khó')}
            </div>
          </div>
          <div className="rounded-xl bg-amber-50 p-4">
            <p className="mb-3 font-medium text-slate-800">Bài nâng cao · {advTotal} câu</p>
            <div className="grid grid-cols-3 gap-3">
              {numInput('adv_easy', 'Dễ')}
              {numInput('adv_normal', 'Vừa')}
              {numInput('adv_advanced', 'Khó')}
            </div>
          </div>
        </div>
        {(basicTotal === 0 || advTotal === 0) && <p className="text-sm text-rose-600">Mỗi loại bài cần ít nhất 1 câu.</p>}
      </section>

      <section className="panel space-y-4 p-5">
        <div>
          <h2 className="font-semibold text-slate-900">Điểm</h2>
          <p className="text-sm text-slate-500">
            Điểm của <b>lần làm đầu tiên</b> mỗi đề (tính bảng xếp hạng). Chênh lệch nhỏ để các bạn bám sát nhau; trừ điểm câu sai để các con cẩn thận hơn.
            Thay đổi chỉ áp dụng cho các bài làm sau này.
          </p>
        </div>
        <div className="grid gap-5 lg:grid-cols-2">
          <div className="rounded-xl bg-sky-50 p-4">
            <p className="mb-3 font-medium text-slate-800">Bài cơ bản: mỗi câu đúng</p>
            <div className="grid grid-cols-3 gap-3">
              {numInput('points_easy', 'Câu dễ')}
              {numInput('points_normal', 'Câu vừa')}
              {numInput('points_advanced', 'Câu khó')}
            </div>
          </div>
          {hasRules && (
            <div className="rounded-xl bg-amber-50 p-4">
              <p className="mb-3 font-medium text-slate-800">Bài nâng cao: mỗi câu đúng</p>
              <div className="grid grid-cols-3 gap-3">
                {numInput('adv_points_easy', 'Câu dễ')}
                {numInput('adv_points_normal', 'Câu vừa')}
                {numInput('adv_points_advanced', 'Câu khó')}
              </div>
            </div>
          )}
        </div>
        {hasRules && (
          <>
            <div className="grid gap-4 sm:grid-cols-3">
              {numInput('wrong_penalty', 'Mỗi câu sai trừ', 'điểm')}
            </div>
            {check('score_floor_zero', 'Điểm mỗi đề thấp nhất là 0', 'Sai nhiều cũng không bị âm điểm (khuyên dùng để các con không nản).')}
            <div>
              <span className="label">Bài làm lại (không tính bảng xếp hạng, chỉ cộng sao)</span>
              <div className="flex flex-col gap-2 sm:flex-row sm:gap-6">
                {(Object.keys(RETAKE_LABEL) as RetakeMode[]).map((m) => (
                  <label key={m} className="flex items-center gap-2 text-sm">
                    <input type="radio" name="retake_mode" checked={form.retake_mode === m} onChange={() => setForm({ ...form, retake_mode: m })} />
                    {RETAKE_LABEL[m]}
                  </label>
                ))}
              </div>
            </div>
          </>
        )}
      </section>

      {hasRules && (
        <>
          <section className="panel space-y-4 p-5">
            <div>
              <h2 className="font-semibold text-slate-900">Lượng bài mỗi ngày / mỗi tuần</h2>
              <p className="text-sm text-slate-500">Vừa đủ, không quá tải. Tính mọi lần bắt đầu đề (cả làm lại); làm tiếp bài đang dở thì không tính thêm. Tuần tính từ thứ Hai đến Chủ nhật. Mỗi môn có thể đặt riêng.</p>
            </div>
            <div className="grid gap-4 sm:grid-cols-3">
              {numInput('daily_max_lessons', 'Mỗi môn tối đa', 'đề / ngày')}
              {hasWeekly && numInput('weekly_max_lessons', 'Mỗi môn tối đa', 'đề / tuần')}
            </div>
            <p className="text-xs text-slate-500">Đặt 0 = không giới hạn. Đặt cả hai thì chạm mức nào trước sẽ dừng ở mức đó.</p>
            {!hasWeekly && <p className="text-xs text-amber-700">Chạy <code>0008_weekly_limit.sql</code> để có giới hạn mỗi tuần.</p>}
          </section>

          <section className="panel space-y-4 p-5">
            <div>
              <h2 className="font-semibold text-slate-900">Giờ làm bài</h2>
              <p className="text-sm text-slate-500">Ngoài giờ, các con vẫn xem được điểm và bảng xếp hạng nhưng không bắt đầu đề mới được (đề đang làm dở vẫn nộp được). Giờ Việt Nam; “24:00” là hết ngày.</p>
            </div>
            {check('schedule_enabled', 'Bật giới hạn giờ làm bài', 'Tắt đi thì làm bài lúc nào cũng được.')}
            <div className={`grid gap-2 ${form.schedule_enabled ? '' : 'pointer-events-none opacity-50'}`}>
              {DAYS.map((d) => {
                const w = schedule[d];
                return (
                  <div key={d} className="flex flex-wrap items-center gap-3 rounded-xl bg-slate-50 px-3 py-2">
                    <label className="flex w-32 items-center gap-2 text-sm font-medium">
                      <input type="checkbox" checked={!!w} onChange={(e) => setDay(d, e.target.checked ? ['17:00', '22:30'] : null)} />
                      {WEEKDAY_LABEL[d]}
                    </label>
                    {w ? (
                      <div className="flex items-center gap-2 text-sm">
                        <input className="input w-24 text-center" inputMode="numeric" aria-label={`${WEEKDAY_LABEL[d]} giờ mở`} value={w[0]} onChange={(e) => setDay(d, [e.target.value, w[1]])} />
                        <span>đến</span>
                        <input className="input w-24 text-center" inputMode="numeric" aria-label={`${WEEKDAY_LABEL[d]} giờ đóng`} value={w[1]} onChange={(e) => setDay(d, [w[0], e.target.value])} />
                        <button type="button" className="btn btn-secondary btn-sm" onClick={() => setDay(d, ['00:00', '24:00'])}>Cả ngày</button>
                      </div>
                    ) : (
                      <span className="text-sm text-slate-500">Nghỉ cả ngày</span>
                    )}
                  </div>
                );
              })}
            </div>
            {badDays.length > 0 && (
              <p className="text-sm text-rose-600">Giờ chưa đúng ở: {badDays.map((d) => WEEKDAY_LABEL[d]).join(', ')}. Nhập dạng 17:00, giờ đóng phải sau giờ mở.</p>
            )}
          </section>

          <section className="panel space-y-4 p-5">
            <div>
              <h2 className="font-semibold text-slate-900">Phần thưởng</h2>
              <p className="text-sm text-slate-500">
                1 điểm = 1 sao (cộng cả sao của bài làm lại). Huy chương tuần tính theo % điểm lần đầu so với điểm tối đa của <b>tất cả</b> đề đã mở trong tuần (đề chưa làm tính 0 điểm).
              </p>
            </div>
            <div className="grid gap-4 sm:grid-cols-4">
              {numInput('stars_per_diamond', 'Đổi 1 kim cương', 'sao')}
              {numInput('medal_gold_pct', 'Vàng: trên', '%')}
              {numInput('medal_silver_pct', 'Bạc: trên', '%')}
              {numInput('medal_bronze_pct', 'Đồng: trên', '%')}
            </div>
            <p className="text-xs text-slate-500">Dưới mức Đồng: Khuyến khích (chỉ tính bạn đã làm ít nhất 1 đề trong tuần).</p>
            {badMedals && <p className="text-sm text-rose-600">Mức Vàng phải ≥ Bạc ≥ Đồng.</p>}
            {check('medal_include_advanced', 'Tính cả bài nâng cao vào huy chương', 'Mặc định chỉ tính bài cơ bản để bạn nào cũng có cơ hội đạt Vàng.')}
          </section>

          <section className="panel space-y-4 p-5">
            <div>
              <h2 className="font-semibold text-slate-900">Gợi ý độ khó câu hỏi</h2>
              <p className="text-sm text-slate-500">Trang Câu hỏi sẽ gợi ý tăng độ khó cho câu các con làm đúng quá nhiều, giảm cho câu sai quá nhiều.</p>
            </div>
            <div className="grid gap-4 sm:grid-cols-3">
              {numInput('adapt_min_answers', 'Xét khi có ít nhất', 'lượt trả lời')}
              {numInput('adapt_up_pct', 'Gợi ý tăng khi đúng từ', '%')}
              {numInput('adapt_down_pct', 'Gợi ý giảm khi đúng dưới', '%')}
            </div>
          </section>
        </>
      )}

      {isDemoMode && (
        <section className="panel space-y-3 border-amber-200 p-5">
          <h2 className="font-semibold text-slate-900">Dữ liệu demo</h2>
          <p className="text-sm text-slate-600">Bản demo lưu dữ liệu trong trình duyệt. Bấm nút dưới để xoá hết và tạo lại dữ liệu mẫu ban đầu.</p>
          <button type="button" className="btn btn-danger" onClick={resetDemo}><RotateCcw className="h-4 w-4" /> Tạo lại dữ liệu demo</button>
        </section>
      )}
    </form>
  );
}
