# BabyShop — UI/UX Rebuild Guide

This file steers Claude Code sessions rebuilding the BabyShop website's UI/UX with the
`ui-ux-pro-max` skill (installed at `.claude/skills/ui-ux-pro-max/`, sourced from
[nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)).
It does not cover backend/business logic — see "Out of scope" below.

## Project shape

- **Stack**: Java 21, Jakarta Servlet + JSP/JSTL, JDBI, MySQL, Maven. No frontend build
  tooling — `package.json` at the repo root only carries the `sweetalert2` runtime
  dependency, no bundler.
- **Where the UI lives**: `JSP_Servlet/src/main/webapp/`
  - Page templates: `*.jsp` at the webapp root (`home.jsp`, `cart.jsp`, `productDetail...`
    is served via query params on a shared JSP, etc.)
  - `header.jsp` / `footer.jsp` are pulled into every storefront page via `<jsp:include>`
    (not an iframe — `home.css` still has unused `#header-frame`/`#footer-frame` rules
    from an earlier iframe-based layout; safe to delete once found dead elsewhere too).
  - One CSS file per page under `css/` (`home.css`, `cart Style.css`, `productList.css`,
    `admin_style.css`, …) — no shared base stylesheet or design tokens today.
  - Plain JS per page under `js/` (`home.js`, `cart.js`, …), no framework.
- **Two distinct UIs, two audiences**:
  1. **Storefront** (`home`, `productList`, `productDetail`, `cart`, `orderSign`,
     `profile`, `favorite`, `news`, `voucherList`/`voucherDetail`, `contact`,
     `login`/`register`) — Vietnamese-language, consumer-facing, marketing + shopping
     flows.
  2. **Admin** (`admin_*.jsp` — accounts, brands, categories, contacts, orders,
     overview/dashboard, products, settings, stocks, vouchers) — internal dashboard,
     denser, data/table-heavy.
- **Current visual state** (why we're rebuilding): fonts vary file-to-file (`Segoe UI`,
  `Poppins`, `Inter`, plain `Arial`), no consistent spacing or type scale, and no shared
  accessibility baseline (touch target sizes, focus states haven't been audited).
  **Color has been unified** — the old scattered per-file palettes (storefront `#e63946`
  red / `#004a…` blue; admin `#4d7cff` / `#00114d` / `#ECEBFF` blue-violet) were swept
  to the `#008BC6` / `#FEF7FF` theme across the live CSS and JSP inline styles. Colors
  are still hardcoded hex per file rather than tokens on the un-migrated pages; the
  Tailwind configs in `header.jsp` / `admin_sidebar.jsp` are the canonical source.
- **Dead CSS** (not referenced by any JSP — don't spend time theming these): `news.css`,
  `newsDetail.css`, `orderSign.css`, `upload-signature.css`.

## Decisions already made

- **Scope**: rebuild both the storefront and the admin dashboard.
- **Palette is shared across both areas** (owner decision, supersedes the earlier "two
  separate design systems, do not force one palette onto both" rule): brand **`#008BC6`**,
  page background **`#FEF7FF`**. Storefront and admin still differ in **density, layout,
  and dark mode** (admin only) — keep those separate; only color is unified.
- **`#008BC6` is an identity color, not a text color.** It measures 3.8:1 on white, under
  the 4.5:1 AA floor for normal text. Use it for fills, icons, borders, focus rings, and
  large text; use `#007BA8` (`brand-600`, 4.8:1) for text-sized elements and primary
  button fills, and `#00658F` (`brand-700`, 5.2:1 on tint) for text on any brand tint.
  Full scale + rationale: `design-system/{storefront,admin}/MASTER.md`.
- **Styling approach**: adopt Tailwind CSS via the CDN script (no build step). Add it
  once in `header.jsp` (storefront) and once in the admin layout entry point, each with
  its own `tailwind.config` `theme.extend` block sourced from that area's design-system
  output. Convert page CSS to Tailwind utility classes in the JSP markup; drop the
  per-page hand-written CSS files as each page is migrated. Keep `sweetalert2` and any
  small bespoke JS interactions as-is — Tailwind only replaces layout/visual CSS.
- **Stack override for the skill**: `ui-ux-pro-max`'s own `SKILL.md` Quick Reference
  defaults to app-UI stacks (React Native / JavaFX) in its example workflow — **ignore
  that default for this repo**. BabyShop renders server-side HTML from JSP, so always
  pass `--stack html-tailwind` (see `data/stacks/html-tailwind.csv`) for implementation
  guidance, and treat the "Pre-Delivery Checklist" / "Common Rules" sections in
  `SKILL.md` that say "App UI (iOS/Android/React Native/Flutter)" as **not applicable**
  — use the numbered Quick Reference table (Accessibility → Charts & Data) instead,
  which is platform-general.

## Rebuild workflow

Run this once per design system (storefront, admin), then once per page group.

### 1. Generate the two Master design systems

```bash
python scripts/search.py "baby products ecommerce storefront Vietnamese warm trustworthy" \
  --design-system --persist -p "BabyShop Storefront" -f markdown
# working dir: .claude/skills/ui-ux-pro-max
```

```bash
python scripts/search.py "internal admin dashboard ecommerce operations dense tables" \
  --design-system --persist -p "BabyShop Admin" --density 8 -f markdown
```

This writes `design-system/MASTER.md` + `design-system/pages/` per project name. Keep
the two outputs in separate folders, e.g.:
- `JSP_Servlet/src/main/webapp/design-system/storefront/MASTER.md`
- `JSP_Servlet/src/main/webapp/design-system/admin/MASTER.md`

(Move/copy the generated files there — the script writes relative to its own working
directory by default.)

### 2. Page-level overrides (as needed)

Only when a specific page genuinely deviates from its Master (e.g. `productDetail` needs
a gallery/zoom pattern the home page doesn't):

```bash
python scripts/search.py "product detail gallery zoom variant selector" \
  --design-system --persist -p "BabyShop Storefront" --page "product-detail"
```

### 3. Before implementing a page, read in this order

1. `design-system/<area>/MASTER.md`
2. `design-system/<area>/pages/<page>.md` if it exists (overrides Master)
3. `--domain landing` / `--domain product` / `--domain ux` searches for anything the
   Master doesn't cover (e.g. cart empty-state, checkout multi-step progress, admin
   table sorting/pagination patterns)
4. `--stack html-tailwind` for Tailwind-specific implementation notes

### 4. Implement

- Translate the Master's color/type/spacing tokens into each area's
  `tailwind.config.theme.extend` (colors, fontFamily, borderRadius, spacing) so both
  areas stay internally consistent even though they differ from each other.
- Replace the page's CSS file with Tailwind utility classes in the `.jsp` markup; delete
  the old CSS file's `<link>` once migrated.
- Keep all Vietnamese copy as-is unless the user asks you to change wording — this is a
  visual/UX rebuild, not a content rewrite.
- Keep every servlet route, form field `name` attribute, and JSTL data binding
  (`${...}`) unchanged — only touch presentation.

### 5. Before calling a page done

Run the Quick Reference checklist from `SKILL.md` (§1–§9 as relevant) against the page,
at minimum:
- Contrast ≥ 4.5:1 for body text, both the light values already in use and after any
  palette swap.
- Touch targets ≥ 44×44px, 8px+ spacing between them (nav links, product card CTAs, form
  buttons currently have no such guarantee).
- Mobile-first: test at 375px width — several pages use fixed hero heights/absolute
  positioning (`hero { height: 400px }`) that will need `min-h`/`aspect-ratio`-based
  responsive treatment instead.
- No layout shift from images — add explicit width/height or `aspect-ratio` (product
  images currently have none).
- `prefers-reduced-motion` respected for the existing `fadeUp` hero animation and any
  new motion.

## Out of scope

- Java controllers/servlets, DAO/service layer, DB schema, auth/session logic — do not
  touch `src/main/java` for this work unless a UI change requires a genuinely new field
  the backend doesn't expose yet, and confirm with the user first.
- Don't introduce a JS framework or a bundler as part of this rebuild — Tailwind CDN
  keeps the zero-build-step constraint intact. If that constraint changes later, revisit
  this file.
