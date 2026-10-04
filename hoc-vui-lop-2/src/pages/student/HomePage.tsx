import { useEffect, useMemo, useState } from 'react';
import { Link, Navigate, useNavigate } from 'react-router';
import { ChevronRight, Clock, Flame, Gem, Lock, Medal, Moon, Rocket, Star, Trophy, Zap } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { clearStudent, getStoredStudent, storeStudent } from '../../lib/studentSession';
import { formatNumber, formatOpenTime, lessonLabel, MEDAL_INFO } from '../../lib/text';
import { useAsync } from '../../hooks/useAsync';
import { Avatar, LoadingBlock, StudentError, subjectEmoji, subjectStyle } from '../../components/ui';
import type { BackendError } from '../../lib/backend';
import type { DailyQuota, HomeLesson, MedalKind, ScheduleStatus, StudentHome, StudentRewards } from '../../types';

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

/** null = được làm; còn lại là lý do khoá nút bắt đầu đề mới. */
type LockReason = null | 'closed' | 'limit' | 'week_limit';

const LOCK_LABEL: Record<Exclude<LockReason, null>, string> = {
  closed: 'Chưa đến giờ',
  limit: 'Mai làm tiếp',
  week_limit: 'Tuần sau làm tiếp',
};

function lockFor(home: StudentHome, subjectCode: string): LockReason {
  if (home.schedule && !home.schedule.open) return 'closed';
  const q = home.daily?.[subjectCode];
  if (q?.week_max && (q.week_used ?? 0) >= q.week_max) return 'week_limit';
  if (q && q.max > 0 && q.used >= q.max) return 'limit';
  return null;
}

function quotaText(q: DailyQuota, subjectName: string): string | null {
  const parts: string[] = [];
  if (q.max > 0) parts.push(`Hôm nay còn ${q.max - q.used}/${q.max}`);
  if (q.week_max) parts.push(`tuần này còn ${q.week_max - (q.week_used ?? 0)}/${q.week_max}`);
  if (parts.length === 0) return null;
  const text = `${parts.join(', ')} đề ${subjectName}`;
  return text.charAt(0).toUpperCase() + text.slice(1);
}

function LockedButton({ reason, className = '' }: { reason: Exclude<LockReason, null>; className?: string }) {
  return (
    <span className={`btn-kid btn-soft min-h-12 flex-1 cursor-not-allowed px-3 text-base opacity-70 ${className}`} aria-disabled>
      <Lock className="h-5 w-5" /> {LOCK_LABEL[reason]}
    </span>
  );
}

function LessonCard({ lesson, lock, quota }: { lesson: HomeLesson; lock: LockReason; quota?: DailyQuota }) {
  const st = subjectStyle(lesson.subject_color);
  const done = isDone(lesson);
  const label = lessonLabel(lesson);
  const quotaLine = quota && !lock ? quotaText(quota, lesson.subject_name) : null;
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
      {quotaLine && <p className="text-xs font-semibold text-slate-500">{quotaLine}</p>}
      <div className="mt-auto flex gap-2">
        {lock ? (
          <LockedButton reason={lock} />
        ) : (
          <>
            <Link to={`/lesson/${lesson.id}?mode=basic`} className={`btn-kid ${done ? 'btn-soft' : 'btn-blue'} min-h-12 flex-1 px-3 text-base`}>
              {done ? 'Làm lại' : 'Làm bài'}
            </Link>
            {lesson.has_advanced && (
              <Link to={`/lesson/${lesson.id}?mode=advanced`} className="btn-kid btn-amber min-h-12 px-4 text-base" title="Thử thách nâng cao">
                <Zap className="h-5 w-5" /> {lesson.advanced_correct ? lesson.advanced_correct : 'Nâng cao'}
              </Link>
            )}
          </>
        )}
      </div>
    </div>
  );
}

function ScheduleBanner({ schedule }: { schedule: ScheduleStatus }) {
  if (!schedule.enabled) return null;
  if (!schedule.open) {
    return (
      <div className="flex items-center gap-3 rounded-3xl bg-indigo-50 px-5 py-4 text-indigo-900 ring-2 ring-indigo-200" role="status">
        <Moon className="h-8 w-8 shrink-0 text-indigo-500" />
        <div>
          <p className="font-display text-lg font-bold">Bây giờ là giờ nghỉ ngơi 🌙</p>
          <p className="text-sm">
            {schedule.next_open_at ? <>Giờ làm bài mở lại lúc <b>{formatOpenTime(schedule.next_open_at)}</b>. </> : null}
            Bạn vẫn xem được điểm và bảng xếp hạng nhé!
          </p>
        </div>
      </div>
    );
  }
  const minutesLeft = schedule.closes_at ? Math.round((new Date(schedule.closes_at).getTime() - Date.now()) / 60000) : null;
  if (minutesLeft === null || minutesLeft > 60) return null;
  return (
    <div className="flex items-center gap-3 rounded-3xl bg-amber-50 px-5 py-3 font-semibold text-amber-900 ring-2 ring-amber-200" role="status">
      <Clock className="h-6 w-6 shrink-0 text-amber-500" /> Còn khoảng {Math.max(1, minutesLeft)} phút nữa là hết giờ làm bài hôm nay.
    </div>
  );
}

function RewardsCard({ rewards }: { rewards: StudentRewards }) {
  const toNext = rewards.stars_per_diamond - rewards.stars;
  const week = rewards.this_week;
  const t = rewards.thresholds;
  const counts = (['gold', 'silver', 'bronze', 'encourage'] as MedalKind[]).filter((k) => rewards.medal_counts[k]);
  return (
    <div className="card flex flex-col gap-4 p-5">
      <h2 className="flex items-center gap-2 font-display text-xl font-bold text-slate-800"><Gem className="h-6 w-6 text-sky-500" /> Kho báu của bạn</h2>
      <div className="flex items-center gap-3">
        <div className="flex flex-1 items-center gap-2 rounded-2xl bg-sky-50 px-3 py-2 ring-1 ring-sky-200">
          <span className="text-2xl" aria-hidden>💎</span>
          <div><div className="font-display text-2xl font-bold text-sky-700">{formatNumber(rewards.diamonds)}</div><div className="text-xs font-semibold text-slate-500">kim cương</div></div>
        </div>
        <div className="flex flex-1 items-center gap-2 rounded-2xl bg-amber-50 px-3 py-2 ring-1 ring-amber-200">
          <span className="text-2xl" aria-hidden>⭐</span>
          <div><div className="font-display text-2xl font-bold text-amber-600">{formatNumber(rewards.stars)}</div><div className="text-xs font-semibold text-slate-500">sao</div></div>
        </div>
      </div>
      <div>
        <div className="h-3 overflow-hidden rounded-full bg-slate-100" role="progressbar" aria-valuemin={0} aria-valuemax={rewards.stars_per_diamond} aria-valuenow={rewards.stars}>
          <div className="h-full rounded-full bg-gradient-to-r from-amber-300 to-sky-400" style={{ width: `${(100 * rewards.stars) / rewards.stars_per_diamond}%` }} />
        </div>
        <p className="mt-1 text-xs font-semibold text-slate-500">Thêm {toNext} sao nữa để đổi 1 kim cương ({rewards.stars_per_diamond} sao = 1 💎)</p>
      </div>

      {rewards.medal_eligible === false && (
        <p className="rounded-2xl bg-slate-50 p-3 text-xs font-semibold text-slate-500">Huy chương tuần chỉ dành cho các bạn trong lớp. Bạn vẫn nhận sao và kim cương như mọi bạn nhé!</p>
      )}
      {week && (
        <div className="rounded-2xl bg-slate-50 p-3">
          <div className="flex items-center justify-between gap-2">
            <span className="font-bold text-slate-700">Huy chương tuần này</span>
            {week.medal && <span className={`chip ${MEDAL_INFO[week.medal].className}`}>{MEDAL_INFO[week.medal].emoji} {MEDAL_INFO[week.medal].label}</span>}
          </div>
          <div className="relative mt-3 h-3 rounded-full bg-slate-200">
            <div className="h-full rounded-full bg-emerald-500" style={{ width: `${Math.min(100, week.pct)}%` }} />
            {[t.bronze, t.silver, t.gold].map((p, i) => (
              <span key={p + '-' + i} className="absolute -top-1 h-5 w-0.5 bg-slate-400" style={{ left: `${p}%` }} aria-hidden />
            ))}
          </div>
          <div className="relative mt-1 h-4 text-[10px] font-bold text-slate-500">
            <span className="absolute -translate-x-1/2" style={{ left: `${t.bronze}%` }}>🥉</span>
            <span className="absolute -translate-x-1/2" style={{ left: `${t.silver}%` }}>🥈</span>
            <span className="absolute -translate-x-1/2" style={{ left: `${t.gold}%` }}>🥇</span>
          </div>
          <p className="mt-1 text-xs font-semibold text-slate-500">
            {formatNumber(week.score)}/{formatNumber(week.max_score)} điểm ({week.pct}%) các bài tuần {week.class_week}. Trên {t.gold}% được Vàng, trên {t.silver}% Bạc, trên {t.bronze}% Đồng.
          </p>
        </div>
      )}
      {(rewards.last_week?.medal || counts.length > 0) && (
        <div className="flex flex-wrap items-center gap-2 text-sm">
          {rewards.last_week?.medal && (
            <span className={`chip ${MEDAL_INFO[rewards.last_week.medal].className}`}>Tuần trước: {MEDAL_INFO[rewards.last_week.medal].emoji} {MEDAL_INFO[rewards.last_week.medal].label}</span>
          )}
          {counts.map((k) => <span key={k} className="chip bg-white text-slate-600 ring-1 ring-slate-200">{MEDAL_INFO[k].emoji} × {rewards.medal_counts[k]}</span>)}
        </div>
      )}
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
  const card = (l: HomeLesson) => <LessonCard key={l.id} lesson={l} lock={lockFor(home, l.subject_code)} quota={home.daily?.[l.subject_code]} />;
  const todayLock = today ? lockFor(home, today.subject_code) : null;
  const todayQuota = today ? home.daily?.[today.subject_code] : undefined;

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
              {home.rewards && (
                <span className="flex items-center gap-2 rounded-2xl bg-white/90 px-4 py-2 font-bold text-slate-700 shadow-sm">
                  💎 {formatNumber(home.rewards.diamonds)} · ⭐ {formatNumber(home.rewards.stars)}
                </span>
              )}
            </div>
          </div>
          <div className="hidden h-36 w-36 shrink-0 items-center justify-center rounded-3xl bg-white/70 text-8xl shadow-inner sm:flex" aria-hidden>🦉</div>
        </div>
      </section>

      {home.schedule && <ScheduleBanner schedule={home.schedule} />}

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
                <span className="rounded-2xl bg-slate-100 px-3 py-1.5 text-sm font-bold whitespace-nowrap text-slate-600">{todayQuota?.basic_count ?? home.basic_count} câu</span>
              </div>
              <p className="text-lg text-slate-700"><strong>{lessonLabel(today).title}</strong></p>
              {todayLock ? (
                <LockedButton reason={todayLock} className="mt-auto flex-none text-xl" />
              ) : (
                <Link to={`/lesson/${today.id}?mode=basic`} className="btn-kid btn-green mt-auto text-xl">
                  <Rocket className="h-6 w-6" /> BẮT ĐẦU LÀM BÀI
                </Link>
              )}
            </div>
            {today.has_advanced && (
              <div className="card relative flex flex-col gap-4 overflow-hidden p-6 pt-8">
                <div className="absolute inset-x-0 top-0 h-3 bg-amber-500" />
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <span className="chip bg-amber-100 text-amber-800 uppercase">Dành cho bạn giỏi</span>
                    <h3 className="mt-1 font-display text-2xl font-bold text-amber-600">🔥 Thử thách nâng cao</h3>
                  </div>
                  <span className="rounded-2xl bg-amber-100 px-3 py-1.5 text-sm font-bold whitespace-nowrap text-amber-800">{todayQuota?.advanced_count ?? home.advanced_count} câu</span>
                </div>
                <p className="text-lg text-slate-700">Nhiều câu khó hơn, <strong>nhiều sao hơn</strong>!</p>
                {todayLock ? (
                  <LockedButton reason={todayLock} className="mt-auto flex-none text-xl" />
                ) : (
                  <Link to={`/lesson/${today.id}?mode=advanced`} className="btn-kid btn-amber mt-auto text-xl">
                    <Zap className="h-6 w-6" /> THỬ SỨC NGAY
                  </Link>
                )}
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
                {current.map(card)}
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
                      {items.map(card)}
                    </div>
                  </details>
                );
              })}
            </section>
          )}
        </div>
        <aside className="flex flex-col gap-6">
          {home.rewards && <RewardsCard rewards={home.rewards} />}
          <MiniLeaderboard studentId={stored.id} />
        </aside>
      </div>
    </div>
  );
}
