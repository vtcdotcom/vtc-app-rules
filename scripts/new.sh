#!/usr/bin/env bash
# Create a new app folder under ~/apps and install the VTC central-rules stub.
#
# Usage:  ~/cursor_rules/scripts/new.sh
#         Opens the new project in Cursor and drops you into that folder in the terminal.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APPS_ROOT="${APPS_ROOT:-$HOME/apps}"
CURSOR_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
STUB_SRC="$CURSOR_REPO/stubs/vtc-central.mdc"
CENTRAL_RULES="$CURSOR_REPO/rules"

echo "VTC app folder setup"
echo "  Apps root:       $APPS_ROOT"
echo "  Rules stub:      $STUB_SRC"
echo "  Central rules:   $CENTRAL_RULES"
echo ""

if [ ! -f "$STUB_SRC" ]; then
  echo "Error: stub not found at $STUB_SRC" >&2
  exit 1
fi
if [ ! -d "$CENTRAL_RULES" ]; then
  echo "Error: central rules not found at $CENTRAL_RULES" >&2
  exit 1
fi

read -r -p "New folder name (under $APPS_ROOT): " NAME

if [ -z "${NAME// }" ]; then
  echo "Error: name cannot be empty." >&2
  exit 1
fi

# Safe folder name: letters, numbers, hyphen, underscore
if ! [[ "$NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
  echo "Error: use a letter first, then letters, numbers, hyphens, or underscores only." >&2
  exit 1
fi

APP_DIR="$APPS_ROOT/$NAME"

if [ -e "$APP_DIR" ]; then
  echo "Error: already exists: $APP_DIR" >&2
  exit 1
fi

mkdir -p "$APP_DIR"

# Stub only — agents load rules from ~/cursor_rules/rules/ (no full pack copy)
"$SCRIPT_DIR/push-stub.sh" "$APP_DIR"

read -r -p "Dev port [5019]: " PORT_IN
PORT="${PORT_IN:-5019}"
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
  echo "Error: port must be 1024–65535." >&2
  exit 1
fi

# hostname -I is Linux-only; pipefail + set -e would exit before .gitignore on macOS
LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}')" || true
if [ -z "${LAN_IP:-}" ]; then
  for _iface in en0 en1; do
    LAN_IP="$(ipconfig getifaddr "$_iface" 2>/dev/null)" || true
    [ -n "${LAN_IP:-}" ] && break
  done
fi
LAN_IP="${LAN_IP:-YOUR_LAN_IP}"

cat > "$APP_DIR/.gitignore" <<'GITIGNORE'
node_modules/
.next/
out/
.env.development
.env.local
.env.production.local
.cursor/
npm-debug.log*
.DS_Store
*.log
GITIGNORE

cat > "$APP_DIR/README.md" <<README
# ${NAME}

VTC child app — scaffold with Cursor using central rules at \`~/cursor_rules/rules/\` (stub: \`.cursor/rules/00-vtc-central.mdc\`; see \`scaffold-checklist.mdc\`).

## Local dev

\`\`\`bash
./start.sh
\`\`\`

Edit \`env_development\` first (port, LAN IP, \`DEV_JWT_TOKEN\`, \`NEXT_PUBLIC_APP_URL\`).

## Production

- URL: \`https://${NAME}.apps.vtc.com\` (set in \`.env.production\` when created)
- \`APP_NAME=${NAME}\`

## Repository

\`\`\`bash
git remote add origin <gitea-url>/zeresoft/${NAME}.git
\`\`\`
README

cat > "$APP_DIR/env_development" <<ENV
NODE_ENV=development
PORT=${PORT}

# Dev server: listen on all interfaces (phones on LAN)
DEV_BIND_HOST=0.0.0.0
DEV_LAN_HOST=${LAN_IP}

MONGODB_DEV_URI=mongodb://localhost:27017
MONGODB_URI=mongodb://localhost:27017
PUBLISHER_DB_NAME=db_2_2

JWT_SECRET=dev-secret-key-change-in-production
# Paste a dev JWT from VTC (group context) after first login:
DEV_JWT_TOKEN=

NEXT_PUBLIC_APP_URL=http://${LAN_IP}:${PORT}
NEXT_PUBLIC_DEFAULT_GROUP_ID=2
NEXT_PUBLIC_VTC_JOIN_URL=https://vtc.com
NEXT_PUBLIC_VTC_CREATE_SPACE_URL=https://vtc.com
NEXT_PUBLIC_VTC_CREATE_NETWORK_URL=https://vtc.com
NEXT_PUBLIC_APP_DISPLAY_NAME=${NAME}

APP_NAME=${NAME}
APP_PORT=${PORT}
ENV

git -C "$APP_DIR" init -b main >/dev/null
git -C "$APP_DIR" add .gitignore README.md env_development
if git -C "$APP_DIR" commit -m "init: $NAME" >/dev/null 2>&1; then
  GIT_NOTE="initial commit init: $NAME"
else
  GIT_NOTE="init only (set git user.name / user.email to commit)"
fi

echo ""
echo "Created: $APP_DIR"
echo "Rules:   $APP_DIR/.cursor/rules/00-vtc-central.mdc (stub → $CENTRAL_RULES)"
echo "Files:   .gitignore, README.md, env_development (port ${PORT})"
echo "Git:     branch main — $GIT_NOTE"
echo ""

if command -v cursor >/dev/null 2>&1; then
  echo "Opening in Cursor..."
  cursor "$APP_DIR"
fi

echo "Next steps:"
echo "  1. Edit env_development — DEV_JWT_TOKEN, DEV_LAN_HOST, display name, production URL"
echo "  2. Scaffold the Next.js app (~/cursor_rules/rules/scaffold-checklist.mdc)"
echo "  3. Add .env.production and git remote when ready"

# A child script cannot cd the parent shell; hand off an interactive shell in APP_DIR instead.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  cd "$APP_DIR" || exit 1
elif [[ -t 0 && -t 1 ]]; then
  echo ""
  echo "Ready in: $APP_DIR"
  cd "$APP_DIR" || exit 1
  exec "${SHELL:-/bin/bash}"
else
  echo ""
  echo "  cd $APP_DIR"
fi
