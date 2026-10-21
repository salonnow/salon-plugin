# Salon — plugins for Claude and ChatGPT

Run your beauty salon on **SALON** from Claude or ChatGPT, through the Salon connector
(`https://mcp.salon.now/mcp`). One repository, one folder per platform:

- **[`claude/`](claude/)** — the Claude plugin: the connector and the `salon-operations` skill.
  This is the folder the Anthropic directory reads. See [`claude/README.md`](claude/README.md).
- **[`openai/`](openai/)** — what ChatGPT's plugin directory adds: its manifest, MCP config and
  assets. `openai/build-zip.sh` builds the ZIP from this folder plus the skill in
  `claude/skills/`, which lives only there.

Support: **soporte@salon.now**. Licensed under the Apache License, Version 2.0 — see `LICENSE`;
the SALON and SALON NOW names are not licensed with the plugins (see `NOTICE`).
