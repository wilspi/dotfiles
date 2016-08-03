source ~/.bash_aliases
source ~/.bash_functions

# Use .secrets for stuff that you don't want to share in your public, versioned repo.
if [[ -e ~/.secrets ]]; then
  source ~/.secrets
fi