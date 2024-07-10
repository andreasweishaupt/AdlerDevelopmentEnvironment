#!/bin/bash
WSL_USER=markus
MOODLE_PARENT_DIRECTORY=/home/$WSL_USER

cd "$(dirname "$0")"

# load additional environment variables from .env to be as close to non-moodle as possible
set -o allexport
source .env
set +o allexport


# install dependencies
sudo apt install -y apache2 php8.1 php8.1-curl php8.1-zip composer php8.1-gd php8.1-dom php8.1-xml php8.1-mysqli php8.1-soap php8.1-xmlrpc php8.1-intl php8.1-xdebug mariadb-client-10.6

# create moodle folders
mkdir $MOODLE_PARENT_DIRECTORY/moodle $MOODLE_PARENT_DIRECTORY/moodledata $MOODLE_PARENT_DIRECTORY/moodledata_phpu $MOODLE_PARENT_DIRECTORY/moodledata_bht
# download moodle to $MOODLE_PARENT_DIRECTORY/moodle

# setup database
sudo docker compose up -d
while ! mysqladmin ping -h 127.0.0.1 -P3312 --silent 2>/dev/null; do echo "db is starting" && sleep 1; done
echo "db is up"

# configure apache
sudo sed -i "s#<Directory /var/www/>#<Directory $MOODLE_PARENT_DIRECTORY/>#g"  /etc/apache2/apache2.conf
sudo sed -i "s#DocumentRoot /var/www/html#DocumentRoot $MOODLE_PARENT_DIRECTORY/moodle#g" /etc/apache2/sites-enabled/000-default.conf
sudo sed -i "s#export APACHE_RUN_USER=www-data#export APACHE_RUN_USER=$WSL_USER#g" /etc/apache2/envvars
sudo sed -i "s#export APACHE_RUN_GROUP=www-data#export APACHE_RUN_GROUP=$WSL_USER#g" /etc/apache2/envvars

# configure php
echo "max_input_vars = 5000" | sudo tee /etc/php/8.1/cli/conf.d/moodle.ini
sudo ln -s  /etc/php/8.1/cli/conf.d/moodle.ini /etc/php/8.1/apache2/conf.d/moodle.ini

echo "[XDebug]
# https://xdebug.org/docs/all_settings
zend_extension = xdebug

xdebug.mode=debug
;xdebug.mode=develop
xdebug.client_port=9000

; host ip adress of wsl network adapter
xdebug.client_host=172.18.48.1

; idekey value is specific to PhpStorm
xdebug.idekey=phpstorm

// TODO: always enabling debugging slows down the web interface significantly.
// Instead prefer to enable debugging only when needed. See README.md for more information.
;xdebug.start_with_request=true
" | sudo tee /etc/php/8.1/apache2/conf.d/20-xdebug.ini
sudo rm /etc/php/8.1/cli/conf.d/20-xdebug.ini
sudo ln -s  /etc/php/8.1/apache2/conf.d/20-xdebug.ini /etc/php/8.1/cli/conf.d/20-xdebug.ini

# restart apache to apply updated config
sudo service apache2 restart

# install moodle
php $MOODLE_PARENT_DIRECTORY/moodle/admin/cli/install.php --lang=DE --wwwroot=http://localhost --dataroot=$MOODLE_PARENT_DIRECTORY/moodledata --dbtype=mariadb --dbhost=127.0.0.1 --dbport=3312 --dbuser=${_DB_MOODLE_USER} --dbpass=${_DB_MOODLE_PW} --dbname=${_DB_MOODLE_NAME} --fullname=fullname --shortname=shortname --adminuser=${_MOODLE_USER} --adminpass=${_MOODLE_PW} --adminemail=admin@blub.blub --supportemail=admin@blub.blub --non-interactive --agree-license

# setup for plugins (but don't download them, they have be present in the moodle folder already)
git clone https://github.com/ProjektAdLer/moodle-docker /tmp/moodle-docker
cp -r /tmp/moodle-docker/opt/adler/moodle/adler_setup $MOODLE_PARENT_DIRECTORY/moodle/
rm -rf /tmp/moodle-docker
php $MOODLE_PARENT_DIRECTORY/moodle/adler_setup/setup.php --first_run=true --user_name=${_USER_NAME} --user_password=${_USER_PASSWORD} --user_role=${_USER_ROLE} --develop_dont_install_plugins=true

# moodle config.php
# If changing anything: absolutely pay attention to escape $ (if shouln't be evaluated) and "
echo "
//=========================================================================
// 7. SETTINGS FOR DEVELOPMENT SERVERS - not intended for production use!!!
//=========================================================================

// configure phpunit
\$CFG->phpunit_prefix = 'phpu_';
\$CFG->phpunit_dataroot = '$MOODLE_PARENT_DIRECTORY/moodledata_phpu';
// \$CFG->phpunit_profilingenabled = true; // optional to profile PHPUnit runs.

// Force a debugging mode regardless the settings in the site administration
@error_reporting(E_ALL | E_STRICT); // NOT FOR PRODUCTION SERVERS!
@ini_set('display_errors', '1');    // NOT FOR PRODUCTION SERVERS!
\$CFG->debug = (E_ALL | E_STRICT);   // === DEBUG_DEVELOPER - NOT FOR PRODUCTION SERVERS!
\$CFG->debugdisplay = 1;             // NOT FOR PRODUCTION SERVERS!

// Force result of checks used to determine whether a site is considered \"public\" or not (such as for site registration).
// \$CFG->site_is_public = false;

# disable some caching (recommended by moodle introduction course)
\$CFG->langstringcache = 0;
\$CFG->cachetemplates = 0;
\$CFG->cachejs = 0;

//=========================================================================
// 11. BEHAT SUPPORT
//=========================================================================
// Behat test site needs a unique www root, data directory and database prefix:
//
\$CFG->behat_wwwroot = 'http://127.0.0.1';
\$CFG->behat_prefix = 'bht_';
\$CFG->behat_dataroot = '$MOODLE_PARENT_DIRECTORY/moodledata_bht';

require_once('$MOODLE_PARENT_DIRECTORY/moodle/moodle-browser-config/init.php');
require_once(__DIR__ . '/lib/setup.php'); // Do not edit
" >> $MOODLE_PARENT_DIRECTORY/moodle/config.php

# configure cron job
echo adding cron job
echo "*/1 * * * * $WSL_USER php $MOODLE_PARENT_DIRECTORY/moodle/admin/cli/cron.php > /dev/null 2>> $MOODLE_PARENT_DIRECTORY/moodledata/moodle-cron.log" | sudo tee /etc/cron.d/moodle


echo moodle login data: username: ${_MOODLE_USER} password: ${_MOODLE_PW}
echo db root pass: ${_DB_ROOT_PW}


# TODO untested
cd $MOODLE_PARENT_DIRECTORY/moodle
composer i
php admin/tool/phpunit/cli/init.php
php admin/tool/behat/cli/init.php
