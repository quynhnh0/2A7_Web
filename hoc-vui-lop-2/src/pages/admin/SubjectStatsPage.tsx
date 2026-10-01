import { useMemo, useState } from 'react';
import { Link } from 'react-router';
import { ArrowDown, ArrowUp, Download, Trophy } from 'lucide-react';
import { EmptyState, GuestBadge, PageHeader, pct } from '../../components/admin';
import { AdminError, Avatar, LoadingBlock, subjectEmoji, subjectStyle } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { downloadText, toCsv } from '../../lib/csv';
import { formatDuration, formatNumber, isGuestName } from '../../lib/text';
import type { AdminSubjectStats, StatsPeriod, StudentSubjectCell, SubjectStat } from '../../types';

const PERIODS: Array<[StatsPeriod, string]> = [['day', 'Hôm nay'], ['week', 'Tuần này'], ['month', 'Tháng này'], ['all', 'Từ trước tới nay']];
const WEAK_THRESHOLD = 60;

type Sort = { key: 'name' | 'total' | string; asc: boolean };
type StudentRow = AdminSubjectStats['students'][number];

function accuracyTone(v: number | null | undefined): string {
  if (v === null || v === undefined) return 'bg-slate-100 text-slate-500';
  if (v >= 80) return 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200';
  if (v >= WEAK_THRESHOLD) return 'bg-amber-50 text-amber-700 ring-1 ring-amber-200';
  return 'bg-rose-50 text-rose-700 ring-1 ring-rose-200';
}

const totalScore = (s: StudentRow) => {
  let t = 0;
  for (const c of Object.values(s.by_subject)) t += c.score;
  return t;
};

export default function SubjectStatsPage() {
  const [period, setPeriod] = useState<StatsPeriod>('week');
  const { data, error, loading, reload } = useAsync(() => adminApi.subjectStats(period), [period]);
  const [sort, setSort] = useState<Sort>({ key: 'name', asc: true });
  const [onlyWeak, setOnlyWeak] = useState(false);
  const [hardSubject, setHardSubject] = useState<string | null>(null);

  const subjects = data?.subjects ?? [];

  const students = useMemo(() => {
    if (!data) return [];
    let rows = data.students;
    if (onlyWeak) {
      rows = rows.filter((s) => data.subjects.some((sj) => {
        const c = s.by_subject[sj.id];
        return !c || (c.accuracy ?? 0) < WEAK_THRESHOLD;
      }));
    }
    const dir = sort.asc ? 1 : -1;
    return [...rows].sort((a, b) => {
      if (sort.key === 'name') return dir * a.display_name.localeCompare(b.display_name, 'vi');
      if (sort.key === 'total') return dir * (totalScore(a) - totalScore(b));
      const va = a.by_subject[sort.key]?.accuracy;
      const vb = b.by_subject[sort.key]?.accuracy;
      // Bạn chưa làm môn này luôn nằm cuối để không lẫn với bạn làm sai nhiều.
      if (va == null && vb == null) return a.display_name.localeCompare(b.display_name, 'vi');
      if (va == null) return 1;
      if (vb == null) return -1;
      return dir * (va - vb) || a.display_name.localeCompare(b.display_name, 'vi');
    });
  }, [data, sort, onlyWeak]);

  const toggleSort = (key: Sort['key']) =>
    setSort((s) => (s.key === key ? { key, asc: !s.asc } : { key, asc: key !== 'total' }));

  const range = data?.start && data?.end
    ? `${new Date(data.start).toLocaleDateString('vi-VN')} – ${new Date(new Date(data.end).getTime() - 1).toLocaleDateString('vi-VN')}`
    : 'Toàn bộ dữ liệu';

  const exportCsv = () => {
    if (!data) return;
    const columns: Array<[string, string]> = [['full_name', 'ho_ten']];
    for (const sj of data.subjects) {
      columns.push([`${sj.id}.attempts`, `${sj.code}_so_luot`], [`${sj.id}.score`, `${sj.code}_diem`], [`${sj.id}.accuracy`, `${sj.code}_ti_le_dung`]);
    }
    const rows = students.map((s) => {
      const r: Record<string, unknown> = { full_name: s.full_name };
      for (const sj of data.subjects) {
        const c = s.by_subject[sj.id];
        r[`${sj.id}.attempts`] = c?.attempts ?? 0;
        r[`${sj.id}.score`] = c?.score ?? 0;
        r[`${sj.id}.accuracy`] = c?.accuracy ?? '';
      }
      return r;
    });
    downloadText(`thong_ke_theo_mon_${period}_${new Date().toISOString().slice(0, 10)}.csv`, toCsv(rows, columns));
  };

  const hardSubjectId = hardSubject ?? subjects[0]?.id ?? null;
  const hardest = data?.hardest.filter((h) => h.subject_id === hardSubjectId) ?? [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Thống kê theo môn học"
        description={<>So sánh kết quả từng môn và từng bạn. <b>{range}</b></>}
        actions={<button type="button" className="btn btn-secondary" onClick={exportCsv} disabled={!data?.students.length}><Download className="h-4 w-4" /> Xuất CSV</button>}
      />

      <div className="flex w-full overflow-x-auto rounded-lg bg-slate-100 p-1 sm:w-fit">
        {PERIODS.map(([p, label]) => (
          <button key={p} type="button" onClick={() => setPeriod(p)}
            className={`flex-1 rounded-md px-4 py-1.5 text-sm font-medium whitespace-nowrap ${period === p ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`}>
            {label}
          </button>
        ))}
      </div>

      {error !== null && <AdminError error={error} onRetry={reload} />}
      {loading && !data && <LoadingBlock />}

      {data && (
        <div className={`space-y-6 transition-opacity ${loading ? 'opacity-60' : ''}`}>
          {subjects.length === 0 ? (
            <div className="panel"><EmptyState title="Chưa có môn học nào" /></div>
          ) : (
            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {subjects.map((s) => <SubjectCard key={s.id} subject={s} totalStudents={data.total_students} />)}
            </div>
          )}

          <section className="panel">
            <div className="flex flex-col gap-3 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 className="font-semibold text-slate-800">Từng bạn theo từng môn</h2>
                <p className="text-xs text-slate-500">Bấm tên cột môn để sắp theo tỉ lệ đúng (thấp → cao để thấy bạn cần giúp trước).</p>
              </div>
              <label className="flex items-center gap-2 text-sm text-slate-700">
                <input type="checkbox" className="h-4 w-4 rounded" checked={onlyWeak} onChange={(e) => setOnlyWeak(e.target.checked)} />
                Chỉ hiện bạn cần chú ý (chưa làm hoặc đúng dưới {WEAK_THRESHOLD}%)
              </label>
            </div>
            {students.length === 0 ? (
              <EmptyState title={onlyWeak ? 'Không có bạn nào cần chú ý 🎉' : 'Chưa có học sinh'} />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr>
                      <SortTh label="Học sinh" active={sort.key === 'name'} asc={sort.asc} onClick={() => toggleSort('name')} />
                      {subjects.map((sj) => (
                        <SortTh key={sj.id} label={sj.name} active={sort.key === sj.id} asc={sort.asc} onClick={() => toggleSort(sj.id)} />
                      ))}
                      <SortTh label="Tổng điểm" active={sort.key === 'total'} asc={sort.asc} onClick={() => toggleSort('total')} />
                    </tr>
                  </thead>
                  <tbody>
                    {students.map((s) => (
                      <tr key={s.student_id} className="border-t border-slate-100">
                        <td className="td">
                          <div className="flex items-center gap-2">
                            <Avatar name={s.full_name} id={s.student_id} size="h-7 w-7 text-[10px]" />
                            <span className="font-medium whitespace-nowrap text-slate-800" title={s.full_name}>{s.display_name}</span>
                            {isGuestName(s.full_name) && <GuestBadge />}
                          </div>
                        </td>
                        {subjects.map((sj) => <Cell key={sj.id} cell={s.by_subject[sj.id]} />)}
                        <td className="td font-bold whitespace-nowrap text-blue-700">{formatNumber(totalScore(s))}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>

          <section className="panel">
            <div className="flex flex-col gap-3 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
              <h2 className="font-semibold text-slate-800">Câu nhiều bạn làm sai theo môn</h2>
              {subjects.length > 1 && (
                <div className="flex overflow-x-auto rounded-lg bg-slate-100 p-1">
                  {subjects.map((sj) => (
                    <button key={sj.id} type="button" onClick={() => setHardSubject(sj.id)}
                      className={`rounded-md px-3 py-1 text-sm font-medium whitespace-nowrap ${hardSubjectId === sj.id ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`}>
                      {sj.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
            {hardest.length === 0 ? (
              <EmptyState title="Chưa đủ dữ liệu">Cần ít nhất 3 lượt trả lời mỗi câu (trong khoảng thời gian đang chọn).</EmptyState>
            ) : (
              <ul className="divide-y divide-slate-100">
                {hardest.map((q) => (
                  <li key={q.question_id} className="flex items-center gap-4 px-5 py-3">
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-medium text-slate-800">{q.text}</p>
                      <p className="text-xs text-slate-500">Tuần {q.week_number} · {q.lesson_name}</p>
                    </div>
                    <div className="w-32 shrink-0">
                      <div className="flex justify-between text-xs text-slate-500">
                        <span>{q.wrong}/{q.answered} sai</span>
                        <span className="font-semibold text-rose-600">{pct(q.wrong_rate)}</span>
                      </div>
                      <div className="mt-1 h-2 rounded-full bg-slate-100">
                        <div className="h-2 rounded-full bg-rose-500" style={{ width: `${Math.min(100, q.wrong_rate)}%` }} />
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </div>
      )}
    </div>
  );
}

function SubjectCard({ subject: s, totalStudents }: { subject: SubjectStat; totalStudents: number }) {
  const st = subjectStyle(s.color);
  const reach = totalStudents > 0 ? Math.round((100 * s.active_students) / totalStudents) : 0;
  return (
    <div className="panel flex flex-col gap-4 p-5">
      <div className="flex items-center justify-between gap-2">
        <span className={`chip text-sm ${st.chip}`}><span aria-hidden>{subjectEmoji(s.code, s.color)}</span> {s.name}</span>
        <Link to={`/admin/leaderboard?subject=${s.id}`} className="flex items-center gap-1 text-xs font-medium text-blue-600 hover:underline">
          <Trophy className="h-3.5 w-3.5" /> Xếp hạng môn
        </Link>
      </div>

      <div className="flex items-end justify-between gap-3">
        <div>
          <p className="text-xs font-medium text-slate-500">Tỉ lệ đúng</p>
          <p className={`text-3xl font-bold ${s.accuracy === null ? 'text-slate-300' : st.text}`}>{pct(s.accuracy)}</p>
        </div>
        <div className="text-right">
          <p className="text-xs font-medium text-slate-500">Điểm xếp hạng</p>
          <p className="text-xl font-bold text-slate-800">{formatNumber(s.ranked_score)}</p>
        </div>
      </div>
      <div className="h-2 rounded-full bg-slate-100">
        <div className={`h-2 rounded-full ${st.bar}`} style={{ width: `${Math.min(100, s.accuracy ?? 0)}%` }} />
      </div>

      <dl className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
        <dt className="text-slate-500">Bạn đã học</dt>
        <dd className="text-right font-semibold text-slate-800">{s.active_students}/{totalStudents} <span className="text-xs font-normal text-slate-500">({reach}%)</span></dd>
        <dt className="text-slate-500">Lượt làm xong</dt>
        <dd className="text-right font-semibold text-slate-800">{formatNumber(s.attempts_completed)}</dd>
        <dt className="text-slate-500">Thời gian TB / bài</dt>
        <dd className="text-right font-semibold text-slate-800">{s.avg_duration ? formatDuration(s.avg_duration) : '—'}</dd>
        <dt className="text-slate-500">Bài đang mở</dt>
        <dd className="text-right font-semibold text-slate-800">{s.published_count}/{s.lesson_count} <span className="text-xs font-normal text-slate-500">· {formatNumber(s.question_count)} câu</span></dd>
      </dl>
    </div>
  );
}

function SortTh({ label, active, asc, onClick }: { label: string; active: boolean; asc: boolean; onClick: () => void }) {
  const Icon = asc ? ArrowUp : ArrowDown;
  return (
    <th className="th" aria-sort={active ? (asc ? 'ascending' : 'descending') : 'none'}>
      <button type="button" onClick={onClick} className={`inline-flex items-center gap-1 uppercase ${active ? 'text-blue-700' : 'hover:text-slate-700'}`}>
        {label} {active && <Icon className="h-3 w-3" />}
      </button>
    </th>
  );
}

function Cell({ cell }: { cell: StudentSubjectCell | undefined }) {
  if (!cell) return <td className="td"><span className="chip bg-slate-100 text-slate-400">chưa làm</span></td>;
  return (
    <td className="td whitespace-nowrap">
      <span className={`chip ${accuracyTone(cell.accuracy)}`}>{pct(cell.accuracy)}</span>
      <span className="ml-2 text-xs text-slate-500">{cell.attempts} lượt · {formatNumber(cell.score)} đ</span>
    </td>
  );
}
