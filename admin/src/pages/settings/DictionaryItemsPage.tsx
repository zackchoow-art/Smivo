/**
 * Dictionary items page — CRUD entries for a specific dict_type.
 * Supports inline editing, add, delete, and toggle active status.
 */
import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Plus, Trash2, Loader2, GripVertical, ToggleLeft, ToggleRight } from 'lucide-react';
import { useDictItems, useCreateDictItem, useUpdateDictItem, useDeleteDictItem } from '@/hooks/useDictionary';
import type { DictItem } from '@/types';

export function DictionaryItemsPage() {
  const { dictCode } = useParams<{ dictCode: string }>();
  const navigate = useNavigate();
  const { data: items, isLoading } = useDictItems(dictCode ?? '');
  const createItem = useCreateDictItem();
  const updateItem = useUpdateDictItem();
  const deleteItem = useDeleteDictItem();

  const [showAdd, setShowAdd] = useState(false);
  const [newKey, setNewKey] = useState('');
  const [newValue, setNewValue] = useState('');
  const [newDesc, setNewDesc] = useState('');

  const handleAdd = async () => {
    if (!newKey || !newValue || !dictCode) return;
    await createItem.mutateAsync({
      dict_type: dictCode,
      dict_key: newKey,
      dict_value: newValue,
      description: newDesc || null,
      display_order: (items?.length ?? 0) + 1,
      is_active: true,
    });
    setNewKey('');
    setNewValue('');
    setNewDesc('');
    setShowAdd(false);
  };

  const handleToggle = (item: DictItem) => {
    updateItem.mutate({ id: item.id, is_active: !item.is_active });
  };

  const handleDelete = (id: string) => {
    if (confirm('Delete this dictionary entry?')) {
      deleteItem.mutate(id);
    }
  };

  return (
    <div className="ditems-page">
      <div className="ditems-header">
        <button className="ditems-back" onClick={() => navigate('/settings/dictionary')}>
          <ArrowLeft size={16} />
          Back
        </button>
        <div>
          <h1 className="ditems-title">
            <code>{dictCode}</code>
          </h1>
          <p className="ditems-subtitle tabular-nums">
            {items?.length ?? 0} entries
          </p>
        </div>
        <button className="ditems-add-btn" onClick={() => setShowAdd(true)}>
          <Plus size={14} />
          Add Entry
        </button>
      </div>

      {/* Add form */}
      {showAdd && (
        <div className="ditems-add-form">
          <input placeholder="Key (e.g. pending)" value={newKey}
            onChange={(e) => setNewKey(e.target.value)} className="ditems-input" />
          <input placeholder="Display Value" value={newValue}
            onChange={(e) => setNewValue(e.target.value)} className="ditems-input" />
          <input placeholder="Description (optional)" value={newDesc}
            onChange={(e) => setNewDesc(e.target.value)} className="ditems-input" />
          <div className="ditems-add-actions">
            <button className="ditems-btn-cancel" onClick={() => setShowAdd(false)}>Cancel</button>
            <button className="ditems-btn-save" onClick={handleAdd} disabled={createItem.isPending}>
              {createItem.isPending ? <Loader2 size={14} className="spin" /> : 'Save'}
            </button>
          </div>
        </div>
      )}

      {/* Items list */}
      {isLoading ? (
        <div className="ditems-loading"><Loader2 size={20} className="spin" /> Loading...</div>
      ) : (
        <div className="ditems-list">
          <div className="ditems-row ditems-row-header">
            <span></span>
            <span>Key</span>
            <span>Value</span>
            <span>Description</span>
            <span>Order</span>
            <span>Status</span>
            <span></span>
          </div>
          {items?.map((item) => (
            <div key={item.id} className={`ditems-row ${!item.is_active ? 'inactive' : ''}`}>
              <GripVertical size={14} color="var(--color-text-tertiary)" />
              <code className="ditems-key">{item.dict_key}</code>
              <span className="ditems-value">{item.dict_value}</span>
              <span className="ditems-desc">{item.description ?? '—'}</span>
              <span className="ditems-order tabular-nums">{item.display_order}</span>
              <button className="ditems-toggle" onClick={() => handleToggle(item)}>
                {item.is_active
                  ? <ToggleRight size={20} color="var(--color-success)" />
                  : <ToggleLeft size={20} color="var(--color-text-tertiary)" />}
              </button>
              <button className="ditems-delete" onClick={() => handleDelete(item.id)}>
                <Trash2 size={14} />
              </button>
            </div>
          ))}
          {items?.length === 0 && (
            <div className="ditems-empty">No entries yet. Click "Add Entry" to create one.</div>
          )}
        </div>
      )}

      <style>{`
        .ditems-page { padding: var(--spacing-page); max-width: 900px; }

        .ditems-header {
          display: flex;
          align-items: center;
          gap: 16px;
          margin-bottom: 20px;
        }

        .ditems-back {
          display: flex;
          align-items: center;
          gap: 4px;
          padding: 6px 10px;
          font-size: 13px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          cursor: pointer;
          color: var(--color-text-secondary);
        }

        .ditems-title { font-size: 20px; font-weight: 700; }
        .ditems-title code {
          font-family: var(--font-mono);
          color: var(--color-info);
        }
        .ditems-subtitle { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; }

        .ditems-add-btn {
          margin-left: auto;
          display: flex;
          align-items: center;
          gap: 4px;
          padding: 6px 14px;
          font-size: 13px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          cursor: pointer;
        }

        .ditems-add-form {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 8px;
          padding: 14px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          margin-bottom: 16px;
        }

        .ditems-add-form .ditems-input:nth-child(3) { grid-column: 1 / -1; }

        .ditems-input {
          padding: 7px 10px;
          font-size: 13px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
          outline: none;
        }

        .ditems-input:focus { border-color: var(--color-border-focus); }

        .ditems-add-actions {
          grid-column: 1 / -1;
          display: flex;
          justify-content: flex-end;
          gap: 8px;
        }

        .ditems-btn-cancel, .ditems-btn-save {
          padding: 6px 14px;
          font-size: 13px;
          border-radius: var(--radius-sm);
          cursor: pointer;
          border: 1px solid var(--color-border);
          display: flex;
          align-items: center;
          gap: 4px;
        }

        .ditems-btn-cancel { background: var(--color-bg-primary); color: var(--color-text-secondary); }
        .ditems-btn-save { background: var(--color-info); color: white; border-color: var(--color-info); }
        .ditems-btn-save:disabled { opacity: 0.5; }

        .ditems-list {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          overflow: hidden;
        }

        .ditems-row {
          display: grid;
          grid-template-columns: 24px 1fr 1fr 1.5fr 60px 40px 32px;
          gap: 8px;
          align-items: center;
          padding: 10px 14px;
          font-size: 13px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .ditems-row:last-child { border-bottom: none; }

        .ditems-row.inactive { opacity: 0.5; }

        .ditems-row-header {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
          background: var(--color-bg-secondary);
        }

        .ditems-key {
          font-family: var(--font-mono);
          font-size: 12px;
          color: var(--color-info);
        }

        .ditems-value { color: var(--color-text-primary); font-weight: 500; }
        .ditems-desc { color: var(--color-text-tertiary); font-size: 12px; }
        .ditems-order { text-align: center; color: var(--color-text-tertiary); }

        .ditems-toggle, .ditems-delete {
          background: none;
          border: none;
          cursor: pointer;
          padding: 2px;
          display: flex;
          align-items: center;
        }

        .ditems-delete { color: var(--color-text-tertiary); }
        .ditems-delete:hover { color: var(--color-danger); }

        .ditems-loading, .ditems-empty {
          padding: 40px 0;
          text-align: center;
          color: var(--color-text-tertiary);
          font-size: 13px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
        }

        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
