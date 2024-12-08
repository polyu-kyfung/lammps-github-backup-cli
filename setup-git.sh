#!/bin/bash

# Initialize a new Git repository
git init

# Configure Git user information
git config --local user.email "${GITHUB_EMAIL}"
git config --local user.name "${GITHUB_USERNAME}"
