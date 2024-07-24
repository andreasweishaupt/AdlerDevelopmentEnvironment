#/bin/bash

MOODLE_RELEASE=MOODLE_404_STABLE

MOODLE_PARENT_DIRECTORY=$(getent passwd 1000 | cut -d: -f6)  # /home/<user>

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
done

