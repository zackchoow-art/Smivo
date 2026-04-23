# Design System Specification

## 1. Overview & Creative North Star: "The Democratic Architect"
This design system is built upon the philosophy that high-end design should be accessible, practical, and undeniably functional. Moving beyond a "standard" marketplace interface, we are adopting the persona of **The Democratic Architect**. 

The goal is to evoke the feeling of a well-organized Scandinavian workshop: clean, light-filled, and modular. We break the "generic app" mold by utilizing intentional asymmetry in layout, extreme typographic scales, and a departure from traditional structural lines. We don't use lines to separate ideas; we use space and tonal shifts to define boundaries.

---

## 2. Colors & Surface Architecture
The palette leverages the iconic high-contrast pairing of deep blues and vibrant yellows, tempered by a sophisticated range of architectural grays.

### Core Palette
- **Primary (The Authority):** `primary` (#004181) and `primary_container` (#0058ab). Used for primary actions and brand presence.
- **Secondary (The Accent):** `secondary_container` (#fdd816). Reserved for high-attention callouts, promotions, or "Actionable Interest."
- **Tertiary (The Tactile):** `tertiary` (#702d00). Used sparingly for warmth and organic contrast.

### The "No-Line" Rule
To achieve a premium editorial feel, **1px solid borders are prohibited for sectioning.** Boundaries must be defined solely through background color shifts or subtle tonal transitions.
- Use `surface` (#f9f9f9) for the base background.
- Use `surface_container_low` (#f3f3f3) for secondary content blocks.
- Use `surface_container_highest` (#e2e2e2) to signal a nested, interactive area.

### Surface Hierarchy & Nesting
Think of the UI as a series of physical materials.
- **Base Layer:** `surface`.
- **Section Layer:** `surface_container`.
- **Component Layer:** `surface_container_lowest` (Pure White #ffffff).
By placing a "lowest" (brightest) card on a "low" (soft gray) background, we create a "natural lift" that feels more premium than a digital drop shadow.

### The "Glass & Gradient" Rule
While the brand is practical, we inject "visual soul" through:
- **Glassmorphism:** Use `surface_container_lowest` at 80% opacity with a `20px backdrop-blur` for floating navigation bars or headers.
- **Signature Gradients:** For primary CTAs, use a subtle linear gradient from `primary` to `primary_container` (Top-Left to Bottom-Right) to provide a soft, 3D volume that flat color lacks.

---

## 3. Typography
We utilize **Plus Jakarta Sans** for its robust, clean, yet approachable character. The hierarchy is designed to feel editorial and authoritative.

| Level | Size | Weight | Usage |
| :--- | :--- | :--- | :--- |
| **display-lg** | 3.5rem | Bold | Large hero marketing statements. |
| **headline-md** | 1.75rem | SemiBold | Major section headers. |
| **title-sm** | 1.0rem | Bold | Product titles and card headers. |
| **body-md** | 0.875rem | Regular | Descriptions and primary metadata. |
| **label-md** | 0.75rem | Bold | All-caps utility labels (Category, Status). |

**Editorial Contrast:** Pair a `label-md` (bold, uppercase) directly above a `display-sm` headline to create a sophisticated, "designed" look that breaks the standard vertical rhythm.

---

## 4. Elevation & Depth
Depth in this system is achieved through **Tonal Layering** rather than structural lines.

- **The Layering Principle:** Stack surfaces to define importance. A `surface_container_lowest` (#ffffff) card sitting on a `surface_container` (#eeeeee) background creates an immediate focal point.
- **Ambient Shadows:** For floating elements (Modals, FABs), use extra-diffused shadows.
    - *Shadow:* `x:0, y:8, blur:24, spread:-4`
    - *Color:* `on_surface` (#1a1c1c) at 6% opacity. This mimics natural ambient light.
- **The "Ghost Border" Fallback:** If a container requires definition against a similar background (e.g., an image container), use a "Ghost Border": `outline_variant` (#c2c6d3) at **15% opacity**. Never use 100% opaque borders.

---

## 5. Components

### Buttons (Blocky & Authoritative)
- **Primary:** `primary` background, `on_primary` text. Rectangular with `DEFAULT` (0.25rem) radius. High contrast is mandatory.
- **Secondary:** `secondary_container` background, `on_secondary_container` text. Use for "Add to Cart" or "Contact Seller."
- **Tertiary:** No background. Bold text with `primary` color and a `Ghost Border`.

### Cards & Lists
- **Rule:** Forbid the use of divider lines.
- **Execution:** Separate list items using 8px of vertical whitespace or by alternating background tones between `surface` and `surface_container_low`.
- **Cards:** Use `surface_container_lowest` with no border and a soft ambient shadow on hover.

### Input Fields
- **Style:** Large, blocky containers using `surface_container_highest`. 
- **Active State:** Change background to `surface_container_lowest` and add a 2px `primary` bottom-border only. This maintains the "architectural" grid.

### Navigation (The Bottom Bar)
- **Style:** Use a `surface_container_lowest` background with a 10% `outline_variant` top "Ghost Border."
- **Active State:** The active icon should be housed in a `secondary_container` (Yellow) pill-shaped container to provide a clear, "utilitarian" highlight.

---

## 6. Do's and Don'ts

### Do
- **Use "White Space" as a Tool:** Give elements 32px+ of breathing room to maintain the Scandinavian "airy" feel.
- **Embrace Asymmetry:** Align text to the left but allow images to bleed to the edge of the screen to break the "grid-box" feel.
- **Prioritize Legibility:** Ensure `on_surface` text always meets WCAG AAA contrast ratios against surface colors.

### Don't
- **Don't Use Dividers:** Never use a 1px line to separate items in a list. Use space.
- **Don't Over-Round:** Avoid the "pill" shape for buttons (except for selection chips). Keep the corners architectural (`DEFAULT` or `md` radius).
- **Don't Use Pure Black:** Always use `on_surface` (#1a1c1c) for text to keep the interface feeling sophisticated rather than "harsh."
- **Don't Use Generic Shadows:** Never use heavy, dark, or tight drop shadows. If it looks "computer-generated," it's wrong.