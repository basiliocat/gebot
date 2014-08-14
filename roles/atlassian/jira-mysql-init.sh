#!/bin/sh

myip=`ifconfig -l | tr ' ' '\n' | grep -v lo0 | xargs -n 1 ifconfig | grep -F "inet " | head -n 1 | cut -d ' ' -f 2`
jirapw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
mysql <<EOT
CREATE DATABASE jira CHARACTER SET utf8 COLLATE utf8_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on jira.* TO jira@$myip IDENTIFIED BY '$jirapw';
EOT

echo "Mysql database jira@$myip/jira, password is $jirapw"

