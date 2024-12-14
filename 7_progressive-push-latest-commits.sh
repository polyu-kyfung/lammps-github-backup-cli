#!/bin/bash

# Constants
declare -r DELAY_MINUTES=2         # Time interval between pushing each commit (in minutes)
declare -r REMOTE="origin"

# Get the current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Print the branch name
echo "Current branch: $branch_name"
# Get the number of unpushed commits - 1
count=$(git rev-list --count "origin/$branch_name"..HEAD^)
if [[ -z "$count" ]]; then
    echo "Error: No commits found."
    exit 1
fi

# Loop to prompt user for input until a valid integer is provided
while true; do
    # Prompt user to input an integer
    echo "Enter the HEAD~ number [current: $count]:"
    read -r num
    num="${num:=$count}"
    # Validate that the input is an integer and less than or equal to $count
    if [[ "$num" =~ ^[0-9]+$ && "$num" -le "$count" ]]; then
        break
    else
        echo "Invalid input. Please enter an integer smaller than or equal to $count."
    fi
done

# Push HEAD~$num to HEAD~1 one by one with a delay in between
readonly LAST=1
queue=$(seq "$num" -1 $LAST)
for i in $queue; do
    echo "Preparing to push HEAD~$i:"
    git show "HEAD~$i" -s
    
    git push origin "HEAD~$i":"$branch_name"

    if (( i > LAST )); then
        echo "Sleeping for $DELAY_MINUTES minutes..."
        sleep "${DELAY_MINUTES}m"
    fi
done

# Push the latest commit (HEAD) to the remote repository
echo "Preparing to push HEAD:"
git show HEAD -s
git push origin HEAD:"$branch_name"
