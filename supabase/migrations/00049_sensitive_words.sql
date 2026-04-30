-- Migration 00049: Sensitive words table for content moderation
-- Words are downloaded to Flutter client, cached locally, and checked before submission.
-- Admin backend will bulk-import words from third-party providers (Sightengine, etc.)

CREATE TABLE IF NOT EXISTS public.sensitive_words (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    -- Core field: the actual word or phrase to match
    word text NOT NULL,
    -- Category for admin organization (e.g. weapons, drugs, adult, hate, fraud)
    category text NOT NULL DEFAULT 'general',
    -- Severity: 'block' = prevent submission, 'warn' = show warning only
    severity text NOT NULL DEFAULT 'block' CHECK (severity IN ('block', 'warn')),
    -- Language code (ISO 639-1), supports multi-language expansion
    language text NOT NULL DEFAULT 'en',
    -- Source tracking: 'manual' = admin added, 'import' = bulk imported, 'api' = from third-party API
    source text NOT NULL DEFAULT 'manual',
    -- Soft switch to disable without deleting
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    -- UNIQUE constraint on word+language to prevent duplicates across imports
    CONSTRAINT unique_word_per_language UNIQUE (word, language)
);

-- Index for efficient client-side download query
CREATE INDEX IF NOT EXISTS idx_sensitive_words_active
    ON public.sensitive_words (is_active, severity, language);

-- RLS: All authenticated users can read active words (needed for client-side filter)
ALTER TABLE public.sensitive_words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read active words"
    ON public.sensitive_words FOR SELECT
    TO authenticated
    USING (is_active = true);

-- NOTE: INSERT/UPDATE/DELETE policies will be added when React Admin is implemented.
-- Admin will use service_role key to bypass RLS for word management.
