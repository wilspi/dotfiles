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

# Public IP address.
myip() {
	curl -fsS https://api.ipify.org && printf '\n'
}

# Local, non-loopback IPv4 addresses.
localip() {
	case "$OSTYPE" in
		darwin*)
			ifconfig | awk '
				/^[[:alnum:]]/ { interface=$1; sub(/:$/, "", interface) }
				$1 == "inet" && $2 != "127.0.0.1" { print interface, $2 }
			'
			;;
		linux*)
			command ip -4 -brief address show scope global
			;;
		*)
			echo "localip: unsupported OS: $OSTYPE" >&2
			return 1
			;;
	esac
}

# Discover devices on the active LAN. An explicit CIDR may be supplied.
# usage: lan [192.168.1.0/24]
lan() {
	local target="${1:-}" interface address mask prefix=0 octet mask_value bit

	if ! command -v nmap >/dev/null 2>&1; then
		echo "lan: nmap is not installed; run: dotsync --only packages" >&2
		return 1
	fi

	if [ -z "$target" ]; then
		case "$OSTYPE" in
			darwin*)
				interface="$(route -n get default 2>/dev/null | awk '/interface:/ { print $2; exit }')"
				if [ -z "$interface" ]; then
					interface="$(ifconfig | awk '
						/^[[:alnum:]]/ { interface=$1; sub(/:$/, "", interface) }
						$1 == "inet" && $2 != "127.0.0.1" && interface ~ /^en[0-9]+$/ {
							print interface
							exit
						}
					')"
				fi
				if [ -n "$interface" ]; then
					address="$(ifconfig "$interface" 2>/dev/null | awk '$1 == "inet" { print $2; exit }')"
					mask="$(ifconfig "$interface" 2>/dev/null | awk '$1 == "inet" { print $4; exit }')"
				fi
				[ -n "$address" ] && [ -n "$mask" ] || {
					echo "lan: could not determine the active IPv4 subnet; pass one explicitly" >&2
					return 1
				}
				if [[ "$mask" == 0x* ]]; then
					mask_value=$(( mask ))
					for (( bit = 31; bit >= 0; bit-- )); do
						(( mask_value & (1 << bit) )) && (( prefix += 1 )) || break
					done
				else
					for octet in ${(s:.:)mask}; do
						case "$octet" in
							255) (( prefix += 8 )) ;;
							254) (( prefix += 7 )) ;;
							252) (( prefix += 6 )) ;;
							248) (( prefix += 5 )) ;;
							240) (( prefix += 4 )) ;;
							224) (( prefix += 3 )) ;;
							192) (( prefix += 2 )) ;;
							128) (( prefix += 1 )) ;;
							0) ;;
							*) echo "lan: unsupported subnet mask: $mask" >&2; return 1 ;;
						esac
					done
				fi
				target="$address/$prefix"
				;;
			linux*)
				interface="$(command ip -4 route show default 2>/dev/null | awk '{ print $5; exit }')"
				[ -n "$interface" ] && target="$(command ip -4 -o address show dev "$interface" scope global 2>/dev/null | awk '{ print $4; exit }')"
				[ -n "$target" ] || {
					echo "lan: could not determine the active IPv4 subnet; pass one explicitly" >&2
					return 1
				}
				;;
			*)
				echo "lan: unsupported OS: $OSTYPE" >&2
				return 1
				;;
		esac
	fi

	echo "Scanning $target ..."
	nmap -sn "$target"
}

# Files bigger than N megabytes under the current dir. usage: bigfiles [200]
bigfiles() { find . -type f -size +"${1:-200}"M -exec ls -lh {} \; 2>/dev/null; }

# Re-run the dotfiles setup
dotsync() { "$DOTFILES/bootstrap.sh" "$@"; }
