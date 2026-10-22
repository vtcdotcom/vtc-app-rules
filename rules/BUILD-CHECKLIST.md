# VTC App Build Checklist

Human-readable companion to the Cursor rules in this folder. For AI routing details, see `README.md`.

**Terminology:** UI **Space** → code `group_id`. Data Storage: **Space** / **Publisher** (token `app`) / **Personal**. **Shared** app (multi-tenant, per-space data) · **Dedicated** / Publisher (publisher-space DB) · **Personal** (`personalDb()`, `group=0`) — `personal-storage.mdc`.

---

## Before you code

- [ ] **Implement from `.cursor/rules/` only** — do not copy patterns from sibling apps in `~/apps/` (`core.mdc` #12)
- [ ] What task does the user complete in one visit?
- [ ] **Space** (CRM, bookings), **Publisher** (catalog, price list; token `app`), and/or **Personal** (follows the user at `group=0`)? — `app-types.mdc`, `personal-storage.mdc`
- [ ] Primary screen is a **list or task** — not a dashboard (unless the brief requires it)
- [ ] Who acts: member vs admin (`role_type`)?
- [ ] Entities, fields, search columns defined
- [ ] Collection names: `{appshortname}_{entity}`
- [ ] Touches customers, guests, leads, suppliers, contacts, products/services, invoices or payments? → **Space Core Records** (`core-records.mdc`): link by `clientId`/`itemId`, write via `@vtc/suite-core`, no private copies
- [ ] Realtime needed? → `wss://ws.vtc.com` only (not `chat.vtc.com`)
- [ ] Map / location UI? → `maps.mdc` — `NEXT_PUBLIC_MAP_STYLE_URL` or `VITE_MAP_STYLE_URL` + OpenMapTiles attribution
- [ ] Publish visibility (Space / Network / Platform) is shell config — **do not build in app code**

---

## Scaffold order

- [ ] Link rules: `~/apps/cursor/scripts/add.sh <app>` (do not commit `.cursor/`)
- [ ] Folder skeleton: `src/app`, `src/lib`, providers, `start.sh`
- [ ] `next.config` → `output: 'standalone'` from first commit
- [ ] `env_development` + committed `.env.production`
- [ ] Lib: `jwt.ts`, `auth.ts`, `clientAuth.ts`, `mongodb.ts`, `db.ts` (Shared vs Dedicated)
- [ ] Auth bootstrap: URL `?token=&user=&group=` → `localStorage`, `addTokenToUrl()` on fetches
- [ ] i18n: `I18nProvider`, `en.json` complete, `es.json` / `pt.json` stubs
- [ ] Promotional landing: hero + features panel + Connect to VTC cards — `landing-page.mdc`
- [ ] `LayoutContent.tsx`: ThemeProvider + I18nProvider
- [ ] Authenticated home: list or task screen
- [ ] API routes: `/api/[entity]/list|create|update|delete`
- [ ] Create/edit UI with validation, loading, empty, error states
- [ ] UI polish: Tailwind v4, light + dark, sticky header (**no app name in header when shell-embedded** — `ui.mdc`)
- [ ] **No app name anywhere when shell-embedded** — not in the header, not as the home heading/`pageTitle`, not in a home subtitle ("Your personal X"). Home starts with content/actions; nested screen titles OK; signed-out landing + direct tab unchanged. `@vtc/ui` ≥ 1.4.0 in the lockfile.
- [ ] `~/cursor_rules/scripts/check-embedded-app-name.sh .` → `PASS`, then open from `app.vtc.com/<module>` at 390×844 and confirm the iframe shows no app name (`ui.mdc` § Verify)

---

## Non-negotiables

| # | Rule |
|---|------|
| 1 | No hardcoded URLs, DB URIs, or API keys — use env (`VTC_API_URL` → `https://api.vtc.com`) |
| 2 | App JWT as query `?token=` — not `Authorization` on app routes |
| 3 | **Dedicated:** `connectDB()` only. **Shared:** `getDb()` when `group_id !== '0'` in production. **Personal:** `personalDb()` only (`personal-storage.mdc`) |
| 4 | **Shared:** filter `group_id` + exclude `status: 'deleted'` on every query |
| 5 | Soft delete by default |
| 6 | No dashboard unless requested |
| 7 | i18n for all user-visible text |
| 8 | Do not run `./start.sh` unless asked |
| 9 | No `alert()`, `confirm()`, `prompt()` |
| 10 | Subdomain apps auto-deploy on push (Next.js → k3s; static → object storage) |
| 11 | Runtime accent via `--app-accent*` — no hardcoded indigo/purple primaries in components |
| 12 | Implement from Cursor rules — do not copy sibling apps under `~/apps/` (`core.mdc` #12) |
| 13 | User-facing features, fixes, improvements, and new apps listed in the app store are published into VTC Updates in the same work (`vtc-changelog.mdc`). A commit or deploy does not add the note |

### Static Vite SPA (`runtime_type=static`)

- [ ] `runtime-types.mdc` + `scaffold-checklist-static.mdc`
- [ ] Auth from URL `?token=` — no app `/api/*` routes
- [ ] ZAPI calls from browser; no `MONGODB_URI` in app repo
- [ ] `VITE_*` env only in `.env.production`

---

## Platform stack

- [ ] Node 22.x (`"engines": { "node": ">=22 <23" }`)
- [ ] Exact versions for Next.js, React, react-dom (no `^` / `~`)
- [ ] Tailwind **v4** on new apps
- [ ] Dev server bound to `127.0.0.1` only
- [ ] Required env: `MONGODB_DEV_URI`, `APP_PORT` + `APP_NAME` in `env_development` (build injects identity into `.env.production`)
- [ ] `.env.production` committed — **app-owned keys only**; no `VTC_API_URL`, `POSIF_API_URL`, `MONGODB_URI`, `DEEPINFRA_*`, or legacy `*.posif.com` URLs (`env-development.mdc`, `deployment.mdc`)

---

## Data model (every business document)

- [ ] `_id`, `created_at`, `updated_at`, `created_by`, `status`
- [ ] `status`: `active` \| `archived` \| `deleted`
- [ ] **Shared apps:** `group_id` on create and every query
- [ ] **Dedicated apps:** no `group_id` unless brief requires per-user rows
- [ ] **Personal:** `personalDb()`; do not set/filter `user_id`; no `getPersonalDb()`
- [ ] Default lists exclude `status: 'deleted'`

---

## API routes

- [ ] `getDbWithAuth(request)` on every handler
- [ ] List: `q`, `limit` (max 100), `offset`, `sort`, `order`
- [ ] Success: `{ success: true, data }`
- [ ] Error: `{ success: false, code, error }` with correct HTTP status
- [ ] Client: `fetch(addTokenToUrl('/api/...'))`

---

## UI / UX

- [ ] **App Shell** + responsive container by screen purpose (`ui.mdc`)
- [ ] Authenticated home = list/task — not dashboard
- [ ] List screens: `max-w-[900px]` default — not 450px on desktop
- [ ] Admin/edit: header slots + form + collapsible panels — no bottom bar
- [ ] Detail/content: `max-w-[760px]` reading layout
- [ ] Four states on data screens: loading, empty, error, no search results
- [ ] Light + dark theme on every screen
- [ ] **Runtime accent color** — `--app-accent*` from URL `color` (space/network branding) → `NEXT_PUBLIC_APP_ACCENT` → persisted `posif_color` → **VTC Blue `#004A80`** fallback (`ui.mdc`)
- [ ] **Header action slots:** max 3 platform icons + vertical ellipsis (slot 4 always); no arbitrary icons
- [ ] No bottom action bar or FAB — all actions in header slots or ellipsis menu
- [ ] Top bar: **embedded** — action slots only (no app name; platform chrome shows title). **Standalone** — app name left. No text nav, headings, or labeled buttons — screen titles in page body
- [ ] Home screen (embedded): no app-name heading or subtitle — first thing is content or a primary action
- [ ] Admin/settings in ellipsis menu by default — never plain text link in top bar
- [ ] **Typography Standard** — platform type scale; no custom fonts; page titles in `<main>` (`ui.mdc`)
- [ ] **VTC packages** — `.npmrc` points at `npm.vtc.com`; developers run `npm adduser --registry https://npm.vtc.com` once; CI uses `NPM_VTC_PASSWORD_B64` (`vtc-packages.mdc`)
- [ ] Floating-label inputs; no nested cards
- [ ] Preserve `token`, `mode`, `lang` in navigation
- [ ] No hardcoded strings in `.tsx` — use i18n keys

---

## Auth

- [ ] `bootstrapAuthFromUrl()` on layout mount (inside `mounted` guard)
- [ ] Server decodes JWT, validates `exp`, uses `user_id` / `group_id` (snake_case)
- [ ] `isAdmin` / `isOwner` from `role.role_type`

---

## Optional (only when needed)

| Feature | Check |
|---------|--------|
| File uploads | `@vtc/sdk/storage`, server-only; **public** bucket + permanent URL for world-readable assets; **private** bucket + key for restricted files — `storage.mdc`, `vtc-packages.mdc` |
| Realtime | `NEXT_PUBLIC_WS_URL=wss://ws.vtc.com` |
| In-app ACL | 3-segment UI (Username / Role / UserList) + chips — see `access-control.mdc`, copy `~/apps/jobs` |
| Personal storage | `personalDb()` (`@vtc/sdk` ≥ 1.4.0); dual-scope lists; share index if others must view — `personal-storage.mdc` |
| Cross-app APIs | `{APP}_APP_URL` env, JWT in query params |
| Link to network chat | `NEXT_PUBLIC_PLATFORM_URL` + `/dashboard/chat/with/{userId}` — `app-integration.mdc` |
| Multiplayer game | `/api/game-info`, `/lobby-start`, LobbyNet contract |
| RAG / AI | DeepInfra vars, server-only, Docling pipeline |

---

## Deploy

- [ ] `npm run build` passes locally
- [ ] Commit + push code and `.env.production`
- [ ] Subdomain apps deploy automatically — no manual release step

Shell/API deploy (beta.vtc.com, ZAPI) is separate — see `deploy-platform.mdc`.

---

## Quick reference — rule files

| Building… | Read |
|-----------|------|
| New app | `scaffold-checklist.mdc` → `product-start.mdc` → `app-types.mdc` |
| Shared vs Dedicated | `app-types.mdc` → `architecture.mdc` → `data-model.mdc` |
| Personal storage | `personal-storage.mdc` → `app-types.mdc` |
| API only | `api-routes.mdc` → `business-patterns.mdc` |
| UI | `ui.mdc` → `ux-screens.mdc` → `i18n.mdc` |
| Auth / JWT details | `auth-bootstrap.mdc` → `auth-jwt-reference.mdc` |
