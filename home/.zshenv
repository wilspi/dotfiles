# Read by every zsh, interactive or not. Keep it to environment only — no output,
# no completions, nothing slow.

export DOTFILES="$HOME/Documents/CodeStuff/dotfiles"

# XDG base directories — everything below assumes these exist.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R -F -X"
export LANG="en_US.UTF-8"

# Keep $HOME tidy: tools that honour XDG.
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export AWS_CONFIG_FILE="$HOME/.aws/config"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export PYTHONDONTWRITEBYTECODE=1

# PATH — built once here, deduped by zsh's typeset -U.
typeset -U path PATH
path=(
	"$HOME/.local/bin"      # mise shims live here
	"$XDG_DATA_HOME/cargo/bin"
	"$DOTFILES/bin"
	/opt/homebrew/bin /opt/homebrew/sbin
	/usr/local/bin /usr/local/sbin
	$path
)
export PATH
