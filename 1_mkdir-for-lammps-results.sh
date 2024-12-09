#!/bin/bash

declare -r prefix="lammps-nanocutting-SiC_" # dirname prefix
declare -r suffix="--potential-EA--eq2" # dirname suffix, e.g. "--potential-EA", "--Tersoff-1994"
# Prompt user to confirm the project prefix and suffix
while true; do
    echo "- Prefix: $prefix"
    echo "- Suffix: $suffix"
    read -r -p "Do you confirm to use these affixes for the new folder name? (y/n) " yN

    case $yN in
        y) break;;
        n) exit;;
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
# If "no" is received, format the middle part of dirname with the text "defect-free"
# Otherwise, calculate half width based on the user's input 
while true; do

    read -r -p "Enter the groove depth [no, 3, 6 or 9]: " depth

    if [[ "$depth" =~ ^[nN][oO]?$ ]]; then
        middle="results_defect-free-tool_speed-${speed}.0"
        break  
    elif [[ "$depth" =~ ^[3|6|9]$ ]]; then
        halfwidth=$(printf %.1f "$((depth*5))e-1" | printf %g "$(</dev/stdin)")  # return "1.5", "3" or "4.5"
        break
    else
        echo "Invalid input"
    fi

done

# If the user input a positive number above, ask to input the groove shape
# Then, determine the groove width based on the shape
# format the middle part of dirname with the text pattern "${depth}-by-${width}-v-groove-defect"
if  [[ "$depth" =~ ^[1-9]$ ]]; then
    
    while true; do
        read -r -p "Choose the groove shape [isosceles acute (a) / isosceles right (r)]: " shape
        case $shape in
            [aA]* ) width=$halfwidth; break;;
            [rR]* ) width=$depth; break;;
            * ) echo "Please type either a or r.";;
        esac
    done

    middle="results_${depth}x${width}-v-groove-defect-tool_speed-${speed}.0"

fi

# Create a new directory with the formatted name
dirname="${prefix}${middle}${suffix}"
mkdir "$dirname"

# Display the new directory name
echo "Created $dirname"
