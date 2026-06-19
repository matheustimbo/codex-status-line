#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG_PATH="${CODEX_CONFIG_PATH:-$CODEX_HOME/config.toml}"
PRESET="${STATUSLINE_PRESET:-full}"

case "$PRESET" in
  full)
    DEFAULT_ITEMS="model-with-reasoning,git-branch,context-used,five-hour-limit,weekly-limit"
    ;;
  compact)
    DEFAULT_ITEMS="model-with-reasoning,context-remaining,git-branch"
    ;;
  tokens)
    DEFAULT_ITEMS="model-with-reasoning,git-branch,context-used,used-tokens,total-input-tokens,total-output-tokens"
    ;;
  all)
    DEFAULT_ITEMS="model-with-reasoning,git-branch,context-used,context-remaining,five-hour-limit,weekly-limit,used-tokens,total-input-tokens,total-output-tokens,thread-id,task-progress,current-dir"
    ;;
  *)
    echo "Error: unknown STATUSLINE_PRESET '$PRESET'." >&2
    echo "Valid presets: full, compact, tokens, all" >&2
    exit 1
    ;;
esac

ITEMS="${STATUSLINE_ITEMS:-${CODEX_STATUS_LINE:-$DEFAULT_ITEMS}}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required to safely update config.toml." >&2
  exit 1
fi

python3 - "$CONFIG_PATH" "$ITEMS" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import re
import shutil
import sys
import tempfile

try:
    import tomllib
except ModuleNotFoundError:
    tomllib = None

config_path = pathlib.Path(sys.argv[1]).expanduser()
items = [item.strip() for item in sys.argv[2].split(",") if item.strip()]

known_items = {
    "model-with-reasoning",
    "model",
    "reasoning",
    "git-branch",
    "git",
    "context-used",
    "context-remaining",
    "five-hour-limit",
    "weekly-limit",
    "used-tokens",
    "total-input-tokens",
    "total-output-tokens",
    "thread-id",
    "task-progress",
    "current-dir",
    "run-state",
    "thread-title",
    "codex-version",
}

if not items:
    raise SystemExit("Error: no status-line items configured.")

unknown = [item for item in items if item not in known_items]
if unknown:
    valid = ", ".join(sorted(known_items))
    raise SystemExit(
        "Error: unknown status-line item(s): "
        + ", ".join(unknown)
        + "\nValid items: "
        + valid
    )

config_path.parent.mkdir(parents=True, exist_ok=True)
old_text = config_path.read_text() if config_path.exists() else ""

if tomllib is not None:
    try:
        tomllib.loads(old_text or "")
    except tomllib.TOMLDecodeError as exc:
        raise SystemExit(f"Error: {config_path} is not valid TOML: {exc}") from exc

new_setting = "status_line = [" + ", ".join(json.dumps(item) for item in items) + "]\n"
lines = old_text.splitlines(keepends=True)

table_re = re.compile(r"^\s*\[[^\]]+\]\s*(?:#.*)?$")
tui_re = re.compile(r"^\s*\[tui\]\s*(?:#.*)?$")
setting_re = re.compile(r"^\s*status_line\s*=")

tui_index = next((i for i, line in enumerate(lines) if tui_re.match(line)), None)

def find_table_end(start: int) -> int:
    for index in range(start, len(lines)):
        if table_re.match(lines[index]):
            return index
    return len(lines)

def find_setting_end(start: int) -> int:
    balance = 0
    saw_array = False
    for index in range(start, len(lines)):
        line = lines[index]
        balance += line.count("[") - line.count("]")
        saw_array = saw_array or "[" in line
        if not saw_array or balance <= 0:
            return index + 1
    return start + 1

if tui_index is None:
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"
    if lines and lines[-1].strip():
        lines.append("\n")
    lines.extend(["[tui]\n", new_setting])
else:
    section_start = tui_index + 1
    section_end = find_table_end(section_start)
    setting_index = next(
        (i for i in range(section_start, section_end) if setting_re.match(lines[i])),
        None,
    )
    if setting_index is None:
        insert_at = section_end
        if insert_at > section_start and lines[insert_at - 1].strip():
            lines.insert(insert_at, "\n")
            insert_at += 1
        lines.insert(insert_at, new_setting)
        if insert_at + 1 < len(lines) and table_re.match(lines[insert_at + 1]):
            lines.insert(insert_at + 1, "\n")
    else:
        setting_end = find_setting_end(setting_index)
        lines[setting_index:setting_end] = [new_setting]

new_text = "".join(lines)
if tomllib is not None:
    tomllib.loads(new_text)

if config_path.exists() and new_text != old_text:
    stamp = dt.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_path = config_path.with_name(config_path.name + f".bak.{stamp}")
    shutil.copy2(config_path, backup_path)
else:
    backup_path = None

with tempfile.NamedTemporaryFile(
    "w", encoding="utf-8", dir=str(config_path.parent), delete=False
) as tmp:
    tmp.write(new_text)
    tmp_path = pathlib.Path(tmp.name)

tmp_path.replace(config_path)

print(f"Updated {config_path}")
if backup_path:
    print(f"Backup: {backup_path}")
print("Status line:", ", ".join(items))
PY

echo
echo "Done. Restart Codex CLI, or run /statusline inside Codex to adjust interactively."
