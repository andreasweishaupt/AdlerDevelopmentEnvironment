#!/bin/bash
MOODLE_PARENT_DIRECTORY=/home/markus

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
  compression_command="zstd -6 --threads=0"
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
cp -r $MOODLE_PARENT_DIRECTORY/moodledata_phpu $backup_dir/
cp $MOODLE_PARENT_DIRECTORY/moodle/config.php $backup_dir/config.php

# Backup database
mysqldump -h localhost -P 3312 -u root -p"$_DB_ROOT_PW" $_DB_MOODLE_NAME > $backup_dir/moodle_database.sql

# Create compressed archive
start=$(date +%s%N)
tar -cf - -C /tmp ${backup_datetime}_moodle_backup | $compression_command > $MOODLE_PARENT_DIRECTORY/${backup_datetime}_moodle_backup.$compression_extension
echo "Archive duration: $(( ($(date +%s%N) - start) / 1000000 )) ms"

# Remove temporary backup folder
rm -rf $backup_dir

# Print success message
echo "Backup successfully created at $MOODLE_PARENT_DIRECTORY/${backup_datetime}_moodle_backup.$compression_extension"
