#!/usr/bin/env bash
# Symlink everything under home/ into $HOME, mirroring the directory layout.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

info "linking home/ into $HOME"
link_tree "$DOTFILES/home" "$HOME"

# ~/.secrets holds anything that must not live in a public repo.
if [ ! -f "$HOME/.secrets" ]; then
	run cp "$DOTFILES/.secrets.example" "$HOME/.secrets"
	run chmod 600 "$HOME/.secrets"
	ok "created ~/.secrets from the example — fill it in"
else
	skip "~/.secrets"
fi

# Code directory referenced by aliases and by the git config includeIf rules.
run mkdir -p "$HOME/Documents/CodeStuff"
