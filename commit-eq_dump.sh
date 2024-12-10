#!/bin/bash

filetype="equilibration"
dirname="equilibration dump"  # Default directory name
fileprefix="dump.cutsic_eq"  # File name prefix
filesuffix="lammpstrj.gz*"  # File name suffix

git add "${dirname}/${fileprefix}.0.${filesuffix}"
git add "${dirname}/${fileprefix}.[0-9]00.${filesuffix}"
git add "${dirname}/${fileprefix}.[0-9][0-9]00.${filesuffix}"
git commit -m "Add ${filetype} files (index < 9000)"

for i in {1..1}
do
  git add "${dirname}/${fileprefix}.${i}[0-9][0-9]00.${filesuffix}"
  git commit -m "Add ${filetype} files (index < ${i}9900)"
done

git add "${dirname}/${fileprefix}.2[0-7][0-9]00.${filesuffix}"
git commit -m "Add last ${filetype} file (<= 27000)"
