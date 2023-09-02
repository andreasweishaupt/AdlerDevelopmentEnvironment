#!/bin/bash
MOODLE_PARENT_DIRECTORY=/home/markus

sudo rm -r $MOODLE_PARENT_DIRECTORY/moodledata $MOODLE_PARENT_DIRECTORY/moodledata_phpu
sudo rm $MOODLE_PARENT_DIRECTORY/moodle/config.php
sudo docker stop moodle_mariadb && docker rm moodle_mariadb
