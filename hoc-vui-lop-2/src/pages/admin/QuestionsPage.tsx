import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Link, useSearchParams } from 'react-router';
import { Download, Pencil, Plus, Search, Trash2, Upload, Wand2 } from 'lucide-react';
import { DifficultyChip, EmptyState, PageHeader, Pager, pct, Toggle, TypeChip } from '../../components/admin';
import { QuestionText } from '../../components/QuestionInput';
import { AdminError, LoadingBlock, Modal, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import type { Filter } from '../../lib/backend';
import { downloadText, toCsv } from '../../lib/csv';
import { DIFFICULTY_LABEL } from '../../lib/text';
import type { LessonView, Question, QuestionType, QuestionView } from '../../types';

const PAGE_SIZE = 30;

const BANKS: Record<string, { label: string; filter: Filter }> = {
  archimes: { label: 'Archimes (theo bộ sách)', filter: ['generator_type', 'eq', 'archimes'] },
  rule: { label: 'Sinh tự động', filter: ['generator_type', 'ilike', 'rule:%'] },
  import: { label: 'Nhập từ file', filter: ['generator_type', 'eq', 'import'] },
  manual: { label: 'Tự thêm tay', filter: ['generator_type', 'is', null] },
};

type Adapt = 'up' | 'down' | 'check';
interface AdaptRule { min: number; up: number; down: number }

const ADAPT_INFO: Record<Adapt, { label: string; cls: string; hint: string }> = {
  up: { label: 'Nên tăng độ khó', cls: 'bg-blue-100 text-blue-800', hint: 'Hầu hết các bạn làm đúng' },
  down: { label: 'Nên giảm độ khó', cls: 'bg-amber-100 text-amber-800', hint: 'Nhiều bạn làm sai' },
  check: { label: 'Kiểm tra lại câu', cls: 'bg-rose-100 text-rose-800', hint: 'Câu dễ mà nhiều bạn sai: có thể đề khó hiểu hoặc đáp án nhập nhầm' },
};

/** Gợi ý chỉnh độ khó theo tỉ lệ làm đúng; cần đủ số lượt trả lời mới gợi ý. */
function adaptOf(q: Pick<QuestionView, 'answered_count' | 'correct_count' | 'difficulty'>, r: AdaptRule): Adapt | null {
  if (q.answered_count < Math.max(1, r.min)) return null;
  const rate = (100 * q.correct_count) / q.answered_count;
  if (rate >= r.up && q.difficulty < 3) return 'up';
  if (rate < r.down) return q.difficulty > 1 ? 'down' : 'check';
  return null;
}

function optionsOf(q: Pick<Question, 'option_a' | 'option_b' | 'option_c' | 'option_d'>): string[] {
  return [q.option_a, q.option_b, q.option_c, q.option_d].filter((o): o is string => !!o);
}

function sourceLabel(q: Pick<Question, 'generator_type' | 'source_book' | 'source_page'>): string | null {
  if (q.generator_type === 'archimes') return `Archimes${q.source_page ? ` · tr.${q.source_page}` : ''}`;
  if (q.generator_type?.startsWith('rule:')) return 'Tự sinh';
  if (q.generator_type === 'import') return 'Nhập file';
  return null;
}

export default function QuestionsPage() {
  const [params, setParams] = useSearchParams();
  const lessonId = params.get('lesson') ?? '';
  const subjectId = params.get('subject') ?? '';
  const difficulty = params.get('difficulty') ?? '';
  const type = params.get('type') ?? '';
  const active = params.get('active') ?? '';
  const bank = params.get('bank') ?? '';
  const adapt = (params.get('adapt') ?? '') as Adapt | '';
  const q = params.get('q') ?? '';
  const page = Number(params.get('page') ?? 0) || 0;

  const [searchText, setSearchText] = useState(q);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [editing, setEditing] = useState<Partial<Question> | null>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<unknown>(null);

  const lessonsState = useAsync(() => adminApi.listLessons(), []);
  const lessons = lessonsState.data ?? [];
  const settingsState = useAsync(() => adminApi.getSettings(), []);
  const s = settingsState.data;
  const rule: AdaptRule = { min: s?.adapt_min_answers ?? 10, up: s?.adapt_up_pct ?? 90, down: s?.adapt_down_pct ?? 40 };
  const subjects = useMemo(() => {
    const m = new Map<string, string>();
    for (const l of lessons) m.set(l.subject_id, l.subject_name);
    return [...m.entries()];
  }, [lessons]);

  const filters = useMemo<Filter[]>(() => {
    const f: Filter[] = [];
    if (lessonId) f.push(['lesson_id', 'eq', lessonId]);
    else if (subjectId) f.push(['subject_id', 'eq', subjectId]);
    if (difficulty) f.push(['difficulty', 'eq', Number(difficulty)]);
    if (type) f.push(['question_type', 'eq', type]);
    if (active) f.push(['is_active', 'eq', active === '1']);
    if (BANKS[bank]) f.push(BANKS[bank].filter);
    if (q.trim()) f.push(['question_text', 'ilike', `%${q.trim()}%`]);
    return f;
  }, [lessonId, subjectId, difficulty, type, active, bank, q]);

  const order: Array<[string, boolean]> = [['week_number', true], ['lesson_order', true], ['difficulty', true], ['created_at', true]];
  const { data, error, loading, reload } = useAsync(async () => {
    if (!adapt) return adminApi.listQuestions({ filters, order, limit: PAGE_SIZE, offset: page * PAGE_SIZE });
    // Tỉ lệ đúng không lọc được trên server: lấy các câu đủ lượt trả lời rồi lọc và chia trang tại máy.
    const all = await adminApi.listQuestions({ filters: [...filters, ['answered_count', 'gte', Math.max(1, rule.min)]], order, limit: 10000 });
    const matched = all.rows.filter((r) => adaptOf(r, rule) === adapt);
    return { rows: matched.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE), count: matched.length };
  }, [JSON.stringify(filters), page, adapt, rule.min, rule.up, rule.down]);

  useEffect(() => setSelected(new Set()), [JSON.stringify(filters), page, adapt]);
  useEffect(() => setSearchText(q), [q]);

  const setParam = (key: string, value: string) => {
    const next = new URLSearchParams(params);
    if (value) next.set(key, value);
    else next.delete(key);
    if (key !== 'page') next.delete('page');
    if (key === 'subject') next.delete('lesson');
    setParams(next, { replace: true });
  };

  const run = async (fn: () => Promise<unknown>) => {
    setBusy(true);
    setActionError(null);
    try {
      await fn();
      reload();
      lessonsState.reload();
    } catch (e) {
      setActionError(e);
    } finally {
      setBusy(false);
    }
  };

  const rows = data?.rows ?? [];
  const total = data?.count ?? 0;
  const allChecked = rows.length > 0 && rows.every((r) => selected.has(r.id));
  const selectedIds = [...selected];

  const shiftDifficulty = (qs: QuestionView[], delta: 1 | -1) => run(async () => {
    for (const d of [1, 2, 3] as const) {
      const ids = qs.filter((x) => x.difficulty === d && d + delta >= 1 && d + delta <= 3).map((x) => x.id);
      if (ids.length) await adminApi.updateQuestions(ids, { difficulty: (d + delta) as 1 | 2 | 3 });
    }
  });
  const selectedRows = rows.filter((r) => selected.has(r.id));

  const exportCsv = () => run(async () => {
    const all = await adminApi.listQuestions({ filters, order, limit: 10000 });
    const csv = toCsv(all.rows.map((r) => ({ ...r, subject: r.subject_code })), [
      ['subject', 'subject'], ['week_number', 'week'], ['lesson_order', 'lesson'], ['lesson_name', 'lesson_name'],
      ['difficulty', 'difficulty'], ['question_type', 'type'], ['question_text', 'question'],
      ['option_a', 'option_a'], ['option_b', 'option_b'], ['option_c', 'option_c'], ['option_d', 'option_d'],
      ['correct_answer', 'answer'], ['accepted_answers', 'accepted_answers'], ['explanation', 'explanation'],
      ['skill_tag', 'skill_tag'], ['source_page', 'source_page'], ['answered_count', 'so_luot_tra_loi'], ['correct_count', 'so_luot_dung'],
    ]);
    downloadText(`cau_hoi_${new Date().toISOString().slice(0, 10)}.csv`, csv);
  });

  const lessonOptions = subjectId ? lessons.filter((l) => l.subject_id === subjectId) : lessons;

  return (
    <div className="space-y-5">
      <PageHeader
        title="Ngân hàng câu hỏi"
        description="Đáp án chỉ lưu trên máy chủ, học sinh không xem được trước khi nộp."
        actions={
          <>
            <Link to="/admin/import" className="btn btn-secondary"><Upload className="h-4 w-4" /> Nhập file</Link>
            <Link to="/admin/generator" className="btn btn-secondary"><Wand2 className="h-4 w-4" /> Sinh tự động</Link>
            <button type="button" className="btn btn-secondary" onClick={exportCsv} disabled={busy}><Download className="h-4 w-4" /> Xuất CSV</button>
            <button
              type="button"
              className="btn btn-primary"
              disabled={lessons.length === 0}
              onClick={() => setEditing({ lesson_id: lessonId || lessons[0]?.id, difficulty: 1, question_type: 'multiple_choice', is_active: true })}
            >
              <Plus className="h-4 w-4" /> Thêm câu hỏi
            </button>
          </>
        }
      />

      <div className="panel grid gap-3 p-4 sm:grid-cols-2 lg:grid-cols-4">
        <select className="input" value={bank} onChange={(e) => setParam('bank', e.target.value)} aria-label="Lọc theo ngân hàng">
          <option value="">Mọi ngân hàng</option>
          {Object.entries(BANKS).map(([id, b]) => <option key={id} value={id}>{b.label}</option>)}
        </select>
        <form
          className="relative sm:col-span-1 lg:col-span-3"
          onSubmit={(e) => {
            e.preventDefault();
            setParam('q', searchText);
          }}
        >
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input className="input pl-9" placeholder="Tìm nội dung câu hỏi…" value={searchText} onChange={(e) => setSearchText(e.target.value)} onBlur={() => searchText !== q && setParam('q', searchText)} aria-label="Tìm câu hỏi" />
        </form>
        <select className="input" value={subjectId} onChange={(e) => setParam('subject', e.target.value)} aria-label="Lọc theo môn">
          <option value="">Tất cả môn</option>
          {subjects.map(([id, name]) => <option key={id} value={id}>{name}</option>)}
        </select>
        <select className="input" value={lessonId} onChange={(e) => setParam('lesson', e.target.value)} aria-label="Lọc theo bài">
          <option value="">Tất cả bài</option>
          {lessonOptions.map((l) => <option key={l.id} value={l.id}>T{l.week_number} · Bài {l.lesson_order}: {l.name}</option>)}
        </select>
        <select className="input" value={difficulty} onChange={(e) => setParam('difficulty', e.target.value)} aria-label="Lọc theo độ khó">
          <option value="">Mọi độ khó</option>
          <option value="1">Dễ</option>
          <option value="2">Vừa</option>
          <option value="3">Nâng cao</option>
        </select>
        <div className="flex gap-2">
          <select className="input" value={type} onChange={(e) => setParam('type', e.target.value)} aria-label="Lọc theo dạng">
            <option value="">Mọi dạng</option>
            <option value="multiple_choice">Trắc nghiệm</option>
            <option value="number">Điền số</option>
            <option value="text">Điền chữ</option>
          </select>
          <select className="input" value={active} onChange={(e) => setParam('active', e.target.value)} aria-label="Lọc trạng thái">
            <option value="">Tất cả</option>
            <option value="1">Đang dùng</option>
            <option value="0">Đã tắt</option>
          </select>
        </div>
        <select className="input" value={adapt} onChange={(e) => setParam('adapt', e.target.value)} aria-label="Lọc theo gợi ý độ khó">
          <option value="">Mọi gợi ý độ khó</option>
          {(Object.keys(ADAPT_INFO) as Adapt[]).map((k) => <option key={k} value={k}>{ADAPT_INFO[k].label}</option>)}
        </select>
        <p className="self-center text-xs text-slate-500 sm:col-span-1 lg:col-span-3">
          Gợi ý khi câu có từ {rule.min} lượt trả lời: đúng từ {rule.up}% trở lên → nên tăng; đúng dưới {rule.down}% → nên giảm (câu Dễ thì nên kiểm tra lại đề/đáp án). Đổi ngưỡng ở <Link to="/admin/settings" className="font-semibold text-blue-700 hover:underline">Cài đặt</Link>.
        </p>
      </div>

      {selected.size > 0 && (
        <div className="flex flex-wrap items-center gap-2 rounded-xl bg-blue-50 px-4 py-2 text-sm text-blue-800">
          <span className="font-semibold">Đã chọn {selected.size} câu</span>
          <button type="button" className="btn btn-secondary btn-sm" disabled={busy} onClick={() => run(() => adminApi.updateQuestions(selectedIds, { is_active: true }))}>Bật</button>
          <button type="button" className="btn btn-secondary btn-sm" disabled={busy} onClick={() => run(() => adminApi.updateQuestions(selectedIds, { is_active: false }))}>Tắt</button>
          <button type="button" className="btn btn-secondary btn-sm" disabled={busy} onClick={() => shiftDifficulty(selectedRows, 1)}>Tăng độ khó</button>
          <button type="button" className="btn btn-secondary btn-sm" disabled={busy} onClick={() => shiftDifficulty(selectedRows, -1)}>Giảm độ khó</button>
          <button
            type="button"
            className="btn btn-danger btn-sm"
            disabled={busy}
            onClick={() => confirm(`Xoá vĩnh viễn ${selected.size} câu hỏi? Câu trả lời cũ của học sinh cho các câu này cũng bị xoá.`) && run(() => adminApi.deleteQuestions(selectedIds))}
          >
            Xoá
          </button>
          <button type="button" className="btn btn-ghost btn-sm" onClick={() => setSelected(new Set())}>Bỏ chọn</button>
        </div>
      )}

      {actionError !== null && <AdminError error={actionError} />}
      {error !== null && <AdminError error={error} onRetry={reload} />}

      <div className="panel overflow-hidden">
        {loading && !data ? (
          <LoadingBlock />
        ) : rows.length === 0 ? (
          <EmptyState title="Không có câu hỏi phù hợp">Thử bỏ bớt bộ lọc, nhập file CSV hoặc dùng bộ sinh câu hỏi.</EmptyState>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr>
                  <th className="th w-10">
                    <input
                      type="checkbox"
                      aria-label="Chọn tất cả"
                      checked={allChecked}
                      onChange={(e) => setSelected(e.target.checked ? new Set(rows.map((r) => r.id)) : new Set())}
                    />
                  </th>
                  <th className="th">Câu hỏi & đáp án</th>
                  <th className="th">Bài</th>
                  <th className="th">Phân loại</th>
                  <th className="th">Đúng</th>
                  <th className="th">Dùng</th>
                  <th className="th w-24" />
                </tr>
              </thead>
              <tbody className={loading ? 'opacity-60' : ''}>
                {rows.map((r) => (
                  <QuestionRow
                    key={r.id}
                    q={r}
                    adapt={adaptOf(r, rule)}
                    checked={selected.has(r.id)}
                    busy={busy}
                    onShift={(d) => shiftDifficulty([r], d)}
                    onCheck={(v) => setSelected((s) => {
                      const n = new Set(s);
                      if (v) n.add(r.id);
                      else n.delete(r.id);
                      return n;
                    })}
                    onToggle={(v) => run(() => adminApi.updateQuestion(r.id, { is_active: v }))}
                    onEdit={() => setEditing(r)}
                    onDelete={() => confirm('Xoá vĩnh viễn câu hỏi này?') && run(() => adminApi.deleteQuestions([r.id]))}
                  />
                ))}
              </tbody>
            </table>
          </div>
        )}
        <Pager page={page} pageSize={PAGE_SIZE} total={total} onChange={(p) => setParam('page', String(p))} />
      </div>

      {editing && (
        <QuestionForm
          question={editing}
          lessons={lessons}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            reload();
            lessonsState.reload();
          }}
        />
      )}
    </div>
  );
}

function QuestionRow({ q, adapt, checked, busy, onCheck, onShift, onToggle, onEdit, onDelete }: {
  q: QuestionView; adapt: Adapt | null; checked: boolean; busy: boolean;
  onCheck: (v: boolean) => void; onShift: (delta: 1 | -1) => void; onToggle: (v: boolean) => void; onEdit: () => void; onDelete: () => void;
}) {
  const opts = optionsOf(q);
  const source = sourceLabel(q);
  return (
    <tr className={`border-t border-slate-100 align-top ${q.is_active ? '' : 'bg-slate-50 text-slate-400'}`}>
      <td className="td"><input type="checkbox" aria-label="Chọn câu hỏi" checked={checked} onChange={(e) => onCheck(e.target.checked)} /></td>
      <td className="td max-w-md">
        <p className="font-medium text-slate-800">{q.question_text}</p>
        {opts.length > 0 && (
          <div className="mt-1 flex flex-wrap gap-1">
            {opts.map((o) => (
              <span key={o} className={`chip ${o === q.correct_answer ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'}`}>{o}</span>
            ))}
          </div>
        )}
        {opts.length === 0 && (
          <p className="mt-1 text-xs">
            Đáp án: <b className="text-emerald-700">{q.correct_answer}</b>
            {q.accepted_answers && q.accepted_answers.length > 0 && <span className="text-slate-500"> · chấp nhận: {q.accepted_answers.join(', ')}</span>}
          </p>
        )}
      </td>
      <td className="td whitespace-nowrap text-xs text-slate-500">
        {q.subject_name}<br />T{q.week_number} · Bài {q.lesson_order}
      </td>
      <td className="td">
        <div className="flex flex-col items-start gap-1">
          <DifficultyChip value={q.difficulty} />
          <TypeChip value={q.question_type} />
          {source && <span className={`chip ${q.generator_type === 'archimes' ? 'bg-purple-100 text-purple-800' : 'bg-slate-100 text-slate-600'}`}>{source}</span>}
        </div>
      </td>
      <td className="td whitespace-nowrap text-xs">
        {q.answered_count > 0 ? <>{pct((100 * q.correct_count) / q.answered_count)}<br /><span className="text-slate-400">{q.answered_count} lượt</span></> : <span className="text-slate-400">—</span>}
        {adapt && (
          <div className="mt-1 flex flex-col items-start gap-1">
            <span className={`chip ${ADAPT_INFO[adapt].cls}`} title={ADAPT_INFO[adapt].hint}>{ADAPT_INFO[adapt].label}</span>
            {adapt !== 'check' && (
              <button type="button" className="btn btn-secondary btn-sm" disabled={busy} onClick={() => onShift(adapt === 'up' ? 1 : -1)}>
                {adapt === 'up' ? '↑' : '↓'} {DIFFICULTY_LABEL[q.difficulty + (adapt === 'up' ? 1 : -1)]}
              </button>
            )}
          </div>
        )}
      </td>
      <td className="td"><Toggle checked={q.is_active} disabled={busy} onChange={onToggle} label={q.is_active ? 'Đang dùng' : 'Đã tắt'} /></td>
      <td className="td whitespace-nowrap">
        <button type="button" className="btn btn-ghost btn-icon" aria-label="Sửa câu hỏi" onClick={onEdit}><Pencil className="h-4 w-4" /></button>
        <button type="button" className="btn btn-ghost btn-icon text-rose-600" aria-label="Xoá câu hỏi" onClick={onDelete}><Trash2 className="h-4 w-4" /></button>
      </td>
    </tr>
  );
}

export function QuestionForm({ question, lessons, onClose, onSaved }: {
  question: Partial<Question>; lessons: LessonView[]; onClose: () => void; onSaved: () => void;
}) {
  const [f, setF] = useState<Partial<Question>>(question);
  const [accepted, setAccepted] = useState((question.accepted_answers ?? []).join(' | '));
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | unknown>(null);
  const set = <K extends keyof Question>(k: K, v: Question[K]) => setF((p) => ({ ...p, [k]: v }));

  const type: QuestionType = f.question_type ?? 'multiple_choice';
  const opts = optionsOf({ option_a: f.option_a ?? null, option_b: f.option_b ?? null, option_c: f.option_c ?? null, option_d: f.option_d ?? null });

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const text = (f.question_text ?? '').trim();
    const answer = (f.correct_answer ?? '').trim();
    if (!text || !answer) return setError('Cần nhập nội dung câu hỏi và đáp án đúng.');
    if (type === 'multiple_choice') {
      if (opts.length < 2) return setError('Trắc nghiệm cần ít nhất 2 lựa chọn.');
      if (!opts.includes(answer)) return setError('Đáp án đúng phải trùng một trong các lựa chọn.');
      if (new Set(opts).size !== opts.length) return setError('Các lựa chọn không được trùng nhau.');
    }
    if (type === 'number' && !/^-?\d+$/.test(answer.replace(/[\s.,]/g, ''))) return setError('Đáp án dạng điền số phải là số.');

    const payload: Partial<Question> = {
      lesson_id: f.lesson_id,
      difficulty: f.difficulty ?? 1,
      question_type: type,
      question_text: text,
      option_a: type === 'multiple_choice' ? opts[0] ?? null : null,
      option_b: type === 'multiple_choice' ? opts[1] ?? null : null,
      option_c: type === 'multiple_choice' ? opts[2] ?? null : null,
      option_d: type === 'multiple_choice' ? opts[3] ?? null : null,
      correct_answer: answer,
      accepted_answers: type === 'multiple_choice' ? null : (accepted.split('|').map((s) => s.trim()).filter(Boolean) || null),
      explanation: f.explanation?.trim() || null,
      points: f.points ? Number(f.points) : null,
      skill_tag: f.skill_tag?.trim() || null,
      source_page: f.source_page ? Number(f.source_page) : null,
      is_active: f.is_active ?? true,
    };
    if (payload.accepted_answers && payload.accepted_answers.length === 0) payload.accepted_answers = null;
    setBusy(true);
    setError(null);
    try {
      if (question.id) await adminApi.updateQuestion(question.id, payload);
      else await adminApi.insertQuestions([payload]);
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
      wide
      title={question.id ? 'Sửa câu hỏi' : 'Thêm câu hỏi'}
      onClose={onClose}
      footer={
        <>
          <button type="button" className="btn btn-secondary" onClick={onClose}>Huỷ</button>
          <button type="submit" form="question-form" className="btn btn-primary" disabled={busy}>{busy && <Spinner className="h-4 w-4 text-white" />} Lưu câu hỏi</button>
        </>
      }
    >
      <div className="grid gap-6 lg:grid-cols-[1fr_320px]">
        <form id="question-form" onSubmit={submit} className="space-y-4">
          <div>
            <label className="label" htmlFor="q-lesson">Bài học</label>
            <select id="q-lesson" className="input" required value={f.lesson_id ?? ''} onChange={(e) => set('lesson_id', e.target.value)}>
              {lessons.map((l) => <option key={l.id} value={l.id}>{l.subject_name} · T{l.week_number} · Bài {l.lesson_order}: {l.name}</option>)}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label" htmlFor="q-diff">Độ khó</label>
              <select id="q-diff" className="input" value={f.difficulty ?? 1} onChange={(e) => set('difficulty', Number(e.target.value) as 1 | 2 | 3)}>
                <option value={1}>Dễ</option>
                <option value={2}>Vừa</option>
                <option value={3}>Nâng cao</option>
              </select>
            </div>
            <div>
              <label className="label" htmlFor="q-type">Dạng câu hỏi</label>
              <select id="q-type" className="input" value={type} onChange={(e) => set('question_type', e.target.value as QuestionType)}>
                <option value="multiple_choice">Trắc nghiệm</option>
                <option value="number">Điền số</option>
                <option value="text">Điền chữ</option>
              </select>
            </div>
          </div>
          <div>
            <label className="label" htmlFor="q-text">Nội dung câu hỏi</label>
            <textarea id="q-text" className="input min-h-20" required value={f.question_text ?? ''} onChange={(e) => set('question_text', e.target.value)} placeholder="VD: 38 + ___ = 45  (dùng ___ để tạo ô trống)" />
          </div>
          {type === 'multiple_choice' ? (
            <>
              <div className="grid grid-cols-2 gap-3">
                {(['option_a', 'option_b', 'option_c', 'option_d'] as const).map((k, i) => (
                  <div key={k}>
                    <label className="label" htmlFor={`q-${k}`}>Lựa chọn {'ABCD'[i]}{i >= 2 && ' (không bắt buộc)'}</label>
                    <input id={`q-${k}`} className="input" value={f[k] ?? ''} onChange={(e) => set(k, e.target.value || null)} />
                  </div>
                ))}
              </div>
              <div>
                <label className="label" htmlFor="q-answer">Đáp án đúng</label>
                <select id="q-answer" className="input" required value={f.correct_answer ?? ''} onChange={(e) => set('correct_answer', e.target.value)}>
                  <option value="">— Chọn đáp án đúng —</option>
                  {opts.map((o) => <option key={o} value={o}>{o}</option>)}
                </select>
              </div>
            </>
          ) : (
            <div className="grid gap-3 sm:grid-cols-2">
              <div>
                <label className="label" htmlFor="q-answer">Đáp án đúng</label>
                <input id="q-answer" className="input" required inputMode={type === 'number' ? 'numeric' : 'text'} value={f.correct_answer ?? ''} onChange={(e) => set('correct_answer', e.target.value)} />
              </div>
              <div>
                <label className="label" htmlFor="q-accepted">Đáp án khác cũng đúng</label>
                <input id="q-accepted" className="input" value={accepted} onChange={(e) => setAccepted(e.target.value)} placeholder="ngăn cách bằng dấu |" />
              </div>
              <p className="text-xs text-slate-500 sm:col-span-2">
                Hệ thống tự bỏ qua khoảng trắng thừa, chữ hoa/thường và dấu chấm cuối câu. {type === 'number' && 'Với số: “1.000”, “1 000” và “1000” được coi là như nhau.'}
              </p>
            </div>
          )}
          <div>
            <label className="label" htmlFor="q-exp">Giải thích (hiện sau khi học sinh trả lời)</label>
            <textarea id="q-exp" className="input min-h-16" value={f.explanation ?? ''} onChange={(e) => set('explanation', e.target.value)} />
          </div>
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="label" htmlFor="q-points">Điểm riêng</label>
              <input id="q-points" type="number" min={1} max={100} className="input" placeholder="Mặc định" value={f.points ?? ''} onChange={(e) => set('points', e.target.value ? Number(e.target.value) : null)} />
            </div>
            <div>
              <label className="label" htmlFor="q-skill">Kỹ năng</label>
              <input id="q-skill" className="input" value={f.skill_tag ?? ''} onChange={(e) => set('skill_tag', e.target.value)} />
            </div>
            <div>
              <label className="label" htmlFor="q-page">Trang sách</label>
              <input id="q-page" type="number" min={0} className="input" value={f.source_page ?? ''} onChange={(e) => set('source_page', e.target.value ? Number(e.target.value) : null)} />
            </div>
          </div>
          {error !== null && (typeof error === 'string' ? <p className="rounded-lg bg-rose-50 p-3 text-sm text-rose-700">{error}</p> : <AdminError error={error} />)}
        </form>

        <aside className="rounded-2xl bg-sky-50 p-4">
          <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-slate-500">Học sinh sẽ thấy</p>
          <div className="card p-4">
            <QuestionText text={f.question_text || 'Nội dung câu hỏi…'} big={false} />
            {type === 'multiple_choice' ? (
              <div className="mt-4 grid grid-cols-2 gap-2">
                {opts.map((o) => (
                  <div key={o} className={`rounded-xl border-2 px-3 py-3 text-center font-display text-lg font-bold ${o === f.correct_answer ? 'border-emerald-400 bg-emerald-50 text-emerald-700' : 'border-slate-200 text-slate-700'}`}>{o}</div>
                ))}
              </div>
            ) : (
              <div className="mt-4 rounded-xl border-2 border-dashed border-blue-300 bg-white px-3 py-3 text-center text-slate-400">
                {type === 'number' ? 'Bàn phím số' : 'Ô gõ chữ'} → <b className="text-emerald-700">{f.correct_answer || '…'}</b>
              </div>
            )}
          </div>
        </aside>
      </div>
    </Modal>
  );
}
