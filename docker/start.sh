#!/bin/bash

# Get the current time in seconds since epoch
current_seconds=$(date +%s)

# Get the current minute and second
current_minute=$(date +%M)
current_second=$(date +%S)

# Calculate the number of seconds that have passed since the start of the current hour
seconds_since_hour_start=$((current_minute * 60 + current_second))

# Calculate the total number of seconds in an hour
seconds_in_an_hour=$((60 * 60))

# Calculate the number of seconds until the next hour
seconds_until_next_hour=$((seconds_in_an_hour - seconds_since_hour_start))

# Output the result
echo "until the next hour we run the recorder manualy: $seconds_until_next_hour"

AUDIO_SEGMENT="$seconds_until_next_hour" /app/pige.sh record &

/usr/local/bin/supercronic -passthrough-logs -overlapping /app/crontab