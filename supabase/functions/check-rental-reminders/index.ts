import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// NOTE: CORS headers must be included on EVERY response (including errors),
// otherwise the browser treats a non-2xx response as a CORS failure and
// surfaces it as "Failed to send a request to the Edge Function".
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type, apikey, x-client-info",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}

// NOTE: This function is designed to be called by:
//   1. pg_cron daily at 08:00 UTC via sql job (migration 00105)
//   2. Manually from the admin dashboard (Run Scheduler Now button)
serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  console.log("[check-rental-reminders] Received request:", req.method);

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Call DB function to insert rental_reminder notifications for all active
    // rentals whose reminder window has arrived (rental_end_date - today <= reminder_days_before).
    const { data: reminderCount, error: rpcError } = await supabase
      .rpc("check_rental_reminders");

    if (rpcError) {
      console.error("[check-rental-reminders] RPC error:", rpcError.message, rpcError.details);
      return jsonResponse({ success: false, error: rpcError.message }, 500);
    }

    const count = reminderCount ?? 0;
    console.log(`[check-rental-reminders] Processed ${count} rental reminder(s).`);

    // Push delivery is handled automatically via the Supabase Database Webhook
    // on notifications table INSERT → push-notification Edge Function → OneSignal.

    return jsonResponse({
      success: true,
      reminders_processed: count,
      message: `${count} rental reminder notification(s) queued for push delivery.`,
    });
  } catch (err) {
    console.error("[check-rental-reminders] Unexpected error:", String(err));
    return jsonResponse({ success: false, error: String(err) }, 500);
  }
});
