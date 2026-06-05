
# Ai-Tools (ai-tools)



## Example Usage

```json
"features": {
    "ghcr.io/bobrossthepainter/devcontainer-features/ai-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| claude | Install Claude Code CLI? | boolean | false |
| codex | Install OpenAI Codex CLI? | boolean | false |
| pi | Install Pi Coding Agent Harness? | boolean | false |

## Supported Tools

- **Claude Code CLI** — Anthropic's CLI for Claude. See [claude.ai](https://claude.ai) for more information.
- **OpenAI Codex CLI** — OpenAI's coding agent. Installed via npm (`@openai/codex`).

Both tools default to not being installed. Enable the ones you need via the feature options.

## OS Support

`bash` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bobrossthepainter/devcontainer-features/blob/main/src/ai-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
