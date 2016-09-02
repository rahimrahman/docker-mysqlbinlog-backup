# docker-mysqlbinlog-backup

Backup MySQL database using daily dump and incremental backup using `mysqlbinlog`.

## Usage

Run mysqlbinlog-backup container with the following flags:

```
docker run \
  --rm \
  --volumes-from <mysql-container-name> \
  --name mysqlbinlog_backup \
  --env-file env.txt \
  -e "BACKUP_TYPE=hourly" \
  r2integration/mysqlbinlog-backup
```

Note: `BACKUP_TYPE=hourly` will fail if there are no current daily backup.

Available options:

* "BACKUP_TYPE=daily" - create daily backup.  Can only happened once a day.

Make sure to have `env.txt`

```
AWS_ACCESS_KEY_ID=<aws-access-key-id>
AWS_SECRET_ACCESS_KEY=<aws-secret-access-key>
AWS_DEFAULT_REGION=us-east-1
AWS_S3BUCKET_PATH=s3://<aws-bucket-name>

MYSQL_USER=root
MYSQL_PASSWORD=<mysql-password>
MYSQL_HOST=<mysql-host>
MYSQL_PORT=3306
```

Valid Amazon Web Service credentials and S3 bucket are required to upload compressed files to Amazon S3.

## Assumptions

* mysql binary logging is enabled 
* default mysql storage path: /var/lib/mysql
* mariadb mysqldump and mysqlbinlog will work the same as actual mysql. Please let me know if this is a bad assumption.


## TODO:

- [ ] ability to use different mysql bin log file name
- [ ] ability to use different path to mysql bin log
- [ ] ability to create separate cron job for daily and hourly






