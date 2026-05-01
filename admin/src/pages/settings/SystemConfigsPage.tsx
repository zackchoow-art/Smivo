import { Loader2, ShieldAlert } from 'lucide-react';
import { useSystemConfigs, useUpdateSystemConfig, type SystemConfig } from '@/hooks/useSystemConfigs';
import { useAuth } from '@/hooks/useAuth';

export function SystemConfigsPage() {
  const { admin } = useAuth();
  const { data: configs, isLoading, error } = useSystemConfigs();
  const updateConfig = useUpdateSystemConfig();

  const handleToggle = async (config: SystemConfig) => {
    if (!admin) return;
    const isCurrentlyEnabled = config.config_value === 'true' || config.config_value === true;
    const newValue = !isCurrentlyEnabled;
    
    // Store as JSON string or boolean depending on how it was originally saved
    // We'll use string 'true'/'false' for simplicity as seeded in migration
    await updateConfig.mutateAsync({
      key: config.config_key,
      value: String(newValue),
      adminId: admin.user_id,
    });
  };

  const handleChangeSelect = async (config: SystemConfig, newValue: string) => {
    if (!admin) return;
    await updateConfig.mutateAsync({
      key: config.config_key,
      value: `"${newValue}"`, // We stored string values as JSON strings (e.g. '"openai"') in migration
      adminId: admin.user_id,
    });
  };

  if (isLoading) {
    return (
      <div className="sc-state">
        <Loader2 size={24} className="spin" />
        <span>Loading configurations...</span>
      </div>
    );
  }

  if (error || !configs) {
    return <div className="sc-state sc-error">Failed to load configs.</div>;
  }

  const aiModerationEnabled = configs.find(c => c.config_key === 'ai_moderation_enabled');
  const aiProvider = configs.find(c => c.config_key === 'ai_provider');
  const aiAction = configs.find(c => c.config_key === 'ai_action_on_hit');

  return (
    <div className="sc-page">
      <div className="sc-header">
        <h1 className="sc-title">System Configurations</h1>
        <p className="sc-subtitle">Manage global AI settings and moderation rules</p>
      </div>

      <div className="sc-section">
        <div className="sc-section-header">
          <ShieldAlert size={20} color="var(--color-warning)" />
          <h2>AI Content Moderation</h2>
        </div>
        
        <div className="sc-card-list">
          {aiModerationEnabled && (
            <div className="sc-card">
              <div className="sc-card-info">
                <h3>Secondary AI Review</h3>
                <p>{aiModerationEnabled.description}</p>
              </div>
              <div className="sc-card-action">
                <label className="sc-toggle">
                  <input 
                    type="checkbox" 
                    checked={aiModerationEnabled.config_value === 'true' || aiModerationEnabled.config_value === true}
                    onChange={() => handleToggle(aiModerationEnabled)}
                    disabled={updateConfig.isPending}
                  />
                  <span className="sc-slider"></span>
                </label>
              </div>
            </div>
          )}

          {aiProvider && (
            <div className="sc-card">
              <div className="sc-card-info">
                <h3>AI Provider</h3>
                <p>{aiProvider.description}</p>
              </div>
              <div className="sc-card-action">
                <select 
                  value={(aiProvider.config_value || '').replace(/"/g, '')}
                  onChange={(e) => handleChangeSelect(aiProvider, e.target.value)}
                  disabled={updateConfig.isPending}
                  className="sc-select"
                >
                  <option value="openai">OpenAI (GPT-4o Vision)</option>
                  <option value="google">Google (Gemini Pro Vision)</option>
                </select>
              </div>
            </div>
          )}

          {aiAction && (
            <div className="sc-card">
              <div className="sc-card-info">
                <h3>Action on Violation</h3>
                <p>{aiAction.description}</p>
              </div>
              <div className="sc-card-action">
                <select 
                  value={(aiAction.config_value || '').replace(/"/g, '')}
                  onChange={(e) => handleChangeSelect(aiAction, e.target.value)}
                  disabled={updateConfig.isPending}
                  className="sc-select"
                >
                  <option value="flag">Flag for Manual Review</option>
                  <option value="reject">Auto-Reject (Remove immediately)</option>
                </select>
              </div>
            </div>
          )}
        </div>
      </div>

      <style>{`
        .sc-page { padding: var(--spacing-page); max-width: 800px; }
        .sc-header { margin-bottom: 32px; }
        .sc-title { font-size: 24px; font-weight: 700; color: var(--color-text-primary); margin: 0; }
        .sc-subtitle { font-size: 14px; color: var(--color-text-secondary); margin-top: 4px; }
        
        .sc-section { margin-bottom: 32px; }
        .sc-section-header { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
        .sc-section-header h2 { font-size: 18px; font-weight: 600; color: var(--color-text-primary); margin: 0; }
        
        .sc-card-list { display: flex; flex-direction: column; gap: 1px; background: var(--color-border-light); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); overflow: hidden; }
        .sc-card { display: flex; justify-content: space-between; align-items: center; padding: 20px; background: var(--color-bg-primary); }
        
        .sc-card-info h3 { font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 4px; }
        .sc-card-info p { font-size: 13px; color: var(--color-text-secondary); margin: 0; }
        
        .sc-select { padding: 8px 12px; font-size: 13px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); background: var(--color-bg-secondary); color: var(--color-text-primary); cursor: pointer; outline: none; }
        .sc-select:focus { border-color: var(--color-info); }
        .sc-select:disabled { opacity: 0.5; cursor: not-allowed; }
        
        /* Toggle Switch CSS */
        .sc-toggle { position: relative; display: inline-block; width: 44px; height: 24px; }
        .sc-toggle input { opacity: 0; width: 0; height: 0; }
        .sc-slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: var(--color-border); transition: .2s; border-radius: 24px; }
        .sc-slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; transition: .2s; border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        input:checked + .sc-slider { background-color: var(--color-success); }
        input:disabled + .sc-slider { opacity: 0.5; cursor: not-allowed; }
        input:checked + .sc-slider:before { transform: translateX(20px); }

        .sc-state { display: flex; align-items: center; justify-content: center; padding: 48px; gap: 8px; color: var(--color-text-secondary); }
        .sc-error { color: var(--color-danger); }
        .spin { animation: spin 1s linear infinite; }
        @keyframes spin { 100% { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
