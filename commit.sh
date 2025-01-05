#!/bin/bash

# Define the log file
log_file="logs/commit.log"

# Check for files to commit
files_to_commit=$(git status --porcelain | grep '^??' | awk '{print $2}')

if [ -z "$files_to_commit" ]; then
    echo "$(date): No new files to commit." >> "$log_file"
    exit 0
fi

# Commit each file separately
for file in $files_to_commit; do
    git add "$file"
    if git commit -m "Matrix commit for $(date +%Y-%m-%d) - $file" >> "$log_file" 2>&1; then
        if git push origin main >> "$log_file" 2>&1; then
            echo "$(date): Successfully committed and pushed $file." >> "$log_file"
        else
            echo "$(date): Failed to push $file." >> "$log_file"
        fi
    else
        echo "$(date): Failed to commit $file." >> "$log_file"
    fi
done

echo "$(date): All pending files processed." >> "$log_file"
