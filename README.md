# dotfiles

macOS (MacBook Pro) and Arch Linux (headless workstation, reached over Tailscale)
from one repo. Idempotent — re-run it any time; it asks before touching anything
that already exists.

## Setup

```sh
git clone https://github.com/wilspi/dotfiles ~/Documents/CodeStuff/dotfiles
cd ~/Documents/CodeStuff/dotfiles
./bootstrap.sh
```

```sh
./bootstrap.sh --dry-run              # show what it would do, change nothing
./bootstrap.sh --only shell,runtimes  # run just those modules
./bootstrap.sh --skip packages        # everything except package installs
./bootstrap.sh --conflict keep        # never replace an existing config file
./bootstrap.sh --conflict overwrite   # always replace (originals are backed up)
./bootstrap.sh --list                 # list module names
```

By default every conflict is an explicit prompt: **k**eep / **o**verwrite / **d**iff.
Overwritten files are backed up to `~/.dotfiles-backup/`.

## Layout

| Path         | What it is |
|--------------|------------|
| `bootstrap.sh` | The only entrypoint. Detects the OS, runs `modules/` in order. |
| `lib/common.sh` | Logging, OS detection, conflict prompts, symlink/copy, package-list installer. |
| `modules/NN-*.sh` | One concern each, run in numeric order. |
| `packages/*.txt` | Package lists. Same format everywhere: one name per line, `#` comments. |
| `home/` | Mirrors `$HOME`. Every file here is **symlinked** into place. |
| `shell/*.zsh` | Sourced by `~/.zshrc` in numeric order. OS-specific files self-guard. |
| `config/` | Files the app itself rewrites, so they are **copied**, not linked. |

## Modules

| Module | Does |
|--------|------|
| `10-packages` | Homebrew formulae/casks/mas, or pacman + AUR (bootstraps `yay`). |
| `20-dotfiles` | Symlinks `home/` into `$HOME`, seeds `~/.secrets`. |
| `30-shell` | oh-my-zsh, plugins, makes zsh the login shell. |
| `40-runtimes` | Installs `mise` and the pinned node/python/rust versions. |
| `50-git` | Writes git identity to `~/.config/git/config.local` (gitignored). |
| `60-ssh` | ed25519 key, agent, optional upload to GitHub via `gh`. |
| `70-tailscale` | Enables `tailscaled` + `sshd` on Arch; checks the app on macOS. |
| `80-system` | macOS `defaults`, or Arch systemd services. |
| `85-docker` | Arch: docker service + group. macOS: a context pointing at the Arch box. |
| `90-apps` | Gas Mask hosts files, VLC credit-skipper, AWS config template, Ollama. |
| `95-ai` | Agent CLIs, shared rules file, skills installed into every agent. |

## AI agents

Claude, Codex and Gemini each read a differently-named instruction file. All three
are symlinked to one source so the rules can't drift:

| Agent | Reads | → |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `ai/AGENTS.md` |
| Codex | `~/.codex/AGENTS.md` | `ai/AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` | `ai/AGENTS.md` |

Edit `ai/AGENTS.md` — never the symlinks.

Skills come from the separate `skills` repo, whose `install-skills.sh` fans out to
every agent's `skills/` directory. Re-run it after adding or renaming a skill:

```sh
cd ~/Documents/CodeStuff/skills && ./install-skills.sh
```

It only removes symlinks pointing back into that repo, so vendor skills installed
by other means (`cloudflare`, `wrangler`, `web-perf`…) survive a re-run.

Install channels differ by OS — `claude-code`/`codex` casks and the `gemini-cli`
formula on macOS, global npm packages on mise's node on Arch. The commands you type
are identical either way.

## Docker

One CLI, two daemons, selected by context — the commands never change:

```sh
dctx default        # local: Docker Desktop on the MacBook
dctx workstation    # the Arch box, over Tailscale SSH — its CPU, its disk
dctxl               # list contexts
```

Docker on macOS is the `docker-desktop` cask **only**. Adding the `docker` or
`docker-compose` formulae installs a second competing copy of the same binaries.

## Keeping repos in sync across machines

Git, not file sync.

```sh
repos             # per-repo branch / dirty / unpushed across ~/Documents/CodeStuff
repos discover    # rebuild the manifest from your github account (needs `gh`)
repos clone       # on a new machine: clone whatever is missing
repos pull        # fast-forward every clean repo (dirty ones are skipped)
repos add         # add the repo you're standing in
repos missing     # local repos not yet in the manifest
```

The manifest is `~/.config/repos.txt`, deliberately **outside this repo** — dotfiles
is public, and a list of clone URLs would publish the names of every private repo
and org you work in. `repos discover` regenerates it from GitHub, so a fresh machine
needs nothing copied across by hand.

Do **not** put `~/Documents/CodeStuff` in Syncthing — see `notes.md`.

## This repo is public

- Secrets go in `~/.secrets` (gitignored, `chmod 600`), never in a tracked file.
- Git identity goes in `~/.config/git/config.local`, not `home/.config/git/config`.
- `.secrets.example` and `config/aws/config.example` are templates — keep every
  value in them a placeholder.
- Before pushing, `git status` should show nothing you didn't intend. `.gitignore`
  blocks keys, `repos.txt` and `*.local`, but it is a backstop, not a substitute
  for looking.

## Language versions — one tool, one set of commands

[`mise`](https://mise.jdx.dev) manages node, python, rust (and go/java) on both
machines. Each repo pins its own versions in its own `.mise.toml`; mise also reads
existing `.nvmrc`, `.node-version`, `.python-version` and `rust-toolchain.toml`,
so nothing needs migrating.

```sh
cd myrepo
mise use node@22 python@3.13 rust@stable   # writes ./.mise.toml, installs, activates
mise install                               # install whatever this repo pins
mise ls --current                          # what's active here
mise outdated && mise upgrade
```

Same verbs, any language. Global fallbacks: `home/.config/mise/config.toml`.

Packages within a project stay with that project's native tool, each pinned by mise:

| Language | Packages | Why |
|----------|----------|-----|
| Python | `uv` — `uv venv`, `uv add`, `uv sync`, `uv run` | one tool for venv + resolve + lock, fast |
| Node | `pnpm` via corepack, pinned by `package.json#packageManager` | version travels with the repo |
| Rust | `cargo` | pinned by `rust-toolchain.toml` / `.mise.toml` |

## Secrets

- `~/.secrets` — env vars and tokens, sourced by `~/.zshrc`, `chmod 600`, never committed.
- `~/.config/git/config.local` — git identity, gitignored.
- `~/.zshrc.local` — anything machine-specific.

## Adding things

- **A package** → add a line to the right `packages/*.txt`, re-run `./bootstrap.sh --only packages`.
- **A dotfile** → drop it in `home/` at the path it should have under `$HOME`, re-run `--only dotfiles`.
- **An alias** → `shell/20-aliases.zsh`, or the OS-specific file.
- **A new concern** → a new `modules/NN-name.sh`; it is picked up automatically.
