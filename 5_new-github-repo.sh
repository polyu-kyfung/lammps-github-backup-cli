#!/bin/bash

owner="${GITHUB_REPO_OWNER}"
topics="lammps-data,molecular-dynamics-simulation"

# Prompt user to input the file type
# Append values to the $topics varible based on the file type
while true; do

  echo "Enter the type of data files [dump/force/rerun]"
  read -r filetype

  case $filetype in
    dump)
      topics+=",trajectory-data"
      break;;
    force)
      topics+=",force-data"
      break;;
    mat)
      ;;
    rerun)
      break;;
    *)
      echo "Invalid input"
      ;;
  esac
  
done

# Generate the new repository name from the name of working directory
dirname=${PWD##*/}
reponame=${dirname}
pattern="results"
if [[ "${filetype}" != "dump" ]]; then 
  reponame=${dirname/${pattern}/${filetype}-${pattern}}
fi

if [ ${#reponame} -gt 100 ]; then
  readonly NC_COLOR='\e[0m'
  readonly RED_COLOR='\e[0;31m'
  readonly YELLOW_COLOR='\e[1;33m'
  echo -e "${RED_COLOR}Name is too long (maximum is 100 characters)${NC_COLOR}"
  echo -e "Please create ${YELLOW_COLOR}$reponame${NC_COLOR} manually on GitHub website."
  exit 1
fi

# Create an empty private repository on GitHub
gh repo create "${owner}/${reponame}" --private --source=.

# Assign the topics of the GitHub repository
gh repo edit --add-topic $topics

# Prompt user to choose whether to view the online repository or not
read -r -p "Do you want to open the repository in the broswer? (y/n) " ans

if [[ "$ans" =~ ^[yY]([eE][sS])?$ ]]; then
  gh repo view --web
fi
