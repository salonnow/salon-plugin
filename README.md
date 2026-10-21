# Salon — Claude plugin

Run your beauty salon on **SALON** from Claude, by text or by voice: book, move, confirm and
cancel appointments; block hours of the agenda for the salon or one professional; keep the menu
and the professionals' assignments; add and update clients and read the client portfolio; see
closed months and today's sales; check the salon's own SALON subscription status (read-only —
payment happens in the SALON app); and write WhatsApp messages to clients that a person at the
salon then sends from the salon's own WhatsApp. Spanish-first, built for Mexican salons.

The plugin bundles two things:

- the **Salon connector** — the MCP server at `https://mcp.salon.now/mcp`, which reads and
  writes your salon's data through the SALON API under your own SALON account;
- the **`salon-operations` skill** — the workflow playbooks (which tool first, what to read back
  before a write, how a message to a client is written) and the output style, so Claude does
  not have to work the sequence out from tool names every conversation.

## How to connect

1. Install the plugin in Claude (the connector appears under **Connectors**).
2. Connect it: Claude sends you to `login.salon.now`, where you sign in with your SALON account
   and see exactly which permissions the connector asks for (sales, bookings, clients, contact).
3. Grant them. From then on Claude operates the salons your SALON profile is authorised for —
   the same permissions the app gives you, nothing more.

A SALON account is required (`https://salon.mx`). Which of your people may use the connector is
decided by the salon's owner in the SALON app.

## What data flows, and where

- Everything Claude reads or changes goes to **one destination only**: `mcp.salon.now`, the
  SALON connector, which in turn calls the SALON API under your account. The plugin itself
  stores nothing and calls nothing else.
- Tool results — appointments, client names, sales figures — become part of your conversation
  on Claude and are kept by it like any other message in that conversation.
- Phone numbers that come from SALON are shown masked, and the connector never reads a number
  out. One exception you ask for explicitly: when you request WhatsApp links for an audience
  you confirmed, each `wa.me` link carries that client's full number inside the link (that is
  what makes it open the chat), and those links are part of your conversation too.
- The connector never sends a message by itself: a WhatsApp message is left in the SALON app's
  queue (or handed to you as a link) and a person sends it.
- Every write — a booking, a cancellation, a block, a menu change, a new client, a queued
  message — is read back to you and happens only after you say yes. Asking it not to ask
  ("no me preguntes") does not skip that question.

## The OpenAI package (`openai/`)

The same connector and the same skill go to ChatGPT's plugin directory as a ZIP in OpenAI's own
layout. The repo root stays the Claude plugin (Claude reads `.claude-plugin/plugin.json` at the
root); the `openai/` folder holds only what OpenAI adds — `plugin.json` (the Agent Plugins
manifest with the listing, the review test cases and the publication fields under
`extensions.com.openai`), `mcp.json` (the one remote server, OAuth with dynamic client
registration) and `assets/` (the SALON mark). The skill is **not** copied there: it lives once,
at the root `skills/`, and `openai/build-zip.sh` assembles `dist/salon-openai-<version>.zip`
from the folder plus the root skill. The script refuses when the two manifests disagree on the
version — one public version (the connector's `CONNECTOR_VERSION`, this manifest, the OpenAI
manifest), bumped together. The demo video URL travels in `review.demo_recording_url`;
reviewer credentials are typed in OpenAI's dashboard, and the ZIP never carries them.

## Support

Write to **soporte@salon.now** (or support@salon.now). To cut the connection, revoke it in
Claude's connector settings or write to the same address and it is removed the same day.

## Licence and trademarks

Licensed under the Apache License, Version 2.0 — see `LICENSE`. The names SALON and SALON NOW,
and the SALON domains, are the property of SALON NOW INC and are not licensed with this plugin;
see `NOTICE`. A copy or modification of this plugin may not be presented as SALON, as SALON NOW,
or as an official SALON NOW INC product.
