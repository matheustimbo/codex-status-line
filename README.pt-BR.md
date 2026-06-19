<div align="center">

# codex-status-line

**Status line para o [Codex CLI](https://developers.openai.com/codex)** — deixe modelo, reasoning, branch do git, contexto e limites do Codex visíveis no footer do terminal.

[![Instalação em uma linha](https://img.shields.io/badge/instala%C3%A7%C3%A3o-uma%20linha-brightgreen)](#instalação-em-uma-linha)
[![Codex CLI](https://img.shields.io/badge/Codex-CLI-blue)](https://developers.openai.com/codex)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-yellow)](LICENSE)
[![PT-BR](https://img.shields.io/badge/idioma-PT--BR-green)](README.pt-BR.md)

[EN](README.md) · **PT-BR**

</div>

---

O Codex CLI já tem um footer nativo na TUI. Este repo configura esse footer definindo `tui.status_line` em `~/.codex/config.toml`.

Layout padrão:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Isso entrega o equivalente no Codex da status line original do Claude:

- modelo ativo e nível de reasoning
- branch atual do git
- uso de contexto
- limite de uso de 5 horas
- limite semanal

Sem chamadas de API, sem processo em background, sem renderer customizado. O proprio Codex renderiza o footer com o estilo da TUI.

## Requisitos

- Codex CLI com suporte a `tui.status_line`
- `bash`
- `python3`

## Instalação Em Uma Linha

```bash
curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

Depois reinicie o Codex CLI. Você também pode ajustar o footer interativamente com `/statusline`.

O instalador preserva seu `~/.codex/config.toml`, altera apenas `tui.status_line` e cria um backup com timestamp antes de mudar um arquivo existente.

## Presets

Use `STATUSLINE_PRESET` para escolher um layout:

```bash
STATUSLINE_PRESET=compact curl -fsSL https://raw.githubusercontent.com/matheustimbo/codex-status-line/main/install.sh | bash
```

| Preset | Itens |
| --- | --- |
| `full` | `model-with-reasoning`, `git-branch`, `context-used`, `five-hour-limit`, `weekly-limit` |
| `compact` | `model-with-reasoning`, `context-remaining`, `git-branch` |
| `tokens` | `model-with-reasoning`, `git-branch`, `context-used`, `used-tokens`, `total-input-tokens`, `total-output-tokens` |
| `all` | modelo, git, contexto, limites, contadores de token, thread, progresso da tarefa, diretório atual |

## Layout Customizado

Defina `STATUSLINE_ITEMS` com uma lista explícita separada por vírgulas:

```bash
STATUSLINE_ITEMS="model-with-reasoning,git-branch,context-remaining,used-tokens" bash install.sh
```

IDs conhecidos:

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

## Instalação Manual

Edite `~/.codex/config.toml`:

```toml
[tui]
status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]
```

Reinicie o Codex CLI.

## Diferença Para Claude Code

A status line do Claude Code roda um comando externo que recebe JSON via stdin. O Codex CLI usa IDs nativos de footer no `config.toml`. Este repo configura o footer nativo do Codex em vez de emular o contrato de comando do Claude.

## Licença

MIT
