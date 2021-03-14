#!/usr/bin/env bash

# Colors
# https://stackoverflow.com/a/5947802
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

USERNAME="wilspi"

echo -e "hello ${PURPLE}$USERNAME${NC}"
echo -e "${BLUE}INFO:${NC} personalization of your system has started ..."
echo ""

# Get email (timeout 10 secs)
read -t 10 -p "Enter your email id [$USERNAME@system]:" email
if [ -z "$email" ]; then
	echo ""
fi
email=${email:-"$USERNAME@system"} # default
echo -e "${BLUE}INFO:${NC} noted your email id as: $email"

# Get file path for current working directory
cwd="`(cd $(dirname \"$0\") && pwd -P )`"
if [ -z "$cwd" ] ; then
	echo -e "${RED}ERR:${NC} file path found empty"
	exit 1
fi

# Files to be generated
# All aliases are moved to .bash_aliases
# All other configs are moved to .bash_profile
bash_files=".bash_aliases"

# Backup any existing bash files
#echo -e "${BLUE}INFO:${NC} moving old dotfiles files to '~/dotfiles_old/bash'"
#[ ! -d ~/dotfiles_old/bash ] && mkdir -p ~/dotfiles_old/bash
#for file in $bash_files; do
#	[ -f ~/$file ] && mv ~/$file ~/dotfiles_old/bash
#done

# Create directory if doesnt exist
[ ! -d "$cwd/bash" ] && mkdir "$cwd/bash"

# Identify OS
system="SYSTEM"
if [ "$(uname -s)" = "Darwin" ]; then
	system="MACOS"
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
	if [ "$(hostnamectl | grep -i 'operating system')" = "  Operating System: Arch Linux" ]; then
		system="ARCH"
	else
		# other linux is UBUNTU for me
		echo -e "${BLUE}INFO:${NC} 'UBUNTU' assumed"
		system="UBUNTU"
	fi
else
	echo -e "${RED}ERR:${NC} unidentified system found"
	exit 1
fi
echo -e "${BLUE}INFO:${NC} '$system' identified"

# Run setup
$cwd/setup/.init.sh $system $email


# TODO: Use secrets
# # Use .secrets for stuff that you don't want to share in your public, versioned repo.
# if [[ -e ~/.secrets ]]; then
# 	source ~/.secrets
# fi

# Symlink bash files in home directory
for file in $bash_files; do
	[ -f $cwd/bash/$file ] && ln -s "$cwd/bash/$file" ~/$file
done

echo -e "${BLUE}INFO:${NC} personalization completed"

# Reload .bash_profile .bash_aliases
# source ~/.bash_profile
# TODO: confirm if it works
source ~/.bash_aliases
echo "BYE: Have a good day"
