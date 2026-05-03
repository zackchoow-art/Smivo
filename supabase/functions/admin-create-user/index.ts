import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const authHeader = req.headers.get('Authorization');

    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 1. Create client to verify caller
    const supabaseClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
      global: { headers: { Authorization: authHeader } },
    });

    // 2. Verify caller is a sysadmin
    const token = authHeader.replace('Bearer ', '').trim();
    const { data: userData, error: userError } = await supabaseClient.auth.getUser(token);
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: 'Unauthorized', details: userError }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: roleData, error: roleError } = await supabaseClient.rpc('is_platform_sysadmin');
    if (roleError || !roleData) {
      return new Response(JSON.stringify({ error: 'Only sysadmins can create users' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { email, displayName, password, role, schoolId } = await req.json();

    if (!email || !role || !displayName) {
      return new Response(JSON.stringify({ error: 'Missing required fields: email, role, or display name' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 3. Create Admin client with Service Role Key
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // 4. Create user
    // This will trigger handle_new_user.
    // We pass bypass_edu: 'true' in user_metadata so the trigger bypasses the .edu check
    // and reads school_id and role from metadata to insert into user_profiles and admin_users.
    const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password: password || 'password123',
      email_confirm: true,
      user_metadata: {
        bypass_edu: 'true',
        school_id: schoolId,
        role: role,
        display_name: displayName
      }
    });

    if (createError) throw createError;

    // 5. Log audit
    await supabaseAdmin.from('admin_audit_logs').insert({
      admin_id: userData.user.id,
      action: 'admin_create_user',
      target_type: 'user',
      target_id: newUser.user.id,
      payload: { email, role, schoolId }
    });

    return new Response(JSON.stringify({ success: true, user_id: newUser.user.id }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message || 'Unknown error occurred' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  }
});
