#!/bin/bash

# Determine the directory where the script is located
SCRIPT_DIR=$(dirname "$0")

# Source the configuration file located in the same directory as the script
CONFIG_FILE="$SCRIPT_DIR/config"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi


# Get the current date in seconds since 1970-01-01 00:00:00 UTC
current_date=$(date +%s)

# Initialize counters
N_FILES=0
N_FILES_REMOVED=0
N_FILES_KEPT=0

# Iterate over files with the given pattern in the specified directory
for file in "$ARCHIVE_PATH"/*.mp3; do
  # Increase the total file counter
  N_FILES=$((N_FILES + 1))

  # Extract the timestamp from the filename
  file_timestamp=$(basename "$file" | grep -oP '\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}')

  # Convert the extracted timestamp to the format YYYY-MM-DD HH:MM:SS
  formatted_timestamp=$(echo "$file_timestamp" | sed 's/_/ /' | sed 's/-/:/3g')

  # Convert the timestamp to seconds since 1970-01-01 00:00:00 UTC
  file_date=$(date --date="$formatted_timestamp" +%s 2>/dev/null)

  # Check if the conversion was successful
  if [ $? -eq 0 ]; then
    # Calculate the difference in days between the current date and the file's date
    days_diff=$(( (current_date - file_date) / 86400 ))

    # Check if the difference is greater than the threshold days
    if [ $days_diff -gt $DAYS_THRESHOLD ]; then
      # File is older than the threshold, so remove it
      N_FILES_REMOVED=$((N_FILES_REMOVED + 1))
      rm "$file"
    else
      # File is within the threshold, so keep it
      N_FILES_KEPT=$((N_FILES_KEPT + 1))
    fi
  else
    # Handle invalid date format
    echo "Invalid date format for file: $file"
  fi
done

# Print summary
echo "-----------------------------"
echo "Total files processed: $N_FILES"
echo "Files removed: $N_FILES_REMOVED"
echo "Files kept: $N_FILES_KEPT"
echo "-----------------------------"