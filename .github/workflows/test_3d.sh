#!/bin/bash

export DISPLAY=:99

url_3d=$1
coursename=$2
username=$3
password=$4

echo "url_3d: $url_3d"
echo "coursename: $coursename"
echo "username: $username"
echo "password: $password"

python3 $GITHUB_WORKSPACE/.github/workflows/test_3d.py "$url_3d" "$username" "$password" "$COURSE_ID"
