const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env' });

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);

async function test() {
  const { data, error, count } = await supabase
    .from('listings')
    .select(`
      *,
      images:listing_images(image_url),
      seller:user_profiles!seller_id(id, display_name, email, avatar_url)
    `, { count: 'exact' })
    .limit(1);
    
  if (error) {
    console.error("ERROR:", error);
  } else {
    console.log("SUCCESS, COUNT:", count);
  }
}
test();
