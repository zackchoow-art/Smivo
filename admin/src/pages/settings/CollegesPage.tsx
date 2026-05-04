/**
 * School/College management page.
 * Only accessible to platform_super_admin.
 * Displays schools as cards with create/edit capabilities.
 */
import { useState } from 'react';
import { Plus, School, Globe, Users, MapPin, ExternalLink, Loader2, Download, CheckCircle2 } from 'lucide-react';
import { useColleges, useCreateCollege, useUpdateCollege, useToggleCollegeActive } from '@/hooks/useColleges';
import { useImportAllDefaultsForSchool } from '@/hooks/useSchoolDictData';
import { useAdminRole } from '@/hooks/useAdminRole';
import { useAuthStore } from '@/stores/auth-store';
import { CollegeDialog } from '@/components/settings/CollegeDialog';
import { showToast } from '@/hooks/useToast';
import { ADMIN_ROLES } from '@/lib/constants';
import type { College } from '@/types';

export function CollegesPage() {
  const { data: colleges, isLoading, error } = useColleges();
  const createCollege    = useCreateCollege();
  const updateCollege    = useUpdateCollege();
  const toggleActive     = useToggleCollegeActive();
  const importDefaults   = useImportAllDefaultsForSchool();
  const { role }         = useAdminRole();
  const { roles }        = useAuthStore();
  const adminId          = roles[0]?.user_id ?? '';

  const [dialogOpen, setDialogOpen]       = useState(false);
  const [editingCollege, setEditingCollege] = useState<College | null>(null);
  // Track which school IDs are currently importing
  const [importingIds, setImportingIds]   = useState<Set<string>>(new Set());
  // Track last import result per school: { categories, conditions, pickupLocations }
  const [importResults, setImportResults] = useState<Record<string, { total: number; detail: string }>>({});

  const isSuperAdmin = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  // RBAC gate — only super admins can see this page
  if (!isSuperAdmin) {
    return (
      <div className="colleges-denied">
        <School size={48} color="var(--color-text-tertiary)" />
        <h2>Access Denied</h2>
        <p>Only Platform Super Admins can manage schools.</p>
      </div>
    );
  }

  const handleCreate = () => {
    setEditingCollege(null);
    setDialogOpen(true);
  };

  const handleEdit = (college: College) => {
    setEditingCollege(college);
    setDialogOpen(true);
  };

  const handleSubmit = async (data: Partial<College>) => {
    if (editingCollege) {
      await updateCollege.mutateAsync({ id: editingCollege.id, ...data });
    } else {
      await createCollege.mutateAsync(data);
    }
    setDialogOpen(false);
    setEditingCollege(null);
  };

  const handleImportDefaults = async (college: College) => {
    if (importingIds.has(college.id) || !adminId) return;
    setImportingIds(prev => new Set(prev).add(college.id));
    try {
      const result = await importDefaults.mutateAsync({ schoolId: college.id, adminId });
      const total = (result.categories_imported ?? 0)
        + (result.conditions_imported ?? 0)
        + (result.pickup_locations_imported ?? 0);

      const parts: string[] = [];
      if (result.categories_imported)       parts.push(`${result.categories_imported} categories`);
      if (result.conditions_imported)       parts.push(`${result.conditions_imported} conditions`);
      if (result.pickup_locations_imported) parts.push(`${result.pickup_locations_imported} pickup locations`);

      const detail = parts.length > 0 ? parts.join(', ') : 'All already up to date';

      setImportResults(prev => ({ ...prev, [college.id]: { total, detail } }));

      if (total === 0) {
        showToast(`${college.name}: all defaults already present.`, 'info');
      } else {
        showToast(`${college.name}: imported ${parts.join(', ')}.`, 'success');
      }
    } catch (e: any) {
      showToast(`Import failed for ${college.name}: ${e?.message ?? 'unknown error'}`, 'error');
    } finally {
      setImportingIds(prev => { const s = new Set(prev); s.delete(college.id); return s; });
    }
  };

  if (isLoading) {
    return (
      <div className="colleges-loading">
        <Loader2 size={24} className="spin" />
        <span>Loading schools...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="colleges-error">
        Failed to load schools: {(error as Error).message}
      </div>
    );
  }

  return (
    <div className="colleges-page">
      <div className="colleges-header">
        <div>
          <h1 className="colleges-title">School Management</h1>
          <p className="colleges-subtitle">
            {colleges?.length ?? 0} registered schools
          </p>
        </div>
        <button className="colleges-add-btn" onClick={handleCreate}>
          <Plus size={16} />
          Add School
        </button>
      </div>

      <div className="colleges-grid">
        {colleges?.map((college) => (
          <div key={college.id} className={`college-card ${!college.is_active ? 'inactive' : ''}`}>
            {/* Color bar */}
            <div
              className="college-color-bar"
              style={{ background: college.primary_color || 'var(--color-info)' }}
            />

            <div className="college-card-body">
              <div className="college-card-header">
                <div className="college-name-row">
                  <h3 className="college-name">{college.name}</h3>
                  {!college.is_active && (
                    <span className="college-inactive-badge">Inactive</span>
                  )}
                </div>
                <code className="college-slug">{college.slug}</code>
              </div>

              <div className="college-meta">
                <div className="college-meta-item">
                  <Globe size={12} />
                  <span>{college.email_domain}</span>
                </div>
                {college.student_count && (
                  <div className="college-meta-item">
                    <Users size={12} />
                    <span className="tabular-nums">
                      {college.student_count.toLocaleString()} students
                    </span>
                  </div>
                )}
                {college.city && college.state && (
                  <div className="college-meta-item">
                    <MapPin size={12} />
                    <span>{college.city}, {college.state}</span>
                  </div>
                )}
                {college.website_url && (
                  <div className="college-meta-item">
                    <ExternalLink size={12} />
                    <a href={college.website_url} target="_blank" rel="noopener noreferrer">
                      Website
                    </a>
                  </div>
                )}
              </div>

              {college.description && (
                <p className="college-desc">{college.description}</p>
              )}

              <div className="college-card-actions">
                <button
                  className="college-btn-edit"
                  onClick={() => handleEdit(college)}
                >
                  Edit
                </button>

                {/* One-click "seed all platform defaults" button */}
                <button
                  id={`init-defaults-${college.id}`}
                  className="college-btn-init"
                  onClick={() => handleImportDefaults(college)}
                  disabled={importingIds.has(college.id)}
                  title="Copy platform defaults (categories, conditions, pickup locations) into this school. Skips items that already exist."
                >
                  {importingIds.has(college.id)
                    ? <Loader2 size={12} className="spin" />
                    : <Download size={12} />}
                  Init Defaults
                </button>

                <button
                  className={`college-btn-toggle ${college.is_active ? 'deactivate' : 'activate'}`}
                  onClick={() => toggleActive.mutate({
                    id: college.id,
                    is_active: !college.is_active,
                  })}
                  disabled={toggleActive.isPending}
                >
                  {college.is_active ? 'Deactivate' : 'Activate'}
                </button>
              </div>

              {/* Last import result summary (shown after button click) */}
              {importResults[college.id] && (
                <div className="college-import-result">
                  <CheckCircle2 size={11} />
                  {importResults[college.id]!.total === 0
                    ? 'All defaults already present'
                    : `Last import: ${importResults[college.id]!.detail}`}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Dialog */}
      {dialogOpen && (
        <CollegeDialog
          college={editingCollege}
          onClose={() => { setDialogOpen(false); setEditingCollege(null); }}
          onSubmit={handleSubmit}
          isSubmitting={createCollege.isPending || updateCollege.isPending}
        />
      )}

      <style>{`
        .colleges-page {
          padding: var(--spacing-page);
        }

        .colleges-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 24px;
        }

        .colleges-title {
          font-size: 24px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .colleges-subtitle {
          font-size: 13px;
          color: var(--color-text-tertiary);
          margin-top: 4px;
        }

        .colleges-add-btn {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 16px;
          font-size: 13px;
          font-weight: 500;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: opacity 0.15s;
        }

        .colleges-add-btn:hover {
          opacity: 0.9;
        }

        .colleges-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
          gap: 16px;
        }

        .college-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          overflow: hidden;
          transition: box-shadow 0.15s ease;
        }

        .college-card:hover {
          box-shadow: var(--shadow-card-hover);
        }

        .college-card.inactive {
          opacity: 0.6;
        }

        .college-color-bar {
          height: 4px;
        }

        .college-card-body {
          padding: 16px;
        }

        .college-card-header {
          margin-bottom: 12px;
        }

        .college-name-row {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .college-name {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .college-inactive-badge {
          font-size: 10px;
          padding: 2px 6px;
          background: var(--color-danger-light);
          color: var(--color-danger);
          border-radius: var(--radius-sm);
          font-weight: 600;
        }

        .college-slug {
          font-size: 12px;
          font-family: var(--font-mono);
          color: var(--color-text-tertiary);
          background: var(--color-bg-tertiary);
          padding: 2px 6px;
          border-radius: var(--radius-sm);
        }

        .college-meta {
          display: flex;
          flex-direction: column;
          gap: 6px;
          margin-bottom: 12px;
        }

        .college-meta-item {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 12px;
          color: var(--color-text-secondary);
        }

        .college-meta-item a {
          color: var(--color-info);
          text-decoration: none;
        }

        .college-meta-item a:hover {
          text-decoration: underline;
        }

        .college-desc {
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-bottom: 12px;
          line-height: 1.5;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }

        .college-card-actions {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
          padding-top: 12px;
          border-top: 1px solid var(--color-border-light);
        }

        .college-btn-edit,
        .college-btn-toggle,
        .college-btn-init {
          padding: 6px 12px;
          font-size: 12px;
          border-radius: var(--radius-sm);
          cursor: pointer;
          border: 1px solid var(--color-border);
          display: flex;
          align-items: center;
          gap: 5px;
        }

        .college-btn-edit {
          background: var(--color-bg-primary);
          color: var(--color-text-secondary);
        }

        .college-btn-edit:hover {
          border-color: var(--color-info);
          color: var(--color-info);
        }

        .college-btn-init {
          background: var(--color-bg-primary);
          color: var(--color-text-secondary);
          transition: all 0.12s;
        }

        .college-btn-init:hover:not(:disabled) {
          border-color: var(--color-success);
          color: var(--color-success);
        }

        .college-btn-init:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .college-import-result {
          display: flex;
          align-items: center;
          gap: 5px;
          margin-top: 8px;
          padding: 5px 8px;
          background: var(--color-success-light, #d3f9d8);
          color: var(--color-success);
          border-radius: var(--radius-sm);
          font-size: 11px;
          font-weight: 500;
        }

        .college-btn-toggle.deactivate {
          background: var(--color-danger-light);
          color: var(--color-danger);
          border-color: transparent;
        }

        .college-btn-toggle.activate {
          background: var(--color-success-light);
          color: var(--color-success);
          border-color: transparent;
        }

        .college-btn-toggle:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .colleges-loading, .colleges-error, .colleges-denied {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 12px;
          padding: 80px 0;
          color: var(--color-text-tertiary);
          font-size: 14px;
          text-align: center;
        }

        .colleges-denied h2 {
          font-size: 18px;
          color: var(--color-text-primary);
        }

        .colleges-error {
          color: var(--color-danger);
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
