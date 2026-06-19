# codex-status-line

Claude-style status line for Codex CLI.

Current public Codex CLI renders `tui.status_line` as a native one-line list of item IDs. To match Claude Code behavior, this repo ships two pieces:

- `patches/codex-status-line-command.patch`: a Codex TUI patch that adds `[tui.status_line_command]`.
- `statusline-command.sh`: an external renderer that receives JSON on stdin, emits ANSI, and can output multiple lines.

## Install

1. Apply the patch to Codex source:

```bash
git clone https://github.com/openai/codex.git
cd codex
git apply /Users/matheustimbo/Documents/codex-status-line/patches/codex-status-line-command.patch
cd codex-rs
cargo build -p codex-cli --bin codex --release
```

2. Put the patched binary first in `PATH`:

```bash
export PATH="$PWD/target/release:$PATH"
```

3. Install the status line:

```bash
bash /Users/matheustimbo/Documents/codex-status-line/install.sh
```

The installer copies `statusline-command.sh` to `~/.codex/statusline-command.sh` and appends:

```toml
[tui.status_line_command]
command = "bash ~/.codex/statusline-command.sh"
refresh_interval_ms = 1000
timeout_ms = 1000
```

It backs up `~/.codex/config.toml` before changing an existing file.

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
