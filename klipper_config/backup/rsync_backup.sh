#!/bin/bash

set -e

# Function to read INI file
parse_ini() {
    local file="$1"
    local section="$2"
    local key="$3"
    sed -n "/^\[$section\]/,/^\[/p" "$file" | grep "^$key=" | cut -d'=' -f2-
}

# Read configuration
CONFIG_FILE="$HOME/scripts/backup.ini"
REMOTE_USER=$(parse_ini "$CONFIG_FILE" "Remote" "USER")
REMOTE_HOST=$(parse_ini "$CONFIG_FILE" "Remote" "HOST")
BACKUP_ROOT=$(parse_ini "$CONFIG_FILE" "Remote" "BACKUP_ROOT")
MAX_BACKUPS=$(parse_ini "$CONFIG_FILE" "Backup" "MAX_BACKUPS")

# Read sources
SOURCES=()
while IFS= read -r line; do
    if [[ $line == SOURCE* ]]; then
        value=$(echo "$line" | cut -d'=' -f2-)
        SOURCES+=("${value/#\~/$HOME}")  # Replace leading tilde with $HOME
    fi
done < "$CONFIG_FILE"

DATE=$(date +"%Y-%m-%d-%H%M%S")
LATEST="$BACKUP_ROOT/latest"


# Set up SSH agent
eval $(ssh-agent -s)
ssh-add $HOME/.ssh/id_rsa

# Create backup directory and copy latest backup on remote
ssh $REMOTE_USER@$REMOTE_HOST "
    mkdir -p $BACKUP_ROOT/$DATE
    if [ -e $LATEST ]; then
        cp -al $LATEST/. $BACKUP_ROOT/$DATE/
    fi
"

# Perform incremental backup for each source
for SOURCE in "${SOURCES[@]}"; do
    SOURCE_NAME=$(basename "$SOURCE")
    LINK_DEST="$LATEST/$SOURCE_NAME"

    # Check if the link-dest directory exists
    if ssh $REMOTE_USER@$REMOTE_HOST "[ -d $LINK_DEST ]"; then
        LINK_DEST_OPTION="--link-dest=$LINK_DEST"
    else
        LINK_DEST_OPTION=""
    fi
    
    echo "Backup $LINK_DEST"
    rsync -avz --delete $LINK_DEST_OPTION \
        --exclude='.git' \
        --rsync-path=/usr/bin/rsync \
        "$SOURCE/" "$REMOTE_USER@$REMOTE_HOST:$BACKUP_ROOT/$DATE/$(basename "$SOURCE")/"
done

# Update latest symlink and remove old backups
ssh $REMOTE_USER@$REMOTE_HOST "
    ln -snf $BACKUP_ROOT/$DATE $LATEST
    cd $BACKUP_ROOT
    while [ \$(find . -maxdepth 1 -type d -name '20*' | wc -l) -gt $MAX_BACKUPS ]; do
        oldest=\$(find . -maxdepth 1 -type d -name '20*' | sort | head -n 1)
        rm -rf \$oldest
    done
"

echo "Backup completed successfully"

