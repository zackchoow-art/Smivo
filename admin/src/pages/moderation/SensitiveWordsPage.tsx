/**
 * Sensitive words library management page.
 * Supports search, multi-filter, add, delete, toggle, CSV batch import,
 * and cloud sync from LDNOOBW (github.com/LDNOOBW).
 */
import { useState, useRef } from 'react';
import { Plus, Search, Upload, Trash2, Loader2, ChevronLeft, ChevronRight, ToggleLeft, ToggleRight, Filter, CloudDownload, ArrowLeftRight, X } from 'lucide-react';
import { useSensitiveWords, useCreateSensitiveWord, useDeleteSensitiveWord, useBatchImportWords, useBatchToggleWords, buildCloudSyncPreview, type SensitiveWordFilters, type ImportMode, type CloudSyncPreview } from '@/hooks/useSensitiveWords';
import { DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { SensitiveWord } from '@/types';

const SEV_COLOR: Record<string, string> = { block: 'var(--color-danger)', warn: 'var(--color-warning)' };
const CATS = ['general', 'weapons', 'drugs', 'adult', 'hate', 'fraud', 'spam'];
const MODE_LABELS: Record<ImportMode, { label: string; desc: string }> = {
  strict: { label: 'Strict', desc: 'All words → block. Maximum safety.' },
  recommended: { label: 'Recommended', desc: 'Mild words → warn, rest → block.' },
  relaxed: { label: 'Relaxed', desc: 'Skip mild words entirely, only block severe.' },
};

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

  // Cloud sync state
  const [showSyncPanel, setShowSyncPanel] = useState(false);
  const [syncLangs, setSyncLangs] = useState<{ en: boolean; zh: boolean }>({ en: true, zh: true });
  const [syncMode, setSyncMode] = useState<ImportMode>('recommended');
  const [syncLoading, setSyncLoading] = useState(false);
  const [syncPreview, setSyncPreview] = useState<CloudSyncPreview | null>(null);
  const [editableWords, setEditableWords] = useState<Partial<SensitiveWord>[]>([]);
  const [previewSearch, setPreviewSearch] = useState('');

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
    if (words.length > 0) setPreviewWords(words);
    if (fileRef.current) fileRef.current.value = '';
  };

  const confirmImport = async () => {
    if (!previewWords) return;
    await batchImport.mutateAsync(previewWords);
    alert(`Imported ${previewWords.length} words.`);
    setPreviewWords(null);
  };

  const handleSyncFetch = async () => {
    const langs = [...(syncLangs.en ? ['en' as const] : []), ...(syncLangs.zh ? ['zh' as const] : [])];
    if (langs.length === 0) { alert('Select at least one language.'); return; }
    setSyncLoading(true);
    try {
      const preview = await buildCloudSyncPreview(langs, syncMode);
      setSyncPreview(preview);
      setEditableWords(preview.words);
      setPreviewSearch('');
    } catch (err) {
      console.error(err);
      alert('Failed to fetch from cloud.');
    } finally { setSyncLoading(false); }
  };

  // Preview editing helpers
  const moveWord = (idx: number) => {
    setEditableWords(prev => prev.map((w, i) => i === idx ? { ...w, severity: w.severity === 'block' ? 'warn' : 'block' } : w));
  };
  const removeWord = (idx: number) => {
    setEditableWords(prev => prev.filter((_, i) => i !== idx));
  };
  const addPreviewWord = (word: string, severity: 'block' | 'warn') => {
    if (!word.trim()) return;
    setEditableWords(prev => [{ word: word.trim().toLowerCase(), category: 'general', severity, language: 'en', source: 'api' as const, is_active: true }, ...prev]);
  };

  const handleSyncConfirm = async () => {
    if (editableWords.length === 0) return;
    try {
      await batchImport.mutateAsync(editableWords);
      alert(`Imported ${editableWords.length} words.`);
      setSyncPreview(null);
      setEditableWords([]);
      setShowSyncPanel(false);
    } catch (err) {
      console.error(err);
      alert('Import failed.');
    }
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
          <button className="sw-bo" onClick={() => { setShowSyncPanel(!showSyncPanel); setSyncPreview(null); }}><CloudDownload size={14}/> Sync Cloud</button>
          <label className="sw-bo"><Upload size={14}/> CSV<input ref={fileRef} type="file" accept=".csv" hidden onChange={handleCSV}/></label>
          <button className="sw-bp" onClick={() => setShowAdd(true)}><Plus size={14}/> Add</button>
        </div></div>

      {/* ── Cloud Sync Panel ── */}
      {showSyncPanel && (
        <div className="sw-sync-panel">
          <h3 className="sw-sync-title">☁️ Cloud Sync — LDNOOBW</h3>
          <p className="sw-sync-desc">Fetch profanity word lists from <a href="https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words" target="_blank" rel="noreferrer">LDNOOBW</a> (3.3k ⭐, 27 languages, CC BY 4.0)</p>

          <div className="sw-sync-controls">
            <div className="sw-sync-group">
              <span className="sw-sync-label">Languages</span>
              <label className="sw-sync-check"><input type="checkbox" checked={syncLangs.en} onChange={e => setSyncLangs(p => ({...p, en: e.target.checked}))}/> English (403 words)</label>
              <label className="sw-sync-check"><input type="checkbox" checked={syncLangs.zh} onChange={e => setSyncLangs(p => ({...p, zh: e.target.checked}))}/> Chinese (319 words)</label>
            </div>
            <div className="sw-sync-group">
              <span className="sw-sync-label">Import Mode</span>
              {(['recommended', 'relaxed', 'strict'] as ImportMode[]).map(m => (
                <label key={m} className={`sw-sync-mode ${syncMode === m ? 'sw-sync-mode--active' : ''}`}>
                  <input type="radio" name="mode" checked={syncMode === m} onChange={() => setSyncMode(m)}/>
                  <strong>{MODE_LABELS[m].label}</strong>
                  <span>{MODE_LABELS[m].desc}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="sw-sync-actions">
            <button className="sw-bc" onClick={() => { setShowSyncPanel(false); setSyncPreview(null); }}>Cancel</button>
            <button className="sw-bs" onClick={handleSyncFetch} disabled={syncLoading}>
              {syncLoading ? <><Loader2 size={14} className="spin"/> Fetching...</> : 'Fetch & Preview'}
            </button>
          </div>

          {/* Sync Preview Results — editable two-column layout */}
          {syncPreview && (() => {
            const blockWords = editableWords.map((w, i) => ({ ...w, _idx: i })).filter(w => w.severity === 'block');
            const warnWords  = editableWords.map((w, i) => ({ ...w, _idx: i })).filter(w => w.severity === 'warn');
            const q = previewSearch.toLowerCase();
            const filterFn = (w: Partial<SensitiveWord>) => !q || (w.word ?? '').includes(q);
            const filteredBlock = blockWords.filter(filterFn);
            const filteredWarn  = warnWords.filter(filterFn);

            return (
            <div className="sw-sync-results">
              {/* Stats row */}
              <div className="sw-sync-stats">
                <div className="sw-sync-stat"><span className="sw-sync-stat-val tabular-nums">{syncPreview.stats.totalFetched}</span><span className="sw-sync-stat-lbl">Fetched</span></div>
                <div className="sw-sync-stat"><span className="sw-sync-stat-val tabular-nums" style={{color:'var(--color-text-tertiary)'}}>{syncPreview.stats.alreadyInDb}</span><span className="sw-sync-stat-lbl">In DB</span></div>
                <div className="sw-sync-stat"><span className="sw-sync-stat-val tabular-nums" style={{color:'var(--color-danger)'}}>{blockWords.length}</span><span className="sw-sync-stat-lbl">Block</span></div>
                <div className="sw-sync-stat"><span className="sw-sync-stat-val tabular-nums" style={{color:'var(--color-warning)'}}>{warnWords.length}</span><span className="sw-sync-stat-lbl">Warn</span></div>
                <div className="sw-sync-stat"><span className="sw-sync-stat-val tabular-nums" style={{color:'var(--color-success)'}}>{editableWords.length}</span><span className="sw-sync-stat-lbl">Total Import</span></div>
              </div>

              {/* Search + Add */}
              <div className="sw-prev-toolbar">
                <div className="sw-fi" style={{flex:1}}><Search size={14}/><input placeholder="Search preview..." value={previewSearch} onChange={e=>setPreviewSearch(e.target.value)} className="sw-fii"/></div>
                <form className="sw-prev-add" onSubmit={e=>{e.preventDefault();const inp=(e.target as HTMLFormElement).elements.namedItem('newword') as HTMLInputElement;addPreviewWord(inp.value,'block');inp.value='';}}>
                  <input name="newword" placeholder="Add word..." className="sw-in" style={{padding:'5px 8px',fontSize:12}}/>
                  <button type="submit" className="sw-bp" style={{padding:'4px 10px',fontSize:12}}>+ Add</button>
                </form>
              </div>

              {editableWords.length > 0 ? (
                <div className="sw-prev-cols">
                  {/* Block column */}
                  <div className="sw-prev-col">
                    <div className="sw-prev-col-hdr sw-prev-col-hdr--block">🚫 Block ({blockWords.length})</div>
                    <div className="sw-prev-col-list">
                      {filteredBlock.slice(0, 200).map(w => (
                        <div key={w._idx} className="sw-prev-word">
                          <span className="sw-prev-word-txt">{w.word} <span className="sw-prev-lang">{w.language?.toUpperCase()}</span></span>
                          <div className="sw-prev-word-acts">
                            <button title="Move to Warn" onClick={()=>moveWord(w._idx)} className="sw-prev-btn sw-prev-btn--move"><ArrowLeftRight size={12}/></button>
                            <button title="Remove" onClick={()=>removeWord(w._idx)} className="sw-prev-btn sw-prev-btn--del"><X size={12}/></button>
                          </div>
                        </div>
                      ))}
                      {filteredBlock.length > 200 && <div className="sw-prev-more">+{filteredBlock.length - 200} more</div>}
                      {filteredBlock.length === 0 && <div className="sw-prev-empty">No matches</div>}
                    </div>
                  </div>
                  {/* Warn column */}
                  <div className="sw-prev-col">
                    <div className="sw-prev-col-hdr sw-prev-col-hdr--warn">⚠️ Warn ({warnWords.length})</div>
                    <div className="sw-prev-col-list">
                      {filteredWarn.slice(0, 200).map(w => (
                        <div key={w._idx} className="sw-prev-word">
                          <span className="sw-prev-word-txt">{w.word} <span className="sw-prev-lang">{w.language?.toUpperCase()}</span></span>
                          <div className="sw-prev-word-acts">
                            <button title="Move to Block" onClick={()=>moveWord(w._idx)} className="sw-prev-btn sw-prev-btn--move"><ArrowLeftRight size={12}/></button>
                            <button title="Remove" onClick={()=>removeWord(w._idx)} className="sw-prev-btn sw-prev-btn--del"><X size={12}/></button>
                          </div>
                        </div>
                      ))}
                      {filteredWarn.length > 200 && <div className="sw-prev-more">+{filteredWarn.length - 200} more</div>}
                      {filteredWarn.length === 0 && <div className="sw-prev-empty">No matches</div>}
                    </div>
                  </div>
                </div>
              ) : (
                <p style={{textAlign:'center',color:'var(--color-success)',padding:16,fontSize:13}}>✅ Database is already up to date.</p>
              )}

              {editableWords.length > 0 && (
                <div className="sw-sync-actions" style={{marginTop:12}}>
                  <span style={{fontSize:12,color:'var(--color-text-tertiary)'}}>Removed {syncPreview.stats.newWords - editableWords.length} word(s) from original</span>
                  <button className="sw-bs" onClick={handleSyncConfirm} disabled={batchImport.isPending}>
                    {batchImport.isPending ? 'Importing...' : `Confirm Import (${editableWords.length})`}
                  </button>
                </div>
              )}
            </div>
            );
          })()}
        </div>
      )}

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

      {/* CSV preview (reused from before) */}
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

/* Cloud Sync Panel */
.sw-sync-panel{background:var(--color-bg-primary);border:1px solid var(--color-info);border-radius:var(--radius-lg);padding:20px;margin-bottom:16px;box-shadow:0 2px 8px rgba(0,0,0,.06)}
.sw-sync-title{font-size:16px;font-weight:600;color:var(--color-text-primary);margin:0 0 4px}
.sw-sync-desc{font-size:12px;color:var(--color-text-tertiary);margin:0 0 16px}
.sw-sync-desc a{color:var(--color-info);text-decoration:underline}
.sw-sync-controls{display:flex;gap:24px;margin-bottom:16px;flex-wrap:wrap}
.sw-sync-group{display:flex;flex-direction:column;gap:8px;min-width:200px}
.sw-sync-label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--color-text-tertiary)}
.sw-sync-check{font-size:13px;color:var(--color-text-secondary);display:flex;align-items:center;gap:6px;cursor:pointer}
.sw-sync-mode{display:flex;flex-direction:column;gap:2px;padding:8px 12px;border:1px solid var(--color-border);border-radius:var(--radius-sm);cursor:pointer;font-size:12px;color:var(--color-text-secondary);transition:border-color .15s}
.sw-sync-mode input{display:none}
.sw-sync-mode strong{font-size:13px;color:var(--color-text-primary)}
.sw-sync-mode--active{border-color:var(--color-info);background:var(--color-info-light)}
.sw-sync-actions{display:flex;gap:8px;justify-content:flex-end}
.sw-sync-results{margin-top:16px;border-top:1px solid var(--color-border-light);padding-top:16px}
.sw-sync-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:16px}
.sw-sync-stat{text-align:center;padding:12px;background:var(--color-bg-secondary);border-radius:var(--radius-sm)}
.sw-sync-stat-val{display:block;font-size:22px;font-weight:700;color:var(--color-text-primary)}
.sw-sync-stat-lbl{font-size:11px;color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:.04em}

/* Two-column editable preview */
.sw-prev-toolbar{display:flex;gap:8px;margin-bottom:12px;align-items:center}
.sw-prev-add{display:flex;gap:4px;align-items:center}
.sw-prev-cols{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media(max-width:768px){.sw-prev-cols{grid-template-columns:1fr}}
.sw-prev-col{border:1px solid var(--color-border-light);border-radius:var(--radius-md);overflow:hidden}
.sw-prev-col-hdr{padding:8px 12px;font-size:13px;font-weight:600;text-transform:uppercase;letter-spacing:.03em}
.sw-prev-col-hdr--block{background:rgba(239,68,68,.08);color:var(--color-danger);border-bottom:2px solid var(--color-danger)}
.sw-prev-col-hdr--warn{background:rgba(245,158,11,.08);color:var(--color-warning);border-bottom:2px solid var(--color-warning)}
.sw-prev-col-list{max-height:320px;overflow-y:auto;padding:4px 0}
.sw-prev-word{display:flex;align-items:center;justify-content:space-between;padding:3px 10px;font-size:12px;border-bottom:1px solid var(--color-border-light)}
.sw-prev-word:last-child{border-bottom:none}
.sw-prev-word:hover{background:var(--color-bg-secondary)}
.sw-prev-word-txt{font-weight:500;color:var(--color-text-primary);flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.sw-prev-lang{font-size:10px;font-weight:700;color:var(--color-text-tertiary);margin-left:4px}
.sw-prev-word-acts{display:flex;gap:2px;flex-shrink:0}
.sw-prev-btn{background:none;border:none;cursor:pointer;padding:3px;border-radius:var(--radius-sm);color:var(--color-text-tertiary);display:flex;align-items:center}
.sw-prev-btn:hover{background:var(--color-bg-tertiary)}
.sw-prev-btn--move:hover{color:var(--color-info)}
.sw-prev-btn--del:hover{color:var(--color-danger)}
.sw-prev-more,.sw-prev-empty{padding:8px 12px;text-align:center;font-size:11px;color:var(--color-text-tertiary);font-style:italic}
      `}</style>
    </div>
  );
}
