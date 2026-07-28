#!/usr/bin/env bash
# Docker. One CLI, two daemons, switched with `docker context use`:
#
#   docker context use default        # local (Docker Desktop / local dockerd)
#   docker context use workstation    # the arch box, over tailscale ssh
#
# Same commands and aliases either way — nothing to remember per machine.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

# ------------------------------------------------------------------- arch ---
if is_arch; then
	have docker || { warn "docker not installed — run the packages module first"; exit 0; }

	if systemctl is-enabled docker >/dev/null 2>&1; then
		skip "docker service"
	else
		run sudo systemctl enable --now docker && ok "docker service" || warn "could not enable docker"
	fi

	if id -nG "$USER" | grep -qw docker; then
		skip "$USER is in the docker group"
	elif confirm "add $USER to the docker group (use docker without sudo)?" y; then
		run sudo usermod -aG docker "$USER" && ok "added — log out and back in for it to apply"
	fi

	# Remote contexts connect over ssh, so the daemon socket stays unexposed.
	info "this box is reachable as a docker context from the macbook — no open tcp port needed"
fi

# ------------------------------------------------------------------ macos ---
if is_macos; then
	if ! have docker; then
		warn "docker cli not found — it comes with the docker-desktop cask; open it once to finish setup"
		exit 0
	fi

	# Point a context at the Arch box so `dctx workstation` builds and runs there
	# (its CPU, its disk) while you stay in the MacBook shell.
	REMOTE_HOST="${DOCKER_REMOTE_HOST:-workstation}"

	if docker context inspect "$REMOTE_HOST" >/dev/null 2>&1; then
		skip "docker context '$REMOTE_HOST'"
	elif confirm "create a docker context for the arch box over ssh ($REMOTE_HOST)?" y; then
		if run docker context create "$REMOTE_HOST" \
			--description "arch workstation over tailscale" \
			--docker "host=ssh://$REMOTE_HOST"; then
			ok "docker context '$REMOTE_HOST' — switch with: dctx $REMOTE_HOST"
		else
			warn "could not create the context (is '$REMOTE_HOST' reachable over ssh?)"
		fi
	fi

	docker context ls 2>/dev/null | sed 's/^/    /' || true
fi
