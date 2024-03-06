# K1-Backup
Custom script to watch klipper configuration folder and automatically back up to github whenever a change is made in that directory.

Credit to [gitwatch](https://github.com/gitwatch/gitwatch) for automatic watching and commit to github. Modified their script to work for busybox sh, specifically the Creality K1 & K1 Max.
This script uses inotifywait, part of the inotify-utils, and pkill. Packages will be installed during the installation process if not already installed.

## Installation
First, create a new repository to direct your backups to. You will also need to create a personal access token. [Here is the process if you're unfamiliar.](https://docs.github.com/en/enterprise-server@3.9/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) Once you have your token, do not navigate away from the page, as you will not be able to see the token again.

To install the script:
```
git clone https://github.com/lokiagent/K1-Backup.sh /usr/data/K1-Backup
chmod +x /usr/data/K1-Backup/K1-Backup.sh && sh /usr/data/K1-Backup/K1-backup.sh -i
```
Enter your github personal access token, repository, branch and username. You can direct the script to watch any directory, but it should be /usr/data/printer_data/config for your klipper config folder. Once installation is complete, it will save all of those variables to a .env file in the directory given and place a service script in /etc/init.d to start up on boot.

## Usage
The script can be controlled with the following flags:
```
Usage: K1-Backup.sh [-i] [-p] [-r] [-s] -b branch -t target -g remote
Options:
  -i              Install
  -p              Pause
  -r              Resume
  -s              Stop
  -b branch       Specify branch for git push
  -t target       Specify target directory or file to watch
  -g remote       Specify remote for git push
```

- Pause stops the currently running K1-Backup service, but it will be restarted on the next reboot, or when manually resumed.
- Stop will stop the K1-Backup service until it is manually resumed.
- Resume renables the background service and starts it if not already running.
- Branch, target and remote are all required to start the service, and will be saved in the .env file during installation.

## Klipper Macros
The following macros can be enabled to control K1-Backup service from Mainsail/Fluidd. NOTE: These macros will require the [gcode_shell_command](https://github.com/Guilouz/Creality-K1-and-K1-Max/wiki/Klipper-Gcode-Shell-Command) addon to be installed.
- BACKUP_STOP
- BACKUP_PAUSE
- BACKUP_RESUME

To install the macros, ssh to the printer and input ```ln -s /usr/data/K1-Backup/backup_macro.cfg /usr/data/printer_data/config/backup_macro.cfg``` and add the line ```[include backup_macro.cfg]``` to your printer.cfg file.

## Updates
To keep the backup script up-to-date, you can this to your moonraker.conf file:
```
[update_manager K1-Backup]
type: git_repo
channel: dev
path: /usr/data/K1-Backup
origin: https://github.com/lokiagent/K1-Backup.git
primary_branch: main
is_system_service: false
```
