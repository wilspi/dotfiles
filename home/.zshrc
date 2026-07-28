# Interactive zsh. Everything lives in $DOTFILES/shell/*.zsh so this file stays
# a table of contents.

# ------------------------------------------------------------------ history ---
HISTFILE="$XDG_STATE_HOME/zsh/history"
[ -d "${HISTFILE:h}" ] || mkdir -p "${HISTFILE:h}"
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_VERIFY SHARE_HISTORY INC_APPEND_HISTORY

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS EXTENDED_GLOB INTERACTIVE_COMMENTS
setopt NO_BEEP

# ---------------------------------------------------------------- oh-my-zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="false"
zstyle ':omz:update' mode reminder

plugins=(
	git
	colored-man-pages
	command-not-found
	history-substring-search
	zsh-completions
	zsh-autosuggestions
	zsh-syntax-highlighting   # must stay last
)
[[ "$OSTYPE" == linux* ]] && plugins=(archlinux $plugins)
[[ "$OSTYPE" == darwin* ]] && plugins=(macos brew $plugins)

[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------------- config ---
for f in "$DOTFILES"/shell/*.zsh; do
	[ -r "$f" ] && source "$f"
done
unset f

# Machine-local overrides and anything that must not be in a public repo.
[ -r "$HOME/.secrets" ] && source "$HOME/.secrets"
[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
