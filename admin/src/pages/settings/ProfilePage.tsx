/**
 * Admin profile settings page.
 * Shows current admin's info and allows editing display name.
 */
import { useState } from 'react';
import { User, Shield, School, Save, Loader2, Check } from 'lucide-react';
import { useAuthStore } from '@/stores/auth-store';
import { supabase } from '@/lib/supabase';
import { TABLES, ADMIN_ROLES } from '@/lib/constants';
import { showToast } from '@/hooks/useToast';

const ROLE_LABELS: Record<string, string> = {
  [ADMIN_ROLES.PLATFORM_SUPER_ADMIN]: 'Platform Super Admin',
  [ADMIN_ROLES.PLATFORM_MODERATOR]: 'Platform Moderator',
  [ADMIN_ROLES.SCHOOL_ADMIN]: 'School Admin',
};

export function ProfilePage() {
  const { admin, scopes, setAdmin } = useAuthStore();
  const [displayName, setDisplayName] = useState(admin?.display_name ?? '');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  if (!admin) return null;

  const handleSave = async () => {
    setSaving(true);
    setSaved(false);

    try {
      const { error } = await supabase
        .from(TABLES.ADMIN_USERS)
        .update({
          display_name: displayName,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', admin.user_id);

      if (error) throw error;

      // Update local state
      setAdmin({ ...admin, display_name: displayName }, scopes);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      console.error('Failed to update profile:', err);
      showToast('Failed to save profile. Please try again.', 'error', 5000);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="profile-page">
      <h1 className="profile-title">Profile Settings</h1>
      <p className="profile-subtitle">Manage your admin account information.</p>

      <div className="profile-card">
        {/* Avatar */}
        <div className="profile-avatar-section">
          <div className="profile-avatar">
            {admin.avatar_url ? (
              <img src={admin.avatar_url} alt={admin.display_name ?? 'Admin'} />
            ) : (
              <User size={32} color="var(--color-text-tertiary)" />
            )}
          </div>
        </div>

        {/* Info fields */}
        <div className="profile-fields">
          {/* Display Name — editable */}
          <div className="profile-field">
            <label className="profile-label">Display Name</label>
            <input
              type="text"
              className="profile-input"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Enter your display name"
            />
          </div>

          {/* Email — read only */}
          <div className="profile-field">
            <label className="profile-label">Email</label>
            <div className="profile-readonly">{admin.email}</div>
          </div>

          {/* Role — read only */}
          <div className="profile-field">
            <label className="profile-label">Role</label>
            <div className="profile-role-badge">
              <Shield size={14} />
              {ROLE_LABELS[admin.role] ?? admin.role}
            </div>
          </div>

          {/* Authorized Schools */}
          <div className="profile-field">
            <label className="profile-label">Authorized Schools</label>
            <div className="profile-schools">
              {admin.role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN ? (
                <div className="profile-school-chip platform">
                  🌐 All Schools (Platform-wide)
                </div>
              ) : scopes.length > 0 ? (
                scopes.map((scope) => (
                  <div key={scope.college_id} className="profile-school-chip">
                    <School size={12} />
                    {scope.college_id.slice(0, 8)}…
                  </div>
                ))
              ) : (
                <span className="profile-no-schools">No schools assigned</span>
              )}
            </div>
          </div>

          {/* Save button */}
          <button
            className={`profile-save-btn ${saved ? 'saved' : ''}`}
            onClick={handleSave}
            disabled={saving || displayName === admin.display_name}
          >
            {saving ? (
              <Loader2 size={16} className="spin" />
            ) : saved ? (
              <Check size={16} />
            ) : (
              <Save size={16} />
            )}
            {saved ? 'Saved!' : 'Save Changes'}
          </button>
        </div>
      </div>

      <style>{`
        .profile-page {
          padding: var(--spacing-page);
          max-width: 600px;
        }

        .profile-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .profile-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
          margin-bottom: 24px;
        }

        .profile-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          padding: 24px;
        }

        .profile-avatar-section {
          display: flex;
          justify-content: center;
          margin-bottom: 24px;
        }

        .profile-avatar {
          width: 80px;
          height: 80px;
          border-radius: 50%;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          overflow: hidden;
        }

        .profile-avatar img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }

        .profile-fields {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .profile-field {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .profile-label {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
        }

        .profile-input {
          padding: 8px 12px;
          font-size: 14px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
          outline: none;
        }

        .profile-input:focus {
          border-color: var(--color-border-focus);
        }

        .profile-readonly {
          font-size: 14px;
          color: var(--color-text-secondary);
          padding: 8px 0;
        }

        .profile-role-badge {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          font-size: 13px;
          font-weight: 500;
          padding: 6px 12px;
          background: var(--color-info-light);
          color: var(--color-info);
          border-radius: var(--radius-md);
          width: fit-content;
        }

        .profile-schools {
          display: flex;
          flex-wrap: wrap;
          gap: 6px;
        }

        .profile-school-chip {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          padding: 4px 10px;
          background: var(--color-bg-tertiary);
          border-radius: var(--radius-sm);
          color: var(--color-text-secondary);
        }

        .profile-school-chip.platform {
          background: var(--color-success-light);
          color: var(--color-success);
        }

        .profile-no-schools {
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .profile-save-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 6px;
          padding: 10px 20px;
          font-size: 14px;
          font-weight: 500;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: all 0.15s ease;
          margin-top: 8px;
        }

        .profile-save-btn:hover:not(:disabled) {
          opacity: 0.9;
        }

        .profile-save-btn:disabled {
          opacity: 0.4;
          cursor: not-allowed;
        }

        .profile-save-btn.saved {
          background: var(--color-success);
        }

        .spin {
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
