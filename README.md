
# pigeSH

This repository contains two Bash scripts for recording audio streams and managing the retention of recorded files. The scripts are:

1. **`recorder.sh`**: Records audio from a specified stream.
2. **`cleaner.sh`**: Cleans up old recordings based on a retention policy.

## Overview

- **`recorder.sh`**: Captures audio from a streaming URL and saves it as an MP3 file in a directory structure based on the current date and time.
- **`cleaner.sh`**: Deletes old recordings that exceed the specified retention period.

## Prerequisites

- **Bash**: These scripts are written in Bash and require a Unix-like environment.
- **ffmpeg**: Ensure `ffmpeg` is installed for recording audio streams. You can install it via package managers like `apt` (Debian/Ubuntu) or `brew` (macOS).

## Installation

Follow these steps to clone the repository and set up the scripts:

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/jee-r/pigeSH.git
   ```

2. **Navigate to the Repository Directory**:

   ```bash
   cd pigeSH
   ```

3. **Copy the Sample Configuration File**:

   - Copy the `config-sample` file to `config`:

     ```bash
     cp config-sample config
     ```

   - Edit the `config` file to specify your configuration settings:

     ```bash
     nano config
     ```

     Update the following configuration values in `config`:

     ```bash
     # Enter the stream URL to record:
     STREAM_URL=https://my-radio.com:8080/myradio_a

     # Set the retention period for recordings in days (0 for indefinite)
     DAYS_THRESHOLD=31

     # Set the directory path where the archives are located
     ARCHIVE_PATH="/data/pige"
     ```

## Scripts

### `recorder.sh`

This script records audio from the specified stream and saves it in a directory based on the current date and time.

### `cleaner.sh`

This script removes recordings that are older than the specified retention period.

## Scheduling with Cron

### Using `cron` for Scheduling

`cron` is a time-based job scheduler in Unix-like operating systems. You can schedule scripts to run at specific intervals.

1. **Edit the Crontab**: Open the crontab configuration file for editing.

   ```bash
   crontab -e
   ```

2. **Add the Following Entries**:

   To run `recorder.sh` every hour:

   ```cron
   0 * * * * /path/to/pigeSH/recorder.sh
   ```

   To run `cleaner.sh` once daily at midnight:

   ```cron
   0 0 * * * /path/to/pigeSH/cleaner.sh
   ```

   Adjust the paths to the scripts as needed.

3. **Save and Exit**: Save the crontab file and exit the editor. The cron daemon will automatically pick up the changes.

## Scheduling with systemd-timer

### Using `systemd-timer` for Scheduling

`systemd-timer` is a more modern scheduling mechanism used in systems with `systemd`.

1. **Create Service Files**:

   - **`recorder.service`**:
     ```ini
     [Unit]
     Description=Record audio from stream

     [Service]
     ExecStart=/path/to/pigeSH/recorder.sh
     ```

   - **`cleaner.service`**:
     ```ini
     [Unit]
     Description=Clean up old recordings

     [Service]
     ExecStart=/path/to/pigeSH/cleaner.sh
     ```

   Save these files in `/etc/systemd/system/`.

2. **Create Timer Files**:

   - **`recorder.timer`**:
     ```ini
     [Unit]
     Description=Run recorder script every hour

     [Timer]
     OnCalendar=hourly
     Persistent=true

     [Install]
     WantedBy=timers.target
     ```

   - **`cleaner.timer`**:
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
   sudo systemctl enable recorder.timer
   sudo systemctl start recorder.timer

   sudo systemctl enable cleaner.timer
   sudo systemctl start cleaner.timer
   ```

4. **Check Timer Status**:

   You can check the status of the timers to ensure they are active:

   ```bash
   systemctl list-timers
   ```

## How It Works

- **`recorder.sh`**:
  - Reads configuration values from `config`.
  - Creates a directory structure based on the current date (`YEAR/MONTH/DAY`).
  - Records audio from the provided stream URL for the specified duration and saves it as an MP3 file in the created directory.

- **`cleaner.sh`**:
  - Reads configuration values from `config`.
  - Calculates the cutoff date based on the retention period.
  - Deletes directories containing recordings older than the retention period.

## Troubleshooting

- **Configuration File Not Found**: Ensure `config` is located in the same directory as the script and is properly named.
- **ffmpeg Not Found**: Install `ffmpeg` if it’s missing. Use your package manager to install it.
- **Cron/Timer Issues**: Check logs for errors using `journalctl` for `systemd-timer` or the cron log files.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

For any questions or issues, please open an issue on the repository.
