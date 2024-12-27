# Custom bash completion function for 'gh repo clone' command
# 
# Copyright (C) 2024 Chris K.Y. Fung (chriskyfung.github.io)
# Conceptually based on gitcompletion (http://gitweb.hawaga.org.uk/).
# Distributed under the GNU General Public License, version 2.0.
#
# To use these routines:
#
#    1) Copy this file to somewhere (e.g. ~/.gh-repo-clone-completion.bash).
#    2) Add the following line to your .bashrc/.zshrc:
#        source ~/.gh-repo-clone-completion.bash
#
# Compatible with bash 3.2.57.

_gh_repo_clone_custom() {
  local git_flags cur
  COMPREPLY=()  # Initialize the array for completion results
  cur="${COMP_WORDS[COMP_CWORD]}"  # Get the current word to be completed

  # Define the list of git flags for completion
  git_flags="--also-filter-submodules --branch= --depth= --filter= --no-checkout --quiet --recurse-submodules --shallow-since= --single-branch --sparse --tags --verbose"

  # Check if the command is 'gh repo clone'
  if [[ "${COMP_WORDS[1]} ${COMP_WORDS[2]}" == "repo clone" ]]; then
    if [[ ! "$COMP_LINE" =~ ' -- ' && "${cur:0:1}" != "-" ]]; then
      # Suggest repository names if no flags are present and the current word does not start with '-'
      COMPREPLY=( $(compgen -W "$(gh api graphql --paginate -f query='query($endCursor: String) { viewer { repositories(first: 100, after: $endCursor) { nodes { nameWithOwner } pageInfo { hasNextPage endCursor } } } }' -q '.data.viewer.repositories.nodes[] | .nameWithOwner')" -- "$cur") )
    elif [[ "$COMP_LINE" =~ ' -- ' ]]; then
      # Suggest git flags if flags are present and the current word starts with '-'
      COMPREPLY=( $(compgen -W "$git_flags" -- "$cur") )
    else 
      # Fallback to default gh completion
      __start_gh
    fi
  else
    # Fallback to default gh completion for other commands
    __start_gh
  fi
  return 0
}

# Register the custom completion function for the 'gh' command
complete -F _gh_repo_clone_custom gh
