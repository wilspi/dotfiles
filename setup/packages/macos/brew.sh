#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Homebrew: Setup Packages
which -s brew
if [[ $? != 0 ]] ; then
	echo -e "${BLUE}INFO:${NC} Installing Homebrew: The missing package manager for OS X"
	# Install Homebrew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo -e "${BLUE}INFO:${NC} Homebrew found, checking for updates"
	brew update
	# brew upgrade --all
fi


# Install Formulae / Tools
#echo -e "${BLUE}INFO:${NC} Installing brew formulae"

# Caskroom for Homebrew : Installing MacOS Applications
# https://caskroom.github.io/
brew tap caskroom/cask

# Required for sshfs
# brew cask install osxfuse

# sshfs: mount remote file systems over SSH
# brew install homebrew/fuse/sshfs

# youtube-dl: download videos from youtube and other video sites
# https://github.com/rg3/youtube-dl/
brew install youtube-dl

# Install iTerm2
brew cask install iterm2

# brew install htop
brew install telnet

# For Tree view of folders/files from terminal
#brew install tree

# watch: to run command every x seconds
# https://en.wikipedia.org/wiki/Watch_(Unix)
# brew install watch

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
# brew install wifi-password

# ffmpeg: video editing utility
# https://ffmpeg.org/ffmpeg.html
brew install ffmpeg

# git bash autocomplete
brew install bash-completion


# Mac OS Applications
brew cask install google-chrome
#brew cask install sublime-text3
brew cask install vlc

# Remove outdated versions from the cellar.
brew cleanup
