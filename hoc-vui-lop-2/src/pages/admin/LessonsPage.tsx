import { useMemo, useState, type FormEvent } from 'react';
import { Link } from 'react-router';
import { Eye, EyeOff, ListChecks, Pencil, Plus, Settings2, Tags, Trash2 } from 'lucide-react';
import { EmptyState, isoToLocalInput, localInputToIso, PageHeader, pct, Toggle } from '../../components/admin';
import { SubjectSettingsModal } from '../../components/SubjectSettingsModal';
import { AdminError, LoadingBlock, Modal, Spinner, subjectStyle } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import type { Lesson, LessonView, PublishMode, Subject, SubjectColor } from '../../types';

const MODE_LABEL: Record<PublishMode, string> = {
  always: 'Mở ngay',
  week: 'Mở theo tuần',
  date: 'Mở theo ngày',
};

function visibility(l: LessonView, currentWeek: number): { label: string; cls: string } {
  if (!l.is_published) return { label: 'Đang ẩn', cls: 'bg-slate-100 text-slate-600' };
  if (l.publish_mode === 'week' && l.week_number > currentWeek) return { label: `Chờ tới tuần ${l.week_number}`, cls: 'bg-amber-50 text-amber-700' };
  if (l.publish_mode === 'date') {
    const now = Date.now();
    if (l.available_from && new Date(l.available_from).getTime() > now) return { label: 'Chờ tới ngày mở', cls: 'bg-amber-50 text-amber-700' };
    if (l.available_until && new Date(l.available_until).getTime() < now) return { label: 'Đã đóng', cls: 'bg-slate-100 text-slate-600' };
  }
  return { label: 'Học sinh đang thấy', cls: 'bg-emerald-50 text-emerald-700' };
}

export default function LessonsPage() {
  const { data, error, loading, reload } = useAsync(async () => {
    const [subjects, lessons, settings] = await Promise.all([adminApi.listSubjects(), adminApi.listLessons(), adminApi.getSettings()]);
    return { subjects, lessons, currentWeek: settings?.current_week ?? 1 };
  }, []);
  const [subjectFilter, setSubjectFilter] = useState<string>('all');
  const [editing, setEditing] = useState<Partial<Lesson> | null>(null);
  const [subjectsOpen, setSubjectsOpen] = useState(false);
  const [settingsFor, setSettingsFor] = useState<Subject | null>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<unknown>(null);

  const groups = useMemo(() => {
    if (!data) return [];
    const map = new Map<string, { key: string; subject: string; sort: number; color: SubjectColor; week: number; lessons: LessonView[] }>();
    for (const l of data.lessons) {
      if (subjectFilter !== 'all' && l.subject_id !== subjectFilter) continue;
      const key = `${l.subject_id}-${l.week_number}`;
      if (!map.has(key)) map.set(key, { key, subject: l.subject_name, sort: l.subject_sort, color: l.subject_color, week: l.week_number, lessons: [] });
      map.get(key)!.lessons.push(l);
    }
    return [...map.values()].sort((a, b) => a.week - b.week || a.sort - b.sort || a.subject.localeCompare(b.subject, 'vi'));
  }, [data, subjectFilter]);

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;
  if (!data) return null;

  const run = async (fn: () => Promise<unknown>) => {
    setBusy(true);
    setActionError(null);
    try {
      await fn();
      reload();
    } catch (e) {
      setActionError(e);
    } finally {
      setBusy(false);
    }
  };

  const togglePublish = (l: LessonView, v: boolean) => run(() => adminApi.updateLesson(l.id, { is_published: v }));
  const setWeekPublished = (lessons: LessonView[], v: boolean) => run(() => adminApi.updateLessons(lessons.map((l) => l.id), { is_published: v }));
  const deleteLesson = (l: LessonView) => {
    if (!confirm(`Xoá bài "${l.name}"?\n\nToàn bộ ${l.question_count} câu hỏi và kết quả làm bài của bài này sẽ bị xoá vĩnh viễn.\nNếu chỉ muốn tạm ẩn, hãy tắt công bố.`)) return;
    void run(() => adminApi.deleteLesson(l.id));
  };

  const newLesson = () => {
    const subjectId = subjectFilter !== 'all' ? subjectFilter : data.subjects[0]?.id;
    const same = data.lessons.filter((l) => l.subject_id === subjectId);
    const lastOrder = same.reduce((m, l) => Math.max(m, l.lesson_order), 0);
    setEditing({
      subject_id: subjectId,
      week_number: data.currentWeek,
      lesson_order: lastOrder + 1,
      name: '',
      is_published: true,
      publish_mode: 'week',
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Bài học & lịch mở bài"
        description={<>Tuần hiện tại: <b>Tuần {data.currentWeek}</b>. Bài “Mở theo tuần” chỉ hiện khi tới tuần của bài.</>}
        actions={
          <>
            <button type="button" className="btn btn-secondary" onClick={() => setSubjectsOpen(true)}><Tags className="h-4 w-4" /> Môn học</button>
            <button type="button" className="btn btn-primary" onClick={newLesson} disabled={data.subjects.length === 0}><Plus className="h-4 w-4" /> Thêm bài</button>
          </>
        }
      />

      <div className="flex flex-wrap gap-2">
        <button type="button" className={`btn btn-sm ${subjectFilter === 'all' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setSubjectFilter('all')}>Tất cả môn</button>
        {data.subjects.map((s) => (
          <button key={s.id} type="button" className={`btn btn-sm ${subjectFilter === s.id ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setSubjectFilter(s.id)}>{s.name}</button>
        ))}
        {subjectFilter !== 'all' && (() => {
          const s = data.subjects.find((x) => x.id === subjectFilter);
          return s ? (
            <button type="button" className="btn btn-sm btn-ghost" onClick={() => setSettingsFor(s)}>
              <Settings2 className="h-4 w-4" /> Cài đặt môn {s.name}
            </button>
          ) : null;
        })()}
      </div>

      {actionError !== null && <AdminError error={actionError} />}

      {groups.length === 0 && (
        <div className="panel">
          <EmptyState title="Chưa có bài học nào">
            Thêm bài bằng nút “Thêm bài”, hoặc <Link to="/admin/import" className="text-blue-600 hover:underline">nhập file CSV</Link> — bài sẽ được tạo tự động.
          </EmptyState>
        </div>
      )}

      {groups.map((g) => {
        const allPublished = g.lessons.every((l) => l.is_published);
        const style = subjectStyle(g.color);
        return (
          <section key={g.key} className="panel overflow-hidden">
            <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-100 bg-slate-50/60 px-5 py-3">
              <div className="flex items-center gap-2">
                <span className={`chip ${style.chip}`}>{g.subject}</span>
                <h2 className="font-semibold text-slate-800">Tuần {g.week}</h2>
                {g.week === data.currentWeek && <span className="chip bg-blue-600 text-white">Tuần hiện tại</span>}
              </div>
              <button type="button" className="btn btn-ghost btn-sm" disabled={busy} onClick={() => setWeekPublished(g.lessons, !allPublished)}>
                {allPublished ? <><EyeOff className="h-4 w-4" /> Ẩn cả tuần</> : <><Eye className="h-4 w-4" /> Công bố cả tuần</>}
              </button>
            </div>
            <ul className="divide-y divide-slate-100">
              {g.lessons.map((l) => {
                const vis = visibility(l, data.currentWeek);
                return (
                  <li key={l.id} className="flex flex-col gap-3 px-5 py-3 md:flex-row md:items-center">
                    <div className="min-w-0 flex-1">
                      <p className="font-medium text-slate-800">Bài {l.lesson_order}: {l.name}</p>
                      <p className="mt-0.5 text-xs text-slate-500">
                        {l.question_count} câu (dễ {l.easy_count} · vừa {l.normal_count} · khó {l.advanced_count})
                        {' · '}{l.students_done} bạn đã làm · đúng {pct(l.accuracy)}
                      </p>
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="chip bg-slate-100 text-slate-600">{MODE_LABEL[l.publish_mode]}</span>
                      <span className={`chip ${vis.cls}`}>{vis.label}</span>
                      <Toggle checked={l.is_published} disabled={busy} onChange={(v) => togglePublish(l, v)} label={l.is_published ? 'Đang công bố — bấm để ẩn' : 'Đang ẩn — bấm để công bố'} />
                      <Link to={`/admin/questions?lesson=${l.id}`} className="btn btn-ghost btn-sm"><ListChecks className="h-4 w-4" /> Câu hỏi</Link>
                      <button type="button" className="btn btn-ghost btn-icon" aria-label="Sửa bài" onClick={() => setEditing(l)}><Pencil className="h-4 w-4" /></button>
                      <button type="button" className="btn btn-ghost btn-icon text-rose-600" aria-label="Xoá bài" onClick={() => deleteLesson(l)}><Trash2 className="h-4 w-4" /></button>
                    </div>
                  </li>
                );
              })}
            </ul>
          </section>
        );
      })}

      {editing && (
        <LessonForm
          lesson={editing}
          subjects={data.subjects}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            reload();
          }}
        />
      )}
      <SubjectsModal open={subjectsOpen} subjects={data.subjects} onClose={() => setSubjectsOpen(false)} onChanged={reload}
        onSettings={(s) => { setSubjectsOpen(false); setSettingsFor(s); }} />
      <SubjectSettingsModal subject={settingsFor} onClose={() => setSettingsFor(null)} />
    </div>
  );
}

function LessonForm({ lesson, subjects, onClose, onSaved }: {
  lesson: Partial<Lesson>; subjects: Subject[]; onClose: () => void; onSaved: () => void;
}) {
  const [form, setForm] = useState<Partial<Lesson>>(lesson);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);
  const set = <K extends keyof Lesson>(k: K, v: Lesson[K]) => setForm((f) => ({ ...f, [k]: v }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    const payload: Partial<Lesson> = {
      subject_id: form.subject_id,
      week_number: Number(form.week_number),
      lesson_order: Number(form.lesson_order),
      name: (form.name ?? '').trim(),
      description: form.description?.trim() || null,
      is_published: !!form.is_published,
      publish_mode: form.publish_mode ?? 'week',
      available_from: form.publish_mode === 'date' ? form.available_from ?? null : null,
      available_until: form.publish_mode === 'date' ? form.available_until ?? null : null,
    };
    try {
      if (lesson.id) await adminApi.updateLesson(lesson.id, payload);
      else await adminApi.insertLessons([payload]);
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
      title={lesson.id ? 'Sửa bài học' : 'Thêm bài học'}
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose}>Huỷ</button>
          <button type="submit" form="lesson-form" className="btn btn-primary" disabled={busy}>{busy && <Spinner className="h-4 w-4 text-white" />} Lưu</button>
        </>
      }
    >
      <form id="lesson-form" onSubmit={submit} className="space-y-4">
        <div className="grid grid-cols-3 gap-3">
          <div className="col-span-3 sm:col-span-1">
            <label className="label" htmlFor="l-subject">Môn</label>
            <select id="l-subject" className="input" value={form.subject_id ?? ''} onChange={(e) => set('subject_id', e.target.value)} required>
              {subjects.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          </div>
          <div>
            <label className="label" htmlFor="l-week">Tuần</label>
            <input id="l-week" type="number" min={1} max={60} className="input" required value={form.week_number ?? 1} onChange={(e) => set('week_number', Number(e.target.value))} />
          </div>
          <div>
            <label className="label" htmlFor="l-order">Bài số</label>
            <input id="l-order" type="number" min={0} className="input" required value={form.lesson_order ?? 1} onChange={(e) => set('lesson_order', Number(e.target.value))} />
          </div>
        </div>
        <div>
          <label className="label" htmlFor="l-name">Tên bài</label>
          <input id="l-name" className="input" required maxLength={200} value={form.name ?? ''} onChange={(e) => set('name', e.target.value)} placeholder="VD: Phép cộng có nhớ trong phạm vi 100" />
        </div>
        <div>
          <label className="label" htmlFor="l-desc">Mô tả ngắn (không bắt buộc)</label>
          <input id="l-desc" className="input" maxLength={300} value={form.description ?? ''} onChange={(e) => set('description', e.target.value)} />
        </div>
        <fieldset className="space-y-2">
          <legend className="label">Lịch mở bài</legend>
          {(Object.keys(MODE_LABEL) as PublishMode[]).map((m) => (
            <label key={m} className="flex items-start gap-2 text-sm">
              <input type="radio" name="publish_mode" className="mt-1" checked={form.publish_mode === m} onChange={() => set('publish_mode', m)} />
              <span>
                <b>{MODE_LABEL[m]}</b>
                <span className="block text-xs text-slate-500">
                  {m === 'always' && 'Học sinh thấy ngay khi công bố.'}
                  {m === 'week' && 'Chỉ hiện khi “tuần hiện tại” ≥ tuần của bài (đổi tuần ở trang Tổng quan).'}
                  {m === 'date' && 'Hiện trong khoảng thời gian chọn bên dưới.'}
                </span>
              </span>
            </label>
          ))}
        </fieldset>
        {form.publish_mode === 'date' && (
          <div className="grid gap-3 sm:grid-cols-2">
            <div>
              <label className="label" htmlFor="l-from">Mở từ</label>
              <input id="l-from" type="datetime-local" className="input" value={isoToLocalInput(form.available_from)} onChange={(e) => set('available_from', localInputToIso(e.target.value))} />
            </div>
            <div>
              <label className="label" htmlFor="l-until">Đóng lúc (không bắt buộc)</label>
              <input id="l-until" type="datetime-local" className="input" value={isoToLocalInput(form.available_until)} onChange={(e) => set('available_until', localInputToIso(e.target.value))} />
            </div>
          </div>
        )}
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={!!form.is_published} onChange={(e) => set('is_published', e.target.checked)} />
          Công bố bài này
        </label>
        {error !== null && <AdminError error={error} />}
      </form>
    </Modal>
  );
}

const COLORS: Array<[SubjectColor, string]> = [['blue', 'Xanh dương'], ['green', 'Xanh lá'], ['amber', 'Vàng'], ['rose', 'Hồng'], ['purple', 'Tím']];

function SubjectsModal({ open, subjects, onClose, onChanged, onSettings }: {
  open: boolean; subjects: Subject[]; onClose: () => void; onChanged: () => void; onSettings: (s: Subject) => void;
}) {
  const [draft, setDraft] = useState({ code: '', name: '', color: 'blue' as SubjectColor });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  const run = async (fn: () => Promise<unknown>) => {
    setBusy(true);
    setError(null);
    try {
      await fn();
      onChanged();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  };

  const add = (e: FormEvent) => {
    e.preventDefault();
    const code = draft.code.trim().toLowerCase().replace(/[^a-z0-9_]+/g, '_');
    if (!code || !draft.name.trim()) return;
    void run(async () => {
      await adminApi.insertSubject({ code, name: draft.name.trim(), color: draft.color, sort_order: subjects.length + 1 });
      setDraft({ code: '', name: '', color: 'blue' });
    });
  };

  return (
    <Modal open={open} title="Môn học" onClose={onClose}>
      <ul className="mb-4 divide-y divide-slate-100 rounded-lg border border-slate-200">
        {subjects.map((s) => (
          <li key={s.id} className="flex items-center gap-2 px-3 py-2">
            <input className="input flex-1" defaultValue={s.name} aria-label="Tên môn" onBlur={(e) => e.target.value.trim() && e.target.value !== s.name && run(() => adminApi.updateSubject(s.id, { name: e.target.value.trim() }))} />
            <select className="input w-32" value={s.color} aria-label="Màu" onChange={(e) => run(() => adminApi.updateSubject(s.id, { color: e.target.value as SubjectColor }))}>
              {COLORS.map(([c, label]) => <option key={c} value={c}>{label}</option>)}
            </select>
            <code className="hidden text-xs text-slate-400 sm:inline">{s.code}</code>
            <button type="button" className="btn btn-ghost btn-icon" aria-label={`Cài đặt riêng môn ${s.name}`} title="Cài đặt riêng của môn" onClick={() => onSettings(s)}>
              <Settings2 className="h-4 w-4" />
            </button>
            <button
              type="button"
              className="btn btn-ghost btn-icon text-rose-600"
              aria-label={`Xoá môn ${s.name}`}
              disabled={busy}
              onClick={() => confirm(`Xoá môn "${s.name}"? Mọi bài học, câu hỏi và kết quả của môn này sẽ bị xoá.`) && run(() => adminApi.deleteSubject(s.id))}
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </li>
        ))}
      </ul>
      <form onSubmit={add} className="grid grid-cols-2 gap-2 sm:grid-cols-[1fr_1fr_auto_auto]">
        <input className="input" placeholder="Mã (vd: tnxh)" value={draft.code} onChange={(e) => setDraft({ ...draft, code: e.target.value })} required aria-label="Mã môn" />
        <input className="input" placeholder="Tên môn" value={draft.name} onChange={(e) => setDraft({ ...draft, name: e.target.value })} required aria-label="Tên môn mới" />
        <select className="input" value={draft.color} onChange={(e) => setDraft({ ...draft, color: e.target.value as SubjectColor })} aria-label="Màu môn mới">
          {COLORS.map(([c, label]) => <option key={c} value={c}>{label}</option>)}
        </select>
        <button type="submit" className="btn btn-primary" disabled={busy}><Plus className="h-4 w-4" /> Thêm</button>
      </form>
      <p className="mt-2 text-xs text-slate-500">Mã môn dùng trong cột <code>subject</code> của file CSV (vd: toan, tieng_viet).</p>
      {error !== null && <div className="mt-3"><AdminError error={error} /></div>}
    </Modal>
  );
}
