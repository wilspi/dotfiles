#!/usr/bin/env bash
# Shared helpers for every module. Sourced, never executed directly.

# ---------------------------------------------------------------- logging ---

if [ -t 1 ]; then
	C_RED=$'\033[0;31m'; C_YEL=$'\033[0;33m'; C_BLU=$'\033[0;34m'
	C_GRN=$'\033[0;32m'; C_DIM=$'\033[2m';    C_OFF=$'\033[0m'
else
	C_RED=; C_YEL=; C_BLU=; C_GRN=; C_DIM=; C_OFF=
fi

info() { printf '%s\n' "${C_BLU}==>${C_OFF} $*"; }
ok()   { printf '%s\n' "${C_GRN} ok${C_OFF} $*"; }
warn() { printf '%s\n' "${C_YEL}  !${C_OFF} $*" >&2; }
err()  { printf '%s\n' "${C_RED}ERR${C_OFF} $*" >&2; }
skip() { printf '%s\n' "${C_DIM}  - $*${C_OFF}"; }
die()  { err "$*"; exit 1; }

# ------------------------------------------------------------------- misc ---

have() { command -v "$1" >/dev/null 2>&1; }

# Shorten $HOME to ~ for display. (A literal ~ in a replacement pattern has to
# come from a variable, otherwise it stays backslash-escaped in the output.)
_TILDE='~'
tildify() { printf '%s' "${1/#$HOME/$_TILDE}"; }

# run <cmd...> — honours DRY_RUN
run() {
	if [ "${DRY_RUN:-0}" = 1 ]; then
		skip "would run: $*"
		return 0
	fi
	"$@"
}

# ---------------------------------------------------------------------- os ---

detect_os() {
	case "$(uname -s)" in
		Darwin) echo macos ;;
		Linux)
			if [ -r /etc/os-release ] && grep -qi '^ID=arch' /etc/os-release; then
				echo arch
			else
				echo linux
			fi
			;;
		*) echo unknown ;;
	esac
}

is_macos() { [ "$OS" = macos ]; }
is_arch()  { [ "$OS" = arch ]; }

# ---------------------------------------------------------------- prompts ---
#
# Conflict policy, set by bootstrap.sh via --conflict / DOTFILES_CONFLICT:
#   ask       (default) prompt per file
#   keep      never touch an existing file
#   overwrite always replace (existing file is backed up first)

# Is there a terminal we can prompt on? Loops here often redirect stdin
# (link_tree pipes `find` into its while loop), so always talk to /dev/tty
# rather than to whatever stdin happens to be.
interactive() { [ -r /dev/tty ] && [ -t 1 ]; }

# ask <prompt> <varname>
ask() {
	local __prompt="$1" __var="$2" __reply
	read -r -p "    $__prompt " __reply < /dev/tty
	printf -v "$__var" '%s' "$__reply"
}

# confirm <question> [default:y|n]
confirm() {
	local q="$1" def="${2:-n}" ans prompt
	[ "$def" = y ] && prompt="[Y/n]" || prompt="[y/N]"
	if [ "${ASSUME_YES:-0}" = 1 ]; then
		skip "$q $prompt -> yes (--yes)"
		return 0
	fi
	if ! interactive; then
		skip "$q $prompt -> $def (non-interactive)"
		[ "$def" = y ]
		return
	fi
	ask "$q $prompt" ans
	ans="${ans:-$def}"
	[[ "$ans" =~ ^[Yy] ]]
}

_backup() {
	local target="$1" stamp
	stamp="$(date +%Y%m%d-%H%M%S)"
	mkdir -p "$BACKUP_DIR"
	local dest="$BACKUP_DIR/$(basename "$target").$stamp"
	run mv "$target" "$dest"
	warn "backed up $target -> $dest"
}

# _resolve_conflict <target> <src> — 0 = go ahead and write, 1 = keep existing
_resolve_conflict() {
	local target="$1" src="$2"

	case "${CONFLICT:-ask}" in
		keep)      skip "keeping existing $target"; return 1 ;;
		overwrite) _backup "$target"; return 0 ;;
	esac

	if ! interactive; then
		skip "keeping existing $target (non-interactive, use --conflict overwrite to replace)"
		return 1
	fi

	printf '%s\n' "${C_YEL}  ?${C_OFF} $target already exists and differs from the repo version"
	while true; do
		local ans
		ask "[k]eep existing / [o]verwrite (backup first) / [d]iff ?" ans
		case "${ans:-k}" in
			k|K) skip "keeping existing $target"; return 1 ;;
			o|O) _backup "$target"; return 0 ;;
			d|D) diff -u "$target" "$src" | sed 's/^/      /' || true ;;
			*)   echo "    answer k, o or d" ;;
		esac
	done
}

# link_file <src> <target> — symlink, with conflict handling
link_file() {
	local src="$1" target="$2"

	if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
		skip "linked   $(tildify "$target")"
		return 0
	fi

	if [ -e "$target" ] || [ -L "$target" ]; then
		if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$target" "$src"; then
			# identical content, just swap it for a link
			run rm -f "$target"
		else
			_resolve_conflict "$target" "$src" || return 0
		fi
	fi

	run mkdir -p "$(dirname "$target")"
	run ln -sfn "$src" "$target"
	ok "linked   $(tildify "$target")"
}

# copy_file <src> <target> — copy (for files the app itself rewrites)
copy_file() {
	local src="$1" target="$2"

	if [ -e "$target" ]; then
		if cmp -s "$target" "$src"; then
			skip "copied   $(tildify "$target")"
			return 0
		fi
		_resolve_conflict "$target" "$src" || return 0
	fi

	run mkdir -p "$(dirname "$target")"
	run cp "$src" "$target"
	ok "copied   $(tildify "$target")"
}

# link_tree <src_dir> <dest_dir> — symlink every file under src_dir, mirroring layout
link_tree() {
	local src_dir="$1" dest_dir="$2" rel
	[ -d "$src_dir" ] || return 0
	while IFS= read -r -d '' f; do
		rel="${f#"$src_dir"/}"
		link_file "$f" "$dest_dir/$rel"
	done < <(find "$src_dir" -type f -not -name '.DS_Store' -print0)
}

# ------------------------------------------------------------- pkg helpers ---

# read_list <file> — emit non-empty, non-comment lines
read_list() {
	[ -f "$1" ] || return 0
	sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true
}

# install_each <label> <listfile> <install_fn> <check_fn>
# Installs one package at a time so a single bad name never aborts the run.
install_each() {
	local label="$1" listfile="$2" install_fn="$3" check_fn="$4" pkg failed=()
	local items; items="$(read_list "$listfile")"
	[ -n "$items" ] || return 0

	info "$label"
	while IFS= read -r pkg; do
		if "$check_fn" "$pkg"; then
			skip "$pkg"
			continue
		fi
		if [ "${DRY_RUN:-0}" = 1 ]; then
			skip "would install $pkg"
		elif "$install_fn" "$pkg"; then
			ok "$pkg"
		else
			failed+=("$pkg")
			warn "failed: $pkg"
		fi
	done <<< "$items"

	[ ${#failed[@]} -eq 0 ] || warn "$label — could not install: ${failed[*]}"
}
