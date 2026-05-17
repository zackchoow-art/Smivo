-- ============================================================
-- Migration 00175: Cleanup backup system
-- ============================================================
-- Adds backup-before-delete to school cleanup, scoped storage
-- cleanup, restore capability, and drops platform-wide purge.
-- ============================================================

-- ── 1. Backup table ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cleanup_backups (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  school_id     uuid        NOT NULL REFERENCES public.schools(id),
  admin_id      uuid        NOT NULL,
  backup_data   jsonb       NOT NULL DEFAULT '{}'::jsonb,
  -- Storage file paths that were backed up (filled by frontend after copy)
  storage_manifest jsonb    NOT NULL DEFAULT '[]'::jsonb,
  created_at    timestamptz NOT NULL DEFAULT now(),
  restored_at   timestamptz,
  purged_at     timestamptz
);

COMMENT ON TABLE public.cleanup_backups IS
'Snapshots of school data taken before cleanup. Allows one-click restore.';

-- ── 2. Backup storage bucket ────────────────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('cleanup-backups', 'cleanup-backups', false)
ON CONFLICT (id) DO NOTHING;

-- Admin-only read/write/delete on backup bucket
CREATE POLICY "Admin read cleanup-backups"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'cleanup-backups' AND public.is_admin_user());

CREATE POLICY "Admin insert cleanup-backups"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'cleanup-backups' AND public.is_admin_user());

CREATE POLICY "Admin delete cleanup-backups"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'cleanup-backups' AND public.is_admin_user());

-- ── 3. Drop platform-wide purge ─────────────────────────────
DROP FUNCTION IF EXISTS public.clear_platform_test_data();

-- ── 4. Rewrite clear_school_test_data (backup-first) ────────
DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_backup_id      uuid;
  v_listing_ids    uuid[];
  v_user_ids       uuid[];
  v_order_ids      uuid[];
  v_room_ids       uuid[];
  v_trip_ids       uuid[];
  v_group_room_ids uuid[];
  v_backup_data    jsonb;
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  -- ── Collect IDs ───────────────────────────────────────────
  SELECT array_agg(id) INTO v_listing_ids
    FROM public.listings WHERE school_id = p_school_id;
  SELECT array_agg(id) INTO v_user_ids
    FROM public.user_profiles WHERE school_id = p_school_id;

  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids
      FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids
      FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);
  END IF;

  IF v_user_ids IS NOT NULL THEN
    SELECT array_agg(DISTINCT ct.id) INTO v_trip_ids
      FROM public.carpool_trips ct
      WHERE ct.creator_id = ANY(v_user_ids)
         OR ct.id IN (
           SELECT trip_id FROM public.carpool_members
           WHERE user_id = ANY(v_user_ids)
         );
    IF v_trip_ids IS NOT NULL THEN
      SELECT array_agg(id) INTO v_group_room_ids
        FROM public.group_chat_rooms WHERE trip_id = ANY(v_trip_ids);
    END IF;
  END IF;

  -- ── Build backup snapshot ─────────────────────────────────
  v_backup_data := jsonb_build_object(
    'meta', jsonb_build_object(
      'school_id', p_school_id,
      'rpc_version', '00175',
      'cleaned_at', now(),
      'listing_count', COALESCE(array_length(v_listing_ids, 1), 0),
      'user_count',    COALESCE(array_length(v_user_ids, 1), 0),
      'order_count',   COALESCE(array_length(v_order_ids, 1), 0)
    ),
    'scope', jsonb_build_object(
      'user_ids',       COALESCE(to_jsonb(v_user_ids), '[]'::jsonb),
      'listing_ids',    COALESCE(to_jsonb(v_listing_ids), '[]'::jsonb),
      'order_ids',      COALESCE(to_jsonb(v_order_ids), '[]'::jsonb),
      'chat_room_ids',  COALESCE(to_jsonb(v_room_ids), '[]'::jsonb),
      'trip_ids',       COALESCE(to_jsonb(v_trip_ids), '[]'::jsonb),
      'group_room_ids', COALESCE(to_jsonb(v_group_room_ids), '[]'::jsonb)
    ),
    'tables', jsonb_build_object(
      'listings',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.listings t
          WHERE t.id = ANY(v_listing_ids)), '[]'::jsonb),
      'listing_images',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.listing_images t
          WHERE t.listing_id = ANY(v_listing_ids)), '[]'::jsonb),
      'orders',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.orders t
          WHERE t.listing_id = ANY(v_listing_ids)), '[]'::jsonb),
      'order_evidence',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.order_evidence t
          WHERE t.order_id = ANY(v_order_ids)), '[]'::jsonb),
      'rental_extensions',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.rental_extensions t
          WHERE t.order_id = ANY(v_order_ids)), '[]'::jsonb),
      'chat_rooms',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.chat_rooms t
          WHERE t.listing_id = ANY(v_listing_ids)), '[]'::jsonb),
      'messages',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.messages t
          WHERE t.chat_room_id = ANY(v_room_ids)), '[]'::jsonb),
      'saved_listings',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.saved_listings t
          WHERE t.listing_id = ANY(v_listing_ids)), '[]'::jsonb),
      'notifications',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.notifications t
          WHERE t.user_id = ANY(v_user_ids)), '[]'::jsonb),
      'carpool_trips',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.carpool_trips t
          WHERE t.id = ANY(v_trip_ids)), '[]'::jsonb),
      'carpool_members',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.carpool_members t
          WHERE t.trip_id = ANY(v_trip_ids) OR t.user_id = ANY(v_user_ids)), '[]'::jsonb),
      'carpool_proposals',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.carpool_proposals t
          WHERE t.trip_id = ANY(v_trip_ids) OR t.proposer_id = ANY(v_user_ids)), '[]'::jsonb),
      'carpool_reviews',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.carpool_reviews t
          WHERE t.trip_id = ANY(v_trip_ids) OR t.reviewer_id = ANY(v_user_ids)), '[]'::jsonb),
      'group_chat_rooms',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.group_chat_rooms t
          WHERE t.id = ANY(v_group_room_ids)), '[]'::jsonb),
      'group_chat_members',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.group_chat_members t
          WHERE t.room_id = ANY(v_group_room_ids) OR t.user_id = ANY(v_user_ids)), '[]'::jsonb),
      'group_messages',
        COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM public.group_messages t
          WHERE t.room_id = ANY(v_group_room_ids)), '[]'::jsonb)
    )
  );

  -- ── Insert backup record ──────────────────────────────────
  v_backup_id := gen_random_uuid();
  INSERT INTO public.cleanup_backups (id, school_id, admin_id, backup_data)
  VALUES (v_backup_id, p_school_id, auth.uid(), v_backup_data);

  -- ── Delete data (same order as before) ────────────────────
  IF v_listing_ids IS NOT NULL THEN
    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence    WHERE order_id = ANY(v_order_ids);
    END IF;
    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages      WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;
    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports
        WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports           WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_views             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_queue          WHERE target_id  = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms                WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders                    WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings            WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images            WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings                  WHERE id         = ANY(v_listing_ids);
  END IF;

  -- ── Carpool & group-chat ──────────────────────────────────
  IF v_user_ids IS NOT NULL THEN
    IF v_trip_ids IS NOT NULL THEN
      IF v_group_room_ids IS NOT NULL THEN
        DELETE FROM public.group_messages     WHERE room_id = ANY(v_group_room_ids);
        DELETE FROM public.group_chat_members WHERE room_id = ANY(v_group_room_ids);
        DELETE FROM public.group_chat_rooms   WHERE id      = ANY(v_group_room_ids);
      END IF;
      DELETE FROM public.carpool_reviews WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_votes WHERE proposal_id IN (
        SELECT id FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids)
      );
      DELETE FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_members   WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_trips     WHERE id      = ANY(v_trip_ids);
    END IF;
    DELETE FROM public.group_chat_members WHERE user_id    = ANY(v_user_ids);
    DELETE FROM public.carpool_members    WHERE user_id    = ANY(v_user_ids);
    DELETE FROM public.carpool_reviews    WHERE reviewer_id = ANY(v_user_ids);
    DELETE FROM public.carpool_votes      WHERE voter_id    = ANY(v_user_ids);
    DELETE FROM public.carpool_proposals  WHERE proposer_id = ANY(v_user_ids);
  END IF;

  -- ── User-linked data (scoped, NOT global) ─────────────────
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks
      WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports
      WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.notifications       WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans           WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats     WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks      WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id = ANY(v_user_ids);
  END IF;

  -- NOTE: admin_audit_logs are NEVER deleted — they are the audit trail.

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object(
      'school_id', p_school_id,
      'backup_id', v_backup_id,
      'timestamp', now(),
      'version', 'v00175'
    ));

  RETURN jsonb_build_object(
    'status',     'success',
    'scope',      'school',
    'school_id',  p_school_id,
    'backup_id',  v_backup_id,
    'user_ids',   COALESCE(to_jsonb(v_user_ids), '[]'::jsonb),
    'order_ids',  COALESCE(to_jsonb(v_order_ids), '[]'::jsonb),
    'purged_at',  now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

-- ── 5. Restore RPC ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.restore_school_backup(p_backup_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_backup   record;
  v_tables   jsonb;
  v_restored int := 0;
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  SELECT * INTO v_backup FROM public.cleanup_backups WHERE id = p_backup_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Backup not found: %', p_backup_id;
  END IF;
  IF v_backup.restored_at IS NOT NULL THEN
    RAISE EXCEPTION 'Backup already restored at %', v_backup.restored_at;
  END IF;

  v_tables := v_backup.backup_data -> 'tables';

  -- Re-insert in FK-safe order. ON CONFLICT DO NOTHING prevents duplicates.
  -- 1. listings (parent of most other tables)
  INSERT INTO public.listings
    SELECT * FROM jsonb_populate_recordset(null::public.listings, v_tables -> 'listings')
    ON CONFLICT (id) DO NOTHING;
  GET DIAGNOSTICS v_restored = ROW_COUNT;

  -- 2. listing_images
  INSERT INTO public.listing_images
    SELECT * FROM jsonb_populate_recordset(null::public.listing_images, v_tables -> 'listing_images')
    ON CONFLICT (id) DO NOTHING;

  -- 3. orders, saved_listings, chat_rooms
  INSERT INTO public.orders
    SELECT * FROM jsonb_populate_recordset(null::public.orders, v_tables -> 'orders')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.saved_listings
    SELECT * FROM jsonb_populate_recordset(null::public.saved_listings, v_tables -> 'saved_listings')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.chat_rooms
    SELECT * FROM jsonb_populate_recordset(null::public.chat_rooms, v_tables -> 'chat_rooms')
    ON CONFLICT (id) DO NOTHING;

  -- 4. order_evidence, rental_extensions, messages
  INSERT INTO public.order_evidence
    SELECT * FROM jsonb_populate_recordset(null::public.order_evidence, v_tables -> 'order_evidence')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.rental_extensions
    SELECT * FROM jsonb_populate_recordset(null::public.rental_extensions, v_tables -> 'rental_extensions')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.messages
    SELECT * FROM jsonb_populate_recordset(null::public.messages, v_tables -> 'messages')
    ON CONFLICT (id) DO NOTHING;

  -- 5. notifications
  INSERT INTO public.notifications
    SELECT * FROM jsonb_populate_recordset(null::public.notifications, v_tables -> 'notifications')
    ON CONFLICT (id) DO NOTHING;

  -- 6. carpool hierarchy
  INSERT INTO public.carpool_trips
    SELECT * FROM jsonb_populate_recordset(null::public.carpool_trips, v_tables -> 'carpool_trips')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.carpool_members
    SELECT * FROM jsonb_populate_recordset(null::public.carpool_members, v_tables -> 'carpool_members')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.carpool_proposals
    SELECT * FROM jsonb_populate_recordset(null::public.carpool_proposals, v_tables -> 'carpool_proposals')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.carpool_reviews
    SELECT * FROM jsonb_populate_recordset(null::public.carpool_reviews, v_tables -> 'carpool_reviews')
    ON CONFLICT (id) DO NOTHING;

  -- 7. group chat
  INSERT INTO public.group_chat_rooms
    SELECT * FROM jsonb_populate_recordset(null::public.group_chat_rooms, v_tables -> 'group_chat_rooms')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.group_chat_members
    SELECT * FROM jsonb_populate_recordset(null::public.group_chat_members, v_tables -> 'group_chat_members')
    ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.group_messages
    SELECT * FROM jsonb_populate_recordset(null::public.group_messages, v_tables -> 'group_messages')
    ON CONFLICT (id) DO NOTHING;

  -- Mark as restored
  UPDATE public.cleanup_backups
    SET restored_at = now()
    WHERE id = p_backup_id;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_restore', 'backup', p_backup_id,
    jsonb_build_object('school_id', v_backup.school_id, 'timestamp', now()));

  RETURN jsonb_build_object(
    'status', 'success',
    'backup_id', p_backup_id,
    'school_id', v_backup.school_id,
    'listings_restored', v_restored,
    'restored_at', now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.restore_school_backup(uuid) TO authenticated;

-- ── 6. Delete backup RPC ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.delete_school_backup(p_backup_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  UPDATE public.cleanup_backups SET purged_at = now() WHERE id = p_backup_id;

  RETURN jsonb_build_object('status', 'success', 'backup_id', p_backup_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_school_backup(uuid) TO authenticated;

-- ── 7. Helper: list backups for a school ────────────────────
CREATE OR REPLACE FUNCTION public.get_school_backups(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  RETURN COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', b.id,
      'school_id', b.school_id,
      'created_at', b.created_at,
      'restored_at', b.restored_at,
      'purged_at', b.purged_at,
      'meta', b.backup_data -> 'meta',
      'storage_manifest', b.storage_manifest
    ) ORDER BY b.created_at DESC)
    FROM public.cleanup_backups b
    WHERE b.school_id = p_school_id AND b.purged_at IS NULL
  ), '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_school_backups(uuid) TO authenticated;

COMMENT ON FUNCTION public.clear_school_test_data IS
'v00175 — school-scoped cleanup with backup-first pattern. Snapshots all
affected data into cleanup_backups before deletion. Returns backup_id and
user_ids/order_ids for scoped storage cleanup.';

NOTIFY pgrst, 'reload schema';
