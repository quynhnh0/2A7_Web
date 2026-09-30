// NGÂN HÀNG CÂU HỎI ARCHIMES — soạn theo bộ phiếu bài tập Archimedes School (Toán 2, Tiếng Việt 2).
// Nguồn: data/archimes/*.json  =>  supabase/archimes.sql + data/archimes.csv
// Chạy: npm run archimes:build          (kiểm tra + sinh file)
//       npm run archimes:check -- toan1 (chỉ kiểm tra 1 file, không ghi gì)
import { existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

type Subject = 'toan' | 'tieng_viet';
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
  page?: number;
  check?: string;
}

interface RawWeek {
  week: number;
  title: string;
  questions: RawQuestion[];
}

interface RawBook {
  subject: Subject;
  book: string;
  weeks: RawWeek[];
}

export const BANK_NAME = 'Archimes';
export const LESSON_ORDER = 100;
const MIN_PER_WEEK = { total: 20, easy: 8, normal: 6, advanced: 6 };

const root = new URL('..', import.meta.url);
const srcDir = new URL('data/archimes/', root);

const norm = (s: string) => s.normalize('NFC').trim().replace(/\s+/g, ' ');
const fold = (s: string) => norm(s).toLocaleLowerCase('vi').replace(/[.!?,;:]+$/, '');
const sqlStr = (v: string | number | null | undefined) =>
  v === null || v === undefined || v === '' ? 'null' : `'${String(v).replace(/'/g, "''")}'`;
const csvCell = (v: string | number | null | undefined) => {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};

/** Tính biểu thức số học đơn giản của lớp 2: + - × x * : / ( ). */
export function evalArithmetic(expr: string): number | null {
  const src = expr.replace(/[×xX]/g, '*').replace(/:/g, '/').replace(/\s+/g, '');
  if (!/^[0-9+\-*/()]+$/.test(src)) return null;
  let i = 0;
  const peek = () => src[i];
  const num = (): number => {
    if (peek() === '(') { i++; const v = add(); if (src[i++] !== ')') throw new Error('thiếu )'); return v; }
    const m = /^\d+/.exec(src.slice(i));
    if (!m) throw new Error('cần số tại vị trí ' + i);
    i += m[0].length;
    return Number(m[0]);
  };
  const mul = (): number => {
    let v = num();
    while (peek() === '*' || peek() === '/') {
      const op = src[i++]; const r = num();
      if (op === '*') v *= r;
      else { if (r === 0 || v % r !== 0) throw new Error('chia không hết'); v /= r; }
    }
    return v;
  };
  const add = (): number => {
    let v = mul();
    while (peek() === '+' || peek() === '-') { const op = src[i++]; const r = mul(); v = op === '+' ? v + r : v - r; }
    return v;
  };
  try {
    const v = add();
    return i === src.length ? v : null;
  } catch {
    return null;
  }
}

interface Issue { where: string; msg: string }

export function validateBook(book: RawBook, file: string): Issue[] {
  const issues: Issue[] = [];
  const err = (where: string, msg: string) => issues.push({ where: `${file} ${where}`, msg });
  if (book.subject !== 'toan' && book.subject !== 'tieng_viet') err('', `subject phải là "toan" hoặc "tieng_viet"`);
  if (!book.book) err('', 'thiếu "book"');
  if (!Array.isArray(book.weeks) || book.weeks.length === 0) { err('', 'thiếu "weeks"'); return issues; }
  const seenWeeks = new Set<number>();
  for (const w of book.weeks) {
    const W = `tuần ${w.week}`;
    if (!Number.isInteger(w.week) || w.week < 1 || w.week > 60) err(W, 'week phải từ 1–60');
    if (seenWeeks.has(w.week)) err(W, 'tuần bị lặp');
    seenWeeks.add(w.week);
    if (!w.title || norm(w.title).length < 2 || norm(w.title).length > 150) err(W, 'title 2–150 ký tự');
    const qs = w.questions ?? [];
    const c = { 1: 0, 2: 0, 3: 0 };
    const keys = new Set<string>();
    qs.forEach((q, idx) => {
      const Q = `${W} câu ${idx + 1}`;
      if (![1, 2, 3].includes(q.d)) err(Q, 'd phải là 1, 2 hoặc 3');
      else c[q.d]++;
      if (!['mcq', 'number', 'text'].includes(q.type)) err(Q, 'type phải là mcq | number | text');
      const text = typeof q.q === 'string' ? q.q.normalize('NFC').trim() : '';
      if (text.length < 5 || text.length > 700) err(Q, `q dài ${text.length} (cần 5–700)`);
      const ans = q.answer === undefined || q.answer === null ? '' : String(q.answer).normalize('NFC').trim();
      if (!ans || ans.length > 200) err(Q, 'answer rỗng hoặc quá dài');
      if (q.explain && q.explain.length > 600) err(Q, 'explain quá dài (>600)');
      if (q.page !== undefined && (!Number.isInteger(q.page) || q.page < 1 || q.page > 200)) err(Q, 'page không hợp lệ');
      if (q.skill && !/^[a-z0-9_]{2,40}$/.test(q.skill)) err(Q, 'skill phải là snake_case không dấu');
      const acc = (q.accepted ?? []).map((a) => String(a).normalize('NFC').trim());
      if (q.type === 'mcq') {
        const opts = (q.options ?? []).map((o) => String(o).normalize('NFC').trim());
        if (opts.length < 2 || opts.length > 4) err(Q, `mcq cần 2–4 lựa chọn (đang có ${opts.length})`);
        if (opts.some((o) => !o || o.length > 200)) err(Q, 'lựa chọn rỗng hoặc quá dài');
        if (new Set(opts.map(fold)).size !== opts.length) err(Q, 'lựa chọn bị trùng');
        if (!opts.some((o) => fold(o) === fold(ans))) err(Q, `đáp án "${ans}" không nằm trong lựa chọn`);
        if (acc.length) err(Q, 'mcq không dùng accepted');
      }
      if (q.type === 'number') {
        if (!/^\d+$/.test(ans)) err(Q, `đáp án số phải là số nguyên không âm: "${ans}"`);
        if (acc.some((a) => !/^\d+$/.test(a))) err(Q, 'accepted của câu số phải là số');
        if (q.options?.length) err(Q, 'câu số không có options');
      }
      if (q.type === 'text') {
        if (ans.length > 60) err(Q, 'đáp án chữ nên ngắn (≤ 60 ký tự) để chấm tự động chính xác');
        if (q.options?.length) err(Q, 'câu chữ không có options');
      }
      if (q.check !== undefined) {
        const v = evalArithmetic(q.check);
        if (v === null) err(Q, `check "${q.check}" không tính được`);
        else if (String(v) !== ans.replace(/\s/g, '')) err(Q, `check "${q.check}" = ${v} nhưng đáp án là "${ans}"`);
      }
      const key = fold(text) + '|' + (q.options ?? []).map((o) => fold(String(o))).join('¦');
      if (keys.has(key)) err(Q, 'câu hỏi trùng trong cùng tuần');
      keys.add(key);
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
  if (!books.length) { console.error('Không tìm thấy file nguồn trong data/archimes/'); process.exit(1); }

  const issues = books.flatMap(({ file, book }) => validateBook(book, file));
  for (const b of books) {
    const n = b.book.weeks.reduce((s, w) => s + (w.questions?.length ?? 0), 0);
    console.log(`  ${b.file}: ${b.book.weeks.length} tuần, ${n} câu`);
  }
  if (issues.length) {
    for (const i of issues.slice(0, 200)) console.error(`✗ ${i.where}: ${i.msg}`);
    console.error(`\n${issues.length} lỗi.`);
    process.exit(1);
  }
  if (checkOnly) { console.log('✓ Hợp lệ.'); return; }

  const weeksBySubject = new Map<string, RawWeek>();
  for (const { book } of books) {
    for (const w of book.weeks) {
      const k = `${book.subject}:${w.week}`;
      if (weeksBySubject.has(k)) { console.error(`✗ ${book.subject} tuần ${w.week} xuất hiện ở nhiều file`); process.exit(1); }
      weeksBySubject.set(k, w);
    }
  }

  const sql: string[] = [`-- =====================================================================
-- NGÂN HÀNG CÂU HỎI "${BANK_NAME}" (tự sinh bởi scripts/build-archimes.ts — đừng sửa tay,
-- hãy sửa data/archimes/*.json rồi chạy: npm run archimes:build).
-- Soạn theo bộ phiếu bài tập Archimedes School: Toán 2 và Tiếng Việt 2, tuần 1–35.
-- Mỗi tuần, mỗi môn là 1 bài "${BANK_NAME}: …" (lesson_order = ${LESSON_ORDER}), mở theo tuần hiện tại.
-- Chạy SAU 0001_init.sql (và seed.sql nếu có). Chạy lại nhiều lần không tạo trùng.
-- =====================================================================

insert into public.subjects (code, name, color, sort_order) values
  ('toan', 'Toán', 'blue', 1),
  ('tieng_viet', 'Tiếng Việt', 'green', 2)
on conflict (code) do nothing;
`];
  const csv: string[] = [
    'subject,week,lesson,lesson_name,difficulty,type,question,option_a,option_b,option_c,option_d,answer,accepted_answers,explanation,skill_tag,source_page',
  ];
  let total = 0;
  let lessonCount = 0;

  for (const { book } of books) {
    for (const w of [...book.weeks].sort((a, b) => a.week - b.week)) {
      lessonCount++;
      const name = `${BANK_NAME}: ${norm(w.title)}`;
      const description = `Ngân hàng ${BANK_NAME} — ${book.book}, tuần ${w.week}`;
      const rows = w.questions.map((q) => {
        const o = (q.options ?? []).map((x) => String(x).normalize('NFC').trim());
        const answerRaw = String(q.answer).normalize('NFC').trim();
        const answer = q.type === 'mcq' ? o.find((x) => fold(x) === fold(answerRaw)) ?? answerRaw : answerRaw;
        const acc = (q.accepted ?? []).map((a) => String(a).normalize('NFC').trim()).filter((a) => a && fold(a) !== fold(answer));
        return { q, o, answer, acc, text: q.q.normalize('NFC').trim() };
      });
      total += rows.length;

      sql.push(`
-- ${book.subject === 'toan' ? 'Toán' : 'Tiếng Việt'} • Tuần ${w.week}: ${norm(w.title)} (${rows.length} câu)
insert into public.lessons (subject_id, week_number, lesson_order, name, description, is_published, publish_mode)
select id, ${w.week}, ${LESSON_ORDER}, ${sqlStr(name)}, ${sqlStr(description)}, true, 'week' from public.subjects where code = '${book.subject}'
on conflict (subject_id, week_number, lesson_order) do nothing;

insert into public.questions (lesson_id, difficulty, question_type, question_text, option_a, option_b, option_c, option_d,
                              correct_answer, accepted_answers, explanation, skill_tag, source_book, source_page, generator_type)
select l.id, v.difficulty, v.question_type, v.question_text, v.option_a, v.option_b, v.option_c, v.option_d,
       v.correct_answer, v.accepted_answers, v.explanation, v.skill_tag, ${sqlStr(BANK_NAME)}, v.source_page, 'archimes'
  from public.lessons l
  join public.subjects s on s.id = l.subject_id and s.code = '${book.subject}'
  cross join (values
${rows.map(({ q, o, answer, acc, text }) => {
    const accSql = acc.length ? `'${JSON.stringify(acc).replace(/'/g, "''")}'::jsonb` : 'null::jsonb';
    return `    (${q.d}::smallint, '${TYPE_MAP[q.type]}', ${sqlStr(text)}, ${sqlStr(o[0])}, ${sqlStr(o[1])}, ${sqlStr(o[2])}, ${sqlStr(o[3])}, ${sqlStr(answer)}, ${accSql}, ${sqlStr(q.explain?.trim())}, ${sqlStr(q.skill)}, ${q.page ?? 'null'}::int)`;
  }).join(',\n')}
  ) as v(difficulty, question_type, question_text, option_a, option_b, option_c, option_d, correct_answer, accepted_answers, explanation, skill_tag, source_page)
 where l.week_number = ${w.week} and l.lesson_order = ${LESSON_ORDER}
   and not exists (select 1 from public.questions q where q.lesson_id = l.id and q.generator_type = 'archimes');
`);

      for (const { q, o, answer, acc, text } of rows) {
        csv.push([
          book.subject, w.week, LESSON_ORDER, name, q.d, TYPE_MAP[q.type], text,
          o[0], o[1], o[2], o[3], answer, acc.join('|'), q.explain?.trim(), q.skill, q.page,
        ].map(csvCell).join(','));
      }
    }
  }

  // Không ghi vào public/: file có đáp án, không được để học sinh tải về từ web.
  writeFileSync(new URL('supabase/archimes.sql', root), sql.join(''));
  writeFileSync(new URL('data/archimes.csv', root), '\ufeff' + csv.join('\n') + '\n');
  console.log(`✓ ${BANK_NAME}: ${lessonCount} bài, ${total} câu hỏi => supabase/archimes.sql, data/archimes.csv`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
