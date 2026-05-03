const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: 'admin/.env' });
const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);
async function test() {
  const { data } = await supabase.from('user_profiles').select('*, school:schools(name)').limit(1).single();
  console.log(data);
}
test();
