#!/usr/bin/env bash
# ~/.agents/scripts/sync.sh
# Idempotent symlink deployer. Run after cloning or pulling this repo.
#
# Usage:
#   agents sync         Add/update/remove skill symlinks at all consumers
#   agents status       Show what would change without modifying anything
#   agents help         Show this help
#
# Override default consumers (opencode, claude, hermes) by exporting
# AGENTS_CONSUMERS as space-separated "label:path" entries. "~" expands to
# $HOME in paths.
#
# Examples:
#   AGENTS_CONSUMERS="claude:~/.claude/skills" agents sync
#   AGENTS_CONSUMERS="a:~/a b:~/b opencode:~/.config/opencode/skills" agents sync

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

DEFAULT_CONSUMERS=(
  "opencode:$HOME/.config/opencode/skills"
  "claude:$HOME/.claude/skills"
  "hermes:$HOME/.hermes/skills"
)

expand_path() {
  case "$1" in
    "~") printf '%s' "$HOME" ;;
    "~/"*) printf '%s/%s' "$HOME" "${1#~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

usage() {
  sed -n '2,16p' "$0"
}

cmd=${1:-sync}
shift || true

case "$cmd" in
  help|-h|--help) usage; exit 0 ;;
  status) DRY_RUN=1 ;;
  sync)   DRY_RUN=0 ;;
  *)     echo "Unknown command: $cmd" >&2; usage >&2; exit 2 ;;
esac

if [ ! -d "$SKILLS_DIR" ]; then
  echo "error: skills directory not found at $SKILLS_DIR" >&2
  exit 1
fi

# Collect current skills (bash 3 + macOS-compatible)
current_skills=()
for d in "$SKILLS_DIR"/*/; do
  [ -d "$d" ] || continue
  current_skills+=("$(basename "$d")")
done

contains() {
  local needle="$1"; shift
  for s in "$@"; do [ "$s" = "$needle" ] && return 0; done
  return 1
}

added=0; updated=0; removed=0; unchanged=0; skipped=0

# Resolve consumer list
if [ -n "${AGENTS_CONSUMERS:-}" ]; then
  consumers_raw=$AGENTS_CONSUMERS
else
  consumers_raw="${DEFAULT_CONSUMERS[*]}"
fi

for consumer in $consumers_raw; do
  IFS=':' read -r label target_raw <<< "$consumer"
  target_dir=$(expand_path "$target_raw")

  if [ "$DRY_RUN" = 1 ] && [ ! -d "$target_dir" ]; then
    echo "[$label] would create dir: $target_dir"
  elif [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
  fi

  for skill in "${current_skills[@]}"; do
    source="$SKILLS_DIR/$skill"
    link="$target_dir/$skill"

    # Normalize: strip trailing slashes AND resolve relative paths so equivalent
    # targets compare equal regardless of how they were originally written.
    norm() {
      local p="${1%/}"
      case "$p" in
        /*) printf '%s' "$p" ;;
        *) (cd "$(dirname "$p")" 2>/dev/null && printf '%s/%s' "$(pwd -P)" "$(basename "$p")") ;;
      esac
    }

    if [ -L "$link" ] && [ "$(norm "$(readlink "$link")")" = "$(norm "$source")" ]; then
      unchanged=$((unchanged+1))
      continue
    fi

    if [ -L "$link" ]; then
      verb="update"
      if [ "$DRY_RUN" = 1 ]; then
        :
      else
        rm "$link" && ln -s "$source" "$link"
      fi
      updated=$((updated+1))
    elif [ -e "$link" ]; then
      verb="skip"
      echo "[$label] WARN: $link exists and is not a symlink, skipping" >&2
      skipped=$((skipped+1))
      continue
    else
      verb="add"
      if [ "$DRY_RUN" = 1 ]; then
        :
      else
        ln -s "$source" "$link"
      fi
      added=$((added+1))
    fi

    echo "[$label] $verb: $skill -> $source"
  done

  # Remove stale symlinks pointing into our skills dir
  [ -d "$target_dir" ] || continue
  for entry in "$target_dir"/*; do
    [ -L "$entry" ] || continue
    target=$(readlink "$entry")
    case "$target" in
      "$SKILLS_DIR"/*)
        skill_name=$(basename "$entry")
        if ! contains "$skill_name" "${current_skills[@]}"; then
          echo "[$label] remove stale: $skill_name -> $target"
          if [ "$DRY_RUN" = 1 ]; then
            removed=$((removed+1))
          else
            rm "$entry"
            removed=$((removed+1))
          fi
        fi
        ;;
    esac
  done
done

mode_tag=""
[ "$DRY_RUN" = 1 ] && mode_tag=" (dry-run)"
echo
echo "Summary: added=$added updated=$updated removed=$removed unchanged=$unchanged skipped=$skipped$mode_tag"
