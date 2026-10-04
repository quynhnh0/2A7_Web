import { useEffect, type ReactNode } from 'react';
import { AlertCircle, Loader2, RotateCw, X } from 'lucide-react';
import type { BackendError } from '../lib/backend';
import type { SubjectColor } from '../types';

export function Spinner({ className = 'h-6 w-6' }: { className?: string }) {
  return <Loader2 className={`animate-spin text-blue-600 ${className}`} aria-hidden />;
}

export function LoadingBlock({ label = 'Đang tải…' }: { label?: string }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-16 text-slate-500" role="status">
      <Spinner className="h-10 w-10" />
      <p className="font-display text-lg font-semibold">{label}</p>
    </div>
  );
}

const STUDENT_MESSAGES: Record<string, string> = {
  student_not_found: 'Không tìm thấy tên bạn. Hãy chọn lại tên nhé!',
  student_disabled: 'Tên này đang tạm khóa. Hãy nhờ cô giáo hoặc bố mẹ giúp nhé!',
  self_register_disabled: 'Chưa có tên bạn trong lớp. Hãy nhờ cô giáo hoặc bố mẹ thêm tên nhé!',
  invalid_name: 'Tên chưa đúng. Bạn gõ lại họ và tên nhé!',
  student_exists: 'Tên này đã có trong lớp rồi. Bạn bấm vào tên của mình ở danh sách nhé!',
  lesson_not_available: 'Bài này chưa mở. Bạn chọn bài khác nhé!',
  no_questions: 'Bài này chưa có câu hỏi. Bạn chọn bài khác nhé!',
  attempt_not_found: 'Không tìm thấy bài làm này.',
  closed_hours: 'Bây giờ chưa phải giờ làm bài. Bạn nghỉ ngơi, quay lại vào giờ học nhé! 🌙',
  daily_limit_reached: 'Hôm nay bạn đã làm đủ số đề của môn này rồi. Giỏi lắm! Mai làm tiếp nhé! 🌟',
};

export function studentMessage(err: unknown): string {
  const code = (err as BackendError | undefined)?.code;
  return (code && STUDENT_MESSAGES[code]) || 'Có lỗi xảy ra. Hãy thử lại nhé!';
}

export function adminMessage(err: unknown): string {
  const e = err as BackendError | undefined;
  if (!e) return 'Lỗi không xác định';
  if (e.code === 'duplicate') return 'Dữ liệu bị trùng (đã tồn tại). ' + e.message;
  if (e.code === 'not_admin') return 'Tài khoản này chưa có quyền quản trị.';
  if (e.code === 'invalid_credentials' || /invalid login credentials/i.test(e.message)) return 'Sai email hoặc mật khẩu.';
  if (/email not confirmed/i.test(e.message)) return 'Email chưa được xác nhận. Vào Supabase → Authentication → Users để xác nhận.';
  if (/failed to fetch|network/i.test(e.message)) return 'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.';
  if (/foreign key/i.test(e.message)) return 'Không xoá được vì còn dữ liệu liên quan (bài học/câu hỏi/kết quả).';
  return e.message || String(err);
}

export function StudentError({ error, onRetry }: { error: unknown; onRetry?: () => void }) {
  return (
    <div className="card mx-auto flex max-w-md flex-col items-center gap-4 p-8 text-center animate-rise">
      <div className="text-6xl" aria-hidden>🙈</div>
      <p className="font-display text-xl font-bold text-slate-700">{studentMessage(error)}</p>
      {onRetry && (
        <button type="button" className="btn-kid btn-blue" onClick={onRetry}>
          <RotateCw className="h-5 w-5" /> Thử lại
        </button>
      )}
    </div>
  );
}

export function AdminError({ error, onRetry }: { error: unknown; onRetry?: () => void }) {
  return (
    <div className="flex items-start gap-3 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-800">
      <AlertCircle className="mt-0.5 h-5 w-5 shrink-0" />
      <div className="flex-1">
        <p className="font-semibold">Có lỗi xảy ra</p>
        <p className="mt-1 break-words">{adminMessage(error)}</p>
      </div>
      {onRetry && <button type="button" className="btn btn-secondary btn-sm" onClick={onRetry}>Thử lại</button>}
    </div>
  );
}

export function Modal({ open, title, onClose, children, footer, wide = false }: {
  open: boolean; title: string; onClose: () => void; children: ReactNode; footer?: ReactNode; wide?: boolean;
}) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/40 p-0 backdrop-blur-sm sm:items-center sm:p-4" onMouseDown={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className={`flex max-h-[92vh] w-full flex-col rounded-t-2xl bg-white shadow-2xl sm:rounded-2xl ${wide ? 'sm:max-w-4xl' : 'sm:max-w-lg'} animate-rise`}
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-3">
          <h2 className="text-base font-bold text-slate-800">{title}</h2>
          <button type="button" className="btn btn-ghost btn-icon" onClick={onClose} aria-label="Đóng"><X className="h-4 w-4" /></button>
        </div>
        <div className="overflow-y-auto px-5 py-4">{children}</div>
        {footer && <div className="flex justify-end gap-2 border-t border-slate-100 px-5 py-3">{footer}</div>}
      </div>
    </div>
  );
}

export const SUBJECT_STYLES: Record<SubjectColor, { card: string; text: string; chip: string; bar: string; emoji: string }> = {
  blue: { card: 'bg-sky-50 ring-blue-200', text: 'text-blue-700', chip: 'bg-blue-100 text-blue-800', bar: 'bg-blue-500', emoji: '🔢' },
  green: { card: 'bg-emerald-50 ring-emerald-200', text: 'text-emerald-700', chip: 'bg-emerald-100 text-emerald-800', bar: 'bg-emerald-500', emoji: '📖' },
  amber: { card: 'bg-amber-50 ring-amber-200', text: 'text-amber-700', chip: 'bg-amber-100 text-amber-800', bar: 'bg-amber-500', emoji: '🎨' },
  rose: { card: 'bg-rose-50 ring-rose-200', text: 'text-rose-700', chip: 'bg-rose-100 text-rose-800', bar: 'bg-rose-500', emoji: '🎵' },
  purple: { card: 'bg-violet-50 ring-violet-200', text: 'text-violet-700', chip: 'bg-violet-100 text-violet-800', bar: 'bg-violet-500', emoji: '🌏' },
};

export function subjectStyle(color: string | null | undefined) {
  return SUBJECT_STYLES[(color as SubjectColor) ?? 'blue'] ?? SUBJECT_STYLES.blue;
}

const SUBJECT_EMOJI: Record<string, string> = {
  toan: '🔢',
  tieng_viet: '📖',
  ky_nang_song: '🌱',
  khoa_hoc: '🔬',
};

/** Biểu tượng theo mã môn; môn tự thêm thì dùng biểu tượng theo màu. */
export function subjectEmoji(code: string | null | undefined, color: string | null | undefined) {
  return (code && SUBJECT_EMOJI[code]) || subjectStyle(color).emoji;
}

const AVATAR_COLORS = ['bg-blue-600', 'bg-amber-500', 'bg-emerald-600', 'bg-rose-500', 'bg-violet-600', 'bg-sky-500', 'bg-orange-500', 'bg-teal-600'];

export function Avatar({ name, id, size = 'h-10 w-10 text-sm' }: { name: string; id: string; size?: string }) {
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  const parts = name.trim().split(/\s+/);
  const text = parts.length >= 2 ? parts[parts.length - 2][0] + parts[parts.length - 1][0] : name.slice(0, 2);
  return (
    <span className={`inline-flex shrink-0 items-center justify-center rounded-full font-bold text-white ${AVATAR_COLORS[h % AVATAR_COLORS.length]} ${size}`} aria-hidden>
      {text.toLocaleUpperCase('vi')}
    </span>
  );
}
