import { useState, useRef } from 'react';
import { Upload, Trash2, Download, Smartphone, FileArchive, Clock, Link2, ExternalLink, CheckCircle2, XCircle } from 'lucide-react';
import { useAppReleases, useCreateRelease, useCreateReleaseFromUrl, useDeleteRelease, parseGoogleDriveFileId, getGoogleDriveDownloadUrl } from '@/hooks/useAppReleases';
import { useAuth } from '@/hooks/useAuth';
import { showToast } from '@/hooks/useToast';
import type { AppRelease } from '@/hooks/useAppReleases';

function formatFileSize(bytes: number | null): string {
  if (!bytes) return '—';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

type UploadMode = 'gdrive' | 'file';

export function ApkUploadPage() {
  const { admin } = useAuth();
  const { data: releases, isLoading } = useAppReleases('android');
  const createMutation = useCreateRelease();
  const createFromUrlMutation = useCreateReleaseFromUrl();
  const deleteMutation = useDeleteRelease();

  const [mode, setMode] = useState<UploadMode>('gdrive');
  const [version, setVersion] = useState('');
  const [buildNumber, setBuildNumber] = useState('');
  const [notes, setNotes] = useState('');
  const [fileSizeMB, setFileSizeMB] = useState('');
  const [submitting, setSubmitting] = useState(false);

  // Google Drive mode
  const [gdriveUrl, setGdriveUrl] = useState('');
  const [gdriveStatus, setGdriveStatus] = useState<'idle' | 'valid' | 'invalid'>('idle');
  const [parsedFileId, setParsedFileId] = useState<string | null>(null);

  // File upload mode
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const resetForm = () => {
    setVersion(''); setBuildNumber(''); setNotes(''); setFileSizeMB('');
    setGdriveUrl(''); setGdriveStatus('idle'); setParsedFileId(null);
    setSelectedFile(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  // Validate Google Drive URL on change
  const handleGdriveUrlChange = (url: string) => {
    setGdriveUrl(url);
    if (!url.trim()) { setGdriveStatus('idle'); setParsedFileId(null); return; }
    const fileId = parseGoogleDriveFileId(url.trim());
    if (fileId) { setGdriveStatus('valid'); setParsedFileId(fileId); }
    else { setGdriveStatus('invalid'); setParsedFileId(null); }
  };

  const handleTestLink = () => {
    if (!parsedFileId) return;
    window.open(getGoogleDriveDownloadUrl(parsedFileId), '_blank');
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.name.endsWith('.apk')) { showToast('Please select a .apk file', 'error'); return; }
      setSelectedFile(file);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!version.trim() || !buildNumber.trim() || !admin) return;

    setSubmitting(true);
    try {
      if (mode === 'gdrive') {
        if (!parsedFileId) return;
        const downloadUrl = getGoogleDriveDownloadUrl(parsedFileId);
        const fileSize = fileSizeMB ? Math.round(parseFloat(fileSizeMB) * 1024 * 1024) : null;
        await createFromUrlMutation.mutateAsync({
          downloadUrl, platform: 'android', version: version.trim(),
          buildNumber: buildNumber.trim(), notes: notes.trim(),
          fileSize, adminId: admin.user_id,
        });
      } else {
        if (!selectedFile) return;
        await createMutation.mutateAsync({
          file: selectedFile, platform: 'android', version: version.trim(),
          buildNumber: buildNumber.trim(), notes: notes.trim(), adminId: admin.user_id,
        });
      }
      showToast(`v${version} (Build ${buildNumber}) saved ✅`, 'success');
      resetForm();
    } catch (err: any) {
      console.error(err);
      showToast(err?.message || 'Failed. Please try again.', 'error', 5000);
    } finally { setSubmitting(false); }
  };

  const handleDelete = async (release: AppRelease) => {
    if (!admin) return;
    if (!confirm(`Delete v${release.version} (Build ${release.build_number})?`)) return;
    try {
      await deleteMutation.mutateAsync({ release, adminId: admin.user_id });
      showToast('Deleted', 'success');
    } catch { showToast('Failed to delete', 'error'); }
  };

  const canSubmit = version.trim() && buildNumber.trim() && !submitting &&
    (mode === 'gdrive' ? gdriveStatus === 'valid' : !!selectedFile);

  const latestRelease = releases?.[0];

  return (
    <div className="apk-container">
      <header className="apk-header">
        <div>
          <h1 className="apk-title">Android APK Manager</h1>
          <p className="apk-subtitle">Upload and manage Android application packages</p>
        </div>
      </header>

      {/* Upload Card */}
      <div className="apk-upload-card">
        <h2 className="apk-section-title"><Upload size={18} /> New Version</h2>

        {/* Mode Tabs */}
        <div className="apk-tabs">
          <button className={`apk-tab ${mode === 'gdrive' ? 'apk-tab--active' : ''}`} onClick={() => setMode('gdrive')}>
            <Link2 size={15} /> Google Drive Link
          </button>
          <button className={`apk-tab ${mode === 'file' ? 'apk-tab--active' : ''}`} onClick={() => setMode('file')}>
            <Upload size={15} /> Direct Upload
          </button>
        </div>

        <form onSubmit={handleSubmit} className="apk-form">
          <div className="apk-form-row">
            <div className="apk-form-group">
              <label>Version <span className="required">*</span></label>
              <input type="text" placeholder="e.g. 1.3.0" value={version} onChange={e => setVersion(e.target.value)} required />
            </div>
            <div className="apk-form-group">
              <label>Build Number <span className="required">*</span></label>
              <input type="text" placeholder="e.g. 10" value={buildNumber} onChange={e => setBuildNumber(e.target.value)} required />
            </div>
          </div>

          {mode === 'gdrive' ? (
            <>
              <div className="apk-form-group">
                <label>Google Drive Share Link <span className="required">*</span></label>
                <div className="apk-gdrive-input-row">
                  <div className="apk-gdrive-input-wrap">
                    <input type="url" placeholder="https://drive.google.com/file/d/.../view?usp=sharing"
                      value={gdriveUrl} onChange={e => handleGdriveUrlChange(e.target.value)} required />
                    {gdriveStatus === 'valid' && <CheckCircle2 size={18} className="apk-gdrive-icon apk-gdrive-ok" />}
                    {gdriveStatus === 'invalid' && <XCircle size={18} className="apk-gdrive-icon apk-gdrive-err" />}
                  </div>
                  {gdriveStatus === 'valid' && (
                    <button type="button" className="apk-btn-test" onClick={handleTestLink}>
                      <ExternalLink size={14} /> Test
                    </button>
                  )}
                </div>
                {gdriveStatus === 'invalid' && <span className="apk-hint-error">Invalid Google Drive link</span>}
                {gdriveStatus === 'valid' && <span className="apk-hint-ok">✓ File ID: {parsedFileId?.slice(0, 20)}…</span>}
              </div>
              <div className="apk-form-group">
                <label>File Size (MB) <span className="apk-optional">optional</span></label>
                <input type="number" step="0.1" min="0" placeholder="e.g. 76.2"
                  value={fileSizeMB} onChange={e => setFileSizeMB(e.target.value)} />
              </div>
            </>
          ) : (
            <div className="apk-form-group">
              <label>APK File <span className="required">*</span></label>
              <div className={`apk-dropzone ${selectedFile ? 'apk-dropzone--has-file' : ''}`}
                onClick={() => fileInputRef.current?.click()}>
                <input ref={fileInputRef} type="file" accept=".apk" onChange={handleFileSelect} style={{ display: 'none' }} />
                {selectedFile ? (
                  <div className="apk-file-info"><FileArchive size={24} /><div>
                    <div className="apk-file-name">{selectedFile.name}</div>
                    <div className="apk-file-size">{formatFileSize(selectedFile.size)}</div>
                  </div></div>
                ) : (
                  <div className="apk-dropzone-placeholder"><Upload size={32} strokeWidth={1.5} /><span>Click to select APK</span></div>
                )}
              </div>
            </div>
          )}

          <div className="apk-form-group">
            <label>Release Notes</label>
            <textarea placeholder="What's new…" value={notes} onChange={e => setNotes(e.target.value)} rows={2} />
          </div>

          <button type="submit" className="apk-btn-upload" disabled={!canSubmit}>
            {submitting ? 'Saving…' : mode === 'gdrive' ? 'Save Release' : 'Upload APK'}
          </button>
        </form>
      </div>

      {/* Current Live Version */}
      {latestRelease && (
        <div className="apk-live-card">
          <div className="apk-live-badge">LIVE</div>
          <div className="apk-live-info">
            <div className="apk-live-version">v{latestRelease.version}
              <span className="apk-live-build">Build {latestRelease.build_number}</span></div>
            <div className="apk-live-meta"><Clock size={13} />{new Date(latestRelease.uploaded_at).toLocaleString()}
              <span className="apk-live-size">{formatFileSize(latestRelease.file_size)}</span></div>
          </div>
          <a href={latestRelease.download_url} className="apk-btn-download" target="_blank" rel="noopener noreferrer">
            <Download size={16} /> Download</a>
        </div>
      )}

      {/* Version History */}
      <div className="apk-history-card">
        <h2 className="apk-section-title"><Smartphone size={18} /> Version History</h2>
        {isLoading ? <div className="apk-empty">Loading…</div> : !releases?.length ? <div className="apk-empty">No releases yet.</div> : (
          <table className="apk-table"><thead><tr>
            <th>Version</th><th>Build</th><th>Size</th><th>Notes</th><th>Source</th><th>Uploaded By</th><th>Uploaded At</th><th className="apk-actions-th">Actions</th>
          </tr></thead><tbody>
            {releases.map((r, idx) => (
              <tr key={r.id} className={idx === 0 ? 'apk-row-latest' : ''}>
                <td><span className="apk-version-tag">v{r.version}</span>{idx === 0 && <span className="apk-latest-badge">Latest</span>}</td>
                <td className="apk-mono">{r.build_number}</td>
                <td className="apk-mono">{formatFileSize(r.file_size)}</td>
                <td className="apk-notes-cell">{r.notes || '—'}</td>
                <td><span className={`apk-source-badge ${r.download_url.includes('drive.google') ? 'apk-source-gdrive' : 'apk-source-storage'}`}>
                  {r.download_url.includes('drive.google') ? 'Drive' : 'Storage'}</span></td>
                <td>{r.uploader_name || '—'}</td>
                <td className="apk-time-cell">{new Date(r.uploaded_at).toLocaleString()}</td>
                <td className="apk-actions-cell">
                  <a href={r.download_url} className="apk-icon-btn apk-icon-download" title="Download" target="_blank" rel="noopener noreferrer"><Download size={14} /></a>
                  <button className="apk-icon-btn apk-icon-delete" title="Delete" onClick={() => handleDelete(r)} disabled={deleteMutation.isPending}><Trash2 size={14} /></button>
                </td>
              </tr>
            ))}
          </tbody></table>
        )}
      </div>

      <style>{`
        .apk-container { padding: var(--spacing-page); max-width: 960px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .apk-header { display: flex; justify-content: space-between; align-items: flex-start; }
        .apk-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin-bottom: 4px; }
        .apk-subtitle { font-size: 14px; color: var(--color-text-tertiary); }
        .apk-upload-card, .apk-history-card { background: var(--color-bg-primary); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: 24px; box-shadow: var(--shadow-card); }
        .apk-section-title { font-size: 16px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 16px; display: flex; align-items: center; gap: 8px; }

        /* Tabs */
        .apk-tabs { display: flex; gap: 4px; margin-bottom: 20px; background: var(--color-bg-secondary); border-radius: var(--radius-md); padding: 4px; }
        .apk-tab { flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 8px 12px; border: none; border-radius: var(--radius-sm); background: transparent; color: var(--color-text-secondary); font-size: 13px; font-weight: 500; cursor: pointer; transition: all 0.15s; }
        .apk-tab:hover { color: var(--color-text-primary); }
        .apk-tab--active { background: var(--color-bg-primary); color: var(--color-info); font-weight: 600; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }

        .apk-form { display: flex; flex-direction: column; gap: 16px; }
        .apk-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .apk-form-group { display: flex; flex-direction: column; gap: 6px; }
        .apk-form-group label { font-size: 13px; font-weight: 600; color: var(--color-text-secondary); }
        .required { color: var(--color-danger); }
        .apk-optional { font-weight: 400; color: var(--color-text-tertiary); font-size: 11px; }
        .apk-form-group input, .apk-form-group textarea { padding: 10px 12px; border: 1px solid var(--color-border); border-radius: var(--radius-md); font-family: inherit; font-size: 14px; color: var(--color-text-primary); background: var(--color-bg-primary); outline: none; transition: border-color 0.15s; }
        .apk-form-group input:focus, .apk-form-group textarea:focus { border-color: var(--color-info); }

        /* Google Drive input */
        .apk-gdrive-input-row { display: flex; gap: 8px; align-items: center; }
        .apk-gdrive-input-wrap { flex: 1; position: relative; }
        .apk-gdrive-input-wrap input { width: 100%; padding-right: 36px; }
        .apk-gdrive-icon { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); }
        .apk-gdrive-ok { color: var(--color-success); }
        .apk-gdrive-err { color: var(--color-danger); }
        .apk-hint-error { font-size: 12px; color: var(--color-danger); }
        .apk-hint-ok { font-size: 12px; color: var(--color-success); }
        .apk-btn-test { display: inline-flex; align-items: center; gap: 4px; padding: 8px 14px; border: 1px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-bg-primary); color: var(--color-text-secondary); font-size: 13px; cursor: pointer; white-space: nowrap; transition: all 0.15s; }
        .apk-btn-test:hover { border-color: var(--color-info); color: var(--color-info); }

        /* Dropzone */
        .apk-dropzone { border: 2px dashed var(--color-border); border-radius: var(--radius-md); padding: 32px; text-align: center; cursor: pointer; transition: all 0.2s; background: var(--color-bg-secondary); }
        .apk-dropzone:hover { border-color: var(--color-info); background: var(--color-bg-primary); }
        .apk-dropzone--has-file { border-style: solid; border-color: var(--color-success); background: var(--color-bg-primary); padding: 16px 20px; text-align: left; }
        .apk-dropzone-placeholder { display: flex; flex-direction: column; align-items: center; gap: 8px; color: var(--color-text-tertiary); font-size: 14px; }
        .apk-file-info { display: flex; align-items: center; gap: 12px; color: var(--color-success); }
        .apk-file-name { font-size: 14px; font-weight: 600; color: var(--color-text-primary); }
        .apk-file-size { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; }

        .apk-btn-upload { padding: 12px 24px; background: var(--color-info); color: white; border: none; border-radius: var(--radius-md); font-size: 14px; font-weight: 600; cursor: pointer; align-self: flex-start; transition: opacity 0.15s; }
        .apk-btn-upload:hover:not(:disabled) { opacity: 0.9; }
        .apk-btn-upload:disabled { opacity: 0.5; cursor: not-allowed; }

        /* Live Card */
        .apk-live-card { display: flex; align-items: center; gap: 16px; background: linear-gradient(135deg, #065f46 0%, #047857 100%); color: white; border-radius: var(--radius-md); padding: 20px 24px; box-shadow: 0 4px 16px rgba(4,120,87,0.25); }
        .apk-live-badge { background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 100px; font-size: 11px; font-weight: 700; letter-spacing: 1px; flex-shrink: 0; }
        .apk-live-info { flex: 1; }
        .apk-live-version { font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
        .apk-live-build { font-size: 12px; font-weight: 500; opacity: 0.7; background: rgba(255,255,255,0.15); padding: 2px 8px; border-radius: 6px; }
        .apk-live-meta { display: flex; align-items: center; gap: 6px; font-size: 12px; opacity: 0.8; margin-top: 4px; }
        .apk-live-size { margin-left: 8px; opacity: 0.7; }
        .apk-btn-download { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; background: rgba(255,255,255,0.2); color: white; text-decoration: none; border-radius: var(--radius-md); font-size: 13px; font-weight: 600; transition: background 0.15s; flex-shrink: 0; }
        .apk-btn-download:hover { background: rgba(255,255,255,0.3); }

        /* Table */
        .apk-empty { text-align: center; padding: 40px; color: var(--color-text-tertiary); font-size: 14px; }
        .apk-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .apk-table th { text-align: left; padding: 10px 12px; font-size: 11px; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid var(--color-border); }
        .apk-table td { padding: 12px; border-bottom: 1px solid var(--color-border-light); color: var(--color-text-primary); }
        .apk-row-latest { background: var(--color-bg-secondary); }
        .apk-version-tag { font-weight: 600; color: var(--color-info); }
        .apk-latest-badge { display: inline-block; margin-left: 6px; font-size: 10px; font-weight: 600; background: var(--color-success); color: white; padding: 1px 6px; border-radius: 4px; text-transform: uppercase; vertical-align: middle; }
        .apk-mono { font-family: var(--font-mono); font-size: 13px; }
        .apk-notes-cell { max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--color-text-secondary); }
        .apk-time-cell { font-size: 12px; color: var(--color-text-secondary); white-space: nowrap; }
        .apk-actions-th { text-align: right; }
        .apk-actions-cell { text-align: right; display: flex; justify-content: flex-end; gap: 6px; }
        .apk-icon-btn { display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 30px; border-radius: var(--radius-sm); border: 1px solid transparent; background: transparent; cursor: pointer; transition: all 0.15s; text-decoration: none; }
        .apk-icon-download { color: var(--color-info); }
        .apk-icon-download:hover { background: var(--color-info-light); }
        .apk-icon-delete { color: var(--color-danger); }
        .apk-icon-delete:hover { background: var(--color-danger-light); }
        .apk-icon-delete:disabled { opacity: 0.4; cursor: not-allowed; }

        /* Source badges */
        .apk-source-badge { font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
        .apk-source-gdrive { background: #e8f5e9; color: #2e7d32; }
        .apk-source-storage { background: #e3f2fd; color: #1565c0; }
      `}</style>
    </div>
  );
}
