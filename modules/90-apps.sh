#!/usr/bin/env bash
# App config that lives outside $HOME's dotfile conventions, or that the app
# itself rewrites (so it is copied, not symlinked). Every copy respects the
# keep/overwrite prompt.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

CFG="$DOTFILES/config"

# ---------------------------------------------------------------- gas mask ---
if is_macos; then
	GM_DIR="$HOME/Library/Gas Mask/Local"
	info "gas mask hosts files"
	run mkdir -p "$GM_DIR"
	for f in "$CFG"/gasmask/*.hst; do
		[ -e "$f" ] || continue
		copy_file "$f" "$GM_DIR/$(basename "$f")"
	done
	info "in Gas Mask: Local files appear in the sidebar, activate one to write /etc/hosts"
fi

# --------------------------------------------------------------------- vlc ---
# Credit Skipper: https://github.com/michaelbull/vlc-credit-skipper
if [ -f "$CFG/vlc/credit-skipper.conf" ]; then
	if is_macos; then
		VLC_EXT="$HOME/Library/Application Support/org.videolan.vlc/lua/extensions"
		VLC_CFG="$HOME/Library/Preferences/org.videolan.vlc"
	else
		VLC_EXT="$HOME/.local/share/vlc/lua/extensions"
		VLC_CFG="$HOME/.config/vlc"
	fi

	if [ -d "/Applications/VLC.app" ] || have vlc; then
		info "vlc credit-skipper extension"
		run mkdir -p "$VLC_EXT" "$VLC_CFG"
		if [ -f "$VLC_EXT/credit-skipper.lua" ]; then
			skip "credit-skipper.lua"
		else
			run curl -fsSL -o "$VLC_EXT/credit-skipper.lua" \
				https://raw.githubusercontent.com/michaelbull/vlc-credit-skipper/master/credit-skipper.lua \
				&& ok "credit-skipper.lua" || warn "download failed"
		fi
		copy_file "$CFG/vlc/credit-skipper.conf" "$VLC_CFG/credit-skipper.conf"
	else
		skip "vlc not installed"
	fi
fi

# ---------------------------------------------------------------- aws cli ---
if [ ! -f "$HOME/.aws/config" ] && [ -f "$CFG/aws/config.example" ]; then
	run mkdir -p "$HOME/.aws"
	copy_file "$CFG/aws/config.example" "$HOME/.aws/config"
	warn "~/.aws/config is a template — edit it, and keep credentials in ~/.secrets or SSO"
else
	skip "~/.aws/config"
fi

# ----------------------------------------------------------------- ollama ---
if have ollama; then
	if is_arch; then
		systemctl is-enabled ollama >/dev/null 2>&1 && skip "ollama service" \
			|| { confirm "enable the ollama service?" y && run sudo systemctl enable --now ollama; }
		info "to reach ollama from other tailnet machines, set OLLAMA_HOST=0.0.0.0 in its unit override"
	fi
fi
