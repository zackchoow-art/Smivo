import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: 'admin/.env' });

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);

async function test() {
  const { data, error } = await supabase
    .from('listings')
    .select(`
      *,
      images:listing_images(image_url),
      seller:user_profiles!seller_id(id, display_name, email, avatar_url)
    `)
    .limit(1);
    
  if (error) {
    console.error("ERROR:", error);
  } else {
    console.log("SUCCESS:", data.length);
  }
}
test();
