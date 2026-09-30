import { useEffect, useState } from 'react';
import { Link, NavLink, Outlet, useNavigate } from 'react-router';
import { GraduationCap, Home, Trophy, UserRound } from 'lucide-react';
import { studentApi } from '../lib/api';
import { isDemoMode } from '../lib/backend';
import { clearStudent, getStoredStudent } from '../lib/studentSession';
import type { PublicConfig } from '../types';
import { Avatar } from './ui';

let configCache: PublicConfig | null = null;

export function usePublicConfig(): PublicConfig | null {
  const [config, setConfig] = useState<PublicConfig | null>(configCache);
  useEffect(() => {
    let alive = true;
    studentApi.getConfig().then((c) => {
      configCache = c;
      if (alive) setConfig(c);
    }, (e) => console.warn('[StudentLayout] Không tải được cấu hình lớp:', e));
    return () => {
      alive = false;
    };
  }, []);
  return config;
}

export function Logo({ subtitle }: { subtitle?: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-amber-500 shadow-[0_4px_0_0_#b45309]">
        <GraduationCap className="h-7 w-7 text-white" />
      </div>
      <div className="leading-tight">
        <div className="font-display text-xl font-bold tracking-tight text-blue-700">Học Vui Lớp 2</div>
        {subtitle && <div className="text-[11px] font-bold tracking-wider text-amber-700 uppercase">{subtitle}</div>}
      </div>
    </div>
  );
}

const navClass = ({ isActive }: { isActive: boolean }) =>
  `flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-bold transition-colors ${
    isActive ? 'bg-blue-600 text-white shadow-[0_4px_0_0_#1e40af]' : 'text-slate-600 hover:bg-white'
  }`;

export default function StudentLayout() {
  const config = usePublicConfig();
  const navigate = useNavigate();
  const student = getStoredStudent();

  const switchStudent = () => {
    if (window.confirm('Đổi sang bạn khác trên máy này?')) {
      clearStudent();
      navigate('/select-student');
    }
  };

  return (
    <div className="flex min-h-dvh flex-col">
      <header className="sticky top-0 z-40 border-b border-slate-200/70 bg-white/90 backdrop-blur-lg">
        <div className="mx-auto flex h-18 max-w-[1120px] items-center justify-between gap-3 px-4 sm:px-6">
          <Link to="/home" aria-label="Về trang chủ">
            <Logo subtitle={config ? `${config.class_name} • ${config.school_year}` : undefined} />
          </Link>
          <nav className="hidden items-center gap-1 rounded-2xl bg-slate-100 p-1 md:flex">
            <NavLink to="/home" className={navClass}><Home className="h-4 w-4" /> Bài tập</NavLink>
            <NavLink to="/leaderboard" className={navClass}><Trophy className="h-4 w-4" /> Xếp hạng</NavLink>
          </nav>
          {student ? (
            <button
              type="button"
              onClick={switchStudent}
              className="flex items-center gap-2 rounded-full bg-amber-100 py-1 pr-3 pl-1 text-left text-amber-900 transition hover:bg-amber-200"
              title="Đổi bạn khác"
            >
              <Avatar name={student.full_name} id={student.id} size="h-9 w-9 text-xs" />
              <span className="hidden flex-col leading-tight sm:flex">
                <span className="text-sm font-bold">{student.display_name}</span>
                <span className="text-[11px] font-medium opacity-75">Đổi bạn khác</span>
              </span>
            </button>
          ) : (
            <Link to="/select-student" className="flex items-center gap-2 rounded-full bg-blue-50 px-3 py-2 text-sm font-bold text-blue-700">
              <UserRound className="h-4 w-4" /> Chọn tên
            </Link>
          )}
        </div>
      </header>

      {isDemoMode && (
        <div className="bg-amber-50 px-4 py-1.5 text-center text-xs font-semibold text-amber-800">
          Chế độ DEMO — dữ liệu chỉ lưu trên máy này. Xem README để kết nối Supabase miễn phí.
        </div>
      )}

      <main className="mx-auto w-full max-w-[1120px] flex-1 px-4 pt-5 pb-28 sm:px-6 md:pb-10">
        <Outlet />
      </main>

      <footer className="hidden border-t border-slate-200 py-5 text-center text-xs text-slate-400 md:block">
        Học Vui Lớp 2 • Học mà chơi, chơi mà học •{' '}
        <Link to="/admin" className="font-semibold text-slate-500 hover:text-blue-600">Dành cho thầy cô</Link>
      </footer>

      <nav className="fixed inset-x-0 bottom-0 z-40 grid grid-cols-2 gap-2 border-t border-slate-200 bg-white/95 p-2 pb-[max(0.5rem,env(safe-area-inset-bottom))] backdrop-blur md:hidden">
        <NavLink to="/home" className={({ isActive }) => `flex flex-col items-center gap-0.5 rounded-xl py-2 text-xs font-bold ${isActive ? 'bg-blue-600 text-white' : 'text-slate-500'}`}>
          <Home className="h-6 w-6" /> Bài tập
        </NavLink>
        <NavLink to="/leaderboard" className={({ isActive }) => `flex flex-col items-center gap-0.5 rounded-xl py-2 text-xs font-bold ${isActive ? 'bg-amber-500 text-white' : 'text-slate-500'}`}>
          <Trophy className="h-6 w-6" /> Xếp hạng
        </NavLink>
      </nav>
    </div>
  );
}
