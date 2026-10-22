#!/usr/bin/env bash
# Install VTC central-rules stub into each subfolder of a parent directory.
#
# Usage:
#   ~/cursor_rules/scripts/add.sh              # prompt for parent folder
#   ~/cursor_rules/scripts/add.sh ~/games      # all immediate subfolders
#   ~/cursor_rules/scripts/add.sh ~/apps/dev   # full path
#
# Installs <project>/.cursor/rules/00-vtc-central.mdc (stub → ~/cursor_rules/rules/).
# (.cursor/ is gitignored in app repos — never commit rules)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
CENTRAL_RULES="$CURSOR_REPO/rules"
STUB_SRC="$CURSOR_REPO/stubs/vtc-central.mdc"

DRY_RUN=false
PARENT_ARG=""

usage() {
	cat <<EOF
Usage:
  $(basename "$0") [--dry-run] [<parent-folder>]

Installs the central-rules stub in each immediate subfolder.
Agents read ~/cursor_rules/rules/ from that stub.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--dry-run)
		DRY_RUN=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		echo "ERROR: unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	*)
		PARENT_ARG="$1"
		shift
		;;
	esac
done

resolve_parent() {
	local input="${1:-}"

	if [[ -z "$input" ]]; then
		echo "VTC Cursor — install central-rules stub into subfolders" >&2
		echo "  Stub:         $STUB_SRC" >&2
		echo "  Central:      $CENTRAL_RULES" >&2
		echo "" >&2
		read -r -p "Parent folder path (each subfolder gets .cursor rules): " input
	fi

	if [[ -z "${input// }" ]]; then
		echo "ERROR: folder path cannot be empty." >&2
		exit 1
	fi

	if [[ "$input" == ~* ]]; then
		input="${input/#\~/$HOME}"
	fi

	if [[ ! -d "$input" ]]; then
		echo "ERROR: not a directory: $input" >&2
		exit 1
	fi

	(cd "$input" && pwd)
}

PARENT="$(resolve_parent "$PARENT_ARG")"

if [[ ! -f "$STUB_SRC" ]]; then
	echo "ERROR: stub not found: $STUB_SRC" >&2
	exit 1
fi
if [[ ! -d "$CENTRAL_RULES" ]]; then
	echo "ERROR: central rules not found: $CENTRAL_RULES" >&2
	exit 1
fi

STUB_ARGS=(--parent "$PARENT" --replace)
if $DRY_RUN; then
	STUB_ARGS+=(--dry-run)
fi

"$SCRIPT_DIR/push-stub.sh" "${STUB_ARGS[@]}"
