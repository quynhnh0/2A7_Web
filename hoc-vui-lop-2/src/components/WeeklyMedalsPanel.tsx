import { useState } from 'react';
import { ChevronLeft, ChevronRight, Download, Save } from 'lucide-react';
import { useAsync } from '../hooks/useAsync';
import { adminApi } from '../lib/api';
import { downloadText, toCsv } from '../lib/csv';
import { MEDAL_INFO } from '../lib/text';
import type { MedalKind } from '../types';
import { EmptyState, pct } from './admin';
import { AdminError, Avatar, LoadingBlock, Spinner } from './ui';

const KINDS: MedalKind[] = ['gold', 'silver', 'bronze', 'encourage'];

function addDays(isoDate: string, days: number): string {
  const d = new Date(`${isoDate}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

function weekRange(isoDate: string): string {
  const fmt = (s: string) => new Date(`${s}T00:00:00Z`).toLocaleDateString('vi-VN', { timeZone: 'UTC', day: '2-digit', month: '2-digit' });
  return `${fmt(isoDate)} – ${fmt(addDays(isoDate, 6))}`;
}

/** Huy chương theo tuần lịch (Thứ 2 – Chủ nhật): % điểm bài cơ bản lần đầu so với điểm tối đa các bài đã mở của tuần học. */
export function WeeklyMedalsPanel() {
  const [week, setWeek] = useState<string | null>(null);
  const { data, error, loading, reload } = useAsync(() => adminApi.weeklyMedals(week), [week]);
  const [classWeek, setClassWeek] = useState('');
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState<unknown>(null);
  const missing = error != null && /admin_weekly_medals/.test(String((error as Error).message));

  if (missing) {
    return <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-900">Database chưa chạy <code>0006_learning_rules.sql</code> nên chưa có huy chương tuần.</p>;
  }
  if (error) return <AdminError error={error} onRetry={reload} />;
  if (loading && !data) return <LoadingBlock />;
  if (!data) return null;

  const counts = KINDS.map((k) => [k, data.rows.filter((r) => r.medal === k).length] as const);
  const editWeek = classWeek === '' ? String(data.class_week ?? '') : classWeek;

  const saveClassWeek = async () => {
    const n = Number(editWeek);
    if (!Number.isInteger(n) || n < 1 || n > 60) return setSaveError(new Error('Tuần học phải từ 1 đến 60.'));
    setBusy(true);
    setSaveError(null);
    try {
      await adminApi.setWeekClass(data.week_start, n);
      setClassWeek('');
      reload();
    } catch (e) {
      setSaveError(e);
    } finally {
      setBusy(false);
    }
  };

  const exportCsv = () => downloadText(
    `huy_chuong_${data.week_start}.csv`,
    toCsv(data.rows.map((r) => ({ ...r, medal: MEDAL_INFO[r.medal].label })) as unknown as Array<Record<string, unknown>>, [
      ['full_name', 'ho_ten'], ['score', 'diem'], ['max_score', 'diem_toi_da'], ['pct', 'phan_tram'], ['medal', 'huy_chuong'],
    ]),
  );

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div className="flex items-center gap-2">
          <button type="button" className="btn btn-secondary btn-icon" aria-label="Tuần trước" onClick={() => { setClassWeek(''); setWeek(addDays(data.week_start, -7)); }}>
            <ChevronLeft className="h-4 w-4" />
          </button>
          <select
            className="input w-56"
            aria-label="Chọn tuần"
            value={data.week_start}
            onChange={(e) => { setClassWeek(''); setWeek(e.target.value); }}
          >
            {!data.weeks.some((w) => w.week_start === data.week_start) && <option value={data.week_start}>{weekRange(data.week_start)}</option>}
            {data.weeks.map((w) => <option key={w.week_start} value={w.week_start}>{weekRange(w.week_start)} · Tuần {w.class_week}</option>)}
          </select>
          <button type="button" className="btn btn-secondary btn-icon" aria-label="Tuần sau" disabled={data.is_current} onClick={() => { setClassWeek(''); setWeek(addDays(data.week_start, 7)); }}>
            <ChevronRight className="h-4 w-4" />
          </button>
          {data.is_current && <span className="chip bg-emerald-100 text-emerald-800">Tuần này</span>}
        </div>
        <div className="flex flex-wrap items-end gap-2">
          <div>
            <label className="label" htmlFor="wm-class">Tính theo bài của tuần học</label>
            <input id="wm-class" type="number" min={1} max={60} className="input w-24" value={editWeek} onChange={(e) => setClassWeek(e.target.value)} />
          </div>
          <button type="button" className="btn btn-secondary" disabled={busy || editWeek === String(data.class_week ?? '')} onClick={saveClassWeek}>
            {busy ? <Spinner className="h-4 w-4" /> : <Save className="h-4 w-4" />} Đổi
          </button>
          <button type="button" className="btn btn-secondary" onClick={exportCsv} disabled={!data.rows.length}><Download className="h-4 w-4" /> Xuất CSV</button>
        </div>
      </div>

      <p className="text-sm text-slate-500">
        Điểm tối đa: <b>{data.max_score}</b> (bài {data.include_advanced ? 'cơ bản + nâng cao' : 'cơ bản'} lần đầu của mọi bài đã mở trong tuần học {data.class_week ?? '—'}).
        Vàng &gt; {data.thresholds.gold}%, Bạc &gt; {data.thresholds.silver}%, Đồng &gt; {data.thresholds.bronze}%, còn lại Khuyến khích.
        Chỉ bạn có làm ít nhất 1 bài trong tuần mới được xét; bạn khách (tên có dấu “-”) không tham gia.
        {data.is_current && ' Tuần chưa kết thúc nên kết quả còn thay đổi.'}
      </p>
      {saveError !== null && <AdminError error={saveError} />}

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {counts.map(([k, n]) => (
          <div key={k} className={`rounded-xl p-3 ${MEDAL_INFO[k].className}`}>
            <p className="text-sm font-medium">{MEDAL_INFO[k].emoji} {MEDAL_INFO[k].label}</p>
            <p className="mt-1 text-2xl font-bold">{n}</p>
          </div>
        ))}
      </div>

      <div className="panel overflow-hidden">
        {data.rows.length === 0 ? (
          <EmptyState title="Chưa có ai làm bài trong tuần này">
            {data.class_week == null
              ? 'Tuần này chưa gắn với tuần học nào. Nếu lớp có học, nhập số tuần học ở ô phía trên rồi bấm Đổi.'
              : data.max_score === 0 && 'Tuần học này chưa có bài cơ bản nào được mở.'}
          </EmptyState>
        ) : (
          <table className={`w-full text-sm ${loading ? 'opacity-60' : ''}`}>
            <thead><tr><th className="th">Học sinh</th><th className="th">Điểm</th><th className="th w-1/3">Tiến độ</th><th className="th">Huy chương</th></tr></thead>
            <tbody>
              {data.rows.map((r) => (
                <tr key={r.student_id} className="border-t border-slate-100">
                  <td className="td">
                    <div className="flex items-center gap-3">
                      <Avatar name={r.full_name} id={r.student_id} size="h-8 w-8 text-xs" />
                      <span className="font-medium text-slate-800">{r.full_name}</span>
                    </div>
                  </td>
                  <td className="td whitespace-nowrap"><b className="text-blue-700">{r.score}</b><span className="text-slate-400"> / {r.max_score}</span></td>
                  <td className="td">
                    <div className="flex items-center gap-2">
                      <div className="h-2 flex-1 overflow-hidden rounded-full bg-slate-100">
                        <div className="h-full rounded-full bg-blue-500" style={{ width: `${Math.min(100, r.pct)}%` }} />
                      </div>
                      <span className="w-10 text-right text-xs text-slate-500">{pct(r.pct)}</span>
                    </div>
                  </td>
                  <td className="td"><span className={`chip ${MEDAL_INFO[r.medal].className}`}>{MEDAL_INFO[r.medal].emoji} {MEDAL_INFO[r.medal].label}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
