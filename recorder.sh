#!/bin/sh

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

# Create a directory for recording based on the current date and time
DAY=$(date +%d)
MONTH=$(date +%m)
YEAR=$(date +%Y)
HOUR=$(date +%H)
MINUTE=$(date +%M)
SECOND=$(date +%S)

# Create the destination directory
mkdir -p "$ARCHIVE_PATH"

# Record the stream for one hour and ten seconds
ffmpeg -i "$STREAM_URL" -t 60 -c copy "$ARCHIVE_PATH/$YEAR-$MONTH-$DAY_$HOUR-$MINUTE-$SECOND.mp3"
