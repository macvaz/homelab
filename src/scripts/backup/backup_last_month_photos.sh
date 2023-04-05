#! /bin/bash

set -e

BASEDIR=$(dirname "$0")
source "$BASEDIR/.env"

if [ -z "$1" ]; then
  month=$(date -d "$(date +%Y-%m-1) -1 month" +%Y%m)
else
  month=$1
fi

echo "Backing up month $month"

if [ -d "$NAS_PATH/$month" ]; then
  echo "Deleting files in $month to ensure deleted files from origin are deleted in backups"
  rm -rf "${NAS_PATH:?}/$month/*"
fi

mkdir -p "$NAS_PATH/$month"

echo "From syncthing folders to unique NAS month folder (onsite backup)"
backup_folder () {
  count=$(find $SYNCTHING_PATH/$1 -name "IMG-*" | wc -l)
  if [ "$count" -ge 1 ]; then
    echo "Ensuring IMG_ preffix in $SYNCTHING_PATH/$1"
    for f in $(ls $SYNCTHING_PATH/$1/IMG-*); do
      new_name=$(echo $f | sed -e 's/IMG-/IMG_/g')
      mv $f $new_name
      echo "Old name: $f to new name: $new_name"
    done;
  fi;

   count=$(find $SYNCTHING_PATH/$1/ -name "*_$month*" | wc -l)
   if [ "$count" -ge 1 ]; then
     rsync -avh $SYNCTHING_PATH/$1/*_$month* "$NAS_PATH/$month/"
   else
     echo "Missing files in $SYNCTHING_PATH/$1/*_$month*" | mutt -s "Backup error" $EMAIL_ADDRESS
   fi
}

backup_folder "movil_miguel/camara/Camera"
backup_folder "Tarjeta-Movil-Maria"

echo "Starting rclone (offsite backup)"
rclone sync "$NAS_PATH/$month" "$RCLONE_REMOTE:$month" --progress

sleep 2

cat $HOME/backup.log | mutt -s "Backup result" -a $HOME/backup.log -- $EMAIL_ADDRESS
