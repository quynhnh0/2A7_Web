import { Crown, Star } from 'lucide-react';
import type { LeaderboardRow, Period } from '../types';
import { formatNumber } from '../lib/text';
import { Avatar } from './ui';

export const PERIOD_LABEL: Record<Period, string> = { day: 'Hôm nay', week: 'Tuần này', month: 'Tháng này' };

export function PeriodTabs({ value, onChange }: { value: Period; onChange: (p: Period) => void }) {
  return (
    <div className="inline-flex rounded-2xl bg-slate-100 p-1" role="tablist" aria-label="Chọn thời gian xếp hạng">
      {(['day', 'week', 'month'] as Period[]).map((p) => (
        <button
          key={p}
          type="button"
          role="tab"
          aria-selected={value === p}
          onClick={() => onChange(p)}
          className={`min-h-11 rounded-xl px-4 text-sm font-bold transition sm:px-5 ${value === p ? 'bg-white text-blue-700 shadow' : 'text-slate-500 hover:text-slate-700'}`}
        >
          {PERIOD_LABEL[p]}
        </button>
      ))}
    </div>
  );
}

const PODIUM = [
  { place: 2, height: 'h-24', block: 'bg-gradient-to-b from-slate-200 to-slate-300 text-slate-600', medal: '🥈' },
  { place: 1, height: 'h-32', block: 'bg-gradient-to-b from-amber-300 to-amber-500 text-amber-900', medal: '🥇' },
  { place: 3, height: 'h-20', block: 'bg-gradient-to-b from-orange-200 to-orange-300 text-orange-800', medal: '🥉' },
];

export function Podium({ rows, meId }: { rows: LeaderboardRow[]; meId?: string | null }) {
  const top = rows.slice(0, 3);
  if (top.length === 0) return null;
  return (
    <div className="grid grid-cols-3 items-end gap-2 sm:gap-4">
      {PODIUM.map(({ place, height, block, medal }) => {
        const r = top[place - 1];
        if (!r) return <div key={place} />;
        return (
          <div key={place} className="flex flex-col items-center gap-2 animate-rise">
            {place === 1 && <Crown className="h-7 w-7 text-amber-500" fill="currentColor" />}
            <div className={`relative rounded-full p-1 ${place === 1 ? 'bg-amber-400' : 'bg-white'} ${r.student_id === meId ? 'ring-4 ring-blue-400' : ''}`}>
              <Avatar name={r.full_name} id={r.student_id} size={place === 1 ? 'h-16 w-16 text-lg' : 'h-12 w-12 text-sm'} />
              <span className="absolute -right-1 -bottom-1 text-xl">{medal}</span>
            </div>
            <div className="text-center">
              <div className="line-clamp-1 text-sm font-bold text-slate-800 sm:text-base">{r.display_name}</div>
              <div className="flex items-center justify-center gap-1 text-sm font-bold text-amber-600">
                <Star className="h-4 w-4" fill="currentColor" /> {formatNumber(r.score)}
              </div>
            </div>
            <div className={`flex w-full flex-col items-center justify-start rounded-t-2xl pt-2 ${height} ${block}`}>
              <span className="font-display text-3xl font-bold">{r.rank}</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function RankList({ rows, meId, start = 3 }: { rows: LeaderboardRow[]; meId?: string | null; start?: number }) {
  const rest = rows.slice(start);
  if (rest.length === 0) return null;
  return (
    <ol className="divide-y divide-slate-100">
      {rest.map((r) => (
        <li key={r.student_id} className={`flex items-center gap-3 px-3 py-3 sm:px-4 ${r.student_id === meId ? 'rounded-2xl bg-blue-50 ring-2 ring-blue-300' : ''}`}>
          <span className="w-8 text-center font-display text-lg font-bold text-slate-400">{r.rank}</span>
          <Avatar name={r.full_name} id={r.student_id} />
          <div className="min-w-0 flex-1">
            <div className="truncate font-bold text-slate-800">{r.full_name}{r.student_id === meId && ' (Bạn)'}</div>
            <div className="text-xs text-slate-500">{r.lessons_done} bài • đúng {r.accuracy}%</div>
          </div>
          <span className="flex items-center gap-1 rounded-full bg-amber-50 px-3 py-1 text-sm font-bold text-amber-700 ring-1 ring-amber-200">
            <Star className="h-4 w-4" fill="currentColor" /> {formatNumber(r.score)}
          </span>
        </li>
      ))}
    </ol>
  );
}
