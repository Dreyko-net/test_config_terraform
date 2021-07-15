#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
cat << EOF > /var/www/html/health-check-web-server.html
<html>
<body>

</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on
