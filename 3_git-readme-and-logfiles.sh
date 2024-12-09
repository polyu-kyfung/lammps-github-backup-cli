#!/bin/bash

readonly frontImageFile="front_view.png"
readonly isometricImageFile="isometric_view.png"
readonly xProjectionImageFile="left_view.png"
readonly logFolder="log_files/"
readonly inputFolder="Input file"
readonly outputFolder="Output files"

if [ -f "README.md" ]; then
    if [ -f "$frontImageFile" ]; then git add $frontImageFile; fi
    git add README.md
    git commit -m "Add README file"
fi

if [ -d "$inputFolder" ]; then
    git add "$inputFolder"
    git commit -m "Add input file"
fi

hasLogfiles=false
if ls log.* 1> /dev/null 2>&1; then git add log.* ; hasLogfiles=true ; fi
if ls -- *.log 1> /dev/null 2>&1; then git add -- *.log ; hasLogfiles=true ; fi
if ls $logFolder 1> /dev/null 2>&1; then git add $logFolder ; hasLogfiles=true ; fi
if $hasLogfiles ; then
    git commit -m "Add log files"
fi

if [ -d "$outputFolder" ]; then
    git add "$outputFolder"
    git commit -m "Add output (log) files"
fi

if [ -f "$isometricImageFile" ]; then
    git add $isometricImageFile
    git commit -m "Add isometric view image"
fi

if [ -f "$xProjectionImageFile" ]; then
    git add $xProjectionImageFile
    git commit -m "Add x+ projection image"
fi
