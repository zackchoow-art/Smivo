/**
 * Admin user management page — sysadmin only.
 * Supports listing admins, assigning 5-level roles, and multi-school scope assignment.
 *
 * Now reads from the unified admin_roles table (migration 00102).
 */
import { useState } from 'react';
import { showToast } from '@/hooks/useToast';
import { Shield, Plus, Loader2, School, Info, Search } from 'lucide-react';
import { useAdmins, useCreateAdminRole, useDeleteAdminRole, useSearchUsers, useRemoveAdmin, useUpdateAdminRole } from '@/hooks/useAdmins';
import { useColleges } from '@/hooks/useColleges';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLE_LABELS } from '@/lib/constants';
import type { AdminRoleName, AdminUserInfo } from '@/types';
import { CreateAdminDialog } from '@/components/users/CreateAdminDialog';

const ROLE_COLORS: Record<string, string> = {
  sysadmin:          'var(--color-danger)',
  platform_admin:    '#7048e8',
  platform_reviewer: 'var(--color-info)',
  school_admin:      'var(--color-success)',
  school_reviewer:   '#20c997',
};

const ROLE_OPTIONS: { value: AdminRoleName; label: string; hint: string }[] = [
  { value: 'platform_admin',    label: 'Platform Admin',     hint: 'Cross-school management' },
  { value: 'platform_reviewer', label: 'Platform Reviewer',  hint: 'Cross-school moderation' },
  { value: 'school_admin',      label: 'School Admin',       hint: 'Management within school(s)' },
  { value: 'school_reviewer',   label: 'School Reviewer',    hint: 'Campus moderation' },
];

// ── School picker (checkboxes for all non-sysadmin roles) ─────────────────────

interface SchoolPickerProps {
  role: AdminRoleName;
  selected: string[];
  onChange: (ids: string[]) => void;
  colleges: { id: string; name: string }[];
}

function SchoolPicker({ role, selected, onChange, colleges }: SchoolPickerProps) {
  if (role === 'sysadmin') {
    return (
      <p className="am-scope-note">
        <Info size={12} /> Super admin has access to all schools automatically.
      </p>
    );
  }

  // Platform-level roles also don't need school selection
  if (role === 'platform_admin' || role === 'platform_reviewer') {
    return (
      <p className="am-scope-note">
        <Info size={12} /> Platform-level roles automatically have access to all schools.
      </p>
    );
  }

  const toggle = (id: string) => {
    onChange(selected.includes(id) ? selected.filter((c) => c !== id) : [...selected, id]);
  };

  return (
    <div className="am-ff">
      <label className="am-fl">School Access</label>
      <div className="am-chips">
        {colleges.map((c) => (
          <button
            key={c.id}
            className={`am-chip ${selected.includes(c.id) ? 'sel' : ''}`}
            onClick={() => toggle(c.id)}
          >
            <School size={11} />
            {c.name}
          </button>
        ))}
      </div>
      {selected.length === 0 && (
        <p className="am-scope-warn">⚠ No schools selected — this admin will have no data access.</p>
      )}
    </div>
  );
}

// ── Main page ─────────────────────────────────────────────────────────────────

export function AdminsPage() {
  const { data: admins, isLoading } = useAdmins();
  const { data: colleges }          = useColleges();
  const { role: myRole }            = useAdminRole();
  const createRole                  = useCreateAdminRole();
  const deleteRole                  = useDeleteAdminRole();
  const updateRole                  = useUpdateAdminRole();
  const removeAdmin                 = useRemoveAdmin();

  const [showAdd, setShowAdd]     = useState(false);
  const [showPromote, setShowPromote] = useState(false);

  // Promote existing user state
  const [searchQ, setSearchQ]     = useState('');
  const { data: searchResults }   = useSearchUsers(searchQ);
  const [selUser, setSelUser]     = useState<{ id: string; name: string; email: string } | null>(null);
  const [selRole, setSelRole]     = useState<AdminRoleName>('school_reviewer');
  const [selSchools, setSelSchools] = useState<string[]>([]);

  const [editingAdmin, setEditingAdmin] = useState<AdminUserInfo | null>(null);

  if (myRole !== 'sysadmin') {
    return (
      <div className="am-denied">
        <Shield size={48} color="var(--color-text-tertiary)" />
        <h2>Access Denied</h2>
        <p>Only the Super Admin can manage administrators.</p>
      </div>
    );
  }

  if (isLoading) return <div className="am-ld"><Loader2 size={24} className="spin" /> Loading admins...</div>;

  const handlePromote = async () => {
    if (!selUser) return;
    try {
      const scopeType = ['sysadmin', 'platform_admin', 'platform_reviewer'].includes(selRole) ? 'platform' : 'school';

      if (scopeType === 'school' && selSchools.length > 0) {
        // Create one role record per school
        for (const schoolId of selSchools) {
          await createRole.mutateAsync({
            userId: selUser.id,
            role: selRole,
            scopeType: 'school',
            scopeId: schoolId,
          });
        }
      } else {
        // Platform-level: single record, no scope_id
        await createRole.mutateAsync({
          userId: selUser.id,
          role: selRole,
          scopeType,
          scopeId: null,
        });
      }

      showToast('Admin role assigned successfully', 'success');
      setShowPromote(false);
      setSelUser(null);
      setSearchQ('');
      setSelSchools([]);
    } catch (err: any) {
      showToast(err?.message || 'Failed to assign role', 'error');
    }
  };

  const handleRevokeAll = async (admin: AdminUserInfo) => {
    const confirmRemove = window.confirm(`Are you sure you want to revoke all admin privileges for ${admin.display_name || admin.email}?`);
    if (!confirmRemove) return;
    try {
      await removeAdmin.mutateAsync({ userId: admin.user_id });
      showToast('Admin privileges revoked', 'success');
    } catch (err: any) {
      showToast(err?.message || 'Failed to revoke admin', 'error');
    }
  };

  const handleDeleteRole = async (roleId: string) => {
    try {
      await deleteRole.mutateAsync({ roleId });
      showToast('Role removed', 'success');
    } catch (err: any) {
      showToast(err?.message || 'Failed to remove role', 'error');
    }
  };

  // NOTE: Handle inline role change for a specific role record
  const handleRoleChange = async (roleId: string, newRole: AdminRoleName) => {
    try {
      await updateRole.mutateAsync({ roleId, role: newRole });
      showToast('Role updated', 'success');
    } catch (err: any) {
      showToast(err?.message || 'Failed to update role', 'error');
    }
  };

  // NOTE: Filter out sysadmin from the displayed list — sysadmin should
  // never be editable or visible in the admin management UI.
  const visibleAdmins = admins?.filter((a) => a.highest_role !== 'sysadmin') ?? [];

  return (
    <div className="am-page">
      {/* Header */}
      <div className="am-hdr">
        <div>
          <h1 className="am-title">Admin Management</h1>
          <p className="am-sub">{visibleAdmins.length} administrators</p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button className="am-add" onClick={() => { setShowPromote(true); setShowAdd(false); }}>
            <Plus size={14} /> Promote existing user
          </button>
          <button className="am-add" onClick={() => { setShowAdd(true); setShowPromote(false); }}>
            <Plus size={14} /> Add new user
          </button>
        </div>
      </div>

      {showAdd && (
        <CreateAdminDialog onClose={() => setShowAdd(false)} />
      )}

      {/* Promote form */}
      {showPromote && (
        <div className="am-form">
          <h3 className="am-fh">Promote Existing User</h3>

          <div className="am-search">
            <Search size={14} />
            <input
              placeholder="Search users by name or email..."
              value={searchQ}
              onChange={(e) => { setSearchQ(e.target.value); setSelUser(null); }}
              className="am-si"
            />
          </div>

          {searchResults && searchResults.length > 0 && !selUser && (
            <div className="am-sr">
              {searchResults.map((u) => (
                <button key={u.id} className="am-sri"
                  onClick={() => { setSelUser({ id: u.id, name: u.display_name || u.email, email: u.email }); setSearchQ(u.display_name || u.email); }}>
                  <span className="am-srn">{u.display_name || u.email}</span>
                  <span className="am-sre">{u.email}</span>
                </button>
              ))}
            </div>
          )}

          {selUser && (
            <>
              <div className="am-ff">
                <label className="am-fl">Role</label>
                <div className="am-role-grid">
                  {ROLE_OPTIONS.map((opt) => (
                    <button
                      key={opt.value}
                      className={`am-role-btn ${selRole === opt.value ? 'sel' : ''}`}
                      style={{ '--role-color': ROLE_COLORS[opt.value] } as any}
                      onClick={() => { setSelRole(opt.value); setSelSchools([]); }}
                    >
                      <span className="am-role-name">{opt.label}</span>
                      <span className="am-role-hint">{opt.hint}</span>
                    </button>
                  ))}
                </div>
              </div>

              <SchoolPicker
                role={selRole}
                selected={selSchools}
                onChange={setSelSchools}
                colleges={colleges ?? []}
              />

              <div className="am-fa">
                <button className="am-fc" onClick={() => { setShowPromote(false); setSelUser(null); }}>Cancel</button>
                <button className="am-fs" onClick={handlePromote} disabled={createRole.isPending}>
                  {createRole.isPending ? <Loader2 size={14} className="spin" /> : 'Promote to Admin'}
                </button>
              </div>
            </>
          )}
        </div>
      )}

      {/* Admin list */}
      <div className="am-list">
        {visibleAdmins.map((admin) => (
          <div key={admin.user_id} className="am-card">
            <div className="am-cr">
              <div className="am-cn"
                onClick={() => setEditingAdmin(editingAdmin?.user_id === admin.user_id ? null : admin)}
                style={{ cursor: 'pointer' }}>
                <h3 className="am-cname">{admin.display_name || admin.email}</h3>
                <span className="am-ce">{admin.email}</span>
              </div>
              <div className="am-ca">
                {editingAdmin?.user_id === admin.user_id ? (
                  // Inline role editor — select dropdown
                  <select
                    className="am-role-select"
                    value={admin.roles[0]?.role || ''}
                    onChange={(e) => {
                      if (admin.roles[0]) {
                        handleRoleChange(admin.roles[0].id, e.target.value as AdminRoleName);
                      }
                    }}
                  >
                    {ROLE_OPTIONS.map((opt) => (
                      <option key={opt.value} value={opt.value}>{opt.label}</option>
                    ))}
                  </select>
                ) : (
                  admin.highest_role && (
                    <span className="am-role-badge" style={{
                      color: ROLE_COLORS[admin.highest_role],
                      borderColor: (ROLE_COLORS[admin.highest_role] ?? '') + '40',
                    }}>
                      {ADMIN_ROLE_LABELS[admin.highest_role] ?? admin.highest_role}
                    </span>
                  )
                )}
              </div>
            </div>

            {/* Role records list — only show for multi-role admins */}
            {admin.roles.length > 1 && (
              <div className="am-roles-list">
                {admin.roles.map((r) => (
                  <div key={r.id} className="am-role-row">
                    {editingAdmin?.user_id === admin.user_id ? (
                      <select
                        className="am-role-select-sm"
                        value={r.role}
                        onChange={(e) => handleRoleChange(r.id, e.target.value as AdminRoleName)}
                      >
                        {ROLE_OPTIONS.map((opt) => (
                          <option key={opt.value} value={opt.value}>{opt.label}</option>
                        ))}
                      </select>
                    ) : (
                      <span className="am-role-tag" style={{ color: ROLE_COLORS[r.role] }}>
                        {ADMIN_ROLE_LABELS[r.role]}
                      </span>
                    )}
                    <span className="am-scope-tag">
                      {r.scope_type === 'platform' ? 'Platform' : admin.school_names.find((_, i) => admin.roles.filter(rr => rr.scope_type === 'school')[i]?.scope_id === r.scope_id) ?? r.scope_id}
                    </span>
                    {editingAdmin?.user_id === admin.user_id && (
                      <button className="am-role-del" onClick={() => handleDeleteRole(r.id)}>×</button>
                    )}
                  </div>
                ))}
              </div>
            )}

            {admin.school_names.length > 0 && admin.roles.length <= 1 && (
              <div className="am-sc">
                {admin.school_names.map((name, i) => (
                  <span key={i} className="am-st"><School size={10} />{name}</span>
                ))}
              </div>
            )}

            {/* Edit actions */}
            {editingAdmin?.user_id === admin.user_id && (
              <div className="am-fa" style={{ marginTop: 12 }}>
                <button className="am-fc" style={{ color: 'var(--color-danger)', borderColor: 'var(--color-danger)' }}
                  onClick={() => handleRevokeAll(admin)}>
                  Revoke All
                </button>
                <button className="am-fc" onClick={() => setEditingAdmin(null)}>Done</button>
              </div>
            )}

            <div className="am-meta tabular-nums">Created {new Date(admin.roles[0]?.created_at ?? '').toLocaleDateString()}</div>
          </div>
        ))}
      </div>

      <style>{`
        .am-page { padding: var(--spacing-page); max-width: 900px; }
        .am-hdr { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px; }
        .am-title { font-size:24px; font-weight:700; color:var(--color-text-primary); }
        .am-sub { font-size:13px; color:var(--color-text-tertiary); margin-top:4px; }
        .am-add { display:flex; align-items:center; gap:4px; padding:8px 16px; font-size:13px;
          background:var(--color-info); color:white; border:none; border-radius:var(--radius-md); cursor:pointer; }
        .am-form { padding:16px; background:var(--color-bg-primary); border:1px solid var(--color-border-light);
          border-radius:var(--radius-lg); margin-bottom:20px; }
        .am-fh { font-size:15px; font-weight:600; color:var(--color-text-primary); }
        .am-search { display:flex; align-items:center; gap:6px; padding:8px 12px; margin-top:12px;
          border:1px solid var(--color-border); border-radius:var(--radius-md); background:var(--color-bg-secondary); }
        .am-si { border:none; outline:none; background:transparent; font-size:13px; color:var(--color-text-primary); width:100%; }
        .am-sr { border:1px solid var(--color-border-light); border-radius:var(--radius-md); margin-top:4px; max-height:180px; overflow-y:auto; }
        .am-sri { display:flex; justify-content:space-between; width:100%; padding:8px 12px; background:none;
          border:none; border-bottom:1px solid var(--color-border-light); cursor:pointer; font-size:13px; text-align:left; }
        .am-sri:hover { background:var(--color-bg-secondary); } .am-sri:last-child { border-bottom:none; }
        .am-srn { font-weight:500; color:var(--color-text-primary); } .am-sre { color:var(--color-text-tertiary); font-size:12px; }
        .am-ff { margin-top:14px; }
        .am-fl { font-size:11px; font-weight:600; text-transform:uppercase; letter-spacing:.04em;
          color:var(--color-text-tertiary); display:block; margin-bottom:6px; }
        .am-fl-hint { font-size:11px; font-weight:400; text-transform:none; color:var(--color-info); }

        /* Role picker grid */
        .am-role-grid { display:grid; grid-template-columns:1fr 1fr; gap:8px; }
        .am-role-btn { display:flex; flex-direction:column; align-items:flex-start; gap:2px;
          padding:10px 12px; border:1.5px solid var(--color-border); border-radius:var(--radius-md);
          background:var(--color-bg-primary); cursor:pointer; text-align:left; transition:all .12s; }
        .am-role-btn:hover { border-color:var(--role-color, var(--color-info)); }
        .am-role-btn.sel { border-color:var(--role-color, var(--color-info));
          background:color-mix(in srgb, var(--role-color, var(--color-info)) 8%, transparent); }
        .am-role-name { font-size:13px; font-weight:600; color:var(--color-text-primary); }
        .am-role-hint { font-size:11px; color:var(--color-text-tertiary); }

        /* School chips */
        .am-chips { display:flex; flex-wrap:wrap; gap:6px; margin-top:4px; }
        .am-chip { display:flex; align-items:center; gap:4px; padding:5px 10px; font-size:12px;
          border:1px solid var(--color-border); border-radius:var(--radius-sm); cursor:pointer;
          background:var(--color-bg-primary); color:var(--color-text-secondary); }
        .am-chip.sel { background:var(--color-info-light); border-color:var(--color-info); color:var(--color-info); }
        .am-scope-note { display:flex; align-items:center; gap:5px; font-size:12px;
          color:var(--color-text-tertiary); margin-top:6px; }
        .am-scope-warn { font-size:12px; color:#e67700; margin-top:4px; }

        /* Form actions */
        .am-fa { display:flex; justify-content:flex-end; gap:8px; margin-top:16px;
          padding-top:12px; border-top:1px solid var(--color-border-light); }
        .am-fc, .am-fs { padding:7px 16px; font-size:13px; border-radius:var(--radius-md);
          cursor:pointer; border:1px solid var(--color-border); display:flex; align-items:center; gap:4px; }
        .am-fc { background:var(--color-bg-primary); color:var(--color-text-secondary); }
        .am-fs { background:var(--color-info); color:white; border-color:var(--color-info); }
        .am-fs:disabled { opacity:.5; cursor:not-allowed; }

        /* Admin card */
        .am-list { display:flex; flex-direction:column; gap:8px; }
        .am-card { background:var(--color-bg-primary); border:1px solid var(--color-border-light);
          border-radius:var(--radius-lg); padding:14px 16px; }
        .am-cr { display:flex; justify-content:space-between; align-items:center; }
        .am-cname { font-size:14px; font-weight:600; color:var(--color-text-primary);
          text-decoration:underline; text-decoration-color:transparent; }
        .am-cn:hover .am-cname { text-decoration-color:var(--color-info); }
        .am-ce { font-size:12px; color:var(--color-text-tertiary); }
        .am-ca { display:flex; align-items:center; gap:10px; }
        .am-role-badge { font-size:12px; font-weight:600; padding:3px 10px;
          border:1px solid; border-radius:var(--radius-sm); }
        .am-sc { display:flex; flex-wrap:wrap; gap:4px; margin-top:8px; }
        .am-st { display:flex; align-items:center; gap:3px; font-size:11px; padding:2px 8px;
          background:var(--color-bg-tertiary); border-radius:var(--radius-sm); color:var(--color-text-secondary); }
        .am-meta { font-size:11px; color:var(--color-text-tertiary); margin-top:8px; }
        .am-ld, .am-denied { display:flex; flex-direction:column; align-items:center;
          justify-content:center; gap:12px; padding:80px 0; color:var(--color-text-tertiary);
          font-size:14px; text-align:center; }
        .am-denied h2 { font-size:18px; color:var(--color-text-primary); }
        .spin { animation:spin 1s linear infinite; } @keyframes spin { to { transform:rotate(360deg); } }

        /* Role records list */
        .am-roles-list { display:flex; flex-direction:column; gap:4px; margin-top:8px;
          padding:8px; background:var(--color-bg-secondary); border-radius:var(--radius-sm); }
        .am-role-row { display:flex; align-items:center; gap:8px; font-size:12px; }
        .am-role-tag { font-weight:600; }
        .am-scope-tag { color:var(--color-text-tertiary); }
        .am-role-del { background:none; border:none; cursor:pointer; color:var(--color-danger);
          font-size:16px; font-weight:bold; padding:0 4px; }

        /* Inline role editor dropdowns */
        .am-role-select { padding:4px 8px; font-size:12px; font-weight:600; border:1px solid var(--color-info);
          border-radius:var(--radius-sm); background:var(--color-bg-primary); color:var(--color-info);
          cursor:pointer; outline:none; }
        .am-role-select:focus { box-shadow:0 0 0 2px color-mix(in srgb, var(--color-info) 20%, transparent); }
        .am-role-select-sm { padding:2px 6px; font-size:11px; font-weight:600; border:1px solid var(--color-border);
          border-radius:var(--radius-sm); background:var(--color-bg-primary); color:var(--color-text-primary);
          cursor:pointer; outline:none; }
      `}</style>
    </div>
  );
}
