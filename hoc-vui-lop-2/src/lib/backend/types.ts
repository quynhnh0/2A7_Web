export type FilterOp = 'eq' | 'neq' | 'gt' | 'gte' | 'lt' | 'lte' | 'in' | 'ilike' | 'is';
export type Filter = [column: string, op: FilterOp, value: unknown];
export type Row = Record<string, unknown>;

export interface SelectOptions {
  columns?: string;
  filters?: Filter[];
  /** [cột, tăng dần?] */
  order?: Array<[string, boolean]>;
  limit?: number;
  offset?: number;
  count?: boolean;
}

export interface AdminUser {
  email: string;
  isAdmin: boolean;
}

export interface Backend {
  mode: 'supabase' | 'demo';
  rpc<T>(fn: string, args?: Row): Promise<T>;
  select<T>(table: string, opts?: SelectOptions): Promise<{ rows: T[]; count: number | null }>;
  insert<T>(table: string, rows: Row[]): Promise<T[]>;
  update<T>(table: string, patch: Row, filters: Filter[]): Promise<T[]>;
  remove(table: string, filters: Filter[]): Promise<void>;
  auth: {
    getUser(): Promise<AdminUser | null>;
    signIn(email: string, password: string): Promise<void>;
    signOut(): Promise<void>;
  };
}

export class BackendError extends Error {
  code: string;
  constructor(code: string, message?: string) {
    super(message ?? code);
    this.code = code;
    this.name = 'BackendError';
  }
}

const KNOWN_CODES = [
  'student_not_found', 'student_disabled', 'self_register_disabled', 'invalid_name', 'lesson_not_available',
  'no_questions', 'attempt_not_found', 'attempt_completed', 'question_not_in_attempt', 'invalid_period',
  'invalid_exercise_type', 'not_admin', 'student_exists', 'subject_not_found',
];

export function toBackendError(err: unknown): BackendError {
  if (err instanceof BackendError) return err;
  const message = err instanceof Error ? err.message : typeof err === 'object' && err && 'message' in err ? String((err as { message: unknown }).message) : String(err);
  const code = KNOWN_CODES.find((c) => message.includes(c))
    ?? (/duplicate key|unique/i.test(message) ? 'duplicate'
      : /could not find the function|function .+ does not exist/i.test(message) ? 'missing_function' : 'unknown');
  return new BackendError(code, message);
}
