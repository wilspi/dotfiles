[[ "$OSTYPE" == darwin* ]] || return 0

# --- ip ---
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en0'

# --- housekeeping ---
alias update='softwareupdate -i -a; brew update && brew upgrade && brew cleanup; mise upgrade'
alias cleanup='find . -type f -name ".DS_Store" -print -delete'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias lsclean='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder'

# --- finder ---
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias hidedesktop='defaults write com.apple.finder CreateDesktop -bool false && killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop -bool true && killall Finder'

alias afk='open -a ScreenSaverEngine'
alias copy='pbcopy'
alias paste='pbpaste'

# Tailscale CLI ships inside the app bundle
[ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ] && \
	alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'

# Open the current directory in Finder. usage: o [path]
o() { open "${1:-.}"; }
