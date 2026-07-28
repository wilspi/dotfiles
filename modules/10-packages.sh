#!/usr/bin/env bash
# Install packages from packages/*.txt — one at a time, failures reported not fatal.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

P="$DOTFILES/packages"

# ------------------------------------------------------------------ macos ---
if is_macos; then
	# Find brew even when it is not yet on PATH (apple silicon vs intel prefix).
	BREW_BIN=""
	for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew "$(command -v brew 2>/dev/null)"; do
		[ -n "$candidate" ] && [ -x "$candidate" ] && { BREW_BIN="$candidate"; break; }
	done

	if [ -z "$BREW_BIN" ]; then
		if [ "$DRY_RUN" = 1 ]; then
			skip "would install homebrew"
			exit 0
		fi
		info "installing homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
			|| die "homebrew install failed"
		BREW_BIN=/opt/homebrew/bin/brew
		[ -x "$BREW_BIN" ] || BREW_BIN=/usr/local/bin/brew
	fi
	eval "$("$BREW_BIN" shellenv)"
	ok "homebrew: $BREW_BIN"

	info "brew update"
	run brew update >/dev/null || warn "brew update failed"

	_brew_has()  { brew list --formula --versions "$1" >/dev/null 2>&1; }
	_brew_get()  { brew install "$1"; }
	_cask_has()  { brew list --cask --versions "$1" >/dev/null 2>&1; }
	_cask_get()  { brew install --cask "$1"; }

	install_each "formulae" "$P/brew-formulae.txt" _brew_get _brew_has
	install_each "casks"    "$P/brew-casks.txt"    _cask_get _cask_has

	if have mas; then
		_mas_has() { mas list 2>/dev/null | grep -q "^$1 "; }
		_mas_get() { mas install "$1"; }
		if mas account >/dev/null 2>&1; then
			install_each "mac app store" "$P/mas.txt" _mas_get _mas_has
		else
			warn "not signed in to the App Store — skipping packages/mas.txt"
		fi
	fi

	info "brew cleanup"
	run brew cleanup >/dev/null || true

# ------------------------------------------------------------------- arch ---
elif is_arch; then
	info "pacman -Syu"
	run sudo pacman -Syu --noconfirm || warn "system upgrade failed"

	_pac_has() { pacman -Qi "$1" >/dev/null 2>&1; }
	_pac_get() { sudo pacman -S --needed --noconfirm "$1"; }
	install_each "pacman packages" "$P/pacman.txt" _pac_get _pac_has

	if ! have yay; then
		info "bootstrapping yay (AUR helper)"
		tmp="$(mktemp -d)"
		if run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" \
			&& run bash -c "cd '$tmp/yay-bin' && makepkg -si --noconfirm"; then
			ok "yay installed"
		else
			warn "yay bootstrap failed — skipping AUR packages"
		fi
		rm -rf "$tmp"
	fi

	if have yay; then
		_aur_get() { yay -S --needed --noconfirm "$1"; }
		install_each "aur packages" "$P/aur.txt" _aur_get _pac_has
	fi

else
	warn "no package list for OS '$OS' — skipping"
fi
