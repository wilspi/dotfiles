#!/usr/bin/env bash
# Tailscale. The Arch box is headless and reached over the tailnet, so it also
# gets ssh + a stable hostname.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

if is_arch; then
	have tailscale || die "tailscale not installed — run the packages module first"
	run sudo systemctl enable --now tailscaled || warn "could not enable tailscaled"

	if tailscale status >/dev/null 2>&1; then
		skip "already connected to the tailnet"
		tailscale status --peers=false 2>/dev/null | sed 's/^/    /' || true
	else
		info "not connected. Bring it up with (pick the flags you want):"
		cat <<-'EOF' | sed 's/^/    /'
		sudo tailscale up --ssh --hostname="$(hostname -s)"
		# expose the LAN behind this box:   --advertise-routes=192.168.1.0/24
		# use it as an exit node:           --advertise-exit-node
		EOF
	fi

	# sshd, for when tailscale ssh is not the path in
	run sudo systemctl enable --now sshd || warn "could not enable sshd"

elif is_macos; then
	if [ -d "/Applications/Tailscale.app" ]; then
		skip "Tailscale.app installed"
		info "if the CLI is missing, run: sudo ln -sfn /Applications/Tailscale.app/Contents/MacOS/Tailscale /usr/local/bin/tailscale"
	else
		warn "Tailscale.app not found — it is in packages/brew-casks.txt"
	fi
	tailscale status >/dev/null 2>&1 && skip "connected to the tailnet" \
		|| info "open Tailscale.app and sign in"
fi
