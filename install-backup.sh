#!/bin/sh

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
echo "GITWATCH_GITHUB_TOKEN=$GITHUB_TOKEN" >> $IFS/.env
echo "GITWATCH_REMOTE=$REPO_NAME" >> $IFS/.env
echo "GITWATCH_BRANCH=$BRANCH" >> $IFS/.env
echo "GITWATCH_USER=$USER_NAME" >> $IFS/.env

# Insert .env to S52gitwatch.sh and move to init.d
cp -f /usr/data/K1-Backup/S52backup.sh /etc/init.d/S52backup
sed -i "2i source $IFS/.env" /etc/init.d/S52backup
chmod +x /etc/init.d/S52backup
sh /etc/init.d/S52backup start

echo "K1 Backup has been installed and configured."
