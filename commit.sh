#!/bin/bash

log_file="logs/commit.log"

# Get the list of modified or new files
files_to_commit=$(git ls-files --others --modified --exclude-standard)

# Log the current timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

if [ -n "$files_to_commit" ]; then
    echo "$timestamp: Files to commit: $files_to_commit" >> $log_file

    # Loop through each file and commit one at a time with a delay
    for file in $files_to_commit; do
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo "$timestamp: Adding and committing $file" >> $log_file

        # Stage the file
        git add "$file"

        # Commit the file with a message
        git commit -m "Automated commit by scheduler: $file"

        # Push to the repository
        git push origin main

        echo "$timestamp: Push successful for $file" >> $log_file

        # Delay for one minute between each push
        sleep 60
    done
else
    echo "$timestamp: No new files to commit" >> $log_file
fi

