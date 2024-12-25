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
#   Repository Links Generator Script
#   This script generates markdown links for repositories based on specified parameters.
#
# Features:
#   - Uses default values or parses arguments for repository owner, prefix, suffix, and midtag
#   - Generates links for different speeds, depths, shapes, and file types
#   - Outputs the links to a markdown file
#
# Usage:
#   ./gen-repo-links.sh [-o owner] [-p prefix] [-s suffix] [-m midtag]
#
# Author: Chris K.Y. Fung (chriskyfung.github.io)
# Created: 2023-08-29
# Updated: 2024-12-25
# Repository: https://github.com/polyu-kyfung/lammps-github-backup-cli

# Default values
declare -r default_owner="${GITHUB_REPO_OWNER}" # repository owner
declare -r default_prefix="lammps-nanocutting-SiC_" # repo name prefix
declare -r default_suffix="_1994.tersoff" # repo name suffix, e.g. "_1994.tersoff", "_EA.tersoff"
declare -r default_midtag=""
declare -r default_output_file="repo-links.md"

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

output_file="${default_output_file}_${owner}_${prefix}${midtag}${suffix}"

# Define ranges and arrays
speeds=$(seq 1 1 3)
depths=$(seq 3 3 9)
shapes=("a" "r")
filetypes=("results" "extra-data")

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

# Generate the markdown file
echo ""
> "$output_file"  # Truncate the file if it exists
for speed in $speeds; do
    repos=()
    links=()
    caption="At a cutting speed of ${speed}00 m s^-1, the simulation results of the defective tools with the different v-groove sizes and shapes:"
    {
    echo "$caption"
    echo ""
    echo "| depth |             isosceles acute (a)            |            isosceles right (r)            |"
    echo "| :---: | :----------------------------------------: | :---------------------------------------: |"
    } >> "$output_file"

    for depth in $depths; do
        row="|   $depth   | "
        halfwidth=$(printf %.1f "$((depth*5))e-1" | printf %g $(</dev/stdin))  # return "1.5", "3" or "4.5"
        for shape in ${shapes[@]}; do
            case $shape in
                [aA]* ) width=$halfwidth; ;;
                [rR]* ) width=$depth; ;;
                * ) echo "Invalid $shape value";;
            esac
            cell=""
            for filetype in ${filetypes[@]}; do
                middle_name="results_$depth-by-$width-v-groove-defect-tool${midtag}_speed-$speed.0"
                repo="$owner/$prefix${middle_name}$suffix"
                repos+=(repo)
                label="d$depth${shape:0:1}$speed${filetype:0:1}${suffix: -2}"
                cell+="\[[$filetype][$label]\] "
                links+=("[$label]:https://github.com/$repo")
            done
            row+=" $cell |"
        done
        echo "$row" >> "$output_file"
    done
    echo "$caption"
    {
    echo ""
    for link in ${links[@]}; do
        echo "$link"
    done
    echo ""
    } | tee -a "$output_file"
done
