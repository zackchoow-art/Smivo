/**
 * Dictionary items page — CRUD for a specific dict_type.
 * Routes to the correct data source:
 *   - school-level types (category/condition/pickup_location) → dedicated tables
 *   - all other types → system_dictionaries table
 */
import { useState, useRef, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Plus, Trash2, Loader2, GripVertical, Pencil,
  ToggleLeft, ToggleRight, Lock, School, Download,
} from 'lucide-react';
import {
  useDictItems, useCreateDictItem, useUpdateDictItem,
  useDeleteDictItem, useReorderDictItems,
  DICT_REGISTRY, ACCESS_LEVEL_META, canEditLevel,
} from '@/hooks/useDictionary';
import {
  SCHOOL_DICT_SOURCE_MAP,
  useSchoolDictItems, useCreateSchoolDictItem, useUpdateSchoolDictItem,
  useDeleteSchoolDictItem, useReorderSchoolDictItems,
  useImportPlatformDefaults,
} from '@/hooks/useSchoolDictData';
import { MaterialIconPicker } from '@/components/MaterialIconPicker';
import { useAdminRole } from '@/hooks/useAdminRole';
import { ADMIN_ROLES } from '@/lib/constants';
import { useAuthStore } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { useColleges } from '@/hooks/useColleges';
import { showToast } from '@/hooks/useToast';
import type { DictItem } from '@/types';

// ── Edit / Add Modal ──────────────────────────────────────────────────────────

interface ModalProps {
  dictType: string;
  item?: DictItem | null;
  onClose: () => void;
  onSave: (data: Partial<DictItem>) => Promise<void>;
  isSaving: boolean;
  isSchoolSource: boolean;
}

function DictItemModal({ dictType, item, onClose, onSave, isSaving, isSchoolSource }: ModalProps) {
  const regMeta = DICT_REGISTRY[dictType];
  const isEdit  = !!item;

  const [key,  setKey]  = useState(item?.dict_key   ?? '');
  const [val,  setVal]  = useState(item?.dict_value  ?? '');
  const [desc, setDesc] = useState(item?.description ?? '');
  const [extra, setExtra] = useState<Record<string, string>>(() =>
    item?.extra ? Object.fromEntries(Object.entries(item.extra).map(([k, v]) => [k, String(v)])) : {}
  );
  // Icon picker is shown for category type only
  const [showIconPicker, setShowIconPicker] = useState(false);
  const isCategoryType = dictType === 'category';

  const handleSubmit = async () => {
    if (!val.trim()) { showToast('Display Value is required.', 'warning'); return; }
    if (!isSchoolSource && !key.trim()) { showToast('Key is required.', 'warning'); return; }
    if (!isSchoolSource && !isEdit && !key.trim()) return;

    const extraObj = regMeta?.extraFields?.length
      ? Object.fromEntries(regMeta.extraFields.map((f) => [
          f.key,
          f.type === 'number' ? Number(extra[f.key] ?? 0) : (extra[f.key] ?? ''),
        ]))
      // For school category, icon is stored in extra even without regMeta.extraFields
      : isCategoryType ? { icon: extra['icon'] ?? '' } : null;

    await onSave({ dict_key: key.trim(), dict_value: val.trim(), description: desc.trim() || null, extra: extraObj });
  };

  // For pickup_locations the key field is the uuid (auto), so hide it in add mode
  const showKeyField = !isSchoolSource || dictType !== 'pickup_location';

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-box" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Edit Entry' : 'Add Entry'}</h2>
        <p className="modal-subtitle">{regMeta?.title ?? dictType}</p>
        <div className="modal-form">
          {showKeyField && (
            <label className="modal-label">
              {isSchoolSource ? 'Slug (ID)' : 'Key'} {!isEdit && <span className="modal-required">*</span>}
              <input className="modal-input" value={key} onChange={(e) => setKey(e.target.value)}
                disabled={isEdit} placeholder="e.g. electronics" />
            </label>
          )}
          <label className="modal-label">
            Display Value <span className="modal-required">*</span>
            <input className="modal-input" value={val} onChange={(e) => setVal(e.target.value)} placeholder="e.g. Electronics" />
          </label>
          <label className="modal-label modal-full">
            Description
            <input className="modal-input" value={desc} onChange={(e) => setDesc(e.target.value)} placeholder="Optional description" />
          </label>

          {/* Icon picker for category dict type */}
          {isCategoryType && (
            <label className="modal-label modal-full">
              Icon
              <div className="modal-icon-row">
                {extra['icon'] ? (
                  <span className="modal-icon-preview">
                    <span className="material-symbols-outlined">{extra['icon']}</span>
                  </span>
                ) : (
                  <span className="modal-icon-empty">No icon</span>
                )}
                <button type="button" className="modal-icon-pick-btn"
                  onClick={() => setShowIconPicker(true)}>
                  Choose Icon
                </button>
                {extra['icon'] && (
                  <button type="button" className="modal-icon-clear-btn"
                    onClick={() => setExtra({ ...extra, icon: '' })}>
                    Clear
                  </button>
                )}
                <code className="modal-icon-name">{extra['icon'] || '—'}</code>
              </div>
            </label>
          )}

          {/* Other extra fields (non-category) */}
          {!isCategoryType && regMeta?.extraFields?.map((f) => (
            <label key={f.key} className="modal-label">
              {f.label}
              {f.type === 'color' ? (
                <div className="modal-color-row">
                  <input type="color" className="modal-color-swatch"
                    value={extra[f.key] ?? '#000000'} onChange={(e) => setExtra({ ...extra, [f.key]: e.target.value })} />
                  <input className="modal-input" value={extra[f.key] ?? ''}
                    onChange={(e) => setExtra({ ...extra, [f.key]: e.target.value })} placeholder={f.placeholder} />
                </div>
              ) : (
                <input className="modal-input" type={f.type === 'number' ? 'number' : 'text'}
                  value={extra[f.key] ?? ''} onChange={(e) => setExtra({ ...extra, [f.key]: e.target.value })}
                  placeholder={f.placeholder} />
              )}
            </label>
          ))}
        </div>
        <div className="modal-actions">
          <button className="modal-btn-cancel" onClick={onClose}>Cancel</button>
          <button className="modal-btn-save" onClick={handleSubmit} disabled={isSaving}>
            {isSaving ? <Loader2 size={14} className="spin" /> : (isEdit ? 'Save Changes' : 'Add Entry')}
          </button>
        </div>
      </div>

      {/* Icon picker overlay */}
      {showIconPicker && (
        <MaterialIconPicker
          value={extra['icon'] ?? ''}
          onSelect={(iconName) => setExtra({ ...extra, icon: iconName })}
          onClose={() => setShowIconPicker(false)}
        />
      )}
    </div>
  );
}

// ── Main page ─────────────────────────────────────────────────────────────────

export function DictionaryItemsPage() {
  const { dictCode }           = useParams<{ dictCode: string }>();
  const navigate               = useNavigate();
  const { role }               = useAdminRole();
  const { admin }              = useAuthStore();
  const adminId                = admin?.user_id ?? '';
  const { currentCollegeId }   = useSchoolScopeStore();
  const { data: colleges }     = useColleges();

  const isSchoolSource = !!dictCode && !!SCHOOL_DICT_SOURCE_MAP[dictCode];

  // ── Data source routing ───────────────────────────────────────────────────
  const systemItems  = useDictItems(!isSchoolSource ? (dictCode ?? '') : '');
  const schoolItems  = useSchoolDictItems(isSchoolSource ? (dictCode ?? '') : '');

  const { data: items, isLoading } = isSchoolSource ? schoolItems : systemItems;

  // System mutations
  const sysCreate  = useCreateDictItem();
  const sysUpdate  = useUpdateDictItem();
  const sysDelete  = useDeleteDictItem();
  const sysReorder = useReorderDictItems();

  // School mutations
  const schCreate  = useCreateSchoolDictItem(dictCode ?? '');
  const schUpdate  = useUpdateSchoolDictItem(dictCode ?? '');
  const schDelete  = useDeleteSchoolDictItem(dictCode ?? '');
  const schReorder = useReorderSchoolDictItems(dictCode ?? '');
  const importDefaults = useImportPlatformDefaults();

  // All 3 school-level dict types support platform defaults import
  const supportsImport = isSchoolSource && (
    dictCode === 'category' || dictCode === 'condition' || dictCode === 'pickup_location'
  );
  // Platform super admins see all actions; school admins cannot modify imported defaults
  const isSuperAdmin = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;

  const isMutating = isSchoolSource
    ? (schCreate.isPending || schUpdate.isPending)
    : (sysCreate.isPending || sysUpdate.isPending);

  // ── Modal & drag state ────────────────────────────────────────────────────
  const [modalItem, setModalItem]       = useState<DictItem | null | undefined>(undefined);
  const [draftItems, setDraftItems]     = useState<DictItem[] | null>(null);
  const [deletedItems, setDeletedItems] = useState<Set<string>>(new Set());
  const [isSavingAll, setIsSavingAll]   = useState(false);
  const [isImporting, setIsImporting]   = useState(false);
  const dragIndex                       = useRef<number | null>(null);

  useEffect(() => {
    if (items && draftItems === null) {
      setDraftItems(JSON.parse(JSON.stringify(items)));
    }
  }, [items, draftItems]);

  const regMeta       = DICT_REGISTRY[dictCode ?? ''];
  const level         = regMeta?.access_level ?? 'platform';
  const levelMeta     = ACCESS_LEVEL_META[level];
  const canEdit       = canEditLevel(role, level);
  const displayItems  = draftItems ?? items ?? [];

  const hasUnsavedChanges = draftItems !== null && (JSON.stringify(draftItems) !== JSON.stringify(items) || deletedItems.size > 0);

  // ── School context banner ─────────────────────────────────────────────────
  const currentSchoolName = colleges?.find((c) => c.id === currentCollegeId)?.name;

  // Warn if school-level but no school selected
  if (isSchoolSource && !currentCollegeId) {
    return (
      <div className="ditems-page">
        <button className="ditems-back" onClick={() => navigate('/settings/dictionary')}>
          <ArrowLeft size={15} /> Dictionary
        </button>
        <div className="ditems-no-school">
          <School size={40} color="var(--color-text-tertiary)" />
          <h3>No School Selected</h3>
          <p>
            School-specific fields require a school context.<br />
            Please select a school from the school switcher in the sidebar.
          </p>
        </div>
      </div>
    );
  }

  // ── Drag handlers ─────────────────────────────────────────────────────────

  const handleDragStart = (index: number) => { if (canEdit) dragIndex.current = index; };

  const handleDragOver = (e: React.DragEvent, index: number) => {
    e.preventDefault();
    if (dragIndex.current === null || dragIndex.current === index) return;
    const reordered = [...displayItems];
    const [moved] = reordered.splice(dragIndex.current, 1);
    reordered.splice(index, 0, moved!);
    dragIndex.current = index;
    setDraftItems(reordered);
  };

  const handleDrop = () => {
    if (dragIndex.current === null || !canEdit) return;
    dragIndex.current = null;
    // We don't save immediately anymore.
  };

  // ── Handlers ────────────────────────────────────────────────────────────

  const handleModalSave = async (data: Partial<DictItem>) => {
    if (!dictCode) return;
    if (modalItem) {
      // Edit
      setDraftItems(prev => prev!.map(item => item.id === modalItem.id ? { ...item, ...data } : item));
    } else {
      // Add
      const tempId = `temp-${Date.now()}`;
      const newItem = {
        id: tempId,
        dict_key: data.dict_key,
        dict_value: data.dict_value,
        description: data.description,
        extra: data.extra,
        is_active: true,
        display_order: displayItems.length + 1,
      } as DictItem;
      setDraftItems(prev => [...(prev || items || []), newItem]);
    }
    setModalItem(undefined);
  };

  const handleToggle = (item: DictItem) => {
    if (!canEdit) return;
    // NOTE: imported platform defaults cannot be toggled by school admins
    if (item.is_imported_default && !isSuperAdmin) return;
    setDraftItems(prev => prev!.map(i => i.id === item.id ? { ...i, is_active: !i.is_active } : i));
  };

  const handleDelete = (item: DictItem) => {
    if (!canEdit) return;
    // NOTE: imported platform defaults cannot be deleted by school admins
    if (item.is_imported_default && !isSuperAdmin) {
      showToast('Platform default items cannot be deleted. Contact a platform admin.', 'warning');
      return;
    }
    if (!confirm(`Delete "${item.dict_value}"?`)) return;
    if (!item.id.startsWith('temp-')) {
      setDeletedItems(prev => new Set(prev).add(item.id));
    }
    setDraftItems(prev => prev!.filter(i => i.id !== item.id));
  };

  const handleImportDefaults = async () => {
    if (!adminId || isImporting) return;
    setIsImporting(true);
    try {
      const result = await importDefaults.mutateAsync({ adminId });
      const total = (result?.categories_imported ?? 0)
        + (result?.conditions_imported ?? 0)
        + (result?.pickup_locations_imported ?? 0);
      if (total === 0) {
        showToast('All platform defaults are already imported.', 'info');
      } else {
        const parts: string[] = [];
        if (result?.categories_imported)       parts.push(`${result.categories_imported} categories`);
        if (result?.conditions_imported)       parts.push(`${result.conditions_imported} conditions`);
        if (result?.pickup_locations_imported) parts.push(`${result.pickup_locations_imported} pickup locations`);
        showToast(`Imported: ${parts.join(', ')}.`, 'success');
        setDraftItems(null);
      }
    } catch (e: any) {
      showToast(e?.message || 'Import failed.', 'error');
    } finally {
      setIsImporting(false);
    }
  };

  const handleSaveAll = async () => {
    if (!dictCode) return;
    setIsSavingAll(true);
    try {
      // 1. Deletes
      for (const id of deletedItems) {
        const originalItem = items?.find(i => i.id === id);
        if (originalItem) {
          if (isSchoolSource) await schDelete.mutateAsync({ id, adminId });
          else await sysDelete.mutateAsync({ id, adminId, dictType: dictCode, dictKey: originalItem.dict_key });
        }
      }

      // 2. Updates & Creates
      for (let i = 0; i < displayItems.length; i++) {
        const item = displayItems[i];
        const isNew = item.id.startsWith('temp-');
        const payload = {
          dict_key: item.dict_key,
          dict_value: item.dict_value,
          description: item.description,
          extra: item.extra,
          is_active: item.is_active,
          display_order: i + 1,
        };

        if (isNew) {
          if (isSchoolSource) {
            await schCreate.mutateAsync({ item: payload, adminId });
          } else {
            await sysCreate.mutateAsync({ item: { ...payload, dict_type: dictCode, access_level: level }, adminId });
          }
        } else {
          if (isSchoolSource) {
            await schUpdate.mutateAsync({ id: item.id, adminId, ...payload });
          } else {
            await sysUpdate.mutateAsync({ id: item.id, adminId, dictType: dictCode, ...payload });
          }
        }
      }

      showToast('All changes saved successfully.', 'success');
      setDeletedItems(new Set());
      setDraftItems(null); // Force re-sync with fresh data
      
      if (isSchoolSource) schoolItems.refetch();
      else systemItems.refetch();

    } catch (e: any) {
      showToast(e?.message || 'Failed to save changes.', 'error');
    } finally {
      setIsSavingAll(false);
    }
  };

  // ── Render ────────────────────────────────────────────────────────────────

  const extraColsCount = regMeta?.extraFields?.length || 0;
  const extraColsStyle = extraColsCount > 0 ? `repeat(${extraColsCount}, 110px)` : '';
  const actionsColWidth = canEdit ? '120px' : '40px';
  const gridTemplate = `24px 32px 150px 1fr 1.4fr ${extraColsStyle} ${actionsColWidth}`;

  return (
    <div className="ditems-page">
      {/* Header */}
      <div className="ditems-header">
        <button className="ditems-back" onClick={() => navigate('/settings/dictionary')}>
          <ArrowLeft size={15} /> Dictionary
        </button>
        <div className="ditems-header-center">
          <div className="ditems-title-row">
            <h1 className="ditems-title">{regMeta?.title ?? dictCode}</h1>
            <span className="ditems-level-badge" style={{ background: levelMeta.bgColor, color: levelMeta.color }}>
              {levelMeta.label}
            </span>
            {isSchoolSource && currentSchoolName && (
              <span className="ditems-school-badge">
                <School size={11} /> {currentSchoolName}
              </span>
            )}
            {!canEdit && (
              <span className="ditems-readonly-badge"><Lock size={10} /> Read-only</span>
            )}
          </div>
          <p className="ditems-subtitle">
            <code>{dictCode}</code>
            {' · '}{displayItems.length} entries
            {isSchoolSource && (
              <> · Stored in <code>{SCHOOL_DICT_SOURCE_MAP[dictCode!]}</code></>
            )}
          </p>
        </div>
        {canEdit && (
          <div className="ditems-header-actions">
            {supportsImport && (
              <button
                className="ditems-import-btn"
                onClick={handleImportDefaults}
                disabled={isImporting}
                title="Copy platform default items to this school (skips duplicates)"
              >
                {isImporting
                  ? <Loader2 size={13} className="spin" />
                  : <Download size={13} />}
                Import Base Items
              </button>
            )}
            <button className="ditems-add-btn" onClick={() => setModalItem(null)}>
              <Plus size={14} /> Add Entry
            </button>
          </div>
        )}
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="ditems-loading"><Loader2 size={20} className="spin" /> Loading...</div>
      ) : (
        <div className="ditems-table">
          <div className="ditems-row ditems-row-header" style={{ gridTemplateColumns: gridTemplate }}>
            <span />
            <span>#</span>
            <span>Key / Slug</span>
            <span>Display Value</span>
            <span>Description</span>
            {regMeta?.extraFields?.map((f) => <span key={f.key}>{f.label}</span>)}
            <span style={{ textAlign: 'right', paddingRight: '8px' }}>Actions</span>
          </div>

          {displayItems.map((item, index) => (
            <div
              key={item.id}
              className={`ditems-row ${!item.is_active ? 'inactive' : ''}`}
              style={{ gridTemplateColumns: gridTemplate }}
              draggable={canEdit}
              onDragStart={() => handleDragStart(index)}
              onDragOver={(e) => handleDragOver(e, index)}
              onDrop={handleDrop}
            >
              <span className={`ditems-grip ${!canEdit ? 'no-drag' : ''}`}>
                <GripVertical size={14} color={canEdit ? 'var(--color-text-tertiary)' : 'transparent'} />
              </span>
              <span className="ditems-order tabular-nums">{index + 1}</span>
              <code className="ditems-key">{item.dict_key}</code>
              <span className="ditems-value">{item.dict_value}</span>
              <span className="ditems-desc" title={item.description ?? ''}>{item.description ?? '—'}</span>
              {regMeta?.extraFields?.map((f) => {
                const rawVal = (item.extra as any)?.[f.key];
                return (
                  <span key={f.key} className="ditems-extra">
                    {f.type === 'color' && rawVal
                      ? <span className="ditems-color-dot" style={{ background: String(rawVal) }} title={String(rawVal)} />
                      : rawVal != null ? String(rawVal) : '—'}
                  </span>
                );
              })}
              <div className="ditems-actions-cell">
                {(item as any).is_imported_default ? (
                  // NOTE: Platform-imported defaults are locked for everyone.
                  // They can only be modified by editing the platform_*_defaults
                  // tables and re-running import_platform_defaults().
                  <span className="ditems-lock-badge" title="Platform default — cannot be edited or deleted. Manage in Platform Defaults tables.">
                    <Lock size={11} /> Platform default
                  </span>
                ) : (
                  <>
                    <button className="ditems-toggle" onClick={() => handleToggle(item)} disabled={!canEdit}
                      title={item.is_active ? 'Click to deactivate' : 'Click to activate'}>
                      {item.is_active
                        ? <ToggleRight size={20} color="var(--color-success)" />
                        : <ToggleLeft  size={20} color="var(--color-text-tertiary)" />}
                    </button>
                    {canEdit && (
                      <>
                        <button className="ditems-btn-icon" onClick={() => setModalItem(item)} title="Edit">
                          <Pencil size={13} />
                        </button>
                        <button className="ditems-btn-icon danger" onClick={() => handleDelete(item)} title="Delete">
                          <Trash2 size={13} />
                        </button>
                      </>
                    )}
                  </>
                )}
              </div>
            </div>
          ))}

          {displayItems.length === 0 && (
            <div className="ditems-empty">
              No entries yet.{canEdit ? ' Click "Add Entry" to create one.' : ''}
            </div>
          )}
        </div>
      )}

      {/* Save all changes bar */}
      {hasUnsavedChanges && (
        <div className="ditems-save-bar">
          <span>You have unsaved changes.</span>
          <button className="ditems-btn-save-all" onClick={handleSaveAll} disabled={isSavingAll}>
            {isSavingAll ? <Loader2 size={14} className="spin" /> : 'Save All Changes'}
          </button>
        </div>
      )}

      {/* Modal */}
      {modalItem !== undefined && (
        <DictItemModal
          dictType={dictCode ?? ''}
          item={modalItem}
          onClose={() => setModalItem(undefined)}
          onSave={handleModalSave}
          isSaving={isMutating}
          isSchoolSource={isSchoolSource}
        />
      )}

      <style>{`
        .ditems-page { padding: var(--spacing-page); max-width: 1000px; }
        .ditems-header { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; flex-wrap: wrap; }
        .ditems-header-center { flex: 1; min-width: 0; }
        .ditems-back {
          display: flex; align-items: center; gap: 4px; padding: 6px 10px; font-size: 13px;
          background: var(--color-bg-primary); border: 1px solid var(--color-border);
          border-radius: var(--radius-md); cursor: pointer; color: var(--color-text-secondary); white-space: nowrap;
        }
        .ditems-back:hover { border-color: var(--color-info); color: var(--color-info); }
        .ditems-title-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 3px; }
        .ditems-title { font-size: 20px; font-weight: 700; color: var(--color-text-primary); }
        .ditems-level-badge { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px;
          border-radius: var(--radius-sm); font-size: 11px; font-weight: 600; }
        .ditems-school-badge { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px;
          background: var(--color-success-light); color: var(--color-success);
          border-radius: var(--radius-sm); font-size: 11px; font-weight: 600; }
        .ditems-readonly-badge { display: inline-flex; align-items: center; gap: 3px; padding: 2px 7px;
          background: var(--color-bg-tertiary); color: var(--color-text-tertiary);
          border-radius: var(--radius-sm); font-size: 11px; font-weight: 500; }
        .ditems-subtitle { font-size: 12px; color: var(--color-text-tertiary); }
        .ditems-subtitle code { font-family: var(--font-mono); color: var(--color-info);
          background: var(--color-info-light); padding: 1px 5px; border-radius: 3px; }
        .ditems-add-btn { display: flex; align-items: center; gap: 4px; padding: 7px 14px; font-size: 13px;
          background: var(--color-info); color: white; border: none; border-radius: var(--radius-md);
          cursor: pointer; white-space: nowrap; }
        .ditems-add-btn:hover { opacity: 0.9; }

        .ditems-header-actions { display: flex; align-items: center; gap: 8px; margin-left: auto; flex-shrink: 0; }

        .ditems-import-btn { display: flex; align-items: center; gap: 5px; padding: 7px 13px; font-size: 13px;
          background: var(--color-bg-primary); color: var(--color-text-secondary);
          border: 1px solid var(--color-border); border-radius: var(--radius-md);
          cursor: pointer; white-space: nowrap; transition: all 0.12s; }
        .ditems-import-btn:hover:not(:disabled) { border-color: var(--color-success); color: var(--color-success); }
        .ditems-import-btn:disabled { opacity: 0.6; cursor: not-allowed; }

        .ditems-lock-badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 8px;
          background: var(--color-bg-tertiary); color: var(--color-text-tertiary);
          border-radius: var(--radius-sm); font-size: 11px; font-weight: 600;
          border: 1px solid var(--color-border-light); white-space: nowrap; }

        /* Modal icon picker row */
        .modal-icon-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 2px; }
        .modal-icon-preview { display: inline-flex; align-items: center; justify-content: center;
          width: 36px; height: 36px; border-radius: var(--radius-sm);
          background: var(--color-info-light); border: 1px solid var(--color-info); color: var(--color-info); }
        .modal-icon-preview .material-symbols-outlined { font-size: 20px; }
        .modal-icon-empty { font-size: 12px; color: var(--color-text-tertiary); font-style: italic; }
        .modal-icon-pick-btn { padding: 6px 12px; font-size: 12px; background: var(--color-bg-secondary);
          border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer;
          color: var(--color-text-secondary); transition: all 0.1s; }
        .modal-icon-pick-btn:hover { border-color: var(--color-info); color: var(--color-info); }
        .modal-icon-clear-btn { padding: 6px 10px; font-size: 12px; background: none;
          border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); cursor: pointer;
          color: var(--color-text-tertiary); transition: all 0.1s; }
        .modal-icon-clear-btn:hover { border-color: var(--color-danger); color: var(--color-danger); }
        .modal-icon-name { font-family: var(--font-mono); font-size: 11px; color: var(--color-text-tertiary);
          background: var(--color-bg-tertiary); padding: 2px 6px; border-radius: 3px; }

        /* Material Symbols font for icon display in table rows */
        @import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200');
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
          font-size: 18px; line-height: 1; user-select: none; }


        /* No school warning */
        .ditems-no-school { display: flex; flex-direction: column; align-items: center; gap: 12px;
          padding: 80px 0; color: var(--color-text-tertiary); text-align: center; }
        .ditems-no-school h3 { font-size: 18px; color: var(--color-text-primary); margin: 0; }
        .ditems-no-school p { font-size: 13px; line-height: 1.6; margin: 0; }

        /* Table */
        .ditems-table { background: var(--color-bg-primary); border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg); overflow: hidden; }
        .ditems-row { display: grid;
          gap: 8px; align-items: center; padding: 10px 14px; font-size: 13px;
          border-bottom: 1px solid var(--color-border-light); }
        .ditems-row:last-child { border-bottom: none; }
        .ditems-row:not(.ditems-row-header):hover { background: var(--color-bg-secondary); }
        .ditems-row.inactive { opacity: 0.45; }
        .ditems-row-header { font-size: 11px; font-weight: 600; text-transform: uppercase;
          letter-spacing: 0.04em; color: var(--color-text-tertiary); background: var(--color-bg-secondary); }
        .ditems-grip { cursor: grab; display: flex; align-items: center; }
        .ditems-grip.no-drag { cursor: default; }
        .ditems-order { text-align: center; color: var(--color-text-tertiary); font-size: 12px; }
        .ditems-key { font-family: var(--font-mono); font-size: 12px; color: var(--color-info); }
        .ditems-value { font-weight: 500; color: var(--color-text-primary); }
        .ditems-desc { color: var(--color-text-tertiary); font-size: 12px;
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .ditems-extra { color: var(--color-text-tertiary); font-size: 12px; display: flex; align-items: center; gap: 4px; }
        .ditems-color-dot { width: 16px; height: 16px; border-radius: 3px;
          border: 1px solid var(--color-border); display: inline-block; }
        
        .ditems-actions-cell { display: flex; align-items: center; justify-content: flex-end; gap: 16px; }
        
        .ditems-toggle { background: none; border: none; cursor: pointer; padding: 2px;
          display: flex; align-items: center; }
        .ditems-toggle:disabled { cursor: default; }
        
        .ditems-btn-icon { display: flex; align-items: center; justify-content: center;
          width: 26px; height: 26px; background: none; border: 1px solid var(--color-border-light);
          border-radius: var(--radius-sm); cursor: pointer; color: var(--color-text-tertiary); transition: all 0.12s; }
        .ditems-btn-icon:hover { border-color: var(--color-info); color: var(--color-info); }
        .ditems-btn-icon.danger:hover { border-color: var(--color-danger); color: var(--color-danger); }
        
        .ditems-loading, .ditems-empty { padding: 40px 0; text-align: center;
          color: var(--color-text-tertiary); font-size: 13px;
          display: flex; align-items: center; justify-content: center; gap: 8px; }

        /* Save Bar */
        .ditems-save-bar { margin-top: 20px; padding: 16px 20px; background: var(--color-bg-primary); 
          border: 1px solid var(--color-info); border-radius: var(--radius-lg); display: flex; align-items: center; 
          justify-content: space-between; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .ditems-save-bar span { font-weight: 500; color: var(--color-info); }
        .ditems-btn-save-all { padding: 10px 20px; background: var(--color-info); color: white; border: none; 
          border-radius: var(--radius-md); font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.15s; }
        .ditems-btn-save-all:disabled { opacity: 0.6; cursor: not-allowed; }
        .ditems-btn-save-all:hover:not(:disabled) { opacity: 0.9; }

        /* Modal */
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.45);
          display: flex; align-items: center; justify-content: center; z-index: 200; padding: 16px; }
        .modal-box { background: var(--color-bg-primary); border-radius: var(--radius-lg);
          box-shadow: 0 20px 60px rgba(0,0,0,0.25); padding: 24px; width: 100%; max-width: 520px; }
        .modal-title { font-size: 18px; font-weight: 700; color: var(--color-text-primary); margin: 0 0 2px 0; }
        .modal-subtitle { font-size: 12px; color: var(--color-text-tertiary); margin: 0 0 18px 0; }
        .modal-form { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; }
        .modal-label { display: flex; flex-direction: column; gap: 5px; font-size: 12px;
          font-weight: 500; color: var(--color-text-secondary); }
        .modal-full { grid-column: 1 / -1; }
        .modal-required { color: var(--color-danger); }
        .modal-input { padding: 8px 10px; font-size: 13px; border: 1px solid var(--color-border);
          border-radius: var(--radius-sm); background: var(--color-bg-secondary);
          color: var(--color-text-primary); outline: none; transition: border-color 0.15s; }
        .modal-input:focus { border-color: var(--color-info); }
        .modal-input:disabled { opacity: 0.5; cursor: not-allowed; }
        .modal-color-row { display: flex; gap: 8px; align-items: center; }
        .modal-color-swatch { width: 36px; height: 34px; border: 1px solid var(--color-border);
          border-radius: var(--radius-sm); cursor: pointer; padding: 2px; background: var(--color-bg-secondary); }
        .modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
        .modal-btn-cancel, .modal-btn-save { padding: 8px 16px; font-size: 13px;
          border-radius: var(--radius-sm); cursor: pointer; display: flex; align-items: center;
          gap: 6px; border: 1px solid var(--color-border); transition: all 0.12s; }
        .modal-btn-cancel { background: var(--color-bg-primary); color: var(--color-text-secondary); }
        .modal-btn-cancel:hover { border-color: var(--color-info); }
        .modal-btn-save { background: var(--color-info); color: white; border-color: var(--color-info); }
        .modal-btn-save:hover { opacity: 0.9; }
        .modal-btn-save:disabled { opacity: 0.5; cursor: not-allowed; }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
