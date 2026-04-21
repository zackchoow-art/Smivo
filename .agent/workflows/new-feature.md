---
description: 
---

# Workflow: New Feature

Use this workflow when building a new feature end-to-end.

## Prerequisites
- Stitch MCP connected in Antigravity (for design system values only)
- Full-page screenshots ready for each screen in this feature
  (captured in Chrome mobile mode 390px width, bottom nav hidden)
- One separate screenshot of the bottom nav bar design (if applicable)

## Phase 1: Design System (run once per project, skip if already done)

Fetch the global design system from Stitch MCP:
  "Use Stitch MCP to fetch the Smivo design system.
   Extract and confirm: color palette, typography scale,
   spacing values, border radius, and shadow styles.
   Save these as the single source of truth for all
   design token decisions throughout the project."

Do NOT fetch any specific page designs from Stitch.
Page designs come from screenshots only.

## Phase 2: Build Screens (no bottom nav yet)

For each screen in this feature, repeat these steps:

1. Ask the user:
   "请提供这个页面的全页截图
   （手机宽度 390px，已隐藏底部导航栏）"
   Do not proceed without the screenshot.

2. Implement the screen using the screenshot as the sole visual reference:
   - The screenshot is the final judge — match it exactly
   - Use Stitch design system tokens for exact values where visible
     (colors, spacing, fonts) — never estimate or invent values
   - Do NOT add a bottom navigation bar at this stage
   - Add 80px bottom padding to all scrollable content areas
     to reserve space for the nav bar added later
   - Do not add, remove, or reorder any UI element
   - If any value cannot be determined from the screenshot or
     design system, stop and ask — never guess

3. Create all required files:
   lib/features/[feature]/screens/[screen]_screen.dart
   lib/features/[feature]/widgets/ (feature-specific widgets)
   lib/features/[feature]/providers/[feature]_provider.dart
   lib/data/models/[model].dart (freezed)
   lib/data/repositories/[feature]_repository.dart

4. Run: dart run build_runner build

5. Register route in lib/core/router/router.dart

6. Take a Browser screenshot.
   Compare side by side against the provided screenshot.
   List every visible difference (spacing, color, font, layout).
   Fix all differences. Screenshot again to confirm.
   Repeat until no visible differences remain.

## Phase 3: Bottom Navigation Bar (after ALL screens are complete)

Only run this phase when every screen in this feature is done.

1. Ask the user:
   "请提供底部导航栏的截图，
    以及需要显示导航栏的页面列表。"

2. Create the shared widget:
   lib/shared/widgets/bottom_nav_bar.dart
   - Use GoRouter for tab navigation
   - Fixed at bottom of screen
   - Match the screenshot exactly

3. Add BottomNavBar only to screens explicitly listed by the user.
   Do NOT add it to: auth screens, detail screens, post screen,
   settings screen, or any screen not in the confirmed list.

4. Screenshot each updated screen to confirm correct placement.

## Phase 4: Output Summary

List every file created, routes registered, and any values
that required clarification and how they were resolved.