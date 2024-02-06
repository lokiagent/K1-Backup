#!/bin/sh

INSTALL=0
PAUSE=0
RESUME=0
STOP=0

# Define a function to print script help
shelp() {
    echo "Usage: install-backup.sh [-i] [-p] [-r] [-s]"
    echo "Options:"
    echo "  -i  Install"
    echo "  -p  Pause"
    echo "  -r  Resume"
    echo "  -s  Stop"
}

# Parse command-line arguments
while getopts "iprs" option; do
    case "${option}" in
        i) INSTALL=$((INSTALL + 1)) ;;
        p) PAUSE=$((PAUSE + 1)) ;;
        r) RESUME=$((RESUME + 1)) ;;
        s) STOP=$((STOP + 1)) ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            shelp
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            shelp
            exit 1
            ;;
    esac
done

# Check if more than one flag is used
if [ "$((INSTALL + PAUSE + RESUME + STOP))" -gt 1 ]; then
    echo "Error: Only one flag is allowed at a time."
    shelp
    exit 1
fi

# If no flags are provided, print the command help
if [ "$((INSTALL + PAUSE + RESUME + STOP))" -eq 0 ]; then
    shelp
    exit 0
fi

# Pause, Resume, Stop flags
if [ "$PAUSE" = 1 ]; then
    echo "Pausing automatic backups until the next reboot or manually restarted..."
    /etc/init.d/S52K1-Backup stop
    exit 0
fi

if [ "$STOP" = 1 ]; then
    echo "Stopping automatic backups until manually restarted...."
    chmod -x /etc/init.d/S52K1-Backup
    exit 0
fi

if [ "$RESUME" = 1 ]; then
    echo "Resuming automatic backups..."
    chmod +x /etc/init.d/S52K1-Backup
    exit 0
fi
if [ "$INSTALL" = 1 ]; then

    # Install required packages using opkg
    if command -v opkg >/dev/null; then
        opkg update
        opkg install inotifywait # Adjust package names if needed
    else
        echo "Error: opkg package manager not found. Please install opkg manually."
        exit 1
    fi
    
    # Prompt user for configuration
    echo "Please enter the configuration information:"
    read -p "Enter GitHub personal access token: " GITHUB_TOKEN
    read -p "Enter backup repository name: " REPO_NAME
    read -p "Enter backup branch name: " BRANCH
    read -p "Enter user name: " USER_NAME
    
    # Prompt user to select folders to be watched
    IFS=/usr/data/printer_data/config
    
    # Clone K1 Backup Repo
    git clone https://github.com/lokiagent/K1-Backup.git /usr/data/K1-Backup
    
    # Connect config directory to github
    cd "$IFS" || exit
    git init
    git remote add origin https://"$USER_NAME":"$GITHUB_TOKEN"@github.com/"$USER_NAME"/"$REPO_NAME".git
    git checkout -b "$BRANCH"
    git add .
    git commit -m "Initial Backup"
    git push -u origin "$BRANCH"
    
    # Write configuration to .env file
    echo "IFS=$IFS" > $IFS/.env
    echo "GITHUB_TOKEN=$GITHUB_TOKEN" >> $IFS/.env
    echo "REMOTE=$REPO_NAME" >> $IFS/.env
    echo "BRANCH=$BRANCH" >> $IFS/.env
    echo "USER=$USER_NAME" >> $IFS/.env

    # Create .gitignore file to protect .env variables
    echo ".env" > $IFS/.gitignore
    
    # Insert .env to S52gitwatch.sh and move to init.d
    cp -f /usr/data/K1-Backup/S52backup /etc/init.d/S52backup
    sed -i "2i source $IFS/.env" /etc/init.d/S52backup
    chmod +x /etc/init.d/S52backup
    /etc/init.d/S52backup start
    
    echo "K1 Backup has been installed and configured."
exit 0
fi
