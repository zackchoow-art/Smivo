/**
 * MaterialIconPicker — curated icon grid for category/item selection.
 *
 * Uses Material Symbols icon font (loaded via CDN in index.html or via CSS).
 * Shows a searchable grid of Material icon names. Clicking selects the icon
 * and returns its name string to the parent via onSelect().
 *
 * Icon names are the snake_case ligature names used by Material Symbols.
 */
import { useState, useMemo } from 'react';
import { Search, X } from 'lucide-react';

// ── Curated icon set ──────────────────────────────────────────────────────────
// Grouped by category for discoverability. Covers most use cases for a
// campus marketplace: objects, activities, places, ui concepts.

const ICONS: Array<{ name: string; group: string }> = [
  // Furniture & Home
  { name: 'chair', group: 'Home' },
  { name: 'chair_alt', group: 'Home' },
  { name: 'desk', group: 'Home' },
  { name: 'bed', group: 'Home' },
  { name: 'table_restaurant', group: 'Home' },
  { name: 'lamp', group: 'Home' },
  { name: 'shelves', group: 'Home' },
  { name: 'bedroom_parent', group: 'Home' },
  { name: 'living', group: 'Home' },
  { name: 'kitchen', group: 'Home' },
  { name: 'home', group: 'Home' },
  { name: 'home_repair_service', group: 'Home' },
  // Electronics
  { name: 'devices', group: 'Electronics' },
  { name: 'laptop', group: 'Electronics' },
  { name: 'smartphone', group: 'Electronics' },
  { name: 'tablet', group: 'Electronics' },
  { name: 'headphones', group: 'Electronics' },
  { name: 'speaker', group: 'Electronics' },
  { name: 'tv', group: 'Electronics' },
  { name: 'keyboard', group: 'Electronics' },
  { name: 'mouse', group: 'Electronics' },
  { name: 'camera', group: 'Electronics' },
  { name: 'videocam', group: 'Electronics' },
  { name: 'monitor', group: 'Electronics' },
  { name: 'router', group: 'Electronics' },
  { name: 'earbuds', group: 'Electronics' },
  // Books & Study
  { name: 'menu_book', group: 'Study' },
  { name: 'book', group: 'Study' },
  { name: 'auto_stories', group: 'Study' },
  { name: 'library_books', group: 'Study' },
  { name: 'school', group: 'Study' },
  { name: 'science', group: 'Study' },
  { name: 'calculate', group: 'Study' },
  { name: 'edit_note', group: 'Study' },
  { name: 'draw', group: 'Study' },
  { name: 'brush', group: 'Study' },
  { name: 'palette', group: 'Study' },
  { name: 'history_edu', group: 'Study' },
  // Music & Instruments
  { name: 'music_note', group: 'Music' },
  { name: 'piano', group: 'Music' },
  { name: 'guitar', group: 'Music' },
  { name: 'queue_music', group: 'Music' },
  { name: 'mic', group: 'Music' },
  { name: 'album', group: 'Music' },
  { name: 'music_video', group: 'Music' },
  { name: 'radio', group: 'Music' },
  // Clothing & Fashion
  { name: 'checkroom', group: 'Clothing' },
  { name: 'dry_cleaning', group: 'Clothing' },
  { name: 'laundry', group: 'Clothing' },
  { name: 'hat', group: 'Clothing' },
  { name: 'styler', group: 'Clothing' },
  { name: 'waving_hand', group: 'Clothing' },
  // Sports & Fitness
  { name: 'sports_soccer', group: 'Sports' },
  { name: 'sports_basketball', group: 'Sports' },
  { name: 'sports_tennis', group: 'Sports' },
  { name: 'sports_volleyball', group: 'Sports' },
  { name: 'sports_football', group: 'Sports' },
  { name: 'sports_baseball', group: 'Sports' },
  { name: 'fitness_center', group: 'Sports' },
  { name: 'directions_bike', group: 'Sports' },
  { name: 'hiking', group: 'Sports' },
  { name: 'sports_esports', group: 'Sports' },
  { name: 'skateboarding', group: 'Sports' },
  { name: 'pool', group: 'Sports' },
  // Food & Kitchen
  { name: 'restaurant', group: 'Food' },
  { name: 'coffee', group: 'Food' },
  { name: 'local_cafe', group: 'Food' },
  { name: 'lunch_dining', group: 'Food' },
  { name: 'local_pizza', group: 'Food' },
  { name: 'set_meal', group: 'Food' },
  { name: 'blender', group: 'Food' },
  { name: 'microwave', group: 'Food' },
  // Transport & Travel
  { name: 'directions_car', group: 'Transport' },
  { name: 'pedal_bike', group: 'Transport' },
  { name: 'electric_scooter', group: 'Transport' },
  { name: 'local_shipping', group: 'Transport' },
  { name: 'backpack', group: 'Transport' },
  { name: 'luggage', group: 'Transport' },
  // Tools & Misc
  { name: 'build', group: 'Tools' },
  { name: 'handyman', group: 'Tools' },
  { name: 'more_horiz', group: 'General' },
  { name: 'category', group: 'General' },
  { name: 'sell', group: 'General' },
  { name: 'local_offer', group: 'General' },
  { name: 'inventory_2', group: 'General' },
  { name: 'recycling', group: 'General' },
  { name: 'eco', group: 'General' },
  { name: 'volunteer_activism', group: 'General' },
  { name: 'star', group: 'General' },
  { name: 'favorite', group: 'General' },
];

// ── Props ─────────────────────────────────────────────────────────────────────

interface MaterialIconPickerProps {
  value: string;
  onSelect: (iconName: string) => void;
  onClose: () => void;
}

// ── Component ─────────────────────────────────────────────────────────────────

export function MaterialIconPicker({ value, onSelect, onClose }: MaterialIconPickerProps) {
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    if (!query.trim()) return ICONS;
    const q = query.toLowerCase().replace(/\s+/g, '_');
    return ICONS.filter(
      (ic) => ic.name.includes(q) || ic.group.toLowerCase().includes(query.toLowerCase()),
    );
  }, [query]);

  // Group filtered icons for display
  const groups = useMemo(() => {
    const map: Record<string, string[]> = {};
    for (const ic of filtered) {
      if (!map[ic.group]) map[ic.group] = [];
      map[ic.group]!.push(ic.name);
    }
    return Object.entries(map);
  }, [filtered]);

  return (
    <div className="mip-overlay" onClick={onClose}>
      <div className="mip-panel" onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div className="mip-header">
          <span className="mip-title">Choose Icon</span>
          <button className="mip-close" onClick={onClose}><X size={16} /></button>
        </div>

        {/* Search */}
        <div className="mip-search-wrap">
          <Search size={14} className="mip-search-icon" />
          <input
            className="mip-search"
            placeholder="Search icons…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            autoFocus
          />
        </div>

        {/* Current selection preview */}
        {value && (
          <div className="mip-current">
            <span className="material-symbols-outlined mip-preview-icon">{value}</span>
            <span className="mip-current-label">Current: <code>{value}</code></span>
          </div>
        )}

        {/* Icon grid */}
        <div className="mip-grid-scroll">
          {groups.length === 0 ? (
            <p className="mip-empty">No icons match "{query}"</p>
          ) : (
            groups.map(([group, icons]) => (
              <div key={group}>
                <p className="mip-group-label">{group}</p>
                <div className="mip-grid">
                  {icons.map((iconName) => (
                    <button
                      key={iconName}
                      className={`mip-icon-btn ${value === iconName ? 'selected' : ''}`}
                      title={iconName}
                      onClick={() => { onSelect(iconName); onClose(); }}
                    >
                      <span className="material-symbols-outlined">{iconName}</span>
                    </button>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      <style>{`
        /* Make sure Material Symbols font is available */
        @import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200');

        .mip-overlay {
          position: fixed; inset: 0; z-index: 300;
          background: rgba(0,0,0,0.5);
          display: flex; align-items: center; justify-content: center;
          padding: 16px;
        }
        .mip-panel {
          background: var(--color-bg-primary);
          border-radius: var(--radius-lg);
          box-shadow: 0 24px 60px rgba(0,0,0,0.3);
          width: 100%; max-width: 520px;
          max-height: 80vh;
          display: flex; flex-direction: column;
          overflow: hidden;
        }
        .mip-header {
          display: flex; align-items: center; justify-content: space-between;
          padding: 16px 20px 12px;
          border-bottom: 1px solid var(--color-border-light);
        }
        .mip-title { font-weight: 700; font-size: 15px; color: var(--color-text-primary); }
        .mip-close {
          display: flex; align-items: center; justify-content: center;
          width: 28px; height: 28px; border: none; background: none;
          color: var(--color-text-tertiary); cursor: pointer; border-radius: var(--radius-sm);
        }
        .mip-close:hover { background: var(--color-bg-tertiary); }

        .mip-search-wrap {
          position: relative; padding: 10px 16px;
          border-bottom: 1px solid var(--color-border-light);
        }
        .mip-search-icon {
          position: absolute; left: 28px; top: 50%; transform: translateY(-50%);
          color: var(--color-text-tertiary);
        }
        .mip-search {
          width: 100%; padding: 8px 10px 8px 34px;
          border: 1px solid var(--color-border); border-radius: var(--radius-sm);
          background: var(--color-bg-secondary); color: var(--color-text-primary);
          font-size: 13px; outline: none;
        }
        .mip-search:focus { border-color: var(--color-info); }

        .mip-current {
          display: flex; align-items: center; gap: 10px;
          padding: 8px 16px;
          background: var(--color-info-light);
          border-bottom: 1px solid var(--color-border-light);
        }
        .mip-preview-icon { font-size: 22px; color: var(--color-info); }
        .mip-current-label { font-size: 12px; color: var(--color-text-secondary); }
        .mip-current-label code {
          font-family: var(--font-mono); color: var(--color-info);
          background: var(--color-bg-primary); padding: 1px 5px; border-radius: 3px;
        }

        .mip-grid-scroll { flex: 1; overflow-y: auto; padding: 12px 16px 16px; }
        .mip-group-label {
          font-size: 10px; font-weight: 700; text-transform: uppercase;
          letter-spacing: 0.08em; color: var(--color-text-tertiary);
          margin: 8px 0 6px;
        }
        .mip-grid {
          display: grid; grid-template-columns: repeat(8, 1fr); gap: 4px;
          margin-bottom: 8px;
        }
        .mip-icon-btn {
          display: flex; align-items: center; justify-content: center;
          width: 40px; height: 40px; border-radius: var(--radius-sm);
          border: 1px solid transparent; background: none;
          cursor: pointer; transition: all 0.1s; color: var(--color-text-secondary);
        }
        .mip-icon-btn:hover {
          background: var(--color-bg-secondary);
          border-color: var(--color-border);
          color: var(--color-text-primary);
        }
        .mip-icon-btn.selected {
          background: var(--color-info-light);
          border-color: var(--color-info);
          color: var(--color-info);
        }
        .mip-icon-btn .material-symbols-outlined { font-size: 20px; }
        .mip-empty {
          text-align: center; padding: 40px 0;
          color: var(--color-text-tertiary); font-size: 13px;
        }
      `}</style>
    </div>
  );
}
