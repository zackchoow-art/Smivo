-- ============================================================
-- Debug: AI Moderation Pipeline Diagnosis
-- ============================================================
-- This script checks the complete moderation pipeline to find
-- where the flow is breaking.

-- 1. Check if backend_review.enabled is true
SELECT config_key, config_value, description
FROM system_configs
WHERE config_key LIKE 'backend_review%'
   OR config_key LIKE 'ai_%'
   OR config_key LIKE 'content_filter%';

-- 2. Check moderation_tasks table: are tasks being created?
SELECT 
  target_type,
  status,
  COUNT(*) as cnt,
  MIN(created_at) as earliest,
  MAX(created_at) as latest
FROM moderation_tasks
GROUP BY target_type, status
ORDER BY target_type, status;

-- 3. Show recent moderation_tasks (last 20)
SELECT id, target_type, target_id, status, error_message, created_at, processed_at
FROM moderation_tasks
ORDER BY created_at DESC
LIMIT 20;

-- 4. Check backend_moderation_logs: are logs being created?
SELECT 
  target_type,
  engine,
  result,
  action_taken,
  COUNT(*) as cnt,
  MAX(created_at) as latest
FROM backend_moderation_logs
GROUP BY target_type, engine, result, action_taken
ORDER BY target_type, latest DESC;

-- 5. Show recent listings and their moderation status
SELECT id, title, moderation_status, created_at
FROM listings
ORDER BY created_at DESC
LIMIT 10;

-- 6. Show recent image messages and check if they have moderation tasks
SELECT m.id, m.message_type, m.image_url IS NOT NULL as has_image_url, 
       m.created_at,
       mt.id as task_id, mt.status as task_status
FROM messages m
LEFT JOIN moderation_tasks mt ON mt.target_id = m.id AND mt.target_type = 'message'
WHERE m.message_type = 'image'
ORDER BY m.created_at DESC
LIMIT 20;

-- 7. Check pg_net extension status
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_net';

-- 8. Check if the triggers exist
SELECT tgname, tgenabled, tgrelid::regclass
FROM pg_trigger
WHERE tgname IN ('on_listing_insert_moderate', 'on_message_insert_moderate', 'on_moderation_task_webhook');

-- 9. Check net._http_response for recent webhook calls (if pg_net is available)
SELECT id, status_code, created, url_path
FROM net._http_response
ORDER BY created DESC
LIMIT 20;
