suffix=`ifconfig | grep inet | grep -v 127.0.0 | head -n 1 | cut -d ' ' -f 2 | cut -d '.' -f 4`
pw groupdel pgsql
pw userdel pgsql
pw groupadd pgsql -g 5$suffix
pw useradd pgsql -u 5$suffix -c "Postgresql user for .$suffix" -g 5$suffix -s /bin/sh -d /usr/local/pgsql
chown -R 5$suffix:5$suffix /usr/local/pgsql
chown -R 5$suffix:5$suffix /data/mfid?
[ -d /data/pgdata ] && chown -R 5$suffix:5$suffix /data/pgdata

