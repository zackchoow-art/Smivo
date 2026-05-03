import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: 'admin/.env' });
const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);
async function test() {
  const { data, error } = await supabase.from('user_bans').insert({
    user_id: 'e4cc0f3a-bf31-4122-bc54-d83125e1fc5a', // Random valid uuid or we will get a FK error
    college_id: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', // valid uuid
    ban_type: 'temporary',
    scope: 'listing_ban',
    reason_code: 'violation_policy',
    duration_days: 0.000694444,
    banned_by: 'e4cc0f3a-bf31-4122-bc54-d83125e1fc5a',
    banned_at: new Date().toISOString()
  });
  console.log("Error:", error);
}
test();
