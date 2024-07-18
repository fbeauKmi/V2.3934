# Rsync Backup for Printer Config and Related Files

This script is designed to backup printer configurations and related files to a Synology NAS.
To use this script, an RSA key for SSH authentication is required.

## Create RSA Key

> [!IMPORTANT]
> Ensure that SSH is activated on your NAS and a user is set up for your backup.

From the printer's shell, enter the following commands:

```bash
cd ~
ssh-keygen -t rsa
ssh-copy-id <syno_user>@<syno_ip>
```` 

## Setup `backup.ini`

Create a file named `backup.ini` in the same directory as the script with the following content:

```ini
[Remote]
USER=username
HOST=192.168.1.100
BACKUP_ROOT=~/voron2.4

[Backup]
MAX_BACKUPS=10

[Sources]
SOURCE=~/printer_data/config
SOURCE=~/printer_data/database
SOURCE=~/update_klipper_and_mcus
```

- `USER`: The remote user you created on the NAS
- `HOST`: The IP address of your Synology NAS
- `BACKUP_ROOT`: The backup folder for this machine on the NAS
- `MAX_BACKUPS`: The number of rolling backups to maintain
- `[Sources]`: Contains the folders to backup (you can add more SOURCE lines as needed)

## Add crontab entry

Use `crontab -e` to schedule the backup. For example:

``0 3 */2 * * /usr/bin/bash /home/pi/backup/rsync_backup.sh >/dev/null 2>&1``

This entry will run the backup every even day at 3:00 AM.

## Running the Script
To run the script manually:

Make sure the script is executable: `chmod +x /path/to/rsync_backup.sh`
Run the script: `/path/to/rsync_backup.sh`

The script will create dated backup folders in the specified `BACKUP_ROOT` on your NAS, maintain the specified number of backups, and create a latest symlink pointing to the most recent backup.

>[!NOTE]
 Ensure that the paths in the backup.ini file are correct for your setup. The script will automatically expand the tilde (~) to the full home directory path.
