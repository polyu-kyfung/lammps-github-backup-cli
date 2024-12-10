#!/bin/bash

declare -r owner="${GITHUB_REPO_OWNER}" # repository owner
declare -r prefix="lammps-nanocutting-SiC_" # repo name prefix
declare -r suffix="--potential-EA--eq2" # repo name suffix, e.g. "--potential-EA", "--Tersoff-1994"

while true; do
    echo "- Prefix: $prefix"
    echo "- Suffix: $suffix"
    read -r -p "Do you confirm to use these affixes for the repository name? (y/n) " yN

    case $yN in
        y) break;;
        n) exit;;
        *) echo "Invalid input";;
    esac
done

# Prompt user to input the file type
# Determine the strings passed to the string template of repository description
while true; do

    echo "Enter the type of data files [dump/force/rerun]"
    read -r filetype

    case $filetype in
        dump) str="LAMMPS simulation"; break;;
        force) str="force"; break;;
        mat) break;;
        rerun) break;;
        *) echo "Invalid input";;
    esac

done

# Prompt user to input the cutting speed
while true; do
    read -r -p "Enter the cutting speed [1-3]: " speed
    if [[ "$speed" =~ ^[1-3]$ ]]; then
        break
    else
        echo "Invalid input"
    fi
done

# Prompt user to input the goove depth
# If "no" is received, format the middle part of the repo name with the text "defect-free"
# Otherwise, calculate half width based on the user's input 
while true; do
    read -r -p "Enter the groove depth [no, 3, 6 or 9]: " depth

    if [[ "$depth" =~ ^[nN][oO]?$ ]]; then
        middle="${filetype}-results_defect-free-tool_speed-${speed}.0"
        depth="NaN"
        break
    elif [[ "$depth" =~ ^[3|6|9]$ ]]; then
        halfwidth=$(printf %.1f "$((depth*5))e-1" | printf %g $(</dev/stdin))  # return "1.5", "3" or "4.5"
        break
    else
        echo "Invalid input"
    fi
done

# If the user input a positive number above, ask to input the groove shape
# Then, determine the groove width based on the shape
# format the middle part of repo name with the text pattern "${depth}-by-${width}-v-groove-defect"
if [[ "$depth" =~ ^[0-9]$ ]]; then

    while true; do
        read -r -p "Choose the groove shape [isosceles acute (a) / isosceles right (r)]: " shape
        case $shape in
            [aA]* ) width=$halfwidth; break;;
            [rR]* ) width=$depth; break;;
            * ) echo "Please type either a or r.";;
        esac
    done

    middle="${filetype}-results_${depth}-by-${width}-v-groove-defect-tool_speed-${speed}.0"
    
fi

repo="$owner/${prefix}${middle}${suffix}"

actions=(
    "Open the GitHub repository in the browser"
    "Display the description and the README"
    "Check the disk usage"
    "Update the description"
)

while true; do
    COLUMNS=1
    PS3="(Use Ctrl-C to exit) #? "
    echo "Choose an action:"
    select action in "${actions[@]}"; do
        case $REPLY in
            1 ) echo "Opening $repo in the browser"
                gh repo view "$repo" --web;
                break;;
            2 ) # Display the description and the README
                gh repo view "$repo";
                break;;
            3 ) echo "Checking the disk usage of $repo"
                gh repo view "$repo" --json diskUsage;
                break;;
            4 ) echo "Updating the repository description to be:"
                if [[ "$depth" =~ "NaN" ]]; then
                    descr="This repository contains ${str} results for the molecular dynamics simulation of nanometric cutting of 3C-SiC against a defect-free diamond tool with at the speed of ${speed}00 m s^-1"
                else
                    descr="This repository contains ${str} results for the molecular dynamics simulation of nanometric cutting of 3C-SiC against a diamond tool with a v-groove surface defect in ${depth}-by-${width} cell units at the speed of ${speed}00 m s^-1"
                fi
                echo "$descr"
                gh repo edit "$repo" --description "$descr";
                break;;
            * ) echo "Invalid input" ;;
        esac
    done
    echo ""
done
