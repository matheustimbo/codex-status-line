# codex-status-line

Claude-style status line for Codex CLI.

Current public Codex CLI renders `tui.status_line` as a native one-line list of item IDs. To match Claude Code behavior, this repo ships two pieces:

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

It backs up `~/.codex/config.toml` before changing an existing file.

## Prerequisite: patched Codex

Current public Codex CLI must be patched before running the installer:

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

## Safety

`install.sh` checks whether the local `codex` binary appears to contain `status_line_command` support. If not, it exits before editing config so an unpatched Codex install is not broken.

Use `CODEX_STATUS_LINE_FORCE=1 bash install.sh` only when you know your Codex binary is patched.

## Local Validation

```bash
bash -n install.sh
bash -n statusline-command.sh
```

Rust compile-check was not run in this environment because `cargo` was not installed in `PATH`.

## License

MIT
