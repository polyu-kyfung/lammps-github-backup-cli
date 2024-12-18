#!/bin/bash

# Constants
declare -r DELAY_MINUTES=1         # Time interval between pushing each commit (in minutes)
declare -r REMOTE="origin"

readonly NC_COLOR='\e[0m'
readonly RED_COLOR='\e[0;31m'
readonly YELLOW_COLOR='\e[1;33m'

# Get the current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Print the branch name
echo "Current branch: $branch_name"

# Check if the branch exists in the remote repository
if git show-ref --verify --quiet "refs/remotes/$REMOTE/$branch_name"; then
    echo "Branch '$branch_name' exists in remote '$REMOTE'."
else
    echo "Branch '$branch_name' does not exist in remote '$REMOTE'."
    echo -e "Use $YELLOW_COLOR'git push -u origin $RED_COLOR<COMMIT_HASH>$YELLOW_COLOR:refs/heads/$branch_name'$NC_COLOR to create the remote branch."
    exit 1
fi

echo "Checking for unpushed commits..."

while true; do

  # Check for any unpushed commits compared to the remote branch
  UNPUSHED_COMMITS=$(git log "$REMOTE/$branch_name"..HEAD --oneline)

  if [ -z "$UNPUSHED_COMMITS" ]; then
    echo ""
    echo "All commits have been pushed to $REMOTE."
    exit 1
  fi

  # Fetch the hash of the first unpushed commit ahead of the remote branch
  FIRST_UNPUSHED_COMMIT_HASH=$(git log --reverse --ancestry-path "origin/$branch_name"..HEAD --format="%H" | head -n 1)

  # Display the hash and the commit message for confirmation
  COMMIT_MSG=$(git log -1 --oneline --format="%s" "${FIRST_UNPUSHED_COMMIT_HASH}")
  echo ""
  echo -e "Preparing to push commit: $YELLOW_COLOR${FIRST_UNPUSHED_COMMIT_HASH:0:8}$NC_COLOR $COMMIT_MSG"

  # Push the commit to the remote branch
  git push $REMOTE "${FIRST_UNPUSHED_COMMIT_HASH}":"$branch_name"

  # Get the number of remaining unpushed commits
  count=$(git rev-list --count "$REMOTE/$branch_name"..HEAD)

  # Sleep for the specified delay before pushing the next commit
  echo "$count unpushed commits remain. Sleeping for ${DELAY_MINUTES} minutes..."
  sleep "${DELAY_MINUTES}m"
done
