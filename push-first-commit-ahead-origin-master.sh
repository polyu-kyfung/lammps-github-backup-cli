#!/bin/bash

# Constants
declare -r DELAY_MINUTES=1         # Time interval between pushing each commit (in minutes)
declare -r REMOTE="origin"

# Get the current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Print the branch name
echo "Current branch: $branch_name"


echo "Checking for unpushed commits..."

while true; do

  # Check for any unpushed commits compared to the remote branch
  UNPUSHED_COMMITS=$(git log "$REMOTE/$branch_name"..HEAD --oneline)

  if [ -z "$UNPUSHED_COMMITS" ]; then
    echo ""
    echo "All commits have been pushed to $REMOTE."
    break
  fi

  # Fetch the hash of the first unpushed commit ahead of the remote branch
  FIRST_UNPUSHED_COMMIT_HASH=$(git log --reverse --ancestry-path "origin/$branch_name"..HEAD --format="%H" | head -n 1)

  # Display the hash and the commit message to the screen for confirmation
  COMMIT_MSG=$(git log -1 --oneline ${FIRST_UNPUSHED_COMMIT_HASH})
  echo ""
  echo "Start to push: ${COMMIT_MSG}"
  echo ""

  # Push the commit to the remote branch
  git push $REMOTE "${FIRST_UNPUSHED_COMMIT_HASH}":"$branch_name"

  # Get the number of remaining unpushed commits
  count=$(git rev-list --count "$REMOTE/$branch_name"..HEAD)

  # Sleep for the specified delay before pushing the next commit
  echo "$count unpushed commits remain. Sleeping for ${DELAY_MINUTES} minutes..."
  sleep "${DELAY_MINUTES}m"
done
