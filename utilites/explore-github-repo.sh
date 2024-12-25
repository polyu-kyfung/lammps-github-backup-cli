#!/bin/bash

# Copyright (c) 2024 Chris K.Y. Fung
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
#   GitHub Repository Explorer Script
#   This script helps explore a GitHub repository based on specified parameters.
#
# Features:
#   - Uses default values or parses arguments for repository owner, prefix, suffix, and midtag
#   - Prompts user for file type, cutting speed, groove depth, and shape
#   - Generates repository name and performs actions like opening in browser, displaying description, checking disk usage, and updating description
#
# Usage:
#   ./explore-github-repo.sh [-o owner] [-p prefix] [-s suffix] [-m midtag]
#
# Author: Chris K.Y. Fung (chriskyfung.github.io)
# Created: 2023-08-30
# Updated: 2024-12-25
# Repository: https://github.com/polyu-kyfung/lammps-github-backup-cli

# Default values
declare -r default_owner="${GITHUB_REPO_OWNER}" # repository owner
declare -r default_prefix="lammps-nanocutting-SiC_" # repo name prefix
declare -r default_suffix="_EA.tersoff_lmp20140312" # repo name suffix, e.g. "_1994.tersoff", "_EA.tersoff"
declare -r default_midtag=""

# Parse arguments
while getopts "o:p:s:m:" opt; do
    case $opt in
        o) owner="$OPTARG" ;;
        p) prefix="$OPTARG" ;;
        s) suffix="$OPTARG" ;;
        m) midtag="$OPTARG" ;;
        *) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

# Use default values if not set by arguments
owner="${owner:-$default_owner}"
prefix="${prefix:-$default_prefix}"
suffix="${suffix:-$default_suffix}"
midtag="${midtag:-$default_midtag}"

# Confirm the affixes with the user
while true; do
    echo "- Owner: $owner"
    echo "- Prefix: $prefix"
    echo "- Suffix: $suffix"
    if [[ -n "$midtag" ]]; then
        echo "- Midtag: $midtag"
    fi
    read -r -p "Do you confirm to use these affixes for the repository name? (y/n) " yN

    case $yN in
        y) break;;
        n) exit;;
        *) echo "Invalid input";;
    esac
done

# Prompt user to input the file type
while true; do
    echo "Enter the type of data files [results, extra-data]:"
    read -r filetype

    case $filetype in
        results) str="LAMMPS simulation"; break;;
        extra-data) str="force"; break;;
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

# Prompt user to input the groove depth
while true; do
    read -r -p "Enter the groove depth [no, 3, 6 or 9]: " depth

    if [[ "$depth" =~ ^[nN][oO]?$ ]]; then
        middle_name="${filetype}_defect-free-tool_speed-${speed}.0"
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
if [[ "$depth" =~ ^[0-9]$ ]]; then
    while true; do
        read -r -p "Choose the groove shape [isosceles acute (a) / isosceles right (r)]: " shape
        case $shape in
            [aA]* ) width=$halfwidth; break;;
            [rR]* ) width=$depth; break;;
            * ) echo "Please type either a or r.";;
        esac
    done
    middle_name="${filetype}_${depth}-by-${width}-v-groove-defect-tool_speed-${speed}.0"
fi

repo="$owner/${prefix}${middle_name}${suffix}"

# Define actions
actions=(
    "Open the GitHub repository in the browser"
    "Display the description and the README"
    "Check the disk usage"
    "Update the description"
)

# Prompt user to choose an action
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
