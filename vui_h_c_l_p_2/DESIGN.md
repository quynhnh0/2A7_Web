---
name: Vui Học Lớp 2
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#434655'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#855300'
  on-secondary: '#ffffff'
  secondary-container: '#fea619'
  on-secondary-container: '#684000'
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#ffddb8'
  secondary-fixed-dim: '#ffb95f'
  on-secondary-fixed: '#2a1700'
  on-secondary-fixed-variant: '#653e00'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-xl:
    fontFamily: Quicksand
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 54px
  headline-xl-mobile:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 42px
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Quicksand
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-xl:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.375rem
  space-sm: 0.75rem
  space-md: 1.25rem
  space-lg: 2rem
  space-xl: 3rem
---

## Brand & Style

This design system serves a dual-audience educational ecosystem: 7-year-old Vietnamese second graders embarking on foundational literacy and numeracy, alongside their teachers and school administrators overseeing learning progress. 

The aesthetic marries **Playful Tactility** for the student learning space with **Clean Modern Utility** for the educator cockpit:
- **Child Interface:** Tactile, joyful, inviting, and ultra-legible. Visual metaphors reference physical stationery, sticker sheets, reward stamps, and toy blocks. Interactions feature generous click targets, bouncy physical feedback, soft drop-pillows, and distinct high-contrast palettes that reward curiosity without sensory overload.
- **Teacher & Admin Interface:** Streamlined, calm, and structured. It retains the signature warm brand accents while introducing disciplined typography, tabular data layouts, concise metric cards, and lower cognitive noise to facilitate grading, lesson tracking, and analytics.

The emotional goal is for children to feel capable, excited, and safe from failure, while educators feel organized, empowered, and effortlessly in control.

## Colors

The palette balances energetic child-friendly primaries with tranquil, accessible backdrops:

- **Primary (`#2563EB` Sky Blue):** Main interactive brand driver. Conveys clarity, focus, and digital confidence. Anchors primary buttons, progress states, and navigation bars.
- **Secondary (`#F59E0B` Sunny Amber):** Evokes warmth, encouragement, trophies, and star rewards. Used for active achievements, streak counters, badges, and cheerful highlights.
- **Tertiary (`#10B981` Cheerful Mint Emerald):** Signals correct answers, mastered skills, safe validation, and growth milestones.
- **Accent Coral (`#F43F5E` Warm Coral Pink):** Reserved for celebratory alerts, playful prompts, hearts/lives counters, and urgent callouts.
- **Neutral Dark (`#1E293B` Deep Slate):** Deep, legible text contrast satisfying strict WCAG AAA guidelines for young readers encountering Vietnamese tone marks (*dấu thanh*).

### Surface & Tonal Backgrounds
- **Student Canvas:** Crisp warm porcelain (`#F8FAFC`) with soft contextual pastel cards:
  - Cream Butter (`#FEF3C7`) for creative challenges and daily quests.
  - Spring Mint (`#ECFDF5`) for reading and vocabulary sessions.
  - Soft Sky (`#EFF6FF`) for math and logic puzzles.
  - Rose Petal (`#FFF1F2`) for active teacher feedback or homework alerts.
- **Admin/Teacher Canvas:** Soft Cool Neutral (`#F1F5F9`) with crisp stark white (`#FFFFFF`) elevated cards, bordered with subtle slate dividers (`#CBD5E1`).

## Typography

Typography prioritizes extreme phoneme and diacritic legibility for early-stage Vietnamese readers:
- **Headline Font (`Quicksand`):** Rounded terminals evoke handwriting and friendly shapes. Its welcoming geometry lowers anxiety around formal tests and exercises.
- **Body & Label Font (`Be Vietnam Pro`):** Purpose-built for Vietnamese typography. Features generous letter-spacing, open counters, and pristine vertical space for diacritical markers (sắc, huyền, hỏi, ngã, nặng, nón, râu), preventing clashing tone marks in multi-syllable compound words.

### Scale Rules:
- **Student View:** Minimum reading body size is strictly `body-lg` (18px) or `body-xl` (20px) to safeguard developing vision. Heading levels `headline-xl` and `headline-lg` power exercise prompts, game objectives, and cheer messages.
- **Teacher View:** Default body shifts to `body-md` (16px) and tables use `body-sm` (14px) or `label-sm` (12px) to support compact data display.

## Layout & Spacing

The layout is built upon an 8pt spatial grid with generous interactive zones:

- **Student Arena:**
  - Uses an auto-centering, single-stage or dual-column canvas with a capped maximum width of `1120px` to prevent visual drifting on wide desktop displays.
  - Touch/Mouse targets never measure below `54px` in interactive height.
  - Spacing between multiple-choice options, answer cards, and draggable elements is mapped strictly to `space-md` (20px) or `space-lg` (32px) to eliminate accidental misclicks by 7-year-olds with nascent motor coordination.

- **Teacher & Admin Portal:**
  - Employs a responsive 12-column grid layout with fixed sidebar navigation (`260px`).
  - Screen containers span up to `1440px` with `gutter` spacing of `1.5rem` (`24px`).
  - Metric dashboards flow 4-across on desktop (`col-span-3`), 2-across on tablet (`col-span-6`), and single stack on mobile screens.

## Elevation & Depth

This system shuns muddy, dark realism in favor of vibrant, candy-like tactile depth:

- **Level 0 (Flat/Base):** Canvas surfaces (`#F8FAFC` student, `#F1F5F9` admin) without borders or drop shadows.
- **Level 1 (Card & Board Tiles):** Tinted ambient shadows. `0px 4px 12px -2px rgba(30, 41, 59, 0.06), 0px 2px 4px -1px rgba(30, 41, 59, 0.04)`. Card tops feature a crisp 1.5px soft border (`border-slate-200/80`).
- **Level 2 (Pillowy 3D Interactive Buttons):** Physical button styling for students. Achieved via an extruded bottom offset: `box-shadow: 0px 4px 0px 0px [darker-shade-token]`. On active click/press, `translate-y: 3px` and shadow reduces to `0px 1px 0px`, simulating the satisfying push of a toy button.
- **Level 3 (Reward Modals & Overlays):** Deep luminous glow: `0px 20px 35px -5px rgba(37, 99, 235, 0.18)`. Backdrop filters use gentle milky blurs (`backdrop-blur-md bg-slate-900/30`).

## Shapes

Shapes are distinctly curved, soft, and organic:
- Standard UI panels, content cards, and input fields utilize `rounded-2xl` (1rem to 1.25rem) to eliminate harsh corners that feel intimidating to children.
- Primary interaction elements (buttons, pill filters, star count badges, search bars) utilize `rounded-full` or `rounded-2xl` with a minimum radius of `16px`.
- Admin metric cards utilize `rounded-xl` (0.75rem) to strike an optimal balance between organizational efficiency and brand unity.

## Components

### Buttons
- **Student Hero Action:** Min-height `56px`, font `label-lg`, `rounded-2xl`. Solid brand background (e.g. `#2563EB` with `#1D4ED8` 4px 3D extrusion). Crisp white bold text.
- **Reward Action (Sunny Amber):** `#F59E0B` with `#D97706` 4px extrusion, paired with star or sparkle SVG icons.
- **Admin Button:** Height `40px`, `rounded-lg`, flat semi-bold styling with subtle hover tinting (`bg-blue-600 hover:bg-blue-700`).

### Cards & Lesson Tiles
- **Pastel Lesson Pods:** Grouped by subject with dedicated colorways:
  - *Toán 2 (Math):* Tinted Sky `#EFF6FF`, border `#BFDBFE`.
  - *Tiếng Việt 2 (Vietnamese):* Tinted Mint `#ECFDF5`, border `#A7F3D0`.
  - *Hoạt Động Trải Nghiệm (Activities):* Tinted Cream `#FEF3C7`, border `#FDE68A`.
- Inner content features high-contrast dark slate text (`#1E293B`) and illustrative visual icons.

### Multiple Choice & Answer Chips
- Minimum height `64px`, border width `2.5px`, `rounded-2xl`.
- **Default State:** White background, Slate border (`#E2E8F0`), deep slate text.
- **Selected State:** Sky Blue background (`#EFF6FF`), Blue border (`#2563EB`).
- **Success State:** Mint Emerald background (`#ECFDF5`), Emerald border (`#10B981`), accompanied by an animated checkmark sticker.
- **Retry State:** Light Coral background (`#FFF1F2`), Coral border (`#F43F5E`).

### Badges, Stars & Streaks
- Pill-shaped (`rounded-full`), padded `space-xs` vertically and `space-sm` horizontally.
- Amber-tinted background with a glowing star icon depicting current points and daily streaks (*Chuỗi ngày học*).

### Admin Data Tables & Controls
- **Table Headers:** `label-sm` in `#64748B` uppercase tracking, seated on `#F8FAFC`.
- **Row Styling:** Hover states with soft `#F1F5F9` transition, 56px row height, inline student avatar badge, status chips with rounded pills.
- **Search & Filter:** Pill-shaped input fields with left-aligned search icons and clear, accessible placeholder texts.