#! /bin/bash

set -e

BASEDIR=$(dirname "$0")

source "$BASEDIR/.env"
month=$(date -d "$(date +%Y-%m-1) -1 month" +%Y%m)

echo "Backing up month $month"

if [ -d "$NAS_PATH/$month" ]; then
  echo "Deleting files in $month to ensure deleted files from origin are deleted in backups"
  rm -rf "${NAS_PATH:?}/$month/*"
fi

mkdir -p "$NAS_PATH/$month"

echo "From syncthing folders to unique NAS month folder (onsite backup)"
backup_folder () {
   count=$(find $SYNCTHING_PATH/$1/ -name "*_$month*" | wc -l)
   if [ "$count" -ge 1 ]; then
     rsync -avh $SYNCTHING_PATH/$1/*_$month* "$NAS_PATH/$month/"
   else
     echo -e "Subject: Backup error\nFrom: email@homelab\nMissing files in $SYNCTHING_PATH/$1/*_$month*" | mail $EMAIL_ADDRESS
   fi
}

backup_folder "movil_miguel/camara/Camera"
backup_folder "Tarjeta-Movil-Maria"

echo "Starting rclone (offsite backup)"
rclone sync "$NAS_PATH/$month" "$RCLONE_REMOTE:$month" --progress

echo -e "Subject: Backup result\nFrom: email@homelab\nBackup result" | mail $EMAIL_ADDRESS
