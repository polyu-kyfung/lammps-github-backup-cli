#!/bin/bash

readonly frontImageFile="front_view.png"
readonly isometricImageFile="isometric_view.png"
readonly xProjectionImageFile="left_view.png"
readonly logFolder="log_files/"

if [ -f "README.md" ]; then
    if [ -f "$frontImageFile" ]; then git add $frontImageFile; fi
    git add README.md
    git commit -m "Add README file"
fi

if ls log.* 1> /dev/null 2>&1; then git add log.* ; fi
if ls -- *.log 1> /dev/null 2>&1; then git add -- *.log ; fi
if ls $logFolder 1> /dev/null 2>&1; then git add $logFolder ; fi
git commit -m "Add log files"

if [ -f "$isometricImageFile" ]; then
    git add $isometricImageFile
    git commit -m "Add isometric view image"
fi

if [ -f "$xProjectionImageFile" ]; then
    git add $xProjectionImageFile
    git commit -m "Add x+ projection image"
fi
