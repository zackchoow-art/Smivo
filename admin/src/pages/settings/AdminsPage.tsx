/**
 * Admin user management page — sysadmin only.
 * Supports listing admins, assigning 5-level roles, and multi-school scope assignment.
 *
 * School scope rules:
 *   sysadmin           — no scope selector (has all schools)
 *   platform_admin     — multi-school checkboxes
 *   platform_reviewer  — multi-school checkboxes
 *   school_admin       — single or multi-school checkboxes
 *   school_reviewer    — single or multi-school checkboxes
 */
import { useState } from 'react';
import { showToast } from '@/hooks/useToast';
import { Shield, Plus, Loader2, ToggleLeft, ToggleRight, School, Info, Search } from 'lucide-react';
import { useAdmins, useUpdateAdminRole, useToggleAdminActive, useUpdateAdminScopes, useCreateAdmin, useSearchUsers, useRemoveAdmin } from '@/hooks/useAdmins';
import { useColleges } from '@/hooks/useColleges';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLE_LABELS } from '@/lib/constants';
import type { AdminRole, AdminUserWithScopes } from '@/types';
import { CreateAdminDialog } from '@/components/users/CreateAdminDialog';

const ROLE_COLORS: Record<string, string> = {
  sysadmin:          'var(--color-danger)',
  platform_admin:    '#7048e8',
  platform_reviewer: 'var(--color-info)',
  school_admin:      'var(--color-success)',
  school_reviewer:   '#20c997',
};

const ROLE_OPTIONS: { value: AdminRole | 'normal_user'; label: string; hint: string }[] = [
  { value: 'sysadmin',          label: 'Super Admin',        hint: 'Full control — only one allowed' },
  { value: 'platform_admin',    label: 'Platform Admin',     hint: 'Cross-school management' },
  { value: 'platform_reviewer', label: 'Platform Reviewer',  hint: 'Cross-school moderation' },
  { value: 'school_admin',      label: 'School Admin',       hint: 'Management within school(s)' },
  { value: 'school_reviewer',   label: 'School Reviewer',    hint: 'Campus moderation' },
  { value: 'normal_user',       label: 'Normal User',        hint: 'Revoke all admin privileges' },
];

// ── School picker (checkboxes for all non-sysadmin roles) ─────────────────────

interface SchoolPickerProps {
  role: AdminRole;
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

  const toggle = (id: string) => {
    if (role.startsWith('school_')) {
      onChange([id]);
    } else {
      onChange(selected.includes(id) ? selected.filter((c) => c !== id) : [...selected, id]);
    }
  };

  return (
    <div className="am-ff">
      <label className="am-fl">
        School Access
        {role.startsWith('platform_') && (
          <span className="am-fl-hint"> — multiple schools allowed</span>
        )}
      </label>
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
  const updateRole                  = useUpdateAdminRole();
  const updateScopes                = useUpdateAdminScopes();
  const toggleActive                = useToggleAdminActive();
  const createAdmin                 = useCreateAdmin();
  
  const [showAdd, setShowAdd]     = useState(false);
  const [showPromote, setShowPromote] = useState(false);
  
  // Promote existing user state
  const [searchQ, setSearchQ]     = useState('');
  const { data: searchResults }   = useSearchUsers(searchQ);
  const [selUser, setSelUser]     = useState<{ id: string; name: string; email: string } | null>(null);
  const [selRole, setSelRole]     = useState<AdminRole>('school_reviewer');
  const [selSchools, setSelSchools] = useState<string[]>([]);

  const [editingAdmin, setEditingAdmin] = useState<AdminUserWithScopes | null>(null);
  const [editRole, setEditRole]         = useState<AdminRole | 'normal_user'>('school_reviewer');
  const [editSchools, setEditSchools]   = useState<string[]>([]);

  const removeAdmin                 = useRemoveAdmin();

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


  const handleSaveEdit = async () => {
    if (!editingAdmin) return;
    try {
      if (editRole === 'normal_user') {
        const confirmRemove = window.confirm('Are you sure you want to revoke all admin privileges for this user?');
        if (!confirmRemove) return;
        await removeAdmin.mutateAsync({ userId: editingAdmin.user_id });
      } else {
        if (editRole !== editingAdmin.role) {
          await updateRole.mutateAsync({ userId: editingAdmin.user_id, role: editRole });
        }
        await updateScopes.mutateAsync({
          userId: editingAdmin.user_id,
          collegeIds: editRole === 'sysadmin' ? [] : editSchools,
        });
        showToast('Admin privileges updated successfully', 'success');
      }
      setEditingAdmin(null);
    } catch (err: any) {
      console.error(err);
      showToast(err?.message || 'Failed to update admin', 'error');
    }
  };

  const handlePromote = async () => {
    if (!selUser) return;
    await createAdmin.mutateAsync({
      userId: selUser.id,
      role: selRole,
      displayName: selUser.name,
      email: selUser.email,
      collegeIds: selRole === 'sysadmin' ? [] : selSchools,
    });
    setShowPromote(false);
    setSelUser(null);
    setSearchQ('');
    setSelSchools([]);
  };

  return (
    <div className="am-page">
      {/* Header */}
      <div className="am-hdr">
        <div>
          <h1 className="am-title">Admin Management</h1>
          <p className="am-sub">{admins?.length ?? 0} administrators</p>
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
                  {ROLE_OPTIONS.filter(o => o.value !== 'normal_user').map((opt) => (
                    <button
                      key={opt.value}
                      className={`am-role-btn ${selRole === opt.value ? 'sel' : ''}`}
                      style={{ '--role-color': ROLE_COLORS[opt.value as AdminRole] } as any}
                      onClick={() => { setSelRole(opt.value as AdminRole); setSelSchools([]); }}
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
                <button className="am-fs" onClick={handlePromote} disabled={createAdmin.isPending}>
                  {createAdmin.isPending ? <Loader2 size={14} className="spin" /> : 'Promote to Admin'}
                </button>
              </div>
            </>
          )}
        </div>
      )}

      {/* Admin list */}
      <div className="am-list">
        {admins?.map((admin) => (
          <div key={admin.user_id} className={`am-card ${!admin.is_active ? 'am-ci' : ''}`}>
            {editingAdmin?.user_id === admin.user_id ? (
              <div className="am-ef" style={{ marginTop: '16px', padding: '16px', background: 'var(--color-bg-secondary)', borderRadius: '8px' }}>
                <p className="am-fh" style={{ marginBottom: 12 }}>Edit {admin.display_name || admin.email}</p>

                <div className="am-ff">
                  <label className="am-fl">Change Role</label>
                  <div className="am-role-grid">
                    {ROLE_OPTIONS.map((opt) => (
                      <button
                        key={opt.value}
                        className={`am-role-btn ${editRole === opt.value ? 'sel' : ''}`}
                        style={{ '--role-color': opt.value === 'normal_user' ? 'var(--color-text-tertiary)' : ROLE_COLORS[opt.value as AdminRole] } as any}
                        onClick={() => { setEditRole(opt.value as any); setEditSchools([]); }}
                      >
                        <span className="am-role-name">{opt.label}</span>
                        <span className="am-role-hint">{opt.hint}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {editRole !== 'normal_user' && (
                  <SchoolPicker
                    role={editRole as AdminRole}
                    selected={editSchools}
                    onChange={setEditSchools}
                    colleges={colleges ?? []}
                  />
                )}

                <div className="am-fa">
                  <button className="am-fc" onClick={() => setEditingAdmin(null)}>Cancel</button>
                  <button className="am-fs" onClick={handleSaveEdit}
                    disabled={updateRole.isPending || updateScopes.isPending}>
                    {updateRole.isPending || updateScopes.isPending
                      ? <Loader2 size={14} className="spin" /> : 'Save Changes'}
                  </button>
                </div>
              </div>
            ) : (
              <>
                <div className="am-cr">
                  <div className="am-cn"
                    onClick={() => { setEditingAdmin(admin); setEditRole(admin.role as AdminRole); setEditSchools(admin.scopes.map((s) => s.college_id)); }}
                    style={{ cursor: 'pointer' }}>
                    <h3 className="am-cname">{admin.display_name || admin.email}</h3>
                    <span className="am-ce">{admin.email}</span>
                  </div>
                  <div className="am-ca">
                    <span className="am-role-badge" style={{ color: ROLE_COLORS[admin.role], borderColor: ROLE_COLORS[admin.role] + '40' }}>
                      {ADMIN_ROLE_LABELS[admin.role] ?? admin.role}
                    </span>
                    <button className="am-tg" onClick={() => toggleActive.mutate({ userId: admin.user_id, isActive: !admin.is_active })}>
                      {admin.is_active
                        ? <ToggleRight size={20} color="var(--color-success)" />
                        : <ToggleLeft  size={20} color="var(--color-text-tertiary)" />}
                    </button>
                  </div>
                </div>
                {admin.college_names.length > 0 && (
                  <div className="am-sc">
                    {admin.college_names.map((name, i) => (
                      <span key={i} className="am-st"><School size={10} />{name}</span>
                    ))}
                  </div>
                )}
                {admin.role === 'sysadmin' && (
                  <p className="am-scope-note" style={{ marginTop: 8 }}>
                    <Info size={11} /> Access to all schools
                  </p>
                )}
                <div className="am-meta tabular-nums">Created {new Date(admin.created_at).toLocaleDateString()}</div>
              </>
            )}
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
        .am-ci { opacity:.5; }
        .am-cr { display:flex; justify-content:space-between; align-items:center; }
        .am-cname { font-size:14px; font-weight:600; color:var(--color-text-primary);
          text-decoration:underline; text-decoration-color:transparent; }
        .am-cn:hover .am-cname { text-decoration-color:var(--color-info); }
        .am-ce { font-size:12px; color:var(--color-text-tertiary); }
        .am-ca { display:flex; align-items:center; gap:10px; }
        .am-role-badge { font-size:12px; font-weight:600; padding:3px 10px;
          border:1px solid; border-radius:var(--radius-sm); }
        .am-tg { background:none; border:none; cursor:pointer; padding:2px; display:flex; }
        .am-sc { display:flex; flex-wrap:wrap; gap:4px; margin-top:8px; }
        .am-st { display:flex; align-items:center; gap:3px; font-size:11px; padding:2px 8px;
          background:var(--color-bg-tertiary); border-radius:var(--radius-sm); color:var(--color-text-secondary); }
        .am-meta { font-size:11px; color:var(--color-text-tertiary); margin-top:8px; }
        .am-ld, .am-denied { display:flex; flex-direction:column; align-items:center;
          justify-content:center; gap:12px; padding:80px 0; color:var(--color-text-tertiary);
          font-size:14px; text-align:center; }
        .am-denied h2 { font-size:18px; color:var(--color-text-primary); }
        .spin { animation:spin 1s linear infinite; } @keyframes spin { to { transform:rotate(360deg); } }
      `}</style>
    </div>
  );
}
