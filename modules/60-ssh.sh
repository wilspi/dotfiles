#!/usr/bin/env bash
# SSH key + agent. ed25519, not the rsa-4096 the old script generated.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

KEY="$HOME/.ssh/id_ed25519"

run mkdir -p "$HOME/.ssh"
run chmod 700 "$HOME/.ssh"

if [ -f "$KEY" ]; then
	skip "ssh key $KEY"
else
	email="$(git config -f "$HOME/.config/git/config.local" user.email 2>/dev/null || echo "$(whoami)@$(hostname -s)")"
	if confirm "generate a new ssh key for $email?" y; then
		run ssh-keygen -t ed25519 -a 100 -C "$email" -f "$KEY"
		ok "created $KEY"
	fi
fi

if [ -f "$KEY" ]; then
	if is_macos; then
		# --apple-use-keychain replaces the long-removed `-K` flag.
		run ssh-add --apple-use-keychain "$KEY" >/dev/null 2>&1 || warn "ssh-add failed"
	else
		[ -n "${SSH_AUTH_SOCK:-}" ] && run ssh-add "$KEY" >/dev/null 2>&1 || true
	fi

	if have gh && gh auth status >/dev/null 2>&1; then
		if gh ssh-key list 2>/dev/null | grep -q "$(awk '{print $2}' "$KEY.pub")"; then
			skip "public key already on github"
		elif confirm "upload $KEY.pub to github?" y; then
			run gh ssh-key add "$KEY.pub" --title "$(hostname -s)" && ok "uploaded to github"
		fi
	else
		info "add this to github (https://github.com/settings/keys):"
		sed 's/^/    /' "$KEY.pub"
	fi
fi
