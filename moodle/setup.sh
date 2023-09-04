#!/bin/bash
WSL_USER=markus
MOODLE_PARENT_DIRECTORY=/home/$WSL_USER

# install dependencies
sudo apt install -y apache2 php8.1 php8.1-curl php8.1-zip composer php8.1-gd php8.1-dom php8.1-xml php8.1-mysqli php8.1-soap php8.1-xmlrpc php8.1-intl php8.1-xdebug

# create moodle folders
mkdir $MOODLE_PARENT_DIRECTORY/moodle $MOODLE_PARENT_DIRECTORY/moodledata $MOODLE_PARENT_DIRECTORY/moodledata_phpu
# download moodle to $MOODLE_PARENT_DIRECTORY/moodle

# setup database
sudo docker run -d --name moodle_mariadb --env MARIADB_USER=moodle --env MARIADB_PASSWORD=moodle --env MARIADB_DATABASE=moodle --env MARIADB_ROOT_PASSWORD=password --restart=always -p 3312:3306 mariadb
while ! mysqladmin ping -hlocalhost -P3312 --silent 2>/dev/null; do echo "db is starting" && sleep 1; done
echo "db is up"

# configure apache
sudo sed -i 's#<Directory /var/www/>#<Directory $MOODLE_PARENT_DIRECTORY/>#g'  /etc/apache2/apache2.conf
sudo sed -i 's#DocumentRoot /var/www/html#DocumentRoot $MOODLE_PARENT_DIRECTORY/moodle#g' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i 's#export APACHE_RUN_USER=www-data#export APACHE_RUN_USER=$WSL_USER#g' /etc/apache2/envvars
sudo sed -i 's#export APACHE_RUN_GROUP=www-data#export APACHE_RUN_GROUP=$WSL_USER#g' /etc/apache2/envvars

# configure php
echo "max_input_vars = 5000" | sudo tee /etc/php/8.1/cli/conf.d/moodle.ini
sudo ln -s  /etc/php/8.1/cli/conf.d/moodle.ini /etc/php/8.1/apache2/conf.d/moodle.ini

echo "
[XDebug]
# https://xdebug.org/docs/all_settings
zend_extension = xdebug

xdebug.mode=debug
;xdebug.mode=develop
xdebug.client_port=9000

; host ip adress of wsl network adapter
xdebug.client_host=172.18.48.1

; idekey value is specific to PhpStorm
xdebug.idekey=phpstorm

xdebug.start_with_request=true
" | sudo tee /etc/php/8.1/apache2/conf.d/20-xdebug.ini
sudo rm /etc/php/8.1/cli/conf.d/20-xdebug.ini
sudo ln -s  /etc/php/8.1/apache2/conf.d/20-xdebug.ini /etc/php/8.1/cli/conf.d/20-xdebug.ini

# restart apache to apply updated config
sudo systemctl restart apache2

# install moodle
php $MOODLE_PARENT_DIRECTORY/moodle/admin/cli/install.php --lang=DE --wwwroot=http://localhost --dataroot=$MOODLE_PARENT_DIRECTORY/moodledata --dbtype=mariadb --dbhost=127.0.0.1 --dbport=3312 --dbuser=moodle --dbpass=moodle --dbname=moodle --fullname=fullname --shortname=shortname --adminpass=pass --adminemail=admin@blub.blub --non-interactive --agree-license

# setup for plugins
git clone https://github.com/Glutamat42/moodle-docker /tmp/moodle-docker
cp -r /tmp/moodle-docker/opt/adler/moodle/adler_setup $MOODLE_PARENT_DIRECTORY/moodle/
rm -rf /tmp/moodle-docker
php $MOODLE_PARENT_DIRECTORY/moodle/adler_setup/setup.php --first_run=true --user_name=student,manager --user_password='Student1234!1234,Manager1234!1234' --user_role=manager,false --develop_dont_install_plugins=true

# moodle config.php
echo "
//=========================================================================
// 7. SETTINGS FOR DEVELOPMENT SERVERS - not intended for production use!!!
//=========================================================================

// configure phpunit
$CFG->phpunit_prefix = 'phpu_';
$CFG->phpunit_dataroot = '$MOODLE_PARENT_DIRECTORY/moodledata_phpu';
// $CFG->phpunit_profilingenabled = true; // optional to profile PHPUnit runs.

// Force a debugging mode regardless the settings in the site administration
@error_reporting(E_ALL | E_STRICT); // NOT FOR PRODUCTION SERVERS!
@ini_set('display_errors', '1');    // NOT FOR PRODUCTION SERVERS!
$CFG->debug = (E_ALL | E_STRICT);   // === DEBUG_DEVELOPER - NOT FOR PRODUCTION SERVERS!
// $CFG->debugdisplay = 1;             // NOT FOR PRODUCTION SERVERS!

// Force result of checks used to determine whether a site is considered "public" or not (such as for site registration).
// $CFG->site_is_public = false;

# disable some caching (recommended by moodle introduction course)
$CFG->langstringcache = 0;
$CFG->cachetemplates = 0;
$CFG->cachejs = 0;
" >> $MOODLE_PARENT_DIRECTORY/moodle/config.php

echo moodle login data: username: admin password: pass
echo db root pass: password
