#!/bin/bash
WSL_USER=$(awk -F: '($3>=1000)&&($3!=65534){print $1, $3}' /etc/passwd | sort -k2 -n | tail -1 | cut -d' ' -f1)
MOODLE_PARENT_DIRECTORY=$(getent passwd $WSL_USER | cut -d: -f6)

# Default value for DB_HOST
DB_HOST="127.0.0.1"

# Parse command line arguments for DB_HOST
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dbhost|-d) DB_HOST="$2"; shift ;;
        *) ;;
    esac
    shift
done

cd "$(dirname "$0")"

# Load additional environment variables from .env to be as close to non-moodle as possible
set -o allexport
source .env
set +o allexport

echo "First, backup everything."

# Execute the backup_data.sh script
./backup_data.sh --dbhost $DB_HOST

echo "Now reset everything."

# Remove files and directories
sudo rm -r $MOODLE_PARENT_DIRECTORY/moodledata $MOODLE_PARENT_DIRECTORY/moodledata_phpu $MOODLE_PARENT_DIRECTORY/moodledata_bht
sudo rm $MOODLE_PARENT_DIRECTORY/moodle/config.php

# Stop and remove Docker containers and volumes
sudo --preserve-env docker compose down -v
