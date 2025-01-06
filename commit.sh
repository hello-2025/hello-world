#!/bin/bash

log_file="logs/commit.log"

# Get the list of modified or new files
files_to_commit=$(git ls-files --others --modified --exclude-standard)

# Log the current timestamp
#timestamp=$(date "+%a %b %e %H:%M:%S %Z %Y")
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

if [ -n "$files_to_commit" ]; then
    echo "$timestamp: Files to commit: $files_to_commit" >> $log_file

    # Stage the files
    echo "$files_to_commit" | xargs git add

    # Commit the files with a message
    git commit -m "Automated commit by scheduler"

    # Push to the repository
    git push origin main

    echo "$timestamp: Commit and push successful" >> $log_file
else
    echo "$timestamp: No new files to commit" >> $log_file
fi

