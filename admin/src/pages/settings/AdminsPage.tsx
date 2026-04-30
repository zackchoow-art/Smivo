/**
 * Admin user management page.
 * Supports listing admins, assigning roles, toggling active, managing scopes.
 */
import { useState } from 'react';
import { Shield, Plus, Loader2, ToggleLeft, ToggleRight, School, Search } from 'lucide-react';
import { useAdmins, useCreateAdmin, useUpdateAdminRole, useToggleAdminActive, useSearchUsers } from '@/hooks/useAdmins';
import { useColleges } from '@/hooks/useColleges';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';
import type { AdminRole } from '@/types';

const ROLE_COLORS: Record<string, string> = {
  platform_super_admin: 'var(--color-danger)',
  platform_moderator: 'var(--color-info)',
  school_admin: 'var(--color-success)',
};

export function AdminsPage() {
  const { data: admins, isLoading } = useAdmins();
  const { data: colleges } = useColleges();
  const { role: myRole } = useAdminRole();
  const createAdmin = useCreateAdmin();
  const updateRole = useUpdateAdminRole();
  const toggleActive = useToggleAdminActive();

  const [showAdd, setShowAdd] = useState(false);
  const [searchQ, setSearchQ] = useState('');
  const { data: searchResults } = useSearchUsers(searchQ);

  const [selUser, setSelUser] = useState<{ id: string; name: string; email: string } | null>(null);
  const [selRole, setSelRole] = useState<AdminRole>('school_admin');
  const [selColleges, setSelColleges] = useState<string[]>([]);

  const isSuperAdmin = myRole === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  if (!isSuperAdmin) {
    return <div className="am-denied"><Shield size={48} color="var(--color-text-tertiary)"/><h2>Access Denied</h2><p>Only Super Admins can manage administrators.</p></div>;
  }

  const handleCreate = async () => {
    if (!selUser) return;
    await createAdmin.mutateAsync({
      userId: selUser.id, role: selRole,
      displayName: selUser.name, email: selUser.email,
      collegeIds: selColleges,
    });
    setShowAdd(false); setSelUser(null); setSearchQ(''); setSelColleges([]);
  };

  const toggleCollege = (cid: string) => {
    setSelColleges(prev => prev.includes(cid) ? prev.filter(c => c !== cid) : [...prev, cid]);
  };

  if (isLoading) return <div className="am-ld"><Loader2 size={24} className="spin"/> Loading admins...</div>;

  return (
    <div className="am-page">
      <div className="am-hdr">
        <div><h1 className="am-title">Admin Management</h1><p className="am-sub">{admins?.length ?? 0} administrators</p></div>
        <button className="am-add" onClick={() => setShowAdd(true)}><Plus size={14}/> Add Admin</button>
      </div>

      {showAdd && <div className="am-form">
        <h3 className="am-fh">Add New Admin</h3>
        <div className="am-search">
          <Search size={14}/><input placeholder="Search users by name or email..." value={searchQ} onChange={e => { setSearchQ(e.target.value); setSelUser(null); }} className="am-si"/>
        </div>
        {searchResults && searchResults.length > 0 && !selUser && <div className="am-sr">
          {searchResults.map(u => <button key={u.id} className="am-sri" onClick={() => { setSelUser({ id: u.id, name: u.display_name || u.email, email: u.email }); setSearchQ(u.display_name || u.email); }}>
            <span className="am-srn">{u.display_name || u.email}</span><span className="am-sre">{u.email}</span>
          </button>)}
        </div>}
        {selUser && <>
          <div className="am-ff"><label className="am-fl">Role</label>
            <select value={selRole} onChange={e => setSelRole(e.target.value as AdminRole)} className="am-sel">
              <option value="school_admin">School Admin</option>
              <option value="platform_moderator">Platform Moderator</option>
              <option value="platform_super_admin">Super Admin</option>
            </select>
          </div>
          {selRole === 'school_admin' && <div className="am-ff"><label className="am-fl">Schools</label>
            <div className="am-chips">{colleges?.map(c => <button key={c.id} className={`am-chip ${selColleges.includes(c.id)?'sel':''}`} onClick={() => toggleCollege(c.id)}><School size={12}/>{c.name}</button>)}</div>
          </div>}
          <div className="am-fa">
            <button className="am-fc" onClick={() => { setShowAdd(false); setSelUser(null); }}>Cancel</button>
            <button className="am-fs" onClick={handleCreate} disabled={createAdmin.isPending}>{createAdmin.isPending?<Loader2 size={14} className="spin"/>:'Create'}</button>
          </div>
        </>}
      </div>}

      <div className="am-list">
        {admins?.map(admin => <div key={admin.user_id} className={`am-card ${!admin.is_active?'am-ci':''}`}>
          <div className="am-cr">
            <div className="am-cn">
              <h3>{admin.display_name || admin.email}</h3>
              <span className="am-ce">{admin.email}</span>
            </div>
            <div className="am-ca">
              <select value={admin.role} onChange={e => updateRole.mutate({ userId: admin.user_id, role: e.target.value })} className="am-rs" style={{ color: ROLE_COLORS[admin.role] }}>
                <option value="school_admin">School Admin</option>
                <option value="platform_moderator">Moderator</option>
                <option value="platform_super_admin">Super Admin</option>
              </select>
              <button className="am-tg" onClick={() => toggleActive.mutate({ userId: admin.user_id, isActive: !admin.is_active })}>
                {admin.is_active ? <ToggleRight size={20} color="var(--color-success)"/> : <ToggleLeft size={20} color="var(--color-text-tertiary)"/>}
              </button>
            </div>
          </div>
          {admin.college_names.length > 0 && <div className="am-sc">
            {admin.college_names.map((name, i) => <span key={i} className="am-st"><School size={10}/>{name}</span>)}
          </div>}
          <div className="am-meta tabular-nums">Created {new Date(admin.created_at).toLocaleDateString()}</div>
        </div>)}
      </div>

      <style>{`
.am-page{padding:var(--spacing-page)}
.am-hdr{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px}
.am-title{font-size:24px;font-weight:700;color:var(--color-text-primary)}
.am-sub{font-size:13px;color:var(--color-text-tertiary);margin-top:4px}
.am-add{display:flex;align-items:center;gap:4px;padding:8px 16px;font-size:13px;background:var(--color-info);color:white;border:none;border-radius:var(--radius-md);cursor:pointer}
.am-form{padding:16px;background:var(--color-bg-primary);border:1px solid var(--color-border-light);border-radius:var(--radius-lg);margin-bottom:20px}
.am-fh{font-size:15px;font-weight:600;margin-bottom:12px;color:var(--color-text-primary)}
.am-search{display:flex;align-items:center;gap:6px;padding:8px 12px;border:1px solid var(--color-border);border-radius:var(--radius-md);background:var(--color-bg-secondary)}
.am-si{border:none;outline:none;background:transparent;font-size:13px;color:var(--color-text-primary);width:100%}
.am-sr{border:1px solid var(--color-border-light);border-radius:var(--radius-md);margin-top:4px;max-height:200px;overflow-y:auto}
.am-sri{display:flex;justify-content:space-between;width:100%;padding:8px 12px;background:none;border:none;border-bottom:1px solid var(--color-border-light);cursor:pointer;font-size:13px;text-align:left}
.am-sri:hover{background:var(--color-bg-secondary)}.am-sri:last-child{border-bottom:none}
.am-srn{font-weight:500;color:var(--color-text-primary)}.am-sre{color:var(--color-text-tertiary);font-size:12px}
.am-ff{margin-top:12px}.am-fl{font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;color:var(--color-text-tertiary);display:block;margin-bottom:4px}
.am-sel{padding:7px 10px;font-size:13px;border:1px solid var(--color-border);border-radius:var(--radius-sm);background:var(--color-bg-secondary);color:var(--color-text-primary);width:100%}
.am-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:4px}
.am-chip{display:flex;align-items:center;gap:4px;padding:4px 10px;font-size:12px;border:1px solid var(--color-border);border-radius:var(--radius-sm);cursor:pointer;background:var(--color-bg-primary);color:var(--color-text-secondary)}
.am-chip.sel{background:var(--color-info-light);border-color:var(--color-info);color:var(--color-info)}
.am-fa{display:flex;justify-content:flex-end;gap:8px;margin-top:16px;padding-top:12px;border-top:1px solid var(--color-border-light)}
.am-fc,.am-fs{padding:6px 16px;font-size:13px;border-radius:var(--radius-md);cursor:pointer;border:1px solid var(--color-border);display:flex;align-items:center;gap:4px}
.am-fc{background:var(--color-bg-primary);color:var(--color-text-secondary)}.am-fs{background:var(--color-info);color:white;border-color:var(--color-info)}.am-fs:disabled{opacity:.5}
.am-list{display:flex;flex-direction:column;gap:8px}
.am-card{background:var(--color-bg-primary);border:1px solid var(--color-border-light);border-radius:var(--radius-lg);padding:14px 16px;transition:box-shadow .12s}
.am-card:hover{box-shadow:var(--shadow-card-hover)}.am-ci{opacity:.5}
.am-cr{display:flex;justify-content:space-between;align-items:center}
.am-cn h3{font-size:14px;font-weight:600;color:var(--color-text-primary)}.am-ce{font-size:12px;color:var(--color-text-tertiary)}
.am-ca{display:flex;align-items:center;gap:8px}
.am-rs{padding:4px 8px;font-size:12px;font-weight:600;border:1px solid var(--color-border);border-radius:var(--radius-sm);background:var(--color-bg-primary);cursor:pointer}
.am-tg{background:none;border:none;cursor:pointer;padding:2px;display:flex}
.am-sc{display:flex;flex-wrap:wrap;gap:4px;margin-top:8px}
.am-st{display:flex;align-items:center;gap:3px;font-size:11px;padding:2px 8px;background:var(--color-bg-tertiary);border-radius:var(--radius-sm);color:var(--color-text-secondary)}
.am-meta{font-size:11px;color:var(--color-text-tertiary);margin-top:8px}
.am-ld,.am-denied{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;padding:80px 0;color:var(--color-text-tertiary);font-size:14px;text-align:center}
.am-denied h2{font-size:18px;color:var(--color-text-primary)}
.spin{animation:spin 1s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}
      `}</style>
    </div>
  );
}
