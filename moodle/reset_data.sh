#!/bin/bash
MOODLE_PARENT_DIRECTORY=/home/markus

cd "$(dirname "$0")"

# Load additional environment variables from .env to be as close to non-moodle as possible
set -o allexport
source .env
set +o allexport

echo "First, backup everything."

# Execute the backup_data.sh script
./backup_data.sh

echo "Now reset everything."

# Remove files and directories
sudo rm -r $MOODLE_PARENT_DIRECTORY/moodledata $MOODLE_PARENT_DIRECTORY/moodledata_phpu
sudo rm $MOODLE_PARENT_DIRECTORY/moodle/config.php

# Stop and remove Docker containers and volumes
sudo docker compose down -v
