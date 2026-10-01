import { useState } from 'react';
import { Link, Navigate, NavLink, Outlet, useLocation, useNavigate } from 'react-router';
import {
  BarChart3, BookOpen, ExternalLink, LayoutDashboard, ListChecks, LogOut, Menu, PieChart, Settings, Trophy, Upload, Users, Wand2, X,
} from 'lucide-react';
import { AdminError, LoadingBlock } from '../../components/ui';
import { useAsync } from '../../hooks/useAsync';
import { getBackend, isDemoMode } from '../../lib/backend';

const NAV = [
  { to: '/admin', label: 'Tổng quan', icon: LayoutDashboard, end: true },
  { to: '/admin/lessons', label: 'Bài học & lịch mở', icon: BookOpen },
  { to: '/admin/questions', label: 'Ngân hàng câu hỏi', icon: ListChecks },
  { to: '/admin/import', label: 'Nhập CSV / Excel', icon: Upload },
  { to: '/admin/generator', label: 'Sinh câu hỏi tự động', icon: Wand2 },
  { to: '/admin/students', label: 'Học sinh', icon: Users },
  { to: '/admin/results', label: 'Kết quả làm bài', icon: BarChart3 },
  { to: '/admin/subject-stats', label: 'Thống kê theo môn', icon: PieChart },
  { to: '/admin/leaderboard', label: 'Bảng xếp hạng', icon: Trophy },
  { to: '/admin/settings', label: 'Cài đặt', icon: Settings },
];

export default function AdminLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const { data: user, loading, error, reload } = useAsync(async () => (await getBackend()).auth.getUser(), []);

  if (loading) return <LoadingBlock label="Đang kiểm tra đăng nhập…" />;
  if (error) return <div className="mx-auto max-w-lg p-6"><AdminError error={error} onRetry={reload} /></div>;
  if (!user) return <Navigate to={`/admin/login?next=${encodeURIComponent(location.pathname + location.search)}`} replace />;

  const signOut = async () => {
    await (await getBackend()).auth.signOut();
    navigate('/admin/login', { replace: true });
  };

  if (!user.isAdmin) {
    return (
      <div className="mx-auto mt-16 max-w-lg space-y-4 p-6">
        <div className="panel space-y-3 p-6">
          <h1 className="text-lg font-bold text-slate-800">Tài khoản chưa có quyền quản trị</h1>
          <p className="text-sm text-slate-600">
            Bạn đã đăng nhập bằng <b>{user.email}</b> nhưng tài khoản này chưa nằm trong bảng <code>admins</code>.
            Vào Supabase → SQL Editor và chạy:
          </p>
          <pre className="overflow-x-auto rounded-lg bg-slate-900 p-3 text-xs text-slate-100">
            {`insert into public.admins (user_id)\nselect id from auth.users where email = '${user.email}';`}
          </pre>
          <button type="button" className="btn btn-secondary" onClick={signOut}><LogOut className="h-4 w-4" /> Đăng xuất</button>
        </div>
      </div>
    );
  }

  const sidebar = (
    <nav className="flex h-full flex-col gap-1 p-3" aria-label="Menu quản trị">
      <div className="mb-4 flex items-center gap-3 px-2 pt-2">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600 text-lg text-white">🎒</div>
        <div>
          <p className="font-display text-base font-bold text-slate-900">Học Vui Lớp 2</p>
          <p className="text-xs text-slate-500">Khu vực thầy cô</p>
        </div>
      </div>
      {NAV.map(({ to, label, icon: Icon, end }) => (
        <NavLink
          key={to}
          to={to}
          end={end}
          onClick={() => setMenuOpen(false)}
          className={({ isActive }) =>
            `flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
              isActive ? 'bg-blue-50 text-blue-700' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
            }`}
        >
          <Icon className="h-[18px] w-[18px]" /> {label}
        </NavLink>
      ))}
      <div className="mt-auto space-y-2 border-t border-slate-100 pt-3">
        <Link to="/" target="_blank" className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-600 hover:bg-slate-100">
          <ExternalLink className="h-4 w-4" /> Mở trang học sinh
        </Link>
        <div className="flex items-center justify-between gap-2 px-3 py-1">
          <span className="truncate text-xs text-slate-500" title={user.email}>{user.email}</span>
          <button type="button" className="btn btn-ghost btn-icon" onClick={signOut} aria-label="Đăng xuất" title="Đăng xuất">
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </div>
    </nav>
  );

  return (
    <div className="min-h-screen bg-slate-50">
      <aside className="fixed inset-y-0 left-0 z-30 hidden w-64 border-r border-slate-200 bg-white lg:block">{sidebar}</aside>

      <header className="sticky top-0 z-20 flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3 lg:hidden">
        <button type="button" className="btn btn-ghost btn-icon" onClick={() => setMenuOpen(true)} aria-label="Mở menu"><Menu className="h-5 w-5" /></button>
        <span className="font-display font-bold text-slate-900">Học Vui Lớp 2 · Quản trị</span>
        <span className="w-9" />
      </header>

      {menuOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div className="absolute inset-0 bg-slate-900/40" onClick={() => setMenuOpen(false)} />
          <aside className="absolute inset-y-0 left-0 w-72 bg-white shadow-xl">
            <button type="button" className="btn btn-ghost btn-icon absolute right-2 top-2" onClick={() => setMenuOpen(false)} aria-label="Đóng menu">
              <X className="h-5 w-5" />
            </button>
            {sidebar}
          </aside>
        </div>
      )}

      <main className="lg:pl-64">
        {isDemoMode && (
          <div className="border-b border-amber-200 bg-amber-50 px-4 py-2 text-center text-sm text-amber-800">
            Đang chạy <b>bản demo</b>: dữ liệu chỉ lưu trong trình duyệt này. Xem README để kết nối Supabase miễn phí.
          </div>
        )}
        <div className="mx-auto max-w-7xl p-4 sm:p-6 lg:p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
