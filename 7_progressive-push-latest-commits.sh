#!/bin/bash

# Constants
BRANCH="master"         # Remote branch name
DELAY_MINUTES=3         # Time interval between pushing each commit (in minutes)

# Get the number of unpushed commits
count=$(git rev-list --count origin/${BRANCH}..HEAD^)
if [[ -z "$count" ]]; then
    echo "Error: No commits could be found."
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
    echo "Pushing HEAD~$i to remote:"
    git show HEAD~$i -s
    
    git push origin HEAD~$i:$BRANCH

    if (( i > LAST )); then
        echo "Sleeping. Resume in $DELAY_MINUTES minutes."
        sleep "${DELAY_MINUTES}m"
    fi
done

# Push the latest commit (HEAD) to the remote repository
echo "Pushing HEAD to remote:"
git show HEAD -s
git push origin HEAD:$BRANCH
