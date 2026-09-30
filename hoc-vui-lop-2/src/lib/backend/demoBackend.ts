// CHẾ ĐỘ DEMO: chạy đúng file SQL của Supabase trên PGlite (Postgres WASM) ngay trong trình duyệt,
// dữ liệu lưu ở IndexedDB. Chỉ được tải khi chưa cấu hình VITE_SUPABASE_URL.
import type { PGlite as PGliteType } from '@electric-sql/pglite';
import stubsSql from '../../../supabase/demo/supabase_stubs.sql?raw';
import migrationSql from '../../../supabase/migrations/0001_init.sql?raw';
import seedSql from '../../../supabase/seed.sql?raw';
import archimesSql from '../../../supabase/archimes.sql?raw';
import demoDataSql from '../../../supabase/demo/demo_data.sql?raw';
import { BackendError, toBackendError, type Backend, type Filter, type Row, type SelectOptions } from './types';

export const DEMO_EMAIL = 'admin@demo.vn';
export const DEMO_PASSWORD = 'demo1234';
const DEMO_UID = '00000000-0000-0000-0000-00000000a001';
const DB_NAME = 'hoc-vui-lop-2-demo-v2';
const SESSION_KEY = 'hv-demo-admin';

const IDENT = /^[a-z_][a-z0-9_]*$/;
const OPS: Record<string, string> = { eq: '=', neq: '<>', gt: '>', gte: '>=', lt: '<', lte: '<=' };

function ident(name: string): string {
  if (!IDENT.test(name)) throw new BackendError('invalid_identifier', name);
  return name;
}

function toParam(v: unknown): unknown {
  if (v === undefined) return null;
  if (v !== null && typeof v === 'object' && !(v instanceof Date)) return JSON.stringify(v);
  return v;
}

let dbPromise: Promise<PGliteType> | null = null;

async function openDb(): Promise<PGliteType> {
  const { PGlite, types } = await import('@electric-sql/pglite');
  const toNumber = (x: string) => (x === null ? null : Number(x));
  const db = new PGlite(`idb://${DB_NAME}`, {
    parsers: {
      [types.INT8]: toNumber,
      [types.NUMERIC]: toNumber,
      [types.TIMESTAMPTZ]: (x: string) => new Date(x).toISOString(),
    },
  });
  await db.waitReady;
  const ready = await db.query<{ t: string | null }>(`select to_regclass('public.app_settings')::text as t`);
  if (!ready.rows[0]?.t) {
    await db.exec(stubsSql);
    await db.exec(migrationSql);
    await db.exec(seedSql);
    await db.exec(archimesSql);
    await db.query(`insert into auth.users (id, email) values ($1, $2) on conflict do nothing`, [DEMO_UID, DEMO_EMAIL]);
    await db.query(`insert into public.admins (user_id) values ($1) on conflict do nothing`, [DEMO_UID]);
    await db.exec(demoDataSql);
  } else {
    // Bản demo tạo trước khi có ngân hàng Archimes: nạp bổ sung (file chạy lại không tạo trùng).
    const has = await db.query<{ n: number }>(`select count(*)::int as n from public.questions where generator_type = 'archimes'`);
    if (!has.rows[0]?.n) await db.exec(archimesSql);
  }
  if (localStorage.getItem(SESSION_KEY)) {
    await db.query(`select set_config('demo.uid', $1, false)`, [DEMO_UID]);
  }
  return db;
}

function getDb(): Promise<PGliteType> {
  if (!dbPromise) {
    dbPromise = openDb().catch((e) => {
      dbPromise = null;
      throw e;
    });
  }
  return dbPromise;
}

export async function resetDemoData(): Promise<void> {
  if (dbPromise) {
    const db = await dbPromise.catch(() => null);
    await db?.close();
    dbPromise = null;
  }
  localStorage.removeItem(SESSION_KEY);
  await new Promise<void>((resolve) => {
    const req = indexedDB.deleteDatabase(`/pglite/${DB_NAME}`);
    req.onsuccess = req.onerror = req.onblocked = () => resolve();
  });
}

function buildWhere(filters: Filter[] = [], params: unknown[]): string {
  if (filters.length === 0) return '';
  const p = (v: unknown) => {
    params.push(toParam(v));
    return `$${params.length}`;
  };
  const parts = filters.map(([col, op, value]) => {
    const c = ident(col);
    if (op === 'in') {
      const arr = value as unknown[];
      return arr.length ? `${c} in (${arr.map(p).join(', ')})` : 'false';
    }
    if (op === 'is') return `${c} is ${value === null ? 'null' : value ? 'true' : 'false'}`;
    if (op === 'ilike') return `${c}::text ilike ${p(value)}`;
    return `${c} ${OPS[op]} ${p(value)}`;
  });
  return ' where ' + parts.join(' and ');
}

async function run<T>(sql: string, params: unknown[] = []): Promise<T[]> {
  const db = await getDb();
  try {
    const res = await db.query<T>(sql, params);
    return res.rows;
  } catch (e) {
    throw toBackendError(e);
  }
}

export function createDemoBackend(): Backend {
  return {
    mode: 'demo',

    async rpc<T>(fn: string, args: Row = {}) {
      const keys = Object.keys(args);
      const call = `public.${ident(fn)}(${keys.map((k, i) => `${ident(k)} => $${i + 1}`).join(', ')})`;
      const rows = await run<{ r: T }>(`select ${call} as r`, keys.map((k) => toParam(args[k])));
      return rows[0]?.r as T;
    },

    async select<T>(table: string, opts: SelectOptions = {}) {
      const params: unknown[] = [];
      const cols = !opts.columns || opts.columns === '*' ? '*' : opts.columns.split(',').map((c) => ident(c.trim())).join(', ');
      const where = buildWhere(opts.filters, params);
      let sql = `select ${cols} from public.${ident(table)}${where}`;
      if (opts.order?.length) sql += ' order by ' + opts.order.map(([c, asc]) => `${ident(c)} ${asc ? 'asc' : 'desc'} nulls last`).join(', ');
      if (opts.limit !== undefined) sql += ` limit ${Math.max(0, Math.floor(opts.limit))} offset ${Math.max(0, Math.floor(opts.offset ?? 0))}`;
      const rows = await run<T>(sql, params);
      let count: number | null = null;
      if (opts.count) {
        const countParams: unknown[] = [];
        const c = await run<{ n: number }>(`select count(*) as n from public.${ident(table)}${buildWhere(opts.filters, countParams)}`, countParams);
        count = Number(c[0]?.n ?? 0);
      }
      return { rows, count };
    },

    async insert<T>(table: string, rows: Row[]) {
      if (rows.length === 0) return [];
      const cols = Array.from(new Set(rows.flatMap((r) => Object.keys(r)))).map(ident);
      const params: unknown[] = [];
      const values = rows.map((r) => '(' + cols.map((c) => {
        if (!(c in r)) return 'default';
        params.push(toParam(r[c]));
        return `$${params.length}`;
      }).join(', ') + ')');
      return run<T>(`insert into public.${ident(table)} (${cols.join(', ')}) values ${values.join(', ')} returning *`, params);
    },

    async update<T>(table: string, patch: Row, filters: Filter[]) {
      if (filters.length === 0) throw new BackendError('update_without_filter');
      const params: unknown[] = [];
      const sets = Object.keys(patch).map((k) => {
        params.push(toParam(patch[k]));
        return `${ident(k)} = $${params.length}`;
      });
      const where = buildWhere(filters, params);
      return run<T>(`update public.${ident(table)} set ${sets.join(', ')}${where} returning *`, params);
    },

    async remove(table: string, filters: Filter[]) {
      if (filters.length === 0) throw new BackendError('delete_without_filter');
      const params: unknown[] = [];
      await run(`delete from public.${ident(table)}${buildWhere(filters, params)}`, params);
    },

    auth: {
      async getUser() {
        return localStorage.getItem(SESSION_KEY) ? { email: DEMO_EMAIL, isAdmin: true } : null;
      },
      async signIn(email: string, password: string) {
        if (email.trim().toLowerCase() !== DEMO_EMAIL || password !== DEMO_PASSWORD) {
          throw new BackendError('invalid_credentials', 'Invalid login credentials');
        }
        await run(`select set_config('demo.uid', $1, false)`, [DEMO_UID]);
        localStorage.setItem(SESSION_KEY, '1');
      },
      async signOut() {
        await run(`select set_config('demo.uid', '', false)`);
        localStorage.removeItem(SESSION_KEY);
      },
    },
  };
}
