---
name: Scribbly
colors:
  surface: '#fbf8ff'
  surface-dim: '#dbd9e2'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f2fc'
  surface-container: '#efedf6'
  surface-container-high: '#e9e7f0'
  surface-container-highest: '#e3e1ea'
  on-surface: '#1a1b22'
  on-surface-variant: '#454652'
  inverse-surface: '#2f3037'
  inverse-on-surface: '#f2eff9'
  outline: '#757684'
  outline-variant: '#c5c5d4'
  surface-tint: '#4355b9'
  primary: '#24389c'
  on-primary: '#ffffff'
  primary-container: '#3f51b5'
  on-primary-container: '#cacfff'
  inverse-primary: '#bac3ff'
  secondary: '#006a60'
  on-secondary: '#ffffff'
  secondary-container: '#85f6e5'
  on-secondary-container: '#007166'
  tertiary: '#6c3400'
  on-tertiary: '#ffffff'
  tertiary-container: '#8f4700'
  on-tertiary-container: '#ffc7a2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105c'
  on-primary-fixed-variant: '#293ca0'
  secondary-fixed: '#85f6e5'
  secondary-fixed-dim: '#67d9c9'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb784'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#713700'
  background: '#fbf8ff'
  on-background: '#1a1b22'
  surface-variant: '#e3e1ea'
typography:
  display:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 12px
  margin-mobile: 16px
  margin-tablet: 24px
---

## Brand & Style
This design system establishes a premium, utility-focused environment for high-performance productivity. The brand personality is disciplined yet approachable, characterized by a "quiet" interface that recedes to prioritize user content. 

The aesthetic is a refined evolution of **Material 3**, leaning heavily into **Minimalism** with a **Corporate/Modern** backbone. It utilizes a compact layout strategy to enable high information density without sacrificing clarity. The emotional response should be one of "calm focus"—an organized workspace that feels both high-end and highly functional.

## Colors
The color strategy employs a "neutral-first" approach. **White (#FFFFFF)** serves as the primary canvas, while **Light Gray (#F5F5F5)** differentiates surface levels and containers. **Charcoal (#333333)** provides high-legibility text contrast.

**Indigo (#3F51B5)** acts as the primary brand signal for high-emphasis actions and active states. The secondary **Teal (#009688)** is reserved for success states or specific "Canvas" related features. The accent palette (Amber, Coral, Sage) is used sparingly for categorization (e.g., Task priority, File tags) to maintain the minimal aesthetic while providing functional visual cues.

## Typography
**Inter** is selected for its exceptional legibility at small sizes, which is critical for a high-density productivity app. 

The scale is tightly knit. Use `display` only for empty-state hero text. `headline-md` and `title-lg` are the primary anchors for screen headers and card titles. `body-md` is the workhorse for task descriptions and note previews. To maintain the "compact" feel, letter spacing is slightly tightened on larger headings and expanded on `label-lg` (all-caps) for metadata like dates or file types.

## Layout & Spacing
The system follows a strict **8dp grid** rhythm. To achieve high information density, internal card padding is set to `md` (16px), but vertical list spacing is compressed to `sm` (8px).

The layout utilizes a **fluid grid** with fixed margins. On mobile, a 4-column grid is used with 16px margins. As the screen scales to tablets, it transitions to an 8-column grid with 24px margins, allowing for side-by-side "Note" and "Task" views. Gutters are kept narrow (`gutter`: 12px) to maximize content area.

## Elevation & Depth
Depth is communicated through **Tonal Layers** supplemented by very soft, ambient shadows. In accordance with Material 3 principles:
- **Level 0 (Base):** White (#FFFFFF) - The main background.
- **Level 1 (Cards/Surface):** Light Gray (#F5F5F5) - Used for task items and note cards. No shadow, just a subtle tonal shift.
- **Level 2 (Floating/Active):** White (#FFFFFF) with a soft, diffused shadow (Blur: 8px, Y: 2px, Opacity: 4% Charcoal). Used for the Floating Action Button and active dialogs.
- **Level 3 (Navigation):** A subtle top-border (1px, #EEEEEE) on the bottom navigation bar to separate it from the content without heavy shadowing.

## Shapes
The design system adopts a **Rounded** profile. All standard containers, such as cards and text inputs, utilize a 16px (`rounded-lg`) corner radius to soften the high-density layout. Small elements like chips or checkboxes use 8px (`rounded-md`). The Floating Action Button (FAB) and primary buttons utilize a full pill-shape to distinguish them as interactive triggers.

## Components
- **Bottom Navigation:** Features five destinations (Home, Notes, Canvas, Tasks, Files). Use Indigo for the active icon and label; Charcoal at 60% opacity for inactive states. Icons are 24dp optical size.
- **Floating Action Button (FAB):** Positioned at the bottom right. A pill-shaped Indigo container with a White icon. It should expand into a speed-dial on tap to reveal specific "New Note" or "New Task" actions.
- **Cards:** Use #F5F5F5 backgrounds with 16px rounded corners. No borders. Title in `title-md` and metadata in `label-md`.
- **Inputs:** Clean, underlined or lightly boxed (1px #E0E0E0) fields. Active state uses an Indigo 2px bottom border.
- **Chips:** Used for "Files" tags and "Task" priorities. Small (height: 32px), 8px rounded corners, using the accent palette (e.g., Sage for 'Completed', Amber for 'In Progress') at 15% opacity with full-saturation text.
- **Lists:** High-density arrangement with 8px vertical spacing between items. Use subtle dividers (1px #F0F0F0) only when content is text-heavy and requires clear row separation.