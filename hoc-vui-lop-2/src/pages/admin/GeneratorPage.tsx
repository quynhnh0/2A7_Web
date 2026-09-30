import { useMemo, useRef, useState } from 'react';
import { Link } from 'react-router';
import { CheckCircle2, RefreshCw, Save, Trash2, Wand2 } from 'lucide-react';
import { DifficultyChip, PageHeader, TypeChip } from '../../components/admin';
import { AdminError, LoadingBlock, Spinner } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { adminApi } from '../../lib/api';
import { ALL_SKILLS, createRng, generateBatch, questionKey, type GeneratedQuestion } from '../../lib/generators';
import type { Question } from '../../types';

const SUBJECT_GROUPS: Array<{ code: 'toan' | 'tieng_viet'; name: string }> = [
  { code: 'toan', name: 'Toán' },
  { code: 'tieng_viet', name: 'Tiếng Việt' },
];

export default function GeneratorPage() {
  const { data, error, loading, reload } = useAsync(async () => {
    const [subjects, lessons, settings] = await Promise.all([adminApi.listSubjects(), adminApi.listLessons(), adminApi.getSettings()]);
    return { subjects, lessons, currentWeek: settings?.current_week ?? 1 };
  }, []);

  const [group, setGroup] = useState<'toan' | 'tieng_viet'>('toan');
  const [skillIds, setSkillIds] = useState<Set<string>>(new Set());
  const [target, setTarget] = useState<'existing' | 'new'>('existing');
  const [lessonId, setLessonId] = useState('');
  const [newLesson, setNewLesson] = useState({ week: 0, order: 0, name: '' });
  const [counts, setCounts] = useState({ easy: 8, normal: 6, advanced: 6 });
  const [preview, setPreview] = useState<GeneratedQuestion[]>([]);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<unknown>(null);
  const [saved, setSaved] = useState<{ count: number; lessonId: string } | null>(null);
  const previewRef = useRef<HTMLElement>(null);

  const skills = useMemo(() => ALL_SKILLS.filter((s) => s.subject === group), [group]);
  const subject = data?.subjects.find((s) => s.code === group);
  const lessons = useMemo(() => (data && subject ? data.lessons.filter((l) => l.subject_id === subject.id) : []), [data, subject]);

  if (loading && !data) return <LoadingBlock />;
  if (error) return <AdminError error={error} onRetry={reload} />;
  if (!data) return null;

  const chosenSkills = skills.filter((s) => skillIds.has(s.id));
  const effectiveLessonId = lessonId || lessons[0]?.id || '';
  const nextOrder = lessons.reduce((m, l) => Math.max(m, l.lesson_order), 0) + 1;
  const newWeek = newLesson.week || data.currentWeek;
  const newOrder = newLesson.order || nextOrder;
  const useNew = target === 'new' || lessons.length === 0;

  const toggleSkill = (id: string) => setSkillIds((s) => {
    const n = new Set(s);
    if (n.has(id)) n.delete(id);
    else n.add(id);
    return n;
  });

  const existingKeys = async (): Promise<string[]> => {
    if (useNew || !effectiveLessonId) return [];
    const rows = await adminApi.questionKeysForLesson(effectiveLessonId);
    return rows.map((q) => questionKey({ question_text: q.question_text, options: [q.option_a, q.option_b, q.option_c, q.option_d] }));
  };

  const generate = async () => {
    setActionError(null);
    setSaved(null);
    setBusy(true);
    try {
      const keys = await existingKeys();
      const out = generateBatch(chosenSkills, counts, createRng(Date.now() ^ Math.floor(Math.random() * 1e9)), keys);
      setPreview(out);
      requestAnimationFrame(() => previewRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' }));
    } catch (e) {
      setActionError(e);
    } finally {
      setBusy(false);
    }
  };

  const save = async () => {
    setActionError(null);
    setBusy(true);
    try {
      let lid = effectiveLessonId;
      if (useNew) {
        let sid = subject?.id;
        if (!sid) {
          const [s] = await adminApi.insertSubject({ code: group, name: group === 'toan' ? 'Toán' : 'Tiếng Việt', color: group === 'toan' ? 'blue' : 'green', sort_order: data.subjects.length + 1 });
          sid = s.id;
        }
        const name = newLesson.name.trim() || chosenSkills.map((s) => s.name).join(', ').slice(0, 200);
        const [l] = await adminApi.insertLessons([{ subject_id: sid, week_number: newWeek, lesson_order: newOrder, name, is_published: true, publish_mode: 'week' }]);
        lid = l.id;
      }
      const keys = new Set(await existingKeys());
      const rows: Partial<Question>[] = [];
      for (const q of preview) {
        const k = questionKey(q);
        if (keys.has(k)) continue;
        keys.add(k);
        const opts = q.options ?? [];
        rows.push({
          lesson_id: lid,
          difficulty: q.difficulty,
          question_type: q.question_type,
          question_text: q.question_text,
          option_a: opts[0] ?? null,
          option_b: opts[1] ?? null,
          option_c: opts[2] ?? null,
          option_d: opts[3] ?? null,
          correct_answer: q.correct_answer,
          accepted_answers: q.accepted_answers,
          explanation: q.explanation,
          skill_tag: q.skill_tag,
          generator_type: q.generator_type,
          is_active: true,
        });
      }
      if (rows.length > 0) await adminApi.insertQuestions(rows);
      setSaved({ count: rows.length, lessonId: lid });
      setPreview([]);
      setTarget('existing');
      setLessonId(lid);
      reload();
    } catch (e) {
      setActionError(e);
    } finally {
      setBusy(false);
    }
  };

  const total = counts.easy + counts.normal + counts.advanced;

  return (
    <div className="space-y-5">
      <PageHeader
        title="Sinh câu hỏi tự động"
        description="Chọn dạng bài theo chương trình lớp 2, hệ thống tạo câu hỏi mới (có đáp án và giải thích). Xem trước rồi mới lưu."
      />

      <div className="grid gap-5 xl:grid-cols-[380px_1fr]">
        <div className="space-y-5">
          <section className="panel space-y-4 p-5">
            <div className="flex gap-2">
              {SUBJECT_GROUPS.map((g) => (
                <button
                  key={g.code}
                  type="button"
                  className={`btn flex-1 ${group === g.code ? 'btn-primary' : 'btn-secondary'}`}
                  onClick={() => {
                    setGroup(g.code);
                    setSkillIds(new Set());
                    setLessonId('');
                    setPreview([]);
                  }}
                >
                  {g.name}
                </button>
              ))}
            </div>

            <div>
              <div className="mb-2 flex items-center justify-between">
                <span className="label mb-0">Dạng bài ({chosenSkills.length} đã chọn)</span>
                <button type="button" className="text-xs text-blue-600 hover:underline" onClick={() => setSkillIds(chosenSkills.length === skills.length ? new Set() : new Set(skills.map((s) => s.id)))}>
                  {chosenSkills.length === skills.length ? 'Bỏ chọn hết' : 'Chọn hết'}
                </button>
              </div>
              <ul className="max-h-80 space-y-1 overflow-y-auto pr-1">
                {skills.map((s) => (
                  <li key={s.id}>
                    <label className={`flex cursor-pointer items-start gap-2 rounded-lg p-2 text-sm hover:bg-slate-50 ${skillIds.has(s.id) ? 'bg-blue-50' : ''}`}>
                      <input type="checkbox" className="mt-1" checked={skillIds.has(s.id)} onChange={() => toggleSkill(s.id)} />
                      <span>
                        <span className="font-medium text-slate-800">{s.name}</span>
                        <span className="block text-xs text-slate-500">VD: {s.example}</span>
                      </span>
                    </label>
                  </li>
                ))}
              </ul>
            </div>
          </section>

          <section className="panel space-y-4 p-5">
            <span className="label">Lưu vào bài</span>
            {lessons.length > 0 && (
              <div className="flex gap-2">
                <button type="button" className={`btn btn-sm flex-1 ${!useNew ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTarget('existing')}>Bài đã có</button>
                <button type="button" className={`btn btn-sm flex-1 ${useNew ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTarget('new')}>Tạo bài mới</button>
              </div>
            )}
            {!useNew ? (
              <select className="input" value={effectiveLessonId} onChange={(e) => setLessonId(e.target.value)} aria-label="Chọn bài">
                {lessons.map((l) => <option key={l.id} value={l.id}>T{l.week_number} · Bài {l.lesson_order}: {l.name} ({l.question_count} câu)</option>)}
              </select>
            ) : (
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="label" htmlFor="g-week">Tuần</label>
                  <input id="g-week" type="number" min={1} max={60} className="input" value={newWeek} onChange={(e) => setNewLesson({ ...newLesson, week: Number(e.target.value) })} />
                </div>
                <div>
                  <label className="label" htmlFor="g-order">Bài số</label>
                  <input id="g-order" type="number" min={0} className="input" value={newOrder} onChange={(e) => setNewLesson({ ...newLesson, order: Number(e.target.value) })} />
                </div>
                <div className="col-span-2">
                  <label className="label" htmlFor="g-name">Tên bài</label>
                  <input id="g-name" className="input" value={newLesson.name} placeholder="Để trống = lấy tên các dạng bài" onChange={(e) => setNewLesson({ ...newLesson, name: e.target.value })} />
                </div>
              </div>
            )}

            <div className="grid grid-cols-3 gap-3">
              {([['easy', 'Dễ'], ['normal', 'Vừa'], ['advanced', 'Nâng cao']] as const).map(([k, label]) => (
                <div key={k}>
                  <label className="label" htmlFor={`g-${k}`}>{label}</label>
                  <input id={`g-${k}`} type="number" min={0} max={100} className="input" value={counts[k]} onChange={(e) => setCounts({ ...counts, [k]: Math.max(0, Math.min(100, Number(e.target.value) || 0)) })} />
                </div>
              ))}
            </div>
            <p className="text-xs text-slate-500">Bài cơ bản cần nhiều câu dễ, bài nâng cao cần nhiều câu khó. Nên có ít nhất 10 câu mỗi mức để các lần làm lại không trùng câu.</p>

            <button type="button" className="btn btn-primary w-full" disabled={busy || chosenSkills.length === 0 || total === 0} onClick={generate}>
              {busy ? <Spinner className="h-4 w-4 text-white" /> : <Wand2 className="h-4 w-4" />} Sinh {total} câu hỏi
            </button>
          </section>
        </div>

        <section ref={previewRef} className="panel flex min-h-96 scroll-mt-4 flex-col">
          <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-100 px-5 py-3">
            <h2 className="font-semibold text-slate-800">Xem trước {preview.length > 0 && `(${preview.length} câu)`}</h2>
            {preview.length > 0 && (
              <div className="flex gap-2">
                <button type="button" className="btn btn-secondary btn-sm" onClick={generate} disabled={busy}><RefreshCw className="h-4 w-4" /> Sinh lại</button>
                <button type="button" className="btn btn-primary btn-sm" onClick={save} disabled={busy}><Save className="h-4 w-4" /> Lưu {preview.length} câu</button>
              </div>
            )}
          </div>
          {actionError !== null && <div className="p-4"><AdminError error={actionError} /></div>}
          {saved && (
            <div className="m-4 flex items-center gap-3 rounded-xl bg-emerald-50 p-4 text-sm text-emerald-800">
              <CheckCircle2 className="h-5 w-5" />
              <span className="flex-1">Đã lưu {saved.count} câu hỏi mới{saved.count < total && ' (đã bỏ câu trùng)'}.</span>
              <Link to={`/admin/questions?lesson=${saved.lessonId}`} className="font-semibold underline">Xem trong ngân hàng</Link>
            </div>
          )}
          {preview.length === 0 && !saved ? (
            <div className="flex flex-1 flex-col items-center justify-center gap-2 p-10 text-center text-slate-500">
              <Wand2 className="h-10 w-10 text-slate-300" />
              <p>Chọn dạng bài bên trái rồi bấm “Sinh câu hỏi”.</p>
            </div>
          ) : (
            <ol className="divide-y divide-slate-100">
              {preview.map((q, i) => (
                <li key={`${i}-${q.question_text}`} className="flex gap-3 px-5 py-3 text-sm">
                  <span className="w-6 shrink-0 text-right text-slate-400">{i + 1}.</span>
                  <div className="min-w-0 flex-1">
                    <p className="font-medium text-slate-800">{q.question_text}</p>
                    {q.options ? (
                      <div className="mt-1 flex flex-wrap gap-1">
                        {q.options.map((o) => (
                          <span key={o} className={`chip ${o === q.correct_answer ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'}`}>{o}</span>
                        ))}
                      </div>
                    ) : (
                      <p className="mt-1 text-xs">Đáp án: <b className="text-emerald-700">{q.correct_answer}</b></p>
                    )}
                    {q.explanation && <p className="mt-1 text-xs text-slate-500">💡 {q.explanation}</p>}
                  </div>
                  <div className="flex shrink-0 flex-col items-end gap-1">
                    <DifficultyChip value={q.difficulty} />
                    <TypeChip value={q.question_type} />
                    <button type="button" className="btn btn-ghost btn-icon text-rose-600" aria-label="Bỏ câu này" onClick={() => setPreview((p) => p.filter((_, j) => j !== i))}>
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </li>
              ))}
            </ol>
          )}
        </section>
      </div>
    </div>
  );
}
