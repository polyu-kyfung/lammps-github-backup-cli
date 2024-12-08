#!/bin/bash

# Prompt user to input the file type
# Determine the glob patterns used to filter target files
while true; do
  echo "Enter file type [dump/force/rerun]:"
  read -r filetype

  case $filetype in
      dump)
          dirname="dumpfiles"  # Default directory name
          aliasdir="dump_files"  # Alias directory name
          fileprefix="dump.cutsic"  # File name prefix
          filesuffix="lammpstrj.gz*"  # File name suffix
          break;;
      force)
          dirname="force_files"
          aliasdir="dump*force"  # Support using the * wildcard
          fileprefix="dump.force.cut_sic"
          filesuffix="gz*"  # Support using the * wildcard
          break;;
      rerun)
          dirname="rerun_files"
          aliasdir="dump_rerun"
          fileprefix="dump.rerun.cut_sic"
          filesuffix="gz*"  # Support using the * wildcard
          break;;
      *)
          echo "Invalid input"
          ;;
  esac
done

# Prompt user to input the cutting speed
while true; do
    echo "Enter the cutting speed [1-3]:"
    read -r speed
    if [[ "$speed" =~ ^[1-3]$ ]]; then
        break
    else
        echo "Invalid input"
    fi
done

# Rename alias directory to the default name
if [[ ! -d "$dirname" ]] && ls -d "$aliasdir" 1> /dev/null 2>&1; then
  mv "$aliasdir/" "$dirname/"
fi

# Create commits according to the user inputs
# Determine the number of iterations required to commit all files based on cutting speed
if [[ -n "$dirname" && -n "$fileprefix" && -n "$filesuffix" ]]; then
    
    echo "git add ${dirname}/*"
    git add "${dirname}/${fileprefix}.0.${filesuffix}"
    git add "${dirname}/${fileprefix}.[0-9]00.${filesuffix}"
    git add "${dirname}/${fileprefix}.[0-9][0-9]00.${filesuffix}"
    git commit -m "Add ${filetype} files (index < 9000)"

    if [ "$speed" -eq 1 ]
    then
        
      for i in {1..39}
      do
        git add "${dirname}/${fileprefix}.${i}[0-9][0-9]00.${filesuffix}"
        git commit -m "Add ${filetype} files (index < ${i}9900)"
      done
      
      git add "${dirname}/${fileprefix}.40[0-9][0-9]00.${filesuffix}"
      git commit -m "Add last ${filetype} file (400000)"

    elif [ "$speed" -eq 2 ]
    then

      for i in {1..19}
      do
        git add "${dirname}/${fileprefix}.${i}[0-9][0-9]00.${filesuffix}"
        git commit -m "Add ${filetype} files (index < ${i}9900)"
      done
      
      git add "${dirname}/${fileprefix}.20[0-9][0-9]00.${filesuffix}"
      git commit -m "Add last ${filetype} file (200000)"
      
    elif [ "$speed" -eq 3 ]
    then

      for i in {1..12}
      do
        git add "${dirname}/${fileprefix}.${i}[0-9][0-9]00.${filesuffix}"
        git commit -m "Add ${filetype} files (index < ${i}9900)"
      done
      
      git add "${dirname}/${fileprefix}.13[0-2][0-9]00.${filesuffix}"
      git commit -m "Add ${filetype} files (index < 132900)"

      git add "${dirname}/${fileprefix}.13[0-9][0-9]00.${filesuffix}"
      git commit -m "Add last ${filetype} file (133000)"
      
    else
        echo "Invalid input. Please enter a number from 1 to 3."
    fi

fi
