import { useEffect, useState } from 'react';
import { dismissToast, subscribeToasts, type Toast, type ToastType } from '@/hooks/useToast';

const ICONS: Record<ToastType, string> = {
  success: '✅',
  error:   '❌',
  warning: '⚠️',
  info:    'ℹ️',
};

const STYLES: Record<ToastType, { bg: string; border: string; color: string }> = {
  success: { bg: '#f0faf4', border: '#34c759', color: '#1a7a3c' },
  error:   { bg: '#fff0f0', border: '#ff3b30', color: '#c0392b' },
  warning: { bg: '#fff8e1', border: '#ff9500', color: '#b36200' },
  info:    { bg: '#f0f6ff', border: '#007aff', color: '#005bbf' },
};

function ToastItem({ toast }: { toast: Toast }) {
  const [visible, setVisible] = useState(false);
  const s = STYLES[toast.type];

  useEffect(() => {
    // Trigger slide-in on mount
    const show = requestAnimationFrame(() => setVisible(true));

    // Begin slide-out slightly before removal (250ms before durationMs)
    const hide = setTimeout(
      () => setVisible(false),
      Math.max(toast.durationMs - 250, 0),
    );

    return () => {
      cancelAnimationFrame(show);
      clearTimeout(hide);
    };
  }, [toast.durationMs]);

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'flex-start',
        gap: '10px',
        padding: '14px 18px',
        borderRadius: '12px',
        background: s.bg,
        border: `1.5px solid ${s.border}`,
        boxShadow: '0 4px 20px rgba(0,0,0,0.12)',
        minWidth: '280px',
        maxWidth: '420px',
        cursor: 'pointer',
        transform: visible ? 'translateX(0)' : 'translateX(120%)',
        opacity: visible ? 1 : 0,
        transition: 'transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.25s ease',
        willChange: 'transform, opacity',
      }}
      onClick={() => dismissToast(toast.id)}
      role="alert"
      aria-live="polite"
    >
      <span style={{ fontSize: '18px', lineHeight: '1', flexShrink: 0 }}>
        {ICONS[toast.type]}
      </span>
      <span
        style={{
          fontSize: '14px',
          lineHeight: '1.5',
          color: s.color,
          fontWeight: 500,
          flex: 1,
        }}
      >
        {toast.message}
      </span>
      <button
        onClick={(e) => { e.stopPropagation(); dismissToast(toast.id); }}
        style={{
          background: 'none',
          border: 'none',
          cursor: 'pointer',
          color: s.color,
          opacity: 0.6,
          fontSize: '16px',
          lineHeight: '1',
          padding: '0',
          flexShrink: 0,
        }}
        aria-label="Dismiss notification"
      >
        ×
      </button>
    </div>
  );
}

/**
 * ToastContainer — mount once in App.tsx.
 * Renders floating toasts in the top-right corner of the viewport.
 */
export function ToastContainer() {
  const [toasts, setToasts] = useState<Toast[]>([]);

  useEffect(() => {
    return subscribeToasts(setToasts);
  }, []);

  if (toasts.length === 0) return null;

  return (
    <div
      style={{
        position: 'fixed',
        top: '20px',
        right: '20px',
        zIndex: 9999,
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
        pointerEvents: 'none',
      }}
      aria-label="Notifications"
    >
      {toasts.map((t) => (
        <div key={t.id} style={{ pointerEvents: 'auto' }}>
          <ToastItem toast={t} />
        </div>
      ))}
    </div>
  );
}
