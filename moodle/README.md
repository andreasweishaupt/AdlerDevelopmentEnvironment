# Moodle dev env
This file will show a short summary of different approaches to set up a development environment for Moodle on Windows 
and describe the steps to set up the environment.

## Evaluation of different approaches to develop for moodle on windows
**Running moodle webserver on Windows**: All approaches where the webserver runs on Windows have the common problem that the performance is very bad.
The following variants of this approach were tested: [Moodle on Windows](https://docs.moodle.org/402/de/Vollst%C3%A4ndiges_Installationspaket_f%C3%BCr_Windows), own setup with XAMPP with database from XAMPP (DB had problem starting sometimes) and DB in WSL.

**Running moodle webserver in WSL**: This approach works well. This is the approach I followed the most time.
Windows 10 had a bug where WSL hung up regularly (probably caused by switching monitor configuration).

**Running moodle in docker**: In theory a well working approach. Should provide the same performance as the WSL approach and setup should be easier.
In practice there were too many problems with this approach.


## approach WSL
This documentation outlines the steps to set up a Moodle PHP development environment
using Windows Subsystem for Linux (WSL2) and Docker Desktop. Other potential approaches are
described and evaluated below.

**Note**: Although this approach is nearly fully automated,
it is not as reliable as the 3D, AMG and Backend dev environment.
Some Linux knowledge will be very helpful to resolve potential issues.

## Requirements
- WSL2
- Docker Desktop

## Warnings / Hints
- This approach expects port 80 to be unused.
- This approach expects apache is not yet used in the WSL instance.
  It will likely break whatever apache is running in the WSL instance.
  If you are already using apache in the WSL instance, you might want to use another `--distribution` for this approach.
  Note that you will likely also have to change the port of the apache server in this case.
- To resolve any issues with shell scripts (typically ^M errors), disable automatic line ending conversion in git by running:
- `git config --global core.autocrlf false` or `git config --global core.autocrlf input`

**Debug shell scripts manually executed in WSL**:
For PHPStorm path mapping to work it is required to set an environment variable in the WSL instance before executing the PHP script: `export PHP_IDE_CONFIG="serverName=localhost"` \
"localhost" is the name of the server configured in PHPStorm.

It might be necessary to manually set the idekey: `export XDEBUG_CONFIG="idekey=blub"`. The value itself ("blub") is irrelevant. 

## Environment Setup
This section will describe how to setup and reset the development environment.

1. Enter WSL. This guide will use shell commands and therefore does not work with the Windows console.
2. ⚠️ The guide and script assumes you are using the user "markus". 
As this is likely not the case for you, replace "markus" with your WSL username on all occurrences, in the following steps **and in the scripts**.
3. Clone this repository to a place of your choice (eg `/home/markus/AdlerDevelopmentEnvironment`).
4. continue with the following sections

**Note**: I am not sure whether the scripts will work when cloning on a windows system (and yes i know this environment is only for windows).
Should you have trouble executing the script (something with ^M), delete the repository, 
disable automatic line ending conversion in git (`git config --global core.autocrlf input`) and clone again.

### Windows Setup
Windows classifies the WSL network as public.
Therefore, no incoming network connections from WSL to Windows are allowed.

Workaround ([see this issue](https://github.com/microsoft/WSL/issues/4585#issuecomment-610061194):
1. Open Windows terminal as admin
2. Run `New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow` (`New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -Action Allow`)

⚠️ This has to be done after every reboot.

### Installation Script
⚠️ **Run this script only once. To run again, execute the uninstall script first.**
⚠️ **All Paths in this Step are hardcoded. So use them as they are mentioned here!**
1. **Download Moodle**:
    - Download and place the Moodle folder in `/home/markus/moodle`.
    - Download plugins and copy them to respective folders in `/home/markus/moodle`. If installing without plugins the section "setup for plugins" of the setup script will fail.

2. **Execute the Script**:  
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
  `\\wsl$\\Ubuntu\\home\\markus\\moodle -> /home/markus/moodle`


## Configuring Moodle Behat Tests in Windows Subsystem for Linux (WSL)

This documentation outlines the approach I followed to set up Behat tests for Moodle within the WSL environment. It's designed to facilitate the running of UI applications using WSLg, crucial for executing Behat tests that require a graphical user interface.

### Prerequisites
- Ensure WSLg (Windows Subsystem for Linux with GUI support) is enabled to run UI applications in WSL. This feature is necessary for executing tests that involve a graphical user interface.

### Setup Instructions
1. **Moodle Environment Setup:**
    - Follow the official [Moodle setup guide for Behat](https://moodledev.io/general/development/tools/behat/running) to configure your environment for running Behat tests.

2. **Selenium with Chrome:**
    - Attempts to use Selenium with Firefox resulted in errors related to user profile creation.
    - **Chrome Setup:**
        - Download an older version of Chrome that is compatible with the latest chromedriver from [here](http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/).
        - Use chromedriver directly, as chromedriver-wrapper has not been tested in this setup.

3. **Configuration Adjustments in Moodle's `config.php`:**
    - Updated the Moodle `config.php` file with the following settings to define the Behat testing environment:
      ```php
      $CFG->behat_wwwroot = 'http://127.0.0.1';
      $CFG->behat_prefix = 'bht_';
      $CFG->behat_dataroot = '/path/to/your/moodledata_bht';
      
      // Include these lines at the end of the file
      require_once('/path/to/your/moodle/moodle-browser-config/init.php');
      require_once(__DIR__ . '/lib/setup.php'); // Do not edit this line
      ```
      Replace `/path/to/your/` with the actual path to your Moodle installation and data directory.

4. **Driver and Selenium Server Setup:**
    - Download the respective driver and moodle-browser-config to your moodle root directory.
    - Add the path to chromedriver (or geckodriver, if using Firefox) to your system's `PATH` environment variable:
      ```bash
      export PATH="/path/to/your/moodle/:$PATH"
      ```
    - Launch the Selenium server with the following command:
      ```bash
      java -jar path/to/selenium-server-4.17.0.jar standalone
      ```
      Ensure to adjust the path and version number to match the location and version of your Selenium server jar file.

### Running Tests
With the setup complete, you're now ready to run your Behat tests in the WSL environment. 
