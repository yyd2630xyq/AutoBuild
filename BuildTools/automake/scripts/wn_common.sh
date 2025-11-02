#!/bin/sh


# Input logfile count and print the number of errors and warnings
#
# example output: 9      99
#                 errors warnings


# Assign the first command-line argument to 'log_file' variable
log_file=$1
# Check if the file exists
if [ ! -f "$log_file" ]; then
	# If file doesn't exist, print error message to stderr and exit with status 1
	echo "Error: log_file \"$log_file\" does not exist." >&2
	exit 1
fi

# Count the number of lines containing "error" (case-insensitive)
# '[not empty][any]: error[any]:'
errors=$(grep -ci '^[^[:space:]].*: error.*:' "$log_file")

# Count the number of lines containing "warning" (case-insensitive)
# '[not empty][any]: warning[any]:'
warnings=$(grep -ci '^[^[:space:]].*: warning.*:' "$log_file")

# Output the counts: warnings first, then errors
echo "$errors $warnings"
