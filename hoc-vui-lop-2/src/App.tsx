import { lazy, Suspense, useEffect, useState, type ReactNode } from 'react';
import { Link, Navigate, Route, Routes } from 'react-router';
import StudentLayout from './components/StudentLayout';
import { LoadingBlock } from './components/ui';
import { getBackend, isDemoMode } from './lib/backend';
import { getStoredStudent } from './lib/studentSession';
import HomePage from './pages/student/HomePage';
import LeaderboardPage from './pages/student/LeaderboardPage';
import LessonPage from './pages/student/LessonPage';
import ResultPage from './pages/student/ResultPage';
import SelectStudentPage from './pages/student/SelectStudentPage';

const AdminLayout = lazy(() => import('./pages/admin/AdminLayout'));
const AdminLoginPage = lazy(() => import('./pages/admin/LoginPage'));
const DashboardPage = lazy(() => import('./pages/admin/DashboardPage'));
const LessonsPage = lazy(() => import('./pages/admin/LessonsPage'));
const QuestionsPage = lazy(() => import('./pages/admin/QuestionsPage'));
const ImportPage = lazy(() => import('./pages/admin/ImportPage'));
const GeneratorPage = lazy(() => import('./pages/admin/GeneratorPage'));
const StudentsPage = lazy(() => import('./pages/admin/StudentsPage'));
const ResultsPage = lazy(() => import('./pages/admin/ResultsPage'));
const AdminLeaderboardPage = lazy(() => import('./pages/admin/AdminLeaderboardPage'));
const SubjectStatsPage = lazy(() => import('./pages/admin/SubjectStatsPage'));
const SettingsPage = lazy(() => import('./pages/admin/SettingsPage'));

function RootRedirect() {
  return <Navigate to={getStoredStudent() ? '/home' : '/select-student'} replace />;
}

function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
      <div className="text-7xl" aria-hidden>🧭</div>
      <p className="font-display text-2xl font-bold text-slate-700">Không tìm thấy trang này</p>
      <Link to="/" className="btn-kid btn-blue">Về trang chủ</Link>
    </div>
  );
}

/** Chế độ demo: khởi tạo CSDL trong trình duyệt (lần đầu mất vài giây) trước khi hiện giao diện. */
function DemoBoot({ children }: { children: ReactNode }) {
  const [state, setState] = useState<'loading' | 'ready' | 'error'>(isDemoMode ? 'loading' : 'ready');
  useEffect(() => {
    if (!isDemoMode) return;
    let alive = true;
    getBackend()
      .then((b) => b.rpc('get_public_config'))
      .then(() => alive && setState('ready'), (e) => {
        console.error('[DemoBoot] Không khởi tạo được dữ liệu demo:', e);
        if (alive) setState('error');
      });
    return () => {
      alive = false;
    };
  }, []);
  if (state === 'ready') return <>{children}</>;
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-6 text-center">
      {state === 'loading' ? (
        <LoadingBlock label="Đang chuẩn bị bài tập… (lần đầu mất khoảng 10 giây)" />
      ) : (
        <div className="card max-w-md p-8">
          <p className="font-display text-xl font-bold text-slate-700">Trình duyệt này chưa chạy được bản demo.</p>
          <p className="mt-2 text-slate-500">Hãy thử Chrome, Edge hoặc Safari mới nhất và tải lại trang.</p>
          <button type="button" className="btn-kid btn-blue mt-4" onClick={() => location.reload()}>Tải lại</button>
        </div>
      )}
    </div>
  );
}

export default function App() {
  return (
    <DemoBoot>
      <Suspense fallback={<LoadingBlock />}>
        <Routes>
          <Route path="/" element={<RootRedirect />} />
          <Route path="/select-student" element={<SelectStudentPage />} />
          <Route element={<StudentLayout />}>
            <Route path="/home" element={<HomePage />} />
            <Route path="/lesson/:lessonId" element={<LessonPage />} />
            <Route path="/result/:attemptId" element={<ResultPage />} />
            <Route path="/leaderboard" element={<LeaderboardPage />} />
          </Route>
          <Route path="/admin/login" element={<AdminLoginPage />} />
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<DashboardPage />} />
            <Route path="lessons" element={<LessonsPage />} />
            <Route path="questions" element={<QuestionsPage />} />
            <Route path="import" element={<ImportPage />} />
            <Route path="generator" element={<GeneratorPage />} />
            <Route path="students" element={<StudentsPage />} />
            <Route path="results" element={<ResultsPage />} />
            <Route path="leaderboard" element={<AdminLeaderboardPage />} />
            <Route path="subject-stats" element={<SubjectStatsPage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Suspense>
    </DemoBoot>
  );
}
