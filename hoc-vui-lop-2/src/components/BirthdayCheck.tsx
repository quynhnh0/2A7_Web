import { useEffect, useRef, useState } from 'react';
import { Cake, Lock } from 'lucide-react';
import { studentApi } from '../lib/api';
import type { StudentIdentity } from '../types';
import { Avatar, Spinner, studentMessage } from './ui';

const DAYS = Array.from({ length: 31 }, (_, i) => i + 1);
const MONTHS = Array.from({ length: 12 }, (_, i) => i + 1);

type Step = 'day' | 'month';

/** Bé chọn ngày rồi tháng sinh; máy chủ so sánh (ngày sinh không bao giờ gửi về trình duyệt). */
export function BirthdayCheck({ student, onVerified, onCancel }: {
  student: StudentIdentity;
  onVerified: (s: StudentIdentity) => void;
  onCancel: () => void;
}) {
  const [step, setStep] = useState<Step>('day');
  const [day, setDay] = useState<number | null>(null);
  const [month, setMonth] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [lockedUntil, setLockedUntil] = useState<number | null>(null);
  const boxRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    boxRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, []);

  useEffect(() => {
    if (!lockedUntil) return;
    const t = window.setTimeout(() => { setLockedUntil(null); setMessage(null); }, Math.max(0, lockedUntil - Date.now()));
    return () => window.clearTimeout(t);
  }, [lockedUntil]);

  const locked = lockedUntil !== null;

  const lock = (seconds: number) => {
    setLockedUntil(Date.now() + seconds * 1000);
    setMessage(`Bạn nhập sai nhiều lần quá. Đợi khoảng ${Math.max(1, Math.ceil(seconds / 60))} phút rồi thử lại, hoặc nhờ cô giáo / bố mẹ giúp nhé!`);
  };

  const submit = async (d: number, m: number) => {
    setBusy(true);
    setMessage(null);
    try {
      const res = await studentApi.verifyBirthday(student.id, d, m);
      if (res.ok) {
        onVerified(res.student ?? student);
        return;
      }
      setDay(null);
      setMonth(null);
      setStep('day');
      if (res.locked_seconds) {
        lock(res.locked_seconds);
      } else {
        setMessage(`Chưa đúng rồi! Bạn thử lại nhé${res.remaining ? ` (còn ${res.remaining} lần)` : ''}.`);
      }
    } catch (e) {
      console.warn('[BirthdayCheck] verify_student lỗi', e);
      setMessage(studentMessage(e));
    } finally {
      setBusy(false);
    }
  };

  const pickDay = (d: number) => {
    setDay(d);
    setMessage(null);
    if (month !== null) void submit(d, month);
    else setStep('month');
  };

  const pickMonth = (m: number) => {
    setMonth(m);
    setMessage(null);
    if (day !== null) void submit(day, m);
    else setStep('day');
  };

  const chip = (active: boolean) =>
    `flex-1 rounded-2xl px-4 py-3 text-center font-display text-xl font-bold ring-2 transition ${
      active ? 'bg-blue-50 text-blue-700 ring-blue-500' : 'bg-white text-slate-700 ring-slate-200'
    }`;
  const cell = (selected: boolean) =>
    `flex min-h-12 items-center justify-center rounded-xl font-display text-xl font-bold ring-2 transition active:scale-95 disabled:opacity-40 ${
      selected ? 'bg-blue-600 text-white ring-blue-600' : 'bg-white text-slate-700 ring-slate-200 hover:ring-blue-400'
    }`;

  return (
    <div ref={boxRef} className="card flex scroll-mt-4 flex-col items-center gap-4 p-5 text-center ring-2 ring-blue-300 animate-pop sm:p-6">
      <Avatar name={student.full_name} id={student.id} size="h-16 w-16 text-xl" />
      <div>
        <p className="font-display text-2xl font-bold text-slate-800">Chào <span className="text-blue-700">{student.display_name}</span>!</p>
        <p className="mt-1 flex items-center justify-center gap-2 text-lg text-slate-600">
          <Cake className="h-6 w-6 text-pink-500" /> Sinh nhật của bạn là ngày nào?
        </p>
      </div>

      <div className="flex w-full max-w-md gap-3">
        <button type="button" className={chip(step === 'day')} onClick={() => setStep('day')} disabled={busy || locked} aria-pressed={step === 'day'}>
          Ngày {day ?? '…'}
        </button>
        <button type="button" className={chip(step === 'month')} onClick={() => setStep('month')} disabled={busy || locked} aria-pressed={step === 'month'}>
          Tháng {month ?? '…'}
        </button>
      </div>

      {message && (
        <p className={`flex items-center gap-2 rounded-2xl px-4 py-3 text-lg font-semibold ${locked ? 'bg-amber-50 text-amber-800' : 'bg-rose-50 text-rose-700'}`} role="alert">
          {locked && <Lock className="h-5 w-5 shrink-0" />} {message}
        </p>
      )}

      {busy ? (
        <div className="flex items-center gap-3 py-6 text-lg text-slate-600"><Spinner className="h-6 w-6 text-blue-600" /> Đang kiểm tra…</div>
      ) : step === 'day' ? (
        <div className="grid w-full max-w-md grid-cols-7 gap-2" role="group" aria-label="Chọn ngày sinh">
          {DAYS.map((d) => (
            <button key={d} type="button" className={cell(day === d)} disabled={locked} onClick={() => pickDay(d)} aria-pressed={day === d}>{d}</button>
          ))}
        </div>
      ) : (
        <div className="grid w-full max-w-md grid-cols-3 gap-2 sm:grid-cols-4" role="group" aria-label="Chọn tháng sinh">
          {MONTHS.map((m) => (
            <button key={m} type="button" className={`${cell(month === m)} min-h-14 text-lg`} disabled={locked} onClick={() => pickMonth(m)} aria-pressed={month === m}>
              Tháng {m}
            </button>
          ))}
        </div>
      )}

      <button type="button" className="btn-kid btn-soft w-full max-w-md" onClick={onCancel}>Không phải mình</button>
    </div>
  );
}
