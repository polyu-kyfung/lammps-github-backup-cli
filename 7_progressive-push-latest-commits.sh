#!/bin/bash

# Copyright (c) 2023-2024 Chris K.Y. Fung
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Description:
#   Progressive Git Push Script
#   This script progressively pushes unpushed commits to a remote repository
#   with a configurable delay between pushes to avoid overwhelming the server.
#
# Features:
#   - Detects current branch and verifies remote branch existence
#   - Counts unpushed commits and allows user to select push range
#   - Pushes commits one by one with configurable delay
#   - Includes colored output for better visibility
#
# Usage:
#   ./7_progressive-push-latest-commits.sh
#
# Author: Chris K.Y. Fung (chriskyfung.github.io)
# Created: 2023-08-04
# Updated: 2024-12-25
# Repository: https://github.com/polyu-kyfung/lammps-github-backup-cli

# Constants
declare -r DELAY_MINUTES=2         # Time interval between pushing each commit (in minutes)
declare -r REMOTE="origin"

readonly NC_COLOR='\e[0m'
readonly RED_COLOR='\e[0;31m'
readonly YELLOW_COLOR='\e[1;33m'

# Get the current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Print the branch name
echo "Current branch: $branch_name"

# Check if the branch exists in the remote
if git show-ref --verify --quiet "refs/remotes/$REMOTE/$branch_name"; then
    echo "Branch '$branch_name' exists in remote '$REMOTE'."
else
    echo "Branch '$branch_name' does not exist in remote '$REMOTE'."
    echo -e "Use $YELLOW_COLOR'git push -u origin $RED_COLOR<COMMIT_HASH>$YELLOW_COLOR:refs/heads/$branch_name'$NC_COLOR to create the remote branch."
    exit 1
fi

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
