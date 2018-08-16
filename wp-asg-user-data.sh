#!/bin/bash

yum update -y
yum install httpd php php-mysql amazon-efs-utils -y

# Enable AllowOverride All in httpd.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-backup.conf
sed -i '151s/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Mount EFS Volume on /var/www/html
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /var/www/html
echo '${efs_dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab

# Start httpd
service httpd start
chkconfig httpd on

# Sync /var/www/html/wp-content/uploads to S3
cat <<EOF > /root/s3sync.sh
cd /var/www/html/wp-content/
aws s3 sync uploads s3://${s3_bucket_static_name}/wp-content/uploads/ --delete
EOF

chmod +x /root/s3sync.sh
/root/s3sync.sh

cat <<EOF >> /etc/crontab
*/5 * * * * root /root/s3sync.sh
EOF
