# Task T8 Report: Analytics & Feature Flags Update

## Objective
Implement missing WAU/MAU analytics metrics and audit/expose all application feature flags in the Admin Dashboard.

## Changes

### 1. Database (Supabase)
- Created migration `00131_active_user_metrics_rpc.sql` containing a new RPC function `get_active_user_metrics`.
- This function calculates rolling window active user counts:
    - **DAU**: Unique users in past 24 hours.
    - **WAU**: Unique users in past 7 days.
    - **MAU**: Unique users in past 30 days.
- Supports school-scoped filtering for use on the dashboard.

### 2. Admin Dashboard (Hooks)
- Updated `useAnalytics.ts` to fetch rolling DAU/WAU/MAU and include them in the KPI data.
- Updated `useDashboard.ts` to replace the calendar-day DAU with the new rolling window active user metrics.

### 3. Admin Dashboard (UI)
- **Analytics Page**: Added KPI cards for "DAU (24h)", "WAU (7d)", and "MAU (30d)".
- **Dashboard Page**: Added KPI cards for "DAU (24h)", "WAU (7d)", and "MAU (30d)" to the main stats grid.
- **Feature Flags Page**: 
    - Audited the codebase for `system_settings` and `system_configs` usage.
    - Unified both tables into a single management view.
    - Added source metadata (Table name and column) to each flag description.
    - Supported boolean toggling for items in `system_configs`.

## Verified
- Database migration executed successfully.
- `npx tsc -b` passed with 0 errors.
- Verified all identified keys are present in the UI.

## Identified Flags/Configs
| Key | Source Table | Description |
|-----|--------------|-------------|
| `presence.enabled` | `system_settings` | Enable user online status tracking |
| `presence.show_online_dot` | `system_settings` | Show green dot for online users |
| `moderation.strict_mode` | `system_settings` | Require listings review before going live |
| `registration.enabled` | `system_settings` | Allow new user registration |
| `wishlist.enabled` | `system_settings` | Enable wishlist / bottle drift feature |
| `plaza.enabled` | `system_settings` | Enable community plaza feature |
| `ai_moderation_enabled` | `system_configs` | Enable AI secondary review for listings |
| `ai_provider` | `system_configs` | AI provider to use (openai, google) |
| `image_moderation_mode` | `system_configs` | AI moderation policy (blur vs reject) |
| `content_filter.warn_message` | `system_configs` | Warning message shown for flagged content |
