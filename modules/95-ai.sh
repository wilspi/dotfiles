#!/usr/bin/env bash
# AI coding agents: claude, codex, gemini.
#
# Each agent reads a differently-named instruction file, so all three are
# symlinked to one source (ai/AGENTS.md) — the rules cannot drift apart.
# Skills come from the skills repo, whose own installer fans out to every agent.
set -uo pipefail
source "$DOTFILES/lib/common.sh"

SKILLS_REPO="${SKILLS_REPO:-$HOME/Documents/CodeStuff/skills}"

# --------------------------------------------------------------- agent clis ---
if is_macos; then
	# claude-code and codex are casks, gemini-cli is a formula — all handled by
	# the packages module. Nothing to install here.
	:
elif is_arch; then
	# Not in the Arch repos; install as global npm packages on mise's node.
	if have npm; then
		for pkg in @anthropic-ai/claude-code @openai/codex @google/gemini-cli; do
			name="${pkg##*/}"
			if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
				skip "$name"
			elif run npm install -g "$pkg"; then
				ok "$name"
			else
				warn "could not install $pkg"
			fi
		done
		run mise reshim >/dev/null 2>&1 || true
	else
		warn "npm not found — run the runtimes module first"
	fi
fi

# -------------------------------------------------- shared global rules file ---
# Only agents that are actually installed get a link.
info "shared agent rules (ai/AGENTS.md)"
link_agent_rules() {
	local agent_dir="$1" filename="$2"
	if [ -d "$agent_dir" ]; then
		link_file "$DOTFILES/ai/AGENTS.md" "$agent_dir/$filename"
	else
		skip "$(basename "$agent_dir") not installed"
	fi
}
link_agent_rules "$HOME/.claude" CLAUDE.md
link_agent_rules "$HOME/.codex"  AGENTS.md
link_agent_rules "$HOME/.gemini" GEMINI.md

# ------------------------------------------------------------------- skills ---
if [ -d "$SKILLS_REPO/.git" ]; then
	skip "skills repo present"
elif confirm "clone the skills repo into $(tildify "$SKILLS_REPO")?" y; then
	run git clone git@github.com:wilspi/skills.git "$SKILLS_REPO" \
		|| warn "clone failed — check ssh access to github"
fi

if [ -x "$SKILLS_REPO/install-skills.sh" ]; then
	info "installing skills into every agent"
	if [ "${DRY_RUN:-0}" = 1 ]; then
		"$SKILLS_REPO/install-skills.sh" --dry-run | tail -5 | sed 's/^/    /'
	else
		"$SKILLS_REPO/install-skills.sh" | tail -5 | sed 's/^/    /' \
			|| warn "install-skills.sh failed"
	fi
else
	skip "no skills repo installer found"
fi

# ------------------------------------------------------------------- creds ---
# Agent credentials live in the agent's own dir and must never reach a repo.
for f in "$HOME/.codex/auth.json" "$HOME/.claude/.credentials.json"; do
	if [ -f "$f" ]; then
		run chmod 600 "$f"
	fi
done

exit 0
