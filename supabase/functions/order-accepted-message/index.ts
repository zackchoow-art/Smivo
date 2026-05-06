import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ── order-accepted-message Edge Function ──────────────────────────────────
//
// Triggered via a Supabase Database Webhook on the `orders` table
// for UPDATE events where status changes to 'confirmed'.
//
// Behaviour (controlled by system_config key 'auto_accept_message_enabled'):
//   - Reads the system config flag — if disabled, returns 200 immediately.
//   - Looks up the chat room between buyer and seller for the accepted listing.
//   - Inserts a platform system message into the messages table.
//   - The message appears in the existing chat thread so the buyer can contact
//     the seller immediately without finding the chat manually.
//
// NOTE: This function uses the Service Role Key to bypass RLS, which is
// required to insert a message on behalf of the platform (not a real user).
// The sender_id is set to the seller's user_id so the message appears on
// the left side (other party) in the buyer's chat view.

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    const payload = await req.json();

    // Only process UPDATE events (order status changes).
    if (payload.type !== "UPDATE") {
      return new Response("Not an UPDATE event, skipping", { status: 200 });
    }

    const oldRecord = payload.old_record;
    const newRecord = payload.record;

    if (!newRecord || !oldRecord) {
      return new Response("Missing record or old_record in payload", { status: 400 });
    }

    // Only trigger when status transitions TO 'confirmed'.
    const wasConfirmed = oldRecord.status === "confirmed";
    const isNowConfirmed = newRecord.status === "confirmed";

    if (wasConfirmed || !isNowConfirmed) {
      return new Response("Not a confirmed transition, skipping", { status: 200 });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ── 1. Check system config flag ─────────────────────────────────────
    // Stored in system_settings (jsonb column) via migration 00125.
    // The value should be JSON boolean true — but we also handle the legacy
    // JSON string "true" case in case the DB row was inserted without ::jsonb cast.
    const { data: flag, error: flagError } = await supabase
      .from("system_settings")
      .select("value")
      .eq("key", "auto_accept_message_enabled")
      .maybeSingle();

    if (flagError) {
      // NOTE: Log but do not abort — fail open (send the message) so a
      // misconfigured DB doesn't silently break the user experience.
      console.warn("[order-accepted-message] Could not read feature flag, defaulting to enabled:", flagError.message);
    }

    // Resolve flag: default to enabled if row is missing or unreadable.
    // flag.value is JS boolean true  when DB stores jsonb boolean true  (normal case)
    // flag.value is JS string "true" when DB stores jsonb string "true" (legacy case)
    const rawValue = flag?.value;
    const isEnabled = rawValue === undefined || rawValue === null ||
      rawValue === true ||
      rawValue === "true";

    console.log(`[order-accepted-message] Feature flag raw value: ${JSON.stringify(rawValue)}, isEnabled: ${isEnabled}`);

    if (!isEnabled) {
      console.log("[order-accepted-message] Feature disabled via system_settings. Skipping.");
      return new Response("Feature disabled", { status: 200 });
    }

    const orderId = newRecord.id as string;
    const listingId = newRecord.listing_id as string;
    const buyerId = newRecord.buyer_id as string;
    const sellerId = newRecord.seller_id as string;

    if (!orderId || !listingId || !buyerId || !sellerId) {
      return new Response("Missing order fields", { status: 400 });
    }

    // ── 2. Find or Create the chat room for this buyer+seller+listing combo ──
    let chatRoomId: string;
    const { data: chatRoom, error: chatError } = await supabase
      .from("chat_rooms")
      .select("id")
      .eq("listing_id", listingId)
      .eq("buyer_id", buyerId)
      .eq("seller_id", sellerId)
      .maybeSingle();

    if (chatError) {
      console.error("[order-accepted-message] Error fetching chat room:", chatError);
      return new Response("Database error", { status: 500 });
    }

    if (!chatRoom) {
      console.log(`[order-accepted-message] No chat room found for order ${orderId}. Creating one.`);
      const { data: newRoom, error: createError } = await supabase
        .from("chat_rooms")
        .insert({
          listing_id: listingId,
          buyer_id: buyerId,
          seller_id: sellerId,
        })
        .select("id")
        .single();

      if (createError || !newRoom) {
        console.error("[order-accepted-message] Failed to create chat room:", createError);
        return new Response("Failed to create chat room", { status: 500 });
      }
      chatRoomId = newRoom.id as string;
    } else {
      chatRoomId = chatRoom.id as string;
    }

    // ── 3. Fetch the listing title for a contextual message ──────────────
    const { data: listing } = await supabase
      .from("listings")
      .select("title")
      .eq("id", listingId)
      .single();

    const listingTitle = listing?.title ?? "this item";

    // ── 4. Insert a platform message in the chat room ────────────────────
    // NOTE: sender_id is set to the seller so the message appears on the
    // "other" side for the buyer, making it feel like a seller greeting.
    const messageText =
      `✅ Your offer for "${listingTitle}" has been accepted! ` +
      `Feel free to coordinate pickup details here. ` +
      `You can view the order in your Buyer Center.`;

    const { error: msgError } = await supabase.from("messages").insert({
      chat_room_id: chatRoomId,
      sender_id: sellerId,
      content: messageText,
      message_type: "text",
    });

    if (msgError) {
      console.error("[order-accepted-message] Failed to insert message:", msgError);
      return new Response("Failed to insert message", { status: 500 });
    }

    // Also update the chat room's last_message_at and increment unread count for buyer
    await supabase
      .from("chat_rooms")
      .update({
        last_message_at: new Date().toISOString(),
        unread_count_buyer: 1, // Start with 1 if new, or increment logic (though simple update is fine for platform msg)
      })
      .eq("id", chatRoomId);

    console.log(
      `[order-accepted-message] Sent auto-message for order ${orderId} in room ${chatRoomId}`,
    );
    return new Response("Message sent", { status: 200 });
  } catch (err) {
    console.error("[order-accepted-message] Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
