import { useState, type FormEvent } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router';
import { LogIn } from 'lucide-react';
import { AdminError, Spinner } from '../../components/ui';
import { getBackend, isDemoMode } from '../../lib/backend';

const DEMO_EMAIL = 'admin@demo.vn';
const DEMO_PASSWORD = 'demo1234';

export default function LoginPage() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [email, setEmail] = useState(isDemoMode ? DEMO_EMAIL : '');
  const [password, setPassword] = useState(isDemoMode ? DEMO_PASSWORD : '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  const next = params.get('next');
  const target = next && next.startsWith('/admin') ? next : '/admin';

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await (await getBackend()).auth.signIn(email.trim(), password);
      navigate(target, { replace: true });
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4">
      <div className="w-full max-w-sm">
        <div className="mb-6 text-center">
          <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-600 text-2xl text-white">🎒</div>
          <h1 className="font-display text-2xl font-bold text-slate-900">Khu vực thầy cô</h1>
          <p className="mt-1 text-sm text-slate-500">Đăng nhập để quản lý bài tập và học sinh</p>
        </div>
        <form onSubmit={onSubmit} className="panel space-y-4 p-6">
          {isDemoMode && (
            <div className="rounded-lg bg-amber-50 p-3 text-sm text-amber-800">
              Bản demo — tài khoản: <b>{DEMO_EMAIL}</b> / mật khẩu: <b>{DEMO_PASSWORD}</b>
            </div>
          )}
          <div>
            <label className="label" htmlFor="email">Email</label>
            <input id="email" type="email" className="input" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </div>
          <div>
            <label className="label" htmlFor="password">Mật khẩu</label>
            <input id="password" type="password" className="input" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
          </div>
          {error !== null && <AdminError error={error} />}
          <button type="submit" className="btn btn-primary w-full" disabled={busy}>
            {busy ? <Spinner className="h-4 w-4 text-white" /> : <LogIn className="h-4 w-4" />} Đăng nhập
          </button>
        </form>
        <p className="mt-4 text-center text-sm">
          <Link to="/" className="text-blue-600 hover:underline">← Về trang học sinh</Link>
        </p>
      </div>
    </div>
  );
}
