
apk update
apk add bash
apk add "mysql=10.1.17-r0"
apk add "mysql-client=10.1.17-r0"
apk add cpulimit

apk add python
apk add curl

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip "awscli-bundle.zip"
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

rm awscli-bundle.zip
rm -rf awscli-bundle

apk del curl

# cleanup
rm -rf /var/cache/apk/*
