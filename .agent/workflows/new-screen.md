---
description: 
---

# Workflow: New Screen

Use this when adding a single screen to an existing feature.

## Prerequisites
- Stitch MCP connected (for design system tokens only)
- Full-page screenshot of the screen ready
  (Chrome mobile mode 390px, bottom nav hidden if present)

## Steps

1. Ask the user:
   "请提供：
    a) 这个页面的全页截图
       （手机宽度 390px，已隐藏底部导航栏）
    b) 这个页面是否需要底部导航栏？（是/否）"

   Do not proceed without the screenshot.
   Do not fetch this page from Stitch — screenshot is the only
   visual reference.

2. Implement the screen:
   - Screenshot is the sole visual source of truth
   - Use Stitch design system tokens for exact color, spacing,
     and font values where they match what is visible
   - Do NOT add bottom nav bar at this stage
   - Add 80px bottom padding if this screen needs a bottom nav bar
   - Never estimate or invent any value
   - If anything is unclear from the screenshot or design system,
     stop and ask — never guess

3. Create screen file:
   lib/features/[feature]/screens/[screen_name]_screen.dart

4. Create feature-specific widgets if needed:
   lib/features/[feature]/widgets/

5. Wire up providers with ref.watch().
   Create new provider only if existing ones don't cover the need.

6. Add route to lib/core/router/router.dart.

7. Take a Browser screenshot.
   Compare against the provided screenshot.
   List all differences. Fix them. Screenshot again to confirm.
   Repeat until visually matched.

8. If user confirmed this screen needs a bottom nav bar:
   Import BottomNavBar from lib/shared/widgets/bottom_nav_bar.dart
   If that widget does not exist yet, inform the user and skip —
   it will be added in a dedicated bottom nav step.

9. Output: file path, route name, providers used,
   any values that required clarification.