#!/bin/sh

myip=`ifconfig -l | tr ' ' '\n' | grep -v lo0 | xargs -n 1 ifconfig | grep -F "inet " | head -n 1 | cut -d ' ' -f 2`
pw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
mysql <<EOT
CREATE DATABASE $1 CHARACTER SET utf8 COLLATE utf8_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on $1.* TO $1@$myip IDENTIFIED BY '$pw';
EOT

/usr/local/etc/rc.d/$1 start

echo "$1 configured, mysql $1@$myip/$1, password is $pw"

