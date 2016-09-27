FROM alpine:3.4
MAINTAINER Rahim Rahman rahim@r2integration.com

WORKDIR /root

COPY ./alpine3.4-mariadb10.1.17/install.sh ./
RUN sh install.sh && rm install.sh

COPY db_binlog_s3sync.sh ./
COPY run.sh ./

ENV AWS_ACCESS_KEY_ID **none**
ENV AWS_SECRET_ACCESS_KEY **none**
ENV AWS_DEFAULT_REGION us-east-1
ENV AWS_S3BUCKET_PATH **none**

ENV MYSQL_USER root
ENV MYSQL_PASSWORD **none**
ENV MYSQL_HOST **none**
ENV MYSQL_PORT 3306

# if mysqlbinlog-backup is executed in the same server as your MySQL, it could use up
# high % of CPU, especially during tar.  CPU_LIMIT will allow you to limit your cpu 
# usage used for backing up.
ENV CPU_LIMIT 100

CMD ["bash", "run.sh"]
