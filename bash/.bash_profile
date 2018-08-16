#!/usr/bin/env bash

[ -f ~/.dotfiles_path ] && source ~/.dotfiles_path && cwd=$dotfiles_path;

source $cwd/bash/.bash_aliases
source $cwd/bash/.bash_functions
source $cwd/bash/.bash_exports

# Use .secrets for stuff that you don't want to share in your public, versioned repo.
if [[ -e ~/.secrets ]]; then
	source ~/.secrets
fi

# checks if OS is OSX
if [ "$(uname -s)" = "Darwin" ]; then
	source "$cwd/macos/.aliases"
	source "$cwd/macos/.functions"
fi

# Git autocomplete
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

# files to ignore globally for git
git config --global core.excludesfile '$cwd/.git_global_ignore'

# TODO: move somewhere but not here
# export PATH="$HOME/.cargo/bin:$PATH"

# SSH Agent
# Read: https://www.ssh.com/ssh/add
ssh-add -K ~/.ssh/id_rsa
