#!/usr/bin/env bash
# Single entrypoint. Idempotent: safe to re-run any time.
#
#   ./bootstrap.sh                       # everything, prompting on conflicts
#   ./bootstrap.sh --only shell,runtimes # just those modules
#   ./bootstrap.sh --skip packages
#   ./bootstrap.sh --conflict keep       # never touch existing config files
#   ./bootstrap.sh --dry-run             # show what would happen, change nothing
#   ./bootstrap.sh --yes                 # answer yes to every confirm
#   ./bootstrap.sh --list                # list module names

set -uo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$DOTFILES/lib/common.sh"

export OS; OS="$(detect_os)"
export BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"
export CONFLICT="${DOTFILES_CONFLICT:-ask}"
export DRY_RUN=0
export ASSUME_YES=0

ONLY=""
SKIP=""

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while [ $# -gt 0 ]; do
	case "$1" in
		--only)     ONLY="$2"; shift 2 ;;
		--skip)     SKIP="$2"; shift 2 ;;
		--conflict) CONFLICT="$2"; shift 2 ;;
		--dry-run)  DRY_RUN=1; shift ;;
		--yes|-y)   ASSUME_YES=1; shift ;;
		--list)     ls "$DOTFILES/modules" | sed -e 's/^[0-9]*-//' -e 's/\.sh$//'; exit 0 ;;
		-h|--help)  usage ;;
		*)          die "unknown flag: $1 (try --help)" ;;
	esac
done

case "$CONFLICT" in ask|keep|overwrite) ;; *) die "--conflict must be ask|keep|overwrite" ;; esac
[ "$OS" = unknown ] && die "unsupported OS: $(uname -s)"
[ "$OS" = linux ] && warn "non-Arch Linux detected — package module will be skipped"

wants() {
	local name="$1"
	[ -n "$ONLY" ] && { [[ ",$ONLY," == *",$name,"* ]] || return 1; }
	[ -n "$SKIP" ] && { [[ ",$SKIP," == *",$name,"* ]] && return 1; }
	return 0
}

printf '%s\n' "${C_BLU}dotfiles${C_OFF} — os=${OS} conflict=${CONFLICT}$([ "$DRY_RUN" = 1 ] && echo ' (dry run)')"
echo

for module in "$DOTFILES"/modules/*.sh; do
	name="$(basename "$module" .sh)"; name="${name#*-}"
	wants "$name" || { skip "module $name (filtered out)"; continue; }

	printf '%s\n' "${C_BLU}────${C_OFF} ${name}"
	# shellcheck source=/dev/null
	if ! bash "$module"; then
		warn "module '$name' exited non-zero — continuing"
	fi
	echo
done

info "done. backups (if any) are in $(tildify "$BACKUP_DIR")"
[ -f "$HOME/.secrets" ] || warn "no ~/.secrets yet — cp .secrets.example ~/.secrets && \$EDITOR ~/.secrets"
echo "restart your shell:  exec zsh"
