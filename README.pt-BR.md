# codex-status-line

Status line estilo Claude para o Codex CLI.

O Codex CLI público hoje renderiza `tui.status_line` como uma lista nativa de itens em uma única linha. Para ficar igual ao Claude Code, este repo entrega duas peças:

- `patches/codex-status-line-command.patch`: patch para o TUI do Codex aceitar `[tui.status_line_command]`.
- `statusline-command.sh`: renderer externo que recebe JSON via stdin, usa ANSI e pode emitir múltiplas linhas.

## Instalação

1. Aplique o patch no código-fonte do Codex:

```bash
git clone https://github.com/openai/codex.git
cd codex
git apply /Users/matheustimbo/Documents/codex-status-line/patches/codex-status-line-command.patch
cd codex-rs
cargo build -p codex-cli --bin codex --release
```

2. Coloque o binário gerado antes do Codex instalado no `PATH`:

```bash
export PATH="$PWD/target/release:$PATH"
```

3. Instale a status line:

```bash
bash /Users/matheustimbo/Documents/codex-status-line/install.sh
```

O instalador copia `statusline-command.sh` para `~/.codex/statusline-command.sh` e adiciona:

```toml
[tui.status_line_command]
command = "bash ~/.codex/statusline-command.sh"
refresh_interval_ms = 1000
timeout_ms = 1000
```

Ele cria backup do `~/.codex/config.toml` antes de alterar um arquivo existente.

## Opções

Configure pelo ambiente do comando:

```bash
SHOW_LIMITS=0 SHOW_SESSION=1 STATUSLINE_SEP=" | " bash ~/.codex/statusline-command.sh
```

Opções suportadas:

- `SHOW_MODEL=0|1`
- `SHOW_GIT=0|1`
- `SHOW_CONTEXT=0|1`
- `SHOW_LIMITS=0|1`
- `SHOW_SESSION=0|1`
- `STATUSLINE_SEP=" · "`
- `STATUSLINE_MAX_WIDTH=120`
- `STATUSLINE_REFRESH_INTERVAL_MS=1000`
- `STATUSLINE_TIMEOUT_MS=1000`

Os itens de limite incluem o horário de reset quando o Codex tem essa informação no snapshot de rate limit.

## Segurança

O `install.sh` verifica se o binário `codex` parece conter suporte a `status_line_command`. Se não parecer, ele falha antes de editar o config para não quebrar o Codex não-patcheado.

Use `CODEX_STATUS_LINE_FORCE=1 bash install.sh` apenas se você sabe que está usando um build patcheado.

## Validação Local

```bash
bash -n install.sh
bash -n statusline-command.sh
```

A checagem de compilação Rust não foi executada neste ambiente porque `cargo` não estava instalado no `PATH`.

## Licença

MIT
