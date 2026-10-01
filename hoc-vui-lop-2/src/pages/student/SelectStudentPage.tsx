import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import { Search, Sparkles, UserPlus } from 'lucide-react';
import { studentApi } from '../../lib/api';
import { storeStudent } from '../../lib/studentSession';
import { foldVietnamese, isGuestName, titleCaseName } from '../../lib/text';
import { useAsync } from '../../hooks/useAsync';
import { Avatar, LoadingBlock, StudentError, studentMessage } from '../../components/ui';
import { Logo } from '../../components/StudentLayout';
import { BirthdayCheck } from '../../components/BirthdayCheck';
import type { StudentIdentity } from '../../types';

export default function SelectStudentPage() {
  const navigate = useNavigate();
  const { data, error, loading, reload } = useAsync(
    () => Promise.all([studentApi.getConfig(), studentApi.listStudents()]),
    [],
  );
  const [query, setQuery] = useState('');
  const [pending, setPending] = useState<StudentIdentity | null>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const config = data?.[0];
  const students = useMemo(
    () => (data?.[1] ?? []).slice().sort((a, b) => a.display_name.localeCompare(b.display_name, 'vi')),
    [data],
  );
  const folded = foldVietnamese(query);
  // Bạn khách không hiện sẵn trong danh sách lớp, chỉ hiện khi gõ từ 3 chữ trở lên khớp tên.
  const matches = folded
    ? students.filter((s) => foldVietnamese(s.full_name).includes(folded) && (folded.length >= 3 || !isGuestName(s.full_name)))
    : students.filter((s) => !isGuestName(s.full_name));
  const typedName = titleCaseName(query);
  const exact = students.some((s) => foldVietnamese(s.full_name) === folded);
  const canRegister = !!config?.allow_self_register && typedName.split(' ').length >= 2 && !exact;

  const confirm = (s: StudentIdentity) => {
    storeStudent(s);
    navigate('/home', { replace: true });
  };

  const register = async () => {
    setBusy(true);
    setActionError(null);
    try {
      const s = await studentApi.register(typedName);
      confirm(s);
    } catch (e) {
      setActionError(studentMessage(e));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="min-h-dvh bg-gradient-to-b from-blue-50 via-white to-amber-50 px-4 py-6 sm:py-10">
      <div className="mx-auto flex max-w-3xl flex-col gap-6">
        <div className="flex justify-center"><Logo subtitle={config ? `${config.class_name} • ${config.school_year}` : undefined} /></div>

        <div className="card p-6 text-center sm:p-8 animate-rise">
          <div className="text-6xl" aria-hidden>🦉</div>
          <h1 className="mt-2 font-display text-3xl font-bold text-blue-700 sm:text-4xl">Chào bạn! Bạn tên là gì?</h1>
          <p className="mt-2 text-lg text-slate-600">Gõ tên hoặc bấm vào tên của mình ở dưới nhé.</p>
          <div className="relative mx-auto mt-5 max-w-lg">
            <Search className="pointer-events-none absolute top-1/2 left-4 h-6 w-6 -translate-y-1/2 text-slate-400" />
            <input
              value={query}
              onChange={(e) => { setQuery(e.target.value); setPending(null); }}
              placeholder="Ví dụ: Nguyễn Minh Anh"
              aria-label="Họ và tên"
              autoComplete="off"
              className="h-16 w-full rounded-2xl bg-white pr-4 pl-13 font-display text-2xl font-bold text-slate-800 ring-[3px] ring-blue-200 outline-none placeholder:text-lg placeholder:font-medium placeholder:text-slate-300 focus:ring-blue-500"
            />
          </div>
        </div>

        {pending?.needs_birthday && (
          <BirthdayCheck key={pending.id} student={pending} onVerified={confirm} onCancel={() => setPending(null)} />
        )}

        {pending && !pending.needs_birthday && (
          <div className="card flex flex-col items-center gap-4 p-6 text-center ring-2 ring-blue-300 animate-pop">
            <Avatar name={pending.full_name} id={pending.id} size="h-20 w-20 text-2xl" />
            <p className="font-display text-2xl font-bold text-slate-800">Bạn là <span className="text-blue-700">{pending.full_name}</span> phải không?</p>
            <div className="flex w-full max-w-md flex-col gap-3 sm:flex-row">
              <button type="button" className="btn-kid btn-green flex-1" onClick={() => confirm(pending)}>Đúng rồi! 👍</button>
              <button type="button" className="btn-kid btn-soft flex-1" onClick={() => setPending(null)}>Không phải</button>
            </div>
          </div>
        )}

        {loading && <LoadingBlock label="Đang mở danh sách lớp…" />}
        {!!error && <StudentError error={error} onRetry={reload} />}

        {!loading && !error && !pending && (
          <div className="flex flex-col gap-4">
            {matches.length > 0 && (
              <div className="grid grid-cols-2 gap-2 sm:gap-3 md:grid-cols-3">
                {matches.map((s) => (
                  <button key={s.id} type="button" onClick={() => setPending(s)}
                    className="flex min-h-16 items-center gap-2 rounded-2xl bg-white px-3 py-3 text-left ring-2 ring-slate-200 transition hover:ring-blue-400 active:scale-[0.98] sm:gap-3 sm:px-4">
                    <Avatar name={s.full_name} id={s.id} size="h-9 w-9 text-xs sm:h-10 sm:w-10 sm:text-sm" />
                    <span className="min-w-0">
                      <span className="block truncate font-bold text-slate-800">{s.display_name}</span>
                      <span className="block truncate text-sm text-slate-500">{s.full_name}</span>
                    </span>
                  </button>
                ))}
              </div>
            )}

            {matches.length === 0 && folded && (
              <p className="text-center text-lg text-slate-500">Chưa thấy tên “{query.trim()}” trong lớp.</p>
            )}

            {canRegister && (
              <button type="button" className="btn-kid btn-amber mx-auto w-full max-w-lg" onClick={register} disabled={busy}>
                <UserPlus className="h-6 w-6" /> Mình là bạn mới: {typedName}
              </button>
            )}
            {!config?.allow_self_register && folded && matches.length === 0 && (
              <p className="text-center text-slate-500"><Sparkles className="inline h-4 w-4" /> Nhờ cô giáo hoặc bố mẹ thêm tên bạn vào lớp nhé!</p>
            )}
            {config?.allow_self_register && folded && !canRegister && matches.length === 0 && (
              <p className="text-center text-slate-500">Bạn gõ đầy đủ cả họ và tên nhé (ví dụ: Trần Gia Huy).</p>
            )}
            {actionError && <p className="text-center font-semibold text-rose-600">{actionError}</p>}
          </div>
        )}
      </div>
    </div>
  );
}
