#!/bin/sh

[ ! -x /usr/local/bin/screen ] && remove_screen=1

xargs pkg install -y <<EOT
databases/postgresql92-server
sysutils/screen
EOT

mkdir -p /data/pgdata
chown -R pgsql:pgsql /data/pgdata
grep -Eq '^postgresql_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
postgresql_enable="YES"
postgresql_data="/data/pgdata"
postgresql_initdb_flags="--encoding=utf-8 --locale=en_US.UTF-8 --lc-collate=ru_RU.UTF-8"
EOT

/usr/local/etc/rc.d/postgresql initdb

cat >> /data/pgdata/pg_hba.conf << EOT
host    all             all           10.0.0.0/8              md5
host    all             all           172.16.0.0/12           md5
host    all             all           192.168.0.0/16          md5
EOT

#rootpw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
#cat >> /root/.pgpass << EOT
#localhost:*:*:pgsql:$rootpw
#EOT
#chmod 600 /root/.pgpass

tz=`readlink /etc/localtime | cut -d / -f 5,6`
sed -E -i '' -e "s~^(log_)?timezone ?=.*~\1timezone = '$tz'~" \
        /data/pgdata/postgresql.conf

screen -d -m /usr/local/etc/rc.d/postgresql start
sleep 1
[ "$remove_screen" = "1" ] && pkg delete -y sysutils/screen

echo "PostgreSQL installed"
