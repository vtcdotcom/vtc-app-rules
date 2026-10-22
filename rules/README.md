# VTC Cursor Rules — AI Index

**Audience: AI assistants only.** Load `.mdc` files by task; respect `alwaysApply` and `globs` in frontmatter.

**Platform:** Next.js or static Vite SPAs — publisher child apps on `*.apps.vtc.com` (legacy `*.posif.com` aliases); JWT via `?token=`, committed `.env.production`.

**Terminology:** UI says **Space** (code: `group_id`). **Shared** app = per-space data (multi-tenant). **Dedicated** app = publisher DB (shared data). **Personal** = `personalDb()` (`personal-storage.mdc`).

**Human checklist:** `BUILD-CHECKLIST.md` · repo root `EXTERNAL-ONBOARDING.md`

**Rule pack version:** `RULE-PACK-VERSION` in this folder. Refresh app copies after `git pull` on this repo.

---

## Start here (every new app)

**Source of truth:** `.cursor/rules/` in the app workspace — **not** other apps as templates (`core.mdc` #12).

| Order | File | Why |
|-------|------|-----|
| 1 | `product-start.mdc` | Workflow, Spaces, Shared vs Dedicated, publish visibility |
| 2 | `dev-watch.mdc` | EMFILE / Watchpack — Tailwind scope + next.config watchers |
| 3 | `app-types.mdc` | Storage decision tree and query rules |
| 3b | `runtime-types.mdc` | Next.js vs static Vite vs Expo native |
| 4 | `scaffold-checklist.mdc` | Ordered implementation steps (Next.js) |
| 5 | `core.mdc` | Non-negotiables (always loaded) |
| 5c | `plans-directory.mdc` | Save plans to `<workspace>/plans/` (always loaded) |
| 5d | `typography.mdc` | Platform type hierarchy — shell + child apps |

---

## “I am building X” → which rules to read

### New app from scratch

**Next.js:** `scaffold-checklist.mdc` → `dev-watch.mdc` → … → `deployment.mdc`

**Static Vite SPA (preferred default):** `runtime-types.mdc` → `scaffold-checklist-static.mdc` → `zapi-collections.mdc` → `nextjs-to-vite.mdc` → `auth-bootstrap.mdc` → `i18n.mdc` → `ui.mdc` → `deployment.mdc`

**Expo / React Native (VTC Store only):** `scripts/new-native.sh` → `scaffold-checklist-native.mdc`

### Convert existing Next.js app → static Vite

`nextjs-to-vite.mdc` → `scaffold-checklist-static.mdc` → `zapi-collections.mdc`

### Choosing Shared vs Dedicated

`app-types.mdc` → `architecture.mdc` (db.ts) → `data-model.mdc` → `api-routes.mdc` (scoping)

### CRUD entity

`data-model.mdc` → `business-patterns.mdc` → `api-routes.mdc` → `ux-screens.mdc` → `best-practices.mdc` → `ui.mdc`

### Auth / JWT

`auth-bootstrap.mdc` → `landing-page.mdc` → `auth-jwt-reference.mdc` → `lib-canonical.mdc` → `api-routes.mdc`

### Environment / deploy / packages

`env-development.mdc` → `vtc-packages.mdc` (`npm.vtc.com`, `@vtc/*`) → `deployment.mdc` (subdomain apps, auto on push)

### File uploads / video / maps / realtime / games / AI / i18n / ACL

`storage.mdc`, `video-uploads.mdc`, `maps.mdc`, `realtime.mdc`, `multi-user-games.mdc`, `ai-inference.mdc`, `jev-decisions.mdc`, `ai-manifest.mdc`, `platform-ads.mdc`, `i18n.mdc`, `access-control.mdc`, `public-guest-browse.mdc`.

Closed decisions (a label, a yes/no, a score) use Jev in ZAPI — `jev-decisions.mdc`. Do not classify a fixed set with `/apps/ai/chat`.

### Platform Ads (child app monetization / sponsored placements)

`platform-ads.mdc` → `vtc-packages.mdc` (`@vtc/sdk/ads`) — register `module_code` in ZAPI `ads_capable_apps.py`; integrate `getAd` / `trackImpression` / `trackClick`; Space owners enable via shell **Ads → Monetize**.

### Cross-app integration / shell chat links

`app-integration.mdc` — chat slash commands, server-to-server APIs, `NEXT_PUBLIC_PLATFORM_URL` deep links.

### Platform shell bell / inbox notifications

`shell-notifications.mdc` — ZAPI `NotificationDispatchService` + chat `notification:new`; not iframe `postMessage`, not `ws.vtc.com`, not email/SMS.

### In-app Help wiki

`app-wiki-help.mdc` — child app `public/wiki/help.md` + `index.json`; shell chrome **Help** menu.

### Network branding / accent

`network-branding.mdc` → `ui.mdc` — space/network accent scope, `app_typography`, runtime `--app-accent*` tokens.

---

## Full file index (this public pack)

| File | `alwaysApply` | Topic |
|------|---------------|--------|
| `core.mdc` | yes | Non-negotiables |
| `plans-directory.mdc` | yes | Save plans to workspace `plans/` folder |
| `product-start.mdc` | yes | Product model + workflow |
| `app-types.mdc` | yes | Space / Publisher / Personal storage |
| `personal-storage.mdc` | no | `personalDb()`, group=0, dual-scope |
| `i18n.mdc` | yes | Locales, no hardcoded strings |
| `dev-watch.mdc` | yes | EMFILE / webpack watchers |
| `scaffold-checklist.mdc` | no | Bootstrap steps (Next.js) |
| `scaffold-checklist-static.mdc` | no | Bootstrap steps (Vite static) |
| `scaffold-checklist-native.mdc` | no | Bootstrap steps (Expo / VTC Store) |
| `runtime-types.mdc` | no | Next.js vs static Vite vs Expo native |
| `nextjs-to-vite.mdc` | no | ZAPI app services + Next→Vite conversion |
| `zapi-collections.mdc` | globs | ZAPI collections for static SPAs |
| `architecture.mdc` | globs | db.ts, folders, roles |
| `lib-canonical.mdc` | globs | Required `src/lib/*` |
| `auth-bootstrap.mdc` | globs | URL JWT, bootstrap flow |
| `auth-jwt-reference.mdc` | no | JWT claims reference |
| `data-model.mdc` | globs | Document fields, soft delete |
| `api-routes.mdc` | globs | CRUD routes, envelope |
| `env-development.mdc` | globs | env files |
| `deployment.mdc` | globs | standalone, auto deploy |
| `ui.mdc` | globs | App Shell, Tailwind v4, runtime accent |
| `typography.mdc` | globs | Platform type hierarchy |
| `network-branding.mdc` | globs | Network accent scope, app typography |
| `storage.mdc` | globs | `@vtc/sdk/storage` |
| `vtc-packages.mdc` | globs | `@vtc/sdk`, `@vtc/client`, `@vtc/ui`, `@vtc/i18n`, `npm.vtc.com` |
| `video-uploads.mdc` | globs | ZAPI media pipeline |
| `maps.mdc` | no | MapTiler / platform tiles |
| `realtime.mdc` | no | ws.vtc.com |
| `ratings.mdc` | no | ZAPI ratings API |
| `multi-user-games.mdc` | no | LobbyNet + ws relay |
| `ai-manifest.mdc` | no | `public/.well-known/ai-manifest.json` |
| `ai-inference.mdc` | no | ZAPI AI proxy |
| `jev-decisions.mdc` | globs | TypeSafe Jev — closed decisions; ZAPI only |
| `platform-metering.mdc` | no | Credits / metering |
| `platform-ads.mdc` | no | `@vtc/sdk/ads`, capable-app registry |
| `access-control.mdc` | no | In-app ACL |
| `public-guest-browse.mdc` | globs | Anonymous browse without JWT |
| `app-integration.mdc` | no | Cross-app APIs, shell chat deep links |
| `shell-notifications.mdc` | globs | Platform shell bell/inbox — ZAPI + chat `notification:new` |
| `app-wiki-help.mdc` | globs | Child app `public/wiki` Help menu |

---

## Rules the AI must not violate

1. Never hardcode URLs, DB URIs, or API keys — `env-development.mdc`. ZAPI: **`https://api.vtc.com`** via `VTC_API_URL`.
2. App JWT as query `token` — not `Authorization` on app routes (`core.mdc`).
3. **Dedicated:** never `getDb()`. **Shared:** `getDb()` when `group_id !== '0'` in production.
4. **Shared** queries: filter `group_id` + exclude `status: 'deleted'`.
5. Soft delete unless user requests hard delete.
6. No dashboard unless required.
7. i18n for all user-visible text.
8. Do not run `./start.sh` unless user asks.
9. No `alert()`, `confirm()`, `prompt()`.
10. Subdomain apps: auto-deploy on push — do not ask user to deploy (`deployment.mdc`).
11. Runtime accent via `--app-accent*` tokens — no hardcoded indigo/purple primaries (`ui.mdc`).
12. Cursor rules only — do not use other apps as templates (`core.mdc` #12).

---

## Install / refresh

```bash
git clone https://github.com/vtcdotcom/vtc-app-rules.git ~/vtc-app-rules
~/vtc-app-rules/scripts/copy-cursor-rules.sh /path/to/your-app
```

Do not symlink `.cursor/rules`. Do not commit `.cursor/` to app repos.
