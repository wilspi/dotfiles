#!/usr/bin/env bash
# One version manager for every language: mise.
#
# Per-repo versions live in that repo's .mise.toml (mise also reads .nvmrc,
# .node-version, .python-version, rust-toolchain.toml). Global fallbacks live in
# home/.config/mise/config.toml. Same commands on macOS and Arch:
#
#   mise use node@22          # pin in ./.mise.toml, install, activate
#   mise use python@3.13
#   mise use rust@stable
#   mise install              # install everything this repo pins
#   mise ls / mise outdated / mise upgrade
set -uo pipefail
source "$DOTFILES/lib/common.sh"

# mise is in the package lists; this is the fallback for a machine where the
# package module hasn't run (or was skipped).
if ! have mise; then
	if [ "${DRY_RUN:-0}" = 1 ]; then
		skip "mise is not installed yet — nothing further to preview here"
		exit 0
	fi
	info "installing mise"
	sh -c 'curl -fsSL https://mise.run | sh' || die "mise install failed"
	export PATH="$HOME/.local/bin:$PATH"
	have mise || die "mise installed but not on PATH — check ~/.local/bin"
fi

info "installing global runtime versions from ~/.config/mise/config.toml"
run mise install || warn "some runtimes failed to install"
run mise reshim  >/dev/null 2>&1 || true

mise ls --current 2>/dev/null | sed 's/^/    /' || true

# Node package manager: pnpm, pinned per repo via package.json#packageManager.
if have node && have corepack; then
	run corepack enable >/dev/null 2>&1 && ok "corepack enabled (pnpm/yarn resolve per repo)" \
		|| warn "corepack enable failed (needs a writable node bin dir)"
fi

# Legacy managers left behind by the old dotfiles.
for legacy in "$HOME/.pyenv" "$HOME/.nvm" "$HOME/.rbenv"; do
	[ -d "$legacy" ] || continue
	warn "$legacy still exists — mise replaces it"
	confirm "remove $legacy?" n && run rm -rf "$legacy" && ok "removed $legacy"
done
