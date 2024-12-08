#!/bin/bash

declare -r owner="${GITHUB_REPO_OWNER}" # repository owner
declare -r prefix="lammps-nanocutting-SiC---" # repo name prefix
declare -r suffix="--Tersoff-1994" # repo name suffix, e.g. "--potential-EA", "--Tersoff-1994"

speeds=$(seq 1 1 3)
depths=$(seq 3 3 9)
shapes=("a" "r")
filetypes=("dump" "force")

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

for speed in $speeds; do

    repos=()
    links=()
    echo "At a cutting speed of ${speed}00 m s^-1, the simulation results of the defective tools with the different v-groove sizes and shapes:"
    echo ""
    echo "| depth |             isosceles acute (a)            |            isosceles right (r)            |"
    echo "| :---: | :----------------------------------------: | :---------------------------------------: |"

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
                middle="${depth}-by-${width}-v-groove-defect-tool-at-speed-${speed}.0-${filetype}-results"
                repo="$owner/${prefix}${middle}${suffix}"
                repos+=(repo)
                # cell+="\[[$filetype](https://github.com/$repo)\] "
                label="d$depth${shape:0:1}$speed${filetype:0:1}${suffix: -2}"
                cell+="\[[$filetype][$label]\] "
                links+=("[$label]:https://github.com/$repo")
            done
            row+=" $cell |"
        done
        echo "$row"
    done
    echo ""
    for link in ${links[@]}; do
        echo "$link"
    done
    echo ""
done
