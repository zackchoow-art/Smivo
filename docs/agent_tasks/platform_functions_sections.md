# Agent Task: Platform Functions Sections & Page Cleanup

## Task Overview

Implement the content for 7 sections in `PlatformFunctionsPage.tsx` and perform
cleanup on renamed/refactored pages. The skeleton page and routing are already
complete — your job is to **fill in each section** with functional UI components.

---

## Architecture Context

### Key Files You Need

| File | Purpose |
|------|---------|
| `admin/src/pages/settings/PlatformFunctionsPage.tsx` | Skeleton page — replace `SectionPlaceholder` with real components |
| `admin/src/hooks/useDictionary.ts` | Loads dict items from `system_dictionaries` table |
| `admin/src/hooks/useFeatureFlags.ts` | Loads toggles from `system_settings` table |
| `admin/src/hooks/useSystemConfigs.ts` | Loads configs from `system_configs` table |
| `admin/src/pages/settings/DictionaryListPage.tsx` | Current dictionary list — will become School Settings |
| `admin/src/pages/settings/SystemConfigsPage.tsx` | Current Platform Settings — will become Content Moderation |
| `admin/src/pages/settings/FeatureFlagsPage.tsx` | Old page — no longer routed but keep file for reference |

### Available Hooks

```typescript
// Dictionary items (by dict_type)
import { useDictionary } from '@/hooks/useDictionary';
const { items, isLoading, create, update, remove } = useDictionary('order_status');

// Feature Flags (system_settings table — boolean toggles)
import { useFeatureFlags, useToggleFlag } from '@/hooks/useFeatureFlags';
const { data: flags, isLoading } = useFeatureFlags();
const toggleFlag = useToggleFlag(); // toggleFlag.mutate({ key, value })

// System Configs (system_configs table — string/JSON values)
import { useSystemConfigs, useUpdateSystemConfig } from '@/hooks/useSystemConfigs';
const { data: configs, isLoading } = useSystemConfigs();
const updateConfig = useUpdateSystemConfig(); // updateConfig.mutate({ key, value })
```

### DICT_REGISTRY (all registered dict_types)

The dict_types and their access levels:

**Platform-level (admin-editable):**
- `order_status` — Order Statuses
- `rental_status` — Rental Statuses  
- `listing_status` — Listing Statuses
- `transaction_type` — Transaction Types
- `notification_type` — Notification Types
- `feedback_resolution` — Feedback Resolutions
- `review_tag` — Review Tags
- `system_url` — System URLs
- `feedback_type` — Feedback Types
- `report_type` — Report Types
- `report_resolution` — Report Resolutions
- `punishment_type` — Punishment Types

**System-level (sysadmin-only):**
- `moderation_status` — Moderation Statuses

**School-level (school admin editable):**
- `category` — Product Categories
- `condition` — Item Conditions
- `pickup_location` — Pickup Locations

### Feature Flags in `system_settings` table

Key flags relevant to Platform Functions:
- `presence.enabled` — Online presence
- `presence.show_online_dot` — Show online dot
- `feedback.enabled` — User feedback
- `auto_accept_message_enabled` — Auto-accept messaging
- `registration.enabled` — New user registration
- `moderation.strict_mode` — Strict moderation
- `plaza.enable` — Community plaza
- `wishlist.enable` — Wishlists
- `wishlist.cross_school` — Cross-school wishlists

### System Configs in `system_configs` table

Key configs relevant to Platform Functions:
- `auto_accept_message.template` — Message template text
- `user_report.enabled` — User reports toggle (string 'true'/'false')
- `test_user.registration_enabled` — Test user registration
- `test_user.login_enabled` — Test user login
- `content_filter.warn_message` — Content filter warning
- `image_moderation_mode` — Image moderation mode

---

## Part 1: Section Components

Create each section as an inline component within `PlatformFunctionsPage.tsx`,
or as separate files imported into it. Choose based on complexity.

### Section 1: Orders

Replace `<SectionPlaceholder sectionId="orders" />` with content showing:

1. **Dictionary Tables**: Read-only tables for `order_status`, `rental_status`, 
   `listing_status`, `transaction_type`, `moderation_status`.
   - Each shows: Code, Label, Description, Status badge (active/inactive)
   - Use a mini table per dict_type with the dict_type title as sub-heading
   
2. **Auto Accept Message Toggle**: A toggle switch reading from `useFeatureFlags()`
   for key `auto_accept_message_enabled`
   
3. **Auto Accept Message Template**: A text area reading from `useSystemConfigs()`
   for key `auto_accept_message.template`, with save button.

### Section 2: Notification  

Replace `<SectionPlaceholder sectionId="notification" />` with:

1. **Notification Types Table**: Dictionary table for `notification_type`
   - Show: Code, Label, Description

### Section 3: Feedback & Review

Replace `<SectionPlaceholder sectionId="feedback" />` with:

1. **Feedback Enable Toggle**: From `useFeatureFlags()` key `feedback.enabled`
2. **Feedback Types Table**: Dictionary for `feedback_type`
3. **Feedback Shortcuts**: From `useSystemConfigs()` key `feedback_shortcuts`
   (if exists — show as editable list)
4. **Feedback Resolutions Table**: Dictionary for `feedback_resolution`
5. **Review Tags Table**: Dictionary for `review_tag`

### Section 4: User Reports

Replace `<SectionPlaceholder sectionId="reports" />` with:

1. **Enable Reports Toggle**: From `useSystemConfigs()` key `user_report.enabled`
2. **Report Types Table**: Dictionary for `report_type`
3. **Report Resolutions Table**: Dictionary for `report_resolution`

### Section 5: User Punishment

Replace `<SectionPlaceholder sectionId="punishment" />` with:

1. **Punishment Types Table**: Dictionary for `punishment_type`
   - Show extra fields: icon, color, reply_template

### Section 6: System

Replace `<SectionPlaceholder sectionId="system" />` with:

1. **System URLs Table**: Dictionary for `system_url`
2. **Allow New User Registration**: Toggle from `useFeatureFlags()` key `registration.enabled`
3. **Allow Test User Registration**: Config from `useSystemConfigs()` key `test_user.registration_enabled`
4. **Allow Test User Login**: Config from `useSystemConfigs()` key `test_user.login_enabled`
5. **Presence Enabled**: Toggle from `useFeatureFlags()` key `presence.enabled`
6. **Presence Show Online Dot**: Toggle from `useFeatureFlags()` key `presence.show_online_dot`

### Section 7: Coming Soon

Replace `<SectionPlaceholder sectionId="coming-soon" />` with:

1. A styled read-only list of upcoming features:
   - Moderation Strict Mode (`moderation.strict_mode`)
   - Plaza (`plaza.enable`)
   - Wishlist (`wishlist.enable`)
   - Wishlist Cross School (`wishlist.cross_school`)
   - Listing Cross School (`listing.cross_school` in system_settings)
2. Each item shows: name, current value, description, and a "Coming Soon" badge

---

## Part 2: Dictionary Table Component

Create a reusable `DictTable` component that accepts a `dictType` string and renders:

```
┌──────────────────────────────────────────────┐
│ [Title]                    [Edit] button      │
├────────┬──────────┬──────────────┬───────────┤
│ Code   │ Label    │ Description  │ Status    │
├────────┼──────────┼──────────────┼───────────┤
│ ...    │ ...      │ ...          │ ●Active   │
└────────┴──────────┴──────────────┴───────────┘
```

- Clicking "Edit" navigates to `/settings/school-settings/{dictType}` for inline editing
- For platform/system level dicts, show the table inline with read-only view
- Use existing `DICT_REGISTRY` metadata for title and description

---

## Part 3: Toggle Component

Create a reusable `FlagToggle` component:

```typescript
interface FlagToggleProps {
  label: string;
  description: string;
  checked: boolean;
  onChange: (value: boolean) => void;
  disabled?: boolean;
  source: {
    table: string;    // 'system_settings' or 'system_configs'
    key: string;      // the config key
  };
}
```

- Shows toggle with label + description
- Shows source info (which table/key) in small text below
- Disabled if user doesn't have edit permission

---

## Part 4: Page Cleanup

### 4.1 DictionaryListPage.tsx → School Settings

Update `DictionaryListPage.tsx`:
- Change the page title from "Data Dictionary" to "School Settings"
- Change subtitle to describe school-specific settings
- Filter the displayed dict_types to only show `access_level === 'school'`
  (category, condition, pickup_location)
- Keep all existing CRUD functionality

### 4.2 SystemConfigsPage.tsx → Content Moderation

Update `SystemConfigsPage.tsx`:
- Change page title to "Content Moderation"
- Remove the "Feature Flags" tab (`flags` tab and its content)
- Keep tabs: Content Moderation (configs), Image Moderation, Sensitive Words
- Add `content_filter.warn_message` editing in the configs tab
  (show as text area in the App-side settings section)
- Add `image_moderation_mode` as a select dropdown in the Server-side section
  with options: 'off', 'openai', 'google_vision', 'both'

---

## UI Design Guidelines

1. **Consistency**: Use existing CSS variables (--color-*, --radius-*, etc.)
2. **Spacing**: Use the `pf-section__body` as parent — add 16px margin-top for content
3. **Tables**: Use simple `<table>` with consistent styling matching the rest of admin
4. **Toggles**: Use the same toggle style as FeatureFlagsPage
5. **Badges**: Active = green, Inactive = gray, Coming Soon = blue

---

## Verification Checklist

After completing all changes:
1. Run `cd admin && npx tsc -b` — must have ZERO errors
2. Verify all 7 sections render without errors
3. Verify School Settings page only shows school-level dicts
4. Verify Content Moderation page no longer has Feature Flags tab
5. Verify no broken imports (all old paths have redirects in router.tsx)

---

## Report Format

After completion, create a report at `docs/agent_tasks/platform_functions_report.md`:

```markdown
# Platform Functions Implementation Report

## Completed
- [ ] Section 1: Orders — X sub-items
- [ ] Section 2: Notification — X sub-items
- [ ] Section 3: Feedback & Review — X sub-items
- [ ] Section 4: User Reports — X sub-items
- [ ] Section 5: User Punishment — X sub-items
- [ ] Section 6: System — X sub-items
- [ ] Section 7: Coming Soon — X sub-items
- [ ] DictionaryListPage → School Settings
- [ ] SystemConfigsPage → Content Moderation
- [ ] tsc -b passes

## Files Modified
- list each file

## Known Issues
- any issues discovered

## Screenshots
- describe what each section looks like
```
