# codex-status-line

Status line estilo Claude para o Codex CLI.

O instalador funciona no Codex CLI oficial usando `tui.status_line`. Para ter ANSI e múltiplas linhas como no Claude Code, o repo também oferece um renderer para builds patcheados:

- `patches/codex-status-line-command.patch`: patch para o TUI do Codex aceitar `[tui.status_line_command]`.
- `statusline-command.sh`: renderer externo que recebe JSON via stdin, usa ANSI e pode emitir múltiplas linhas.

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

O instalador copia `statusline-command.sh` para `~/.codex/statusline-command.sh` e adiciona:

```toml
[tui.status_line_command]
command = "bash ~/.codex/statusline-command.sh"
refresh_interval_ms = 1000
timeout_ms = 1000
```

Sem o patch, ele configura automaticamente a barra nativa oficial:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Ele cria backup do `~/.codex/config.toml` antes de alterar um arquivo existente.

## Opcional: renderer avançado

Para usar o renderer externo em vez da barra nativa, patcheie o Codex antes de rodar o instalador:

```bash
git clone https://github.com/openai/codex.git
cd codex
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/patches/codex-status-line-command.patch | git apply
cd codex-rs
cargo build -p codex-cli --bin codex --release
```

Coloque o binário gerado antes do Codex instalado no `PATH`:

```bash
export PATH="$PWD/target/release:$PATH"
```

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

## Compatibilidade

O `install.sh` verifica se o binário `codex` contém suporte a `status_line_command`. Caso contrário, usa a configuração nativa compatível com o Codex oficial.

Use `CODEX_STATUS_LINE_FORCE=1 bash install.sh` apenas se você sabe que está usando um build patcheado.

## Validação Local

```bash
bash -n install.sh
bash -n statusline-command.sh
```

A checagem de compilação Rust não foi executada neste ambiente porque `cargo` não estava instalado no `PATH`.

## Licença

MIT
