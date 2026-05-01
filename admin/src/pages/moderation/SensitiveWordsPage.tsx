/**
 * Sensitive words library management page.
 * Supports search, multi-filter, add, delete, toggle, and CSV batch import.
 */
import { useState, useRef } from 'react';
import { Plus, Search, Upload, Trash2, Loader2, ChevronLeft, ChevronRight, ToggleLeft, ToggleRight, Filter } from 'lucide-react';
import { useSensitiveWords, useCreateSensitiveWord, useDeleteSensitiveWord, useBatchImportWords, useBatchToggleWords, type SensitiveWordFilters } from '@/hooks/useSensitiveWords';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { SensitiveWord } from '@/types';

const SEV_COLOR: Record<string, string> = { block: 'var(--color-danger)', warn: 'var(--color-warning)' };
const CATS = ['general', 'weapons', 'drugs', 'adult', 'hate', 'fraud', 'spam'];

export function SensitiveWordsPage() {
  const [page, setPage] = useState(0);
  const [filters, setFilters] = useState<SensitiveWordFilters>({});
  const [showAdd, setShowAdd] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const fileRef = useRef<HTMLInputElement>(null);
  const [nw, setNw] = useState('');
  const [nc, setNc] = useState('general');
  const [ns, setNs] = useState<'block'|'warn'>('block');
  const [nl, setNl] = useState<'en'|'zh'>('en');
  const [previewWords, setPreviewWords] = useState<Partial<SensitiveWord>[] | null>(null);

  const { data, isLoading } = useSensitiveWords(page, filters);
  const createWord = useCreateSensitiveWord();
  const deleteWord = useDeleteSensitiveWord();
  const batchImport = useBatchImportWords();
  const batchToggle = useBatchToggleWords();
  const totalPages = Math.ceil((data?.count ?? 0) / DEFAULT_PAGE_SIZE);

  const handleAdd = async () => {
    if (!nw.trim()) return;
    await createWord.mutateAsync({ word: nw.trim().toLowerCase(), category: nc, severity: ns, language: nl, source: 'manual', is_active: true });
    setNw(''); setShowAdd(false);
  };

  const handleCSV = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]; if (!file) return;
    const text = await file.text();
    const lines = text.split('\n').filter(l => l.trim());
    const words: Partial<SensitiveWord>[] = lines.slice(1).map(line => {
      const [word, cat, sev, lang] = line.split(',').map(s => s.trim());
      return { word: word?.toLowerCase(), category: cat || 'general', severity: (sev === 'warn' ? 'warn' : 'block') as 'block'|'warn', language: (lang === 'zh' ? 'zh' : 'en') as 'en'|'zh', source: 'import' as const, is_active: true };
    }).filter(w => w.word);
    if (words.length > 0) {
      setPreviewWords(words);
    }
    if (fileRef.current) fileRef.current.value = '';
  };

  const confirmImport = async () => {
    if (!previewWords) return;
    await batchImport.mutateAsync(previewWords);
    alert(`Imported ${previewWords.length} words.`);
    setPreviewWords(null);
  };

  const toggle = (id: string) => { const n = new Set(selected); n.has(id) ? n.delete(id) : n.add(id); setSelected(n); };

  const batchAct = async (act: 'on'|'off'|'del') => {
    const ids = Array.from(selected); if (!ids.length) return;
    if (act === 'del') { if (!confirm(`Delete ${ids.length} word(s)?`)) return; for (const id of ids) await deleteWord.mutateAsync(id); }
    else await batchToggle.mutateAsync({ ids, is_active: act === 'on' });
    setSelected(new Set());
  };

  return (
    <div style={{ padding: 'var(--spacing-page)' }}>
      <div className="sw-hdr"><div><h1 className="sw-t">Sensitive Words</h1><p className="sw-st tabular-nums">{data?.count ?? 0} total</p></div>
        <div className="sw-ha">
          <button className="sw-bo" onClick={() => setShowFilters(!showFilters)}><Filter size={14}/> Filters</button>
          <label className="sw-bo"><Upload size={14}/> CSV<input ref={fileRef} type="file" accept=".csv" hidden onChange={handleCSV}/></label>
          <button className="sw-bp" onClick={() => setShowAdd(true)}><Plus size={14}/> Add</button>
        </div></div>

      {showFilters && <div className="sw-fl">
        <div className="sw-fi"><Search size={14}/><input placeholder="Search..." value={filters.search??''} onChange={e=>{setFilters({...filters,search:e.target.value});setPage(0);}} className="sw-fii"/></div>
        <select value={filters.category??''} onChange={e=>{setFilters({...filters,category:e.target.value||undefined});setPage(0);}} className="sw-fs"><option value="">All Categories</option>{CATS.map(c=><option key={c} value={c}>{c}</option>)}</select>
        <select value={filters.severity??''} onChange={e=>{setFilters({...filters,severity:e.target.value||undefined});setPage(0);}} className="sw-fs"><option value="">All Severity</option><option value="block">Block</option><option value="warn">Warn</option></select>
        <select value={filters.language??''} onChange={e=>{setFilters({...filters,language:e.target.value||undefined});setPage(0);}} className="sw-fs"><option value="">All Lang</option><option value="en">EN</option><option value="zh">ZH</option></select>
      </div>}

      {showAdd && <div className="sw-af">
        <input placeholder="Word" value={nw} onChange={e=>setNw(e.target.value)} className="sw-in"/>
        <select value={nc} onChange={e=>setNc(e.target.value)} className="sw-sl">{CATS.map(c=><option key={c}>{c}</option>)}</select>
        <select value={ns} onChange={e=>setNs(e.target.value as 'block'|'warn')} className="sw-sl"><option value="block">Block</option><option value="warn">Warn</option></select>
        <select value={nl} onChange={e=>setNl(e.target.value as 'en'|'zh')} className="sw-sl"><option value="en">EN</option><option value="zh">ZH</option></select>
        <div className="sw-aa"><button className="sw-bc" onClick={()=>setShowAdd(false)}>Cancel</button><button className="sw-bs" onClick={handleAdd} disabled={createWord.isPending}>{createWord.isPending?<Loader2 size={14} className="spin"/>:'Add'}</button></div>
      </div>}

      {selected.size > 0 && <div className="sw-bb"><span className="tabular-nums">{selected.size} selected</span>
        <button className="sw-bbn" onClick={()=>batchAct('on')}>Activate</button>
        <button className="sw-bbn" onClick={()=>batchAct('off')}>Deactivate</button>
        <button className="sw-bbn sw-bbd" onClick={()=>batchAct('del')}>Delete</button></div>}

      {previewWords && (
        <div className="sw-preview">
          <h3>Preview Import ({previewWords.length} words)</h3>
          <div className="sw-preview-list">
            {previewWords.slice(0, 10).map((w, i) => (
              <div key={i} className="sw-preview-item">
                <strong>{w.word}</strong> - {w.category} ({w.severity})
              </div>
            ))}
            {previewWords.length > 10 && <div className="sw-preview-item">...and {previewWords.length - 10} more</div>}
          </div>
          <div className="sw-preview-acts">
            <button className="sw-bc" onClick={() => setPreviewWords(null)}>Cancel</button>
            <button className="sw-bs" onClick={confirmImport} disabled={batchImport.isPending}>
              {batchImport.isPending ? 'Importing...' : 'Confirm Import'}
            </button>
          </div>
        </div>
      )}

      {isLoading ? <div className="sw-ld"><Loader2 size={20} className="spin"/> Loading...</div> : <div className="sw-tb">
        <div className="sw-r sw-rh"><span/><span>Word</span><span>Category</span><span>Severity</span><span>Lang</span><span>Source</span><span>Status</span><span/></div>
        {data?.data.map(w => <div key={w.id} className={`sw-r ${!w.is_active?'sw-ri':''}`}>
          <input type="checkbox" checked={selected.has(w.id)} onChange={()=>toggle(w.id)}/>
          <span className="sw-w">{w.word}</span><span className="sw-c">{w.category}</span>
          <span className="sw-sv" style={{color:SEV_COLOR[w.severity]}}>{w.severity}</span>
          <span className="sw-ln">{w.language.toUpperCase()}</span><span className="sw-sr">{w.source}</span>
          <button className="sw-tg" onClick={()=>batchToggle.mutate({ids:[w.id],is_active:!w.is_active})}>
            {w.is_active?<ToggleRight size={18} color="var(--color-success)"/>:<ToggleLeft size={18} color="var(--color-text-tertiary)"/>}</button>
          <button className="sw-dl" onClick={()=>{if(confirm('Delete?'))deleteWord.mutate(w.id)}}><Trash2 size={14}/></button>
        </div>)}
        {data?.data.length===0 && <div className="sw-em">No words found.</div>}
      </div>}

      {totalPages > 1 && <div className="sw-pg">
        <button disabled={page===0} onClick={()=>setPage(p=>p-1)}><ChevronLeft size={14}/> Prev</button>
        <span className="tabular-nums">Page {page+1} / {totalPages}</span>
        <button disabled={page>=totalPages-1} onClick={()=>setPage(p=>p+1)}>Next <ChevronRight size={14}/></button>
      </div>}

      <style>{`
.sw-hdr{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px}
.sw-t{font-size:24px;font-weight:700;color:var(--color-text-primary)}
.sw-st{font-size:13px;color:var(--color-text-tertiary);margin-top:4px}
.sw-ha{display:flex;gap:8px}
.sw-bo,.sw-bp{display:flex;align-items:center;gap:4px;padding:6px 14px;font-size:13px;border-radius:var(--radius-md);cursor:pointer}
.sw-bo{background:var(--color-bg-primary);border:1px solid var(--color-border);color:var(--color-text-secondary)}
.sw-bp{background:var(--color-info);color:white;border:none}
.sw-fl{display:flex;gap:8px;margin-bottom:12px;flex-wrap:wrap}
.sw-fi{display:flex;align-items:center;gap:6px;padding:6px 10px;background:var(--color-bg-primary);border:1px solid var(--color-border);border-radius:var(--radius-sm);flex:1;min-width:160px}
.sw-fii{border:none;outline:none;background:transparent;font-size:13px;color:var(--color-text-primary);width:100%}
.sw-fs{padding:6px 8px;font-size:13px;border:1px solid var(--color-border);border-radius:var(--radius-sm);background:var(--color-bg-primary);color:var(--color-text-primary)}
.sw-af{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:8px;padding:12px;background:var(--color-bg-primary);border:1px solid var(--color-border-light);border-radius:var(--radius-md);margin-bottom:12px}
.sw-in,.sw-sl{padding:7px 10px;font-size:13px;border:1px solid var(--color-border);border-radius:var(--radius-sm);background:var(--color-bg-secondary);color:var(--color-text-primary)}
.sw-aa{grid-column:1/-1;display:flex;justify-content:flex-end;gap:8px}
.sw-bc,.sw-bs{padding:6px 14px;font-size:13px;border-radius:var(--radius-sm);cursor:pointer;border:1px solid var(--color-border);display:flex;align-items:center;gap:4px}
.sw-bc{background:var(--color-bg-primary);color:var(--color-text-secondary)}.sw-bs{background:var(--color-info);color:white;border-color:var(--color-info)}.sw-bs:disabled{opacity:.5}
.sw-bb{display:flex;align-items:center;gap:8px;padding:8px 14px;background:var(--color-info-light);border-radius:var(--radius-md);margin-bottom:8px;font-size:13px;color:var(--color-info)}
.sw-bbn{padding:4px 10px;font-size:12px;background:var(--color-bg-primary);border:1px solid var(--color-border);border-radius:var(--radius-sm);cursor:pointer;color:var(--color-text-secondary)}
.sw-bbd{color:var(--color-danger);border-color:var(--color-danger)}
.sw-tb{background:var(--color-bg-primary);border:1px solid var(--color-border-light);border-radius:var(--radius-lg);overflow:hidden}
.sw-r{display:grid;grid-template-columns:28px 2fr 1fr 80px 50px 70px 36px 32px;gap:8px;align-items:center;padding:9px 14px;font-size:13px;border-bottom:1px solid var(--color-border-light)}
.sw-r:last-child{border-bottom:none}.sw-ri{opacity:.45}
.sw-rh{font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;color:var(--color-text-tertiary);background:var(--color-bg-secondary)}
.sw-w{font-weight:500;color:var(--color-text-primary)}.sw-c,.sw-sr{color:var(--color-text-tertiary);font-size:12px}
.sw-sv{font-weight:600;font-size:12px;text-transform:uppercase}.sw-ln{font-size:11px;font-weight:600;color:var(--color-text-tertiary)}
.sw-tg,.sw-dl{background:none;border:none;cursor:pointer;padding:2px;display:flex;align-items:center}
.sw-dl{color:var(--color-text-tertiary)}.sw-dl:hover{color:var(--color-danger)}
.sw-ld,.sw-em{padding:40px 0;text-align:center;color:var(--color-text-tertiary);font-size:13px;display:flex;align-items:center;justify-content:center;gap:8px}
.sw-pg{display:flex;align-items:center;justify-content:center;gap:16px;margin-top:16px;font-size:13px;color:var(--color-text-secondary)}
.sw-pg button{display:flex;align-items:center;gap:4px;padding:6px 12px;font-size:13px;background:var(--color-bg-primary);border:1px solid var(--color-border);border-radius:var(--radius-sm);cursor:pointer;color:var(--color-text-secondary)}
.sw-pg button:disabled{opacity:.4;cursor:not-allowed}
.spin{animation:spin 1s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}
.sw-preview{background:var(--color-bg-secondary);border:1px solid var(--color-border);border-radius:var(--radius-md);padding:16px;margin-bottom:16px}
.sw-preview h3{margin:0 0 12px;font-size:14px;color:var(--color-text-primary)}
.sw-preview-list{max-height:150px;overflow-y:auto;background:var(--color-bg-primary);border-radius:var(--radius-sm);border:1px solid var(--color-border-light);padding:8px}
.sw-preview-item{font-size:13px;padding:4px 8px;border-bottom:1px solid var(--color-border-light);color:var(--color-text-secondary)}
.sw-preview-item:last-child{border-bottom:none}
.sw-preview-acts{display:flex;justify-content:flex-end;gap:8px;margin-top:12px}
      `}</style>
    </div>
  );
}
