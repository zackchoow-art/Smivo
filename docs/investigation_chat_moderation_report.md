# Investigation Report: Chat Image Moderation Inconsistency

## 1. Executive Summary
This report documents the findings regarding the failure of the automated image blurring mechanism in `ChatRoomScreen` and `ChatPopup`. While the UI components correctly utilize the `ModerationAwareImage` widget, several architectural bottlenecks in the data propagation layer prevent flagged images from being reliably obscured.

## 2. Technical Findings

### 2.1 Stale Blacklist Cache (Provider Limitations)
The `FlaggedImageUrls` provider (in `app/lib/core/providers/moderation_provider.dart`) is responsible for providing the UI with a map of URLs that should be blurred.
- **Limit/Ordering Bug**: The provider fetches a maximum of 500 records from `backend_moderation_logs` without any `order` clause. In a production environment with many listings, chat images (especially recent ones) are often excluded from this random 500-record snapshot.
- **Persistence Issue**: The provider uses `keepAlive: true` and loads only once at session start. It does not listen to real-time changes in the logs, meaning any image moderated *during* the current session will remain unblurred until the app is restarted.

### 2.2 Loading State Vulnerability (Race Condition)
The `ModerationAwareImage` widget and the `ChatRoomScreen` build logic handle the `loading` state of the flagged URL provider insecurely:
- **Default to "Clean"**: If the provider is still fetching data (common during the first few seconds of app launch), `ModerationAwareImage` defaults to `isFlagged = false`, rendering the image in high fidelity.
- **Fullscreen Gallery Leak**: `ChatRoomScreen` calculates a `validImageUrls` list for the fullscreen viewer. If the provider is loading, this list falls back to an empty filter, allowing violating images to be swiped through in high resolution.

### 2.3 URL Matching Precision
The system relies on an exact string match between the `image_url` in the `messages` table and the `content_snapshot`/`url` in the `backend_moderation_logs`. Any discrepancy (e.g., protocol differences or query parameters) would cause a lookup failure. However, current investigation suggests the cache limit and ordering are the primary culprits.

## 3. Config/Flag Audit

| Config Key | Location | Current State | Usage |
| :--- | :--- | :--- | :--- |
| `image_moderation_mode` | `system_configs` | `blur` | Controls UI behavior (blur vs. remove). |
| `ai_action_on_hit` | `system_configs` | `blur` | Controls Edge Function action on violation. |
| `moderation.strict_mode` | `system_settings` | `false` | **Unused**. No logic currently references this key. |

## 4. Conclusion
The moderation architecture is correctly integrated at the UI level (`ModerationAwareImage`), but it fails due to a **stale and non-ordered data provider**. The 500-record limit and lack of real-time invalidation create a significant gap where recent violations are invisible to the client-side enforcement logic.

---
*Report generated on 2026-05-09*
