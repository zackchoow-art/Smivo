/**
 * useToast — lightweight global toast notification system.
 *
 * Usage:
 *   import { showToast } from '@/hooks/useToast';
 *   showToast('Saved successfully', 'success');
 *   showToast('Something went wrong', 'error');
 *
 * Mount <ToastContainer /> once at the app root (App.tsx).
 * No provider needed — state lives in a module-level singleton.
 */

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  durationMs: number;
}

type Listener = (toasts: Toast[]) => void;

// NOTE: Module-level singleton keeps state outside React lifecycle,
// allowing showToast() to be called from hooks, event handlers, and
// async callbacks without needing access to React context.
let _toasts: Toast[] = [];
const _listeners = new Set<Listener>();

function notify() {
  _listeners.forEach((fn) => fn([..._toasts]));
}

/**
 * Show a floating toast notification.
 * @param message - Text to display.
 * @param type    - Visual style: 'success' | 'error' | 'warning' | 'info'.
 * @param durationMs - Auto-dismiss after this many ms. Default: 3000.
 */
export function showToast(
  message: string,
  type: ToastType = 'info',
  durationMs = 3000,
): void {
  const id = `toast_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
  _toasts = [..._toasts, { id, message, type, durationMs }];
  notify();

  // Auto-remove after duration
  setTimeout(() => {
    _toasts = _toasts.filter((t) => t.id !== id);
    notify();
  }, durationMs);
}

export function dismissToast(id: string): void {
  _toasts = _toasts.filter((t) => t.id !== id);
  notify();
}

export function subscribeToasts(listener: Listener): () => void {
  _listeners.add(listener);
  // Immediately call with current state so late subscribers get existing toasts
  listener([..._toasts]);
  return () => _listeners.delete(listener);
}
