/**
 * Sensitive word types for the word library management page.
 * Maps to `sensitive_words` table (migration 00049).
 */

export type SensitiveWordLang = 'en' | 'zh';
export type SensitiveWordSeverity = 'block' | 'warn';
export type SensitiveWordSource = 'manual' | 'import' | 'api';

export interface SensitiveWord {
  id: string;
  word: string;
  category: string;
  severity: SensitiveWordSeverity;
  language: SensitiveWordLang;
  source: SensitiveWordSource;
  is_active: boolean;
  created_at: string;
}
