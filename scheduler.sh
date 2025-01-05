#!/bin/bash

# Function to calculate the first Sunday within the given year
function calculate_start_date() {
    local year=$1

    # Find January 1st of the given year
    local jan_1_date="$year-01-01"

    # Find the weekday of January 1st (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
    local jan_1_weekday=$(date -d "$jan_1_date" +%w)

    # Calculate the offset to the first Sunday (0 = Sunday, 7 - weekday otherwise)
    local offset=$(( (7 - jan_1_weekday) % 7 ))

    # Calculate the first Sunday of the year
    local first_sunday=$(date -d "$jan_1_date + $offset days" +%Y-%m-%d)
    echo "$first_sunday"
}

# Parse command-line arguments
test_mode=false
year=$(date +%Y) # Default to the current year

for arg in "$@"; do
    if [[ "$arg" == "test" ]]; then
        test_mode=true
    elif [[ "$arg" =~ ^[0-9]{4}$ ]]; then
        year=$arg
    fi
done

# Calculate the start date (first Sunday within the year)
start_date=$(calculate_start_date "$year")

# Read the message matrix from message.txt
messageMatrix=()
while IFS= read -r line; do
    messageMatrix+=("$line")
done < "./message.txt"

# Read the github_matrix.txt file into githubMatrix
githubMatrix=()
while IFS= read -r line; do
    githubMatrix+=("$line")
done < "./github_matrix.txt"

log_file="logs/scheduler.log"
# Get today's date
current_date=$(date +%Y-%m-%d)
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Adjust the year in current_date for testing mode
if [ "$test_mode" = true ]; then
    current_date=$(date -d "${year}-$(date +%m-%d)" +%Y-%m-%d)
fi

# Calculate the difference in days
days_since_start=$(( ( $(date -d "$current_date" +%s) - $(date -d "$start_date" +%s) ) / 86400 ))
if (( days_since_start < 0 || current_col >= ${#messageMatrix[0]} )); then
    echo "Error: Current date is outside the valid range of the messageMatrix."
    exit 1
fi

current_col=$(( days_since_start / 7 ))
current_row=$(( days_since_start % 7 ))

# Update today's position in githubMatrix only if messageMatrix has "@"
local_message_char="${messageMatrix[current_row]:$current_col:1}"
if [[ "$local_message_char" == "@" ]]; then
    githubMatrix[current_row]="${githubMatrix[current_row]:0:$current_col}@${githubMatrix[current_row]:$((current_col + 1))}"

    # Write the updated githubMatrix back to github_matrix.txt
    printf "%s\n" "${githubMatrix[@]}" > "github_matrix.txt"
    echo "$timestamp Row: $current_row, Column: $current_col updated with '@'" >> $log_file
else
    echo "$timestamp Row: $current_row, Column: $current_col does not require update" >> $log_file
fi

# Test mode: Print the modified messageMatrix with "-" and "+" substitutions
if [ "$test_mode" = true ]; then
    modifiedMatrix=("${messageMatrix[@]}") # Make a copy to modify for display

    # Update current position in modifiedMatrix
    local_char="${modifiedMatrix[current_row]:$current_col:1}"
    if [[ "$local_char" == "@" ]]; then
        modifiedMatrix[current_row]="${modifiedMatrix[current_row]:0:$current_col}+${modifiedMatrix[current_row]:$((current_col + 1))}"
    elif [[ "$local_char" == "." ]]; then
        modifiedMatrix[current_row]="${modifiedMatrix[current_row]:0:$current_col}-${modifiedMatrix[current_row]:$((current_col + 1))}"
    fi

    echo "Testing mode enabled for year: $year"
    echo "Adjusted Current Date: $current_date"

    echo "Test matrix:"
    for row in "${modifiedMatrix[@]}"; do
        echo "$row"
    done

    exit 0
fi

# Update today's position in githubMatrix only if messageMatrix has "@" at the same position
local_message_char="${messageMatrix[current_row]:$current_col:1}"
if [[ "$local_message_char" == "@" ]]; then
    githubMatrix[current_row]="${githubMatrix[current_row]:0:$current_col}@${githubMatrix[current_row]:$((current_col + 1))}"
fi

# Write the updated githubMatrix back to github_matrix.txt
printf "%s\n" "${githubMatrix[@]}" > "github_matrix.txt"

# Output start date, current_row, current_col, and check if today is a commit day
echo "Year: $year"
echo "Start Date (First Sunday of the Year): $start_date"
if [ "$local_message_char" == "@" ]; then
    echo "$timestamp Row: $current_row, Column: $current_col Commit: yes" >> $log_file
    bash ./generate_readme.sh
    sleep 2
    bash ./commit.sh
else
    echo "$timestamp Row: $current_row, Column: $current_col Commit: no" >> $log_file
fi
