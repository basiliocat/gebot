suffix=`ifconfig | grep inet | grep -v 127.0.0 | head -n 1 | cut -d ' ' -f 2 | cut -d '.' -f 4`
pw groupadd pgsql$suffix -g 5$suffix
pw useradd pgsql$suffix -u 5$suffix -c "Postgresql user for .$suffix" -g 5$suffix -s /bin/sh -m
grep -q "postgresql_user=" /etc/rc.conf || cat <<EOT >> /etc/rc.conf
postgresql_user="pgsql$suffix"
EOT

