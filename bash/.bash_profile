#!/usr/bin/env bash

$PWD=$(pwd)

source ~/.bash_aliases
source ~/.bash_functions
source ~/.bash_exports

# Use .secrets for stuff that you don't want to share in your public, versioned repo.
if [[ -e ~/.secrets ]]; then
  source ~/.secrets
fi

# checks if OS is OSX
if [ "$(uname -s)" = "Darwin" ]; then
	source "$PWD/macos/.aliases"
fi

# files to ignore globally for git
git config --global core.excludesfile '~/.git_global_ignore'
