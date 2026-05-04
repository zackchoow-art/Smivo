/**
 * Edge Function: moderate-image-openai
 *
 * Calls OpenAI omni-moderation-latest model to analyze images for:
 *   - sexual, violence, harassment, hate, self-harm content
 *
 * Image input: public URL (Supabase listing-images bucket is public read)
 * Ref: https://platform.openai.com/docs/api-reference/moderations
 *
 * Request body:
 *   { image_url: string }          — single image URL to moderate
 *   OR { test: true }              — use a built-in test image
 *
 * Response:
 *   { flagged, categories, category_scores, usage_count }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.44.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// A safe, stable placeholder image for test runs.
// picsum.photos serves a small fixed image with high reliability.
// NOTE: When testing Supabase-hosted images, the admin UI uploads a real
// file to the listing-images bucket and passes the URL instead of test:true.
const TEST_IMAGE_URL = 'https://picsum.photos/seed/smivo-test/400/300';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl  = Deno.env.get('SUPABASE_URL')!;
    const serviceKey   = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase     = createClient(supabaseUrl, serviceKey);

    // 1. Retrieve the API key from encrypted storage
    const { data: keyData, error: keyError } = await supabase.rpc(
      'get_platform_secret_decrypted',
      { p_key: 'openai_api_key' }
    );
    if (keyError || !keyData) {
      return new Response(JSON.stringify({
        error: 'OpenAI API key not configured. Please set it in Image Moderation Settings.'
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 });
    }
    const openAiKey = keyData as string;

    const body = await req.json();
    const isTest = body.test === true;
    
    // Support legacy `image_url` and new `text`, `image_urls` array
    const text: string | undefined = body.text;
    let imageUrls: string[] = [];
    
    if (isTest) {
      imageUrls = [TEST_IMAGE_URL];
    } else if (body.image_urls && Array.isArray(body.image_urls)) {
      imageUrls = body.image_urls;
    } else if (body.image_url) {
      imageUrls = [body.image_url];
    }

    if (!text && imageUrls.length === 0) {
      return new Response(JSON.stringify({ error: 'Either text or image_urls must be provided' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400,
      });
    }

    // Prepare OpenAI input payloads (Max 1 image per request)
    const payloads: any[][] = [];
    if (imageUrls.length === 0 && text) {
      payloads.push([{ type: 'text', text }]);
    } else {
      for (const url of imageUrls) {
        const payload = [];
        if (text) payload.push({ type: 'text', text });
        payload.push({ type: 'image_url', image_url: { url } });
        payloads.push(payload);
      }
    }

    // 2. Call OpenAI omni-moderation-latest
    const results = await Promise.all(payloads.map(async (inputPayload) => {
      const openAiResponse = await fetch('https://api.openai.com/v1/moderations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${openAiKey}`,
        },
        body: JSON.stringify({
          model: 'omni-moderation-latest',
          input: inputPayload,
        }),
      });

      if (!openAiResponse.ok) {
        const errText = await openAiResponse.text();
        throw new Error(`OpenAI API error ${openAiResponse.status}: ${errText}`);
      }

      const modData = await openAiResponse.json();
      const res = modData.results?.[0];
      if (!res) throw new Error('Unexpected response format from OpenAI Moderation API');
      return res;
    }));

    let anyFlagged = false;
    const mergedCategories: Record<string, boolean> = {};
    const maxCategoryScores: Record<string, number> = {};

    for (const res of results) {
      if (res.flagged) anyFlagged = true;
      for (const [cat, flagged] of Object.entries(res.categories || {})) {
        if (flagged) mergedCategories[cat] = true;
        if (mergedCategories[cat] === undefined) mergedCategories[cat] = false;
      }
      for (const [cat, score] of Object.entries(res.category_scores || {})) {
        maxCategoryScores[cat] = Math.max(maxCategoryScores[cat] || 0, score as number);
      }
    }

    // 3. Increment monthly usage counter
    const processedCount = payloads.length;
    await supabase.rpc('increment_image_moderation_usage', { p_provider: 'openai', p_amount: processedCount });

    // 4. Return structured result
    return new Response(JSON.stringify({
      provider:         'openai',
      model:            'omni-moderation-latest',
      image_url:        imageUrls.length > 1 ? `${imageUrls.length} images` : (imageUrls[0] || 'text only'),
      flagged:          anyFlagged,
      categories:       mergedCategories,
      category_scores:  maxCategoryScores,
      is_test:          isTest,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    console.error('[moderate-image-openai]', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
