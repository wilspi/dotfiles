#!/usr/bin/env bash

# Homebrew
# Install command line tools for osx

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all




# Formulae / Tool
# ---------------

# sshfs: mount remote file systems over SSH
brew install homebrew/fuse/sshfs

# youtube-dl: download videos from youtube and other video sites
# https://github.com/rg3/youtube-dl/
brew install youtube-dl

# watch: to run command every x seconds
# https://en.wikipedia.org/wiki/Watch_(Unix)
brew install watch





# Remove outdated versions from the cellar.
brew cleanup
