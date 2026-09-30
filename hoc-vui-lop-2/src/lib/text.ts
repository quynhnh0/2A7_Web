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

/** Bài của ngân hàng riêng đặt tên "Archimes: …" => nhãn "Archimes" thay cho "Bài 100". */
export function lessonLabel(lesson: { lesson_order: number; name: string }): { tag: string; title: string } {
  const m = /^\s*(Archimes)\s*:\s*/i.exec(lesson.name);
  return m ? { tag: 'Archimes', title: lesson.name.slice(m[0].length) } : { tag: `Bài ${lesson.lesson_order}`, title: lesson.name };
}

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
