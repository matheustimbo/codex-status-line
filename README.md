# codex-status-line

Claude-style status line for Codex CLI.

The installer works with the public Codex CLI through `tui.status_line`. For Claude Code-style ANSI and multiline output, the repo also provides a renderer for patched builds:

- `patches/codex-status-line-command.patch`: a Codex TUI patch that adds `[tui.status_line_command]`.
- `statusline-command.sh`: an external renderer that receives JSON on stdin, emits ANSI, and can output multiple lines.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

The installer copies `statusline-command.sh` to `~/.codex/statusline-command.sh` and appends:

```toml
[tui.status_line_command]
command = "bash ~/.codex/statusline-command.sh"
refresh_interval_ms = 1000
timeout_ms = 1000
```

Without the patch, it automatically configures the official native status line:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

It backs up `~/.codex/config.toml` before changing an existing file.

## Optional: advanced renderer

To use the external renderer instead of the native status line, patch Codex before running the installer:

```bash
git clone https://github.com/openai/codex.git
cd codex
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/patches/codex-status-line-command.patch | git apply
cd codex-rs
cargo build -p codex-cli --bin codex --release
```

Put the patched binary first in `PATH`:

```bash
export PATH="$PWD/target/release:$PATH"
```

## Options

Configure display with environment variables:

```bash
SHOW_LIMITS=0 SHOW_SESSION=1 STATUSLINE_SEP=" | " bash ~/.codex/statusline-command.sh
```

Supported options:

- `SHOW_MODEL=0|1`
- `SHOW_GIT=0|1`
- `SHOW_CONTEXT=0|1`
- `SHOW_LIMITS=0|1`
- `SHOW_SESSION=0|1`
- `STATUSLINE_SEP=" · "`
- `STATUSLINE_MAX_WIDTH=120`
- `STATUSLINE_REFRESH_INTERVAL_MS=1000`
- `STATUSLINE_TIMEOUT_MS=1000`

Limit items include reset times when Codex has them in the rate-limit snapshot.

## Compatibility

`install.sh` checks whether the local `codex` binary contains `status_line_command` support. Otherwise it uses the native configuration supported by the official Codex CLI.

Use `CODEX_STATUS_LINE_FORCE=1 bash install.sh` only when you know your Codex binary is patched.

## Local Validation

```bash
bash -n install.sh
bash -n statusline-command.sh
```

Rust compile-check was not run in this environment because `cargo` was not installed in `PATH`.

## License

MIT
