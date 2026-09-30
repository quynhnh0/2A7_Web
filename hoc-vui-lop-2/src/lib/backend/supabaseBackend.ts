import { createClient } from '@supabase/supabase-js';
import { toBackendError, type Backend, type Filter, type Row, type SelectOptions } from './types';

// Query builder của supabase-js có kiểu generic rất sâu; ở đây chỉ dùng tập con đơn giản.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AnyQuery = any;

const PAGE_MAX = 1000;

function applyFilters(query: AnyQuery, filters: Filter[] = []): AnyQuery {
  let q = query;
  for (const [col, op, value] of filters) {
    q = op === 'in' ? q.in(col, value as unknown[]) : q[op](col, value);
  }
  return q;
}

export function createSupabaseBackend(url: string, key: string): Backend {
  const client = createClient(url, key, {
    auth: { persistSession: true, autoRefreshToken: true, storageKey: 'hv-admin-auth' },
  });

  const unwrap = <T>(res: { data: unknown; error: unknown; count?: number | null }): T => {
    if (res.error) throw toBackendError(res.error);
    return res.data as T;
  };

  return {
    mode: 'supabase',

    async rpc<T>(fn: string, args: Row = {}) {
      return unwrap<T>(await client.rpc(fn, args));
    },

    async select<T>(table: string, opts: SelectOptions = {}) {
      // PostgREST của Supabase trả tối đa 1000 dòng mỗi lần: lấy theo từng trang khi cần nhiều hơn.
      const start = opts.offset ?? 0;
      const wanted = opts.limit ?? Number.POSITIVE_INFINITY;
      const rows: T[] = [];
      let count: number | null = null;
      while (rows.length < wanted) {
        const from = start + rows.length;
        const size = Math.min(PAGE_MAX, wanted - rows.length);
        let q: AnyQuery = client.from(table).select(opts.columns ?? '*', opts.count && rows.length === 0 ? { count: 'exact' } : undefined);
        q = applyFilters(q, opts.filters);
        for (const [col, asc] of opts.order ?? []) q = q.order(col, { ascending: asc });
        if (!opts.columns) q = q.order('id', { ascending: true });
        const res = await q.range(from, from + size - 1);
        const batch = unwrap<T[]>(res) ?? [];
        if (rows.length === 0) count = res.count ?? null;
        rows.push(...batch);
        if (batch.length < size) break;
      }
      return { rows, count };
    },

    async insert<T>(table: string, rows: Row[]) {
      if (rows.length === 0) return [];
      return unwrap<T[]>(await client.from(table).insert(rows).select());
    },

    async update<T>(table: string, patch: Row, filters: Filter[]) {
      if (filters.length === 0) throw toBackendError('update_without_filter');
      return unwrap<T[]>(await applyFilters(client.from(table).update(patch), filters).select());
    },

    async remove(table: string, filters: Filter[]) {
      if (filters.length === 0) throw toBackendError('delete_without_filter');
      unwrap(await applyFilters(client.from(table).delete(), filters));
    },

    auth: {
      async getUser() {
        const { data } = await client.auth.getSession();
        const user = data.session?.user;
        if (!user) return null;
        const isAdmin = unwrap<boolean>(await client.rpc('is_admin'));
        return { email: user.email ?? '', isAdmin };
      },
      async signIn(email: string, password: string) {
        const { error } = await client.auth.signInWithPassword({ email, password });
        if (error) throw toBackendError(error);
      },
      async signOut() {
        await client.auth.signOut();
      },
    },
  };
}
