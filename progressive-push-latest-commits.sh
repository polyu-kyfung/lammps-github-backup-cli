#!/bin/bash

branch="master" # Remote branch name
delay="5" # Time interval between pushing each commit (in minutes)

# Get the number of unpushed commits
count=$(git rev-list --count origin/${branch}..HEAD^)
if [[ ! "$count" ]]; then
	echo "Error: No commits could be found."
	exit
fi

while true; do
	# Prompt user to input an integer
	echo "Enter the HEAD~ number [current: $count]:"
	read -r num
	num="${num:=$count}"
	# Validate the input is an integer smaller than $count
	if [[ "$num" =~ ^[0-9]+$ && "$num" -le "$count" ]]; then
		break
	else
		echo "Invalid input. Please enter an integer smaller than ${count}."
	fi
done

# Push HEAD~$num to HEAD~1 one by one with a delay in between
readonly last=1
queue=$(seq "$num" -1 $last)
for i in $queue; do
	echo "Pushing HEAD~${i} to remote:"
	git show HEAD~${i} -s
	
	git push origin HEAD~${i}:${branch}

	if (( i > last )); then
			echo "Sleeping. Resume in ${delay} minutes."
			sleep ${delay}m
	fi
done

# Push HEAD to remotecd
echo "Pushing HEAD to remote:"
git show HEAD -s
git push origin HEAD:${branch}
