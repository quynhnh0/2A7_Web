import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, Navigate, useNavigate, useParams, useSearchParams } from 'react-router';
import { ArrowLeft, ArrowRight, CheckCircle2, Info, Lightbulb, Star, Volume2, VolumeX, XCircle } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { getDeviceToken, getStoredStudent } from '../../lib/studentSession';
import { lessonLabel, stableShuffle } from '../../lib/text';
import { canSpeak, speak, stopSpeaking } from '../../lib/speech';
import { isMuted, playCorrect, playFinish, playWrong, setMuted } from '../../lib/sfx';
import { useAsync } from '../../hooks/useAsync';
import { ChoiceAnswer, NumberAnswer, QuestionText, TextAnswer } from '../../components/QuestionInput';
import { LoadingBlock, StudentError, studentMessage, subjectStyle } from '../../components/ui';
import type { AnswerResult, ExerciseType } from '../../types';

const PRAISE = ['Đúng rồi! Giỏi quá! 🎉', 'Chính xác! 🌟', 'Tuyệt vời! 👏', 'Xuất sắc! 🏆', 'Hay lắm! 💪'];
const ENCOURAGE = ['Chưa đúng rồi, cố lên nhé! 💪', 'Sai một chút thôi! 🌈', 'Không sao, lần sau sẽ đúng! 🍀'];

export default function LessonPage() {
  const { lessonId = '' } = useParams();
  const [params] = useSearchParams();
  const mode: ExerciseType = params.get('mode') === 'advanced' ? 'advanced' : 'basic';
  const navigate = useNavigate();
  const student = getStoredStudent();

  const { data: attempt, error, loading, reload } = useAsync(
    () => (student ? studentApi.startAttempt(student.id, lessonId, mode, getDeviceToken()) : Promise.reject(new Error('no student'))),
    [student?.id, lessonId, mode],
  );

  const [answered, setAnswered] = useState<Record<string, AnswerResult>>({});
  const [index, setIndex] = useState(0);
  const [value, setValue] = useState('');
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);
  const [muted, setMutedState] = useState(isMuted());

  useEffect(() => {
    if (!attempt) return;
    setAnswered(attempt.answered ?? {});
    const firstOpen = attempt.questions.findIndex((q) => !attempt.answered?.[q.id]);
    setIndex(firstOpen === -1 ? attempt.questions.length - 1 : firstOpen);
    setValue('');
  }, [attempt]);

  useEffect(() => () => stopSpeaking(), []);

  const question = attempt?.questions[index];
  const result = question ? answered[question.id] ?? null : null;
  const total = attempt?.questions.length ?? 0;
  const answeredCount = Object.keys(answered).length;
  const earned = Object.values(answered).reduce((s, a) => s + a.score_awarded, 0);
  const isLast = index === total - 1;

  const options = useMemo(() => {
    if (!question?.options) return null;
    const short = question.options.every((o) => o.length <= 1);
    return short ? question.options : stableShuffle(question.options, question.id);
  }, [question]);

  const submit = useCallback(async () => {
    if (!attempt || !question || result || busy || !value.trim()) return;
    setBusy(true);
    setActionError(null);
    try {
      const r = await studentApi.submitAnswer(attempt.attempt_id, question.id, value.trim());
      setAnswered((prev) => ({ ...prev, [question.id]: r }));
      if (r.is_correct) playCorrect();
      else playWrong();
    } catch (e) {
      setActionError(studentMessage(e));
    } finally {
      setBusy(false);
    }
  }, [attempt, question, result, busy, value]);

  const finish = async () => {
    if (!attempt) return;
    setBusy(true);
    setActionError(null);
    try {
      const res = await studentApi.finishAttempt(attempt.attempt_id);
      playFinish();
      navigate(`/result/${attempt.attempt_id}`, { replace: true, state: res });
    } catch (e) {
      setActionError(studentMessage(e));
      setBusy(false);
    }
  };

  const next = () => {
    stopSpeaking();
    if (isLast) {
      void finish();
      return;
    }
    setIndex((i) => Math.min(total - 1, i + 1));
    setValue('');
  };

  if (!student) return <Navigate to="/select-student" replace />;
  if (loading && !attempt) return <LoadingBlock label="Đang lấy câu hỏi…" />;
  if (error || !attempt) return <StudentError error={error} onRetry={reload} />;
  if (!question) return <StudentError error={{ code: 'no_questions' }} />;

  const st = subjectStyle(attempt.lesson.subject_color);
  const unansweredBefore = attempt.questions.slice(0, index).some((q) => !answered[q.id]);

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-5">
      {/* Thanh tiêu đề bài */}
      <div className="card flex flex-wrap items-center gap-3 p-4">
        <Link to="/home" className="btn-kid btn-soft min-h-11 px-3 text-sm" aria-label="Về trang chủ (bài làm được lưu lại)">
          <ArrowLeft className="h-5 w-5" /> <span className="hidden sm:inline">Về</span>
        </Link>
        <div className="min-w-0 flex-1">
          <div className={`text-xs font-bold uppercase ${st.text}`}>
            {attempt.lesson.subject_name} • Tuần {attempt.lesson.week_number} • {mode === 'advanced' ? '🔥 Nâng cao' : 'Cơ bản'}
          </div>
          <h1 className="truncate font-display text-lg font-bold text-slate-800 sm:text-xl">{lessonLabel(attempt.lesson).tag}: {lessonLabel(attempt.lesson).title}</h1>
        </div>
        <span className="flex items-center gap-1 rounded-full bg-amber-100 px-3 py-1.5 font-bold text-amber-800">
          <Star className="h-5 w-5 text-amber-500" fill="currentColor" /> {earned}
        </span>
        <button type="button" className="rounded-xl bg-slate-100 p-2.5 text-slate-600" onClick={() => { setMuted(!muted); setMutedState(!muted); }}
          aria-label={muted ? 'Bật âm thanh' : 'Tắt âm thanh'}>
          {muted ? <VolumeX className="h-5 w-5" /> : <Volume2 className="h-5 w-5" />}
        </button>
      </div>

      {!attempt.is_ranked && (
        <div className="flex items-center gap-2 rounded-2xl bg-sky-50 px-4 py-3 text-sm font-semibold text-sky-800 ring-1 ring-sky-200">
          <Info className="h-5 w-5 shrink-0" /> Bạn đã làm bài này rồi. Lần này để luyện tập thêm, không tính điểm xếp hạng.
        </div>
      )}

      {/* Tiến độ */}
      <div className="flex items-center gap-3">
        <div className="flex flex-1 flex-wrap gap-1.5" aria-label={`Câu ${index + 1} trên ${total}`}>
          {attempt.questions.map((q, i) => {
            const a = answered[q.id];
            const color = a ? (a.is_correct ? 'bg-emerald-500' : 'bg-rose-400') : i === index ? 'bg-blue-600' : 'bg-slate-200';
            return (
              <button key={q.id} type="button" onClick={() => { setIndex(i); setValue(''); }}
                className={`h-3 flex-1 rounded-full transition ${color} ${i === index ? 'ring-2 ring-blue-300 ring-offset-2' : ''}`}
                aria-label={`Câu ${i + 1}`} />
            );
          })}
        </div>
        <span className="font-display text-lg font-bold whitespace-nowrap text-slate-600">{index + 1}/{total}</span>
      </div>

      {/* Câu hỏi */}
      <div key={question.id} className="card flex flex-col gap-6 p-5 sm:p-8 animate-rise">
        <div className="flex items-center justify-between gap-2">
          <span className="chip bg-slate-100 text-slate-600">
            Câu {index + 1} • {question.difficulty === 3 ? '🔥 Khó' : question.difficulty === 2 ? 'Vừa' : 'Dễ'} • +{question.points} điểm
          </span>
          {canSpeak && (
            <button type="button" onClick={() => speak(question.text)} className="flex items-center gap-1.5 rounded-xl bg-blue-50 px-3 py-2 text-sm font-bold text-blue-700 hover:bg-blue-100">
              <Volume2 className="h-4 w-4" /> Đọc đề
            </button>
          )}
        </div>

        <div className="rounded-2xl bg-slate-50 px-4 py-6 text-center sm:px-8">
          <QuestionText text={question.text} fill={question.type === 'number' ? (result?.student_answer ?? value) : undefined} />
        </div>

        {question.type === 'multiple_choice' && options && (
          <ChoiceAnswer options={options} value={result?.student_answer ?? value} onChange={setValue} result={result} />
        )}
        {question.type === 'number' && (
          <NumberAnswer value={result?.student_answer ?? value} onChange={setValue} onSubmit={result ? next : submit} disabled={!!result || busy} />
        )}
        {question.type === 'text' && (
          <TextAnswer value={result?.student_answer ?? value} onChange={setValue} onSubmit={submit} disabled={!!result || busy} />
        )}

        {result && (
          <div className={`flex flex-col gap-2 rounded-2xl p-4 animate-pop ${result.is_correct ? 'bg-emerald-50 ring-2 ring-emerald-300' : 'bg-rose-50 ring-2 ring-rose-200'}`} role="status">
            <div className="flex items-center gap-2">
              {result.is_correct ? <CheckCircle2 className="h-8 w-8 text-emerald-600" /> : <XCircle className="h-8 w-8 text-rose-500" />}
              <span className={`font-display text-2xl font-bold ${result.is_correct ? 'text-emerald-700' : 'text-rose-600'}`}>
                {result.is_correct ? PRAISE[index % PRAISE.length] : ENCOURAGE[index % ENCOURAGE.length]}
              </span>
              {result.is_correct && <span className="ml-auto rounded-full bg-amber-400 px-3 py-1 font-bold text-white">+{result.score_awarded} ⭐</span>}
            </div>
            {!result.is_correct && (
              <p className="text-lg text-slate-700">Đáp án đúng là: <strong className="text-emerald-700">{result.correct_answer}</strong></p>
            )}
            {result.explanation && (
              <p className="flex items-start gap-2 text-slate-600"><Lightbulb className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" /> {result.explanation}</p>
            )}
          </div>
        )}

        {actionError && <p className="text-center font-semibold text-rose-600">{actionError}</p>}
      </div>

      {/* Nút điều hướng */}
      <div className="sticky bottom-20 z-30 md:bottom-4">
        <div className="card flex items-center gap-3 p-3">
          <button type="button" className="btn-kid btn-soft px-4" disabled={index === 0} onClick={() => { setIndex(index - 1); setValue(''); }} aria-label="Câu trước">
            <ArrowLeft className="h-6 w-6" />
          </button>
          {!result ? (
            <button type="button" className="btn-kid btn-blue flex-1 text-xl" disabled={!value.trim() || busy} onClick={submit}>
              {busy ? 'Đang chấm…' : 'KIỂM TRA ✓'}
            </button>
          ) : isLast && (answeredCount < total) ? (
            <button type="button" className="btn-kid btn-amber flex-1 text-lg" onClick={() => {
              const firstOpen = attempt.questions.findIndex((q) => !answered[q.id]);
              setIndex(firstOpen); setValue('');
            }}>
              Còn {total - answeredCount} câu chưa làm <ArrowRight className="h-6 w-6" />
            </button>
          ) : (
            <button type="button" className="btn-kid btn-green flex-1 text-xl" disabled={busy} onClick={next}>
              {isLast ? (busy ? 'Đang tổng kết…' : 'XEM KẾT QUẢ 🎉') : <>CÂU TIẾP THEO <ArrowRight className="h-6 w-6" /></>}
            </button>
          )}
        </div>
        {unansweredBefore && !result && <p className="mt-2 text-center text-sm text-slate-500">Bạn có thể quay lại làm các câu còn bỏ trống.</p>}
      </div>
    </div>
  );
}
