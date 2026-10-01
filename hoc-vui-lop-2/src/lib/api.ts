import { getBackend, type BackendError, type Filter, type Row, type SelectOptions } from './backend';
import type {
  AdminDashboard, AdminSubjectStats, AnswerResult, AppSettings, AttemptPayload, AttemptResult, AttemptView, ExerciseType, Leaderboard,
  Lesson, LessonView, Period, PublicConfig, Question, QuestionView, StudentHome, StudentIdentity, StudentStats, Subject,
  StatsPeriod, VerifyStudentResult,
} from '../types';

const rpc = async <T>(fn: string, args?: Row) => (await getBackend()).rpc<T>(fn, args);
const select = async <T>(table: string, opts?: SelectOptions) => (await getBackend()).select<T>(table, opts);
const insert = async <T>(table: string, rows: Row[]) => (await getBackend()).insert<T>(table, rows);
const update = async <T>(table: string, patch: Row, filters: Filter[]) => (await getBackend()).update<T>(table, patch, filters);
const remove = async (table: string, filters: Filter[]) => (await getBackend()).remove(table, filters);

/** Database chưa chạy 0004 => tab "Tất cả môn" vẫn dùng được hàm xếp hạng cũ. */
async function leaderboard(period: Period, subjectId: string | null, studentId: string | null) {
  try {
    return await rpc<Leaderboard>('get_subject_leaderboard', { p_period: period, p_subject_id: subjectId, p_student_id: studentId });
  } catch (e) {
    if (subjectId || (e as BackendError).code !== 'missing_function') throw e;
    console.warn('[api] Chưa có get_subject_leaderboard (chưa chạy 0004_subject_stats.sql) — dùng get_leaderboard.');
    return rpc<Leaderboard>('get_leaderboard', { p_period: period, p_student_id: studentId });
  }
}

// ---------------- Học sinh
export const studentApi = {
  getConfig: () => rpc<PublicConfig>('get_public_config'),
  listStudents: () => rpc<StudentIdentity[]>('list_students'),
  register: (fullName: string) => rpc<StudentIdentity>('register_student', { p_full_name: fullName }),
  verifyBirthday: (studentId: string, day: number, month: number) =>
    rpc<VerifyStudentResult>('verify_student', { p_student_id: studentId, p_day: day, p_month: month }),
  getHome: (studentId: string) => rpc<StudentHome>('get_student_home', { p_student_id: studentId }),
  startAttempt: (studentId: string, lessonId: string, type: ExerciseType, deviceToken: string) =>
    rpc<AttemptPayload>('start_attempt', { p_student_id: studentId, p_lesson_id: lessonId, p_exercise_type: type, p_device_token: deviceToken }),
  submitAnswer: (attemptId: string, questionId: string, answer: string) =>
    rpc<AnswerResult>('submit_answer', { p_attempt_id: attemptId, p_question_id: questionId, p_answer: answer }),
  finishAttempt: (attemptId: string) => rpc<AttemptResult>('finish_attempt', { p_attempt_id: attemptId }),
  getResult: (attemptId: string) => rpc<AttemptResult | null>('get_attempt_result', { p_attempt_id: attemptId }),
  getLeaderboard: (period: Period, studentId?: string | null, subjectId?: string | null) =>
    leaderboard(period, subjectId ?? null, studentId ?? null),
};

// ---------------- Admin
export const adminApi = {
  dashboard: () => rpc<AdminDashboard>('admin_dashboard'),

  async getSettings() {
    const { rows } = await select<AppSettings>('app_settings', { filters: [['id', 'eq', 1]] });
    return rows[0];
  },
  updateSettings: (patch: Partial<AppSettings>) => update<AppSettings>('app_settings', patch as Row, [['id', 'eq', 1]]),

  async listSubjects() {
    return (await select<Subject>('subjects', { order: [['sort_order', true], ['name', true]] })).rows;
  },
  insertSubject: (s: Partial<Subject>) => insert<Subject>('subjects', [s as Row]),
  updateSubject: (id: string, patch: Partial<Subject>) => update<Subject>('subjects', patch as Row, [['id', 'eq', id]]),
  deleteSubject: (id: string) => remove('subjects', [['id', 'eq', id]]),

  async listLessons(filters: Filter[] = []) {
    return (await select<LessonView>('v_lessons', {
      filters,
      order: [['subject_sort', true], ['week_number', true], ['lesson_order', true]],
    })).rows;
  },
  insertLessons: (rows: Partial<Lesson>[]) => insert<Lesson>('lessons', rows as Row[]),
  updateLesson: (id: string, patch: Partial<Lesson>) => update<Lesson>('lessons', patch as Row, [['id', 'eq', id]]),
  updateLessons: (ids: string[], patch: Partial<Lesson>) => update<Lesson>('lessons', patch as Row, [['id', 'in', ids]]),
  deleteLesson: (id: string) => remove('lessons', [['id', 'eq', id]]),

  listQuestions: (opts: SelectOptions) => select<QuestionView>('v_questions', { count: true, ...opts }),
  async questionKeysForLesson(lessonId: string) {
    return (await select<Pick<Question, 'question_text' | 'option_a' | 'option_b' | 'option_c' | 'option_d'>>('questions', {
      columns: 'question_text,option_a,option_b,option_c,option_d',
      filters: [['lesson_id', 'eq', lessonId]],
    })).rows;
  },
  insertQuestions: (rows: Partial<Question>[]) => insert<Question>('questions', rows as Row[]),
  updateQuestion: (id: string, patch: Partial<Question>) => update<Question>('questions', patch as Row, [['id', 'eq', id]]),
  updateQuestions: (ids: string[], patch: Partial<Question>) => update<Question>('questions', patch as Row, [['id', 'in', ids]]),
  deleteQuestions: (ids: string[]) => remove('questions', [['id', 'in', ids]]),

  async listStudents() {
    return (await select<StudentStats>('v_student_stats', { order: [['is_active', false], ['display_name', true]] })).rows;
  },
  insertStudents: (rows: Array<{ full_name: string; display_name?: string | null; note?: string | null; birth_date?: string | null }>) =>
    insert<StudentStats>('students', rows),
  updateStudent: (id: string, patch: Partial<StudentStats>) => update<StudentStats>('students', patch as Row, [['id', 'eq', id]]),
  deleteStudent: (id: string) => remove('students', [['id', 'eq', id]]),

  listAttempts: (opts: SelectOptions) => select<AttemptView>('v_attempts', { count: true, ...opts }),
  getLeaderboard: (period: Period, subjectId?: string | null) => leaderboard(period, subjectId ?? null, null),
  subjectStats: (period: StatsPeriod) => rpc<AdminSubjectStats>('admin_subject_stats', { p_period: period }),
};
