#/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
# Description
#\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
# Schedulable backup of multiple directories


#/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
# Config
#\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
# Backup directories
DIRS="/home /mnt/media"

# SQL login details
MUSER=""
MPASS=""
MHOST="localhost"

# Temp location for DB dumps
MYTEMP="/tmp/mysql.bak"

# log file for completions
LOGFILE="/tmp/mylogs/dailybackups.log"

# Location to backup to
BACKTO="/mnt/backup"


MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

#/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
# MAIN
#\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

# Start logging stdout and stderr to log file
start=`date +%s`
echo "$(date "+%m%d%Y %T") : Starting daily backup\n" >> $LOGFILE 2>&1

# Grab all accessible DBs and dump to temp location
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
FILE=/tmp/mysql.bak/mysql-$db.gz
$MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done

# Run rsync on all dirs
rsync -aHk $DIRS $MYTEMP $BACKTO

# Log backup time upon completion
end=`date +%s`
runtime=$((end-start))
echo "$(date "+%m%d%Y %T") : Daily backup completed after $(runtime).\n"
