import { useState } from 'react';
import { Link } from 'react-router';
import { Lightbulb, RotateCw, Star } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { getStoredStudent } from '../../lib/studentSession';
import { formatNumber } from '../../lib/text';
import { useAsync } from '../../hooks/useAsync';
import { PERIOD_LABEL, PeriodTabs, Podium, RankList } from '../../components/Leaderboard';
import { Avatar, LoadingBlock, StudentError } from '../../components/ui';
import type { Period } from '../../types';

export default function LeaderboardPage() {
  const student = getStoredStudent();
  const [period, setPeriod] = useState<Period>('day');
  const { data, error, loading, reload } = useAsync(() => studentApi.getLeaderboard(period, student?.id), [period, student?.id]);

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-6">
      <div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <h1 className="font-display text-3xl font-bold text-slate-800 sm:text-4xl">🏆 Bảng Vàng Thi Đua</h1>
          <p className="mt-1 text-slate-500">Cùng bạn bè học tập thật vui và chăm chỉ mỗi ngày!</p>
        </div>
        <PeriodTabs value={period} onChange={setPeriod} />
      </div>

      {loading && !data && <LoadingBlock label="Đang xếp hạng…" />}
      {!!error && <StudentError error={error} onRetry={reload} />}

      {data && !data.enabled && (
        <div className="card p-8 text-center text-lg text-slate-600">Bảng xếp hạng đang tạm tắt. 🌙</div>
      )}

      {data?.enabled && (
        <>
          {data.rows.length === 0 ? (
            <div className="card p-10 text-center">
              <div className="text-6xl">🌟</div>
              <p className="mt-3 font-display text-2xl font-bold text-slate-700">{PERIOD_LABEL[period]} chưa có ai ghi điểm.</p>
              <Link to="/home" className="btn-kid btn-blue mt-5">Làm bài ngay để đứng đầu!</Link>
            </div>
          ) : (
            <>
              <section className="rounded-3xl bg-gradient-to-b from-amber-50 to-white px-3 pt-6 ring-1 ring-amber-100 sm:px-8">
                <Podium rows={data.rows} meId={student?.id} />
              </section>
              {data.rows.length > 3 && (
                <section className="card p-2 sm:p-4">
                  <div className="flex items-center justify-between px-3 py-2">
                    <span className="text-xs font-bold tracking-wider text-slate-500 uppercase">Các bạn học tốt khác</span>
                    <button type="button" onClick={reload} className="flex items-center gap-1 text-xs font-bold text-blue-600">
                      <RotateCw className="h-3.5 w-3.5" /> Cập nhật
                    </button>
                  </div>
                  <RankList rows={data.rows} meId={student?.id} />
                </section>
              )}
            </>
          )}

          {student && (
            <section className="sticky bottom-20 flex items-center gap-3 rounded-3xl bg-blue-700 p-4 text-white shadow-xl md:bottom-4">
              <Avatar name={student.full_name} id={student.id} size="h-12 w-12 text-base" />
              <div className="min-w-0 flex-1">
                <div className="text-xs font-bold tracking-wider text-blue-200 uppercase">Vị trí của bạn • {PERIOD_LABEL[period]}</div>
                <div className="truncate font-display text-lg font-bold">{student.full_name}</div>
              </div>
              <div className="text-right">
                <div className="font-display text-2xl font-bold">{data.me ? `#${data.me.rank}` : '—'}</div>
                <div className="flex items-center justify-end gap-1 text-sm text-amber-300"><Star className="h-4 w-4" fill="currentColor" /> {formatNumber(data.me?.score ?? 0)}</div>
              </div>
            </section>
          )}

          <p className="flex items-start gap-2 rounded-2xl bg-slate-100 p-4 text-sm text-slate-600">
            <Lightbulb className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
            Luật chơi công bằng: mỗi bài chỉ tính điểm lần làm đầu tiên. Câu càng khó càng được nhiều điểm. Các lần làm lại giúp bạn luyện tập thêm!
          </p>
        </>
      )}
    </div>
  );
}
