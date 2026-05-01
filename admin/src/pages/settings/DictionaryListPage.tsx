/**
 * Dictionary list page — shows all dict_types as grouped cards.
 * Click a group card to navigate to its items page.
 */
import { useNavigate } from 'react-router-dom';
import { BookOpen, ChevronRight, Loader2 } from 'lucide-react';
import { useDictionaries } from '@/hooks/useDictionary';

const DICT_METADATA: Record<string, { title: string; desc: string }> = {
  category: { title: 'Product Categories', desc: 'Listing item classifications' },
  condition: { title: 'Item Conditions', desc: 'New, Used, Fair, etc.' },
  pickup_location: { title: 'Pickup Locations', desc: 'Pre-approved meeting spots' },
  review_tag: { title: 'Review Tags', desc: 'Feedback labels for users' },
  system_url: { title: 'System URLs', desc: 'Global app links and policies' },
};

export function DictionaryListPage() {
  const { data: groups, isLoading, error } = useDictionaries();
  const navigate = useNavigate();

  if (isLoading) {
    return (
      <div className="dict-loading">
        <Loader2 size={24} className="spin" />
        <span>Loading dictionaries...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dict-error">
        Failed to load: {(error as Error).message}
      </div>
    );
  }

  return (
    <div className="dict-page">
      <div className="dict-header">
        <h1 className="dict-title">Data Dictionaries</h1>
        <p className="dict-subtitle">
          {groups?.length ?? 0} dictionary groups · Manage enumerations and system constants
        </p>
      </div>

      <div className="dict-grid">
        {groups?.map((group) => {
          const meta = DICT_METADATA[group.dict_type] || {
            title: group.dict_type.toUpperCase(),
            desc: `Items for ${group.dict_type}`,
          };
          
          return (
            <button
              key={group.dict_type}
              className="dict-card"
              onClick={() => navigate(`/settings/dictionary/${group.dict_type}`)}
            >
              <div className="dict-card-left">
                <div className="dict-icon-bg">
                  <BookOpen size={20} color="var(--color-info)" />
                </div>
                <div>
                  <h3 className="dict-card-type">{meta.title}</h3>
                  <p className="dict-card-count">
                    {meta.desc} &middot; <span className="tabular-nums">
                      {group.items.length} items ({group.items.filter((i) => i.is_active).length} active)
                    </span>
                  </p>
                </div>
              </div>
              <ChevronRight size={18} color="var(--color-text-tertiary)" />
            </button>
          );
        })}
      </div>

      <style>{`
        .dict-page { padding: var(--spacing-page); }
        .dict-header { margin-bottom: 24px; }
        .dict-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); }
        .dict-subtitle { font-size: 13px; color: var(--color-text-tertiary); margin-top: 4px; }

        .dict-grid {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .dict-card {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 14px 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          cursor: pointer;
          transition: all 0.12s ease;
          text-align: left;
          width: 100%;
        }

        .dict-card:hover {
          box-shadow: var(--shadow-card-hover);
          border-color: var(--color-info);
        }

        .dict-card-left {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .dict-icon-bg {
          width: 40px;
          height: 40px;
          border-radius: var(--radius-sm);
          background: var(--color-info-light);
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .dict-card-type {
          font-size: 15px;
          font-weight: 600;
          color: var(--color-text-primary);
          margin: 0 0 4px 0;
        }

        .dict-card-count {
          font-size: 13px;
          color: var(--color-text-secondary);
          margin: 0;
        }

        .dict-loading, .dict-error {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          padding: 60px 0;
          color: var(--color-text-tertiary);
          font-size: 14px;
        }

        .dict-error { color: var(--color-danger); }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
