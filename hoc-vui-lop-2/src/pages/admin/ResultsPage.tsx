import { useMemo, useState } from 'react';
import { Download } from 'lucide-react';
import { EmptyState, PageHeader, Pager, pct, StatCard } from '../../components/admin';
import { AdminError, LoadingBlock } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import type { Filter } from '../../lib/backend';
import { downloadText, toCsv } from '../../lib/csv';
import { formatDateTime, formatDuration } from '../../lib/text';

const PAGE_SIZE = 50;
type Range = 'today' | '7d' | '30d' | 'all';
const RANGE_LABEL: Record<Range, string> = { today: 'Hôm nay', '7d': '7 ngày', '30d': '30 ngày', all: 'Tất cả' };

function rangeStart(r: Range): string | null {
  if (r === 'all') return null;
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  if (r === '7d') d.setDate(d.getDate() - 6);
  if (r === '30d') d.setDate(d.getDate() - 29);
  return d.toISOString();
}

export default function ResultsPage() {
  const [range, setRange] = useState<Range>('7d');
  const [studentId, setStudentId] = useState('');
  const [lessonId, setLessonId] = useState('');
  const [rankedOnly, setRankedOnly] = useState(false);
  const [page, setPage] = useState(0);

  const meta = useAsync(async () => {
    const [students, lessons] = await Promise.all([adminApi.listStudents(), adminApi.listLessons()]);
    return { students, lessons };
  }, []);

  const filters = useMemo<Filter[]>(() => {
    // So sánh >= cũng loại luôn các lượt chưa nộp (completed_at null).
    const f: Filter[] = [['completed_at', 'gte', rangeStart(range) ?? '2000-01-01T00:00:00Z']];
    if (studentId) f.push(['student_id', 'eq', studentId]);
    if (lessonId) f.push(['lesson_id', 'eq', lessonId]);
    if (rankedOnly) f.push(['is_ranked', 'eq', true]);
    return f;
  }, [range, studentId, lessonId, rankedOnly]);
  const key = JSON.stringify(filters);

  const list = useAsync(() => adminApi.listAttempts({ filters, order: [['completed_at', false]], limit: PAGE_SIZE, offset: page * PAGE_SIZE }), [key, page]);
  // Thống kê tổng cho toàn bộ bộ lọc (tối đa 5000 lượt — đủ cho một lớp học).
  const summary = useAsync(async () => {
    const { rows } = await adminApi.listAttempts({ filters, columns: 'student_id,correct_count,total_questions,score', limit: 5000 });
    const correct = rows.reduce((s, r) => s + r.correct_count, 0);
    const totalQ = rows.reduce((s, r) => s + r.total_questions, 0);
    return {
      attempts: rows.length,
      students: new Set(rows.map((r) => r.student_id)).size,
      accuracy: totalQ ? (100 * correct) / totalQ : null,
      avgScore: rows.length ? Math.round(rows.reduce((s, r) => s + r.score, 0) / rows.length) : 0,
    };
  }, [key]);

  const change = (fn: () => void) => {
    fn();
    setPage(0);
  };

  const exportCsv = async () => {
    const { rows } = await adminApi.listAttempts({ filters, order: [['completed_at', false]], limit: 10000 });
    downloadText(
      `ket_qua_${new Date().toISOString().slice(0, 10)}.csv`,
      toCsv(rows.map((r) => ({
        ...r,
        loai: r.exercise_type === 'advanced' ? 'Nâng cao' : 'Cơ bản',
        tinh_diem: r.is_ranked ? 'Có' : 'Không',
        luc: r.completed_at ? new Date(r.completed_at).toLocaleString('vi-VN') : '',
      })), [
        ['luc', 'thoi_gian'], ['student_name', 'hoc_sinh'], ['subject_name', 'mon'], ['week_number', 'tuan'], ['lesson_name', 'bai'],
        ['loai', 'loai'], ['correct_count', 'so_cau_dung'], ['total_questions', 'tong_so_cau'], ['score', 'diem'],
        ['tinh_diem', 'tinh_xep_hang'], ['duration_seconds', 'thoi_gian_lam_giay'],
      ]),
    );
  };

  const rows = list.data?.rows ?? [];

  return (
    <div className="space-y-5">
      <PageHeader
        title="Kết quả làm bài"
        description="Chỉ lần làm đầu tiên của mỗi bài được tính vào bảng xếp hạng; các lần sau là luyện tập."
        actions={<button type="button" className="btn btn-secondary" onClick={exportCsv}><Download className="h-4 w-4" /> Xuất CSV</button>}
      />

      <div className="panel flex flex-wrap items-center gap-3 p-4">
        <div className="flex rounded-lg bg-slate-100 p-1">
          {(Object.keys(RANGE_LABEL) as Range[]).map((r) => (
            <button key={r} type="button" onClick={() => change(() => setRange(r))} className={`rounded-md px-3 py-1.5 text-sm font-medium ${range === r ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600'}`}>
              {RANGE_LABEL[r]}
            </button>
          ))}
        </div>
        <select className="input w-auto" value={studentId} onChange={(e) => change(() => setStudentId(e.target.value))} aria-label="Lọc học sinh">
          <option value="">Tất cả học sinh</option>
          {meta.data?.students.map((s) => <option key={s.id} value={s.id}>{s.full_name}</option>)}
        </select>
        <select className="input w-auto max-w-xs" value={lessonId} onChange={(e) => change(() => setLessonId(e.target.value))} aria-label="Lọc bài">
          <option value="">Tất cả bài</option>
          {meta.data?.lessons.map((l) => <option key={l.id} value={l.id}>{l.subject_name} · T{l.week_number} · {l.name}</option>)}
        </select>
        <label className="flex items-center gap-2 text-sm text-slate-600">
          <input type="checkbox" checked={rankedOnly} onChange={(e) => change(() => setRankedOnly(e.target.checked))} /> Chỉ lần tính điểm
        </label>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Lượt làm bài" value={summary.data?.attempts ?? '…'} />
        <StatCard label="Số học sinh" value={summary.data?.students ?? '…'} tone="green" />
        <StatCard label="Tỉ lệ đúng" value={summary.data ? pct(summary.data.accuracy) : '…'} tone="amber" />
        <StatCard label="Điểm trung bình / bài" value={summary.data?.avgScore ?? '…'} tone="rose" />
      </div>

      {list.error !== null && <AdminError error={list.error} onRetry={list.reload} />}

      <div className="panel overflow-hidden">
        {list.loading && !list.data ? <LoadingBlock /> : rows.length === 0 ? <EmptyState title="Không có bài làm nào trong khoảng này" /> : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr>
                  <th className="th">Lúc nộp</th><th className="th">Học sinh</th><th className="th">Bài</th><th className="th">Loại</th>
                  <th className="th">Đúng</th><th className="th">Điểm</th><th className="th">Thời gian</th>
                </tr>
              </thead>
              <tbody className={list.loading ? 'opacity-60' : ''}>
                {rows.map((a) => (
                  <tr key={a.id} className="border-t border-slate-100">
                    <td className="td whitespace-nowrap text-slate-500">{formatDateTime(a.completed_at)}</td>
                    <td className="td font-medium text-slate-800">{a.student_name}</td>
                    <td className="td">{a.subject_name} · T{a.week_number} · {a.lesson_name}</td>
                    <td className="td whitespace-nowrap">
                      {a.exercise_type === 'advanced' ? 'Nâng cao' : 'Cơ bản'}
                      {a.is_ranked ? <span className="chip ml-1 bg-blue-50 text-blue-700">Tính điểm</span> : <span className="chip ml-1 bg-slate-100 text-slate-500">Luyện tập</span>}
                    </td>
                    <td className="td">
                      <span className={a.correct_count / Math.max(1, a.total_questions) >= 0.8 ? 'text-emerald-700' : a.correct_count / Math.max(1, a.total_questions) < 0.5 ? 'text-rose-600' : ''}>
                        {a.correct_count}/{a.total_questions}
                      </span>
                    </td>
                    <td className="td font-semibold text-blue-700">{a.score}</td>
                    <td className="td whitespace-nowrap text-slate-500">{formatDuration(a.duration_seconds)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        <Pager page={page} pageSize={PAGE_SIZE} total={list.data?.count ?? 0} onChange={setPage} />
      </div>
    </div>
  );
}
