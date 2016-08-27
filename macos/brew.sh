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

# sshpass: allows to provide the ssh password without using the prompt
# no homebrew package, as homebrew doesnt allow installing sshpass
# http://linux.die.net/man/1/sshpass
curl -O -L http://downloads.sourceforge.net/project/sshpass/sshpass/1.05/sshpass-1.05.tar.gz && tar xvzf sshpass-1.05.tar.gz
cd sshpass-1.05
./configure
make
sudo make install
cd ..
rm -rf sshpass-1.05
rm -rf sshpass-1.05.tar.gz

# awk, gawk: 
brew install gawk

# thefuck
# https://github.com/nvbn/thefuck
brew install thefuck

# wifi-password
# https://github.com/rauchg/wifi-password
brew install wifi-password




# Remove outdated versions from the cellar.
brew cleanup
