#!/bin/bash

# Define the organization name
ORG_NAME="your-organization"

# Define the search pattern (can be passed as an argument or set here)
# Default search pattern is '## Other results'
SEARCH_PATTERN="${1:-## Other results}"

# Define the file to search in (can be passed as an argument or set here)
# Default file is 'README.md'
FILE_PATH="${2:-README.md}"

# List all repositories in the organization, including private ones
# Limit the output to 200 repositories
REPOS=$(gh repo list $ORG_NAME --json name --jq '.[].name' --limit 200)

echo "Listing repositories that contain the specified pattern in $FILE_PATH:"

# Loop through each repository to check for the heading in the specified file
for REPO in $REPOS; do
  # Fetch the specified file content, handle cases where the file might not exist
  FILE_CONTENT=$(gh api "repos/$ORG_NAME/$REPO/contents/$FILE_PATH" --jq '.content' 2>/dev/null | base64 --decode 2>/dev/null)
  
  # Check if the file contains the search pattern
  if [[ -n "$FILE_CONTENT" && "$FILE_CONTENT" == *"$SEARCH_PATTERN"* ]]; then
    echo "  $REPO"
  fi
done
