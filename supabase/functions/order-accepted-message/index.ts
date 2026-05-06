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
    const { data: config } = await supabase
      .from("system_configs")
      .select("config_value")
      .eq("config_key", "auto_accept_message_enabled")
      .single();

    // Default to disabled if config is missing or explicitly false.
    const isEnabled =
      config?.config_value === true ||
      config?.config_value === "true" ||
      config?.config_value === '"true"';

    if (!isEnabled) {
      console.log("[order-accepted-message] Feature disabled via system_configs. Skipping.");
      return new Response("Feature disabled", { status: 200 });
    }

    const orderId = newRecord.id as string;
    const listingId = newRecord.listing_id as string;
    const buyerId = newRecord.buyer_id as string;
    const sellerId = newRecord.seller_id as string;

    if (!orderId || !listingId || !buyerId || !sellerId) {
      return new Response("Missing order fields", { status: 400 });
    }

    // ── 2. Find the chat room for this buyer+seller+listing combo ────────
    const { data: chatRoom, error: chatError } = await supabase
      .from("chat_rooms")
      .select("id")
      .eq("listing_id", listingId)
      .eq("buyer_id", buyerId)
      .eq("seller_id", sellerId)
      .single();

    if (chatError || !chatRoom) {
      console.warn(
        `[order-accepted-message] No chat room found for order ${orderId}. ` +
          "Buyer may not have messaged seller before accepting.",
      );
      return new Response("No chat room found", { status: 200 });
    }

    const chatRoomId = chatRoom.id as string;

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

    console.log(
      `[order-accepted-message] Sent auto-message for order ${orderId} in room ${chatRoomId}`,
    );
    return new Response("Message sent", { status: 200 });
  } catch (err) {
    console.error("[order-accepted-message] Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
