import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env' });
const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);
async function run() {
  const { data, error } = await supabase
    .from('content_reports')
    .select(`*, reporter:user_profiles!reporter_id(display_name, email, avatar_url), reported:user_profiles!reported_user_id(display_name, email, avatar_url)`)
    .eq('target_type', 'listing')
    .eq('status', 'pending')
    .order('created_at', { ascending: true });
  console.log('Error:', error);
  //console.log('Data:', data);
}
run();
