import { useMemo, useRef, useState } from 'react';
import { Link } from 'react-router';
import { AlertTriangle, CheckCircle2, Download, FileSpreadsheet, Upload, XCircle } from 'lucide-react';
import { DifficultyChip, PageHeader, TypeChip } from '../../components/admin';
import { AdminError, Spinner } from '../../components/ui';
import { adminApi } from '../../lib/api';
import { downloadText, readSpreadsheet } from '../../lib/csv';
import { questionKey } from '../../lib/generators/core';
import { parseRows, TEMPLATE_CSV, type ParsedQuestion } from '../../lib/importer';
import type { Lesson, LessonView, Question, Subject, SubjectColor } from '../../types';

type Stage = 'pick' | 'preview' | 'saving' | 'done';
const CHUNK = 200;
const COLORS: SubjectColor[] = ['blue', 'green', 'amber', 'rose', 'purple'];

export default function ImportPage() {
  const fileRef = useRef<HTMLInputElement>(null);
  const [stage, setStage] = useState<Stage>('pick');
  const [fileName, setFileName] = useState('');
  const [rows, setRows] = useState<ParsedQuestion[]>([]);
  const [context, setContext] = useState<{ subjects: Subject[]; lessons: LessonView[] } | null>(null);
  const [createLessons, setCreateLessons] = useState(true);
  const [publishNew, setPublishNew] = useState(true);
  const [showOnly, setShowOnly] = useState<'all' | 'error' | 'dup'>('all');
  const [progress, setProgress] = useState('');
  const [error, setError] = useState<unknown>(null);
  const [summary, setSummary] = useState<{ questions: number; lessons: number; subjects: number } | null>(null);

  const stats = useMemo(() => {
    const invalid = rows.filter((r) => r.errors.length > 0).length;
    const dup = rows.filter((r) => r.errors.length === 0 && r.duplicate).length;
    const needLesson = rows.filter((r) => r.errors.length === 0 && !r.duplicate && !r.lessonId).length;
    const newSubjects = new Set(rows.filter((r) => r.errors.length === 0 && !r.subjectId).map((r) => r.subjectCode)).size;
    return { invalid, dup, valid: rows.length - invalid - dup, needLesson, newSubjects };
  }, [rows]);

  const importable = rows.filter((r) => r.errors.length === 0 && !r.duplicate && (createLessons || r.lessonId));

  const onFile = async (file: File) => {
    setError(null);
    setFileName(file.name);
    setProgress('Đang đọc file…');
    try {
      const [sheet, subjects, lessons] = await Promise.all([readSpreadsheet(file), adminApi.listSubjects(), adminApi.listLessons()]);
      if (sheet.length === 0) throw new Error('File không có dòng dữ liệu nào (dòng đầu tiên phải là tiêu đề cột).');
      if (sheet.length > 5000) throw new Error('File quá lớn: tối đa 5000 câu mỗi lần nhập.');

      // Lấy câu hỏi hiện có của các bài liên quan để phát hiện trùng.
      const draft = parseRows(sheet, subjects, lessons, new Map());
      const lessonIds = [...new Set(draft.map((r) => r.lessonId).filter((x): x is string => !!x))];
      const keys = new Map<string, Set<string>>();
      for (const id of lessonIds) {
        const existing = await adminApi.questionKeysForLesson(id);
        keys.set(id, new Set(existing.map((q) => questionKey({ question_text: q.question_text, options: [q.option_a, q.option_b, q.option_c, q.option_d] }))));
      }
      setRows(parseRows(sheet, subjects, lessons, keys));
      setContext({ subjects, lessons });
      setStage('preview');
      setShowOnly('all');
    } catch (e) {
      setError(e);
    } finally {
      setProgress('');
      if (fileRef.current) fileRef.current.value = '';
    }
  };

  const doImport = async () => {
    if (!context) return;
    setStage('saving');
    setError(null);
    try {
      // 1) Môn mới
      const subjectByCode = new Map(context.subjects.map((s) => [s.code, s]));
      let createdSubjects = 0;
      for (const r of importable) {
        if (subjectByCode.has(r.subjectCode)) continue;
        setProgress(`Tạo môn "${r.subjectRaw}"…`);
        const [s] = await adminApi.insertSubject({
          code: r.subjectCode,
          name: r.subjectRaw.trim(),
          color: COLORS[(context.subjects.length + createdSubjects) % COLORS.length],
          sort_order: context.subjects.length + createdSubjects + 1,
        });
        subjectByCode.set(s.code, s);
        createdSubjects++;
      }

      // 2) Bài mới
      const lessonKey = (subjectId: string, week: number, order: number) => `${subjectId}|${week}|${order}`;
      const lessonMap = new Map<string, string>(context.lessons.map((l) => [lessonKey(l.subject_id, l.week_number, l.lesson_order), l.id]));
      const toCreate = new Map<string, Partial<Lesson>>();
      for (const r of importable) {
        const sid = subjectByCode.get(r.subjectCode)!.id;
        const k = lessonKey(sid, r.week, r.lessonOrder);
        if (!lessonMap.has(k) && !toCreate.has(k)) {
          toCreate.set(k, { subject_id: sid, week_number: r.week, lesson_order: r.lessonOrder, name: r.lessonName, is_published: publishNew, publish_mode: 'week' });
        }
      }
      if (toCreate.size > 0) {
        setProgress(`Tạo ${toCreate.size} bài học mới…`);
        const created = await adminApi.insertLessons([...toCreate.values()]);
        for (const l of created) lessonMap.set(lessonKey(l.subject_id, l.week_number, l.lesson_order), l.id);
      }

      // 3) Câu hỏi
      const isArchimes = /archimes/i.test(fileName);
      const payload: Partial<Question>[] = importable.map((r) => ({
        ...r.question,
        lesson_id: lessonMap.get(lessonKey(subjectByCode.get(r.subjectCode)!.id, r.week, r.lessonOrder)),
        source_book: isArchimes ? 'Archimes' : fileName.slice(0, 200),
        generator_type: isArchimes ? 'archimes' : 'import',
        is_active: true,
      }));
      for (let i = 0; i < payload.length; i += CHUNK) {
        setProgress(`Đang lưu câu hỏi ${i + 1}–${Math.min(payload.length, i + CHUNK)} / ${payload.length}…`);
        await adminApi.insertQuestions(payload.slice(i, i + CHUNK));
      }
      setSummary({ questions: payload.length, lessons: toCreate.size, subjects: createdSubjects });
      setStage('done');
    } catch (e) {
      setError(e);
      setStage('preview');
    } finally {
      setProgress('');
    }
  };

  const reset = () => {
    setStage('pick');
    setRows([]);
    setSummary(null);
    setError(null);
  };

  const visible = rows.filter((r) => showOnly === 'all' || (showOnly === 'error' ? r.errors.length > 0 : r.duplicate && r.errors.length === 0));

  return (
    <div className="space-y-5">
      <PageHeader
        title="Nhập câu hỏi từ CSV / Excel"
        description="Tải file lên → hệ thống kiểm tra từng dòng → xem trước → bấm lưu. Bài học chưa có sẽ được tạo tự động."
        actions={
          <>
            <button type="button" className="btn btn-secondary" onClick={() => downloadText('mau_nhap_cau_hoi.csv', TEMPLATE_CSV)}>
              <Download className="h-4 w-4" /> File mẫu (5 dòng)
            </button>
            <a className="btn btn-secondary" href="/mau/ngan_hang_cau_hoi_mau.csv" download>
              <FileSpreadsheet className="h-4 w-4" /> Ngân hàng mẫu (~800 câu)
            </a>
          </>
        }
      />

      {error !== null && <AdminError error={error} />}

      {stage === 'pick' && (
        <>
          <label
            className="panel flex cursor-pointer flex-col items-center gap-3 border-2 border-dashed border-slate-300 p-10 text-center hover:border-blue-400 hover:bg-blue-50/40"
            onDragOver={(e) => e.preventDefault()}
            onDrop={(e) => {
              e.preventDefault();
              const f = e.dataTransfer.files[0];
              if (f) void onFile(f);
            }}
          >
            {progress ? <Spinner className="h-10 w-10" /> : <Upload className="h-10 w-10 text-blue-600" />}
            <span className="font-semibold text-slate-800">{progress || 'Bấm để chọn file hoặc kéo thả vào đây'}</span>
            <span className="text-sm text-slate-500">Hỗ trợ .csv (UTF-8), .xlsx, .xls — tối đa 5000 dòng</span>
            <input ref={fileRef} type="file" accept=".csv,.xlsx,.xls,.ods,text/csv" className="sr-only" onChange={(e) => e.target.files?.[0] && onFile(e.target.files[0])} />
          </label>

          <section className="panel p-5 text-sm text-slate-700">
            <h2 className="mb-3 font-semibold text-slate-900">Cấu trúc file</h2>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead><tr><th className="th">Cột</th><th className="th">Ý nghĩa</th><th className="th">Ví dụ</th></tr></thead>
                <tbody>
                  {[
                    ['subject', 'Mã hoặc tên môn', 'toan, tieng_viet, Toán'],
                    ['week', 'Tuần học (1–35)', '3'],
                    ['lesson', 'Số thứ tự bài', '5'],
                    ['lesson_name', 'Tên bài (bắt buộc nếu bài chưa có)', 'Phép cộng có nhớ'],
                    ['difficulty', 'Độ khó', '1 / 2 / 3 hoặc dễ / vừa / khó'],
                    ['type', 'Dạng câu hỏi', 'multiple_choice / number / text (hoặc: trắc nghiệm / số / chữ)'],
                    ['question', 'Nội dung — dùng ___ làm ô trống', '38 + ___ = 45'],
                    ['option_a … option_d', 'Các lựa chọn (chỉ trắc nghiệm)', '5, 6, 7, 8'],
                    ['answer', 'Đáp án đúng (trắc nghiệm có thể ghi A/B/C/D)', '7 hoặc C'],
                    ['accepted_answers', 'Các đáp án khác cũng đúng, cách nhau bởi |', 'bảy|7'],
                    ['explanation', 'Giải thích sau khi trả lời (không bắt buộc)', '45 - 38 = 7'],
                    ['source_page', 'Trang sách (không bắt buộc)', '24'],
                  ].map(([c, m, ex]) => (
                    <tr key={c} className="border-t border-slate-100"><td className="td font-mono">{c}</td><td className="td">{m}</td><td className="td text-slate-500">{ex}</td></tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p className="mt-3 text-xs text-slate-500">Tên cột có thể viết tiếng Việt: mon, tuan, bai, ten_bai, do_kho, dang, cau_hoi, a, b, c, d, dap_an, giai_thich…</p>
          </section>
        </>
      )}

      {(stage === 'preview' || stage === 'saving') && (
        <>
          <div className="grid gap-3 sm:grid-cols-3">
            <button type="button" onClick={() => setShowOnly('all')} className={`panel flex items-center gap-3 p-4 text-left ${showOnly === 'all' ? 'ring-2 ring-blue-500' : ''}`}>
              <CheckCircle2 className="h-8 w-8 text-emerald-500" />
              <div><p className="text-2xl font-bold">{stats.valid}</p><p className="text-sm text-slate-500">câu hợp lệ sẽ được lưu</p></div>
            </button>
            <button type="button" onClick={() => setShowOnly('error')} className={`panel flex items-center gap-3 p-4 text-left ${showOnly === 'error' ? 'ring-2 ring-blue-500' : ''}`}>
              <XCircle className="h-8 w-8 text-rose-500" />
              <div><p className="text-2xl font-bold">{stats.invalid}</p><p className="text-sm text-slate-500">dòng lỗi (bỏ qua)</p></div>
            </button>
            <button type="button" onClick={() => setShowOnly('dup')} className={`panel flex items-center gap-3 p-4 text-left ${showOnly === 'dup' ? 'ring-2 ring-blue-500' : ''}`}>
              <AlertTriangle className="h-8 w-8 text-amber-500" />
              <div><p className="text-2xl font-bold">{stats.dup}</p><p className="text-sm text-slate-500">câu trùng (bỏ qua)</p></div>
            </button>
          </div>

          <div className="panel flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-1 text-sm">
              <p><b>{fileName}</b> — {rows.length} dòng</p>
              <label className="flex items-center gap-2">
                <input type="checkbox" checked={createLessons} onChange={(e) => setCreateLessons(e.target.checked)} />
                Tự tạo bài học chưa có ({stats.needLesson} câu thuộc bài mới{stats.newSubjects > 0 && `, ${stats.newSubjects} môn mới`})
              </label>
              <label className="flex items-center gap-2">
                <input type="checkbox" checked={publishNew} onChange={(e) => setPublishNew(e.target.checked)} disabled={!createLessons} />
                Công bố bài mới (mở theo tuần)
              </label>
            </div>
            <div className="flex gap-2">
              <button type="button" className="btn btn-secondary" onClick={reset} disabled={stage === 'saving'}>Chọn file khác</button>
              <button type="button" className="btn btn-primary" onClick={doImport} disabled={stage === 'saving' || importable.length === 0}>
                {stage === 'saving' && <Spinner className="h-4 w-4 text-white" />} Lưu {importable.length} câu hỏi
              </button>
            </div>
          </div>
          {progress && <p className="text-sm text-blue-700">{progress}</p>}

          <div className="panel overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr><th className="th">Dòng</th><th className="th">Trạng thái</th><th className="th">Bài</th><th className="th">Phân loại</th><th className="th">Câu hỏi</th><th className="th">Đáp án</th></tr>
              </thead>
              <tbody>
                {visible.slice(0, 500).map((r) => (
                  <tr key={r.rowNumber} className={`border-t border-slate-100 align-top ${r.errors.length ? 'bg-rose-50/50' : r.duplicate ? 'bg-amber-50/50' : ''}`}>
                    <td className="td text-slate-400">{r.rowNumber}</td>
                    <td className="td">
                      {r.errors.length > 0 ? (
                        <ul className="space-y-0.5 text-xs text-rose-700">{r.errors.map((e) => <li key={e}>• {e}</li>)}</ul>
                      ) : r.duplicate ? (
                        <span className="text-xs text-amber-700">Trùng câu đã có</span>
                      ) : (
                        <span className="text-xs text-emerald-700">{r.lessonId ? 'Hợp lệ' : 'Hợp lệ · bài mới'}</span>
                      )}
                    </td>
                    <td className="td whitespace-nowrap text-xs text-slate-600">
                      {r.subjectRaw} · T{Number.isFinite(r.week) ? r.week : '?'} · B{Number.isFinite(r.lessonOrder) ? r.lessonOrder : '?'}
                      <br /><span className="text-slate-400">{r.lessonName}</span>
                    </td>
                    <td className="td"><div className="flex flex-col items-start gap-1"><DifficultyChip value={r.question.difficulty} /><TypeChip value={r.question.question_type} /></div></td>
                    <td className="td max-w-sm">
                      {r.question.question_text}
                      {r.question.option_a && (
                        <p className="mt-1 text-xs text-slate-500">
                          {[r.question.option_a, r.question.option_b, r.question.option_c, r.question.option_d].filter(Boolean).join(' · ')}
                        </p>
                      )}
                    </td>
                    <td className="td font-semibold text-emerald-700">{r.question.correct_answer}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {visible.length > 500 && <p className="p-3 text-center text-xs text-slate-500">Chỉ hiển thị 500 dòng đầu.</p>}
          </div>
        </>
      )}

      {stage === 'done' && summary && (
        <div className="panel flex flex-col items-center gap-3 p-10 text-center">
          <CheckCircle2 className="h-14 w-14 text-emerald-500" />
          <h2 className="text-xl font-bold text-slate-900">Đã lưu {summary.questions} câu hỏi</h2>
          <p className="text-slate-600">
            {summary.lessons > 0 && `Tạo mới ${summary.lessons} bài học. `}
            {summary.subjects > 0 && `Tạo mới ${summary.subjects} môn học. `}
          </p>
          <div className="flex gap-2">
            <button type="button" className="btn btn-secondary" onClick={reset}>Nhập file khác</button>
            <Link to="/admin/questions" className="btn btn-primary">Xem ngân hàng câu hỏi</Link>
            <Link to="/admin/lessons" className="btn btn-secondary">Xem bài học</Link>
          </div>
        </div>
      )}
    </div>
  );
}
