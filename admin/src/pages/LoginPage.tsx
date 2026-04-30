/**
 * Login page — minimal design per 04_ADMIN_WEB_SPEC.md §22.
 * Email + password only, no registration. Non-admin users get rejected.
 */
import { useState, type FormEvent } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';

export function LoginPage() {
  const { login, loading, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  // Already logged in — go to dashboard
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);

    try {
      await login(email, password);
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    }
  };

  return (
    <div className="login-page">
      <div className="login-card">
        {/* Logo */}
        <div className="login-header">
          <h1 className="login-logo">Smivo Admin</h1>
          <p className="login-subtitle">Campus Marketplace Management</p>
        </div>

        {/* Error banner */}
        {error && (
          <div className="login-error" role="alert">
            {error}
          </div>
        )}

        {/* Login form */}
        <form onSubmit={handleSubmit} className="login-form">
          <div className="login-field">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@smith.edu"
              required
              autoComplete="email"
              autoFocus
            />
          </div>

          <div className="login-field">
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
              autoComplete="current-password"
            />
          </div>

          <button
            type="submit"
            className="login-button"
            disabled={loading || !email || !password}
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>

        <p className="login-footer">
          Need access? Contact your platform administrator.
        </p>
      </div>

      <style>{`
        .login-page {
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          background: var(--color-bg-secondary);
          padding: 16px;
        }

        .login-card {
          width: 100%;
          max-width: 400px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-xl);
          padding: 40px 32px;
          box-shadow: var(--shadow-card);
        }

        .login-header {
          text-align: center;
          margin-bottom: 32px;
        }

        .login-logo {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .login-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .login-error {
          background: var(--color-danger-light);
          color: var(--color-danger);
          padding: 10px 14px;
          border-radius: var(--radius-md);
          font-size: 13px;
          margin-bottom: 20px;
          border: 1px solid color-mix(in srgb, var(--color-danger) 20%, transparent);
        }

        .login-form {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .login-field {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .login-field label {
          font-size: 13px;
          font-weight: 500;
          color: var(--color-text-secondary);
        }

        .login-field input {
          height: 40px;
          padding: 0 12px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          font-size: 14px;
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          outline: none;
          transition: border-color 0.15s;
        }

        .login-field input:focus {
          border-color: var(--color-border-focus);
          box-shadow: 0 0 0 3px color-mix(in srgb, var(--color-border-focus) 15%, transparent);
        }

        .login-button {
          height: 42px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
          transition: opacity 0.15s;
          margin-top: 8px;
        }

        .login-button:hover:not(:disabled) {
          opacity: 0.9;
        }

        .login-button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .login-footer {
          text-align: center;
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-top: 24px;
        }
      `}</style>
    </div>
  );
}
