# Moodle dev env
This file will show a short summary of different approaches to set up a development environment for Moodle on Windows 
and describe the steps to set up the environment.

For information about why this approach was chosen, see the [approach evaluation document](alternative_approaches.md).

## Requirements
- WSL2
- Docker Desktop
- WSL disto Ubuntu 22.04  
  ⚠️ Other Distros likely will not work out of the box as of dependency issues.



## Warnings / Hints
- This approach expects port 80 to be unused.
- This approach expects apache is not yet used in the WSL instance.
  It will likely break whatever apache is running in the WSL instance.
  If you are already using apache in the WSL instance, you might want to use another `--distribution` for this approach.
  Note that you will likely also have to change the port of the apache server in this case.
- To resolve any issues with shell scripts (typically ^M errors), disable automatic line ending conversion in git by running:
`git config --global core.autocrlf false` or `git config --global core.autocrlf input`

**Debug shell scripts manually executed in WSL**:
For PHPStorm path mapping to work it is required to set an environment variable in the WSL instance before executing the PHP script: `export PHP_IDE_CONFIG="serverName=localhost"` \
"localhost" is the name of the server configured in PHPStorm.

It might be necessary to manually set the idekey: `export XDEBUG_CONFIG="idekey=blub"`. The value itself ("blub") is irrelevant. 

## Preparations
This section will describe how to setup and reset the development environment.

1. Enter WSL. This guide will use shell commands and therefore does not work with the Windows console.
2. Clone this repository to a place of your choice (eg `/home/<wsl username>/AdlerDevelopmentEnvironment`).
3. continue with the following sections

**Note**: I am not sure whether the scripts will work when cloning on a Windows system (and yes i know this environment is only for windows).
Should you have trouble executing the script (something with ^M), delete the repository, 
disable automatic line ending conversion in git (`git config --global core.autocrlf input`) and clone again.

### Windows Setup
Windows classifies the WSL network as public.
Therefore, no incoming network connections from WSL to Windows are allowed.

Workaround ([see this issue](https://github.com/microsoft/WSL/issues/4585#issuecomment-610061194):
1. Open Windows terminal as admin
2. Run `New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow` (or this in case the command does not work: `New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -Action Allow`)

⚠️ This has to be done after every reboot.

### Download moodle script
To download moodle, run the following script: `./download_moodle.sh`. It is downloading moodle to `/home/<wsl username>/moodle` and
installs all plugins of the "main" release set ([found here](https://github.com/ProjektAdLer/moodle-docker/blob/main/plugin-releases.json)).
The plugins are installed as git repository, therefore it is possible to directly start developing on them.

### Installation Script
⚠️ **Run this script only once. To run again, execute the uninstall script first.**
⚠️ **All Paths in this Step are hardcoded. So use them as they are mentioned here!**
1. **Execute the setup Script**:  
   The [setup.sh bash script](setup.sh) sets up your environment, including installing required packages, setting up the database, and configuring Apache and PHP.

### uninstall script
To reset the environment run the [reset_data.sh](reset_data.sh) script.
It will not undo all changes made by the installation script, just delete all data so the setup-script can be run again.

### backup and restore scripts
- [backup_data.sh](backup_data.sh): Creates a backup of Moodle data and database. Run using ./backup_data.sh.
- [restore_data.sh](restore_data.sh): Restores Moodle from a backup. Use it like ./restore_data.sh /path/to/backup.

### PHPStorm setup
0. **Make sure, moodle is installed via the installation script**
1. **WSL PHP Interpreter**:
- Navigate to Settings -> PHP -> CLI interpreter
- Click 3 dots -> "+" -> From Docker, Vagrant, ... -> WSL
- Choose your WSL2 distribution and press OK.

2. **Set new interpreter as project default**:
- Ctrl + Shift + A -> Change PHP interpreter
- Choose new interpreter -> OK

3. **PHP Server Setup**:
- Navigate to Settings -> PHP -> Servers -> localhost
- On the first incoming debugging connection, this entry should be created. If not, add it manually (Host: localhost, Port: 80, Debugger: Xdebug).
- Check "Use path mappings (...)"
- Add the following path mapping:  
  `\\wsl$\\Ubuntu\\home\\<wsl username>\\moodle -> /home/<wsl username>/moodle`

## Postgresql
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

## Configuring Moodle Behat Tests in Windows Subsystem for Linux (WSL)

This documentation outlines the approach I followed to set up Behat tests for Moodle within the WSL environment. It's designed to facilitate the running of UI applications using WSLg, crucial for executing Behat tests that require a graphical user interface.

### Prerequisites
- Ensure WSLg (Windows Subsystem for Linux with GUI support) is enabled to run UI applications in WSL. This feature is necessary for executing tests that involve a graphical user interface.

### Setup Instructions
Read the [Moodle setup guide for Behat](https://moodledev.io/general/development/tools/behat/running) to understand the requirements and setup steps for Behat tests.

1. **Selenium with Chrome:**
    - Attempts to use Selenium with Firefox resulted in errors related to user profile creation.
    - **Chrome Setup:**
        - There are two potential paths. Both are equally valid
        - **Old Chrome Version:**
            - Download an [older version of Chrome](http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/) 
            - that is compatible with [the latest chromedriver](https://old.chromedriver.getwebdriver.com/index.html).
            - Place the downloaded chromedriver in the moodle root directory.
            - Note: Use chromedriver directly, as chromedriver-wrapper has not been tested in this setup.
        - **Current Chrome Version:**
            - Download [chromedriver](https://getwebdriver.com/chromedriver#stable) version.
            - Extract the downloaded chromedriver archive and place the chromedriver file in the moodle root directory.
            - Download the [corresponding version of Chrome](http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/).
        - Install Chrome using the following command:
            ```bash
            sudo apt install -y ./<filename of the downloaded Chrome package>
            ```
        - Prevent Chrome from updating by running the following command (as unintended updates will break compatibility with chromedriver):
            ```bash
            sudo apt-mark hold google-chrome-stable
            ```
        - Run `google-chrome-stable` to verify the setup. If a Chrome window opens, the setup was successful.

4. **Download Selenium Server:**
    - Download the latest `Selenium Server (Grid)` jar file from the [official Selenium website](https://www.selenium.dev/downloads/).
    - Place it in the moodle root directory.

### Running Tests

1) navigate to the moodle root directory `cd /home/<wsl username>/moodle`
2) start Selenium: `PATH=./:$PATH java -jar <filename of the downloaded selenium file> standalone`
3) in a new terminal window, run the following command to start the Behat test:
    ```bash
    vendor/bin/behat --config /home/<wsl username>/moodledata_bht/behatrun/behat/behat.yml --profile chrome
    ```
   This is just for testing, it will run all moodle tests. After some tests a Chrome window will open (not all tests actually need
   a browser). If this happens the tests are running correctly.

### Adding a new feature (.feature file)
After adding a new feature file, behat test environment has to be recreated. This can be done by running the following command:
`php admin/tool/behat/cli/init.php`


## Update Moodle
⚠️ This is not an official way to update Moodle but will likely work fine as long as only files were 
changed that are not part of the moodle repository (eg. plugins).

⚠️ It is not possible to downgrade Moodle. To downgrade, it is required to reset the environment (`reset_data.sh`) before starting
with the Update step.

1. **Backup**:
   Especially because this is an unsupported way to update moodle, it is important to create a full backup before updating,
   including the moodle directory itself. The `backup_data.sh` script **does not backup the moodle directory**.
2. **Update**:
   - change to the moodle directory: `cd /home/<wsl username>/moodle`
   - fetch the branch: `git fetch origin <branch name>:<branch name>`
   - checkout the branch: `git checkout <branch name>`
3. **Update the database**:
   - open Moodle in the browser and login as admin
