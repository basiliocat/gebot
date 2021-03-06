#!/bin/sh

# Download latest 5.1.* mysql connector for Java
cd /data/jira/lib
cfile=`curl -l -s ftp://ftp.fi.muni.cz/pub/mysql/Downloads/Connector-J/ | grep -E '^mysql-connector-java-5\.1\.[0-9]+\.tar\.gz$' | sort | tail -n 1`
sfile=`echo $cfile|cut -d '.' -f 1,2,3`
curl -s -O ftp://ftp.fi.muni.cz/pub/mysql/Downloads/Connector-J/$cfile
tar xzf $cfile --strip-components 1 $sfile/$sfile-bin.jar
# Change owner
chown -R jira:jira /data/jira/lib

echo "Mysql Connector/J installed"

