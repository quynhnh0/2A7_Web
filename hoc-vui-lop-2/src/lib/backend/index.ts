import type { Backend } from './types';

export * from './types';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export const isDemoMode = !url || !key;

let backendPromise: Promise<Backend> | null = null;

export function getBackend(): Promise<Backend> {
  if (!backendPromise) {
    backendPromise = (isDemoMode
      ? import('./demoBackend').then((m) => m.createDemoBackend())
      : import('./supabaseBackend').then((m) => m.createSupabaseBackend(url!, key!))
    ).catch((e) => {
      backendPromise = null;
      throw e;
    });
  }
  return backendPromise;
}
