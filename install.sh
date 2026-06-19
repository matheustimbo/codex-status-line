#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG_PATH="${CODEX_CONFIG_PATH:-$CODEX_HOME/config.toml}"
SCRIPT_DEST="${STATUSLINE_SCRIPT_PATH:-$CODEX_HOME/statusline-command.sh}"
REFRESH_INTERVAL_MS="${STATUSLINE_REFRESH_INTERVAL_MS:-1000}"
TIMEOUT_MS="${STATUSLINE_TIMEOUT_MS:-1000}"
FORCE="${CODEX_STATUS_LINE_FORCE:-0}"
RAW_BASE_URL="${CODEX_STATUS_LINE_RAW_BASE_URL:-https://raw.githubusercontent.com/matheustimbo/codex-status-line/main}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required to safely update config.toml." >&2
  exit 1
fi

if [ "$FORCE" != "1" ] && command -v codex >/dev/null 2>&1; then
  codex_bin="$(command -v codex)"
  if ! strings "$codex_bin" 2>/dev/null | grep -q "status_line_command"; then
    cat >&2 <<'EOF'
Error: this Codex binary does not appear to support tui.status_line_command.

Apply patches/codex-status-line-command.patch to Codex CLI and install that build first,
or rerun with CODEX_STATUS_LINE_FORCE=1 if you know your binary is patched.
EOF
    exit 1
  fi
fi

mkdir -p "$CODEX_HOME"

script_source=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$script_dir/statusline-command.sh" ]; then
    script_source="$script_dir/statusline-command.sh"
  fi
fi

if [ -n "$script_source" ]; then
  cp "$script_source" "$SCRIPT_DEST"
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required when install.sh is run without a local statusline-command.sh." >&2
    exit 1
  fi
  curl -fsSL "$RAW_BASE_URL/statusline-command.sh" -o "$SCRIPT_DEST"
fi
chmod 755 "$SCRIPT_DEST"

python3 - "$CONFIG_PATH" "$SCRIPT_DEST" "$REFRESH_INTERVAL_MS" "$TIMEOUT_MS" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import shlex
import shutil
import sys
import tempfile

try:
    import tomllib
except ModuleNotFoundError:
    tomllib = None

config_path = pathlib.Path(sys.argv[1]).expanduser()
script_path = pathlib.Path(sys.argv[2]).expanduser()
refresh_interval_ms = int(sys.argv[3])
timeout_ms = int(sys.argv[4])

if refresh_interval_ms < 250:
    raise SystemExit("Error: STATUSLINE_REFRESH_INTERVAL_MS must be at least 250.")
if timeout_ms < 1:
    raise SystemExit("Error: STATUSLINE_TIMEOUT_MS must be positive.")

config_path.parent.mkdir(parents=True, exist_ok=True)
old_text = config_path.read_text() if config_path.exists() else ""

if tomllib is not None:
    try:
        tomllib.loads(old_text or "")
    except tomllib.TOMLDecodeError as exc:
        raise SystemExit(f"Error: {config_path} is not valid TOML: {exc}") from exc

lines = old_text.splitlines(keepends=True)
new_lines: list[str] = []
skip = False
for line in lines:
    stripped = line.strip()
    if stripped == "[tui.status_line_command]":
        skip = True
        continue
    if skip and stripped.startswith("[") and stripped.endswith("]"):
        skip = False
    if not skip:
        new_lines.append(line)

if new_lines and not new_lines[-1].endswith("\n"):
    new_lines[-1] += "\n"
if new_lines and new_lines[-1].strip():
    new_lines.append("\n")

command = "bash " + shlex.quote(str(script_path))
new_lines.extend(
    [
        "[tui.status_line_command]\n",
        f"command = {json.dumps(command)}\n",
        f"refresh_interval_ms = {refresh_interval_ms}\n",
        f"timeout_ms = {timeout_ms}\n",
    ]
)

new_text = "".join(new_lines)
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
print(f"Installed command: {command}")
PY

echo
echo "Done. Restart a patched Codex CLI to see the command-backed status line."
