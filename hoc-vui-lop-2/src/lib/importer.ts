import { questionKey } from './generators/core';
import { foldVietnamese } from './text';
import type { SheetRow } from './csv';
import type { LessonView, Question, QuestionType, Subject } from '../types';

export interface ParsedQuestion {
  rowNumber: number;
  subjectRaw: string;
  subjectId: string | null;
  subjectCode: string;
  week: number;
  lessonOrder: number;
  lessonName: string;
  lessonId: string | null;
  question: Omit<Partial<Question>, 'lesson_id'> & { question_text: string; correct_answer: string; question_type: QuestionType; difficulty: 1 | 2 | 3 };
  errors: string[];
  duplicate: boolean;
}

const ALIASES: Record<string, string[]> = {
  subject: ['subject', 'mon', 'mon_hoc', 'mon hoc'],
  week: ['week', 'tuan', 'tuan_hoc'],
  lesson: ['lesson', 'bai', 'so_bai', 'lesson_order', 'bai_so'],
  lesson_name: ['lesson_name', 'ten_bai', 'ten bai', 'bai_hoc'],
  difficulty: ['difficulty', 'do_kho', 'muc_do', 'level'],
  type: ['type', 'dang', 'loai', 'dang_cau_hoi', 'question_type'],
  question: ['question', 'cau_hoi', 'noi_dung', 'de_bai', 'question_text'],
  option_a: ['option_a', 'a', 'dap_an_a', 'lua_chon_a'],
  option_b: ['option_b', 'b', 'dap_an_b', 'lua_chon_b'],
  option_c: ['option_c', 'c', 'dap_an_c', 'lua_chon_c'],
  option_d: ['option_d', 'd', 'dap_an_d', 'lua_chon_d'],
  answer: ['answer', 'dap_an', 'dap_an_dung', 'correct_answer', 'ket_qua'],
  accepted_answers: ['accepted_answers', 'dap_an_khac', 'dap_an_chap_nhan'],
  explanation: ['explanation', 'giai_thich', 'huong_dan', 'loi_giai'],
  skill_tag: ['skill_tag', 'ky_nang', 'skill'],
  source_page: ['source_page', 'trang', 'trang_sach'],
  points: ['points', 'diem'],
};

function normKey(k: string): string {
  return foldVietnamese(k).replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
}

export function normalizeRow(row: SheetRow): Record<string, string> {
  const byNorm = new Map<string, string>();
  for (const [k, v] of Object.entries(row)) byNorm.set(normKey(k), String(v ?? '').trim());
  const out: Record<string, string> = {};
  for (const [field, names] of Object.entries(ALIASES)) {
    for (const n of names) {
      const v = byNorm.get(normKey(n));
      if (v !== undefined && v !== '') {
        out[field] = v;
        break;
      }
    }
  }
  return out;
}

export function parseDifficulty(v: string | undefined): 1 | 2 | 3 | null {
  const f = foldVietnamese(v ?? '');
  if (!f) return 1;
  if (['1', 'de', 'easy', 'co ban'].includes(f)) return 1;
  if (['2', 'vua', 'normal', 'trung binh', 'medium', 'tb'].includes(f)) return 2;
  if (['3', 'kho', 'nang cao', 'advanced', 'hard'].includes(f)) return 3;
  return null;
}

export function parseType(v: string | undefined): QuestionType | null {
  const f = foldVietnamese(v ?? '').replace(/[\s_-]+/g, '');
  if (['multiplechoice', 'mcq', 'tracnghiem', 'tn', 'chon'].includes(f)) return 'multiple_choice';
  if (['number', 'so', 'dienso', 'numeric'].includes(f)) return 'number';
  if (['text', 'chu', 'dienchu', 'tu', 'dientu'].includes(f)) return 'text';
  return null;
}

const SUBJECT_ALIASES: Record<string, string> = {
  math: 'toan', maths: 'toan', toan: 'toan',
  vietnamese: 'tieng_viet', tv: 'tieng_viet', tieng_viet: 'tieng_viet', 'tieng viet': 'tieng_viet',
};

export function slugSubject(v: string): string {
  const f = foldVietnamese(v);
  return SUBJECT_ALIASES[f] ?? f.replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
}

export function findSubject(subjects: Subject[], raw: string): Subject | undefined {
  const slug = slugSubject(raw);
  const f = foldVietnamese(raw);
  return subjects.find((s) => s.code === slug || foldVietnamese(s.name) === f || s.code === raw.trim());
}

export function parseRows(
  rows: SheetRow[],
  subjects: Subject[],
  lessons: LessonView[],
  existingKeysByLesson: Map<string, Set<string>>,
): ParsedQuestion[] {
  const seenInFile = new Set<string>();
  return rows.map((raw, i) => {
    const r = normalizeRow(raw);
    const errors: string[] = [];
    const subjectRaw = r.subject ?? '';
    const subject = subjectRaw ? findSubject(subjects, subjectRaw) : undefined;
    if (!subjectRaw) errors.push('Thiếu môn học');

    const week = Number.parseInt(r.week ?? '', 10);
    if (!Number.isFinite(week) || week < 1 || week > 60) errors.push('Tuần phải là số 1–60');
    const lessonOrder = Number.parseInt(r.lesson ?? '', 10);
    if (!Number.isFinite(lessonOrder) || lessonOrder < 0 || lessonOrder > 999) errors.push('Số bài không hợp lệ');

    const lesson = subject
      ? lessons.find((l) => l.subject_id === subject.id && l.week_number === week && l.lesson_order === lessonOrder)
      : undefined;
    const lessonName = r.lesson_name || lesson?.name || '';
    if (!lesson && !lessonName) errors.push('Bài chưa có — cần cột tên bài (lesson_name)');

    const difficulty = parseDifficulty(r.difficulty);
    if (!difficulty) errors.push(`Độ khó "${r.difficulty}" không hợp lệ (1/2/3 hoặc dễ/vừa/khó)`);
    const type = parseType(r.type);
    if (!type) errors.push(`Dạng "${r.type ?? ''}" không hợp lệ (multiple_choice/number/text)`);

    const text = (r.question ?? '').trim();
    if (!text) errors.push('Thiếu nội dung câu hỏi');
    let answer = (r.answer ?? '').trim();
    if (!answer) errors.push('Thiếu đáp án');

    const options = [r.option_a, r.option_b, r.option_c, r.option_d].map((o) => (o ?? '').trim()).filter(Boolean);
    if (type === 'multiple_choice') {
      if (options.length < 2) errors.push('Trắc nghiệm cần ít nhất 2 lựa chọn');
      const letterIdx = ['a', 'b', 'c', 'd'].indexOf(answer.toLowerCase());
      if (answer && !options.includes(answer) && letterIdx >= 0 && options[letterIdx]) answer = options[letterIdx];
      if (answer && options.length >= 2 && !options.includes(answer)) errors.push('Đáp án phải trùng một lựa chọn (hoặc ghi A/B/C/D)');
      if (new Set(options).size !== options.length) errors.push('Các lựa chọn bị trùng nhau');
    }
    if (type === 'number' && answer && !/^-?\d+$/.test(answer.replace(/[\s.,]/g, ''))) errors.push('Đáp án dạng điền số phải là số');

    const accepted = (r.accepted_answers ?? '').split('|').map((s) => s.trim()).filter(Boolean);
    const pageNum = Number.parseInt(r.source_page ?? '', 10);
    const points = Number.parseInt(r.points ?? '', 10);

    const mcqOptions = type === 'multiple_choice' ? options : [];
    const key = questionKey({ question_text: text, options: mcqOptions });
    const fileKey = `${subject?.code ?? slugSubject(subjectRaw)}|${week}|${lessonOrder}|${key}`;
    const duplicate = seenInFile.has(fileKey) || (!!lesson && !!existingKeysByLesson.get(lesson.id)?.has(key));
    seenInFile.add(fileKey);

    return {
      rowNumber: i + 2,
      subjectRaw,
      subjectId: subject?.id ?? null,
      subjectCode: subject?.code ?? slugSubject(subjectRaw),
      week,
      lessonOrder,
      lessonName,
      lessonId: lesson?.id ?? null,
      duplicate,
      errors,
      question: {
        question_text: text,
        question_type: type ?? 'text',
        difficulty: difficulty ?? 1,
        option_a: mcqOptions[0] ?? null,
        option_b: mcqOptions[1] ?? null,
        option_c: mcqOptions[2] ?? null,
        option_d: mcqOptions[3] ?? null,
        correct_answer: answer,
        accepted_answers: accepted.length ? accepted : null,
        explanation: r.explanation || null,
        skill_tag: r.skill_tag || null,
        source_page: Number.isFinite(pageNum) ? pageNum : null,
        points: Number.isFinite(points) ? points : null,
      },
    };
  });
}

export const TEMPLATE_CSV = [
  'subject,week,lesson,lesson_name,difficulty,type,question,option_a,option_b,option_c,option_d,answer,accepted_answers,explanation,source_page',
  'toan,1,1,Ôn tập các số đến 100,1,multiple_choice,8 + 7 = ?,13,14,15,16,15,,Đếm thêm 7 từ 8,12',
  'toan,1,1,Ôn tập các số đến 100,2,number,17 + ___ = 25,,,,,8,,25 - 17 = 8,12',
  'tieng_viet,1,2,Chính tả: c hay k,1,text,Điền c hoặc k: cái ___éo,,,,,k,,Viết k trước e ê i,5',
  'tieng_viet,1,2,Chính tả: c hay k,3,text,Con mèo đang ___ trên ghế.,,,,,nằm,đang nằm|ngủ,,',
].join('\n');
