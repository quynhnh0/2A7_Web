import type { StudentIdentity } from '../types';

const STUDENT_KEY = 'hv_student';
const DEVICE_KEY = 'hv_device_token';

export function getStoredStudent(): StudentIdentity | null {
  try {
    const raw = localStorage.getItem(STUDENT_KEY);
    if (!raw) return null;
    const s = JSON.parse(raw) as StudentIdentity;
    return s && typeof s.id === 'string' ? s : null;
  } catch {
    return null;
  }
}

export function storeStudent(s: StudentIdentity): void {
  localStorage.setItem(STUDENT_KEY, JSON.stringify({ id: s.id, full_name: s.full_name, display_name: s.display_name }));
}

export function clearStudent(): void {
  localStorage.removeItem(STUDENT_KEY);
}

export function getDeviceToken(): string {
  let token = localStorage.getItem(DEVICE_KEY);
  if (!token) {
    token = typeof crypto !== 'undefined' && 'randomUUID' in crypto
      ? crypto.randomUUID()
      : `${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
    localStorage.setItem(DEVICE_KEY, token);
  }
  return token;
}
