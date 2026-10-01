// NGÂN HÀNG "KỸ NĂNG SỐNG" và "KHOA HỌC" cho học sinh lớp 2 (tự soạn).
// Nguồn: data/kien_thuc/*.json  =>  supabase/ky_nang_khoa_hoc.sql + data/ky_nang_khoa_hoc.csv
// Chạy: npm run kienthuc:build            (kiểm tra + sinh file)
//       npm run kienthuc:check -- kns_1   (chỉ kiểm tra 1 file, không ghi gì)
import { existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

type RawType = 'mcq' | 'number' | 'text';

interface RawQuestion {
  d: 1 | 2 | 3;
  type: RawType;
  q: string;
  options?: string[];
  answer: string | number;
  accepted?: (string | number)[];
  explain?: string;
  skill?: string;
}

interface RawWeek {
  week: number;
  title: string;
  questions: RawQuestion[];
}

interface RawBook {
  subject: string;
  weeks: RawWeek[];
}

export const SUBJECTS: Record<string, { name: string; color: string; sort: number; source: string }> = {
  ky_nang_song: { name: 'Kỹ năng sống', color: 'amber', sort: 3, source: 'Học Vui — Kỹ năng sống' },
  khoa_hoc: { name: 'Khoa học', color: 'purple', sort: 4, source: 'Học Vui — Khoa học' },
};
const MIN_PER_WEEK = { total: 22, easy: 8, normal: 6, advanced: 6 };

const root = new URL('..', import.meta.url);
const srcDir = new URL('data/kien_thuc/', root);

const norm = (s: string) => s.normalize('NFC').trim().replace(/\s+/g, ' ');
const fold = (s: string) => norm(s).toLocaleLowerCase('vi').replace(/[.!?,;:]+$/, '');
const sqlStr = (v: string | number | null | undefined) =>
  v === null || v === undefined || v === '' ? 'null' : `'${String(v).replace(/'/g, "''")}'`;
const csvCell = (v: string | number | null | undefined) => {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};

interface Issue { where: string; msg: string }

export function validateBook(book: RawBook, file: string, seen: Map<string, string>): Issue[] {
  const issues: Issue[] = [];
  const err = (where: string, msg: string) => issues.push({ where: `${file} ${where}`, msg });
  if (!SUBJECTS[book.subject]) err('', `subject phải là ${Object.keys(SUBJECTS).join(' | ')}`);
  if (!Array.isArray(book.weeks) || book.weeks.length === 0) { err('', 'thiếu "weeks"'); return issues; }
  for (const w of book.weeks) {
    const W = `bài ${w.week}`;
    if (!Number.isInteger(w.week) || w.week < 1 || w.week > 60) err(W, 'week phải từ 1–60');
    if (!w.title || norm(w.title).length < 2 || norm(w.title).length > 150) err(W, 'title 2–150 ký tự');
    const qs = w.questions ?? [];
    const c = { 1: 0, 2: 0, 3: 0 };
    qs.forEach((q, idx) => {
      const Q = `${W} câu ${idx + 1}`;
      if (![1, 2, 3].includes(q.d)) err(Q, 'd phải là 1, 2 hoặc 3');
      else c[q.d]++;
      if (!['mcq', 'number', 'text'].includes(q.type)) err(Q, 'type phải là mcq | number | text');
      const text = typeof q.q === 'string' ? norm(q.q) : '';
      if (text.length < 5 || text.length > 700) err(Q, `q dài ${text.length} (cần 5–700)`);
      const ans = q.answer === undefined || q.answer === null ? '' : norm(String(q.answer));
      if (!ans || ans.length > 200) err(Q, 'answer rỗng hoặc quá dài');
      if (!q.explain || q.explain.length < 5) err(Q, 'thiếu explain (lời giải thích cho bé)');
      else if (q.explain.length > 600) err(Q, 'explain quá dài (>600)');
      if (q.skill && !/^[a-z0-9_]{2,40}$/.test(q.skill)) err(Q, 'skill phải là snake_case không dấu');
      const acc = (q.accepted ?? []).map((a) => norm(String(a)));
      if (q.type === 'mcq') {
        const opts = (q.options ?? []).map((o) => norm(String(o)));
        if (opts.length < 2 || opts.length > 4) err(Q, `mcq cần 2–4 lựa chọn (đang có ${opts.length})`);
        if (opts.some((o) => !o || o.length > 200)) err(Q, 'lựa chọn rỗng hoặc quá dài');
        if (new Set(opts.map(fold)).size !== opts.length) err(Q, 'lựa chọn bị trùng');
        if (opts.filter((o) => fold(o) === fold(ans)).length !== 1) err(Q, `đáp án "${ans}" phải khớp đúng 1 lựa chọn`);
        if (opts.some((o) => /tất cả|cả [a-d] và|cả hai đáp án/i.test(o))) err(Q, 'không dùng lựa chọn "tất cả các ý trên" (thứ tự lựa chọn bị xáo trộn)');
        if (acc.length) err(Q, 'mcq không dùng accepted');
      }
      if (q.type === 'number') {
        if (!/^\d+$/.test(ans)) err(Q, `đáp án số phải là số nguyên không âm: "${ans}"`);
        if (acc.some((a) => !/^\d+$/.test(a))) err(Q, 'accepted của câu số phải là số');
        if (q.options?.length) err(Q, 'câu số không có options');
      }
      if (q.type === 'text') {
        if (ans.length > 30 || ans.split(' ').length > 3) err(Q, 'đáp án chữ phải ngắn (≤ 3 từ) để chấm tự động chính xác');
        if (q.options?.length) err(Q, 'câu chữ không có options');
      }
      const key = `${book.subject}|${fold(text)}|${(q.options ?? []).map((o) => fold(String(o))).sort().join('¦')}`;
      const prev = seen.get(key);
      if (prev) err(Q, `câu hỏi trùng với ${prev}`);
      else seen.set(key, `${file} ${Q}`);
    });
    if (qs.length < MIN_PER_WEEK.total) err(W, `chỉ có ${qs.length} câu (cần ≥ ${MIN_PER_WEEK.total})`);
    if (c[1] < MIN_PER_WEEK.easy) err(W, `mức Dễ chỉ có ${c[1]} câu (cần ≥ ${MIN_PER_WEEK.easy})`);
    if (c[2] < MIN_PER_WEEK.normal) err(W, `mức Vừa chỉ có ${c[2]} câu (cần ≥ ${MIN_PER_WEEK.normal})`);
    if (c[3] < MIN_PER_WEEK.advanced) err(W, `mức Khó chỉ có ${c[3]} câu (cần ≥ ${MIN_PER_WEEK.advanced})`);
  }
  return issues;
}

const TYPE_MAP: Record<RawType, 'multiple_choice' | 'number' | 'text'> = { mcq: 'multiple_choice', number: 'number', text: 'text' };

function loadBooks(only?: string): { file: string; book: RawBook }[] {
  if (!existsSync(srcDir)) return [];
  return readdirSync(srcDir)
    .filter((f) => f.endsWith('.json') && (!only || f === `${only}.json` || f === only))
    .sort()
    .map((file) => ({ file, book: JSON.parse(readFileSync(new URL(file, srcDir), 'utf8')) as RawBook }));
}

function main() {
  const args = process.argv.slice(2);
  const checkOnly = args.includes('--check');
  const only = args.find((a) => !a.startsWith('--'));
  const books = loadBooks(only);
  if (!books.length) { console.error('Không tìm thấy file nguồn trong data/kien_thuc/'); process.exit(1); }

  const seen = new Map<string, string>();
  const issues = books.flatMap(({ file, book }) => validateBook(book, file, seen));
  const weekKeys = new Map<string, string>();
  for (const { file, book } of books) {
    const n = book.weeks.reduce((s, w) => s + (w.questions?.length ?? 0), 0);
    console.log(`  ${file}: ${book.subject}, ${book.weeks.length} bài, ${n} câu`);
    for (const w of book.weeks) {
      const k = `${book.subject}:${w.week}`;
      if (weekKeys.has(k)) issues.push({ where: file, msg: `${book.subject} bài ${w.week} đã có ở ${weekKeys.get(k)}` });
      weekKeys.set(k, file);
    }
  }
  if (issues.length) {
    for (const i of issues.slice(0, 200)) console.error(`✗ ${i.where}: ${i.msg}`);
    console.error(`\n${issues.length} lỗi.`);
    process.exit(1);
  }
  if (checkOnly) { console.log('✓ Hợp lệ.'); return; }

  const sql: string[] = [`-- =====================================================================
-- NGÂN HÀNG "KỸ NĂNG SỐNG" và "KHOA HỌC" lớp 2 (tự sinh bởi scripts/build-kien-thuc.ts — đừng sửa tay,
-- hãy sửa data/kien_thuc/*.json rồi chạy: npm run kienthuc:build).
-- Mỗi môn 20 bài theo chủ đề, mỗi bài mở theo tuần (bài N = tuần N, lesson_order = N). Thầy cô đổi lịch trong "Bài học & lịch mở".
-- Chạy SAU 0001_init.sql. Chạy lại nhiều lần không tạo trùng.
-- =====================================================================

insert into public.subjects (code, name, color, sort_order) values
${Object.entries(SUBJECTS).map(([code, s]) => `  (${sqlStr(code)}, ${sqlStr(s.name)}, ${sqlStr(s.color)}, ${s.sort})`).join(',\n')}
on conflict (code) do nothing;
`];
  const csv: string[] = [
    'subject,week,lesson,lesson_name,difficulty,type,question,option_a,option_b,option_c,option_d,answer,accepted_answers,explanation,skill_tag',
  ];
  const stats = new Map<string, { lessons: number; questions: number }>();

  const ordered = books.flatMap(({ book }) => book.weeks.map((w) => ({ subject: book.subject, w })))
    .sort((a, b) => SUBJECTS[a.subject].sort - SUBJECTS[b.subject].sort || a.w.week - b.w.week);

  for (const { subject, w } of ordered) {
    const meta = SUBJECTS[subject];
    const name = norm(w.title);
    const rows = w.questions.map((q) => {
      const o = (q.options ?? []).map((x) => norm(String(x)));
      const answerRaw = norm(String(q.answer));
      const answer = q.type === 'mcq' ? o.find((x) => fold(x) === fold(answerRaw)) ?? answerRaw : answerRaw;
      const acc = (q.accepted ?? []).map((a) => norm(String(a))).filter((a) => a && fold(a) !== fold(answer));
      return { q, o, answer, acc, text: norm(q.q) };
    });
    const st = stats.get(subject) ?? { lessons: 0, questions: 0 };
    st.lessons++;
    st.questions += rows.length;
    stats.set(subject, st);

    sql.push(`
-- ${meta.name} • Bài ${w.week}: ${name} (${rows.length} câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, ${w.week}, ${w.week}, ${sqlStr(name)}, ${sqlStr(`${meta.source}, bài ${w.week}`)}, true, 'week' from public.subjects where code = '${subject}'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, ${sqlStr(meta.source)}, '${subject}'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = '${subject}'
  cross join (values
${rows.map(({ q, o, answer, acc, text }) => {
    const accSql = acc.length ? `'${JSON.stringify(acc).replace(/'/g, "''")}'::jsonb` : 'null::jsonb';
    return `    (${q.d}::smallint, '${TYPE_MAP[q.type]}', ${sqlStr(text)}, ${sqlStr(o[0])}, ${sqlStr(o[1])}, ${sqlStr(o[2])}, ${sqlStr(o[3])}, ${sqlStr(answer)}, ${accSql}, ${sqlStr(q.explain?.trim())}, ${sqlStr(q.skill)})`;
  }).join(',\n')}
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag)
 where l.week_number = ${w.week} and l.lesson_order = ${w.week}
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = '${subject}');
`);

    for (const { q, o, answer, acc, text } of rows) {
      csv.push([
        subject, w.week, w.week, name, q.d, TYPE_MAP[q.type], text,
        o[0], o[1], o[2], o[3], answer, acc.join('|'), q.explain?.trim(), q.skill,
      ].map(csvCell).join(','));
    }
  }

  // Không ghi vào public/: file có đáp án, không được để học sinh tải về từ web.
  writeFileSync(new URL('supabase/ky_nang_khoa_hoc.sql', root), sql.join(''));
  writeFileSync(new URL('data/ky_nang_khoa_hoc.csv', root), '\ufeff' + csv.join('\n') + '\n');
  for (const [subject, s] of stats) console.log(`✓ ${SUBJECTS[subject].name}: ${s.lessons} bài, ${s.questions} câu`);
  console.log('=> supabase/ky_nang_khoa_hoc.sql, data/ky_nang_khoa_hoc.csv');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
