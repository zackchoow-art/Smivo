# Smivo Design System (The Academic Pulse)

## 1. Color Palette & Tones
- **Primary (Trust Anchor):** `#006067`
- **Primary Container:** `#007b83`
- **Secondary (Energy Bursts):** `#8b5000`
- **Secondary Container (High Conversion/Sale):** `#ff9800`
- **Tertiary:** `#6f5200`
- **Background Base:** `#f6fafa`
- **Surface Container Low (Sections):** `#f1f4f4`
- **Surface Container Lowest (Primary Cards):** `#ffffff`
- **Surface Bright (Modals/Interactions):** `#f6fafa`
- **On Surface (Text):** `#181c1d`
- **Outline Variant (Ghost Borders):** `#bdc9ca` (Use at max 20% opacity)
- **Error:** `#ba1a1a`
- **Signature Gradient:** Linear gradient from `#006067` to `#007b83` at 135-degree angle.

## 2. Typography Scale
- **Display & Headline (The Voice):** Plus Jakarta Sans
  - E.g., `display-lg` (3.5rem / 56px) with -0.02em letter spacing.
- **Body, Title, Label (The Narrative):** Manrope
  - Used for readability in descriptions, labels, and regular text.

## 3. Spacing & Layout
- **Spacing Scale:** 2
- **White Space Rules:** 
  - No 1px solid dividers.
  - Use `1.5rem` to `2rem` (24px to 32px) of vertical space to separate items.
- **Scrollable Area Padding:** Add `80px` bottom padding to reserve space for the bottom nav bar.
- **Grid Layout:** Embrace asymmetric grids (offset images from descriptions).

## 4. Border Radius (Corners)
- **Base Roundness:** 8px (`ROUND_EIGHT`)
- **Product Images & Input Fields:** `md` (0.75rem / 12px)
- **Primary Buttons:** `xl` (1.5rem / 24px) or `full` (9999px)
- **Verification Badges & Energy Chips:** `full` (9999px)

## 5. Shadows & Elevation
- **Primary Elevation Principle:** Tonal layering (e.g., `#ffffff` stacked on `#f1f4f4`), avoiding heavy drop shadows.
- **Ambient Shadows (Floating Elements/FABs):**
  - Blur: `32px` to `64px` (extra-diffused)
  - Opacity: `4%` to `8%`
  - Color: `#181c1d` (tinted on-surface, no pure black)
- **Glassmorphism (Top Bars / Floating Nav):** 80% opacity surface color with `20px` backdrop blur.

## 6. UI Components
- **Primary Buttons:** Gradient `#006067` to `#007b83`, `full` or `xl` rounded, `#ffffff` text.
- **Secondary Buttons:** `#e5e9e9` (surface_container_high) background, `#006067` text, no border.
- **Input Fields:** `#f1f4f4` (low) fill, transitioning to `#ffffff` (lowest) with a ghost border (`#006067`) on focus, 12px rounded.
- **Cards:** No dividers. Images inset slightly to frame content.
- **Verification Badge:** Small floating glassmorphic pill with `#006067` checkmark.
