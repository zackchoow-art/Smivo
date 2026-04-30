/**
 * Global search component for TopBar.
 * Simultaneously searches users, listings, and orders.
 * Supports Cmd/Ctrl+K keyboard shortcut.
 */
import { useState, useEffect, useRef, useCallback } from 'react';
import { Search, User, Package, ShoppingCart, X, Loader2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

interface SearchResult {
  id: string;
  type: 'user' | 'listing' | 'order';
  title: string;
  subtitle: string;
}

const MAX_RESULTS_PER_GROUP = 3;

export function GlobalSearch() {
  const [query, setQuery] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const navigate = useNavigate();

  // Keyboard shortcut: Cmd/Ctrl+K to focus
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        inputRef.current?.focus();
        setIsOpen(true);
      }
      if (e.key === 'Escape') {
        setIsOpen(false);
        inputRef.current?.blur();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Click outside to close
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const performSearch = useCallback(async (searchQuery: string) => {
    if (searchQuery.length < 2) {
      setResults([]);
      setLoading(false);
      return;
    }

    setLoading(true);

    try {
      const searchPattern = `%${searchQuery}%`;

      // Search users, listings, and orders in parallel
      const [usersRes, listingsRes, ordersRes] = await Promise.all([
        supabase
          .from(TABLES.USER_PROFILES)
          .select('id, display_name, email')
          .or(`display_name.ilike.${searchPattern},email.ilike.${searchPattern}`)
          .limit(MAX_RESULTS_PER_GROUP),

        supabase
          .from(TABLES.LISTINGS)
          .select('id, title, price')
          .ilike('title', searchPattern)
          .limit(MAX_RESULTS_PER_GROUP),

        supabase
          .from(TABLES.ORDERS)
          .select('id, status, total_price')
          .or(`id.eq.${searchQuery},status.ilike.${searchPattern}`)
          .limit(MAX_RESULTS_PER_GROUP),
      ]);

      const mapped: SearchResult[] = [];

      // Map users
      (usersRes.data ?? []).forEach((u) => {
        mapped.push({
          id: u.id,
          type: 'user',
          title: u.display_name || u.email,
          subtitle: u.email,
        });
      });

      // Map listings
      (listingsRes.data ?? []).forEach((l) => {
        mapped.push({
          id: l.id,
          type: 'listing',
          title: l.title,
          subtitle: `$${l.price ?? 0}`,
        });
      });

      // Map orders
      (ordersRes.data ?? []).forEach((o) => {
        mapped.push({
          id: o.id,
          type: 'order',
          title: `Order ${o.id.slice(0, 8)}…`,
          subtitle: o.status ?? 'unknown',
        });
      });

      setResults(mapped);
    } catch (err) {
      console.error('Search failed:', err);
      setResults([]);
    } finally {
      setLoading(false);
    }
  }, []);

  // Debounced search
  const handleInputChange = (value: string) => {
    setQuery(value);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    if (value.length < 2) {
      setResults([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    debounceRef.current = setTimeout(() => performSearch(value), 300);
  };

  const handleResultClick = (result: SearchResult) => {
    setIsOpen(false);
    setQuery('');
    setResults([]);

    switch (result.type) {
      case 'user':
        navigate(`/users/${result.id}`);
        break;
      case 'listing':
        navigate(`/moderation/listings/${result.id}`);
        break;
      case 'order':
        navigate(`/orders/${result.id}`);
        break;
    }
  };

  const ICONS = {
    user: <User size={14} />,
    listing: <Package size={14} />,
    order: <ShoppingCart size={14} />,
  };

  const GROUP_LABELS = {
    user: 'Users',
    listing: 'Listings',
    order: 'Orders',
  };

  // Group results by type
  const grouped = results.reduce<Record<string, SearchResult[]>>((acc, r) => {
    if (!acc[r.type]) acc[r.type] = [];
    acc[r.type]!.push(r);
    return acc;
  }, {});

  return (
    <div className="gsearch" ref={containerRef}>
      <div className={`gsearch__bar ${isOpen ? 'focused' : ''}`}>
        <Search size={15} color="var(--color-text-tertiary)" />
        <input
          ref={inputRef}
          type="text"
          className="gsearch__input"
          placeholder="Search… ⌘K"
          value={query}
          onChange={(e) => handleInputChange(e.target.value)}
          onFocus={() => setIsOpen(true)}
        />
        {query && (
          <button
            className="gsearch__clear"
            onClick={() => { setQuery(''); setResults([]); }}
          >
            <X size={14} />
          </button>
        )}
      </div>

      {isOpen && (query.length >= 2 || results.length > 0) && (
        <div className="gsearch__dropdown">
          {loading && (
            <div className="gsearch__status">
              <Loader2 size={14} className="spin" />
              Searching…
            </div>
          )}

          {!loading && results.length === 0 && query.length >= 2 && (
            <div className="gsearch__status">No results found</div>
          )}

          {!loading && Object.entries(grouped).map(([type, items]) => (
            <div key={type} className="gsearch__group">
              <div className="gsearch__group-label">
                {ICONS[type as keyof typeof ICONS]}
                {GROUP_LABELS[type as keyof typeof GROUP_LABELS]}
              </div>
              {items.map((result) => (
                <button
                  key={result.id}
                  className="gsearch__result"
                  onClick={() => handleResultClick(result)}
                >
                  <span className="gsearch__result-title">{result.title}</span>
                  <span className="gsearch__result-sub">{result.subtitle}</span>
                </button>
              ))}
            </div>
          ))}
        </div>
      )}

      <style>{`
        .gsearch {
          position: relative;
        }

        .gsearch__bar {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 6px 10px;
          background: var(--color-bg-tertiary);
          border: 1px solid transparent;
          border-radius: var(--radius-md);
          min-width: 220px;
          transition: all 0.15s ease;
        }

        .gsearch__bar.focused {
          background: var(--color-bg-primary);
          border-color: var(--color-border-focus);
          box-shadow: 0 0 0 3px rgba(76, 110, 245, 0.1);
        }

        .gsearch__input {
          flex: 1;
          border: none;
          outline: none;
          font-size: 13px;
          color: var(--color-text-primary);
          background: transparent;
        }

        .gsearch__input::placeholder {
          color: var(--color-text-tertiary);
        }

        .gsearch__clear {
          display: flex;
          background: none;
          border: none;
          cursor: pointer;
          padding: 2px;
          color: var(--color-text-tertiary);
        }

        .gsearch__clear:hover {
          color: var(--color-text-primary);
        }

        .gsearch__dropdown {
          position: absolute;
          top: calc(100% + 6px);
          left: 0;
          right: 0;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          box-shadow: var(--shadow-dropdown);
          max-height: 360px;
          overflow-y: auto;
          z-index: 200;
        }

        .gsearch__status {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 6px;
          padding: 16px;
          font-size: 13px;
          color: var(--color-text-tertiary);
        }

        .gsearch__group {
          padding: 4px 0;
          border-bottom: 1px solid var(--color-border-light);
        }

        .gsearch__group:last-child {
          border-bottom: none;
        }

        .gsearch__group-label {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 6px 12px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
        }

        .gsearch__result {
          display: flex;
          align-items: center;
          justify-content: space-between;
          width: 100%;
          padding: 8px 12px;
          background: none;
          border: none;
          cursor: pointer;
          font-size: 13px;
          text-align: left;
          color: var(--color-text-primary);
        }

        .gsearch__result:hover {
          background: var(--color-bg-secondary);
        }

        .gsearch__result-title {
          flex: 1;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .gsearch__result-sub {
          font-size: 11px;
          color: var(--color-text-tertiary);
          margin-left: 8px;
          flex-shrink: 0;
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
