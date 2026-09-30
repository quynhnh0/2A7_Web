import { Component, type ErrorInfo, type ReactNode } from 'react';

interface State {
  error: Error | null;
}

/** Tránh màn hình trắng khi một trang bị lỗi (vd: tải lại chunk cũ sau khi deploy bản mới). */
export default class ErrorBoundary extends Component<{ children: ReactNode }, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('[ErrorBoundary] Giao diện bị lỗi:', error, info.componentStack);
  }

  render() {
    if (!this.state.error) return this.props.children;
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
        <div className="text-7xl" aria-hidden>🛠️</div>
        <p className="font-display text-2xl font-bold text-slate-700">Ôi, có chút trục trặc!</p>
        <p className="max-w-md text-slate-500">Bấm “Tải lại” để thử lại nhé. Nếu vẫn lỗi, hãy báo cho thầy cô hoặc bố mẹ.</p>
        <div className="flex gap-3">
          <button type="button" className="btn-kid btn-blue" onClick={() => location.reload()}>Tải lại</button>
          <a href="/" className="btn-kid btn-soft">Về trang chủ</a>
        </div>
      </div>
    );
  }
}
