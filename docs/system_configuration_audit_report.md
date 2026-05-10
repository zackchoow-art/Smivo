# Smivo System Configuration Audit & Optimization Strategy Report
Date: 2026-05-09
Author: Antigravity AI Agent
Status: Final (Audit + Implementation Strategy)

---

## 1. Executive Summary
This report combines a comprehensive audit of hardcoded configurations across the Smivo platform and a strategic memorandum for migrating to a database-driven, "Zero-Code" architecture. The goal is to eliminate high-friction update cycles and empower the platform with real-time operational agility.

---

## 2. Audit Findings: Hardcoded Configurations

### A. App Side (Frontend)
- **Feedback Category Options**: **HARDCODED**
  - File: `app/lib/features/settings/screens/submit_feedback_screen.dart`
  - Scope: The list `['bug', 'improvement', 'feature_request', 'other']` is fixed in the UI.
- **Report Category Options (Listing/Chat)**: **HARDCODED**
  - File: `app/lib/shared/widgets/report_dialog.dart`
  - Scope: Categories like `spam`, `harassment`, `fraud` are hardcoded in the dialog map.

### B. Admin Side & Backend
- **System Notification Content**:
  - **Order Auto-Messages**: **HARDCODED** in the `order-accepted-message` Edge Function.
  - **Penalty Notifications**: **HARDCODED** in Admin React code.
    - Files: `useChatReports.ts`, `ListingReportDetailPage.tsx`. The titles and bodies (e.g., "Account Restriction Applied") are defined as static strings.
- **Punishment Scopes**: **DATABASE HARDCODED** via `CHECK` constraints.
  - Table: `public.user_bans` (scope). Adding new restriction types requires SQL migrations.
- **Feedback & Report Resolutions**: **MIXED**
  - Shortcuts: Stored in `system_configs` JSON (Dynamic).
  - Status Definitions: Stored in `system_dictionaries` (Dynamic).

---

## 3. Risk Assessment

| Risk Item | Impact | Priority |
| :--- | :--- | :--- |
| **App Hardcoding** | Requires App Store update (2-3 days) to change categories. High friction for compliance updates. | **HIGH** |
| **Penalty Text Hardcoding** | Admin cannot edit the tone or content of penalty notifications without an Admin Dashboard deployment. | **HIGH** |
| **Database Constraints** | New types of user restrictions cannot be added at runtime, limiting moderation flexibility. | **MEDIUM** |
| **Localization Barrier** | Hardcoded strings in code make future multi-language support (i18n) significantly harder. | **MEDIUM** |

---

## 4. Implementation Memorandum: Transitioning to Zero-Code

### 4.1 Proposed Architecture: Dictionary-Driven UI
**Concept**: Shift from static lists to a centralized Dictionary-Driven logic.
- **Action**: Use the existing `system_dictionaries` table to house all App categories.
- **App Side**: Implement a `DictionaryCacheProvider` to fetch `report_category` and `feedback_type` on startup.
- **Benefit**: Categories can be updated instantly via the Admin Dashboard.

### 4.2 Template Engine for Notifications
**Concept**: Decouple business logic from content strings.
- **Action**: Create a `system_templates` table.
- **Mechanism**: Edge Functions and Admin UI should call templates by `key` (e.g., `TEMPLATE_PENALTY_WARN`).
- **Support**: Allow dynamic placeholders like `{{user_name}}` or `{{listing_title}}`.

### 4.3 Database Schema Decoupling
**Concept**: Move from physical constraints to logical metadata.
- **Action**: Remove `CHECK` constraints on `scope` fields.
- **Replacement**: Use a foreign key reference to a `restriction_metadata` table.

---

## 5. Implementation Roadmap (Suggested)

1.  **Phase 1 (Quick Wins)**: Migrate App-side report/feedback categories to `system_dictionaries`.
2.  **Phase 2 (Control)**: Implement the Notification Template system for Edge Functions.
3.  **Phase 3 (Full Agility)**: Build the "System Configuration Manager" in the Admin Dashboard to allow non-technical staff to edit these items safely.

---

## 6. Conclusion
The Smivo platform is architecturally ready for this transition as most underlying tables (`system_dictionaries`, `system_configs`) already exist. Decoupling the remaining hardcoded elements will significantly reduce operational overhead and improve the platform's ability to respond to community moderation needs.
