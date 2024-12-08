#!/bin/bash

filetype="dump"
dirname="dumpfiles"  # Default directory name
fileprefix="dump.cutsic"  # File name prefix
filesuffix="lammpstrj.gz*"  # File name suffix

# git add ${dirname}/${fileprefix}.0.${filesuffix}
# git add ${dirname}/${fileprefix}.[0-9]00.${filesuffix}
# git add ${dirname}/${fileprefix}.[0-9][0-9]00.${filesuffix}
# git commit -m "Add ${filetype} files (index < 9000)"

for i in {300..399}
do
  git add "${dirname}/${fileprefix}.${i}[0-9][0-9]00.${filesuffix}"
  git commit -m "Add ${filetype} files (index < ${i}9900)"
done

git add "${dirname}/${fileprefix}.400[0-9][0-9]00.${filesuffix}"
git commit -m "Add last ${filetype} file (4000000)"
