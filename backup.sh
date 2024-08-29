#!/bin/bash

# Move into the directory with all Linux-Minecraft-Scripts
cd "$( dirname $0 )"

# Read configuration file
source $PWD/config.cfg

# Set script Directory
SHDIR=$PWD

# *-------------------------* SCRIPT *-------------------------*

cd $MCDIR

# Set todays backup dir

if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Starting AutoBackup Script.."
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Working in directory: $PWD."
fi

BACKUPDATE=`date +%d-%m-%Y`
FINALDIR="$BACKUPDIR/$BACKUPDATE"

if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Checking if backup folders exist, if not then create them."
fi

cd $MCDIR

if [ -d $BACKUPDIR ]
then
  echo -n < /dev/null
else
  mkdir "$BACKUPDIR"

  if [ $LOGIT -eq 1 ]
  then
      echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Created Folder: $BACKUPDIR"
  fi

fi

if [ -d "$FINALDIR" ]
then
  echo -n < /dev/null
else
  mkdir "$FINALDIR"
 
  if [ $LOGIT -eq 1 ]
  then
      echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Created Folder: $FINALDIR"
  fi

fi

if [ $OLDBACKUPS -lt 0 ]
then
  OLDBACKUPS=3
fi

# Deletes backups that are 'n' days old
if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Removing backups older than 3 days."
fi
OLDBACKUP=`find $PWD/$BACKUPDIR -type d -mtime +$OLDBACKUPS | grep -v -x "$PWD/$BACKUPDIR" | xargs rm -rf`

#Get level-name
if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Fetching Level Name.."
fi

while read line
do
  VARI=`echo $line | cut -d= -f1`
  if [ "$VARI" == "level-name" ]
  then
      WORLD=`echo $line | cut -d= -f2`
  fi
done < "$PROPFILE"

if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Level-Name is $WORLD"
fi

BFILE="$WORLD.$STAMP.tar.gz"
CMD="tar -czf $FINALDIR/$BFILE $WORLD"
BFILEC="config.$STAMP.tar.gz"
CMDC="tar -czf $FINALDIR/$BFILEC config"

if [ $LOGIT -eq 1 ]
then
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Packing and compressing folder: $WORLD to tar file: $FINALDIR/$BFILE"
  echo "$(date +"%G-%m-%d %H:%M:%S") [LOG] Packing and compressing folder: config to tar file: $FINALDIR/$BFILEC"
fi

if [ $NOTIFY -eq 1 ]
then
  screen -x $SCREENNAME -X stuff "`printf "say Backing up world: \'$WORLD\' Server go in readonly\r"`"
fi

#put the server in readonly mode to reduce the chance of backing up half of a chunk.
  screen -x $SCREENNAME -X stuff `printf "save-off\r"`

#Send save-all to the console
if [ $AUTOSAVE -eq 1 ]
then
  screen -x $SCREENNAME -X stuff `printf "save-all\r"`
  sleep 2
fi

# Run backup command
$CMD
$CMDC
screen -x $SCREENNAME -X stuff "`printf "save-on\r"`"

if [ $NOTIFY -eq 1 ]
then
  # Tell server the backup was completed.
  screen -x $SCREENNAME -X stuff "`printf "say Backup Completed.\r"`"
fi

# --Cron Job Install--

cd $SHDIR

if [ $CRONJOB -eq 1 ]
then

  #Work out crontime
  if [ $UPDATEHOURS -eq 0 -o $UPDATEHOURS -lt 0 ]
  then
      MINS="*"
      HOURS="*"
  else
      MINS="0"
      HOURS="*/$UPDATEHOURS"
  fi

  #Check if cronjob exists, if not then create.
  crontab -l > .crons
  EXIST=`crontab -l | grep $0 | cut -d";" -f2`
  CRONSET="$MINS $HOURS * * * cd $PDW;$0"

  if [ "$EXIST" == "$0" ]
  then

      #Check if cron needs updating.
      THECRON=`crontab -l | grep $0`
      if [ "$THECRON" != "$CRONSET" ]
      then
        CRONS=`crontab -l | grep -v "$0"`
        echo "$CRONS" > .crons
        echo "$CRONSET" >> .crons
        crontab .crons
        echo "Cronjob has been updated"
      fi

      rm .crons
      exit
  else
      crontab -l > .crons
      echo "$CRONSET" >> .crons
      crontab .crons
      rm .crons
      echo "Autobackup has been installed."
      exit
  fi

fi