#!/bin/bash
MOODLE_PARENT_DIRECTORY=/home/markus

echo "-----------------------------------------"
echo "!!!This script is not properly tested.!!!"
echo "!!!Use at your own risk.!!!"
echo "-----------------------------------------"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path_to_backup_archive>"
  exit 1
fi

# Load environment variables
source "$(dirname "$0")/.env"

# Set variables
backup_archive="$1"

# Decide which decompression command to use based on the file extension
if [[ $backup_archive == *.tar.zst ]]; then
  decompression_command="zstd -d --stdout"
elif [[ $backup_archive == *.tar.gz ]]; then
  decompression_command="gzip -d -c"
else
  echo "Unsupported archive format. Please use .tar.zst or .tar.gz"
  exit 1
fi

# Temporary directory for restoration
restore_dir="/tmp/moodle_restore_$(date +'%Y-%m-%d_%H-%M-%S')"

# Create temporary directory
mkdir -p "$restore_dir"

# Decompress and extract archive
tar --use-compress-program="$decompression_command" -xf "$backup_archive" -C "$restore_dir"

# Extract the folder name that contains the backup
backup_folder_name=$(ls "$restore_dir")

# Full path to the backup data
full_restore_path="$restore_dir/$backup_folder_name"

# Restore files and database
cp -r "$full_restore_path/moodledata" $MOODLE_PARENT_DIRECTORY/moodledata
cp -r "$full_restore_path/moodledata_phpu" $MOODLE_PARENT_DIRECTORY/moodledata_phpu
cp "$full_restore_path/config.php" $MOODLE_PARENT_DIRECTORY/moodle/config.php
mysql -h localhost -P 3312 -u root -p"$_DB_ROOT_PW" $_DB_MOODLE_NAME < "$full_restore_path/moodle_database.sql"

# Clean up
rm -rf "$restore_dir"


# Print success message
echo "Data restored from $backup_archive"
