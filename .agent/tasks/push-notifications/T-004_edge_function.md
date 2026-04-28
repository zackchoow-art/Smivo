# T-004: Supabase Edge Function — Push Notification Trigger

## Goal
Create a Supabase Edge Function that receives a Database Webhook payload when a notification is INSERTed, checks user push preferences, and sends a push via OneSignal REST API.

## Prerequisites
- T-001 done (user_profiles has onesignal_player_id and push preference columns)

## Boundary
### DO:
1. Create `supabase/functions/push-notification/index.ts`
2. Document the Database Webhook configuration steps

### DO NOT:
- Modify any Flutter/Dart code
- Modify any SQL migration files
- Modify iOS/Android configs
- Create actual Webhook in Supabase (manual step, document only)

## Implementation

### Create: `supabase/functions/push-notification/index.ts`

The Edge Function should:

1. Parse the incoming webhook payload (contains the new `notifications` row)
2. Extract `user_id`, `type`, `title`, `body` from the payload
3. Query `user_profiles` table for the target user:
   - Get `onesignal_player_id`
   - Get `push_notifications_enabled`, `push_messages`, `push_order_updates`
4. Check if push should be sent:
   - If `push_notifications_enabled` is false → skip
   - If notification type is message-related AND `push_messages` is false → skip
   - If notification type is order-related AND `push_order_updates` is false → skip
   - If `onesignal_player_id` is null → skip
5. Call OneSignal REST API:
   ```
   POST https://api.onesignal.com/notifications
   Authorization: Basic {ONESIGNAL_REST_API_KEY}
   Content-Type: application/json
   
   {
     "app_id": "{ONESIGNAL_APP_ID}",
     "include_subscription_ids": ["{onesignal_player_id}"],
     "headings": {"en": "{title}"},
     "contents": {"en": "{body}"},
     "data": {
       "type": "{notification_type}",
       "order_id": "{related_order_id}"
     }
   }
   ```
6. Return appropriate HTTP response

### Environment variables needed (set via Supabase Dashboard):
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`

### Notification type to preference mapping:
```
order_placed → push_order_updates
order_accepted → push_order_updates
order_cancelled → push_order_updates
order_delivered → push_order_updates
order_completed → push_order_updates
new_message → push_messages
system → push_notifications_enabled (master only)
```

### Database Webhook config (MANUAL — document in report):
- Table: `notifications`
- Event: `INSERT`
- Type: Supabase Edge Function
- Function: `push-notification`

## Verification
- Verify the TypeScript file has no syntax errors
- Document the manual Webhook setup steps clearly

## Report
Write to: `/Users/george/smivo/.agent/tasks/push-notifications/T-004_report.md`
