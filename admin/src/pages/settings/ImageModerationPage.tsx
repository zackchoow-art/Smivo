/**
 * ImageModerationPage
 *
 * Admin settings page for configuring image moderation providers:
 *   - OpenAI omni-moderation-latest (image + text)
 *   - Google Cloud Vision SafeSearch (1000 req/month free tier)
 *
 * Features:
 *   - API key input → encrypted storage (never returned to client)
 *   - Monthly usage counters with quota bar for Google Vision
 *   - Test button with a safe built-in image
 *   - Test with custom URL
 */
import { useState } from 'react';
import {
  Eye, EyeOff, Key, CheckCircle2, AlertCircle, Loader2,
  FlaskConical, ExternalLink, RefreshCw, ShieldCheck
} from 'lucide-react';
import {
  useModerationUsage,
  useSecretStatus,
  useSavePlatformSecret,
  useTestOpenAIModeration,
  useTestGoogleVisionModeration,
  type OpenAIResult,
  type GoogleResult,
} from '@/hooks/useImageModeration';

// ── Likelihood label colors for Google Vision ──────────────────
const LIKELIHOOD_COLOR: Record<string, string> = {
  UNKNOWN:       'var(--color-text-tertiary)',
  VERY_UNLIKELY: 'var(--color-success)',
  UNLIKELY:      'var(--color-success)',
  POSSIBLE:      'var(--color-warning)',
  LIKELY:        'var(--color-danger)',
  VERY_LIKELY:   'var(--color-danger)',
};

// ── Sub-component: API Key Input Card ─────────────────────────
interface ApiKeyCardProps {
  provider: string;
  secretKey: string;
  label: string;
  docsUrl: string;
  description: string;
}

function ApiKeyCard({ provider, secretKey, label, docsUrl, description }: ApiKeyCardProps) {
  const [inputValue, setInputValue] = useState('');
  const [showValue, setShowValue] = useState(false);
  const [saved, setSaved] = useState(false);

  const { data: status, isLoading: statusLoading } = useSecretStatus(secretKey);
  const saveMutation = useSavePlatformSecret();

  const handleSave = async () => {
    if (!inputValue.trim()) return;
    await saveMutation.mutateAsync({
      key: secretKey,
      value: inputValue.trim(),
      description: `${label} API Key`,
    });
    setSaved(true);
    setInputValue('');
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="im-card">
      <div className="im-card-header">
        <div className="im-card-title-row">
          <Key size={16} color="var(--color-info)" />
          <h3 className="im-card-title">{label}</h3>
          <a href={docsUrl} target="_blank" rel="noreferrer" className="im-docs-link">
            Docs <ExternalLink size={11} />
          </a>
        </div>
        <p className="im-card-desc">{description}</p>
      </div>

      {/* Current Status */}
      <div className="im-status-row">
        {statusLoading ? (
          <span className="im-status im-status--loading"><Loader2 size={13} className="spin" /> Checking…</span>
        ) : status?.exists ? (
          <span className="im-status im-status--ok">
            <CheckCircle2 size={13} />
            Key saved · Last updated {status.last_updated
              ? new Date(status.last_updated).toLocaleDateString()
              : 'unknown'}
          </span>
        ) : (
          <span className="im-status im-status--missing">
            <AlertCircle size={13} /> No key configured
          </span>
        )}
      </div>

      {/* Input */}
      <div className="im-input-row">
        <div className="im-input-wrap">
          <input
            id={`api-key-${provider}`}
            type={showValue ? 'text' : 'password'}
            className="im-input"
            placeholder={status?.exists ? '••••••••••••  (enter new key to replace)' : 'Paste API key here'}
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSave()}
          />
          <button
            className="im-eye-btn"
            onClick={() => setShowValue(v => !v)}
            title={showValue ? 'Hide' : 'Show'}
          >
            {showValue ? <EyeOff size={15} /> : <Eye size={15} />}
          </button>
        </div>
        <button
          className="im-btn im-btn--primary"
          onClick={handleSave}
          disabled={!inputValue.trim() || saveMutation.isPending}
        >
          {saveMutation.isPending ? <Loader2 size={14} className="spin" /> : null}
          {saved ? 'Saved!' : 'Save Key'}
        </button>
      </div>

      {saveMutation.isError && (
        <p className="im-error">{(saveMutation.error as Error).message}</p>
      )}
    </div>
  );
}

// ── Sub-component: Usage Counter Card ─────────────────────────
function UsageCard() {
  const { data: usage, isLoading, refetch, isFetching } = useModerationUsage();

  const googleCount   = usage?.google_vision?.count ?? 0;
  const googleLimit   = usage?.google_vision?.limit ?? 1000;
  const googlePct     = Math.min(100, (googleCount / googleLimit) * 100);
  const openAiCount   = usage?.openai?.count ?? 0;
  const currentMonth  = usage?.month ?? new Date().toISOString().slice(0, 7);

  return (
    <div className="im-card">
      <div className="im-card-header">
        <div className="im-card-title-row">
          <RefreshCw size={16} color="var(--color-info)" />
          <h3 className="im-card-title">Monthly Usage — {currentMonth}</h3>
          <button
            className="im-refresh-btn"
            onClick={() => refetch()}
            disabled={isFetching}
            title="Refresh counters"
          >
            <RefreshCw size={13} className={isFetching ? 'spin' : ''} />
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="im-state"><Loader2 size={20} className="spin" /><span>Loading…</span></div>
      ) : (
        <div className="im-usage-grid">
          {/* OpenAI */}
          <div className="im-usage-item">
            <div className="im-usage-label">OpenAI omni-moderation-latest</div>
            <div className="im-usage-count">{openAiCount.toLocaleString()} calls</div>
            <div className="im-usage-sub">No monthly limit (pay per use)</div>
          </div>

          {/* Google Vision */}
          <div className="im-usage-item">
            <div className="im-usage-label">Google Cloud Vision SafeSearch</div>
            <div className="im-usage-count-row">
              <span className={`im-usage-count ${googleCount >= googleLimit ? 'im-count--over' : ''}`}>
                {googleCount.toLocaleString()}
              </span>
              <span className="im-usage-slash">/ {googleLimit.toLocaleString()} free</span>
            </div>
            {/* Quota bar */}
            <div className="im-quota-bar-bg">
              <div
                className={`im-quota-bar-fill ${googlePct >= 90 ? 'im-bar--danger' : googlePct >= 70 ? 'im-bar--warn' : 'im-bar--ok'}`}
                style={{ width: `${googlePct}%` }}
              />
            </div>
            <div className="im-usage-sub">
              {googleCount >= googleLimit
                ? '⚠️ Quota exhausted — resets on the 1st'
                : `${(googleLimit - googleCount).toLocaleString()} requests remaining this month`}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Sub-component: Test Panel ──────────────────────────────────
function TestPanel() {
  const [customUrl, setCustomUrl] = useState('');
  const [useCustom, setUseCustom] = useState(false);

  const openAiTest    = useTestOpenAIModeration();
  const googleTest    = useTestGoogleVisionModeration();

  const [openAiResult,  setOpenAiResult]  = useState<OpenAIResult  | null>(null);
  const [googleResult,  setGoogleResult]  = useState<GoogleResult  | null>(null);

  const handleTestOpenAI = async () => {
    setOpenAiResult(null);
    const res = await openAiTest.mutateAsync(
      useCustom && customUrl ? { imageUrls: [customUrl] } : { isTest: true }
    );
    setOpenAiResult(res);
  };

  const handleTestGoogle = async () => {
    setGoogleResult(null);
    const res = await googleTest.mutateAsync(
      useCustom && customUrl ? { imageUrls: [customUrl] } : { isTest: true }
    );
    setGoogleResult(res);
  };

  return (
    <div className="im-card">
      <div className="im-card-header">
        <div className="im-card-title-row">
          <FlaskConical size={16} color="var(--color-warning)" />
          <h3 className="im-card-title">Test Moderation</h3>
        </div>
        <p className="im-card-desc">
          Run a test call against each provider. The built-in test image is a safe, transparent PNG.
        </p>
      </div>

      {/* Image source toggle */}
      <div className="im-test-source">
        <label className="im-radio-label">
          <input type="radio" name="test-source" checked={!useCustom} onChange={() => setUseCustom(false)} />
          Use built-in test image (safe PNG)
        </label>
        <label className="im-radio-label">
          <input type="radio" name="test-source" checked={useCustom} onChange={() => setUseCustom(true)} />
          Custom image URL
        </label>
      </div>

      {useCustom && (
        <div className="im-input-row" style={{ marginBottom: 16 }}>
          <input
            type="url"
            className="im-input"
            placeholder="https://…/image.jpg (must be publicly accessible)"
            value={customUrl}
            onChange={(e) => setCustomUrl(e.target.value)}
          />
        </div>
      )}

      <div className="im-test-btn-row">
        <button
          id="test-openai-btn"
          className="im-btn im-btn--outline"
          onClick={handleTestOpenAI}
          disabled={openAiTest.isPending}
        >
          {openAiTest.isPending ? <Loader2 size={14} className="spin" /> : <ShieldCheck size={14} />}
          Test OpenAI
        </button>
        <button
          id="test-google-btn"
          className="im-btn im-btn--outline"
          onClick={handleTestGoogle}
          disabled={googleTest.isPending}
        >
          {googleTest.isPending ? <Loader2 size={14} className="spin" /> : <ShieldCheck size={14} />}
          Test Google Vision
        </button>
      </div>

      {/* Error display */}
      {openAiTest.isError && (
        <div className="im-result im-result--error">
          <AlertCircle size={14} /> OpenAI Error: {(openAiTest.error as Error).message}
        </div>
      )}
      {googleTest.isError && (
        <div className="im-result im-result--error">
          <AlertCircle size={14} /> Google Error: {(googleTest.error as Error).message}
        </div>
      )}

      {/* OpenAI Result */}
      {openAiResult && (
        <div className={`im-result ${openAiResult.flagged ? 'im-result--flagged' : 'im-result--clean'}`}>
          <div className="im-result-header">
            {openAiResult.flagged
              ? <AlertCircle size={16} color="var(--color-danger)" />
              : <CheckCircle2 size={16} color="var(--color-success)" />}
            <strong>OpenAI omni-moderation-latest</strong>
            <span className={`im-badge ${openAiResult.flagged ? 'im-badge--danger' : 'im-badge--ok'}`}>
              {openAiResult.flagged ? 'FLAGGED' : 'CLEAN'}
            </span>
          </div>
          <div className="im-score-grid">
            {Object.entries(openAiResult.category_scores)
              .sort(([, a], [, b]) => b - a)
              .map(([cat, score]) => (
                <div key={cat} className="im-score-row">
                  <span className={`im-score-label ${openAiResult.categories[cat] ? 'im-score-label--flagged' : ''}`}>
                    {openAiResult.categories[cat] ? '⚠ ' : ''}{cat}
                  </span>
                  <div className="im-score-bar-bg">
                    <div
                      className="im-score-bar-fill"
                      style={{
                        width: `${Math.round(score * 100)}%`,
                        background: score > 0.5 ? 'var(--color-danger)' : score > 0.1 ? 'var(--color-warning)' : 'var(--color-success)',
                      }}
                    />
                  </div>
                  <span className="im-score-pct">{(score * 100).toFixed(1)}%</span>
                </div>
              ))}
          </div>
        </div>
      )}

      {/* Google Result */}
      {googleResult && (
        <div className={`im-result ${googleResult.flagged ? 'im-result--flagged' : 'im-result--clean'}`}>
          <div className="im-result-header">
            {googleResult.flagged
              ? <AlertCircle size={16} color="var(--color-danger)" />
              : <CheckCircle2 size={16} color="var(--color-success)" />}
            <strong>Google Cloud Vision SafeSearch</strong>
            <span className={`im-badge ${googleResult.flagged ? 'im-badge--danger' : 'im-badge--ok'}`}>
              {googleResult.flagged ? 'FLAGGED' : 'CLEAN'}
            </span>
          </div>
          {googleResult.flagged && (
            <div className="im-flagged-reasons">
              Flagged categories: {googleResult.reasons.join(', ')}
            </div>
          )}
          <div className="im-ss-grid">
            {Object.entries(googleResult.safe_search).map(([cat, likelihood]) => (
              <div key={cat} className="im-ss-row">
                <span className="im-ss-cat">{cat}</span>
                <span className="im-ss-badge" style={{ color: LIKELIHOOD_COLOR[likelihood] ?? 'inherit' }}>
                  {likelihood}
                </span>
              </div>
            ))}
          </div>
          <div className="im-quota-note">
            Google Vision: {googleResult.usage_count}/{googleResult.monthly_limit} used this month
            ({googleResult.quota_remaining} remaining)
          </div>
        </div>
      )}
    </div>
  );
}

// ── Main Page ──────────────────────────────────────────────────
export function ImageModerationPage() {
  return (
    <div className="im-page">
      <div className="im-header">
        <h1 className="im-title">Image Moderation</h1>
        <p className="im-subtitle">
          Configure AI-powered image review providers. API keys are encrypted before storage and are never returned to the client.
        </p>
      </div>

      <div className="im-section-title">🔑 API Keys</div>
      <ApiKeyCard
        provider="openai"
        secretKey="openai_api_key"
        label="OpenAI — omni-moderation-latest"
        docsUrl="https://platform.openai.com/docs/api-reference/moderations"
        description="Detects sexual, violent, harassment, hate, and self-harm content in both images and text. Uses the omni-moderation-latest model with image URL input."
      />
      <ApiKeyCard
        provider="google"
        secretKey="google_vision_api_key"
        label="Google Cloud Vision — SafeSearch Detection"
        docsUrl="https://cloud.google.com/vision/docs/detecting-safe-search"
        description="Detects adult, violent, and racy content. Free tier: 1,000 requests/month. Quota is automatically enforced — calls will be blocked when the limit is reached."
      />

      <div className="im-section-title" style={{ marginTop: 32 }}>📊 Usage This Month</div>
      <UsageCard />

      <div className="im-section-title" style={{ marginTop: 32 }}>🧪 Test</div>
      <TestPanel />

      <style>{`
        .im-page { padding: var(--spacing-page); max-width: 780px; }
        .im-header { margin-bottom: 28px; }
        .im-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .im-subtitle { font-size: 14px; color: var(--color-text-secondary); margin-top: 6px; }

        .im-section-title {
          font-size: 13px; font-weight: 600; text-transform: uppercase;
          letter-spacing: 0.04em; color: var(--color-text-tertiary);
          margin-bottom: 12px;
        }

        .im-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-md);
          padding: 20px 24px;
          margin-bottom: 16px;
        }

        .im-card-header { margin-bottom: 16px; }
        .im-card-title-row { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
        .im-card-title { font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0; flex: 1; }
        .im-card-desc { font-size: 13px; color: var(--color-text-secondary); margin: 0; line-height: 1.5; }

        .im-docs-link {
          display: flex; align-items: center; gap: 3px; font-size: 11px;
          color: var(--color-info); text-decoration: none; white-space: nowrap;
        }
        .im-docs-link:hover { text-decoration: underline; }

        .im-status-row { margin-bottom: 14px; }
        .im-status { display: inline-flex; align-items: center; gap: 5px; font-size: 12px; padding: 4px 10px; border-radius: 20px; }
        .im-status--ok { background: var(--color-success-light, #d3f9d8); color: var(--color-success); }
        .im-status--missing { background: var(--color-warning-light, #fff3cd); color: var(--color-warning); }
        .im-status--loading { color: var(--color-text-tertiary); }

        .im-input-row { display: flex; gap: 10px; align-items: center; }
        .im-input-wrap { position: relative; flex: 1; }
        .im-input {
          width: 100%; padding: 9px 38px 9px 12px; font-size: 13px;
          border: 1px solid var(--color-border); border-radius: var(--radius-sm);
          background: var(--color-bg-secondary); color: var(--color-text-primary); outline: none;
          box-sizing: border-box;
        }
        .im-input:focus { border-color: var(--color-info); }
        .im-eye-btn {
          position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
          background: none; border: none; cursor: pointer; color: var(--color-text-tertiary);
          display: flex; align-items: center; padding: 2px;
        }
        .im-eye-btn:hover { color: var(--color-text-primary); }

        .im-btn {
          display: inline-flex; align-items: center; gap: 6px;
          padding: 9px 16px; font-size: 13px; font-weight: 500;
          border-radius: var(--radius-sm); cursor: pointer; transition: all 0.15s;
          white-space: nowrap; border: none;
        }
        .im-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .im-btn--primary { background: var(--color-info); color: white; }
        .im-btn--primary:hover:not(:disabled) { opacity: 0.9; }
        .im-btn--outline {
          background: transparent; border: 1px solid var(--color-border);
          color: var(--color-text-primary);
        }
        .im-btn--outline:hover:not(:disabled) { background: var(--color-bg-secondary); }

        .im-error { font-size: 12px; color: var(--color-danger); margin-top: 8px; }
        .im-refresh-btn { background: none; border: none; cursor: pointer; color: var(--color-text-tertiary); display: flex; align-items: center; padding: 2px; border-radius: 4px; }
        .im-refresh-btn:hover { color: var(--color-text-primary); }

        /* Usage */
        .im-usage-grid { display: flex; flex-direction: column; gap: 20px; }
        .im-usage-item { padding: 14px 16px; background: var(--color-bg-secondary); border-radius: var(--radius-sm); }
        .im-usage-label { font-size: 12px; font-weight: 600; color: var(--color-text-tertiary); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.03em; }
        .im-usage-count { font-size: 22px; font-weight: 700; color: var(--color-text-primary); }
        .im-count--over { color: var(--color-danger); }
        .im-usage-count-row { display: flex; align-items: baseline; gap: 6px; margin-bottom: 8px; }
        .im-usage-slash { font-size: 14px; color: var(--color-text-tertiary); }
        .im-usage-sub { font-size: 12px; color: var(--color-text-tertiary); margin-top: 4px; }

        .im-quota-bar-bg { width: 100%; height: 6px; background: var(--color-border-light); border-radius: 3px; margin: 8px 0; overflow: hidden; }
        .im-quota-bar-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
        .im-bar--ok { background: var(--color-success); }
        .im-bar--warn { background: var(--color-warning); }
        .im-bar--danger { background: var(--color-danger); }

        /* Test */
        .im-test-source { display: flex; flex-direction: column; gap: 8px; margin-bottom: 16px; }
        .im-radio-label { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--color-text-primary); cursor: pointer; }
        .im-test-btn-row { display: flex; gap: 12px; margin-bottom: 16px; }

        .im-result {
          border-radius: var(--radius-sm); padding: 16px; margin-top: 12px;
          border: 1px solid;
        }
        .im-result--clean { border-color: var(--color-success); background: var(--color-success-light, #d3f9d8); }
        .im-result--flagged { border-color: var(--color-danger); background: #fff5f5; }
        .im-result--error { border-color: var(--color-danger); background: #fff5f5; color: var(--color-danger); font-size: 13px; display: flex; align-items: center; gap: 8px; }

        .im-result-header { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; font-size: 14px; }
        .im-badge { padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 700; }
        .im-badge--ok { background: var(--color-success); color: white; }
        .im-badge--danger { background: var(--color-danger); color: white; }

        .im-flagged-reasons { font-size: 12px; color: var(--color-danger); margin-bottom: 10px; font-weight: 500; }

        /* OpenAI scores */
        .im-score-grid { display: flex; flex-direction: column; gap: 8px; }
        .im-score-row { display: grid; grid-template-columns: 220px 1fr 48px; align-items: center; gap: 10px; }
        .im-score-label { font-size: 12px; color: var(--color-text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .im-score-label--flagged { color: var(--color-danger); font-weight: 600; }
        .im-score-bar-bg { height: 5px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
        .im-score-bar-fill { height: 100%; border-radius: 3px; transition: width 0.3s ease; }
        .im-score-pct { font-size: 11px; color: var(--color-text-tertiary); text-align: right; }

        /* Google SafeSearch */
        .im-ss-grid { display: flex; flex-direction: column; gap: 6px; }
        .im-ss-row { display: flex; justify-content: space-between; align-items: center; }
        .im-ss-cat { font-size: 13px; color: var(--color-text-secondary); text-transform: capitalize; }
        .im-ss-badge { font-size: 12px; font-weight: 600; }

        .im-quota-note { font-size: 11px; color: var(--color-text-tertiary); margin-top: 10px; text-align: right; }

        .im-state { display: flex; align-items: center; justify-content: center; padding: 32px; gap: 8px; color: var(--color-text-secondary); }

        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
