[[ "$OSTYPE" == linux* ]] || return 0
[ -f /etc/arch-release ] || return 0

# --- packages ---
alias update='sudo pacman -Syu && (command -v yay >/dev/null && yay -Sua --noconfirm); mise upgrade'
alias pacs='pacman -Ss'
alias pacq='pacman -Qi'
alias pacown='pacman -Qo'      # which package owns this file

# Reclaim disk: trim package caches and drop orphans
cleanup() {
	sudo paccache -rk1        # keep 1 version of installed packages
	sudo paccache -ruk0       # drop all versions of uninstalled packages
	command -v yay >/dev/null && yay -Sc --noconfirm
	local orphans
	orphans="$(pacman -Qtdq 2>/dev/null)"
	[ -n "$orphans" ] && sudo pacman -Rns --noconfirm $=orphans
	sudo journalctl --vacuum-time=2weeks
}

# --- system ---
alias running='systemctl list-units --state=running'
alias failed='systemctl --failed'
alias jctl='journalctl -xe'
alias jf='journalctl -fu'      # follow a unit: jf nginx
alias localip="ip -4 -brief addr show | awk '\$1 != \"lo\" {print \$1, \$3}'"
alias ip='curl -fsS https://ifconfig.me; echo'
