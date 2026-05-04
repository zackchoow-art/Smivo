/**
 * Edge Function: moderate-image-google
 *
 * Calls Google Cloud Vision API SafeSearch Detection to analyze images for:
 *   - adult, spoof, medical, violence, racy content
 *
 * Likelihood levels: UNKNOWN, VERY_UNLIKELY, UNLIKELY, POSSIBLE, LIKELY, VERY_LIKELY
 * "Flagged" threshold in this function: LIKELY or VERY_LIKELY for adult/violence.
 *
 * Image input: public URL (Supabase listing-images bucket is public read)
 * NOTE: Google recommends gs:// URIs for production reliability.
 * For now we use HTTP URL which works for public buckets.
 *
 * Free tier: 1000 requests/month — enforced via image_moderation_usage counter.
 *
 * Request body:
 *   { image_url: string }    — single image URL to moderate
 *   OR { test: true }        — use a built-in test image
 *
 * Response:
 *   { flagged, safeSearch, reasons, usage_count, quota_remaining }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.44.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const GOOGLE_FREE_TIER_LIMIT = 1000;

// Likelihood levels ordered by severity (index = severity)
const LIKELIHOOD_LEVELS = [
  'UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY',
];

// NOTE: Flag if any category reaches LIKELY or above
const FLAG_THRESHOLD = 4; // index of 'LIKELY'

function isLikelyOrAbove(likelihood: string): boolean {
  return LIKELIHOOD_LEVELS.indexOf(likelihood) >= FLAG_THRESHOLD;
}

const TEST_IMAGE_URL = 'https://picsum.photos/seed/smivo-test/400/300';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey  = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase    = createClient(supabaseUrl, serviceKey);

    // 1. Check current month's usage against free tier limit
    const { data: usageData } = await supabase.rpc('get_image_moderation_usage');
    const googleCount: number = usageData?.google_vision?.count ?? 0;
    const quotaRemaining = Math.max(0, GOOGLE_FREE_TIER_LIMIT - googleCount);

    if (googleCount >= GOOGLE_FREE_TIER_LIMIT) {
      return new Response(JSON.stringify({
        error: `Google Vision monthly quota exhausted (${GOOGLE_FREE_TIER_LIMIT} requests/month). Resets on the 1st of next month.`,
        quota_remaining: 0,
        usage_count: googleCount,
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 429 });
    }

    // 2. Retrieve the API key from encrypted storage
    const { data: keyData, error: keyError } = await supabase.rpc(
      'get_platform_secret_decrypted',
      { p_key: 'google_vision_api_key' }
    );
    if (keyError || !keyData) {
      return new Response(JSON.stringify({
        error: 'Google Vision API key not configured. Please set it in Image Moderation Settings.'
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 });
    }
    const googleApiKey = keyData as string;

    const body = await req.json();
    const isTest = body.test === true;
    
    // Support legacy `image_url` and new `image_urls` array
    let imageUrls: string[] = [];
    if (isTest) {
      imageUrls = [TEST_IMAGE_URL];
    } else if (body.image_urls && Array.isArray(body.image_urls)) {
      imageUrls = body.image_urls;
    } else if (body.image_url) {
      imageUrls = [body.image_url];
    }

    if (imageUrls.length === 0) {
      // Note: Google Vision SafeSearch doesn't natively do text moderation, so we require at least one image
      return new Response(JSON.stringify({ error: 'image_urls is required for Google Vision' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400,
      });
    }

    // 3. Call Google Cloud Vision SafeSearch Detection
    // NOTE: We use imageUri (HTTP URL) since our Supabase bucket is public.
    // For higher reliability in production, consider downloading the image
    // and sending as base64 content instead.
    const visionResponse = await fetch(
      `https://vision.googleapis.com/v1/images:annotate?key=${googleApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          requests: imageUrls.map(url => ({
            image: { source: { imageUri: url } },
            features: [{ type: 'SAFE_SEARCH_DETECTION', maxResults: 1 }],
          })),
        }),
      }
    );

    if (!visionResponse.ok) {
      const errText = await visionResponse.text();
      throw new Error(`Google Vision API error ${visionResponse.status}: ${errText}`);
    }

    const visionData = await visionResponse.json();
    let anyFlagged = false;
    const allReasons = new Set<string>();
    let lastSafeSearch: any = null;

    for (const res of visionData.responses || []) {
      const annotation = res.safeSearchAnnotation;
      if (!annotation) continue;

      lastSafeSearch = {
        adult:    annotation.adult    ?? 'UNKNOWN',
        spoof:    annotation.spoof    ?? 'UNKNOWN',
        medical:  annotation.medical  ?? 'UNKNOWN',
        violence: annotation.violence ?? 'UNKNOWN',
        racy:     annotation.racy     ?? 'UNKNOWN',
      };

      if (isLikelyOrAbove(lastSafeSearch.adult))    { anyFlagged = true; allReasons.add('adult'); }
      if (isLikelyOrAbove(lastSafeSearch.violence)) { anyFlagged = true; allReasons.add('violence'); }
      if (isLikelyOrAbove(lastSafeSearch.racy))     { anyFlagged = true; allReasons.add('racy'); }
    }

    if (!lastSafeSearch) {
       // Check for API-level errors in the response body
       const apiError = visionData?.responses?.[0]?.error;
       if (apiError) throw new Error(`Google Vision: ${apiError.message}`);
       throw new Error('No SafeSearch annotation returned from Google Vision API');
    }
    // NOTE: 'spoof' and 'medical' are informational, not flagged by default

    // 5. Increment monthly usage counter
    const processedCount = imageUrls.length;
    await supabase.rpc('increment_image_moderation_usage', { p_provider: 'google_vision', p_amount: processedCount });

    return new Response(JSON.stringify({
      provider:        'google_vision',
      model:           'cloud-vision-safe-search',
      image_url:       imageUrls.length > 1 ? `${imageUrls.length} images` : imageUrls[0],
      flagged:         anyFlagged,
      reasons:         Array.from(allReasons),
      safe_search:     lastSafeSearch,
      usage_count:     googleCount + processedCount,
      quota_remaining: quotaRemaining - processedCount,
      monthly_limit:   GOOGLE_FREE_TIER_LIMIT,
      is_test:         isTest,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    console.error('[moderate-image-google]', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
