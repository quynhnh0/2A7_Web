import { useEffect, useRef, type ReactNode } from 'react';
import { Check, Delete, X } from 'lucide-react';
import type { AnswerResult } from '../types';

const LETTERS = ['A', 'B', 'C', 'D'];

const same = (a: string | null | undefined, b: string | null | undefined) =>
  (a ?? '').trim().normalize('NFC').toLocaleLowerCase('vi') === (b ?? '').trim().normalize('NFC').toLocaleLowerCase('vi');

/** Hiển thị đề; "___" thành ô trống (có thể điền sẵn giá trị bé đang nhập). */
export function QuestionText({ text, fill, big = true }: { text: string; fill?: ReactNode; big?: boolean }) {
  const parts = text.split(/_{2,}/);
  return (
    <p className={`font-display font-bold whitespace-pre-line text-slate-800 ${big ? 'text-2xl leading-relaxed sm:text-3xl sm:leading-relaxed' : 'text-base'}`}>
      {parts.map((part, i) => (
        <span key={i}>
          {part}
          {i < parts.length - 1 && (
            <span className="mx-1 inline-flex min-w-16 items-center justify-center rounded-xl border-b-4 border-dashed border-blue-300 bg-blue-50 px-3 align-middle text-blue-700">
              {fill || '\u00a0'}
            </span>
          )}
        </span>
      ))}
    </p>
  );
}

export function ChoiceAnswer({ options, value, onChange, result }: {
  options: string[]; value: string; onChange: (v: string) => void; result: AnswerResult | null;
}) {
  const locked = !!result;
  const shortOptions = options.every((o) => o.length <= 3);
  return (
    <div className={`grid gap-4 ${shortOptions ? 'grid-cols-3 sm:grid-cols-4' : 'grid-cols-1 sm:grid-cols-2'}`}>
      {options.map((opt, i) => {
        const selected = same(value, opt);
        const isCorrect = locked && same(result.correct_answer, opt);
        const isWrongPick = locked && selected && !result.is_correct;
        let style = 'bg-white ring-slate-200 hover:ring-blue-300 hover:bg-blue-50/40';
        if (selected && !locked) style = 'bg-blue-50 ring-blue-500';
        if (isCorrect) style = 'bg-emerald-50 ring-emerald-500';
        if (isWrongPick) style = 'bg-rose-50 ring-rose-400 animate-shake';
        if (locked && !isCorrect && !isWrongPick) style = 'bg-white ring-slate-200 opacity-60';
        return (
          <button
            key={opt + i}
            type="button"
            disabled={locked}
            onClick={() => onChange(opt)}
            aria-pressed={selected}
            className={`flex min-h-16 items-center gap-3 rounded-2xl px-4 py-3 text-left ring-[2.5px] transition ${style} ${shortOptions ? 'justify-center' : ''}`}
          >
            {!shortOptions && (
              <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl font-display text-lg font-bold ${selected || isCorrect ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'} ${isCorrect ? '!bg-emerald-600' : ''} ${isWrongPick ? '!bg-rose-500' : ''}`}>
                {LETTERS[i]}
              </span>
            )}
            <span className={`font-display font-bold text-slate-800 ${shortOptions ? 'text-4xl' : 'flex-1 text-xl sm:text-2xl'}`}>{opt}</span>
            {isCorrect && <Check className="h-7 w-7 shrink-0 text-emerald-600" strokeWidth={3} />}
            {isWrongPick && <X className="h-7 w-7 shrink-0 text-rose-500" strokeWidth={3} />}
          </button>
        );
      })}
    </div>
  );
}

export function NumberAnswer({ value, onChange, onSubmit, disabled }: {
  value: string; onChange: (v: string) => void; onSubmit: () => void; disabled: boolean;
}) {
  const valueRef = useRef(value);
  valueRef.current = value;

  // Hỗ trợ bàn phím thật trên máy tính; trên tablet dùng bàn phím số to bên dưới.
  useEffect(() => {
    if (disabled) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
      if (/^[0-9]$/.test(e.key)) {
        valueRef.current = (valueRef.current + e.key).slice(0, 5);
        onChange(valueRef.current);
      } else if (e.key === 'Backspace') {
        valueRef.current = valueRef.current.slice(0, -1);
        onChange(valueRef.current);
      }
      else if (e.key === 'Enter') onSubmit();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [disabled, onChange, onSubmit]);

  // Cập nhật ref ngay để hai lần chạm liên tiếp trước khi render lại không làm mất chữ số.
  const emit = (v: string) => {
    valueRef.current = v;
    onChange(v);
  };
  const press = (d: string) => !disabled && emit((valueRef.current + d).slice(0, 5));
  const keyClass = 'flex h-16 items-center justify-center rounded-2xl bg-white font-display text-3xl font-bold text-blue-800 ring-2 ring-slate-200 shadow-[0_4px_0_0_#cbd5e1] transition active:translate-y-1 active:shadow-none disabled:opacity-40';

  return (
    <div className="mx-auto flex w-full max-w-sm flex-col items-center gap-4">
      <div className={`flex h-20 w-full items-center justify-center rounded-2xl bg-blue-50 font-display text-5xl font-bold ring-[3px] ${disabled ? 'ring-slate-200 text-slate-500' : 'ring-blue-400 text-blue-800'}`} aria-live="polite">
        {value || <span className="text-3xl text-blue-300">Nhập số</span>}
      </div>
      <div className="grid w-full grid-cols-5 gap-2">
        {['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'].map((d) => (
          <button key={d} type="button" className={keyClass} disabled={disabled} onClick={() => press(d)} aria-label={`Số ${d}`}>{d}</button>
        ))}
      </div>
      <button type="button" disabled={disabled || !value} onClick={() => emit(valueRef.current.slice(0, -1))}
        className="flex items-center gap-2 rounded-xl bg-rose-50 px-5 py-2.5 font-bold text-rose-600 ring-2 ring-rose-200 disabled:opacity-40">
        <Delete className="h-5 w-5" /> Xóa bớt
      </button>
    </div>
  );
}

export function TextAnswer({ value, onChange, onSubmit, disabled }: {
  value: string; onChange: (v: string) => void; onSubmit: () => void; disabled: boolean;
}) {
  const ref = useRef<HTMLInputElement>(null);
  useEffect(() => {
    if (!disabled) ref.current?.focus({ preventScroll: true });
  }, [disabled]);
  return (
    <div className="mx-auto w-full max-w-md">
      <input
        ref={ref}
        type="text"
        value={value}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value.slice(0, 60))}
        onKeyDown={(e) => e.key === 'Enter' && onSubmit()}
        placeholder="Gõ câu trả lời…"
        autoComplete="off"
        autoCorrect="off"
        autoCapitalize="off"
        spellCheck={false}
        enterKeyHint="done"
        aria-label="Câu trả lời"
        className="h-20 w-full rounded-2xl bg-white px-5 text-center font-display text-3xl font-bold text-blue-800 ring-[3px] ring-blue-300 outline-none placeholder:text-xl placeholder:text-slate-300 focus:ring-blue-500 disabled:bg-slate-50 disabled:text-slate-500"
      />
    </div>
  );
}
