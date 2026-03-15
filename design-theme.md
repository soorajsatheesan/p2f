# P2F Design Theme

Complete design language reference for the Path2Fitness brand. Use this to maintain consistency across the website and mobile app.

---

## Color Palette

| Token              | Value                          | Usage                        |
| ------------------ | ------------------------------ | ---------------------------- |
| Background         | `#000000`                      | App/page background          |
| Foreground         | `#FFFFFF`                      | Primary text, icons          |
| Muted              | `rgba(255, 255, 255, 0.5)`    | Secondary text, descriptions |
| Subtle             | `rgba(255, 255, 255, 0.35)`   | Tertiary text, labels        |
| Faint              | `rgba(255, 255, 255, 0.15)`   | Numbering, disabled states   |
| Border             | `rgba(255, 255, 255, 0.08)`   | Default borders, dividers    |
| Border Hover       | `rgba(255, 255, 255, 0.2)`    | Borders on hover/focus       |
| Border Strong      | `rgba(255, 255, 255, 0.3)`    | Prominent borders, inputs    |
| Surface            | `rgba(255, 255, 255, 0.02)`   | Card backgrounds             |
| Surface Hover      | `rgba(255, 255, 255, 0.04)`   | Card hover, active states    |
| Surface Elevated   | `rgba(255, 255, 255, 0.08)`   | Grid backgrounds, dividers   |
| Overlay Light      | `rgba(0, 0, 0, 0.5)`         | Image overlay (mid)          |
| Overlay Heavy      | `rgba(0, 0, 0, 0.75)`        | Image overlay (strong)       |
| Overlay Fade       | `rgba(0, 0, 0, 0.95)`        | Image overlay (bottom fade)  |

### Key Principle
Strictly monochrome — black and white only. No accent colors. Hierarchy is achieved through opacity levels of white on black.

---

## Typography

### Font Families

| Role       | Font           | Source                                        |
| ---------- | -------------- | --------------------------------------------- |
| Headings   | Space Grotesk  | Google Fonts — weights: 400, 500, 600, 700    |
| Body       | Inter          | Google Fonts — weights: 300–900               |

### Font Import
```
https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=Space+Grotesk:wght@400;500;600;700&display=swap
```

### Type Scale

| Element             | Font           | Size                          | Weight | Letter Spacing | Line Height |
| ------------------- | -------------- | ----------------------------- | ------ | -------------- | ----------- |
| Hero Title          | Space Grotesk  | `clamp(3.5rem, 10vw, 9rem)`  | 700    | `-0.04em`      | 0.95        |
| Section Title       | Space Grotesk  | `clamp(2rem, 5vw, 3.5rem)`   | 700    | `-0.03em`      | 1.1         |
| CTA Title           | Space Grotesk  | `clamp(2.5rem, 6vw, 5rem)`   | 700    | `-0.04em`      | 1.0         |
| Card Value          | Space Grotesk  | `3rem`                        | 700    | `-0.03em`      | 1.0         |
| Stat Number         | Space Grotesk  | `2.8rem`                      | 700    | `-0.03em`      | 1.0         |
| Feature Heading     | Space Grotesk  | `1.3rem`                      | 600    | `-0.01em`      | default     |
| Logo                | Space Grotesk  | `1.5rem`                      | 700    | `-0.02em`      | default     |
| Body Text           | Inter          | `1.1rem`                      | 400    | normal         | 1.7         |
| Feature Body        | Inter          | `0.95rem`                     | 400    | normal         | 1.7         |
| Nav Links           | Inter          | `0.9rem`                      | 500    | `0.04em`       | default     |
| Button Text         | Inter          | `0.9rem`                      | 600    | `0.03em`       | default     |
| Tags / Eyebrows     | Inter          | `0.85rem`                     | 500    | `0.25em`       | default     |
| Labels (uppercase)  | Inter          | `0.75rem`                     | 600    | `0.15em`       | default     |
| Small Labels        | Inter          | `0.7rem`                      | 500    | `0.1em`        | default     |

### Text Transform
- Tags, labels, nav links, buttons: `uppercase`
- Headings and body: normal case

### Special Text Effects
- **Outline text**: `-webkit-text-stroke: 2px #fff` with `color: transparent`
- Mobile outline: reduce stroke to `1.5px`

---

## Spacing

| Token   | Value    | Usage                              |
| ------- | -------- | ---------------------------------- |
| xs      | `8px`    | Tight gaps, inline spacing         |
| sm      | `12px`   | Small gaps, label margins          |
| md      | `16px`   | Standard gaps, card label margins  |
| lg      | `24px`   | Section gaps, card padding gaps    |
| xl      | `32px`   | Hero padding, description margins  |
| 2xl     | `48px`   | Section padding, page gutters      |
| 3xl     | `64px`   | Section title bottom margin        |
| 4xl     | `100px`  | Section top padding                |
| 5xl     | `120px`  | Section bottom padding             |

### Page Gutters
- Desktop: `48px`
- Mobile: `24px`

---

## Border Radius

| Token     | Value   | Usage                        |
| --------- | ------- | ---------------------------- |
| sm        | `12px`  | Logo, small elements         |
| md        | `14px`  | Badges                       |
| lg        | `20px`  | Cards, feature grid, inputs  |
| full      | `100px` | Buttons, pills               |

---

## Borders

- Default: `1px solid rgba(255, 255, 255, 0.08)`
- Hover: `1px solid rgba(255, 255, 255, 0.2)`
- Strong: `1px solid rgba(255, 255, 255, 0.3)`
- Logo/brand: `2px solid #fff`
- Dividers: `1px solid rgba(255, 255, 255, 0.06)` (footer) or `0.08` (stats)

---

## Shadows

| Usage       | Value                                       |
| ----------- | ------------------------------------------- |
| Card hover  | `0 24px 60px rgba(0, 0, 0, 0.4)`          |
| Button glow | `0 10px 40px rgba(255, 255, 255, 0.1)`    |

---

## Buttons

### Primary (Filled)
- Background: `#FFFFFF`
- Text: `#000000`
- Border: `1px solid #FFFFFF`
- Hover: transparent bg, white text, lift `-2px`, glow shadow

### Ghost (Outline)
- Background: transparent
- Text: `#FFFFFF`
- Border: `1px solid rgba(255, 255, 255, 0.25)`
- Hover: border goes full white, lift `-2px`

### Sizes
- Default: `14px 32px` padding
- Large: `18px 48px` padding, `1rem` font size

### Shape
- `border-radius: 100px` (full pill)

---

## Cards

- Background: `rgba(255, 255, 255, 0.02)`
- Border: `1px solid rgba(255, 255, 255, 0.08)`
- Border Radius: `20px`
- Padding: `40px 32px`
- Hover: lift `-8px`, border brightens, subtle shadow

---

## Animations & Transitions

### Easing
- Primary easing: `cubic-bezier(0.16, 1, 0.3, 1)` — smooth deceleration
- Simple transitions: `ease` or `ease-in-out`

### Durations
| Type              | Duration |
| ----------------- | -------- |
| Hover transitions | `0.3s`   |
| Hover (complex)   | `0.5s`   |
| Reveal entrance   | `0.8s`   |
| Hero entrance     | `0.8s` with staggered delays (0.2s increments) |
| Counter animation | `1.5s–2s` |

### Reveal Animations
- **Fade Up**: `opacity: 0` + `translateY(50px)` → visible
- **Slide Left**: `opacity: 0` + `translateX(-60px)` → visible
- **Slide Right**: `opacity: 0` + `translateX(60px)` → visible
- **Scale Up**: `opacity: 0` + `scale(0.9)` → visible
- Triggered by `IntersectionObserver` at `threshold: 0.12`

### Hero Stagger Sequence
1. Tag — `0.2s` delay
2. Title — `0.4s` delay
3. Description — `0.6s` delay
4. Buttons — `0.8s` delay

### Continuous Animations
- **Float** (cards): `translateY(0)` → `translateY(-10px)` — `6s` loop, staggered by `1s`
- **Shimmer** (outline text): background gradient sweep — `4s` loop
- **Pulse** (CTA button): box-shadow ring — `2.5s` loop
- **Navbar slide**: `translateY(-100%)` → `translateY(0)` on load

### Interactive
- Card 3D tilt: follows mouse via JS, `perspective: 800px`, `rotateX/Y` up to `8deg`
- Number counters: count from 0 to target with ease-out over `1.5–2s`
- Typewriter: text values reveal character by character at `60ms` per char
- Parallax: hero background shifts at `0.3x` scroll speed

---

## Blur & Backdrop

- Navbar: `backdrop-filter: blur(24px)` on `rgba(0, 0, 0, 0.6)` bg
- Scrolled navbar: `rgba(0, 0, 0, 0.85)` bg

---

## Image Treatment

- All images: `filter: grayscale(100%)` to enforce B&W
- Dark overlay gradient on hero images:
  ```
  linear-gradient(180deg,
    rgba(0,0,0,0.75) 0%,
    rgba(0,0,0,0.5)  40%,
    rgba(0,0,0,0.65) 70%,
    rgba(0,0,0,0.95) 100%
  )
  ```

---

## Responsive Breakpoints

| Breakpoint | Target       |
| ---------- | ------------ |
| `768px`    | Tablet/small |
| `480px`    | Mobile       |

### Key Adjustments at Mobile
- Hide nav links, keep logo + CTA button
- Single column grids
- Reduce section padding from `48px` to `24px`
- Buttons go full width at `480px`
- Reduce hero title size to `clamp(2.8rem, 12vw, 5rem)`
- Use `100svh` for hero height

---

## Mobile App Mapping

| Web Element        | Android Equivalent                       |
| ------------------ | ---------------------------------------- |
| `#000` background  | `Color.Black` / dark theme surface       |
| `#FFF` text        | `Color.White` / `onSurface`              |
| Space Grotesk      | Custom font via `ResourceFont`           |
| Inter              | System default or custom font            |
| `100px` radius     | Full pill shape via `RoundedCornerShape(50)` |
| `20px` radius      | `RoundedCornerShape(20.dp)`              |
| Opacity layers     | `Color.White.copy(alpha = 0.08f)`        |
| Fade-up reveal     | `AnimatedVisibility` with `slideInVertically` + `fadeIn` |
| Number counter     | `animateIntAsState` / `Animatable`       |
