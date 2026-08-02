---
type: config
title: Sources Configuration — {{PROJECT_NAME}} Knowledge Hub
description: Declares the data sources available to /km-gather for this hub.
tags: [config, sources, gather]
resource: ./
timestamp: {{INIT_DATE}}
---

# Sources — {{PROJECT_NAME}} Knowledge Hub

_Last updated: {{INIT_DATE}} by {{HUB_OWNER}}_
_Edit directly or let `/km-gather` update this file through Q&A._

## Universal (always available)

These source types work in every hub without any configuration:

- **files** — one or more file paths provided at runtime
- **folder** — scan a local directory; filter by file type or date
- **paste** — content pasted directly into chat

## Configured sources

_Add entries here as your hub connects to external tools._
_Run `/km-gather` and answer "yes" when asked to add a source — it will guide you through the fields._

<!-- Template for a new entry:

### [Descriptive name for this source]
Type: mcp
Tool: [tool or function name, e.g. search_transcripts]
Description: [What this source contains and when to use it]
Added: YYYY-MM-DD by [name]

-->
