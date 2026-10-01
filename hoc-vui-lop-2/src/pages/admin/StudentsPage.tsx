import { useMemo, useRef, useState, type FormEvent } from 'react';
import { Download, History, Pencil, Search, Trash2, Upload, UserPlus } from 'lucide-react';
import { EmptyState, PageHeader, pct, Toggle } from '../../components/admin';
import { AdminError, Avatar, LoadingBlock, Modal, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { downloadText, readSpreadsheet, toCsv } from '../../lib/csv';
import { foldVietnamese, formatBirthDate, formatDateTime, parseBirthDate, relativeTime, titleCaseName } from '../../lib/text';
import type { StudentStats } from '../../types';

const NAME_COLUMNS = ['ho ten', 'ho va ten', 'full name', 'name', 'ten', 'hoc sinh'];
const BIRTH_COLUMNS = ['ngay sinh', 'ngaysinh', 'sinh nhat', 'ngay thang nam sinh', 'birthday', 'birth date', 'dob'];
const columnKey = (c: string) => foldVietnamese(c).replace(/_/g, ' ');

type Entry = { name: string; birth: string | null };

/** "Nguyễn Minh Anh	05/03/2019" hoặc "Nguyễn Minh Anh, 5/3/2019" -> tên + ngày sinh (nếu có). */
function parseEntryLine(line: string): Entry {
  const text = line.replace(/^\s*\d+[.)\-\s]+(?=\D)/, '').trim();
  const m = /^(.*?)[\t,;|]+\s*([\d./-]+)\s*$/.exec(text) ?? /^(.*\D)\s+(\d{1,4}[./-]\d{1,2}[./-]\d{2,4})\s*$/.exec(text);
  if (m) {
    const birth = parseBirthDate(m[2]);
    if (birth) return { name: m[1].trim(), birth };
  }
  return { name: text, birth: null };
}

export default function StudentsPage() {
  const { data, error, loading, reload } = useAsync(() => adminApi.listStudents(), []);
  const [search, setSearch] = useState('');
  const [showInactive, setShowInactive] = useState(true);
  const [addOpen, setAddOpen] = useState(false);
  const [editing, setEditing] = useState<StudentStats | null>(null);
  const [history, setHistory] = useState<StudentStats | null>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<unknown>(null);
  const [notice, setNotice] = useState('');
  const fileRef = useRef<HTMLInputElement>(null);

  const students = useMemo(() => data ?? [], [data]);
  const filtered = useMemo(() => {
    const f = foldVietnamese(search);
    return students.filter((s) => (showInactive || s.is_active) && (!f || foldVietnamese(s.full_name).includes(f)));
  }, [students, search, showInactive]);

  const run = async (fn: () => Promise<unknown>) => {
    setBusy(true);
    setActionError(null);
    setNotice('');
    try {
      await fn();
      reload();
    } catch (e) {
      setActionError(e);
    } finally {
      setBusy(false);
    }
  };

  /**
   * Thêm học sinh mới, bỏ qua tên đã có (so khớp không phân biệt hoa thường / dấu / khoảng trắng).
   * Tên đã có mà kèm ngày sinh khác thì cập nhật ngày sinh.
   */
  const addEntries = async (entries: Entry[]) => {
    const byKey = new Map(students.map((s) => [foldVietnamese(s.full_name), s]));
    const fresh: Array<{ full_name: string; birth_date: string | null }> = [];
    const updates: Array<{ id: string; birth_date: string }> = [];
    for (const e of entries) {
      const name = titleCaseName(e.name);
      if (name.length < 2 || name.length > 80) continue;
      const k = foldVietnamese(name);
      const old = byKey.get(k);
      if (old) {
        if (e.birth && old.birth_date !== e.birth && !updates.some((u) => u.id === old.id)) updates.push({ id: old.id, birth_date: e.birth });
        continue;
      }
      if (fresh.some((f) => foldVietnamese(f.full_name) === k)) continue;
      fresh.push({ full_name: name, birth_date: e.birth });
    }
    if (fresh.length > 0) {
      try {
        await adminApi.insertStudents(fresh);
      } catch {
        // Có thể trùng tên mà máy chủ coi là một: thêm từng tên để không mất cả lô.
        for (const row of fresh) {
          try {
            await adminApi.insertStudents([row]);
          } catch (err) {
            console.warn('[StudentsPage] Bỏ qua tên không thêm được:', row.full_name, err);
          }
        }
      }
    }
    for (const u of updates) {
      await adminApi.updateStudent(u.id, { birth_date: u.birth_date, verify_fails: 0, verify_locked_until: null });
    }
    const parts = [
      fresh.length && `thêm ${fresh.length} học sinh`,
      updates.length && `cập nhật ngày sinh cho ${updates.length} bạn`,
    ].filter(Boolean);
    setNotice(parts.length ? `Đã ${parts.join(', ')}.` : 'Không có gì mới (các tên và ngày sinh đều đã có).');
  };

  const onImportFile = (file: File) => run(async () => {
    const rows = await readSpreadsheet(file);
    if (rows.length === 0) throw new Error('File không có dữ liệu.');
    const cols = Object.keys(rows[0]);
    const nameCol = cols.find((c) => NAME_COLUMNS.includes(columnKey(c))) ?? cols[0];
    const birthCol = cols.find((c) => BIRTH_COLUMNS.includes(columnKey(c)));
    const entries = rows
      .map((r) => ({ name: (r[nameCol] ?? '').trim(), birth: birthCol ? parseBirthDate(r[birthCol]) : null }))
      .filter((e) => e.name);
    const badBirth = birthCol ? rows.filter((r) => (r[birthCol] ?? '').trim() && !parseBirthDate(r[birthCol])).length : 0;
    await addEntries(entries);
    if (badBirth) setNotice((n) => `${n} Có ${badBirth} ngày sinh không đọc được (cần dạng ngày/tháng/năm, ví dụ 05/03/2019).`);
    if (fileRef.current) fileRef.current.value = '';
  });

  const exportCsv = () => downloadText(
    `hoc_sinh_${new Date().toISOString().slice(0, 10)}.csv`,
    toCsv(students.map((s) => ({ ...s, trang_thai: s.is_active ? 'Đang học' : 'Tạm khoá', ngay_sinh: formatBirthDate(s.birth_date) })), [
      ['full_name', 'ho_ten'], ['ngay_sinh', 'ngay_sinh'], ['display_name', 'ten_hien_thi'], ['trang_thai', 'trang_thai'], ['attempts_completed', 'so_bai_da_lam'],
      ['total_score', 'tong_diem'], ['accuracy', 'ti_le_dung'], ['last_active_at', 'lan_cuoi'], ['note', 'ghi_chu'],
    ]),
  );

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;

  const activeCount = students.filter((s) => s.is_active).length;
  const noBirthCount = students.filter((s) => s.is_active && !s.birth_date).length;

  return (
    <div className="space-y-5">
      <PageHeader
        title="Học sinh"
        description={`${activeCount} bạn đang học${students.length > activeCount ? ` · ${students.length - activeCount} tạm khoá` : ''}. Học sinh bấm chọn tên mình, rồi nhập ngày + tháng sinh để xác nhận (bạn chưa có ngày sinh thì vào thẳng).`}
        actions={
          <>
            <button type="button" className="btn btn-secondary" onClick={exportCsv}><Download className="h-4 w-4" /> Xuất CSV</button>
            <label className="btn btn-secondary cursor-pointer">
              <Upload className="h-4 w-4" /> Nhập danh sách
              <input ref={fileRef} type="file" accept=".csv,.xlsx,.xls" className="sr-only" onChange={(e) => e.target.files?.[0] && onImportFile(e.target.files[0])} />
            </label>
            <button type="button" className="btn btn-primary" onClick={() => setAddOpen(true)}><UserPlus className="h-4 w-4" /> Thêm học sinh</button>
          </>
        }
      />

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input className="input pl-9" placeholder="Tìm tên học sinh…" value={search} onChange={(e) => setSearch(e.target.value)} aria-label="Tìm học sinh" />
        </div>
        <label className="flex items-center gap-2 text-sm text-slate-600">
          <input type="checkbox" checked={showInactive} onChange={(e) => setShowInactive(e.target.checked)} /> Hiện cả bạn tạm khoá
        </label>
      </div>

      {notice && <p className="rounded-lg bg-emerald-50 p-3 text-sm text-emerald-800">{notice}</p>}
      {noBirthCount > 0 && (
        <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-800">
          🎂 {noBirthCount} bạn chưa có ngày sinh nên vào học không cần xác nhận. Thêm ngày sinh bằng nút ✏️ Sửa, hoặc “Nhập danh sách” từ file Excel có cột <b>ngay_sinh</b> (dạng 05/03/2019).
        </p>
      )}
      {actionError !== null && <AdminError error={actionError} />}

      <div className="panel overflow-hidden">
        {filtered.length === 0 ? (
          <EmptyState title={students.length === 0 ? 'Chưa có học sinh nào' : 'Không tìm thấy'}>
            {students.length === 0 && 'Bấm “Thêm học sinh” và dán danh sách tên, mỗi dòng một bạn.'}
          </EmptyState>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr>
                  <th className="th">Học sinh</th>
                  <th className="th">Bài đã làm</th>
                  <th className="th">Tổng điểm</th>
                  <th className="th">Tỉ lệ đúng</th>
                  <th className="th">Hoạt động</th>
                  <th className="th">Đang học</th>
                  <th className="th w-32" />
                </tr>
              </thead>
              <tbody>
                {filtered.map((s) => (
                  <tr key={s.id} className={`border-t border-slate-100 ${s.is_active ? '' : 'bg-slate-50 text-slate-400'}`}>
                    <td className="td">
                      <div className="flex items-center gap-3">
                        <Avatar name={s.full_name} id={s.id} size="h-9 w-9 text-xs" />
                        <div>
                          <p className="font-medium text-slate-800">{s.full_name}</p>
                          <p className="text-xs text-slate-500">
                            Hiển thị: {s.display_name}
                            {' · '}{s.birth_date ? <>🎂 {formatBirthDate(s.birth_date)}</> : <span className="text-amber-600">chưa có ngày sinh</span>}
                            {s.verify_locked_until && new Date(s.verify_locked_until) > new Date() && <span className="text-rose-600"> · đang khoá do nhập sai ngày sinh</span>}
                            {s.note && ` · ${s.note}`}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="td">{s.attempts_completed}</td>
                    <td className="td font-semibold text-blue-700">{s.total_score}</td>
                    <td className="td">{pct(s.accuracy)}</td>
                    <td className="td text-slate-500" title={formatDateTime(s.last_active_at)}>{relativeTime(s.last_active_at)}</td>
                    <td className="td"><Toggle checked={s.is_active} disabled={busy} onChange={(v) => run(() => adminApi.updateStudent(s.id, { is_active: v }))} label={s.is_active ? 'Đang học — bấm để tạm khoá' : 'Tạm khoá — bấm để mở'} /></td>
                    <td className="td whitespace-nowrap">
                      <button type="button" className="btn btn-ghost btn-icon" aria-label="Lịch sử làm bài" title="Lịch sử làm bài" onClick={() => setHistory(s)}><History className="h-4 w-4" /></button>
                      <button type="button" className="btn btn-ghost btn-icon" aria-label="Sửa" onClick={() => setEditing(s)}><Pencil className="h-4 w-4" /></button>
                      <button
                        type="button"
                        className="btn btn-ghost btn-icon text-rose-600"
                        aria-label="Xoá"
                        onClick={() => confirm(`Xoá "${s.full_name}" và toàn bộ kết quả làm bài?\nNếu bạn ấy chỉ nghỉ tạm, hãy tắt “Đang học”.`) && run(() => adminApi.deleteStudent(s.id))}
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <AddStudentsModal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        onSubmit={async (entries) => {
          await run(() => addEntries(entries));
          setAddOpen(false);
        }}
      />
      {editing && <EditStudentModal student={editing} onClose={() => setEditing(null)} onSaved={() => { setEditing(null); reload(); }} />}
      {history && <HistoryModal student={history} onClose={() => setHistory(null)} />}
    </div>
  );
}

function AddStudentsModal({ open, onClose, onSubmit }: { open: boolean; onClose: () => void; onSubmit: (entries: Entry[]) => Promise<void> }) {
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const names = text.split(/\r?\n/).map(parseEntryLine).filter((e) => e.name);
  const withBirth = names.filter((e) => e.birth).length;

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    await onSubmit(names);
    setBusy(false);
    setText('');
  };

  return (
    <Modal
      open={open}
      title="Thêm học sinh"
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose}>Huỷ</button>
          <button type="submit" form="add-students" className="btn btn-primary" disabled={busy || names.length === 0}>{busy && <Spinner className="h-4 w-4 text-white" />} Thêm {names.length} bạn</button>
        </>
      }
    >
      <form id="add-students" onSubmit={submit} className="space-y-2">
        <label className="label" htmlFor="names">Họ và tên (kèm ngày sinh nếu có) — mỗi dòng một bạn</label>
        <textarea id="names" className="input min-h-56 font-mono text-sm" value={text} onChange={(e) => setText(e.target.value)} placeholder={'Nguyễn Minh Anh, 05/03/2019\nTrần Gia Bảo, 21/11/2019\nLê Khánh Chi'} />
        <p className="text-xs text-slate-500">
          Có thể dán thẳng 2 cột “Họ tên | Ngày sinh” từ Excel, hoặc gõ “Tên, ngày/tháng/năm”. Số thứ tự đầu dòng (1. 2. …) sẽ tự bỏ.
          Tên đã có thì bỏ qua (nếu kèm ngày sinh thì cập nhật ngày sinh). Tên hiển thị mặc định là 2 chữ cuối (vd: “Minh Anh”).
        </p>
        {names.length > 0 && <p className="text-xs font-medium text-slate-600">{names.length} bạn · {withBirth} bạn có ngày sinh</p>}
      </form>
    </Modal>
  );
}

function EditStudentModal({ student, onClose, onSaved }: { student: StudentStats; onClose: () => void; onSaved: () => void }) {
  const [f, setF] = useState({
    full_name: student.full_name, display_name: student.display_name, note: student.note ?? '', is_active: student.is_active,
    birth_date: student.birth_date ?? '',
  });
  const isLocked = !!student.verify_locked_until && new Date(student.verify_locked_until) > new Date();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await adminApi.updateStudent(student.id, {
        full_name: titleCaseName(f.full_name),
        display_name: f.display_name.trim() || student.display_name,
        note: f.note.trim() || null,
        is_active: f.is_active,
        birth_date: f.birth_date || null,
        verify_fails: 0,
        verify_locked_until: null,
      });
      onSaved();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      open
      title="Sửa thông tin học sinh"
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose}>Huỷ</button>
          <button type="submit" form="edit-student" className="btn btn-primary" disabled={busy}>{busy && <Spinner className="h-4 w-4 text-white" />} Lưu</button>
        </>
      }
    >
      <form id="edit-student" onSubmit={submit} className="space-y-4">
        <div>
          <label className="label" htmlFor="s-full">Họ và tên</label>
          <input id="s-full" className="input" required maxLength={80} value={f.full_name} onChange={(e) => setF({ ...f, full_name: e.target.value })} />
        </div>
        <div>
          <label className="label" htmlFor="s-display">Tên hiển thị (bảng xếp hạng)</label>
          <input id="s-display" className="input" maxLength={40} value={f.display_name} onChange={(e) => setF({ ...f, display_name: e.target.value })} />
        </div>
        <div>
          <label className="label" htmlFor="s-birth">Ngày sinh (để bé xác nhận khi chọn tên)</label>
          <div className="flex gap-2">
            <input id="s-birth" type="date" className="input" min="2000-01-01" max={new Date().toISOString().slice(0, 10)} value={f.birth_date} onChange={(e) => setF({ ...f, birth_date: e.target.value })} />
            {f.birth_date && <button type="button" className="btn btn-secondary" onClick={() => setF({ ...f, birth_date: '' })}>Bỏ trống</button>}
          </div>
          <p className="mt-1 text-xs text-slate-500">
            Bé chỉ cần nhập đúng ngày + tháng. Để trống thì bé vào thẳng, không cần xác nhận.
            {isLocked && <span className="text-rose-600"> Bé đang bị khoá vài phút do nhập sai nhiều lần — bấm Lưu để mở khoá ngay.</span>}
          </p>
        </div>
        <div>
          <label className="label" htmlFor="s-note">Ghi chú</label>
          <input id="s-note" className="input" maxLength={200} value={f.note} onChange={(e) => setF({ ...f, note: e.target.value })} />
        </div>
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={f.is_active} onChange={(e) => setF({ ...f, is_active: e.target.checked })} /> Đang học (bỏ chọn để tạm khoá)
        </label>
        {error !== null && <AdminError error={error} />}
      </form>
    </Modal>
  );
}

function HistoryModal({ student, onClose }: { student: StudentStats; onClose: () => void }) {
  const { data, error, loading } = useAsync(
    () => adminApi.listAttempts({ filters: [['student_id', 'eq', student.id]], order: [['started_at', false]], limit: 100 }),
    [student.id],
  );
  return (
    <Modal open wide title={`Lịch sử làm bài — ${student.full_name}`} onClose={onClose}>
      {loading ? <LoadingBlock /> : error ? <AdminError error={error} /> : !data || data.rows.length === 0 ? (
        <EmptyState title="Chưa làm bài nào" />
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr><th className="th">Lúc</th><th className="th">Bài</th><th className="th">Loại</th><th className="th">Đúng</th><th className="th">Điểm</th></tr></thead>
            <tbody>
              {data.rows.map((a) => (
                <tr key={a.id} className="border-t border-slate-100">
                  <td className="td whitespace-nowrap text-slate-500">{formatDateTime(a.started_at)}</td>
                  <td className="td">{a.subject_name} · T{a.week_number} · {a.lesson_name}</td>
                  <td className="td">{a.exercise_type === 'advanced' ? 'Nâng cao' : 'Cơ bản'}{!a.is_ranked && <span className="text-xs text-slate-400"> (luyện tập)</span>}</td>
                  <td className="td">{a.completed_at ? `${a.correct_count}/${a.total_questions}` : <span className="text-xs text-amber-600">Đang làm dở</span>}</td>
                  <td className="td font-semibold text-blue-700">{a.score}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Modal>
  );
}
