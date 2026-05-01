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
    const listing = payload.record;

    if (!listing || payload.type !== 'INSERT') {
      return new Response(JSON.stringify({ message: 'Ignoring non-insert payload' }), {
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

    const isEnabled = getConfig('ai_moderation_enabled');
    if (isEnabled !== true && isEnabled !== 'true') {
      return new Response(JSON.stringify({ message: 'AI moderation disabled' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    const provider = getConfig('ai_provider') || 'openai';
    const actionOnHit = getConfig('ai_action_on_hit') || 'flag';

    console.log(`Analyzing listing ${listing.id} with ${provider}...`);

    let isViolation = false;
    let violationReason = '';

    // 2. Perform AI Moderation
    if (provider === 'openai') {
      const openAiKey = Deno.env.get('OPENAI_API_KEY');
      if (!openAiKey) throw new Error('OPENAI_API_KEY is not set');

      // Simple text moderation as an example (ideally we would use vision for listing images)
      const response = await fetch('https://api.openai.com/v1/moderations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${openAiKey}`,
        },
        body: JSON.stringify({
          input: `${listing.title}\n\n${listing.description}`,
        }),
      });
      
      const modData = await response.json();
      if (modData.results && modData.results[0].flagged) {
        isViolation = true;
        violationReason = 'OpenAI Flagged Content';
      }
    } else if (provider === 'google') {
      // Mock Google Vision/Gemini implementation
      console.log('Google provider selected, using mock validation');
      isViolation = false;
    }

    // 3. Take action if violation detected
    if (isViolation) {
      console.log(`Violation detected for listing ${listing.id}: ${violationReason}`);
      
      // Update listing status
      const newStatus = actionOnHit === 'reject' ? 'rejected' : 'flagged';
      await supabase
        .from('listings')
        .update({ moderation_status: newStatus })
        .eq('id', listing.id);

      // Create a notification for the user
      await supabase.from('notifications').insert({
        user_id: listing.seller_id,
        type: 'system',
        title: 'Listing Moderation Alert',
        body: `Your listing "${listing.title}" has been ${newStatus} due to policy violations.`,
        data: { listing_id: listing.id, reason: violationReason },
        read: false
      });
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
