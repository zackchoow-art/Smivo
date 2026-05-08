/**
 * Edge Function: moderate-content
 *
 * Triggered by Database Webhook on moderation_tasks INSERT.
 * Performs automated content review using the configured engine
 * (OpenAI / Google Vision / sensitive words) and records detailed
 * results in backend_moderation_logs.
 *
 * Flow:
 *   1. Read task from moderation_tasks
 *   2. Fetch target content (listing/message/profile)
 *   3. Read platform config (engine, action, mode)
 *   4. Run text + image moderation
 *   5. Write detailed log to backend_moderation_logs
 *   6. Execute configured action (approve/reject/flag/blur)
 *   7. Mark task as done
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.44.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// ── Helpers ──────────────────────────────────────────────────

interface ModerationResult {
  textFlagged: boolean;
  textDetails: Record<string, any>;
  imageFlagged: boolean;
  imageDetails: Array<{
    index: number;
    url: string;
    flagged: boolean;
    reasons: string[];
    scores?: Record<string, number>;
  }>;
  overallFlagged: boolean;
}

/**
 * Run OpenAI text + image moderation on provided content.
 * Sends one request per image (API limit: 1 image per request).
 */
async function moderateWithOpenAI(
  supabase: any,
  text: string,
  imageUrls: string[],
): Promise<ModerationResult> {
  // Retrieve the API key from encrypted storage
  const { data: keyData } = await supabase.rpc(
    'get_platform_secret_decrypted',
    { p_key: 'openai_api_key' }
  );
  if (!keyData) {
    console.warn('OpenAI API key not configured — skipping AI moderation');
    return { textFlagged: false, textDetails: {}, imageFlagged: false, imageDetails: [], overallFlagged: false };
  }
  const openAiKey = keyData as string;

  let textFlagged = false;
  let textDetails: Record<string, any> = {};

  // Text moderation (if content exists)
  if (text.trim()) {
    const textResp = await fetch('https://api.openai.com/v1/moderations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({ model: 'omni-moderation-latest', input: [{ type: 'text', text }] }),
    });

    if (textResp.ok) {
      const textData = await textResp.json();
      const res = textData.results?.[0];
      if (res) {
        textFlagged = res.flagged;
        textDetails = {
          flagged: res.flagged,
          categories: res.categories,
          category_scores: res.category_scores,
        };
      }
    }
  }

  // Image moderation (one request per image)
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

          if (!resp.ok) {
            console.error(`OpenAI image ${index} error: ${resp.status}`);
            return { index, url, flagged: false, reasons: [] as string[], scores: {} };
          }

          const data = await resp.json();
          const res = data.results?.[0];
          if (!res) return { index, url, flagged: false, reasons: [] as string[], scores: {} };

          // Collect flagged categories
          const reasons: string[] = [];
          for (const [cat, flagged] of Object.entries(res.categories || {})) {
            if (flagged) reasons.push(cat);
          }

          return {
            index,
            url,
            flagged: res.flagged,
            reasons,
            scores: res.category_scores || {},
          };
        } catch (err) {
          console.error(`OpenAI image ${index} exception:`, err);
          return { index, url, flagged: false, reasons: [] as string[], scores: {} };
        }
      })
    );

    for (const r of imageResults) {
      imageDetails.push(r);
      if (r.flagged) imageFlagged = true;
    }

    // Increment monthly usage counter
    await supabase.rpc('increment_image_moderation_usage', {
      p_provider: 'openai',
      p_amount: imageUrls.length,
    });
  }

  return {
    textFlagged,
    textDetails,
    imageFlagged,
    imageDetails,
    overallFlagged: textFlagged || imageFlagged,
  };
}

/**
 * Run Google Vision SafeSearch on images.
 * NOTE: Google Vision doesn't do text moderation.
 */
async function moderateWithGoogle(
  supabase: any,
  imageUrls: string[],
): Promise<{ imageFlagged: boolean; imageDetails: ModerationResult['imageDetails'] }> {
  if (imageUrls.length === 0) {
    return { imageFlagged: false, imageDetails: [] };
  }

  const { data: keyData } = await supabase.rpc(
    'get_platform_secret_decrypted',
    { p_key: 'google_vision_api_key' }
  );
  if (!keyData) {
    console.warn('Google Vision API key not configured — skipping');
    return { imageFlagged: false, imageDetails: [] };
  }
  const googleApiKey = keyData as string;

  const LIKELIHOOD_LEVELS = ['UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY'];
  const FLAG_THRESHOLD = 4; // LIKELY

  const visionResp = await fetch(
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

  if (!visionResp.ok) {
    const errText = await visionResp.text();
    console.error('Google Vision error:', errText);
    return { imageFlagged: false, imageDetails: [] };
  }

  const visionData = await visionResp.json();
  const imageDetails: ModerationResult['imageDetails'] = [];
  let imageFlagged = false;

  for (let i = 0; i < (visionData.responses || []).length; i++) {
    const annotation = visionData.responses[i]?.safeSearchAnnotation;
    if (!annotation) {
      imageDetails.push({ index: i, url: imageUrls[i], flagged: false, reasons: [] });
      continue;
    }

    const reasons: string[] = [];
    const scores: Record<string, number> = {};

    for (const cat of ['adult', 'violence', 'racy'] as const) {
      const level = annotation[cat] || 'UNKNOWN';
      scores[cat] = LIKELIHOOD_LEVELS.indexOf(level);
      if (LIKELIHOOD_LEVELS.indexOf(level) >= FLAG_THRESHOLD) {
        reasons.push(cat);
      }
    }

    const flagged = reasons.length > 0;
    if (flagged) imageFlagged = true;

    imageDetails.push({
      index: i,
      url: imageUrls[i],
      flagged,
      reasons,
      scores,
    });
  }

  // Increment monthly usage counter
  await supabase.rpc('increment_image_moderation_usage', {
    p_provider: 'google_vision',
    p_amount: imageUrls.length,
  });

  return { imageFlagged, imageDetails };
}

/**
 * Run sensitive word matching against text content.
 */
async function moderateWithSensitiveWords(
  supabase: any,
  text: string,
): Promise<{ flagged: boolean; matchedWords: string[] }> {
  const { data: words, error } = await supabase
    .from('sensitive_words')
    .select('word, severity')
    .eq('is_active', true)
    .eq('severity', 'block');

  if (error || !words) return { flagged: false, matchedWords: [] };

  const lower = text.toLowerCase();
  const matchedWords = words
    .filter((w: any) => lower.includes(w.word.toLowerCase()))
    .map((w: any) => w.word);

  return { flagged: matchedWords.length > 0, matchedWords };
}

/**
 * Generate a blurred version of an image with violation type watermark.
 * Uses Supabase Storage to replace the original image.
 *
 * NOTE: Deno Edge Functions don't have Canvas/Sharp. Instead we use
 * Supabase Storage Image Transformations to serve a blurred version,
 * and store the violation metadata for the client to render the overlay.
 * The client will read `backend_moderation_logs.image_details` and
 * display the blur + text overlay locally.
 */


// ── Main Handler ─────────────────────────────────────────────

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const payload = await req.json();

    // Support both Webhook format (record) and direct invocation (task_id)
    let taskId: string;
    let targetType: string;
    let targetId: string;

    if (payload.record) {
      // Database Webhook format
      taskId = payload.record.id;
      targetType = payload.record.target_type;
      targetId = payload.record.target_id;
    } else if (payload.task_id) {
      // Direct invocation
      taskId = payload.task_id;
      const { data: task } = await supabase
        .from('moderation_tasks')
        .select('*')
        .eq('id', payload.task_id)
        .single();
      if (!task) throw new Error(`Task not found: ${payload.task_id}`);
      targetType = task.target_type;
      targetId = task.target_id;
    } else {
      return new Response(JSON.stringify({ message: 'No task data provided' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // Mark task as processing
    await supabase
      .from('moderation_tasks')
      .update({ status: 'processing' })
      .eq('id', taskId);

    // ── 1. Fetch target content ──────────────────────────────

    let textToCheck = '';
    let imageUrls: string[] = [];
    let userId = '';
    let contentSnapshot = '';

    if (targetType === 'listing') {
      const { data: listing } = await supabase
        .from('listings')
        .select('id, title, description, seller_id, listing_images(image_url)')
        .eq('id', targetId)
        .single();

      if (!listing) throw new Error(`Listing not found: ${targetId}`);

      textToCheck = `${listing.title}\n${listing.description || ''}`;
      imageUrls = (listing.listing_images || []).map((img: any) => img.image_url);
      userId = listing.seller_id;
      contentSnapshot = `${listing.title}\n---\n${listing.description || ''}`;
    } else if (targetType === 'message') {
      const { data: message } = await supabase
        .from('messages')
        .select('id, content, sender_id, message_type, image_url')
        .eq('id', targetId)
        .single();

      if (!message) throw new Error(`Message not found: ${targetId}`);

      // For image messages, the actual URL is stored in image_url column,
      // NOT in content (which is just a '[Image]' placeholder).
      if (message.message_type === 'image' && message.image_url) {
        imageUrls = [message.image_url];
      }
      textToCheck = message.message_type === 'text' ? (message.content || '') : '';
      userId = message.sender_id;
      contentSnapshot = message.image_url || message.content || '';
    } else if (targetType === 'profile') {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id, display_name, bio, avatar_url')
        .eq('id', targetId)
        .single();

      if (!profile) throw new Error(`Profile not found: ${targetId}`);

      textToCheck = `${profile.display_name || ''}\n${profile.bio || ''}`;
      if (profile.avatar_url) imageUrls = [profile.avatar_url];
      userId = profile.id;
      contentSnapshot = `Name: ${profile.display_name}\nBio: ${profile.bio || ''}`;
    }

    // ── 2. Read platform config ──────────────────────────────

    const { data: configs } = await supabase
      .from('system_configs')
      .select('config_key, config_value');

    const getConfig = (key: string): string => {
      const c = configs?.find((x: any) => x.config_key === key);
      if (!c) return '';
      // Strip JSON quotes if present
      return String(c.config_value).replace(/^"|"$/g, '');
    };

    const reviewMode = getConfig('backend_review.mode') || 'sensitive_words';
    const aiProvider = getConfig('ai_provider') || 'openai';
    const actionOnHit = getConfig('ai_action_on_hit') || 'flag';
    const aiImageEnabled = getConfig('ai_moderation_enabled');

    // ── 3. Run moderation ────────────────────────────────────

    let wordMatches: string[] = [];
    let textFlagged = false;
    let imageFlagged = false;
    let textDetails: Record<string, any> = {};
    let imageDetails: ModerationResult['imageDetails'] = [];
    let engineUsed = 'sensitive_words';

    // 3a. Sensitive words check
    if (reviewMode === 'sensitive_words' || reviewMode === 'both') {
      const wordResult = await moderateWithSensitiveWords(supabase, textToCheck);
      if (wordResult.flagged) {
        textFlagged = true;
        wordMatches = wordResult.matchedWords;
        textDetails = { matched_words: wordResult.matchedWords };
      }
    }

    // 3b. AI moderation (text + images)
    if (reviewMode === 'ai' || reviewMode === 'both') {
      // Determine which images to send to AI
      const imagesToModerate = (aiImageEnabled === 'true') ? imageUrls : [];

      if (aiProvider === 'google') {
        engineUsed = 'google_vision';
        // Google Vision: images only
        if (imagesToModerate.length > 0) {
          const googleResult = await moderateWithGoogle(supabase, imagesToModerate);
          imageFlagged = googleResult.imageFlagged;
          imageDetails = googleResult.imageDetails;
        }
        // For text with Google, fall back to OpenAI text-only if available
        // Or rely on sensitive words for text
      } else {
        engineUsed = 'openai';
        const openaiResult = await moderateWithOpenAI(supabase, textToCheck, imagesToModerate);
        if (openaiResult.textFlagged) textFlagged = true;
        if (openaiResult.imageFlagged) imageFlagged = true;
        textDetails = { ...textDetails, ai_text: openaiResult.textDetails };
        imageDetails = openaiResult.imageDetails;
      }
    }

    const overallFlagged = textFlagged || imageFlagged;

    // ── 4. Determine action ──────────────────────────────────

    let actionTaken = 'approve';

    if (overallFlagged) {
      if (actionOnHit === 'reject') {
        actionTaken = 'reject';
      } else {
        // Default: flag for manual review
        actionTaken = 'flag';
      }

      // Special case: image-only violation on messages/profiles → blur
      if (imageFlagged && !textFlagged && (targetType === 'message' || targetType === 'profile')) {
        actionTaken = 'blur';
      }
    }

    // ── 5. Write detailed log ────────────────────────────────

    await supabase.from('backend_moderation_logs').insert({
      target_type: targetType,
      target_id: targetId,
      user_id: userId,
      engine: engineUsed,
      review_mode: reviewMode,
      result: overallFlagged ? 'fail' : 'pass',
      action_taken: actionTaken,
      text_details: {
        ...textDetails,
        matched_words: wordMatches,
      },
      image_details: imageDetails,
      content_snapshot: contentSnapshot.substring(0, 2000),
    });

    // ── 6. Execute action ────────────────────────────────────

    let allReasons = [...wordMatches];
    if (textDetails?.ai_text?.categories) {
      for (const [cat, flagged] of Object.entries(textDetails.ai_text.categories)) {
        if (flagged) allReasons.push(cat);
      }
    }
    const imageReasons = imageDetails.filter(i => i.flagged).flatMap(i => i.reasons);
    allReasons.push(...imageReasons);
    // Remove duplicates
    allReasons = [...new Set(allReasons)];
    
    const violationTypesString = allReasons.length > 0 ? allReasons.join(', ') : 'Policy Violation';

    // Update individual flagged images in the listing_images table
    if (targetType === 'listing' && imageDetails.length > 0) {
      const flaggedImages = imageDetails.filter(i => i.flagged);
      for (const img of flaggedImages) {
        const imageStatus = actionTaken === 'reject' ? 'rejected' : 'pending_review';
        await supabase
          .from('listing_images')
          .update({
            moderation_status: imageStatus,
            moderation_reasons: img.reasons.join(', ') || 'Policy Violation',
          })
          .eq('listing_id', targetId)
          .eq('image_url', img.url);
      }
    }

    if (overallFlagged && targetType === 'listing') {
      if (actionTaken === 'reject') {
        await supabase
          .from('listings')
          .update({
            moderation_status: 'rejected',
            moderation_trigger: `AI: ${violationTypesString}`,
            moderation_note: violationTypesString,
          })
          .eq('id', targetId);

        // Notify seller
        await supabase.from('notifications').insert({
          user_id: userId,
          type: 'system',
          title: 'Listing Rejected',
          body: `Your listing has been rejected due to policy violation.`,
          data: { listing_id: targetId },
          read: false,
        });
      } else if (actionTaken === 'flag') {
        await supabase
          .from('listings')
          .update({
            moderation_status: 'pending_review',
            moderation_priority: 'urgent',
            moderation_trigger: `AI: ${violationTypesString}`,
            moderation_note: violationTypesString,
          })
          .eq('id', targetId);

        // Also insert into moderation_queue for admin System Queue
        await supabase.from('moderation_queue').insert({
          target_type: 'listing',
          target_id: targetId,
          user_id: userId,
          trigger_source: 'auto',
          review_method: reviewMode,
          matched_words: wordMatches,
          ai_flags: imageDetails.filter(i => i.flagged).reduce((acc: any, i) => {
            acc[`image_${i.index}`] = i.reasons;
            return acc;
          }, {}),
          content_snapshot: contentSnapshot.substring(0, 2000),
          status: 'pending',
        });

        // Notify seller
        await supabase.from('notifications').insert({
          user_id: userId,
          type: 'system',
          title: 'Listing Under Review',
          body: `Your listing is being reviewed by our team.`,
          data: { listing_id: targetId },
          read: false,
        });
      }
    }

    // For messages/profiles with image violations: store blur metadata
    // The client reads image_details from backend_moderation_logs and
    // renders a blur overlay with violation labels locally.
    if (imageFlagged && targetType === 'message') {
      // Mark the message with moderation metadata (store in a jsonb column or separate table)
      // For now, we can use the moderation_queue to flag for admin visibility
      await supabase.from('moderation_queue').insert({
        target_type: 'message',
        target_id: targetId,
        user_id: userId,
        trigger_source: 'auto',
        review_method: reviewMode,
        ai_flags: imageDetails.filter(i => i.flagged).reduce((acc: any, i) => {
          acc[`image_${i.index}`] = i.reasons;
          return acc;
        }, {}),
        content_snapshot: contentSnapshot.substring(0, 500),
        status: 'pending',
      });
    }

    // ── 7. Mark task as done ─────────────────────────────────

    await supabase
      .from('moderation_tasks')
      .update({
        status: 'done',
        processed_at: new Date().toISOString(),
      })
      .eq('id', taskId);

    return new Response(JSON.stringify({
      success: true,
      task_id: taskId,
      target_type: targetType,
      target_id: targetId,
      flagged: overallFlagged,
      action_taken: actionTaken,
      engine: engineUsed,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    console.error('[moderate-content] Error:', error);

    // Try to mark the task as errored
    try {
      const payload = await new Response(error).text();
      const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
      const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
      const supabase = createClient(supabaseUrl, supabaseKey);
      // We can't easily get taskId here since we're in catch block
    } catch (_) {
      // Ignore cleanup errors
    }

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
