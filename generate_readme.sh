#!/bin/bash

# Define input and output files
header_file="header.md"
matrix_file="github_matrix.txt"
footer_file="footer.md"
revisions_file="revisions.md"
readme_file="README.md"

# Get the current date and time
current_date=$(date "+%Y-%m-%d %H:%M:%S")

# Define the revision message
revision_message="$current_date: Added another dot to the matrix."

# Append the revision message to the revisions.md file
echo "$revision_message" >> "$revisions_file"

# Combine header, matrix, footer, and revisions into README.md
{
    cat "$header_file"
    cat "$matrix_file"
    cat "$footer_file"
    cat "$revisions_file"
} > "$readme_file"

echo "README.md generated successfully."
echo "Revision history updated: $revision_message"
