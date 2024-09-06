# Postgresql
The default `docker-compose.yml` file uses a MariaDB database.
If you want to use a Postgresql database, you can use the `docker-compose-postgres.yml` file instead.
It is configured as similar as possible to the MariaDB database.
At the moment there is no way to migrate the data between the two databases.
Take a backup of the data before switching to Postgresql, so you can restore it later.

⚠️⚠️ **Danger** ⚠️⚠️
- It is not possible to back up a Postgresql with the provided backup script.
- It is not possible to restore a backup from a MariaDB database to a Postgresql database with the provided restore script.

When switching to Postgresql, you have to modify the config.php file in the moodle folder (see the example below).
You also have to delete the content of the moodledata folder (back it up before).
Restart the apache server after installing the dependencies: `sudo systemctl restart apache2`.
```php
$CFG->dbtype    = 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost    = '127.0.0.1';
$CFG->dbname    = 'bitnami_moodle';
$CFG->dbuser    = 'bitnami_moodle';
$CFG->dbpass    = 'c';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
    'dbpersist' => 0,
    'dbport' => 5432, // default PostgreSQL port
    'dbsocket' => '',
    'dbcollation' => 'en_US.utf8', // adjust this according to your PostgreSQL server configuration
);
```
