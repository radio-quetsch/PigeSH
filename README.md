# pigeSH

This repository contains a Bash script for recording audio streams and managing the retention of recorded files.

## Overview

The script provides two main functionalities:

1. **`pige.sh record`**: Records audio from a specified stream URL.
2. **`pige.sh purge`**: Cleans up old recordings based on a retention policy.

## Prerequisites

- **Bash**: These scripts are written in Bash and require a Unix-like environment.
- **ffmpeg**: Ensure `ffmpeg` is installed for recording audio streams. You can install it via package managers like `apt` (Debian/Ubuntu) or `brew` (macOS).

## Installation

Follow these steps to clone the repository and set up the script:

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/jee-r/pigeSH.git
   ```

2. **Navigate to the Repository Directory**:

   ```bash
   cd pigeSH
   ```

## Configuration

### Environment Variables

The script uses environment variables for configuration. Set these variables before running the script:

- **`STREAM_URL`**: The URL of the audio stream (required for the `record` mode).
- **`DAYS_THRESHOLD`**: The number of days to keep recordings (required for the `purge` mode). Default: `31`.
- **`ARCHIVE_PATH`**: The directory path where recordings are saved. Default: `/tmp/pige`.
- **`AUDIO_SEGMENT`**: Duration of the audio recording in seconds. Default: `3610`.

### Example

Set the environment variables inline before calling the script:

```bash
# For recording
STREAM_URL=https://my-radio.com:8080/myradio_a ARCHIVE_PATH="/path/to/archive" /path/to/pigeSH/pige.sh record

# For purging
ARCHIVE_PATH="/path/to/archive" DAYS_THRESHOLD=31 /path/to/pigeSH/pige.sh purge
```

Alternatively, set environment variables in the `cron` or `systemd` configurations (see [Scheduling](#scheduling-with-cron) for details).

## Scripts

### `pige.sh`

This script handles both recording and purging based on the action provided.

#### Usage

```bash
pige.sh [record | purge]
```

- **`record`**: Records audio from the specified stream URL.
- **`purge`**: Deletes recordings older than the specified retention period.

### Environment Variables Required

- **For `record` mode**:
  - `STREAM_URL` (Required)
  - `ARCHIVE_PATH` (Required)

- **For `purge` mode**:
  - `ARCHIVE_PATH` (Required)
  - `DAYS_THRESHOLD` (Required)
  
### Docker

```sh
docker run -d \
  --name pige \
  --network host \
  --restart always \
  --user 1000:1000 \
  -v $(pwd)/data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  -e STREAM_URL=https://my-radio-stream.com\
  -e DAYS_THRESHOLD=61 \
  -e ARCHIVE_PATH=/data \
  -e AUDIO_SEGMENT=3610 \
  -e TZ=Europe/Paris \
  ghcr.io/radio-quetsch/pigesh:latest

```

#### Docker Compose 
```yml
services:
  
  pige:
    image: ghcr.io/radio-quetsch/pigesh:latest
    build:
      context: .
      dockerfile: docker/Dockerfile
      network: host
    restart: always
    user: 1000:1000
    volumes:
      - ./data:/data
      - /etc/localtime:/etc/localtime:ro
      # Uncomment the line below to custommize your crontab
      #- ./crontab:/app/crontab
    environment:
      - STREAM_URL=https://my-radio-stream.com
      - DAYS_THRESHOLD=61
      - ARCHIVE_PATH=/data
      - AUDIO_SEGMENT=3610
      - TZ=Europe/Paris
```

## Scheduling

### Using `cron` for Scheduling

`cron` is a time-based job scheduler in Unix-like operating systems.

1. **Edit the Crontab**:

   ```bash
   crontab -e
   ```

2. **Add the Following Entries**:

   To run the `record` script every hour:

   ```cron
   0 * * * * STREAM_URL=https://my-radio.com:8080/myradio_a ARCHIVE_PATH="/path/to/archive" /full-path/to/pige.sh record
   ```

   To run the `purge` script once daily at midnight:

   ```cron
   0 0 * * * ARCHIVE_PATH="/path/to/archive" DAYS_THRESHOLD=31 /full-path/to/pige.sh purge
   ```

3. **Save and Exit**: Save the crontab file and exit the editor.

### Using `systemd-timer` for Scheduling

`systemd-timer` is a modern scheduling mechanism used in systems with `systemd`.

1. **Create Service Files**:

   - **`pige-record.service`**:
     ```ini
     [Unit]
     Description=Record audio from stream

     [Service]
     Environment="STREAM_URL=https://my-radio.com:8080/myradio_a"
     Environment="ARCHIVE_PATH=/path/to/archive"
     ExecStart=/full-path/to/pige.sh record
     ```

   - **`pige-cleaner.service`**:
     ```ini
     [Unit]
     Description=Clean up old recordings

     [Service]
     Environment="ARCHIVE_PATH=/path/to/archive"
     Environment="DAYS_THRESHOLD=31"
     ExecStart=/full-path/to/pige.sh purge
     ```

   Save these files in `/etc/systemd/system/`.

2. **Create Timer Files**:

   - **`pige-record.timer`**:
     ```ini
     [Unit]
     Description=Run recorder script every hour

     [Timer]
     OnCalendar=hourly
     Persistent=true

     [Install]
     WantedBy=timers.target
     ```

   - **`pige-cleaner.timer`**:
     ```ini
     [Unit]
     Description=Run cleaner script daily

     [Timer]
     OnCalendar=daily
     Persistent=true

     [Install]
     WantedBy=timers.target
     ```

   Save these files in `/etc/systemd/system/`.

3. **Enable and Start the Timers**:

   ```bash
   sudo systemctl enable pige-record.timer
   sudo systemctl start pige-record.timer

   sudo systemctl enable pige-cleaner.timer
   sudo systemctl start pige-cleaner.timer
   ```

4. **Check Timer Status**:

   ```bash
   systemctl list-timers
   ```

## How It Works

- **`pige.sh record`**:
  - Reads configuration values from environment variables.
  - Creates a directory structure based on the current date.
  - Records audio from the provided stream URL for the specified duration and saves it as an MP3 file.

- **`pige.sh purge`**:
  - Reads configuration values from environment variables.
  - Calculates the cutoff date based on the retention period.
  - Deletes recordings older than the retention period.

## Troubleshooting

- **Configuration Issues**: Ensure the environment variables are set correctly before running the script.
- **ffmpeg Not Found**: Install `ffmpeg` if it’s missing. Use your package manager to install it.
- **Cron/Timer Issues**: Check logs for errors using `journalctl` for `systemd-timer` or the cron log files.

## License

This project is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or issues, please open an issue on the repository.