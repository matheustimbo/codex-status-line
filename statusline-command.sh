#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"

json_get() {
  local expr="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r "$expr // empty" 2>/dev/null <<<"$payload"
  else
    PAYLOAD="$payload" python3 - "$expr" <<'PY' 2>/dev/null
import json
import os
import sys

data = json.loads(os.environ["PAYLOAD"])
path = sys.argv[1].strip(".").split(".")
value = data
for part in path:
    if not part:
        continue
    if isinstance(value, dict):
        value = value.get(part)
    else:
        value = None
        break
if value is not None:
    print(value)
PY
  fi
}

color() {
  local code="$1"
  shift
  printf '\033[%sm%s\033[0m' "$code" "$*"
}

dim() { color "2" "$*"; }
green() { color "32" "$*"; }
cyan() { color "36" "$*"; }
yellow() { color "33" "$*"; }
magenta() { color "35" "$*"; }

SHOW_MODEL="${SHOW_MODEL:-1}"
SHOW_GIT="${SHOW_GIT:-1}"
SHOW_CONTEXT="${SHOW_CONTEXT:-1}"
SHOW_LIMITS="${SHOW_LIMITS:-1}"
SHOW_SESSION="${SHOW_SESSION:-0}"
STATUSLINE_SEP="${STATUSLINE_SEP:- · }"
STATUSLINE_MAX_WIDTH="${STATUSLINE_MAX_WIDTH:-$(json_get '.width')}"
STATUSLINE_MAX_WIDTH="${STATUSLINE_MAX_WIDTH:-120}"

model="$(json_get '.model.with_reasoning')"
branch="$(json_get '.git.branch')"
context="$(json_get '.context.used_percent')"
five="$(json_get '.limits.five_hour.text')"
weekly="$(json_get '.limits.weekly.text')"
session="$(json_get '.session.id')"

parts=()

if [ "$SHOW_MODEL" != "0" ] && [ -n "$model" ]; then
  parts+=("$(cyan "$model")")
fi
if [ "$SHOW_GIT" != "0" ] && [ -n "$branch" ]; then
  parts+=("$(green "$branch")")
fi
if [ "$SHOW_CONTEXT" != "0" ] && [ -n "$context" ]; then
  parts+=("$(yellow "Context ${context}% used")")
fi
if [ "$SHOW_LIMITS" != "0" ] && [ -n "$five" ]; then
  parts+=("$(magenta "$five")")
fi
if [ "$SHOW_LIMITS" != "0" ] && [ -n "$weekly" ]; then
  parts+=("$(magenta "$weekly")")
fi
if [ "$SHOW_SESSION" != "0" ] && [ -n "$session" ]; then
  parts+=("$(dim "$session")")
fi

if [ "${#parts[@]}" -eq 0 ]; then
  exit 0
fi

line=""
plain_len=0
sep_plain_len=${#STATUSLINE_SEP}
soft_width=$((STATUSLINE_MAX_WIDTH - 8))
[ "$soft_width" -lt 40 ] && soft_width=40

for part in "${parts[@]}"; do
  plain="$(printf '%s' "$part" | sed $'s/\033\\[[0-9;]*m//g')"
  part_len=${#plain}
  if [ -n "$line" ] && [ $((plain_len + sep_plain_len + part_len)) -gt "$soft_width" ]; then
    printf '%b\n' "$line"
    line="$part"
    plain_len=$part_len
  elif [ -n "$line" ]; then
    line="${line}$(dim "$STATUSLINE_SEP")${part}"
    plain_len=$((plain_len + sep_plain_len + part_len))
  else
    line="$part"
    plain_len=$part_len
  fi
done

printf '%b\n' "$line"
