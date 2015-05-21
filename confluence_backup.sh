#!/bin/sh

DB="<dbname>"
DBUSER="'<username>"
DBPASSWD="<password>"
DATE=`%y_%H_%M`

# export DB
mysqldump -u $DBUSER -p${DBPASSWD} $DB | gzip > /tmp/db_backup/db_${DB}_$DATE.bak.gz

# export configs ###PLEASE NOTE YOUR CONFLUENCE LOCATION MIGHT BE DIFFERENT !!! ###
tar -cf /opt/<confluence-version>/conf/*.tar  /tmp/backup/configs/

#if you are running xml buckup let's move it too 
tar -cf <confluence-home-path>/daily-backup-$DATE.tar /tmp/backup/xml/

# remove backup files older than 30 days
find /tmp/db_backup/db* -mtime +30 -exec rm {} \;
find /tmp/xml_backup/xml_backup* -mtime +30 -exec rm {} \;
find /tmp/backup/configs* -mtime +30 -exec rm {} \;

# upload both backups to s3 
/usr/local/bin/aws s3 sync /tmp/db_backup s3://BUCKET-NAME --delete
/usr/local/bin/aws s3 sync /tmp/backup/configs s3://BUCKET-NAME --delete
/usr/local/bin/aws s3 sync /tmp/xml_backup s3://BUCKET-NAME --delete