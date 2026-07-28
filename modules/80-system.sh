#!/usr/bin/env bash
# OS-level settings: macOS `defaults`, Arch systemd services.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

# ------------------------------------------------------------------ macos ---
if is_macos; then
	confirm "apply macOS system defaults?" y || exit 0

	# Wrapper so --dry-run is honoured for every single write.
	d() { run defaults write "$@"; }

	run osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

	info "finder"
	d com.apple.finder QuitMenuItem -bool true
	d com.apple.finder ShowPathbar -bool true
	d com.apple.finder ShowStatusBar -bool true
	d com.apple.finder _FXSortFoldersFirst -bool true
	d com.apple.finder FXDefaultSearchScope -string "SCcf"
	d com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
	d com.apple.finder AppleShowAllFiles -bool true
	d NSGlobalDomain AppleShowAllExtensions -bool true
	d com.apple.desktopservices DSDontWriteNetworkStores -bool true
	d com.apple.desktopservices DSDontWriteUSBStores -bool true

	info "keyboard & input"
	d NSGlobalDomain KeyRepeat -int 2
	d NSGlobalDomain InitialKeyRepeat -int 15
	d NSGlobalDomain ApplePressAndHoldEnabled -bool false
	d NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	d NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	d NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

	info "dock & screenshots"
	d com.apple.dock autohide -bool true
	d com.apple.dock autohide-delay -float 0
	d com.apple.dock show-recents -bool false
	run mkdir -p "$HOME/Pictures/Screenshots"
	d com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
	d com.apple.screencapture disable-shadow -bool true

	info "misc"
	d NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
	d com.apple.LaunchServices LSQuarantine -bool false
	run sudo systemsetup -setrestartfreeze on >/dev/null 2>&1 || true

	if [ "${DRY_RUN:-0}" != 1 ]; then
		for app in Finder Dock SystemUIServer; do killall "$app" >/dev/null 2>&1 || true; done
	fi
	ok "macOS defaults applied (some need a logout to take effect)"

# ------------------------------------------------------------------- arch ---
elif is_arch; then
	enable_unit() {
		if systemctl is-enabled "$1" >/dev/null 2>&1; then
			skip "$1"
		else
			run sudo systemctl enable --now "$1" && ok "$1" || warn "could not enable $1"
		fi
	}

	info "systemd services"
	enable_unit systemd-timesyncd
	enable_unit vnstat
	enable_unit paccache.timer      # weekly pacman cache trim
	# docker's service and group live in modules/85-docker.sh

	# Headless box: no GUI stack, no display manager. Nothing to enable here on purpose.
	info "headless config — no display manager or Xorg is configured by design"
fi
