#/bin/bash

MOODLE_RELEASE=MOODLE_404_STABLE

MOODLE_PARENT_DIRECTORY=$(getent passwd 1000 | cut -d: -f6)  # /home/<user>

# Check whether moodle is already downloaded
if [ -d "$MOODLE_PARENT_DIRECTORY/moodle" ]; then
  echo "Moodle is already downloaded. Please remove the moodle directory first."
  exit 1
fi

sudo apt update && sudo apt -y install git jq

git clone --depth=1 --branch=$MOODLE_RELEASE https://github.com/moodle/moodle.git $MOODLE_PARENT_DIRECTORY/moodle
cd $MOODLE_PARENT_DIRECTORY/moodle

json_content=$(curl https://raw.githubusercontent.com/ProjektAdLer/moodle-docker/main/plugin-releases.json)
plugin_list=$(echo "$json_content" | jq -r ".common_versions[\"main\"]")

# Iterate over each plugin in the list
echo "$plugin_list" | jq -c '.[]' | while read -r plugin; do
  git_project=$(echo "$plugin" | jq -r '.git_project')
  version=$(echo "$plugin" | jq -r '.version')
  path=$(echo "$plugin" | jq -r '.path')

  # Clone the git project and checkout the specified version
  git clone --branch $version "https://github.com/$git_project.git" "$MOODLE_PARENT_DIRECTORY/moodle/$path"

  # run composer i for the plugin if a composer.json exists
  if [ -f "$MOODLE_PARENT_DIRECTORY/moodle/$path/composer.json" ]; then
    composer install --working-dir="$MOODLE_PARENT_DIRECTORY/moodle/$path"
  fi
done

