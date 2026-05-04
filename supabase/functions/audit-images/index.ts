/**
 * Edge Function: audit-images
 *
 * Dedicated function for image-only moderation that DOES NOT 
 * change the target record's status. It only updates the 
 * moderation_status and reasons of individual images.
 *
 * Used primarily for manual admin actions (like Takedown) where
 * the listing status is already set manually, but we want AI 
 * to provide precise blurring for violating images.
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.44.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ModerationResult {
  imageDetails: Array<{
    index: number;
    url: string;
    flagged: boolean;
    reasons: string[];
    scores?: Record<string, number>;
  }>;
  imageFlagged: boolean;
}

/**
 * Run OpenAI moderation on images.
 */
async function moderateWithOpenAI(
  supabase: any,
  imageUrls: string[],
): Promise<ModerationResult> {
  const { data: keyData } = await supabase.rpc(
    'get_platform_secret_decrypted',
    { p_key: 'openai_api_key' }
  );
  if (!keyData) {
    throw new Error('OpenAI API key not configured');
  }
  const openAiKey = keyData as string;

  const imageDetails: ModerationResult['imageDetails'] = [];
  let imageFlagged = false;

  if (imageUrls.length > 0) {
    const imageResults = await Promise.all(
      imageUrls.map(async (url, index) => {
        try {
          const resp = await fetch('https://api.openai.com/v1/moderations', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${openAiKey}`,
            },
            body: JSON.stringify({
              model: 'omni-moderation-latest',
              input: [{ type: 'image_url', image_url: { url } }],
            }),
          });

          if (!resp.ok) return { index, url, flagged: false, reasons: [] as string[] };

          const data = await resp.json();
          const res = data.results?.[0];
          if (!res) return { index, url, flagged: false, reasons: [] as string[] };

          const reasons: string[] = [];
          for (const [cat, flagged] of Object.entries(res.categories || {})) {
            if (flagged) reasons.push(cat);
          }

          return {
            index,
            url,
            flagged: res.flagged,
            reasons,
          };
        } catch (err) {
          console.error(`AI Audit error for image ${index}:`, err);
          return { index, url, flagged: false, reasons: [] as string[] };
        }
      })
    );

    for (const r of imageResults) {
      imageDetails.push(r);
      if (r.flagged) imageFlagged = true;
    }

    // Usage tracking
    await supabase.rpc('increment_image_moderation_usage', {
      p_provider: 'openai',
      p_amount: imageUrls.length,
    });
  }

  return { imageDetails, imageFlagged };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { listing_id } = await req.json();
    if (!listing_id) throw new Error('listing_id is required');

    // 1. Fetch listing images
    const { data: images, error: imgError } = await supabase
      .from('listing_images')
      .select('image_url')
      .eq('listing_id', listing_id);

    if (imgError || !images) throw new Error('Listing images not found');
    const imageUrls = images.map(img => img.image_url);

    if (imageUrls.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No images to audit' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 2. Run Moderation
    const result = await moderateWithOpenAI(supabase, imageUrls);

    // 3. Update Images Table (Blur violating ones)
    // IMPORTANT: We do NOT update listings table status here.
    const flaggedImages = result.imageDetails.filter(i => i.flagged);
    
    for (const img of result.imageDetails) {
      // If it's flagged by AI, we set it to 'rejected' to trigger blur
      // If it's NOT flagged by AI, we leave it as is (it might have been manually rejected)
      if (img.flagged) {
        await supabase
          .from('listing_images')
          .update({
            moderation_status: 'rejected',
            moderation_reasons: img.reasons.join(', ') || 'AI Audit Violation',
          })
          .eq('listing_id', listing_id)
          .eq('image_url', img.url);
      }
    }

    // 4. Log the audit
    await supabase.from('backend_moderation_logs').insert({
      target_type: 'listing',
      target_id: listing_id,
      user_id: (await supabase.from('listings').select('seller_id').eq('id', listing_id).single()).data?.seller_id,
      engine: 'openai',
      review_mode: 'ai',
      result: result.imageFlagged ? 'fail' : 'pass',
      action_taken: 'audit_only',
      image_details: result.imageDetails,
      content_snapshot: `Audit-only scan for listing ${listing_id}`,
    });

    return new Response(JSON.stringify({
      success: true,
      flagged: result.imageFlagged,
      image_details: result.imageDetails
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    console.error('[audit-images] Error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
