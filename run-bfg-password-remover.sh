#!/bin/bash

java -jar ../bfg-1.14.0.jar --replace-text ../passwords.txt --no-blob-protection


git status

git log -p -S "mail" | tail
