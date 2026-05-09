-- ============================================================
-- Reprocess stuck moderation tasks
-- ============================================================
-- After fixing webhook auth (migration 00128 + --no-verify-jwt),
-- reprocess the 7 tasks that were stuck in 'pending'.
--
-- Strategy: DELETE old pending tasks, then re-INSERT to trigger
-- the AFTER INSERT webhook again.
-- ============================================================

BEGIN;

-- 1. Save the pending task targets before deletion
CREATE TEMP TABLE _pending_targets AS
SELECT target_type, target_id
FROM moderation_tasks
WHERE status = 'pending';

-- 2. Delete the stuck pending tasks
DELETE FROM moderation_tasks WHERE status = 'pending';

-- 3. Re-insert to trigger webhook
INSERT INTO moderation_tasks (target_type, target_id)
SELECT target_type, target_id FROM _pending_targets;

-- 4. Clean up
DROP TABLE _pending_targets;

COMMIT;

-- Verify: show the new tasks
SELECT id, target_type, target_id, status, created_at
FROM moderation_tasks
WHERE status = 'pending'
ORDER BY created_at DESC;
