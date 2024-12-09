#!/bin/bash

declare -r owner="${GITHUB_REPO_OWNER}"

# Repository names to rename
declare -a repoNames=(
    "owner/repo1"	
    "owner/repo2"	
    "owner/repo3"	
    )

declare -r oldString="EA-potential-"
declare -r newString=""
declare -r suffix="--potential-EA"

# now loop through the above array
for repoName in "${repoNames[@]}"
do
    echo "$repoName"
    # or do whatever with individual element of the array
    newName=${repoName/$oldString/$newString}$suffix
    NoOwnerName=${newName#"$owner"/}
    echo "rename to $NoOwnerName"
    gh repo rename "$NoOwnerName" -R "$repoName"
done
