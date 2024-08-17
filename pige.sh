#!/bin/sh

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "This script records audio streams and manages old recordings."
   echo
   echo "Syntax: scriptTemplate [record | purge]"
   echo "Environment Variables:"
   echo "  STREAM_URL       URL of the audio stream (required for 'record')."
   echo "  DAYS_THRESHOLD   Number of days to keep recordings (required for 'purge')."
   echo "  ARCHIVE_PATH     Directory path where recordings are saved (required for both)."
   echo "Options:"
   echo "  help             Display this help message."
}

############################################################
# Default Values                                           #
############################################################

# Default values (can be overridden by environment variables)
DEFAULT_STREAM_URL=
DEFAULT_DAYS_THRESHOLD=31
DEFAULT_ARCHIVE_PATH="/tmp/pige"
DEFAULT_AUDIO_SEGMENT=3610

############################################################
# Environment Variables                                    #
############################################################

# Override default values with environment variables if they are set
STREAM_URL=${STREAM_URL:-$DEFAULT_STREAM_URL}
DAYS_THRESHOLD=${DAYS_THRESHOLD:-$DEFAULT_DAYS_THRESHOLD}
ARCHIVE_PATH=${ARCHIVE_PATH:-$DEFAULT_ARCHIVE_PATH}
AUDIO_SEGMENT=${AUDIO_SEGMENT:-$DEFAULT_AUDIO_SEGMENT}

############################################################
# Recorder Function                                        #
############################################################
Recorder()
{
    # Validation: Check if required variables are set
    if [ -z "$STREAM_URL" ]; then
        echo "Error: STREAM_URL is not set. Please set it as an environment variable."
        exit 1
    fi

    if [ -z "$ARCHIVE_PATH" ]; then
        echo "Error: ARCHIVE_PATH is not set. Please set it as an environment variable."
        exit 1
    fi

    # Create a directory for recording based on the current date and time
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

    # Create the destination directory if it doesn't exist
    mkdir -p "$ARCHIVE_PATH"

     # Record the stream
    if ! ffmpeg -i "$STREAM_URL" -t "$AUDIO_SEGMENT" -c copy "$ARCHIVE_PATH/$TIMESTAMP.mp3"; then
        echo "Error: Failed to record stream from $STREAM_URL."
        exit 1
    fi

    echo "Recording saved to $ARCHIVE_PATH/$TIMESTAMP.mp3"
}

############################################################
# Cleaner Function                                         #
############################################################
Cleaner() {
    # Validation: Check if required variables are set
    if [ -z "$ARCHIVE_PATH" ]; then
        echo "Error: ARCHIVE_PATH is not set. Please set it as an environment variable."
        exit 1
    fi

    if [ -z "$DAYS_THRESHOLD" ]; then
        echo "Error: DAYS_THRESHOLD is not set. Please set it as an environment variable."
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
}

############################################################
# Main Logic                                               #
############################################################

# Check for the required positional argument
if [ $# -eq 0 ]; then
    echo "Error: No action specified. Use 'record', 'purge', or 'help'."
    exit 1
fi

# Execute the corresponding function based on the argument
case $1 in
    record)
        Recorder
        ;;
    purge)
        Cleaner
        ;;
    help)
        Help
        ;;
    *)
        echo "Error: Invalid action. Use 'record', 'purge', or 'help'."
        exit 1
        ;;
esac

exit 0