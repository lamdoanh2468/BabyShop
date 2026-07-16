# BabyShop Admin — Master Design System

Source of truth for every `admin_*.jsp` page (accounts, brands, categories, contacts,
orders, overview, products, settings, stocks, vouchers). Read this before implementing
any admin page; check `pages/<page>.md` first if it exists — it overrides this file.

## Overrides from the raw `ui-ux-pro-max --design-system` run

The auto-generated output (`MASTER.raw.md`, kept for reference) had two mismatches:

1. **Pattern** — same "Real-Time / Operations Landing" mismatch as storefront (it's a
   marketing-landing pattern, not a CRUD dashboard). Replaced with the information
   architecture `admin_overview.jsp` already uses: sidebar nav + KPI cards + charts +
   data table — that structure is correct, it just needs a real visual system.
2. **Style/color** — it returned "Dark Mode (OLED)", dark-only, with a code-editor font
   pairing (Fira Code/Fira Sans) and a green accent unrelated to the current admin UI.
   Forcing staff who work in this dashboard for hours into permanent dark mode with no
   light option is a usability regression, not an upgrade. Kept light-first with a
   proper dark mode.

**Palette is now shared with the storefront** (owner decision): brand `#008BC6`, page
background `#FEF7FF`. This supersedes the earlier "admin keeps its own blue-violet
identity (`#4d7cff` / `#00114d` / `#ECEBFF`)" decision and the broader "two separate
design systems" rule that previously lived in `CLAUDE.md`.

What still separates admin from the storefront is **density, dark mode, and layout** —
not color. Those remain independent and should not be flattened onto storefront values.

Typography (**Be Vietnam Pro / Noto Sans**) is shared with the storefront system — same
justification (full Vietnamese diacritic coverage, and every label/table header here is
Vietnamese).

## Pattern: Operational Dashboard

- **Layout**: fixed left sidebar (nav, icon + label, active state highlighted) + main
  content area with a content-width max (no full-bleed tables on ultra-wide monitors).
- **Section order per page**: page title + primary action (e.g. "Thêm sản phẩm") →
  filters/search → data table or form → pagination.
- **Overview page specifically**: KPI cards (revenue, orders, accounts, products) →
  charts (revenue trend, orders by category) → recent orders table.
- Currently the sidebar markup is duplicated in every `admin_*.jsp` file. Extract it
  into a shared `admin_sidebar.jsp` fragment (`<jsp:include>`), mirroring how the
  storefront already shares `header.jsp`/`footer.jsp` — this is a JSP-side templating
  change only, no servlet/Java changes.

## Colors

| Role | Token | Hex | Usage |
|---|---|---|---|
| Primary identity | `--color-primary-500` | `#008BC6` | Fills, icons, borders, focus rings, large text **only** — 3.8:1 on white, so never normal-size text |
| Primary text / CTA | `--color-primary-600` | `#007BA8` | Links, primary button fill (white label) — 4.8:1 on white |
| Primary deep | `--color-primary-700` | `#00658F` | Hover/active, **text on any primary tint** — 5.2:1 on `primary-100` |
| Primary wash | `--color-primary-100` | `#CDEDF9` | Selected rows, hover backgrounds |
| Primary tint | `--color-primary-50` | `#ECF8FD` | Active nav background, status pills |
| Ink (headings) | `--color-ink-900` | `#1D1B20` | Page titles, table headers |
| Ink (body) | `--color-ink-700` | `#49454F` | Table cell text, labels |
| Ink (muted) | `--color-ink-500` | `#6E6779` | Timestamps, helper text |
| Surface | `--color-surface` | `#FFFFFF` | Cards, table, sidebar |
| Page background | `--color-bg` | `#FEF7FF` | `<body>` background |
| Border | `--color-border` | `#E7E0EC` | Table borders, card borders, dividers |
| Border (strong) | `--color-borderStrong` | `#79747E` | Input borders — UI controls need ≥3:1, `--color-border` is too faint |

Semantic — **identical hex values to the storefront system**, this is what makes order
status legible to both a customer and an admin looking at the same order:

| Role | Hex | Order statuses using it |
|---|---|---|
| Success | `#15803D` / bg `#EAF7EE` | `Done` / `DONE` |
| Warning | `#B45309` / bg `#FEF3E2` | `Pending` / `PENDING` |
| Info | `#0369A1` / bg `#E6F3FB` | `WAITING_SIGNATURE`, `VERIFIED` |
| Danger | `#DC2626` / bg `#FDEDED` | `CANCELLED`, `TAMPERED`, `SIGNATURE_INVALID`, `CERTIFICATE_INVALID` |

Status pills always pair color with the text label already present in `${o.statusOrder}`
— never color alone.

### Dark mode

Admin gets a real dark theme (unlike the storefront, which stays light-only — a
marketing storefront has no reason to force dark mode on shoppers, but staff running
this dashboard for long shifts benefit from one). Toggle via a `data-theme` attribute
persisted in `localStorage`, not just `prefers-color-scheme`, so an operator's choice
sticks across sessions.

| Token | Light | Dark |
|---|---|---|
| `--color-bg` | `#FEF7FF` | `#0F1117` |
| `--color-surface` | `#FFFFFF` | `#171A23` |
| `--color-ink-900` | `#1D1B20` | `#F2F3F8` |
| `--color-ink-700` | `#49454F` | `#C6CAD6` |
| `--color-border` | `#E7E0EC` | `#2A2E3A` |
| brand text | `#007BA8` (`primary-600`) | `#4FC3F0` (`primary-dark`) — 8.6:1 on `#171A23` |

Note the brand inverts in dark mode: `#008BC6` is too dark to sit on `#171A23`, so dark
mode uses the *lighter* `#4FC3F0`. The light-mode "identity vs text" split does not
apply there — `#4FC3F0` clears AA for both roles on the dark surface.

Semantic status colors get lighter/desaturated dark-mode variants (e.g. success text
`#4ADE80` on `#0F2A19` background) — never literally invert.

## Typography

Same pairing and load `<link>` as the storefront system (Be Vietnam Pro / Noto Sans),
but a **denser scale** per the `--density 8` dial: `xs` 0.75/1.3, `sm` 0.8125/1.4,
`base` 0.875/1.5 (admin body text is 14px, not 16px — this is standard dashboard
practice and still passes 4.5:1 at the specified colors), `lg` 1/1.4, `xl` 1.25/1.3,
`2xl` 1.5/1.25. Table headers use `sm` + `uppercase` + `tracking-wide` + `ink-500`.

## Spacing, radius, shadow (dense)

- **Spacing scale**: 8/32px range (not the storefront's 4/96px) — card padding 16–20px,
  table cell padding 10–12px vertical, section gaps 24px. This is what "Dense /
  Dashboard" density means in practice: more rows visible without scrolling, still
  passing the 8px minimum touch-target spacing rule.
- **Radius**: `rounded-lg` (8px) everywhere — cards, buttons, inputs, table container.
  No pill buttons in admin (that's a storefront/marketing trait); consistent 8px reads
  as "tool," not "storefront."
- **Shadow**: flatter than storefront — `0 1px 2px rgba(11,18,32,0.04)` resting card,
  `0 4px 12px -4px rgba(11,18,32,0.12)` for dropdowns/modals only.

## Icons

Keep Font Awesome 6 (already CDN-loaded, already used consistently as `fa-solid`
throughout every admin page) — no reason to churn a working, consistent icon system.
Standardize on solid weight only (already the case) at 16–18px within nav items.

## Accessibility checklist (apply to every admin page before calling it done)

- [ ] Body/table text ≥ 4.5:1 in both light and dark mode
- [ ] Sidebar nav items and table row actions ≥ 44×44px hit area even at dense spacing
- [ ] Status pills readable by screen readers (text label present, not color-only —
      already true via `${o.statusOrder}`, keep it that way through the restyle)
- [ ] Tables: sortable columns expose `aria-sort`; provide a horizontal scroll
      container (`overflow-x-auto`) instead of letting the page scroll sideways
- [ ] Forms (`admin_*_form.jsp`): visible labels, inline validation on blur, errors
      state cause + fix, focus moves to first invalid field on submit
- [ ] Charts (`admin_overview.jsp`) keep a text/table fallback for the two Chart.js
      canvases — screen readers get nothing from a bare `<canvas>`

## Tailwind config (admin, set once in the new `admin_sidebar.jsp` fragment or a shared
`admin_header.jsp` — whichever becomes the single include point for every admin page)

```js
tailwind.config = {
  darkMode: 'selector', // toggled via data-theme on <html>, not OS preference alone
  theme: {
    extend: {
      colors: {
        // Shares the storefront brand scale. primary-500 = identity only (3.8:1 on
        // white); text uses 600/700. primary-dark is the dark-mode brand.
        primary: {
          50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
          500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
          dark: '#4FC3F0',
        },
        brand: {
          50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
          500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
        },
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
    },
  },
}
```
