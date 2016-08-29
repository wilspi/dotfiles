#!/usr/bin/env bash

[ ! -z "$cwdb" ] && cwdb="$(pwd -P)"

source $cwdb/.bash_aliases
source $cwdb/.bash_functions
source $cwdb/.bash_exports

# Use .secrets for stuff that you don't want to share in your public, versioned repo.
if [[ -e ~/.secrets ]]; then
	source ~/.secrets
fi

# checks if OS is OSX
if [ "$(uname -s)" = "Darwin" ]; then
	source "$cwdb/../macos/.aliases"
fi

# files to ignore globally for git
git config --global core.excludesfile '~/.git_global_ignore'
