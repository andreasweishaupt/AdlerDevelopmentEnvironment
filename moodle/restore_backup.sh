#!/bin/bash
MOODLE_PARENT_DIRECTORY=/home/markus

cd "$(dirname "$0")"

echo "-----------------------------------------"
echo "!!!This script is not properly tested.!!!"
echo "!!!Use at your own risk.!!!"
echo "-----------------------------------------"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path_to_backup_archive>"
  exit 1
fi

# Load environment variables
set -o allexport
source .env
set +o allexport

echo "First, backup everything."
# Execute the backup_data.sh script
backup_data.sh

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

# Empty the existing Moodle database
echo "Emptying existing Moodle database..."
tables_to_drop=$(mysql -h localhost -P 3312 -u root -p"$_DB_ROOT_PW" $_DB_MOODLE_NAME -sN -e 'SHOW TABLES')
if [ -z "$tables_to_drop" ]; then
  echo "No tables found in database. Skipping the drop tables step."
else
  tables_to_drop=\`$(echo $tables_to_drop | sed 's/ /`,`/g')\`
  sql_statement="SET FOREIGN_KEY_CHECKS = 0; DROP TABLE IF EXISTS $tables_to_drop; SET FOREIGN_KEY_CHECKS = 1;"
#  echo "$sql_statement"

  mysql -h localhost -P 3312 -u root -p"$_DB_ROOT_PW" $_DB_MOODLE_NAME -e "$sql_statement"
  if [ $? -ne 0 ]; then
    echo "Failed to empty the existing Moodle database. Exiting."
    exit 1
  fi
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
