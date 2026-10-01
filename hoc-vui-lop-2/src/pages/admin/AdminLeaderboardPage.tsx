import { useState } from 'react';
import { Link, useSearchParams } from 'react-router';
import { Download, PieChart } from 'lucide-react';
import { EmptyState, GuestBadge, PageHeader, pct } from '../../components/admin';
import { PERIOD_LABEL } from '../../components/Leaderboard';
import { AdminError, Avatar, LoadingBlock } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { downloadText, toCsv } from '../../lib/csv';
import type { Period } from '../../types';

const MEDAL = ['🥇', '🥈', '🥉'];

export default function AdminLeaderboardPage() {
  const [period, setPeriod] = useState<Period>('week');
  const [params, setParams] = useSearchParams();
  const subjectId = params.get('subject') || null;
  const { data, error, loading, reload } = useAsync(() => adminApi.getLeaderboard(period, subjectId), [period, subjectId]);
  const subject = subjectId ? data?.subjects?.find((s) => s.id === subjectId) : undefined;

  const setSubject = (id: string | null) => {
    const next = new URLSearchParams(params);
    if (id) next.set('subject', id); else next.delete('subject');
    setParams(next, { replace: true });
  };

  const range = data?.start && data?.end
    ? `${new Date(data.start).toLocaleDateString('vi-VN')} – ${new Date(new Date(data.end).getTime() - 1).toLocaleDateString('vi-VN')}`
    : '';

  const exportCsv = () => data && downloadText(
    `xep_hang_${subject?.code ?? 'tat_ca_mon'}_${period}_${new Date().toISOString().slice(0, 10)}.csv`,
    toCsv(data.rows as unknown as Array<Record<string, unknown>>, [
      ['rank', 'hang'], ['full_name', 'ho_ten'], ['score', 'diem'], ['lessons_done', 'so_bai'], ['accuracy', 'ti_le_dung'],
    ]),
  );

  const pill = (active: boolean) =>
    `rounded-md px-4 py-1.5 text-sm font-medium whitespace-nowrap ${active ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`;

  return (
    <div className="space-y-5">
      <PageHeader
        title={subject ? `Bảng xếp hạng môn ${subject.name}` : 'Bảng xếp hạng'}
        description={<>Tính theo điểm các bài làm lần đầu{subject ? ` của môn ${subject.name}` : ' (cộng tất cả các môn)'}. {range && <b>{range}</b>}
          {data?.rows.some((r) => r.is_guest) && <> Bạn có nhãn <GuestBadge /> chỉ thấy chính mình trên bảng xếp hạng; các bạn trong lớp không thấy bạn ấy.</>}</>}
        actions={<>
          <Link to="/admin/subject-stats" className="btn btn-secondary"><PieChart className="h-4 w-4" /> Thống kê theo môn</Link>
          <button type="button" className="btn btn-secondary" onClick={exportCsv} disabled={!data?.rows.length}><Download className="h-4 w-4" /> Xuất CSV</button>
        </>}
      />
      <div className="flex flex-col gap-3 sm:flex-row sm:flex-wrap">
        <div className="flex rounded-lg bg-slate-100 p-1 sm:w-fit">
          {(Object.keys(PERIOD_LABEL) as Period[]).map((p) => (
            <button key={p} type="button" onClick={() => setPeriod(p)} className={`flex-1 ${pill(period === p)}`}>
              {PERIOD_LABEL[p]}
            </button>
          ))}
        </div>
        {data?.subjects && data.subjects.length > 1 && (
          <div className="flex overflow-x-auto rounded-lg bg-slate-100 p-1 sm:w-fit" role="tablist" aria-label="Lọc theo môn">
            <button type="button" role="tab" aria-selected={!subjectId} onClick={() => setSubject(null)} className={pill(!subjectId)}>Tất cả môn</button>
            {data.subjects.map((s) => (
              <button key={s.id} type="button" role="tab" aria-selected={subjectId === s.id} onClick={() => setSubject(s.id)} className={pill(subjectId === s.id)}>
                {s.name}
              </button>
            ))}
          </div>
        )}
      </div>
      {data && !data.enabled && (
        <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-800">Bảng xếp hạng đang <b>tắt</b> với học sinh (bật lại trong Cài đặt). Thầy cô vẫn xem được ở đây.</p>
      )}
      {error !== null && <AdminError error={error} onRetry={reload} />}
      <div className="panel overflow-hidden">
        {loading && !data ? <LoadingBlock /> : !data || data.rows.length === 0 ? <EmptyState title="Chưa có ai làm bài trong khoảng này" /> : (
          <table className="w-full text-sm">
            <thead><tr><th className="th w-16">Hạng</th><th className="th">Học sinh</th><th className="th">Điểm</th><th className="th">Số bài</th><th className="th">Tỉ lệ đúng</th></tr></thead>
            <tbody className={loading ? 'opacity-60' : ''}>
              {data.rows.map((r) => (
                <tr key={r.student_id} className="border-t border-slate-100">
                  <td className="td text-center text-lg font-bold">{MEDAL[r.rank - 1] ?? r.rank}</td>
                  <td className="td">
                    <div className="flex items-center gap-3">
                      <Avatar name={r.full_name} id={r.student_id} size="h-8 w-8 text-xs" />
                      <span className="font-medium text-slate-800">{r.full_name}</span>
                      {r.is_guest && <GuestBadge />}
                    </div>
                  </td>
                  <td className="td font-bold text-blue-700">{r.score}</td>
                  <td className="td">{r.lessons_done}</td>
                  <td className="td">{pct(r.accuracy)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
