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

# Load additional environment variables from .env
set -o allexport
source "$(dirname "$0")/.env"
set +o allexport

echo "Starting backup..."

backup_datetime=$(date +'%Y-%m-%d_%H-%M-%S')
backup_dir="/tmp/${backup_datetime}_moodle_backup"

# Check which compression format to use
if command -v zstd &> /dev/null; then
  compression_format="zstd"
  compression_extension="tar.zst"
  compression_command="zstd --long=31 -6 --threads=0"
else
  compression_format="gzip"
  compression_extension="tar.gz"

  if command -v pigz &> /dev/null; then
    echo "zstd not found, but pigz found, using it for compression"
    echo "Install zstd for better/faster compression"
    compression_command="pigz -8"
  else
    echo "zstd and pigz not found, using gzip for compression"
    echo "Install zstd (or pigz) for better/faster compression"
    compression_command="gzip"
  fi
fi

# Create backup directory
mkdir -p $backup_dir

# Backup files
cp -r $MOODLE_PARENT_DIRECTORY/moodledata $backup_dir/
cp $MOODLE_PARENT_DIRECTORY/moodle/config.php $backup_dir/config.php

# Backup database
mysqldump -h $DB_HOST -P 3312 -u root -p"$_DB_ROOT_PW" $_DB_MOODLE_NAME > $backup_dir/moodle_database.sql

# Create compressed archive
start=$(date +%s%N)
tar -cf - -C /tmp ${backup_datetime}_moodle_backup | $compression_command > $MOODLE_PARENT_DIRECTORY/${backup_datetime}_moodle_backup.$compression_extension
echo "Archive duration: $(( ($(date +%s%N) - start) / 1000000 )) ms"

# Remove temporary backup folder
rm -rf $backup_dir

# Print success message
echo "Backup successfully created at $MOODLE_PARENT_DIRECTORY/${backup_datetime}_moodle_backup.$compression_extension"
