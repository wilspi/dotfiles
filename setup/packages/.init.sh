#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SYSTEM=$1


echo -e "${BLUE}INFO:${NC} install packages for $SYSTEM"
if [ $SYSTEM = "MACOS" ]; then
	$CWD/macos/brew.sh
elif [ $SYSTEM = "ARCH" ]; then
	$CWD/arch/pacman.sh
elif [ $SYSTEM = "LINUX" ]; then
	$CWD/debian/apt.sh
else
	echo -e "${RED}ERR:${NC} unidentified param for system: $SYSTEM"
fi