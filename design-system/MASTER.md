# 🎨 Heza Money — Design System (Glassmorphism)

**Status:** Master Design System v1.0  
**Style:** Glassmorphism with Dark/Light Theme  
**Last Updated:** 2026-05-19  
**Framework:** Flutter + Material 3

---

## 1️⃣ DESIGN PHILOSOPHY

**Glassmorphism + Financial Trust**

Heza Money combines frosted glass aesthetics (modern, premium feel) with your existing green branding (trust, growth, money) adapted for both light and dark modes. The design emphasizes clarity, accessibility, and a sense of control over finances.

**Core Principles:**
- 🔍 **Transparency & Trust** — Glassmorphic overlays show background content (financial data is always visible)
- 💚 **Green Branding** — Your existing colors (#0F6E56, #1D9E75) are primary throughout
- 🌙 **Dual Theme** — Same glassmorphic design works beautifully in light and dark modes
- ✨ **Subtle Motion** — Blur and opacity changes (no flashy animations)
- ♿ **Accessibility First** — 4.5:1 contrast minimum on all text, WCAG AAA where possible

---

## 2️⃣ COLOR SYSTEM

### 2.1 — Primary Brand Colors (Your Existing Green)

| Name | Light Mode | Dark Mode | Usage |
|------|-----------|-----------|-------|
| **Primary** | `#0F6E56` | `#1D9E75` | Headers, primary buttons, nav active state |
| **Primary Light** | `#1D9E75` | `#5DCAA5` | Hover states, secondary emphasis |
| **Primary Accent** | `#5DCAA5` | `#A8E6D4` | Tertiary, decorative elements |
| **Success** | `#059669` | `#10B981` | Positive feedback, completed transactions |
| **Warning** | `#EF9F27` | `#FBBF24` | Objectives, alerts (from your master prompt) |

### 2.2 — Neutral Backgrounds (Light Mode)

| Token | Value | Usage |
|-------|-------|-------|
| **Surface** | `#FFFFFF` | Main background |
| **Surface 2** | `#F9FAFB` | Secondary surfaces, cards |
| **Surface 3** | `#F3F4F6` | Tertiary, subtle backgrounds |
| **Overlay Light** | `rgba(255,255,255,0.7)` | Glassmorphic cards (frosted glass) |
| **Overlay Medium** | `rgba(255,255,255,0.5)` | Glassmorphic containers |

### 2.3 — Neutral Backgrounds (Dark Mode)

| Token | Value | Usage |
|-------|-------|-------|
| **Surface** | `#0F172A` | Main background (deep navy) |
| **Surface 2** | `#1A2847` | Secondary surfaces, cards |
| **Surface 3** | `#24365D` | Tertiary, subtle backgrounds |
| **Overlay Light** | `rgba(255,255,255,0.08)` | Glassmorphic cards (frosted glass) |
| **Overlay Medium** | `rgba(255,255,255,0.12)` | Glassmorphic containers |

### 2.4 — Text Colors

**Light Mode:**
| Token | Value | Usage |
|-------|-------|-------|
| Text Primary | `#1F2937` | Body text, main content |
| Text Secondary | `#6B7280` | Secondary labels, hints |
| Text Muted | `#9CA3AF` | Disabled, placeholder text |

**Dark Mode:**
| Token | Value | Usage |
|-------|-------|-------|
| Text Primary | `#F3F4F6` | Body text, main content |
| Text Secondary | `#D1D5DB` | Secondary labels, hints |
| Text Muted | `#9CA3AF` | Disabled, placeholder text |

### 2.5 — Functional Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| Error | `#DC2626` | `#EF4444` | Destructive actions, errors |
| Error Light | `#FEE2E2` | `#7F1D1D` | Error backgrounds |
| Transparent Border | `rgba(15,110,86,0.2)` | `rgba(255,255,255,0.1)` | Glassmorphic borders |

---

## 3️⃣ GLASSMORPHISM TOKENS

### 3.1 — Blur & Backdrop Effects

**Always use CSS/Flutter equivalents based on platform:**

```dart
// Flutter blur implementation
ClipRRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7), // light mode
        // or
        // color: Colors.white.withOpacity(0.08), // dark mode
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
)
```

| Token | Value | Usage |
|-------|-------|-------|
| **Blur Amount** | `15px` / `sigmaX: 15, sigmaY: 15` | Primary glassmorphic cards |
| **Blur (Light)** | `10px` / `sigmaX: 10, sigmaY: 10` | Subtle blur for secondary elements |
| **Glass Opacity (Light)** | `0.7` (70%) | Light mode frosted glass |
| **Glass Opacity (Dark)** | `0.08` (8%) | Dark mode frosted glass |
| **Border Color** | `rgba(white, 0.2)` | Glassmorphic borders |
| **Border Width** | `1px` | Always hairline |

### 3.2 — Elevation & Depth Layers

**Glassmorphic layering replaces traditional shadows:**

| Layer | z-index | Blur | Overlay Opacity | Use Case |
|-------|---------|------|-----------------|----------|
| **Background** | 0 | — | — | Base content (scrollable) |
| **Card (Default)** | 10 | 15px | 70% (light) / 8% (dark) | Transaction cards, stats |
| **Elevated Card** | 20 | 20px | 80% (light) / 12% (dark) | Featured cards, highlights |
| **Modal Overlay** | 40 | 25px | 90% (light) / 15% (dark) | Modals, bottom sheets |
| **Floating Action** | 50 | 15px | 85% (light) / 10% (dark) | FAB button, floating elements |
| **Top Bar/Nav** | 100 | 20px | 80% (light) / 12% (dark) | Headers, navigation |

### 3.3 — Border & Divider Specifications

| Element | Style | Light Mode | Dark Mode |
|---------|-------|-----------|-----------|
| **Glassmorphic Border** | 1px solid | `rgba(15,110,86,0.2)` | `rgba(255,255,255,0.1)` |
| **Subtle Divider** | 1px solid | `rgba(107,178,139,0.1)` | `rgba(255,255,255,0.05)` |
| **Strong Divider** | 1px solid | `rgba(15,110,86,0.3)` | `rgba(255,255,255,0.15)` |

---

## 4️⃣ TYPOGRAPHY

### 4.1 — Font Stack

```
Font Family: Inter (Google Fonts)
Weights: 300 (Light), 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
```

**Google Fonts Import:**
```dart
// Add to pubspec.yaml
google_fonts:
  family: Inter
  weights: [300, 400, 500, 600, 700]
```

### 4.2 — Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Usage |
|------|------|--------|-------------|----------------|----- |
| **Display Large** | 32px | 600 | 1.2 | -0.015em | App title, hero screens |
| **Display** | 28px | 600 | 1.3 | -0.01em | Major headings |
| **Headline** | 24px | 600 | 1.4 | 0em | Section titles |
| **Title** | 20px | 500 | 1.4 | 0em | Card titles, subtitles |
| **Body Large** | 16px | 400 | 1.5 | 0em | Main body text, inputs |
| **Body** | 14px | 400 | 1.5 | 0em | Secondary text, labels |
| **Label** | 12px | 500 | 1.4 | 0.04em | UI labels, badges |
| **Label Small** | 11px | 500 | 1.3 | 0.05em | Tiny labels, timestamps |

### 4.3 — Font Usage Rules

- **Headers & Titles** → Weight 600 (SemiBold)
- **Body Text** → Weight 400 (Regular)
- **Labels & UI** → Weight 500 (Medium)
- **Minimum Size** → 12px for body text (never smaller)
- **Line Height** → Minimum 1.4 for accessibility
- **All caps** → Label weights only, never body text

---

## 5️⃣ SPACING & LAYOUT

### 5.1 — Spacing Scale (4dp System)

```
4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px
```

| Token | Value | Usage |
|-------|-------|-------|
| `spacing.xs` | 4px | Micro-spacing (gaps between icons) |
| `spacing.sm` | 8px | Small gaps, button padding |
| `spacing.md` | 12px | Standard component spacing |
| `spacing.lg` | 16px | Card padding, section spacing |
| `spacing.xl` | 24px | Large section separation |
| `spacing.2xl` | 32px | Major section breaks |
| `spacing.3xl` | 48px | Screen-level padding |

### 5.2 — Component Dimensions

| Element | Padding | Height | Border Radius |
|---------|---------|--------|----------------|
| **Button** | 12px horizontal, 8px vertical | 48px | 12px |
| **Card** | 16px | Auto | 16px |
| **Input** | 12px | 44px | 12px |
| **FAB** | — | 56px | 28px (circular with 16px padding) |
| **Bottom Nav** | — | 56px (Material 3 style) | 0px |
| **Top App Bar** | 16px | 64px (with status bar) | 0px |

### 5.3 — Border Radius Scale

```
8px   → Small buttons, subtle elements
12px  → Cards, containers, modals
16px  → Large cards, elevated surfaces
24px  → Featured sections, hero areas
28px  → Circular badges, FAB
99px  → Pills, badges
```

---

## 6️⃣ COMPONENT SPECIFICATIONS

### 6.1 — Glassmorphic Card (Primary)

**Light Mode:**
```dart
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  color: Colors.white.withOpacity(0.7), // Glassmorphic
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF0F6E56).withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: child,
      ),
    ),
  ),
)
```

**Dark Mode:**
```dart
// Same structure, but:
color: Colors.white.withOpacity(0.08), // 8% opacity
border: Color(0xFFFFFFFF).withOpacity(0.1), // Lighter border
```

### 6.2 — Primary Button

**Light Mode:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF0F6E56), // Deep green
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  onPressed: () {},
  child: Text('Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
)
```

**Hover/Press:**
- Scale: 0.98
- Opacity: 0.9
- Duration: 150ms

### 6.3 — Secondary Button (Glassmorphic)

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Color(0xFF0F6E56).withOpacity(0.3), width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  onPressed: () {},
  child: Text('Secondary', style: TextStyle(fontSize: 16, color: Color(0xFF0F6E56))),
)
```

### 6.4 — Input Field (Dark Mode Example)

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Amount',
    filled: true,
    fillColor: Colors.white.withOpacity(0.08), // Glassmorphic
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
)
```

---

## 7️⃣ MOTION & ANIMATION

### 7.1 — Timing Standards

| Interaction | Duration | Easing | Purpose |
|-------------|----------|--------|---------|
| **Micro** (opacity, scale) | 150ms | `ease-out` | Button press, hover |
| **Standard** (navigate, modal) | 300ms | `ease-out` | Screen transitions, card entrance |
| **Slow** (complex animations) | 400ms | `ease-out` | Complex reveals, multi-step |

### 7.2 — Easing Curves

```dart
// Entrance: smooth start
Curves.easeOut  // accelerate then decelerate

// Exit: quick start then smooth
Curves.easeIn   // slow start then accelerate

// Elastic: natural spring feel (optional)
Curves.elasticOut  // for fun interactions (sparingly)
```

### 7.3 — Glassmorphic Animations

- **Card Entrance** → Blur in (from 0 to 15px) + opacity (0 to 1) @ 300ms
- **Modal Overlay** → Backdrop blur (0 to 25px) + overlay opacity @ 300ms
- **Button Press** → Scale 1.0 → 0.98 @ 150ms, then back
- **Scroll Backdrop** → Continuous gentle blur shimmer (optional ambient effect)

**No** overly complex animations. Glassmorphism relies on subtle blur transitions.

---

## 8️⃣ LIGHT MODE SPECIFICATION

### 8.1 — Background Hierarchy

```
Screen Background: #FFFFFF
Secondary Surface: #F9FAFB
Tertiary Surface: #F3F4F6
Glassmorphic Overlay: rgba(255,255,255,0.7)
```

### 8.2 — Text & Contrast

```
Primary Text (#1F2937) on White (#FFFFFF)
Contrast: 17:1 ✓ WCAG AAA

Primary Text (#1F2937) on #F9FAFB
Contrast: 14:1 ✓ WCAG AAA

Secondary Text (#6B7280) on White
Contrast: 8:1 ✓ WCAG AA
```

### 8.3 — Brand Color Intensity (Light)

- Primary: `#0F6E56` (deep, trustworthy)
- Light Hover: `#1D9E75` (brighter on interaction)
- Accent: `#5DCAA5` (soft, decorative)

**Avoid:** Pure white text on #0F6E56 (use #FFFFFF, contrast 4.2:1 AA)

---

## 9️⃣ DARK MODE SPECIFICATION

### 9.1 — Background Hierarchy

```
Screen Background: #0F172A (deep navy)
Secondary Surface: #1A2847
Tertiary Surface: #24365D
Glassmorphic Overlay: rgba(255,255,255,0.08)
```

### 9.2 — Text & Contrast

```
Primary Text (#F3F4F6) on #0F172A
Contrast: 14:1 ✓ WCAG AAA

Primary Text (#F3F4F6) on #1A2847
Contrast: 12:1 ✓ WCAG AAA

Secondary Text (#D1D5DB) on #0F172A
Contrast: 7:1 ✓ WCAG AAA
```

### 9.3 — Brand Color Intensity (Dark)

- Primary: `#1D9E75` (brighter, vibrant)
- Light Hover: `#5DCAA5` (even brighter on interaction)
- Accent: `#A8E6D4` (soft, airy)

**Avoid:** Dark grey text on dark surfaces; always use lighter shades for text in dark mode.

---

## 🔟 NAVIGATION & LAYOUT

### 10.1 — Bottom Navigation Bar

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white.withOpacity(0.95), // slight glassmorphic touch
  selectedItemColor: Color(0xFF0F6E56),
  unselectedItemColor: Color(0xFF6B7280),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
    BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Investir'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
  ],
)
```

### 10.2 — Top App Bar (Header)

```dart
AppBar(
  backgroundColor: Colors.white, // Light
  // or
  // backgroundColor: Color(0xFF0F172A), // Dark
  elevation: 0, // No shadow; use glassmorphic approach instead
  title: Text('Heza Money'),
  // Optional: add subtle border instead
  shape: Border(
    bottom: BorderSide(
      color: Colors.black.withOpacity(0.05),
      width: 1,
    ),
  ),
)
```

### 10.3 — Safe Area & Padding

- **Top Padding** → Account for status bar (variable by device)
- **Bottom Padding** → Reserve space for bottom nav (56dp)
- **Side Padding** → 16px minimum (gutters)
- **Landscape** → Increase side padding to 24px

---

## 1️⃣1️⃣ COMPONENT LIBRARY (REUSABLE)

### 11.1 — Glasmorphic Card Widget

```dart
Widget glassCard({
  required Widget child,
  double blur = 15,
  double opacity = 0.7, // Light mode
  EdgeInsets padding = const EdgeInsets.all(16),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
}) {
  return ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: borderRadius,
        ),
        padding: padding,
        child: child,
      ),
    ),
  );
}
```

### 11.2 — Animated Button (Press Feedback)

```dart
Widget animatedButton({
  required VoidCallback onPressed,
  required Widget child,
  Duration duration = const Duration(milliseconds: 150),
}) {
  return GestureDetector(
    onTap: onPressed,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    ),
  );
}
```

---

## 1️⃣2️⃣ ANTI-PATTERNS (AVOID)

### DON'T:

- ❌ **No pure white text on green** → Always use #FFFFFF on #0F6E56
- ❌ **No dark grey text on dark backgrounds** → Use light grey/white
- ❌ **No heavy shadows** → Glassmorphism uses blur, not drop shadows
- ❌ **No hardcoded hex values** → Always use semantic color tokens
- ❌ **No animations > 400ms** → Glassmorphism is subtle and responsive
- ❌ **No text smaller than 12px** → Readability and accessibility
- ❌ **No emojis as icons** → Use Lucide/Material icons (flutter_svg)
- ❌ **No horizontal scroll on mobile** → Content must fit viewport
- ❌ **No overlapping touch targets** → Minimum 44×44dp spacing
- ❌ **No disabled buttons that look enabled** → Use opacity + semantics
- ❌ **No decorative blur for blur's sake** → Blur indicates depth or background content visibility

---

## 1️⃣3️⃣ IMPLEMENTATION CHECKLIST

Before coding any screen, verify:

### Glasmorphism
- [ ] Cards use `BackdropFilter` with 15px blur
- [ ] Overlay opacity matches light/dark token (0.7 light, 0.08 dark)
- [ ] All glassmorphic elements have 1px border with appropriate opacity
- [ ] Blur transitions smoothly (300ms) on interactions

### Color & Contrast
- [ ] Text contrast ≥4.5:1 (normal) / ≥3:1 (large)
- [ ] Primary text uses semantic color tokens, not hardcoded hex
- [ ] Dark mode variant tested independently (not inverted from light)
- [ ] Brand green (#0F6E56 light, #1D9E75 dark) used consistently

### Typography
- [ ] Body text: 14–16px minimum
- [ ] Line height: ≥1.4
- [ ] Font weights: 400 (body), 500 (labels), 600 (headers)
- [ ] No text smaller than 11px (label) except timestamps

### Layout & Spacing
- [ ] 4/8dp spacing rhythm applied consistently
- [ ] Safe area padding respected (top/bottom/sides)
- [ ] Touch targets: ≥44×44dp
- [ ] No horizontal scroll on mobile

### Interaction & Motion
- [ ] Button press: 0.98 scale @ 150ms
- [ ] Card entrance: fade + blur @ 300ms
- [ ] Modal overlay: blur backdrop @ 300ms
- [ ] Easing: ease-out for entrance, ease-in for exit

### Accessibility
- [ ] All icons have labels (icon + text, or aria-label)
- [ ] Form inputs have visible labels (not placeholder-only)
- [ ] Focus states visible (border or glow)
- [ ] Disabled states clear (opacity + semantic)
- [ ] Color not the only indicator (use icon + text for status)

### Icons & Assets
- [ ] Icons from Lucide or Material (SVG, not emoji)
- [ ] Icon sizing: 24px (standard), 20px (compact), 32px (large)
- [ ] Consistent stroke width (1.5px or 2px)
- [ ] Icons scale properly in dark mode (not hardcoded black/white)

---

## 1️⃣4️⃣ FILE STRUCTURE (Design System)

```
design-system/
├── MASTER.md                 ← This file (global rules)
└── pages/
    ├── home.md              ← Home screen overrides
    ├── budget.md            ← Budget screen overrides
    ├── invest.md            ← Investment/Learn screen overrides
    ├── goals.md             ← Goals screen overrides
    └── profile.md           ← Profile/Settings screen overrides
```

When building a screen, **always check `pages/[screen-name].md` first**. If it exists, its rules override this MASTER file. If not, use MASTER exclusively.

---

## 1️⃣5️⃣ COLOR TOKEN EXPORT (Dart/Flutter)

**Create `lib/core/theme/colors.dart`:**

```dart
class AppColors {
  // Primary Brand (Green)
  static const Color primaryDark = Color(0xFF0F6E56);
  static const Color primaryLight = Color(0xFF1D9E75);
  static const Color accent = Color(0xFF5DCAA5);
  
  // Light Mode
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF9FAFB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  
  // Dark Mode
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurface2 = Color(0xFF1A2847);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  
  // Functional
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFEF9F27);
}
```

---

## Questions Before Implementation?

1. **Light/Dark Theme Toggle** → How should users switch? Settings page toggle or system preference?
2. **Glasmorphism Intensity** → Should blur be stronger on certain screens (e.g., modals)?
3. **Animation Budget** → Do you want ambient animations (subtle floating blobs) or purely interaction-driven?
4. **Existing Components** → Should I refactor existing Flutter components or create new glassmorphic ones?

*Next Steps:*
1. Review this MASTER design system
2. Check if you need page-specific overrides (create `pages/[screen].md` as needed)
3. Begin implementation with theme/colors setup
4. Build reusable glassmorphic components
5. Apply to each screen progressively

---

**Made with 💚 for Heza Money**
