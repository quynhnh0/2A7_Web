import { useMemo, useState } from 'react';
import { Link, useLocation, useParams } from 'react-router';
import { CheckCircle2, Clock, Home, Info, RotateCcw, Star, Target, Trophy, XCircle } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { formatDuration, lessonLabel } from '../../lib/text';
import { useAsync } from '../../hooks/useAsync';
import { QuestionText } from '../../components/QuestionInput';
import { LoadingBlock, StudentError } from '../../components/ui';
import type { AttemptResult } from '../../types';

function headline(ratio: number) {
  if (ratio >= 0.9) return { title: 'HOÀN THÀNH XUẤT SẮC!', emoji: '🏆', medal: 'Huy chương Vàng', color: 'text-amber-600' };
  if (ratio >= 0.7) return { title: 'GIỎI LẮM!', emoji: '🥈', medal: 'Huy chương Bạc', color: 'text-blue-700' };
  if (ratio >= 0.5) return { title: 'CỐ LÊN NÀO!', emoji: '🥉', medal: 'Huy chương Đồng', color: 'text-orange-600' };
  return { title: 'CÙNG ÔN LẠI NHÉ!', emoji: '🌱', medal: 'Hạt giống chăm chỉ', color: 'text-emerald-700' };
}

function Confetti() {
  const pieces = useMemo(
    () => Array.from({ length: 22 }, (_, i) => ({
      left: (i * 37) % 100,
      delay: (i % 7) * 0.15,
      duration: 1.8 + (i % 5) * 0.3,
      emoji: ['⭐', '🎉', '✨', '🌟', '🎈'][i % 5],
    })),
    [],
  );
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden" aria-hidden>
      {pieces.map((p, i) => (
        <span key={i} className="absolute -top-8 text-2xl"
          style={{ left: `${p.left}%`, animation: `confetti-fall ${p.duration}s ease-in ${p.delay}s 2 both` }}>
          {p.emoji}
        </span>
      ))}
      <style>{`@keyframes confetti-fall { from { transform: translateY(0) rotate(0); opacity: 1 } to { transform: translateY(520px) rotate(300deg); opacity: 0 } }`}</style>
    </div>
  );
}

export default function ResultPage() {
  const { attemptId = '' } = useParams();
  const location = useLocation();
  const initial = (location.state as AttemptResult | null) ?? null;
  const [showReview, setShowReview] = useState(false);
  const { data, error, loading, reload } = useAsync(
    () => (initial?.attempt_id === attemptId ? Promise.resolve(initial) : studentApi.getResult(attemptId)),
    [attemptId],
  );

  if (loading && !data) return <LoadingBlock label="Đang tính điểm…" />;
  if (error) return <StudentError error={error} onRetry={reload} />;
  if (!data) return <StudentError error={{ code: 'attempt_not_found' }} />;

  const ratio = data.total_questions ? data.correct_count / data.total_questions : 0;
  const h = headline(ratio);
  const stars = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;
  const wrong = data.review.filter((r) => !r.is_correct);

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-6">
      <section className="card relative overflow-hidden p-6 text-center sm:p-10 animate-pop">
        {ratio >= 0.7 && <Confetti />}
        <p className="chip mx-auto bg-amber-100 text-amber-800">
          {data.lesson.subject_name} • {lessonLabel(data.lesson).tag}: {lessonLabel(data.lesson).title}
        </p>
        <div className="mt-4 text-7xl" aria-hidden>{h.emoji}</div>
        <h1 className={`mt-2 font-display text-3xl font-bold sm:text-4xl ${h.color}`}>{h.title}</h1>
        <div className="mt-3 flex justify-center gap-1">
          {[0, 1, 2].map((i) => (
            <Star key={i} className={`h-10 w-10 ${i < stars ? 'text-amber-400' : 'text-slate-200'}`} fill="currentColor" />
          ))}
        </div>
        <p className="mt-1 font-semibold text-slate-500">{h.medal}</p>

        <div className="mt-6 grid grid-cols-3 gap-3">
          <div className="rounded-2xl bg-emerald-50 p-3 ring-1 ring-emerald-200">
            <Target className="mx-auto h-6 w-6 text-emerald-600" />
            <div className="mt-1 font-display text-3xl font-bold text-emerald-700">{data.correct_count}/{data.total_questions}</div>
            <div className="text-xs font-semibold text-slate-500">câu đúng</div>
          </div>
          <div className="rounded-2xl bg-amber-50 p-3 ring-1 ring-amber-200">
            <Star className="mx-auto h-6 w-6 text-amber-500" fill="currentColor" />
            <div className="mt-1 font-display text-3xl font-bold text-amber-600">+{data.score}</div>
            <div className="text-xs font-semibold text-slate-500">điểm</div>
          </div>
          <div className="rounded-2xl bg-blue-50 p-3 ring-1 ring-blue-200">
            <Clock className="mx-auto h-6 w-6 text-blue-600" />
            <div className="mt-1 font-display text-xl leading-9 font-bold text-blue-700">{formatDuration(data.duration_seconds)}</div>
            <div className="text-xs font-semibold text-slate-500">thời gian</div>
          </div>
        </div>

        <p className={`mt-5 flex items-center justify-center gap-2 rounded-2xl px-4 py-2 text-sm font-semibold ${data.is_ranked ? 'bg-amber-50 text-amber-800' : 'bg-sky-50 text-sky-800'}`}>
          <Info className="h-4 w-4 shrink-0" />
          {data.is_ranked
            ? 'Điểm lần này đã được cộng vào bảng xếp hạng!'
            : 'Lần làm lại để luyện tập — không cộng vào bảng xếp hạng.'}
        </p>

        <div className="mt-6 grid gap-3 sm:grid-cols-2">
          {wrong.length > 0 && (
            <button type="button" className="btn-kid btn-soft" onClick={() => setShowReview((v) => !v)}>
              {showReview ? 'Ẩn câu sai' : `Xem lại câu sai (${wrong.length})`}
            </button>
          )}
          <Link to={`/lesson/${data.lesson.id}?mode=${data.exercise_type}`} className="btn-kid btn-blue">
            <RotateCcw className="h-5 w-5" /> Làm lại để luyện tập
          </Link>
          <Link to="/home" className="btn-kid btn-green"><Home className="h-5 w-5" /> Về trang bài tập</Link>
          <Link to="/leaderboard" className="btn-kid btn-amber"><Trophy className="h-5 w-5" /> Xem bảng xếp hạng</Link>
        </div>
      </section>

      {showReview && (
        <section className="flex flex-col gap-3 animate-rise">
          <h2 className="font-display text-2xl font-bold text-slate-800">Cùng xem lại nhé 👀</h2>
          {wrong.map((r) => (
            <div key={r.question_id} className="card flex flex-col gap-3 p-5">
              <QuestionText text={r.text} big={false} />
              <div className="flex flex-wrap gap-3 text-base">
                <span className="flex items-center gap-1.5 rounded-xl bg-rose-50 px-3 py-1.5 font-semibold text-rose-700">
                  <XCircle className="h-5 w-5" /> Bạn chọn: {r.student_answer || '(bỏ trống)'}
                </span>
                <span className="flex items-center gap-1.5 rounded-xl bg-emerald-50 px-3 py-1.5 font-semibold text-emerald-700">
                  <CheckCircle2 className="h-5 w-5" /> Đáp án: {r.correct_answer}
                </span>
              </div>
              {r.explanation && <p className="text-slate-600">💡 {r.explanation}</p>}
            </div>
          ))}
        </section>
      )}
    </div>
  );
}
