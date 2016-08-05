#!/usr/bin/env bash
# Bash Aliases

# navigation
alias ..='cd ..'

# date/time/week
alias now='date +"%T"'
alias now_time=now
alias now_date='date +"%d-%m-%Y"'
alias week='date +%V'

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


# SSH public key
alias ssh_pub_key="cat ~/.ssh/id_rsa.pub"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
# string to json
alias jsonify='python -c '"'"'import json, sys; input_str=sys.argv[1]; print json.loads(input_str.replace("\n", "\\n").replace("\r", "\\r"));'"'"' '


# kill all the tabs in chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chrome_kill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# show pretty git log
alias git_log_pretty="git log --pretty=oneline --abbrev-commit --graph --decorate --all"