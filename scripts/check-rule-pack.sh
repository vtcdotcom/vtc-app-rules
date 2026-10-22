#!/usr/bin/env bash
# List ~/apps repos with missing or outdated copied Cursor rule packs.
#
# Usage:
#   ~/apps/cursor/scripts/check-rule-pack.sh           # all apps
#   ~/apps/cursor/scripts/check-rule-pack.sh my-app  # one app
#
# Does not copy — use add.sh or migrate-all.sh to refresh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=copy-cursor-rules.sh
source "$SCRIPT_DIR/copy-cursor-rules.sh"

CURSOR_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"

resolve_default_scan_root() {
	if [[ -n "${APPS_ROOT:-}" ]]; then
		echo "$APPS_ROOT"
		return 0
	fi
	if [[ -d "$HOME/apps" ]]; then
		echo "$HOME/apps"
		return 0
	fi
	if [[ -d "$(dirname "$CURSOR_REPO")/apps" ]]; then
		echo "$(dirname "$CURSOR_REPO")/apps"
		return 0
	fi
	echo ""
}

APPS_ROOT="$(resolve_default_scan_root)"

current_ver="$(read_rule_pack_version "$CURSOR_RULES")"
echo "Current rule pack: $current_ver"
echo ""

check_one() {
	local app_dir="$1"
	local name
	local app_ver

	name="$(basename "$app_dir")"
	app_ver="$(read_rule_pack_version "$app_dir/.cursor/rules")"

	if [[ "$app_ver" == "$current_ver" ]]; then
		echo "OK       $name ($app_ver)"
		return 0
	fi
	if [[ "$app_ver" == "(none)" ]]; then
		echo "MISSING  $name"
		return 1
	fi
	echo "OUTDATED $name ($app_ver → $current_ver)"
	return 1
}

resolve_target() {
	local input="${1:-}"

	if [[ -z "$input" ]]; then
		if [[ -z "$APPS_ROOT" ]]; then
			echo "ERROR: pass a project directory (no default apps folder found)." >&2
			echo "Usage: $(basename "$0") <project-dir>" >&2
			exit 1
		fi
		echo "$APPS_ROOT"
		return 0
	fi

	if [[ "$input" == /* ]]; then
		echo "$input"
	elif [[ -d "$input" ]]; then
		(cd "$input" && pwd)
	else
		echo "$APPS_ROOT/$input"
	fi
}

TARGET="$(resolve_target "${1:-}")"

outdated=0
checked=0

if [[ "$TARGET" == "$APPS_ROOT" ]]; then
	for app_dir in "$APPS_ROOT"/*/; do
		name="$(basename "$app_dir")"
		[[ "$name" == "cursor" ]] && continue
		[[ -d "$app_dir" ]] || continue
		checked=$((checked + 1))
		check_one "$app_dir" || outdated=$((outdated + 1))
	done
	echo ""
	echo "Checked: $checked — outdated or missing: $outdated"
else
	check_one "$TARGET" || outdated=1
	[[ "$outdated" -eq 0 ]] || exit 1
fi
