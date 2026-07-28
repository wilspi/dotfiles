#!/usr/bin/env bash
# zsh + oh-my-zsh + plugins. Never overwrites ~/.zshrc (that one is ours, symlinked).
set -uo pipefail
source "$DOTFILES/lib/common.sh"

ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM="$ZSH_DIR/custom"

have zsh || die "zsh is not installed — run the packages module first"

# ------------------------------------------------------------- oh-my-zsh ---
OMZ_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
if [ -d "$ZSH_DIR" ]; then
	skip "oh-my-zsh"
elif [ "${DRY_RUN:-0}" = 1 ]; then
	skip "would install oh-my-zsh from $OMZ_URL"
else
	# KEEP_ZSHRC: ~/.zshrc is ours, symlinked by the dotfiles module.
	info "installing oh-my-zsh"
	env KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
		sh -c "$(curl -fsSL "$OMZ_URL")" "" --unattended \
		|| warn "oh-my-zsh install failed"
fi

# --------------------------------------------------------------- plugins ---
clone_plugin() {
	local repo="$1" name="${1##*/}" dest
	dest="$CUSTOM/plugins/$name"
	if [ -d "$dest" ]; then
		skip "plugin $name"
	elif run git clone --depth 1 "https://github.com/$repo" "$dest"; then
		ok "plugin $name"
	else
		warn "plugin $name failed"
	fi
}

if [ -d "$CUSTOM" ]; then
	info "zsh plugins"
	clone_plugin zsh-users/zsh-autosuggestions
	clone_plugin zsh-users/zsh-syntax-highlighting
	clone_plugin zsh-users/zsh-completions
fi

# --------------------------------------------------------- default shell ---
zsh_path="$(command -v zsh)"
if [ "${SHELL:-}" = "$zsh_path" ]; then
	skip "zsh is already the login shell"
elif confirm "make zsh ($zsh_path) your login shell?" y; then
	grep -qxF "$zsh_path" /etc/shells 2>/dev/null || \
		run sudo sh -c "echo '$zsh_path' >> /etc/shells"
	run chsh -s "$zsh_path" && ok "login shell set to zsh (takes effect next login)"
fi
