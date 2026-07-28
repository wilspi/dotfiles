# Notes

Things that don't belong in a script — one-off fixes, manual steps, gotchas.
The old GNOME/GDM/CLion notes were dropped: the Arch box is headless now.

## Arch workstation (headless, reached over Tailscale)

Bring it onto the tailnet, then everything else happens over SSH:

```sh
sudo tailscale up --ssh --hostname=workstation
# route the LAN behind it:  --advertise-routes=192.168.1.0/24  (then approve in the admin console)
# use it as an exit node:   --advertise-exit-node
```

Reach it from the MacBook: `ssh workstation` (Tailscale MagicDNS) or `tailscale ssh workstation`.

Enable pacman parallel downloads and colour — `/etc/pacman.conf`:

```
Color
ParallelDownloads = 5
```

Expose Ollama to the rest of the tailnet (it binds to localhost by default):

```sh
sudo systemctl edit ollama
# [Service]
# Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Then on the MacBook set `OLLAMA_HOST=http://workstation:11434` in `~/.secrets`.

## Manual installs

Not in Homebrew or the Arch repos, so the setup can't do these:

- **DaVinci Resolve** — registration-walled download:
  <https://www.blackmagicdesign.com/products/davinciresolve>
- **SiteOne Crawler** — GitHub releases (macOS + Linux binaries):
  <https://github.com/janreges/siteone-crawler/releases>. Drop the binary in
  `~/.local/bin` (already on `PATH` via `.zshenv`).

## Manual steps the setup can't do

- **App Store apps** (`packages/mas.txt`) need you signed in to the App Store first.
- **Proton VPN / Pass / Mail / Drive** need sign-in.
- **Tailscale on macOS** — sign in through the app; the CLI lives inside the bundle
  (`shell/40-macos.zsh` aliases it).
- **Gas Mask** writes `/etc/hosts` and needs admin rights the first time.
- **Zed** — sign in for AI features; settings themselves are symlinked from this repo.

## Why CodeStuff is not in Syncthing

File-syncing a code directory is a trap:

- It syncs `.git/` internals. Both machines writing the same repo yields
  `sync-conflict-*` files **inside** `.git`, which is a corrupted repo — and it
  stays silent until the next fetch.
- It syncs `node_modules/`, `target/`, `.venv/` — huge, platform-specific, and
  churning constantly. A Rust `target/` alone will thrash it.
- Git already solves this, with conflict resolution built for source code.

Use `repos` (in `bin/`) instead — git is the transport. Its manifest lives at
`~/.config/repos.txt`, **not** in this repo: dotfiles is public and clone URLs
would publish the names of your private repos and orgs. `repos discover` rebuilds
it from GitHub via `gh`, so a fresh machine needs nothing copied by hand.

Syncthing *is* a good fit for things git is bad at, if you want it later — Calibre's
library, scanned documents, screenshots, a plain-notes folder. Keep it pointed at
those directories specifically, never at `~/Documents/CodeStuff`.

## Gotchas

- `mise` needs a repo's `.mise.toml` to be trusted before it runs. Paths under
  `~/Documents/CodeStuff` are pre-trusted in `home/.config/mise/config.toml`;
  anything else needs `mise trust`.
- `home/.config/git/config` sets `url."git@github.com:".insteadOf https://github.com/`,
  so HTTPS clones become SSH. If you need a genuinely anonymous HTTPS clone, use
  `git -c url."https://github.com/".insteadOf= clone ...`.
- The `scripts/git-auto-push` submodule is uninitialised. `git submodule update --init`
  to populate it, or drop it from `.gitmodules` if it is no longer used.
