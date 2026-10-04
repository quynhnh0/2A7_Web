import type { MedalKind, RetakeMode } from '../types';

/** Bỏ dấu tiếng Việt, chữ thường — dùng để tìm tên không phân biệt dấu. */
export function foldVietnamese(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

/** "nguyễn  minh anh" -> "Nguyễn Minh Anh" */
export function titleCaseName(s: string): string {
  return s
    .normalize('NFC')
    .trim()
    .replace(/\s+/g, ' ')
    .split(' ')
    .map((w) => (w ? w.charAt(0).toLocaleUpperCase('vi') + w.slice(1).toLocaleLowerCase('vi') : w))
    .join(' ');
}

/** Bạn khách (không thuộc lớp) đặt tên có dấu gạch, VD "Tiểu Nguyên - Khoai". Khớp với public.is_guest_name. */
export function isGuestName(name: string | null | undefined): boolean {
  return /[-–—]/.test(name ?? '');
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  if (parts.length === 1) return parts[0].slice(0, 2).toLocaleUpperCase('vi');
  return (parts[parts.length - 2][0] + parts[parts.length - 1][0]).toLocaleUpperCase('vi');
}

export function formatNumber(n: number | null | undefined): string {
  return (n ?? 0).toLocaleString('vi-VN');
}

export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleString('vi-VN', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit' });
}

export function formatDuration(sec: number | null | undefined): string {
  if (!sec && sec !== 0) return '—';
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return m > 0 ? `${m} phút ${s} giây` : `${s} giây`;
}

export function relativeTime(iso: string | null | undefined): string {
  if (!iso) return 'Chưa làm bài';
  const diff = (Date.now() - new Date(iso).getTime()) / 1000;
  if (diff < 60) return 'Vừa xong';
  if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`;
  if (diff < 86400 * 30) return `${Math.floor(diff / 86400)} ngày trước`;
  return new Date(iso).toLocaleDateString('vi-VN');
}

function isoDate(y: number, m: number, d: number): string | null {
  const t = new Date(Date.UTC(y, m - 1, d));
  if (t.getUTCFullYear() !== y || t.getUTCMonth() !== m - 1 || t.getUTCDate() !== d) return null;
  if (y < 1990 || y > new Date().getFullYear() + 1) return null;
  return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

/**
 * Đọc ngày sinh kiểu Việt Nam -> 'YYYY-MM-DD' (null nếu không hợp lệ).
 * Nhận: 05/03/2019, 5-3-2019, 5.3.19, 2019-03-05, số ngày kiểu Excel (43529).
 */
export function parseBirthDate(input: string | null | undefined): string | null {
  const s = (input ?? '').trim();
  if (!s) return null;
  let m = /^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})/.exec(s);
  if (m) return isoDate(+m[1], +m[2], +m[3]);
  m = /^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2}|\d{4})$/.exec(s);
  if (m) return isoDate(m[3].length === 2 ? 2000 + +m[3] : +m[3], +m[2], +m[1]);
  if (/^\d{5}$/.test(s)) {
    const t = new Date(Date.UTC(1899, 11, 30) + Number(s) * 86400000);
    return isoDate(t.getUTCFullYear(), t.getUTCMonth() + 1, t.getUTCDate());
  }
  return null;
}

/** '2019-03-05' -> '05/03/2019' */
export function formatBirthDate(iso: string | null | undefined): string {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso ?? '');
  return m ? `${m[3]}/${m[2]}/${m[1]}` : '';
}

/** Bài của ngân hàng riêng đặt tên "Archimes: …" => nhãn "Archimes" thay cho "Bài 100". */
export function lessonLabel(lesson: { lesson_order: number; name: string }): { tag: string; title: string } {
  const m = /^\s*(Archimes)\s*:\s*/i.exec(lesson.name);
  return m ? { tag: 'Archimes', title: lesson.name.slice(m[0].length) } : { tag: `Bài ${lesson.lesson_order}`, title: lesson.name };
}

const CLASS_TZ = 'Asia/Ho_Chi_Minh';
const dayKey = (d: Date) => d.toLocaleDateString('en-CA', { timeZone: CLASS_TZ });

/** Giờ mở/đóng theo giờ Việt Nam: "17:00 hôm nay", "0:00 ngày mai", "17:00 thứ Hai". */
export function formatOpenTime(iso: string | null | undefined): string {
  if (!iso) return '';
  const d = new Date(iso);
  const time = d.toLocaleTimeString('vi-VN', { hour: 'numeric', minute: '2-digit', timeZone: CLASS_TZ });
  const today = new Date();
  const tomorrow = new Date(today.getTime() + 86400e3);
  if (dayKey(d) === dayKey(today)) return `${time} hôm nay`;
  if (dayKey(d) === dayKey(tomorrow)) return `${time} ngày mai`;
  return `${time} ${d.toLocaleDateString('vi-VN', { weekday: 'long', timeZone: CLASS_TZ })}`;
}

export const WEEKDAY_LABEL: Record<string, string> = {
  '1': 'Thứ Hai', '2': 'Thứ Ba', '3': 'Thứ Tư', '4': 'Thứ Năm', '5': 'Thứ Sáu', '6': 'Thứ Bảy', '7': 'Chủ nhật',
};

export const RETAKE_LABEL: Record<RetakeMode, string> = {
  per_correct: 'Mỗi câu đúng được 1 sao',
  pair: 'Cứ 2 câu đúng được 1 sao, 2 câu sai bị trừ 1 sao',
};

export const MEDAL_INFO: Record<MedalKind, { label: string; emoji: string; className: string }> = {
  gold: { label: 'Huy chương Vàng', emoji: '🥇', className: 'bg-amber-100 text-amber-800' },
  silver: { label: 'Huy chương Bạc', emoji: '🥈', className: 'bg-slate-200 text-slate-700' },
  bronze: { label: 'Huy chương Đồng', emoji: '🥉', className: 'bg-orange-100 text-orange-800' },
  encourage: { label: 'Khuyến khích', emoji: '🎗️', className: 'bg-sky-100 text-sky-800' },
};

export const DIFFICULTY_LABEL: Record<number, string> = { 1: 'Dễ', 2: 'Vừa', 3: 'Nâng cao' };
export const TYPE_LABEL: Record<string, string> = { multiple_choice: 'Trắc nghiệm', number: 'Điền số', text: 'Điền chữ' };

/** Trộn thứ tự đáp án ổn định theo id câu hỏi (tải lại trang vẫn giữ nguyên thứ tự). */
export function stableShuffle<T>(items: T[], seedText: string): T[] {
  let h = 2166136261;
  for (let i = 0; i < seedText.length; i++) {
    h ^= seedText.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  const out = items.slice();
  for (let i = out.length - 1; i > 0; i--) {
    h = Math.imul(h ^ (h >>> 13), 0x5bd1e995) >>> 0;
    const j = h % (i + 1);
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}
