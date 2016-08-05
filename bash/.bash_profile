#!/usr/bin/env bash

source ~/.bash_aliases
source ~/.bash_functions

# Use .secrets for stuff that you don't want to share in your public, versioned repo.
if [[ -e ~/.secrets ]]; then
  source ~/.secrets
fi

# files to ignore globally for git
git config --global core.excludesfile '~/.git_global_ignore'