#!/usr/bin/env bash
# Setup across environments

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# https://stackoverflow.com/a/246128
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SYSTEM=$1
EMAIL=$2

# Make code directory
[ ! -d ~/Documents/codestuff/ ] && mkdir -p ~/Documents/codestuff/
echo -e "${BLUE}INFO:${NC} codestuff directory created"

# Packages
$CWD/packages/.init.sh $SYSTEM

# Setup SSH
# Generate new ssh key if ~/.ssh doesn't exist
[ "$EMAIL" != "" ] && [ ! -d ~/.ssh ] && ssh-keygen -t rsa -b 4096 -C $EMAIL
echo -e "${BLUE}INFO:${NC} ssh identity created"
# SSH Agent
# Read: https://www.ssh.com/ssh/add
# required for SSH Agent Forwarding
ssh-add -K ~/.ssh/id_rsa
echo -e "${BLUE}TODO:${NC} Copy ~/.ssh/id_rsa.pub to your github account"

# Files to ignore globally for git
git config --global core.excludesfile '$CWD/.git_global_ignore'

# export PATH="$HOME/.cargo/bin:$PATH"

# Copy aliases
echo "$($CWD/aliases/.init.sh $SYSTEM)" > $CWD/../bash/.bash_aliases

# Configs
$CWD/configs/.init.sh $SYSTEM
