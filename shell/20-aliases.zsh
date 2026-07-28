# Cross-platform aliases. Anything OS-specific belongs in 40-macos.zsh / 40-arch.zsh.

# --- navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias code='cd ~/Documents/CodeStuff'
alias dots='cd "$DOTFILES"'

# --- ls (eza when available, coloured ls otherwise) ---
if command -v eza >/dev/null 2>&1; then
	alias ls='eza --group-directories-first'
	alias ll='eza -l --git --group-directories-first'
	alias la='eza -la --git --group-directories-first'
	alias lt='eza --tree --level=2'
else
	alias ls='ls --color=auto'
	alias ll='ls -lh'
	alias la='ls -lah'
fi

# --- grep / cat ---
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

# --- editors ---
alias v='$EDITOR'
alias sv='sudo -E $EDITOR'
alias hosts='sudo -E $EDITOR /etc/hosts'

# --- git (oh-my-zsh's git plugin covers the short ones; these are the extras) ---
alias gtree="git log --graph --abbrev-commit --decorate --all \
--format=format:'%C(bold blue)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias grecent="git for-each-ref --sort=-committerdate refs/heads/ \
--format='%(committerdate:short)  %(authorname)  %(refname:short)'"
alias gundo='git reset --soft HEAD~1'
alias gwip='git add -A && git commit -m wip --no-verify'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# --- runtimes (one set of verbs, every language) ---
alias mi='mise install'          # install what this repo pins
alias mu='mise use'              # mise use node@22 / python@3.13 / rust@stable
alias ml='mise ls --current'
alias mo='mise outdated'
alias mx='mise exec --'

# --- docker (same verbs on both machines; `dctx` switches which daemon) ---
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
alias dim='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af --volumes'
alias dctx='docker context use'
alias dctxl='docker context ls'
command -v lazydocker >/dev/null 2>&1 && alias ld='lazydocker'

# --- downloads ---
alias yt='yt-dlp'
alias yta='yt-dlp -x --audio-format mp3'

# --- misc ---
alias wget='wget -c'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias path='echo $PATH | tr ":" "\n"'
alias ports='sudo lsof -iTCP -sTCP:LISTEN -n -P'
alias sshkey='cat ~/.ssh/id_ed25519.pub'
alias ts='tailscale'
alias tss='tailscale status'
alias reload='exec zsh'
