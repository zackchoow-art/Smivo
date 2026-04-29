import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_API_KEY = Deno.env.get("ONESIGNAL_REST_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { title, body } = await req.json();

    if (!title || !body) {
      return new Response("Missing required fields (title, body)", { status: 400, headers: corsHeaders });
    }

    // Verify authentication and admin role
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response("Missing Authorization header", { status: 401, headers: corsHeaders });
    }

    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);
    const token = authHeader.replace('Bearer ', '');
    
    // Get user from token
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response("Invalid token", { status: 401, headers: corsHeaders });
    }

    // Check if user is admin
    const { data: isAdmin, error: roleError } = await supabase
      .rpc('is_sysadmin', { user_id: user.id });

    if (roleError || !isAdmin) {
      return new Response("Unauthorized", { status: 403, headers: corsHeaders });
    }

    // Call OneSignal REST API to broadcast
    const oneSignalPayload = {
      app_id: ONESIGNAL_APP_ID,
      included_segments: ["Subscribed Users"],
      headings: { en: title },
      contents: { en: body },
      data: {
        type: 'system',
      }
    };

    const oneSignalRes = await fetch("https://api.onesignal.com/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify(oneSignalPayload),
    });

    if (!oneSignalRes.ok) {
      const errorText = await oneSignalRes.text();
      console.error("OneSignal Error:", errorText);
      return new Response(`OneSignal API Error: ${errorText}`, { status: 500, headers: corsHeaders });
    }

    // Insert to database notifications
    const { error: rpcError } = await supabase.rpc('broadcast_system_notification', {
      p_title: title,
      p_body: body
    });

    if (rpcError) {
      console.error("RPC Error:", rpcError);
      // Even if DB fails, we already sent the push, so just warn
    }

    return new Response(
      JSON.stringify({ success: true, message: "Broadcast sent successfully" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Function error:", err);
    return new Response(`Internal Server Error: ${err.message}`, { status: 500, headers: corsHeaders });
  }
});
