#!/bin/bash

# Directory where the files will be created
DIRECTORY="/tmp/pige"

# Ensure the directory exists
mkdir -p "$DIRECTORY"

# Calculate the start and end dates
START_DATE=$(date -d "today" +%Y-%m-%d)
END_DATE=$(date -d "40 days ago" +%Y-%m-%d)

# Loop through each day from today to 40 days ago
for DAY in $(seq -f "%02g" 1 40); do
    DATE=$(date -d "$DAY days ago" +%Y-%m-%d)
    # Loop through each hour of the day
    for HOUR in $(seq -f "%02g" 0 23); do
        # Generate the filename
        FILENAME="${DATE}_${HOUR}-00-00.mp3"
        # Construct the full path of the file
        FULL_PATH="$DIRECTORY/$FILENAME"
        # Create an empty file at the specified path
        touch "$FULL_PATH"
        echo "Created file: $FULL_PATH"
    done
done