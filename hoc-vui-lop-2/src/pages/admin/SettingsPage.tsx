import { useEffect, useState, type FormEvent } from 'react';
import { Check, Copy, RotateCcw, Save } from 'lucide-react';
import { PageHeader } from '../../components/admin';
import { AdminError, LoadingBlock, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { isDemoMode } from '../../lib/backend';
import type { AppSettings } from '../../types';

type NumKey = 'current_week' | 'basic_easy' | 'basic_normal' | 'basic_advanced' | 'adv_easy' | 'adv_normal' | 'adv_advanced' | 'points_easy' | 'points_normal' | 'points_advanced';

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

  const studentLink = `${location.origin}/`;
  const maxOf = (k: NumKey) => (k === 'current_week' ? 60 : k.startsWith('points_') ? 1000 : 50);
  const setNum = (k: NumKey, v: string) => setForm({ ...form, [k]: Math.max(0, Math.min(maxOf(k), Number(v) || 0)) });

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setSaveError(null);
    setSaved(false);
    try {
      await adminApi.updateSettings({
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
      });
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
  const numInput = (k: NumKey, label: string) => (
    <div>
      <label className="label" htmlFor={`set-${k}`}>{label}</label>
      <input id={`set-${k}`} type="number" min={0} max={maxOf(k)} className="input" value={form[k]} onChange={(e) => setNum(k, e.target.value)} />
    </div>
  );

  return (
    <form onSubmit={submit} className="space-y-5">
      <PageHeader
        title="Cài đặt"
        actions={
          <button type="submit" className="btn btn-primary" disabled={busy}>
            {busy ? <Spinner className="h-4 w-4 text-white" /> : saved ? <Check className="h-4 w-4" /> : <Save className="h-4 w-4" />} {saved ? 'Đã lưu' : 'Lưu cài đặt'}
          </button>
        }
      />
      {saveError !== null && <AdminError error={saveError} />}

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
        <label className="flex items-start gap-2 text-sm">
          <input type="checkbox" className="mt-1" checked={form.allow_self_register} onChange={(e) => setForm({ ...form, allow_self_register: e.target.checked })} />
          <span><b>Cho phép học sinh tự thêm tên</b><span className="block text-xs text-slate-500">Tắt đi nếu thầy cô đã nhập đủ danh sách lớp và không muốn có tên lạ.</span></span>
        </label>
        <label className="flex items-start gap-2 text-sm">
          <input type="checkbox" className="mt-1" checked={form.leaderboard_enabled} onChange={(e) => setForm({ ...form, leaderboard_enabled: e.target.checked })} />
          <span><b>Hiện bảng xếp hạng cho học sinh</b><span className="block text-xs text-slate-500">Xếp hạng theo ngày, tuần (thứ Hai – Chủ nhật) và tháng.</span></span>
        </label>
      </section>

      <section className="panel space-y-4 p-5">
        <div>
          <h2 className="font-semibold text-slate-900">Số câu mỗi lượt làm bài</h2>
          <p className="text-sm text-slate-500">Mỗi lần làm, hệ thống chọn ngẫu nhiên câu hỏi theo tỉ lệ này (ưu tiên câu bạn đó chưa gặp).</p>
        </div>
        <div className="grid gap-5 lg:grid-cols-2">
          <div className="rounded-xl bg-sky-50 p-4">
            <p className="mb-3 font-medium text-slate-800">Bài cơ bản · {basicTotal} câu</p>
            <div className="grid grid-cols-3 gap-3">
              {numInput('basic_easy', 'Dễ')}
              {numInput('basic_normal', 'Vừa')}
              {numInput('basic_advanced', 'Nâng cao')}
            </div>
          </div>
          <div className="rounded-xl bg-amber-50 p-4">
            <p className="mb-3 font-medium text-slate-800">Bài nâng cao · {advTotal} câu</p>
            <div className="grid grid-cols-3 gap-3">
              {numInput('adv_easy', 'Dễ')}
              {numInput('adv_normal', 'Vừa')}
              {numInput('adv_advanced', 'Nâng cao')}
            </div>
          </div>
        </div>
        {(basicTotal === 0 || advTotal === 0) && <p className="text-sm text-rose-600">Mỗi loại bài cần ít nhất 1 câu.</p>}
      </section>

      <section className="panel space-y-4 p-5">
        <div>
          <h2 className="font-semibold text-slate-900">Điểm mỗi câu đúng</h2>
          <p className="text-sm text-slate-500">Áp dụng cho câu không đặt “điểm riêng”. Thay đổi chỉ ảnh hưởng các câu trả lời sau này.</p>
        </div>
        <div className="grid max-w-md grid-cols-3 gap-3">
          {numInput('points_easy', 'Câu dễ')}
          {numInput('points_normal', 'Câu vừa')}
          {numInput('points_advanced', 'Câu nâng cao')}
        </div>
      </section>

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
