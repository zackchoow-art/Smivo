import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.44.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const payload = await req.json();
    const record = payload.record;
    const table = payload.table;

    if (!record || payload.type !== 'INSERT') {
      return new Response(JSON.stringify({ message: 'Ignoring non-insert payload or empty record' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    if (table !== 'listings' && table !== 'messages') {
      return new Response(JSON.stringify({ message: `Ignoring unsupported table: ${table}` }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 1. Fetch system configs
    const { data: configs, error: configError } = await supabase
      .from('system_configs')
      .select('config_key, config_value');

    if (configError) throw configError;

    const getConfig = (key: string) => {
      const config = configs?.find((c) => c.config_key === key);
      return config ? config.config_value : null;
    };

    // 2. Check backend_review.enabled
    const reviewEnabled = getConfig('backend_review.enabled');
    if (reviewEnabled !== 'true' && reviewEnabled !== true) {
      return new Response(JSON.stringify({ message: 'Backend review disabled' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 3. Get review mode
    const mode = getConfig('backend_review.mode') || 'sensitive_words';
    let wordMatches: string[] = [];
    let aiFlags: any = {};
    let isViolation = false;

    let textToCheck = '';
    let userId = '';
    let contentSnapshot = '';

    if (table === 'listings') {
      textToCheck = `${record.title}\n${record.description}`.toLowerCase();
      userId = record.seller_id;
      contentSnapshot = `${record.title}\n---\n${record.description}`;
    } else if (table === 'messages') {
      textToCheck = `${record.content}`.toLowerCase();
      userId = record.sender_id;
      contentSnapshot = record.content;
    }

    // 4a. Sensitive words matching
    if (mode === 'sensitive_words' || mode === 'both') {
      const { data: words, error: wordsError } = await supabase
        .from('sensitive_words')
        .select('word, severity')
        .eq('is_active', true)
        .eq('severity', 'block');
      
      if (!wordsError && words) {
        wordMatches = words
          .filter(w => textToCheck.includes(w.word.toLowerCase()))
          .map(w => w.word);
        
        if (wordMatches.length > 0) isViolation = true;
      }
    }

    // 4b. AI Moderation
    if (mode === 'ai' || mode === 'both') {
      const openAiKey = Deno.env.get('OPENAI_API_KEY');
      if (openAiKey) {
        const response = await fetch('https://api.openai.com/v1/moderations', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${openAiKey}`,
          },
          body: JSON.stringify({
            input: textToCheck,
          }),
        });
        
        const modData = await response.json();
        if (modData.results && modData.results[0].flagged) {
          isViolation = true;
          aiFlags = modData.results[0].categories;
        }
      } else {
        console.warn('OPENAI_API_KEY is not set. Skipping AI moderation.');
      }
    }

    // 5. Take action if violation detected
    if (isViolation) {
      console.log(`Violation detected for ${table} ${record.id}`);
      
      // Insert into moderation_queue
      await supabase.from('moderation_queue').insert({
        target_type: table === 'listings' ? 'listing' : 'message',
        target_id: record.id,
        user_id: userId,
        trigger_source: 'auto',
        review_method: mode,
        matched_words: wordMatches,
        ai_flags: aiFlags,
        content_snapshot: contentSnapshot,
        status: 'pending',
      });

      if (table === 'listings') {
        // Mark listing as flagged
        await supabase
          .from('listings')
          .update({ moderation_status: 'flagged' })
          .eq('id', record.id);

        // Notify seller
        await supabase.from('notifications').insert({
          user_id: userId,
          type: 'system',
          title: 'Content Under Review',
          body: `Your listing "${record.title}" is under review.`,
          data: { listing_id: record.id },
          read: false
        });
      }
    }

    return new Response(JSON.stringify({ 
      success: true, 
      moderated: true,
      violation: isViolation 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error: any) {
    console.error('Error in moderate-content:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
