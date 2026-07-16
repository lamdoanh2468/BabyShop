# BabyShop Storefront — Master Design System

Source of truth for every customer-facing page (`home`, `productList`, `productDetail`,
`cart`, `orderSign`, `profile`, `favorite`, `news`, `voucherList`/`voucherDetail`,
`contact`, `login`/`register`, `header`/`footer`). Read this before implementing any
storefront page; check `pages/<page>.md` first if it exists — it overrides this file.

## Overrides from the raw `ui-ux-pro-max --design-system` run

The auto-generated output (`MASTER.raw.md`, kept alongside this file for reference)
matched on generic keyword scoring and produced two mismatches, corrected below:

1. **Pattern** — it returned "Real-Time / Operations Landing" (built for ops/IoT SaaS
   demos). BabyShop's home page is a retail storefront, not a product demo. Replaced
   with a category-led storefront pattern that matches what `home.jsp` already does
   structurally (hero → categories → products → trust → footer).
2. **Color** — it returned a hot-pink (`#EC4899`) primary, which was rejected. The
   palette is now **owner-specified**: `#008BC6` (blue) as the brand color and `#FEF7FF`
   as the page background, replacing the previous red (`#e63946` → `#DC2626`) family.
   This supersedes the earlier "keep the red, it has brand recognition" decision — the
   rebrand was requested directly. Red survives only as the **danger** semantic.

Typography (**Be Vietnam Pro / Noto Sans**) from the raw run was kept — it's the
skill's dedicated Vietnamese-first pairing and every storefront string is Vietnamese
copy, so it's a correct match, not a default.

## Pattern: Category-Led Storefront

- **Section order**: 1. Hero (seasonal banner + primary CTA), 2. Category grid
  (visual, icon/image-led), 3. Featured / best-selling products (card grid), 4. Trust
  band (vouchers, shipping, return policy), 5. Newsletter or contact CTA, 6. Footer.
- **Primary CTA placement**: hero (pill button) + sticky add-to-cart on product detail +
  cart icon badge in header, persistent across all pages.
- **Conversion notes**: category grid reduces time-to-first-product; voucher/trust band
  addresses price-sensitivity and new-parent risk-aversion; product cards always show
  price + one trust signal (rating or "đã bán" count), never price alone.

## Style direction

Warm, trustworthy, uncluttered — not the auto-generated "Vibrant & Block-based" (too
loud for a baby-products audience who are risk-averse, sleep-deprived, scanning
quickly). Soft rounded surfaces, generous whitespace, one accent color spent on CTAs
only, product photography is the visual interest — not busy chrome around it.

## Colors

Brand blue `#008BC6` and page background `#FEF7FF` are the two owner-specified colors.
Everything else in this table is derived from them.

**The one rule that matters:** `#008BC6` measures **3.8:1 on white** — below the 4.5:1
WCAG AA threshold for normal-size text. It is therefore an **identity color, not a text
color**. Use it for fills, icons, borders, focus rings, and large display text; use
`brand-600` for anything text-sized. This split is why there are two blues, and it is
not negotiable — reverting text to `brand-500` reintroduces an AA failure.

| Role | Token | Hex | Contrast | Usage |
|---|---|---|---|---|
| Brand identity | `--color-brand-500` | `#008BC6` | 3.8:1 on white | Fills, icons, borders, focus rings, large text **only** |
| Brand text / CTA | `--color-brand-600` | `#007BA8` | 4.8:1 on white, 4.5:1 on page | Links, price emphasis, primary button fill (white label) |
| Brand hover / on-tint | `--color-brand-700` | `#00658F` | 6.5:1 on white, 5.2:1 on `brand-100` | Button hover/active, **text on any brand tint** |
| Brand deep | `--color-brand-900` | `#013E58` | — | Gradient ends, deep accents |
| Brand wash | `--color-brand-200` | `#9BDBF3` | — | Decorative, gradient ends |
| Brand wash | `--color-brand-100` | `#CDEDF9` | — | Selected states, hover backgrounds |
| Brand tint | `--color-brand-50` | `#ECF8FD` | — | Badge/pill backgrounds, subtle highlight |
| Ink (headings) | `--color-ink-900` | `#1D1B20` | 16.2:1 on page | Headings, high-emphasis text |
| Ink (body) | `--color-ink-700` | `#49454F` | 8.9:1 on page | Body copy |
| Ink (muted) | `--color-ink-500` | `#6E6779` | 5.2:1 on page | Captions, secondary metadata, placeholders |
| Surface | `--color-surface` | `#FFFFFF` | — | Cards, header, modals |
| Page background | `--color-bg` | `#FEF7FF` | — | `<body>` background |
| Border | `--color-border` | `#E7E0EC` | decorative | Card borders, dividers |
| Border (strong) | `--color-borderStrong` | `#79747E` | 4.3:1 on page | Input borders — UI controls need ≥3:1, `--color-border` is too faint |

`#FEF7FF` is Material Design 3's light surface value, so the neutral ink ramp above is
M3's (tuned for exactly this tinted background) rather than a generic grey scale.

The `trust-*` tokens are retained as aliases onto this same blue scale so existing
markup keeps working; there is no longer a separate "trust blue" — the brand *is* blue.

Semantic (shared with admin — same hex, same meaning everywhere):

| Role | Hex | Usage |
|---|---|---|
| Success | `#15803D` / bg `#EAF7EE` | Order delivered, in-stock, form success |
| Warning | `#B45309` / bg `#FEF3E2` | Pending order, low stock |
| Info | `#0369A1` / bg `#E6F3FB` | Waiting-signature, processing |
| Danger | `#DC2626` / bg `#FDEDED` | Cancelled, tampered/invalid, out of stock, form errors |

Never use color alone for status — pair with an icon or text label (order status pills
already do this via text; keep that).

**Caveat introduced by the blue rebrand:** the Info semantic (`#0369A1`) is now visually
close to `brand-600` (`#007BA8`). Since the brand is blue, blue no longer reads as "this
is an informational status" on its own. Info states must lean on their icon and text
label to stay distinguishable from ordinary brand chrome — this is the one place the
rebrand cost us signal, and it is worth watching if info banners start reading as CTAs.

## Typography

- **Display / headings**: Be Vietnam Pro, weights 600–700.
- **Body**: Noto Sans, weights 400–500. Both have full Vietnamese diacritic coverage —
  this is why they were kept from the raw search, not defaulted to.
- **Load** (add once in `header.jsp`, before Tailwind config):
  ```html
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@500;600;700&family=Noto+Sans:wght@400;500;600&display=swap" rel="stylesheet">
  ```
- **Scale** (rem / line-height): `xs` 0.75/1.33, `sm` 0.875/1.43, `base` 1/1.6 (body
  copy — current CSS never states a line-height; 1.6 fixes cramped paragraphs), `lg`
  1.125/1.56, `xl` 1.25/1.4, `2xl` 1.5/1.33, `3xl` 1.875/1.27, `4xl` 2.25/1.2, `5xl`
  3/1.1 (hero headline — replaces the current unitless `3em`).

## Spacing, radius, shadow

- **Spacing scale**: standard density (per CLAUDE.md storefront ≠ admin) — Tailwind
  default 4px steps; section vertical rhythm 64–96px desktop / 40–56px mobile.
- **Radius**: `rounded-full` for primary/secondary buttons (matches the existing
  `.btn-hero` 30px pill — keep this, it's already a brand trait), `rounded-2xl` (16px)
  for product/content cards, `rounded-lg` (8px) for inputs and small chips.
- **Shadow**: warm-tinted, not pure black — `0 8px 24px -12px rgba(36,23,21,0.18)` for
  raised cards, `0 1px 2px rgba(36,23,21,0.06)` for resting cards.

## Icons

`home.jsp` already loads Font Awesome 7 (CDN) and uses it for product-card actions
(`fa-cart-plus`, `fa-eye`, `fa-heart`) — found during implementation, and it changes
this from the original plan. Standardize the **whole storefront** on Font Awesome
(solid weight) rather than introduce a second icon system just for header/nav chrome;
one icon set loaded once is simpler and matches what product cards already ship. No
emoji as icons (the header currently uses 🔍/👤/🛒 — replace with `fa-magnifying-glass`,
`fa-user`, `fa-cart-shopping`).

## Motion

- Micro-interactions (hover, focus, add-to-cart pulse): 150–250ms ease-out.
- Hero entrance: keep the existing `fadeUp` pattern, ~700ms ease-out, once per page
  load — this is the one deliberate "moment," not a page-wide default.
- Respect `prefers-reduced-motion: reduce` everywhere (currently unimplemented).

## Accessibility checklist (apply to every storefront page before calling it done)

- [ ] Body text ≥ 4.5:1 against its background (verify after every color substitution)
- [ ] Touch targets ≥ 44×44px, 8px+ gap (nav links, card CTAs, quantity steppers)
- [ ] 375px width: no horizontal scroll, hero uses `min-h-*`/`aspect-*` not fixed `px`
      heights
- [ ] Product images: explicit `aspect-ratio` or width/height to prevent CLS
- [ ] `prefers-reduced-motion` disables/reduces the hero fade and any new motion
- [ ] Focus rings visible on every interactive element (links, buttons, form fields)

## Tailwind config (storefront `tailwind.config`, set once in `header.jsp`)

```js
tailwind.config = {
  theme: {
    extend: {
      colors: {
        // brand-500 = identity only (3.8:1 on white). Text uses 600/700.
        brand: {
          50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
          500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
        },
        trust: { 50: '#ECF8FD', 700: '#00658F' }, // alias — kept for existing markup
        ink: { 900: '#1D1B20', 700: '#49454F', 500: '#6E6779' },
        surface: '#FFFFFF',
        page: '#FEF7FF',
        border: '#E7E0EC',
        borderStrong: '#79747E',
        success: '#15803D', warning: '#B45309', info: '#0369A1', danger: '#DC2626',
      },
      fontFamily: {
        display: ['"Be Vietnam Pro"', 'sans-serif'],
        body: ['"Noto Sans"', 'sans-serif'],
      },
      borderRadius: { xl2: '16px' },
      boxShadow: {
        card: '0 1px 2px rgba(29,27,32,0.06)',
        raised: '0 8px 24px -12px rgba(29,27,32,0.18)',
      },
    },
  },
}
```
