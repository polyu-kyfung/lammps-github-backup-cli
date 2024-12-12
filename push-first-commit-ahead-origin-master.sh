#!/bin/bash

# Set delay in minutes
DELAY_MINUTES=2.5

echo ""
echo "Checking for unpushed commits..."

while true; do

  # Check for any unpushed commits
  UNPUSHED_COMMITS=$(git log origin/master..HEAD --oneline)

  if [ -z "$UNPUSHED_COMMITS" ]; then
    echo ""
    echo "All commits have been pushed to origin."
    break
  fi

  # Fetch the hash of the first unpushed commit ahead of origin/master
  FIRST_UNPUSHED_COMMIT_HASH=$(git log --reverse --ancestry-path origin/master..HEAD --format="%H" | head -n 1)

  # Display the hash and the commit message to the screen for confirmation
  COMMIT_MSG=$(git log -1 --oneline ${FIRST_UNPUSHED_COMMIT_HASH})
  echo ""
  echo "Start to push: ${COMMIT_MSG}"
  echo ""

  # Push that commit to the master branch
  git push origin ${FIRST_UNPUSHED_COMMIT_HASH}:master

  # Sleep for the specified delay
  echo ""
  echo "Sleeping for ${DELAY_MINUTES} minutes..."
  sleep ${DELAY_MINUTES}m
done
