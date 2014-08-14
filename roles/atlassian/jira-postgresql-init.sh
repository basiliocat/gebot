#!/bin/sh

myip=`ifconfig -l | tr ' ' '\n' | grep -v lo0 | xargs -n 1 ifconfig | grep -F "inet " | head -n 1 | cut -d ' ' -f 2`
jirapw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
psql -U pgsql template1 -f - <<EOT
CREATE USER jira WITH PASSWORD '$jirapw';
CREATE DATABASE jira WITH OWNER jira ENCODING 'UTF8';
EOT

echo "Postgresql database jira@$myip/jira, password is $jirapw"

