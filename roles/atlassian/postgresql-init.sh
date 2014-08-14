#!/bin/sh

[ "$#" -eq "0" ] && echo "ERROR: parameter required" >&2 && exit
myip=`ifconfig -l | tr ' ' '\n' | grep -v lo0 | xargs -n 1 ifconfig | grep -F "inet " | head -n 1 | cut -d ' ' -f 2`
pw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
psql -U pgsql template1 -f - <<EOT
CREATE USER $1 WITH PASSWORD '$pw';
CREATE DATABASE $1 WITH OWNER $1 ENCODING 'UTF8';
EOT

echo "Postgresql database $1@$myip/$1, password is $pw"

