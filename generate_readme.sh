#!/bin/bash

# Define input and output files
header_file="header.md"
matrix_file="github_matrix.txt"
date_file="current_date.txt"
footer_file="footer.md"
revisions_file="revisions.md"
readme_file="README.md"

# Get the timestamp date and time
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
current_date=$(date "+%a %b %d %Y")

date_message="Last pixel added $current_date."
# Create the date message file
echo "\`\`\`" > "$date_file"
echo "$date_message" >> "$date_file"

# Define the revision message
revision_message="- $timestamp: Added another dot to the matrix"

# Append the revision message to the revisions.md file
echo "$revision_message" >> "$revisions_file"

# Combine header, matrix, footer, and revisions into README.md
{
    cat "$header_file"
    cat "$matrix_file"
    cat "$date_file"
    cat "$footer_file"
    cat "$revisions_file"
} > "$readme_file"

echo "README.md generated successfully."
echo "Revision history updated: $revision_message"

