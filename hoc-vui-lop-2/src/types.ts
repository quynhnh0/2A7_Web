export type QuestionType = 'multiple_choice' | 'number' | 'text';
export type ExerciseType = 'basic' | 'advanced';
export type Period = 'day' | 'week' | 'month';
export type PublishMode = 'always' | 'week' | 'date';
export type SubjectColor = 'blue' | 'green' | 'amber' | 'rose' | 'purple';
export type RetakeMode = 'per_correct' | 'pair';
/** 'ranked' = lần làm đầu (tính BXH); còn lại là kiểu tính sao của lần làm lại. */
export type ScoringMode = 'ranked' | RetakeMode;
export type MedalKind = 'gold' | 'silver' | 'bronze' | 'encourage';
/** Thứ theo ISO: '1' = thứ Hai … '7' = Chủ nhật → [giờ mở, giờ đóng] dạng 'HH:MM'. */
export type WeekSchedule = Partial<Record<'1' | '2' | '3' | '4' | '5' | '6' | '7', [string, string]>>;

export interface PublicConfig {
  class_name: string;
  school_year: string;
  current_week: number;
  leaderboard_enabled: boolean;
  allow_self_register: boolean;
  stars_per_diamond?: number;
}

export interface WeekMedal {
  score: number;
  max_score: number;
  pct: number;
  medal: MedalKind | null;
  class_week: number;
}

export interface StudentRewards {
  stars_total: number;
  stars_per_diamond: number;
  diamonds: number;
  stars: number;
  thresholds: { gold: number; silver: number; bronze: number };
  /** false = bạn khách (tên có dấu "-"): không xét huy chương, vẫn có sao/kim cương. */
  medal_eligible?: boolean;
  this_week: WeekMedal | null;
  last_week: WeekMedal | null;
  medal_counts: Partial<Record<MedalKind, number>>;
}

export interface ScheduleStatus {
  enabled: boolean;
  open: boolean;
  closes_at?: string | null;
  next_open_at?: string | null;
  schedule: WeekSchedule;
}

export interface DailyQuota {
  used: number;
  /** 0 = không giới hạn */
  max: number;
  basic_count: number;
  advanced_count: number;
}

export interface ScoringInfo {
  mode: ScoringMode;
  wrong_penalty: number;
  floor_zero: boolean;
}

export interface StudentIdentity {
  id: string;
  full_name: string;
  display_name: string;
  /** Có ngày sinh trong hệ thống => phải nhập đúng ngày/tháng sinh mới vào được. */
  needs_birthday?: boolean;
}

export interface VerifyStudentResult {
  ok: boolean;
  student?: StudentIdentity;
  remaining?: number;
  locked_seconds?: number;
}

export interface HomeLesson {
  id: string;
  subject_code: string;
  subject_name: string;
  subject_color: SubjectColor;
  week_number: number;
  lesson_order: number;
  name: string;
  description: string | null;
  question_count: number;
  basic_best: number | null;
  basic_ranked_score: number | null;
  basic_correct: string | null;
  advanced_best: number | null;
  advanced_correct: string | null;
  has_advanced: boolean;
}

export interface StudentHome {
  student: StudentIdentity;
  config: PublicConfig;
  points: Record<Period, number>;
  ranks: Record<Period, number | null>;
  basic_count: number;
  advanced_count: number;
  lessons: HomeLesson[];
  /** Các field dưới đây chỉ có khi database đã chạy 0006. */
  rewards?: StudentRewards;
  schedule?: ScheduleStatus;
  daily?: Record<string, DailyQuota>;
}

export interface LessonInfo {
  id: string;
  name: string;
  week_number: number;
  lesson_order: number;
  subject_name: string;
  subject_color: SubjectColor;
}

export interface ExerciseQuestion {
  id: string;
  type: QuestionType;
  text: string;
  difficulty: 1 | 2 | 3;
  /** null = làm lại kiểu "cặp" (sao được chốt khi nộp bài). */
  points: number | null;
  options: string[] | null;
}

export interface AnswerResult {
  is_correct: boolean;
  correct_answer: string;
  explanation: string | null;
  score_awarded: number;
  student_answer: string;
}

export interface AttemptPayload {
  attempt_id: string;
  is_ranked: boolean;
  exercise_type: ExerciseType;
  completed: boolean;
  scoring?: ScoringInfo;
  lesson: LessonInfo;
  questions: ExerciseQuestion[];
  answered: Record<string, AnswerResult>;
}

export interface ReviewItem {
  question_id: string;
  type: QuestionType;
  text: string;
  student_answer: string | null;
  correct_answer: string;
  is_correct: boolean;
  explanation: string | null;
  score_awarded: number;
}

export interface AttemptResult {
  attempt_id: string;
  student_id: string;
  is_ranked: boolean;
  exercise_type: ExerciseType;
  completed: boolean;
  score: number;
  max_score: number;
  correct_count: number;
  wrong_count: number;
  total_questions: number;
  duration_seconds: number | null;
  completed_at: string | null;
  scoring?: ScoringInfo;
  points_gained?: number;
  points_lost?: number;
  lesson: LessonInfo;
  review: ReviewItem[];
}

export interface LeaderboardRow {
  student_id: string;
  full_name: string;
  display_name: string;
  score: number;
  lessons_done: number;
  accuracy: number;
  rank: number;
  is_guest?: boolean;
}

export interface LeaderboardSubject {
  id: string;
  code: string;
  name: string;
  color: SubjectColor;
}

export interface Leaderboard {
  enabled: boolean;
  period: Period;
  /** null = tất cả các môn */
  subject_id?: string | null;
  subjects?: LeaderboardSubject[];
  start?: string;
  end?: string;
  rows: LeaderboardRow[];
  me: { rank: number; score: number } | null;
}

// ---- Admin

export interface AppSettings {
  id: number;
  class_name: string;
  school_year: string;
  current_week: number;
  timezone: string;
  leaderboard_enabled: boolean;
  allow_self_register: boolean;
  basic_easy: number;
  basic_normal: number;
  basic_advanced: number;
  adv_easy: number;
  adv_normal: number;
  adv_advanced: number;
  points_easy: number;
  points_normal: number;
  points_advanced: number;
  // 0006
  adv_points_easy: number;
  adv_points_normal: number;
  adv_points_advanced: number;
  wrong_penalty: number;
  score_floor_zero: boolean;
  retake_mode: RetakeMode;
  daily_max_lessons: number;
  stars_per_diamond: number;
  medal_gold_pct: number;
  medal_silver_pct: number;
  medal_bronze_pct: number;
  medal_include_advanced: boolean;
  schedule_enabled: boolean;
  schedule: WeekSchedule;
  adapt_min_answers: number;
  adapt_up_pct: number;
  adapt_down_pct: number;
}

/** Cài đặt riêng của môn: null = theo cài đặt chung. */
export interface SubjectSettings {
  subject_id: string;
  daily_max_lessons: number | null;
  basic_easy: number | null;
  basic_normal: number | null;
  basic_advanced: number | null;
  adv_easy: number | null;
  adv_normal: number | null;
  adv_advanced: number | null;
  points_easy: number | null;
  points_normal: number | null;
  points_advanced: number | null;
  adv_points_easy: number | null;
  adv_points_normal: number | null;
  adv_points_advanced: number | null;
  wrong_penalty: number | null;
  retake_mode: RetakeMode | null;
}

export interface WeeklyMedalRow extends WeekMedal {
  student_id: string;
  full_name: string;
  display_name: string;
  medal: MedalKind;
  is_guest: boolean;
}

export interface AdminWeeklyMedals {
  week_start: string;
  is_current: boolean;
  class_week: number | null;
  max_score: number;
  include_advanced: boolean;
  thresholds: { gold: number; silver: number; bronze: number };
  rows: WeeklyMedalRow[];
  weeks: Array<{ week_start: string; class_week: number }>;
}

export interface Subject {
  id: string;
  code: string;
  name: string;
  color: SubjectColor;
  sort_order: number;
}

export interface Lesson {
  id: string;
  subject_id: string;
  week_number: number;
  lesson_order: number;
  name: string;
  description: string | null;
  is_published: boolean;
  publish_mode: PublishMode;
  available_from: string | null;
  available_until: string | null;
}

export interface LessonView extends Lesson {
  subject_code: string;
  subject_name: string;
  subject_color: SubjectColor;
  subject_sort: number;
  question_count: number;
  easy_count: number;
  normal_count: number;
  advanced_count: number;
  students_done: number;
  accuracy: number | null;
}

export interface Question {
  id: string;
  lesson_id: string;
  difficulty: 1 | 2 | 3;
  question_type: QuestionType;
  question_text: string;
  option_a: string | null;
  option_b: string | null;
  option_c: string | null;
  option_d: string | null;
  correct_answer: string;
  accepted_answers: string[] | null;
  explanation: string | null;
  points: number | null;
  skill_tag: string | null;
  source_book: string | null;
  source_page: number | null;
  generator_type: string | null;
  is_active: boolean;
  created_at: string;
}

export interface QuestionView extends Question {
  lesson_name: string;
  week_number: number;
  lesson_order: number;
  subject_id: string;
  subject_code: string;
  subject_name: string;
  answered_count: number;
  correct_count: number;
}

/** Số liệu của 1 học sinh trong một khoảng thời gian (cùng cách tính với v_student_stats). */
export type StudentActivity = Pick<StudentStats, 'attempts_completed' | 'total_score' | 'accuracy' | 'last_active_at'>;

export interface StudentStats {
  id: string;
  full_name: string;
  display_name: string;
  is_active: boolean;
  note: string | null;
  /** 'YYYY-MM-DD' */
  birth_date: string | null;
  verify_fails: number;
  verify_locked_until: string | null;
  created_at: string;
  attempts_completed: number;
  total_score: number;
  accuracy: number | null;
  last_active_at: string | null;
}

export interface AttemptView {
  id: string;
  student_id: string;
  lesson_id: string;
  exercise_type: ExerciseType;
  score: number;
  correct_count: number;
  wrong_count: number;
  total_questions: number;
  duration_seconds: number | null;
  is_ranked: boolean;
  started_at: string;
  completed_at: string | null;
  student_name: string;
  student_display_name: string;
  lesson_name: string;
  week_number: number;
  lesson_order: number;
  subject_name: string;
}

export interface AdminDashboard {
  total_students: number;
  current_week: number;
  today: { active_students: number; attempts_completed: number; answers: number; accuracy: number | null };
  week: { active_students: number; attempts_completed: number; accuracy: number | null };
  question_count: number;
  lesson_count: number;
  published_count: number;
  hardest: Array<{ question_id: string; text: string; lesson_name: string; week_number: number; answered: number; wrong: number; wrong_rate: number }>;
  inactive_today: Array<{ id: string; display_name: string; full_name: string }>;
  recent: Array<{ id: string; student: string; lesson: string; exercise_type: ExerciseType; score: number; correct_count: number; total_questions: number; is_ranked: boolean; completed_at: string }>;
}

export type StatsPeriod = Period | 'all';

export interface SubjectStat extends LeaderboardSubject {
  sort_order: number;
  lesson_count: number;
  published_count: number;
  question_count: number;
  attempts_completed: number;
  active_students: number;
  ranked_score: number;
  accuracy: number | null;
  avg_duration: number | null;
}

export interface StudentSubjectCell {
  attempts: number;
  score: number;
  accuracy: number | null;
}

export interface AdminSubjectStats {
  period: StatsPeriod;
  start: string | null;
  end: string | null;
  total_students: number;
  subjects: SubjectStat[];
  students: Array<{ student_id: string; full_name: string; display_name: string; by_subject: Record<string, StudentSubjectCell> }>;
  hardest: Array<{ subject_id: string; question_id: string; text: string; lesson_name: string; week_number: number; answered: number; wrong: number; wrong_rate: number }>;
}
