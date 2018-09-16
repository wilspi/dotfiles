#!/usr/bin/env bash
# Bash Aliases and Functions

# navigation
alias ..='cd ..'

# date/time/week
alias now='date +"%r"'
alias now_time=now
alias now_date='date +"%d-%m-%Y"'
alias week='date +%V'
alias date_cp='date +"%T" | pbcopy'

# vim
alias svim='sudo vim'
alias edit='vim'

# wget: resume downloads by default
alias wget='wget -c'

# list all files colorized in long format, including dot files
alias la="ls -laF ${colorflag}"
# list only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# always enable colored `grep` output
# note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Code Directory
alias codedir='cd ~/Documents/CodeStuff/'

# SSH public key
alias ssh_pub_key="cat ~/.ssh/id_rsa.pub"

# kill all the tabs in chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chrome_kill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# delete all contents of file
# usage: empty_file <filepath>
alias empty_file='echo "" > '


# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$@"
}

# Extract many types of compressed packages
# Credit: http://nparikh.org/notes/zshrc.txt
function extract() {
	if [ -f "$1" ]; then
		case "$1" in
			*.tar.bz2)  tar -jxvf "$1"                        ;;
			*.tar.gz)   tar -zxvf "$1"                        ;;
			*.bz2)      bunzip2 "$1"                          ;;
			*.dmg)      hdiutil mount "$1"                    ;;
			*.gz)       gunzip "$1"                           ;;
			*.tar)      tar -xvf "$1"                         ;;
			*.tbz2)     tar -jxvf "$1"                        ;;
			*.tgz)      tar -zxvf "$1"                        ;;
			*.zip)      unzip "$1"                            ;;
			*.ZIP)      unzip "$1"                            ;;
			*.pax)      cat "$1" | pax -r                     ;;
			*.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
			*.Z)        uncompress "$1"                       ;;
			*) echo "'$1' cannot be extracted/mounted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file to extract"
	fi
}

# Extract audio from video
# Credit: http://www.labnol.org/internet/useful-ffmpeg-commands/28490/
function get_audio() {
	ffmpeg -i "$1" -vn -ab 256 "${1%.*}.mp3"
}
