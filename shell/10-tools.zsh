# Tool activation. Sourced from ~/.zshrc.

# mise — the single version manager for node / python / rust / go / java.
# Activating (rather than just shimming) makes `mise use` take effect immediately.
if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate zsh)"
fi

# direnv — per-directory env vars (.envrc). mise handles versions, direnv handles secrets.
if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

# fzf — ctrl-r history, ctrl-t files, alt-c cd
if command -v fzf >/dev/null 2>&1; then
	source <(fzf --zsh) 2>/dev/null
	export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
	command -v fd >/dev/null 2>&1 && \
		export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Homebrew completions (must come before compinit, which oh-my-zsh already ran;
# re-running for the brew site-functions is cheap enough at startup).
if command -v brew >/dev/null 2>&1; then
	FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

command -v bat >/dev/null 2>&1 && export MANPAGER="sh -c 'col -bx | bat -l man -p'"
