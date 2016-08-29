#!/usr/bin/env bash

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
fi

# files to ignore globally for git
git config --global core.excludesfile '~/.git_global_ignore'
