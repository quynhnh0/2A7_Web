import { useEffect, useMemo, useState } from 'react';
import { Link, Navigate, useNavigate } from 'react-router';
import { ChevronRight, Flame, Medal, Rocket, Star, Trophy, Zap } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { clearStudent, getStoredStudent, storeStudent } from '../../lib/studentSession';
import { formatNumber, lessonLabel } from '../../lib/text';
import { useAsync } from '../../hooks/useAsync';
import { Avatar, LoadingBlock, StudentError, subjectEmoji, subjectStyle } from '../../components/ui';
import type { BackendError } from '../../lib/backend';
import type { HomeLesson, StudentHome } from '../../types';

function isDone(l: HomeLesson) {
  return l.basic_best !== null;
}

function pickTodayLesson(home: StudentHome): HomeLesson | null {
  const week = home.config.current_week;
  const pending = home.lessons.filter((l) => !isDone(l));
  const byRecent = (a: HomeLesson, b: HomeLesson) => b.week_number - a.week_number || a.lesson_order - b.lesson_order;
  return (
    pending.filter((l) => l.week_number === week).sort(byRecent)[0] ??
    pending.sort(byRecent)[0] ??
    null
  );
}

function Stars({ correct }: { correct: string | null }) {
  if (!correct) return null;
  const [c, t] = correct.split('/').map(Number);
  const ratio = t ? c / t : 0;
  const n = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : 1;
  return (
    <span className="inline-flex items-center gap-0.5" aria-label={`${n} sao`}>
      {[0, 1, 2].map((i) => (
        <Star key={i} className={`h-4 w-4 ${i < n ? 'text-amber-400' : 'text-slate-200'}`} fill="currentColor" />
      ))}
    </span>
  );
}

function LessonCard({ lesson }: { lesson: HomeLesson }) {
  const st = subjectStyle(lesson.subject_color);
  const done = isDone(lesson);
  const label = lessonLabel(lesson);
  return (
    <div className={`flex flex-col gap-3 rounded-3xl p-5 ring-2 ${st.card}`}>
      <div className="flex items-start justify-between gap-2">
        <span className={`chip ${st.chip}`}>{subjectEmoji(lesson.subject_code, lesson.subject_color)} {lesson.subject_name}</span>
        {done ? (
          <span className="chip bg-emerald-100 text-emerald-800">✓ Đã làm</span>
        ) : (
          <span className="chip bg-white text-slate-500 ring-1 ring-slate-200">Chưa làm</span>
        )}
      </div>
      <div>
        <div className={`text-sm font-bold ${st.text}`}>{label.tag}</div>
        <h3 className="font-display text-xl leading-snug font-bold text-slate-800">{label.title}</h3>
      </div>
      {done && (
        <div className="flex items-center gap-2 text-sm font-semibold text-slate-600">
          <Stars correct={lesson.basic_correct} /> {lesson.basic_correct} câu đúng
          {lesson.basic_ranked_score !== null && <span className="text-amber-600">• {lesson.basic_ranked_score} điểm</span>}
        </div>
      )}
      <div className="mt-auto flex gap-2">
        <Link to={`/lesson/${lesson.id}?mode=basic`} className={`btn-kid ${done ? 'btn-soft' : 'btn-blue'} min-h-12 flex-1 px-3 text-base`}>
          {done ? 'Làm lại' : 'Làm bài'}
        </Link>
        {lesson.has_advanced && (
          <Link to={`/lesson/${lesson.id}?mode=advanced`} className="btn-kid btn-amber min-h-12 px-4 text-base" title="Thử thách nâng cao">
            <Zap className="h-5 w-5" /> {lesson.advanced_correct ? lesson.advanced_correct : 'Nâng cao'}
          </Link>
        )}
      </div>
    </div>
  );
}

function MiniLeaderboard({ studentId }: { studentId: string }) {
  const { data } = useAsync(() => studentApi.getLeaderboard('day', studentId), [studentId]);
  if (!data?.enabled) return null;
  return (
    <div className="card p-5">
      <div className="mb-3 flex items-center justify-between">
        <h2 className="flex items-center gap-2 font-display text-xl font-bold text-slate-800"><Trophy className="h-6 w-6 text-amber-500" /> Top hôm nay</h2>
      </div>
      {data.rows.length === 0 ? (
        <p className="py-4 text-center text-slate-500">Chưa có ai làm bài hôm nay. Bạn làm đầu tiên nhé! 🚀</p>
      ) : (
        <ol className="flex flex-col gap-2">
          {data.rows.slice(0, 5).map((r) => (
            <li key={r.student_id} className={`flex items-center gap-3 rounded-2xl px-3 py-2 ${r.student_id === studentId ? 'bg-blue-50 ring-2 ring-blue-300' : 'bg-slate-50'}`}>
              <span className="w-6 text-center text-lg">{['🥇', '🥈', '🥉'][r.rank - 1] ?? <span className="font-bold text-slate-400">{r.rank}</span>}</span>
              <Avatar name={r.full_name} id={r.student_id} size="h-8 w-8 text-xs" />
              <span className="flex-1 truncate font-bold text-slate-700">{r.display_name}</span>
              <span className="text-sm font-bold text-amber-600">{formatNumber(r.score)}</span>
            </li>
          ))}
        </ol>
      )}
      <Link to="/leaderboard" className="mt-4 flex items-center justify-between rounded-2xl bg-blue-50 px-4 py-3 font-bold text-blue-700 hover:bg-blue-100">
        Xem bảng xếp hạng tuần & tháng <ChevronRight className="h-5 w-5" />
      </Link>
    </div>
  );
}

export default function HomePage() {
  const navigate = useNavigate();
  const stored = getStoredStudent();
  const [subject, setSubject] = useState<string>('all');
  const { data: home, error, loading, reload } = useAsync(
    () => (stored ? studentApi.getHome(stored.id) : Promise.reject(new Error('no student'))),
    [stored?.id],
  );

  useEffect(() => {
    if ((error as BackendError | null)?.code === 'student_not_found' || (error as BackendError | null)?.code === 'student_disabled') {
      clearStudent();
      navigate('/select-student', { replace: true });
    }
  }, [error, navigate]);

  useEffect(() => {
    if (home && stored && home.student.display_name !== stored.display_name) storeStudent(home.student);
  }, [home, stored]);

  const subjects = useMemo(() => {
    const map = new Map<string, string>();
    home?.lessons.forEach((l) => map.set(l.subject_code, l.subject_name));
    return Array.from(map.entries());
  }, [home]);

  if (!stored) return <Navigate to="/select-student" replace />;
  if (loading && !home) return <LoadingBlock label="Đang chuẩn bị bài tập…" />;
  if (error || !home) return <StudentError error={error} onRetry={reload} />;

  const week = home.config.current_week;
  const today = pickTodayLesson(home);
  const lessons = home.lessons.filter((l) => subject === 'all' || l.subject_code === subject);
  const current = lessons.filter((l) => l.week_number >= week);
  const pastWeeks = Array.from(new Set(lessons.filter((l) => l.week_number < week).map((l) => l.week_number))).sort((a, b) => b - a);
  const doneCount = current.filter(isDone).length;

  return (
    <div className="flex flex-col gap-8">
      {/* Lời chào */}
      <section className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-blue-100 via-sky-50 to-amber-100 p-6 shadow-sm sm:p-8 animate-rise">
        <div className="pointer-events-none absolute -right-10 -bottom-10 h-44 w-44 rounded-full bg-amber-300/30 blur-2xl" />
        <div className="relative flex flex-col items-start gap-5 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="chip mb-2 bg-white/80 text-amber-700 uppercase">⭐ Tuần {week} • {home.config.class_name}</p>
            <h1 className="font-display text-3xl font-bold text-blue-700 sm:text-4xl">Xin chào {home.student.display_name}! 🌟</h1>
            <p className="mt-2 text-lg text-slate-600">Hôm nay mình cùng luyện tập thật vui nhé!</p>
            <div className="mt-4 flex flex-wrap gap-2">
              <span className="flex items-center gap-2 rounded-2xl bg-white/90 px-4 py-2 font-bold text-slate-700 shadow-sm">
                <Star className="h-5 w-5 text-amber-500" fill="currentColor" /> {formatNumber(home.points.day)} điểm hôm nay
              </span>
              <span className="flex items-center gap-2 rounded-2xl bg-white/90 px-4 py-2 font-bold text-slate-700 shadow-sm">
                <Medal className="h-5 w-5 text-emerald-600" /> {home.ranks.day ? `Hạng ${home.ranks.day} hôm nay` : 'Chưa có hạng hôm nay'}
              </span>
              <span className="flex items-center gap-2 rounded-2xl bg-white/90 px-4 py-2 font-bold text-slate-700 shadow-sm">
                <Flame className="h-5 w-5 text-rose-500" /> {formatNumber(home.points.week)} điểm tuần
              </span>
            </div>
          </div>
          <div className="hidden h-36 w-36 shrink-0 items-center justify-center rounded-3xl bg-white/70 text-8xl shadow-inner sm:flex" aria-hidden>🦉</div>
        </div>
      </section>

      {/* Bài hôm nay */}
      <section>
        <div className="mb-4 flex items-center gap-2">
          <div className="h-8 w-3.5 rounded-full bg-emerald-600" />
          <h2 className="font-display text-2xl font-bold text-slate-800 sm:text-3xl">Bài hôm nay</h2>
        </div>
        {today ? (
          <div className="grid gap-5 lg:grid-cols-2">
            <div className="card relative flex flex-col gap-4 overflow-hidden p-6 pt-8">
              <div className="absolute inset-x-0 top-0 h-3 bg-emerald-600" />
              <div className="flex items-start justify-between gap-3">
                <div>
                  <span className="chip bg-emerald-100 text-emerald-800 uppercase">{today.subject_name} • {lessonLabel(today).tag}</span>
                  <h3 className="mt-1 font-display text-2xl font-bold text-emerald-700">🟢 Luyện tập cơ bản</h3>
                </div>
                <span className="rounded-2xl bg-slate-100 px-3 py-1.5 text-sm font-bold whitespace-nowrap text-slate-600">{home.basic_count} câu</span>
              </div>
              <p className="text-lg text-slate-700"><strong>{lessonLabel(today).title}</strong></p>
              <Link to={`/lesson/${today.id}?mode=basic`} className="btn-kid btn-green mt-auto text-xl">
                <Rocket className="h-6 w-6" /> BẮT ĐẦU LÀM BÀI
              </Link>
            </div>
            {today.has_advanced && (
              <div className="card relative flex flex-col gap-4 overflow-hidden p-6 pt-8">
                <div className="absolute inset-x-0 top-0 h-3 bg-amber-500" />
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <span className="chip bg-amber-100 text-amber-800 uppercase">Dành cho bạn giỏi</span>
                    <h3 className="mt-1 font-display text-2xl font-bold text-amber-600">🔥 Thử thách nâng cao</h3>
                  </div>
                  <span className="rounded-2xl bg-amber-100 px-3 py-1.5 text-sm font-bold whitespace-nowrap text-amber-800">{home.advanced_count} câu</span>
                </div>
                <p className="text-lg text-slate-700">Nhiều câu khó hơn, <strong>nhiều sao hơn</strong>!</p>
                <Link to={`/lesson/${today.id}?mode=advanced`} className="btn-kid btn-amber mt-auto text-xl">
                  <Zap className="h-6 w-6" /> THỬ SỨC NGAY
                </Link>
              </div>
            )}
          </div>
        ) : (
          <div className="card p-8 text-center">
            <div className="text-6xl">🏆</div>
            <p className="mt-2 font-display text-2xl font-bold text-emerald-700">
              {home.lessons.length ? 'Giỏi quá! Bạn đã làm hết các bài rồi.' : 'Chưa có bài nào được mở.'}
            </p>
            <p className="mt-1 text-slate-600">
              {home.lessons.length ? 'Hãy thử thách nâng cao hoặc làm lại để luyện tập thêm nhé!' : 'Cô giáo sẽ mở bài sớm thôi. Quay lại sau nhé!'}
            </p>
          </div>
        )}
      </section>

      <div className="grid gap-8 lg:grid-cols-[1fr_340px]">
        <div className="flex flex-col gap-8">
          {/* Bài của tuần */}
          <section>
            <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
              <div className="flex items-center gap-2">
                <div className="h-8 w-3.5 rounded-full bg-blue-600" />
                <h2 className="font-display text-2xl font-bold text-slate-800 sm:text-3xl">Bài của tuần {week}</h2>
              </div>
              <span className="text-sm font-semibold text-slate-500">Đã làm {doneCount}/{current.length} bài</span>
            </div>
            {subjects.length > 1 && (
              <div className="mb-4 flex flex-wrap gap-2">
                {[['all', 'Tất cả'], ...subjects].map(([code, name]) => (
                  <button key={code} type="button" onClick={() => setSubject(code)}
                    className={`min-h-11 rounded-full px-5 font-bold transition ${subject === code ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 ring-2 ring-slate-200'}`}>
                    {code === 'all' ? '🌈' : subjectEmoji(code, home.lessons.find((l) => l.subject_code === code)?.subject_color)} {name}
                  </button>
                ))}
              </div>
            )}
            {current.length ? (
              <div className="grid gap-4 sm:grid-cols-2">
                {current.map((l) => <LessonCard key={l.id} lesson={l} />)}
              </div>
            ) : (
              <p className="card p-6 text-center text-slate-500">Tuần này chưa có bài mới. Bạn ôn lại các tuần trước nhé!</p>
            )}
          </section>

          {pastWeeks.length > 0 && (
            <section className="flex flex-col gap-3">
              <h2 className="font-display text-xl font-bold text-slate-700">📚 Ôn lại các tuần trước</h2>
              {pastWeeks.map((w, i) => {
                const items = lessons.filter((l) => l.week_number === w);
                const done = items.filter(isDone).length;
                return (
                  <details key={w} className="card group overflow-hidden" open={i === 0 && done < items.length}>
                    <summary className="flex min-h-14 cursor-pointer list-none items-center justify-between px-5 py-3 font-bold text-slate-700">
                      <span>Tuần {w}</span>
                      <span className="flex items-center gap-2 text-sm text-slate-500">
                        {done}/{items.length} bài <ChevronRight className="h-5 w-5 transition group-open:rotate-90" />
                      </span>
                    </summary>
                    <div className="grid gap-4 border-t border-slate-100 p-4 sm:grid-cols-2">
                      {items.map((l) => <LessonCard key={l.id} lesson={l} />)}
                    </div>
                  </details>
                );
              })}
            </section>
          )}
        </div>
        <aside className="flex flex-col gap-6">
          <MiniLeaderboard studentId={stored.id} />
        </aside>
      </div>
    </div>
  );
}
