#!/bin/bash

SCRIPT_NAME=db_binlog_s3sync
MYSQL_CREDENTIALS="--user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOST --port=$MYSQL_PORT"

TODAY=`date +%Y%m%d`
TODAY_FILENAME="$TODAY.sql"
TODAY_COMPRESSED_FILENAME="$TODAY_FILENAME.tar.gz"

if [ ! -z "$1" ]
then
  # daily
  if [ "$1" == "daily" ]
  then
    # check to see if daily file already exists on S3
    FILE_EXISTS=`aws s3 ls $AWS_S3BUCKET_PATH/daily/$TODAY_COMPRESSED_FILENAME | wc -l  | tr -d " "`
    if [ "$FILE_EXISTS" == "1" ]
    then
      echo "[$SCRIPT_NAME] Daily file found."
    else
      cpulimit -l $CPU_LIMIT -iz mysqldump $MYSQL_CREDENTIALS --single-transaction --all-databases --flush-logs --master-data=2 > "$TODAY_FILENAME"
      cpulimit -l $CPU_LIMIT -iz tar -zcvf "$TODAY_COMPRESSED_FILENAME" "$TODAY_FILENAME"
      aws s3 --region $AWS_DEFAULT_REGION cp "$TODAY_COMPRESSED_FILENAME" "$AWS_S3BUCKET_PATH/daily/$TODAY_COMPRESSED_FILENAME"
      rm "$TODAY_COMPRESSED_FILENAME" "$TODAY_FILENAME"
      # we don't need old binary logs after creating a full backup
      mysql $MYSQL_CREDENTIALS -e "PURGE BINARY LOGS BEFORE NOW();"
      echo "[$SCRIPT_NAME] Binary logs flushed and old logs purged."
      echo "[$SCRIPT_NAME] Daily backup file ($TODAY_COMPRESSED_FILENAME) uploaded."
    fi
  elif [ "$1" == "hourly" ]
  then
    HOURLY=`date +%Y%m%d-%H%M%S`
    HOURLY_FILENAME="$HOURLY.sql"
    HOURLY_COMPRESSED_FILENAME="$HOURLY_FILENAME.tar.gz"

    # check to see if daily file already exists on S3
    FILE_EXISTS=`aws s3 ls $AWS_S3BUCKET_PATH/daily/$TODAY_COMPRESSED_FILENAME | wc -l  | tr -d " "`
    if [ "$FILE_EXISTS" == "1" ]
    # we found daily backup file, let's proceed.
    then
      # flush logs to lock the current bin log and start new
      mysqladmin $MYSQL_CREDENTIALS flush-logs
      # binlogfiles=`ls -d /var/lib/mysql/mysql-bin.?????? | sed -e 's/\n/ /g'`
      # should make the binlog path & filename in a var
      binlogfiles_array=($(ls -d /var/lib/mysql/mysql-bin.??????))
      # pop the last binlog file from array, since it's usually being used
      unset binlogfiles_array[${#binlogfiles_array[@]}-1]
      # get binlogfiles count
      binlogfiles_count=${#binlogfiles_array[@]}

      if [ "$binlogfiles_count" -ge 1 ]
      then
        # make this into a one liner
        binlogfiles=$( IFS=$'\n'; echo "${binlogfiles_array[*]}" )
        cpulimit -l $CPU_LIMIT -iz mysqlbinlog $binlogfiles > $HOURLY_FILENAME
        cpulimit -l $CPU_LIMIT -iz tar -zcvf "$HOURLY_COMPRESSED_FILENAME" "$HOURLY_FILENAME"
        aws s3 --region $AWS_DEFAULT_REGION cp "$HOURLY_COMPRESSED_FILENAME" "$AWS_S3BUCKET_PATH/hourly/$HOURLY_COMPRESSED_FILENAME"
        rm "$HOURLY_COMPRESSED_FILENAME" "$HOURLY_FILENAME"
        # we don't need old binary logs after creating a full backup
        mysql $MYSQL_CREDENTIALS -e "PURGE BINARY LOGS BEFORE NOW();"

        echo "[$SCRIPT_NAME] Binary logs flushed and old logs purged."
        echo "[$SCRIPT_NAME] Hourly backup file ($HOURLY_COMPRESSED_FILENAME) uploaded."
      else
        echo "[$SCRIPT_NAME] Binlog files not found."
      fi
    else
      echo "[$SCRIPT_NAME] Daily dump file not found"
    fi
  fi

fi
