<div align="center">

# codex-status-line

**A small status-line installer for [Codex CLI](https://developers.openai.com/codex)** — keep model, reasoning, git branch, context, and Codex usage limits visible in the terminal footer.

[![One-line install](https://img.shields.io/badge/install-one%20line-brightgreen)](#one-line-install)
[![Codex CLI](https://img.shields.io/badge/Codex-CLI-blue)](https://developers.openai.com/codex)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)
[![PT-BR](https://img.shields.io/badge/language-PT--BR-green)](README.pt-BR.md)

**EN** · [PT-BR](README.pt-BR.md)

</div>

---

Codex CLI already has a native TUI footer. This repo configures that footer by setting `tui.status_line` in `~/.codex/config.toml`.

Default layout:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

That gives you the Codex equivalent of the original Claude status line:

- active model and reasoning effort
- current git branch
- context usage
- 5-hour usage limit
- weekly usage limit

No API calls, no background process, no custom renderer. Codex renders the footer with its own TUI styling.

## Requirements

- Codex CLI with `tui.status_line` support
- `bash`
- `python3`

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

Then restart Codex CLI. You can also adjust the footer interactively with `/statusline`.

The installer preserves your existing `~/.codex/config.toml`, updates only `tui.status_line`, and writes a timestamped backup before changing an existing file.

## Presets

Use `STATUSLINE_PRESET` to choose a layout:

```bash
STATUSLINE_PRESET=compact curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

| Preset | Items |
| --- | --- |
| `full` | `model-with-reasoning`, `git-branch`, `context-used`, `five-hour-limit`, `weekly-limit` |
| `compact` | `model-with-reasoning`, `context-remaining`, `git-branch` |
| `tokens` | `model-with-reasoning`, `git-branch`, `context-used`, `used-tokens`, `total-input-tokens`, `total-output-tokens` |
| `all` | model, git, context, limits, token counters, thread, task progress, current dir |

## Custom Layout

Set `STATUSLINE_ITEMS` to an explicit comma-separated list:

```bash
STATUSLINE_ITEMS="model-with-reasoning,git-branch,context-remaining,used-tokens" bash install.sh
```

Known item IDs:

```text
model-with-reasoning
model
reasoning
git-branch
git
context-used
context-remaining
five-hour-limit
weekly-limit
used-tokens
total-input-tokens
total-output-tokens
thread-id
task-progress
current-dir
run-state
thread-title
codex-version
```

## Manual Install

Edit `~/.codex/config.toml`:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Restart Codex CLI.

## Claude Code Difference

Claude Code status lines run an external command that receives JSON on stdin. Codex CLI uses native footer item IDs in `config.toml`. This repo intentionally configures the native Codex footer instead of emulating Claude's command contract.

## License

MIT
