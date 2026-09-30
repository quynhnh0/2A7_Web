import { useMemo, useRef, useState, type FormEvent } from 'react';
import { Download, History, Pencil, Search, Trash2, Upload, UserPlus } from 'lucide-react';
import { EmptyState, PageHeader, pct, Toggle } from '../../components/admin';
import { AdminError, Avatar, LoadingBlock, Modal, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { downloadText, readSpreadsheet, toCsv } from '../../lib/csv';
import { foldVietnamese, formatDateTime, relativeTime, titleCaseName } from '../../lib/text';
import type { StudentStats } from '../../types';

const NAME_COLUMNS = ['ho_ten', 'ho va ten', 'họ và tên', 'họ tên', 'full_name', 'name', 'ten', 'tên', 'hoc sinh', 'học sinh'];

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

  /** Thêm danh sách tên, bỏ qua tên đã có (so khớp không phân biệt hoa thường / khoảng trắng). */
  const addNames = async (names: string[]) => {
    const existing = new Set(students.map((s) => foldVietnamese(s.full_name)));
    const fresh: string[] = [];
    for (const raw of names) {
      const name = titleCaseName(raw);
      if (name.length < 2 || name.length > 80) continue;
      const k = foldVietnamese(name);
      if (existing.has(k)) continue;
      existing.add(k);
      fresh.push(name);
    }
    if (fresh.length === 0) {
      setNotice('Không có tên mới (các tên đều đã có trong danh sách).');
      return 0;
    }
    try {
      await adminApi.insertStudents(fresh.map((full_name) => ({ full_name })));
    } catch {
      // Có thể trùng tên khác dấu hoa/thường mà máy chủ coi là một: thêm từng tên để không mất cả lô.
      for (const full_name of fresh) {
        try {
          await adminApi.insertStudents([{ full_name }]);
        } catch (e) {
          console.warn('[StudentsPage] Bỏ qua tên không thêm được:', full_name, e);
        }
      }
    }
    return fresh.length;
  };

  const onImportFile = (file: File) => run(async () => {
    const rows = await readSpreadsheet(file);
    if (rows.length === 0) throw new Error('File không có dữ liệu.');
    const cols = Object.keys(rows[0]);
    const col = cols.find((c) => NAME_COLUMNS.includes(foldVietnamese(c).replace(/_/g, ' ')) || NAME_COLUMNS.includes(c.trim().toLowerCase())) ?? cols[0];
    const names = rows.map((r) => (r[col] ?? '').trim()).filter(Boolean);
    const added = await addNames(names);
    if (added) setNotice(`Đã thêm ${added} học sinh từ file (cột “${col}”).`);
    if (fileRef.current) fileRef.current.value = '';
  });

  const exportCsv = () => downloadText(
    `hoc_sinh_${new Date().toISOString().slice(0, 10)}.csv`,
    toCsv(students.map((s) => ({ ...s, trang_thai: s.is_active ? 'Đang học' : 'Tạm khoá' })), [
      ['full_name', 'ho_ten'], ['display_name', 'ten_hien_thi'], ['trang_thai', 'trang_thai'], ['attempts_completed', 'so_bai_da_lam'],
      ['total_score', 'tong_diem'], ['accuracy', 'ti_le_dung'], ['last_active_at', 'lan_cuoi'], ['note', 'ghi_chu'],
    ]),
  );

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;

  const activeCount = students.filter((s) => s.is_active).length;

  return (
    <div className="space-y-5">
      <PageHeader
        title="Học sinh"
        description={`${activeCount} bạn đang học${students.length > activeCount ? ` · ${students.length - activeCount} tạm khoá` : ''}. Học sinh chỉ cần bấm chọn tên mình để vào học.`}
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
                          <p className="text-xs text-slate-500">Hiển thị: {s.display_name}{s.note && ` · ${s.note}`}</p>
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
        onSubmit={async (names) => {
          await run(async () => {
            const n = await addNames(names);
            if (n) setNotice(`Đã thêm ${n} học sinh.`);
          });
          setAddOpen(false);
        }}
      />
      {editing && <EditStudentModal student={editing} onClose={() => setEditing(null)} onSaved={() => { setEditing(null); reload(); }} />}
      {history && <HistoryModal student={history} onClose={() => setHistory(null)} />}
    </div>
  );
}

function AddStudentsModal({ open, onClose, onSubmit }: { open: boolean; onClose: () => void; onSubmit: (names: string[]) => Promise<void> }) {
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const names = text.split(/\r?\n/).map((s) => s.replace(/^\s*\d+[.)\-\s]+/, '').trim()).filter(Boolean);

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
        <label className="label" htmlFor="names">Họ và tên — mỗi dòng một bạn</label>
        <textarea id="names" className="input min-h-56 font-mono text-sm" value={text} onChange={(e) => setText(e.target.value)} placeholder={'Nguyễn Minh Anh\nTrần Gia Bảo\nLê Khánh Chi'} />
        <p className="text-xs text-slate-500">Có thể dán thẳng từ Excel/Zalo. Số thứ tự đầu dòng (1. 2. …) sẽ tự bỏ; tên trùng sẽ được bỏ qua. Tên hiển thị trên bảng xếp hạng mặc định là 2 chữ cuối (vd: “Minh Anh”).</p>
      </form>
    </Modal>
  );
}

function EditStudentModal({ student, onClose, onSaved }: { student: StudentStats; onClose: () => void; onSaved: () => void }) {
  const [f, setF] = useState({ full_name: student.full_name, display_name: student.display_name, note: student.note ?? '', is_active: student.is_active });
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
