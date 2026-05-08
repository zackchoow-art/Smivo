-- ============================================================
-- Migration 00127: Update cleanup RPCs for current schema
-- ============================================================
-- Tables added since last cleanup update (00088):
--   backend_moderation_logs (00094) — AI review audit trail
--   moderation_tasks        (00094) — moderation task queue
--   user_saved_locations    (00120) — custom pickup addresses
--   user_reviews            (00044) — order reviews
--   user_review_tag_links   (00044) — review ↔ tag junction
--   push_jobs               (00052) — push notification jobs
--   image_moderation_usage  (00090) — API usage counters
--
-- Also fixes school cleanup missing:
--   hourly_active_users, moderation_drafts
-- ============================================================

-- ── School-scoped cleanup ──────────────────────────────────────
DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids  uuid[];
  v_user_ids     uuid[];
  v_order_ids    uuid[];
  v_room_ids     uuid[];
  v_message_ids  uuid[];
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  -- ── Collect entity IDs scoped to this school ──────────────────
  SELECT array_agg(id) INTO v_listing_ids
    FROM public.listings WHERE school_id = p_school_id;

  SELECT array_agg(id) INTO v_user_ids
    FROM public.user_profiles WHERE school_id = p_school_id;

  -- ── Order & chat-linked data ──────────────────────────────────
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids
      FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids
      FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    -- Collect message IDs before deleting messages (needed for moderation_tasks)
    IF v_room_ids IS NOT NULL THEN
      SELECT array_agg(id) INTO v_message_ids
        FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    -- Order-linked children (must precede orders deletion)
    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.user_review_tag_links
        WHERE review_id IN (
          SELECT id FROM public.user_reviews WHERE order_id = ANY(v_order_ids)
        );
      DELETE FROM public.user_reviews WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence WHERE order_id = ANY(v_order_ids);
    END IF;

    -- Chat-linked children (must precede chat_rooms deletion)
    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    -- NOTE: content_reports before listings/chat_rooms to avoid
    -- ON DELETE SET NULL unique constraint violations
    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports
        WHERE reporter_id = ANY(v_user_ids)
           OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);

    -- Moderation data linked to listings/messages
    DELETE FROM public.backend_moderation_logs
      WHERE target_id = ANY(v_listing_ids)
         OR (v_message_ids IS NOT NULL AND target_id = ANY(v_message_ids));
    DELETE FROM public.moderation_tasks
      WHERE (target_type = 'listing'  AND target_id = ANY(v_listing_ids))
         OR (v_message_ids IS NOT NULL AND target_type = 'message' AND target_id = ANY(v_message_ids));
    DELETE FROM public.moderation_queue WHERE target_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_drafts WHERE college_id = p_school_id;

    -- Listing-linked tables
    DELETE FROM public.listing_views WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings WHERE id = ANY(v_listing_ids);
  END IF;

  -- ── User-linked data (school-scoped via v_user_ids) ───────────
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks
      WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports
      WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.backend_moderation_logs WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.moderation_tasks
      WHERE target_type = 'profile' AND target_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.notifications WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.hourly_active_users WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_saved_locations WHERE user_id = ANY(v_user_ids);
    -- NOTE: user_reviews by reviewer/target already handled via order cascade above;
    -- catch any remaining (e.g. reviews for cross-school orders)
    DELETE FROM public.user_review_tag_links
      WHERE review_id IN (
        SELECT id FROM public.user_reviews
        WHERE reviewer_id = ANY(v_user_ids) OR target_user_id = ANY(v_user_ids)
      );
    DELETE FROM public.user_reviews
      WHERE reviewer_id = ANY(v_user_ids) OR target_user_id = ANY(v_user_ids);
  END IF;

  -- School-scoped push jobs
  DELETE FROM public.push_jobs WHERE college_id = p_school_id;

  -- NOTE: admin_audit_logs are intentionally NOT deleted.
  -- Audit trail must be preserved in production for compliance.

  -- Record this cleanup action in the audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object(
    'status', 'success', 'scope', 'school',
    'school_id', p_school_id, 'purged_at', now()
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;


-- ── Platform-wide cleanup ──────────────────────────────────────
DROP FUNCTION IF EXISTS public.clear_platform_test_data();
CREATE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  -- NOTE: target_id is uuid — use nil UUID as placeholder for platform-wide scope
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', '00000000-0000-0000-0000-000000000000'::uuid,
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));

  -- Order matters: children before parents

  -- Review system (must precede orders)
  DELETE FROM public.user_review_tag_links;
  DELETE FROM public.user_reviews;

  -- Order-linked
  DELETE FROM public.rental_extensions;
  DELETE FROM public.order_evidence;

  -- Chat-linked
  DELETE FROM public.messages;

  -- NOTE: content_reports before listings/chat_rooms to avoid
  -- ON DELETE SET NULL unique constraint violations
  DELETE FROM public.content_reports;

  -- Moderation data
  DELETE FROM public.backend_moderation_logs;
  DELETE FROM public.moderation_tasks;
  DELETE FROM public.moderation_queue;
  DELETE FROM public.listing_moderation_notices;
  DELETE FROM public.moderation_drafts;

  -- Listing-linked
  DELETE FROM public.listing_views;
  DELETE FROM public.saved_listings;
  DELETE FROM public.listing_images;

  -- Chat rooms and orders reference listings
  DELETE FROM public.chat_rooms;
  DELETE FROM public.orders;

  -- Now safe to delete listings
  DELETE FROM public.listings;

  -- User-linked
  DELETE FROM public.user_blocks;
  DELETE FROM public.user_feedbacks;
  DELETE FROM public.contribution_ledger;
  DELETE FROM public.notifications;
  DELETE FROM public.user_bans;
  DELETE FROM public.user_active_sessions;
  DELETE FROM public.user_heartbeats;
  DELETE FROM public.hourly_active_users;
  DELETE FROM public.user_saved_locations;

  -- Push notification jobs
  DELETE FROM public.push_jobs;

  -- Usage counters (safe to reset for pre-launch)
  DELETE FROM public.image_moderation_usage;

  RETURN jsonb_build_object('status', 'success', 'scope', 'platform', 'purged_at', now());
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_platform_test_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
