# Global rules (apply to every project)

<!--
Single source of truth for every AI coding agent. Symlinked by modules/95-ai.sh to:
  ~/.claude/CLAUDE.md      (Claude Code)
  ~/.codex/AGENTS.md       (Codex)
  ~/.gemini/GEMINI.md      (Gemini CLI)
Edit this file — never the symlinks — so the rules can't drift between agents.
-->

## Never start servers or run git

- **Never start a dev/app server** — no `npm run dev`, `next dev`, `vite`, `yarn start`, or any equivalent that launches a running server. The user runs their own dev server.
- **Never run any git command** — no `git add/commit/push/status/checkout` or any other git subcommand. The user manages git themselves.

For UI/visual work: make the code change and describe what to verify. Do not spin up a server to screenshot. If verification truly needs a running app, ask the user to check on their already-running server.

## Tokens

Be conservative with tokens and stay focused on what was asked. Use direct file reads and targeted searches rather than broad exploration. Reserve subagents for genuinely complex multi-step research — not for reading a few files.

## Secrets

`~/Documents/CodeStuff/dotfiles` is a **public** repo. Never write credentials, tokens, private repo URLs, or org names into it. Secrets belong in `~/.secrets` (gitignored); the repo manifest belongs in `~/.config/repos.txt`.
