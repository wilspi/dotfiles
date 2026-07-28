#!/usr/bin/env bash
# Git identity. The rest of the git config is a symlinked file (~/.config/git/config),
# so nothing here writes settings that the repo already tracks.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

have git || die "git is not installed — run the packages module first"

# Identity lives in ~/.config/git/config.local (gitignored, machine-local).
LOCAL_CFG="$HOME/.config/git/config.local"

if [ -s "$LOCAL_CFG" ] && git config -f "$LOCAL_CFG" user.email >/dev/null 2>&1; then
	skip "git identity: $(git config -f "$LOCAL_CFG" user.name) <$(git config -f "$LOCAL_CFG" user.email)>"
else
	name="${GIT_AUTHOR_NAME:-wilspi}"
	email="${GIT_AUTHOR_EMAIL:-wilspi@users.noreply.github.com}"
	if interactive && [ "${ASSUME_YES:-0}" != 1 ]; then
		ask "git user.name  [$name]:"  in_name
		ask "git user.email [$email]:" in_email
		name="${in_name:-$name}"
		email="${in_email:-$email}"
	fi
	run mkdir -p "$(dirname "$LOCAL_CFG")"
	run git config -f "$LOCAL_CFG" user.name  "$name"
	run git config -f "$LOCAL_CFG" user.email "$email"
	ok "git identity: $name <$email>"
fi

if have gh && ! gh auth status >/dev/null 2>&1; then
	warn "github cli is not authenticated — run: gh auth login"
fi
