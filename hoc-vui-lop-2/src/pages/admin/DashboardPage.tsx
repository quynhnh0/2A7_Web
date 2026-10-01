import { useState } from 'react';
import { Link } from 'react-router';
import { Activity, BookOpen, CalendarDays, CheckCircle2, ChevronLeft, ChevronRight, PieChart, Target, Users } from 'lucide-react';
import { EmptyState, PageHeader, pct, StatCard } from '../../components/admin';
import { AdminError, LoadingBlock, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { formatNumber, relativeTime } from '../../lib/text';

export default function DashboardPage() {
  const { data, error, loading, reload } = useAsync(() => adminApi.dashboard(), []);
  const [savingWeek, setSavingWeek] = useState(false);
  const [weekError, setWeekError] = useState<unknown>(null);

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;
  if (!data) return null;

  const changeWeek = async (delta: number) => {
    const next = Math.min(60, Math.max(1, data.current_week + delta));
    if (next === data.current_week) return;
    setSavingWeek(true);
    setWeekError(null);
    try {
      await adminApi.updateSettings({ current_week: next });
      reload();
    } catch (e) {
      setWeekError(e);
    } finally {
      setSavingWeek(false);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Tổng quan lớp học"
        description="Tình hình học tập hôm nay và tuần này."
        actions={<>
          <Link to="/admin/subject-stats" className="btn btn-secondary"><PieChart className="h-4 w-4" /> Thống kê theo môn</Link>
          <Link to="/admin/generator" className="btn btn-primary">Sinh thêm câu hỏi</Link>
        </>}
      />

      <div className="panel flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-50 text-amber-600"><CalendarDays className="h-6 w-6" /></div>
          <div>
            <p className="text-sm text-slate-500">Tuần học hiện tại</p>
            <p className="text-2xl font-bold text-slate-900">Tuần {data.current_week}</p>
            <p className="text-xs text-slate-500">Các bài đặt lịch “theo tuần” sẽ mở khi tới tuần của bài.</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button type="button" className="btn btn-secondary" disabled={savingWeek || data.current_week <= 1} onClick={() => changeWeek(-1)}>
            <ChevronLeft className="h-4 w-4" /> Lùi tuần
          </button>
          <button type="button" className="btn btn-primary" disabled={savingWeek} onClick={() => changeWeek(1)}>
            {savingWeek ? <Spinner className="h-4 w-4 text-white" /> : null} Sang tuần {data.current_week + 1} <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
      {weekError !== null && <AdminError error={weekError} />}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Học sinh làm bài hôm nay"
          value={`${data.today.active_students}/${data.total_students}`}
          hint={`${data.week.active_students} bạn đã học trong tuần`}
          icon={<Users className="h-5 w-5" />}
        />
        <StatCard
          label="Bài hoàn thành hôm nay"
          value={formatNumber(data.today.attempts_completed)}
          hint={`${formatNumber(data.week.attempts_completed)} bài trong tuần`}
          icon={<CheckCircle2 className="h-5 w-5" />}
          tone="green"
        />
        <StatCard
          label="Tỉ lệ đúng hôm nay"
          value={pct(data.today.accuracy)}
          hint={`Cả tuần: ${pct(data.week.accuracy)}`}
          icon={<Target className="h-5 w-5" />}
          tone="amber"
        />
        <StatCard
          label="Ngân hàng câu hỏi"
          value={formatNumber(data.question_count)}
          hint={`${data.published_count}/${data.lesson_count} bài đang mở`}
          icon={<BookOpen className="h-5 w-5" />}
          tone="rose"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-3">
        <section className="panel xl:col-span-2">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
            <h2 className="font-semibold text-slate-800">Câu hỏi nhiều bạn làm sai</h2>
            <Link to="/admin/questions" className="text-sm text-blue-600 hover:underline">Ngân hàng câu hỏi</Link>
          </div>
          {data.hardest.length === 0 ? (
            <EmptyState title="Chưa đủ dữ liệu">Cần ít nhất 3 lượt trả lời mỗi câu để thống kê.</EmptyState>
          ) : (
            <ul className="divide-y divide-slate-100">
              {data.hardest.map((q) => (
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

        <section className="panel">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
            <h2 className="font-semibold text-slate-800">Chưa làm bài hôm nay</h2>
            <span className="chip bg-slate-100 text-slate-700">{data.inactive_today.length}</span>
          </div>
          {data.inactive_today.length === 0 ? (
            <EmptyState title="Tuyệt vời!">Cả lớp đều đã làm bài hôm nay 🎉</EmptyState>
          ) : (
            <ul className="flex max-h-80 flex-wrap gap-2 overflow-y-auto p-4">
              {data.inactive_today.map((s) => (
                <li key={s.id} className="chip bg-slate-100 text-slate-700" title={s.full_name}>{s.display_name}</li>
              ))}
            </ul>
          )}
        </section>
      </div>

      <section className="panel">
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
          <h2 className="flex items-center gap-2 font-semibold text-slate-800"><Activity className="h-4 w-4" /> Bài làm gần đây</h2>
          <Link to="/admin/results" className="text-sm text-blue-600 hover:underline">Xem tất cả</Link>
        </div>
        {data.recent.length === 0 ? (
          <EmptyState title="Chưa có bài làm nào" />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr><th className="th">Học sinh</th><th className="th">Bài</th><th className="th">Loại</th><th className="th">Đúng</th><th className="th">Điểm</th><th className="th">Lúc</th></tr>
              </thead>
              <tbody>
                {data.recent.map((r) => (
                  <tr key={r.id} className="border-t border-slate-100">
                    <td className="td font-medium text-slate-800">{r.student}</td>
                    <td className="td">{r.lesson}</td>
                    <td className="td">{r.exercise_type === 'advanced' ? 'Nâng cao' : 'Cơ bản'}{!r.is_ranked && <span className="ml-1 text-xs text-slate-400">(luyện tập)</span>}</td>
                    <td className="td">{r.correct_count}/{r.total_questions}</td>
                    <td className="td font-semibold text-blue-700">{r.score}</td>
                    <td className="td text-slate-500">{relativeTime(r.completed_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
