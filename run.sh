#!/bin/bash

echo "RUNNING"
if [ "$BACKUP_TYPE" == "hourly" ]
then
  ./db_binlog_s3sync.sh hourly
elif [ "$BACKUP_TYPE" == "daily" ]
then
  ./db_binlog_s3sync.sh daily
elif [ "$STAY_ALIVE" == "true" ]
then
  tail -f /dev/null
fi
