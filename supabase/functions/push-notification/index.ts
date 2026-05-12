import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_API_KEY = Deno.env.get("ONESIGNAL_REST_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

serve(async (req) => {
  try {
    const payload = await req.json();

    // Only process INSERT events
    if (payload.type !== "INSERT") {
      return new Response("Not an INSERT event, skipping", { status: 200 });
    }

    const record = payload.record;
    if (!record) {
      return new Response("No record found in payload", { status: 400 });
    }

    const userId = record.user_id;
    const notificationType = record.type;
    const title = record.title;
    const body = record.body;
    const relatedOrderId = record.related_order_id;
    const actionUrl = record.action_url;
    // chat_room_id is populated for 'new_message' notifications only.
    const chatRoomId = record.chat_room_id ?? null;

    if (!userId || !notificationType || (!title && !body)) {
      return new Response("Missing required fields (user_id, type, or title/body)", { status: 400 });
    }

    // Initialize Supabase client using Service Role to bypass RLS
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

    // ── Server-side suppression for chat messages ────────────────────────────
    // If the recipient is currently viewing the exact chat room that generated
    // this notification, skip the push entirely.
    //
    // TTL safety net: only trust session records updated within the last 2
    // minutes. This handles cases where the client crashed or dispose() failed
    // to call clearActiveSession, ensuring push delivery eventually resumes.
    if (notificationType === "new_message" && chatRoomId) {
      const { data: session } = await supabase
        .from("user_active_sessions")
        .select("chat_room_id, updated_at")
        .eq("user_id", userId)
        .single();

      if (session?.chat_room_id === chatRoomId) {
        const sessionAge = Date.now() - new Date(session.updated_at).getTime();
        const SESSION_TTL_MS = 2 * 60 * 1000; // 2 minutes

        if (sessionAge <= SESSION_TTL_MS) {
          console.log(
            `[push] Suppressed: user ${userId} is actively viewing room ${chatRoomId} (session age: ${Math.round(sessionAge / 1000)}s)`,
          );
          return new Response("Suppressed: user is currently in this chat room", { status: 200 });
        } else {
          console.log(
            `[push] Stale session detected (age: ${Math.round(sessionAge / 1000)}s) — delivering push.`,
          );
        }
      }
    }

    // ── Server-side suppression for GROUP chat messages ──────────────────────
    // Same pattern as 1-on-1 chat: check group_chat_room_id column.
    if (notificationType === "group_message") {
      const { data: session } = await supabase
        .from("user_active_sessions")
        .select("group_chat_room_id, updated_at")
        .eq("user_id", userId)
        .single();

      // Extract the room_id from the action_url (format: /group-chat/<room_id>)
      const actionRoomId = actionUrl ? actionUrl.replace('/group-chat/', '') : null;

      if (session?.group_chat_room_id && actionRoomId &&
          session.group_chat_room_id === actionRoomId) {
        const sessionAge = Date.now() - new Date(session.updated_at).getTime();
        const SESSION_TTL_MS = 2 * 60 * 1000;

        if (sessionAge <= SESSION_TTL_MS) {
          console.log(
            `[push] Suppressed group: user ${userId} is in group room ${actionRoomId}`,
          );
          return new Response("Suppressed: user is currently in this group chat", { status: 200 });
        }
      }
    }
    // ─────────────────────────────────────────────────────────────────────────

    // Fetch user profile and push preferences
    const { data: profile, error } = await supabase
      .from("user_profiles")
      .select("onesignal_player_id, push_notifications_enabled, push_messages, push_order_updates")
      .eq("id", userId)
      .single();

    if (error || !profile) {
      console.error("Error fetching user profile:", error);
      return new Response("User profile not found", { status: 404 });
    }

    // Master switch check
    if (!profile.push_notifications_enabled) {
      return new Response("User has push notifications globally disabled", { status: 200 });
    }

    // Order updates switch check
    const isOrderRelated = [
      "order_placed",
      "order_accepted",
      "order_cancelled",
      "order_delivered",
      "order_completed",
    ].includes(notificationType);

    if (isOrderRelated && !profile.push_order_updates) {
      return new Response("User has order update notifications disabled", { status: 200 });
    }

    // Message updates switch check (covers both 1-on-1 and group messages)
    if ((notificationType === "new_message" || notificationType === "group_message") && !profile.push_messages) {
      return new Response("User has message notifications disabled", { status: 200 });
    }

    // Check if user has registered a device for push
    if (!profile.onesignal_player_id) {
      return new Response("User has no onesignal_player_id registered", { status: 200 });
    }

    // Prepare OneSignal payload
    const oneSignalPayload = {
      app_id: ONESIGNAL_APP_ID,
      include_subscription_ids: [profile.onesignal_player_id],
      headings: title ? { en: title } : undefined,
      contents: body ? { en: body } : undefined,
      data: {
        type: notificationType,
        order_id: relatedOrderId || undefined,
        chat_room_id: chatRoomId || undefined,
        action_url: actionUrl || undefined,
      },
    };

    // Call OneSignal REST API
    const oneSignalRes = await fetch("https://api.onesignal.com/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${ONESIGNAL_REST_API_KEY}`,
      },
      body: JSON.stringify(oneSignalPayload),
    });

    if (!oneSignalRes.ok) {
      const errorBody = await oneSignalRes.text();
      console.error("OneSignal error:", errorBody);
      return new Response("Error sending to OneSignal", { status: 500 });
    }

    console.log(`[push] Sent '${notificationType}' push to user ${userId}`);
    return new Response("Notification sent successfully", { status: 200 });
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
