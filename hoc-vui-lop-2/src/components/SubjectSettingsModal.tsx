import { useEffect, useState } from 'react';
import { Save } from 'lucide-react';
import { useAsync } from '../hooks/useAsync';
import { adminApi } from '../lib/api';
import { RETAKE_LABEL } from '../lib/text';
import type { AppSettings, RetakeMode, Subject, SubjectSettings } from '../types';
import { AdminError, LoadingBlock, Modal, Spinner } from './ui';

type OverrideKey = Exclude<keyof SubjectSettings, 'subject_id' | 'retake_mode'>;

const EMPTY: Omit<SubjectSettings, 'subject_id'> = {
  daily_max_lessons: null,
  basic_easy: null, basic_normal: null, basic_advanced: null,
  adv_easy: null, adv_normal: null, adv_advanced: null,
  points_easy: null, points_normal: null, points_advanced: null,
  adv_points_easy: null, adv_points_normal: null, adv_points_advanced: null,
  wrong_penalty: null, retake_mode: null,
};

const maxOf = (k: OverrideKey) => (k.includes('points') ? 1000 : k === 'weekly_max_lessons' ? 300 : k === 'wrong_penalty' ? 100 : 50);

/** Cài đặt riêng của 1 môn: ô để trống = theo cài đặt chung (hiện mờ trong ô). */
export function SubjectSettingsModal({ subject, onClose }: { subject: Subject | null; onClose: () => void }) {
  const { data, error, loading } = useAsync(async () => {
    if (!subject) return null;
    const [global, rows] = await Promise.all([adminApi.getSettings(), adminApi.listSubjectSettings()]);
    return { subjectId: subject.id, global, own: rows.find((r) => r.subject_id === subject.id) ?? null };
  }, [subject?.id]);
  const [form, setForm] = useState<SubjectSettings | null>(null);
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState<unknown>(null);

  useEffect(() => {
    setForm(subject && data?.subjectId === subject.id ? { ...EMPTY, ...(data.own ?? {}), subject_id: subject.id } : null);
  }, [subject, data]);

  if (!subject) return null;
  const global: AppSettings | undefined = data?.global;
  const missing = error != null && /subject_settings/.test(String((error as Error).message));

  const save = async () => {
    if (!form) return;
    setBusy(true);
    setSaveError(null);
    try {
      await adminApi.saveSubjectSettings(form);
      onClose();
    } catch (e) {
      setSaveError(e);
    } finally {
      setBusy(false);
    }
  };

  const num = (k: OverrideKey, label: string) => (
    <div>
      <label className="label" htmlFor={`ss-${k}`}>{label}</label>
      <input
        id={`ss-${k}`}
        type="number"
        min={0}
        max={maxOf(k)}
        className="input"
        placeholder={global ? String(global[k]) : ''}
        value={form?.[k] ?? ''}
        onChange={(e) => form && setForm({ ...form, [k]: e.target.value === '' ? null : Math.max(0, Math.min(maxOf(k), Number(e.target.value) || 0)) })}
      />
    </div>
  );

  return (
    <Modal
      open
      wide
      title={`Cài đặt riêng môn ${subject.name}`}
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={() => form && setForm({ ...EMPTY, subject_id: form.subject_id })} disabled={!form}>
            Theo cài đặt chung hết
          </button>
          <button type="button" className="btn btn-primary" onClick={save} disabled={busy || !form}>
            {busy ? <Spinner className="h-4 w-4 text-white" /> : <Save className="h-4 w-4" />} Lưu
          </button>
        </>
      }
    >
      {loading && !data && <LoadingBlock />}
      {missing && <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-900">Database chưa chạy <code>0006_learning_rules.sql</code> nên chưa có cài đặt riêng từng môn.</p>}
      {error !== null && !missing && <AdminError error={error} />}
      {form && global && (
        <div className="space-y-5">
          <p className="text-sm text-slate-500">Để trống ô nào thì môn này dùng cài đặt chung (số mờ trong ô). Mỗi môn có đặc thù khác nhau, VD môn Tiếng Việt đề ngắn hơn, môn Toán trừ điểm nặng hơn.</p>
          <div className="grid gap-4 sm:grid-cols-2">
            {num('daily_max_lessons', 'Tối đa đề / ngày (0 = không giới hạn)')}
            {'weekly_max_lessons' in global && num('weekly_max_lessons', 'Tối đa đề / tuần (0 = không giới hạn)')}
            {num('wrong_penalty', 'Mỗi câu sai trừ (điểm)')}
            <div>
              <label className="label" htmlFor="ss-retake">Bài làm lại</label>
              <select id="ss-retake" className="input" value={form.retake_mode ?? ''}
                onChange={(e) => setForm({ ...form, retake_mode: (e.target.value || null) as RetakeMode | null })}>
                <option value="">Theo cài đặt chung ({RETAKE_LABEL[global.retake_mode].toLowerCase()})</option>
                {(Object.keys(RETAKE_LABEL) as RetakeMode[]).map((m) => <option key={m} value={m}>{RETAKE_LABEL[m]}</option>)}
              </select>
            </div>
          </div>
          <div className="grid gap-5 lg:grid-cols-2">
            <div className="space-y-3 rounded-xl bg-sky-50 p-4">
              <p className="font-medium text-slate-800">Bài cơ bản</p>
              <p className="text-xs font-semibold text-slate-500 uppercase">Số câu</p>
              <div className="grid grid-cols-3 gap-3">{num('basic_easy', 'Dễ')}{num('basic_normal', 'Vừa')}{num('basic_advanced', 'Khó')}</div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Điểm mỗi câu đúng</p>
              <div className="grid grid-cols-3 gap-3">{num('points_easy', 'Dễ')}{num('points_normal', 'Vừa')}{num('points_advanced', 'Khó')}</div>
            </div>
            <div className="space-y-3 rounded-xl bg-amber-50 p-4">
              <p className="font-medium text-slate-800">Bài nâng cao</p>
              <p className="text-xs font-semibold text-slate-500 uppercase">Số câu</p>
              <div className="grid grid-cols-3 gap-3">{num('adv_easy', 'Dễ')}{num('adv_normal', 'Vừa')}{num('adv_advanced', 'Khó')}</div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Điểm mỗi câu đúng</p>
              <div className="grid grid-cols-3 gap-3">{num('adv_points_easy', 'Dễ')}{num('adv_points_normal', 'Vừa')}{num('adv_points_advanced', 'Khó')}</div>
            </div>
          </div>
          {saveError !== null && <AdminError error={saveError} />}
        </div>
      )}
    </Modal>
  );
}
