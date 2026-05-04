/**
 * Admin profile settings page.
 * Shows current admin's info from the unified admin_roles table.
 */
import { useState, useEffect } from 'react';
import { User, Shield, School, Save, Loader2, Check } from 'lucide-react';
import { useAuthStore, getHighestRole, isSysadmin } from '@/stores/auth-store';
import { supabase } from '@/lib/supabase';
import { TABLES, ADMIN_ROLE_LABELS } from '@/lib/constants';
import { showToast } from '@/hooks/useToast';

export function ProfilePage() {
  const { roles } = useAuthStore();
  const [profile, setProfile] = useState<{ display_name: string; email: string; avatar_url: string | null } | null>(null);
  const [displayName, setDisplayName] = useState('');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const highestRole = getHighestRole(roles);
  const userId = roles[0]?.user_id;

  // Fetch user_profiles for display
  useEffect(() => {
    if (!userId) return;
    supabase
      .from(TABLES.USER_PROFILES)
      .select('display_name, email, avatar_url')
      .eq('id', userId)
      .single()
      .then(({ data }) => {
        if (data) {
          setProfile(data);
          setDisplayName(data.display_name ?? '');
        }
      });
  }, [userId]);

  if (!profile || !userId) return null;

  const handleSave = async () => {
    setSaving(true);
    setSaved(false);

    try {
      const { error } = await supabase
        .from(TABLES.USER_PROFILES)
        .update({
          display_name: displayName,
          updated_at: new Date().toISOString(),
        })
        .eq('id', userId);

      if (error) throw error;

      setProfile({ ...profile, display_name: displayName });
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      console.error('Failed to update profile:', err);
      showToast('Failed to save profile. Please try again.', 'error', 5000);
    } finally {
      setSaving(false);
    }
  };

  // Derive school names from school-scoped roles
  const schoolScopeIds = roles
    .filter((r) => r.is_active && r.scope_type === 'school' && r.scope_id)
    .map((r) => r.scope_id!);

  return (
    <div className="profile-page">
      <h1 className="profile-title">Profile Settings</h1>
      <p className="profile-subtitle">Manage your admin account information.</p>

      <div className="profile-card">
        {/* Avatar */}
        <div className="profile-avatar-section">
          <div className="profile-avatar">
            {profile.avatar_url ? (
              <img src={profile.avatar_url} alt={profile.display_name ?? 'Admin'} />
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
            <div className="profile-readonly">{profile.email}</div>
          </div>

          {/* Role — read only */}
          <div className="profile-field">
            <label className="profile-label">Role</label>
            <div className="profile-role-badge">
              <Shield size={14} />
              {highestRole ? (ADMIN_ROLE_LABELS[highestRole] ?? highestRole) : 'No role'}
            </div>
            {roles.length > 1 && (
              <div style={{ marginTop: 6, display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                {roles.filter((r) => r.is_active).map((r) => (
                  <span key={r.id} style={{
                    fontSize: 11, padding: '2px 8px',
                    background: 'var(--color-bg-tertiary)',
                    borderRadius: 'var(--radius-sm)',
                    color: 'var(--color-text-secondary)',
                  }}>
                    {ADMIN_ROLE_LABELS[r.role]} — {r.scope_type === 'platform' ? 'Platform' : r.scope_id?.slice(0, 8) + '…'}
                  </span>
                ))}
              </div>
            )}
          </div>

          {/* Authorized Schools */}
          <div className="profile-field">
            <label className="profile-label">Authorized Schools</label>
            <div className="profile-schools">
              {isSysadmin(roles) || roles.some((r) => r.is_active && r.scope_type === 'platform') ? (
                <div className="profile-school-chip platform">
                  🌐 All Schools (Platform-wide)
                </div>
              ) : schoolScopeIds.length > 0 ? (
                schoolScopeIds.map((id) => (
                  <div key={id} className="profile-school-chip">
                    <School size={12} />
                    {id.slice(0, 8)}…
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
            disabled={saving || displayName === profile.display_name}
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
        .profile-page { padding: var(--spacing-page); max-width: 600px; }
        .profile-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); }
        .profile-subtitle { font-size: 13px; color: var(--color-text-tertiary); margin-top: 4px; margin-bottom: 24px; }
        .profile-card { background: var(--color-bg-primary); border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg); padding: 24px; }
        .profile-avatar-section { display: flex; justify-content: center; margin-bottom: 24px; }
        .profile-avatar { width: 80px; height: 80px; border-radius: 50%; background: var(--color-bg-tertiary);
          display: flex; align-items: center; justify-content: center; overflow: hidden; }
        .profile-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .profile-fields { display: flex; flex-direction: column; gap: 16px; }
        .profile-field { display: flex; flex-direction: column; gap: 4px; }
        .profile-label { font-size: 11px; font-weight: 600; text-transform: uppercase;
          letter-spacing: 0.04em; color: var(--color-text-tertiary); }
        .profile-input { padding: 8px 12px; font-size: 14px; border: 1px solid var(--color-border);
          border-radius: var(--radius-md); background: var(--color-bg-secondary);
          color: var(--color-text-primary); outline: none; }
        .profile-input:focus { border-color: var(--color-border-focus); }
        .profile-readonly { font-size: 14px; color: var(--color-text-secondary); padding: 8px 0; }
        .profile-role-badge { display: inline-flex; align-items: center; gap: 6px; font-size: 13px;
          font-weight: 500; padding: 6px 12px; background: var(--color-info-light);
          color: var(--color-info); border-radius: var(--radius-md); width: fit-content; }
        .profile-schools { display: flex; flex-wrap: wrap; gap: 6px; }
        .profile-school-chip { display: inline-flex; align-items: center; gap: 4px; font-size: 12px;
          padding: 4px 10px; background: var(--color-bg-tertiary); border-radius: var(--radius-sm);
          color: var(--color-text-secondary); }
        .profile-school-chip.platform { background: var(--color-success-light); color: var(--color-success); }
        .profile-no-schools { font-size: 13px; color: var(--color-text-tertiary); }
        .profile-save-btn { display: flex; align-items: center; justify-content: center; gap: 6px;
          padding: 10px 20px; font-size: 14px; font-weight: 500; background: var(--color-info);
          color: white; border: none; border-radius: var(--radius-md); cursor: pointer;
          transition: all 0.15s ease; margin-top: 8px; }
        .profile-save-btn:hover:not(:disabled) { opacity: 0.9; }
        .profile-save-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .profile-save-btn.saved { background: var(--color-success); }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
