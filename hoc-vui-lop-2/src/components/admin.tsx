import type { ReactNode } from 'react';
import { DIFFICULTY_LABEL, TYPE_LABEL } from '../lib/text';

export function PageHeader({ title, description, actions }: { title: string; description?: ReactNode; actions?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <h1 className="font-display text-2xl font-bold text-slate-900">{title}</h1>
        {description && <p className="mt-1 text-sm text-slate-500">{description}</p>}
      </div>
      {actions && <div className="flex flex-wrap gap-2">{actions}</div>}
    </div>
  );
}

export function StatCard({ label, value, hint, icon, tone = 'blue' }: {
  label: string; value: ReactNode; hint?: ReactNode; icon?: ReactNode; tone?: 'blue' | 'green' | 'amber' | 'rose';
}) {
  const tones = {
    blue: 'bg-blue-50 text-blue-600',
    green: 'bg-emerald-50 text-emerald-600',
    amber: 'bg-amber-50 text-amber-600',
    rose: 'bg-rose-50 text-rose-600',
  };
  return (
    <div className="panel flex items-start gap-4 p-5">
      {icon && <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-xl ${tones[tone]}`}>{icon}</div>}
      <div className="min-w-0">
        <p className="text-sm font-medium text-slate-500">{label}</p>
        <p className="mt-1 text-2xl font-bold text-slate-900">{value}</p>
        {hint && <p className="mt-1 text-xs text-slate-500">{hint}</p>}
      </div>
    </div>
  );
}

export function Toggle({ checked, onChange, label, disabled }: { checked: boolean; onChange: (v: boolean) => void; label: string; disabled?: boolean }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      title={label}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 shrink-0 items-center rounded-full transition-colors disabled:opacity-50 ${checked ? 'bg-emerald-500' : 'bg-slate-300'}`}
    >
      <span className={`inline-block h-5 w-5 rounded-full bg-white shadow transition-transform ${checked ? 'translate-x-5' : 'translate-x-0.5'}`} />
    </button>
  );
}

const DIFF_CHIP: Record<number, string> = {
  1: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
  2: 'bg-amber-50 text-amber-700 ring-amber-200',
  3: 'bg-rose-50 text-rose-700 ring-rose-200',
};

export function DifficultyChip({ value }: { value: number }) {
  return <span className={`chip ring-1 ${DIFF_CHIP[value] ?? ''}`}>{DIFFICULTY_LABEL[value] ?? value}</span>;
}

export function TypeChip({ value }: { value: string }) {
  return <span className="chip bg-slate-100 text-slate-700">{TYPE_LABEL[value] ?? value}</span>;
}

export function EmptyState({ title, children }: { title: string; children?: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-2 px-6 py-12 text-center text-slate-500">
      <p className="font-semibold text-slate-700">{title}</p>
      {children}
    </div>
  );
}

export function Pager({ page, pageSize, total, onChange }: { page: number; pageSize: number; total: number; onChange: (p: number) => void }) {
  const pages = Math.max(1, Math.ceil(total / pageSize));
  if (total <= pageSize) return null;
  return (
    <div className="flex items-center justify-between gap-2 border-t border-slate-100 px-4 py-3 text-sm text-slate-600">
      <span>
        {page * pageSize + 1}–{Math.min(total, (page + 1) * pageSize)} / {total}
      </span>
      <div className="flex gap-2">
        <button type="button" className="btn btn-secondary btn-sm" disabled={page === 0} onClick={() => onChange(page - 1)}>Trước</button>
        <span className="self-center">Trang {page + 1}/{pages}</span>
        <button type="button" className="btn btn-secondary btn-sm" disabled={page >= pages - 1} onClick={() => onChange(page + 1)}>Sau</button>
      </div>
    </div>
  );
}

export function pct(v: number | null | undefined): string {
  return v === null || v === undefined ? '—' : `${Math.round(v)}%`;
}

/** ISO -> giá trị cho <input type="datetime-local"> theo giờ máy. */
export function isoToLocalInput(iso: string | null | undefined): string {
  if (!iso) return '';
  const d = new Date(iso);
  const off = d.getTimezoneOffset();
  return new Date(d.getTime() - off * 60000).toISOString().slice(0, 16);
}

export function localInputToIso(v: string): string | null {
  return v ? new Date(v).toISOString() : null;
}
