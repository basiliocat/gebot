#!/bin/sh

pw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`

mysql <<EOT
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on zabbix.* TO zabbix@localhost IDENTIFIED BY '$pw';
EOT

cd /usr/local/share/zabbix22/server/database/mysql
mysql zabbix < schema.sql
mysql zabbix < images.sql
mysql zabbix < data.sql

if [ -f /usr/local/etc/zabbix22/zabbix_server.conf.sample ]; then
        sed -E -e "s/^DBUser=.*/DBUser=zabbix/" \
                    -e "/# DBPassword=/a\\
DBPassword=$pw" \
        /usr/local/etc/zabbix22/zabbix_server.conf.sample > /usr/local/etc/zabbix22/zabbix_server.conf
fi

if [ -f /usr/local/www/zabbix22/conf/zabbix.conf.php.example ]; then
        sed -E -e 's/^(\$DB\["PASSWORD"\][ 	]+= '"').*';/\1$pw';/" \
        /usr/local/www/zabbix22/conf/zabbix.conf.php.example > /usr/local/www/zabbix22/conf/zabbix.conf.php
fi

echo "Mysql database zabbix@localhost/zabbix, password is $pw"

