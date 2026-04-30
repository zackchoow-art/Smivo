import { createClient } from '@supabase/supabase-js';

// NOTE: Anon key is safe to expose in client-side code — RLS enforces access control.
// Service Role Key is NEVER used here — it lives only in Edge Functions.
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY environment variables. ' +
    'Copy admin/.env.example to admin/.env and fill in the values.'
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
