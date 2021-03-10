#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SYSTEM=$1


echo -e "${BLUE}INFO:${NC} running configs for $SYSTEM"
if [ $SYSTEM = "MACOS" ]; then
	# Run macos configs
	echo "do nothing"

elif [ $SYSTEM = "ARCH" ]; then
	# Download nix file and setup
	curl -o $CWD/setup_nix.sh https://gist.githubusercontent.com/wilspi/847b3794a5dda51a62b8bfd4fd968f3b/raw/setup_nix.sh
	$CWD/setup_nix.sh

	# Copy Terminator config
	mkdir -p ~/.config/terminator/
	cp $CWD/terminator ~/.config/terminator/config

	# Run gnome configs
	$CWD/gnome

	# vlc plugins
	# Credit Skipper: https://github.com/michaelbull/vlc-credit-skipper
	curl https://raw.githubusercontent.com/michaelbull/vlc-credit-skipper/master/credit-skipper.lua --output credit-skipper.lua
	mkdir -p ~/.local/share/vlc/lua/extensions/
	mv credit-skipper.lua ~/.local/share/vlc/lua/extensions/
	mkdir -p ~/.config/vlc/
	cp $CWD/vlc/credit-skipper.conf ~/.config/vlc/

elif [ $SYSTEM = "LINUX" ]; then
	# Copy Terminator config
	cp $CWD/terminator ~/.config/terminator/config

	# vlc plugins
	# Credit Skipper: https://github.com/michaelbull/vlc-credit-skipper
	curl https://raw.githubusercontent.com/michaelbull/vlc-credit-skipper/master/credit-skipper.lua --output credit-skipper.lua
	mkdir -p ~/.local/share/vlc/lua/extensions/
	mv credit-skipper.lua ~/.local/share/vlc/lua/extensions/
	cp $CWD/vlc/credit-skipper.conf ~/.config/vlc/

	# Run gnome configs
	$CWD/gnome

else
	echo -e "${RED}ERR:${NC} unidentified param for system: $SYSTEM"
fi

# Run common
$CWD/zsh
$CWD/pyenv