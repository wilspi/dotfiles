# Cross-platform shell functions.

# mkdir + cd
mkd() { mkdir -p "$1" && cd "$1"; }

# Extract most archive formats
extract() {
	[ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
	case "$1" in
		*.tar.bz2|*.tbz2) tar -jxvf "$1" ;;
		*.tar.gz|*.tgz)   tar -zxvf "$1" ;;
		*.tar.xz)         tar -Jxvf "$1" ;;
		*.tar.zst)        tar --zstd -xvf "$1" ;;
		*.tar)            tar -xvf "$1" ;;
		*.bz2)            bunzip2 "$1" ;;
		*.gz)             gunzip "$1" ;;
		*.xz)             unxz "$1" ;;
		*.zst)            unzstd "$1" ;;
		*.zip|*.ZIP)      unzip "$1" ;;
		*.7z)             7z x "$1" ;;
		*.rar)            unrar x "$1" ;;
		*.dmg)            hdiutil mount "$1" ;;
		*) echo "extract: don't know how to handle '$1'" >&2; return 1 ;;
	esac
}

# Strip audio out of a video
get_audio() { ffmpeg -i "$1" -vn -acodec libmp3lame -q:a 2 "${1%.*}.mp3"; }

# Scaffold a repo with pinned runtimes. usage: pin node@22 python@3.13
pin() {
	[ $# -gt 0 ] || { echo "usage: pin node@22 python@3.13 rust@stable" >&2; return 1; }
	mise use "$@" && mise install && mise ls --current
}

# Serve the current directory over http. usage: serve [port]
serve() { python3 -m http.server "${1:-8000}"; }

# URL-encode / decode a string
urlencode() { python3 -c 'import sys,urllib.parse as u; print(u.quote_plus(sys.argv[1]))' "$1"; }
urldecode() { python3 -c 'import sys,urllib.parse as u; print(u.unquote_plus(sys.argv[1]))' "$1"; }

# Pretty-print json from a string or stdin
jsonf() { if [ $# -gt 0 ]; then printf '%s' "$1" | jq .; else jq .; fi; }

# What is listening on a port. usage: onport 8080
onport() { sudo lsof -nP -iTCP:"$1" -sTCP:LISTEN; }

# Files bigger than N megabytes under the current dir. usage: bigfiles [200]
bigfiles() { find . -type f -size +"${1:-200}"M -exec ls -lh {} \; 2>/dev/null; }

# Re-run the dotfiles setup
dotsync() { "$DOTFILES/bootstrap.sh" "$@"; }
