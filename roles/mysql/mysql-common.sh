#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
databases/mysql56-server
EOT

mkdir -p /data/mysql /data/mysql/tmp
chown -R mysql:mysql /data/mysql
touch /var/log/mysqld.log /var/log/mysqld-slow.log
chown -R mysql:mysql /var/log/mysqld*.log
grep -Eq '^mysql_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
mysql_enable="YES"
mysql_dbdir="/data/mysql"
EOT

grep -Eq '^/var/log/mysqld' /etc/newsyslog.conf || cat >> /etc/newsyslog.conf << 'EOT'
/var/log/mysqld.log		mysql:mysql	600  14    *    $D4   BCJ   /data/mysql/mysql.pid
/var/log/mysqld-slow.log	mysql:mysql	600  14    *    $D4   BCJ   /data/mysql/mysql.pid
EOT

cat > /usr/local/etc/my.cnf << EOT
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/data/mysql/mysqld.pid

[client]
port            = 3306
socket          = /tmp/mysql.sock
loose-default-character-set=utf8

[mysqld]
#skip-slave-start
#skip-networking
skip-external-locking
skip-name-resolve

datadir=/data/mysql
socket=/tmp/mysql.sock
tmpdir=/data/mysql/tmp

query_cache_type=1
query_cache_limit=2M
query_cache_min_res_unit=512
query_cache_size=32M

max_heap_table_size=32M
tmp_table_size=32M

key_buffer_size=256M
sort_buffer_size=2M
read_buffer_size=2M
read_rnd_buffer_size=1M
join_buffer_size=1M

innodb_buffer_pool_size=512M
innodb_log_file_size=100M
innodb_log_buffer_size=8M
innodb_flush_log_at_trx_commit=2
innodb_thread_concurrency=4
innodb_flush_method=O_DIRECT
innodb_file_per_table
transaction-isolation=READ-COMMITTED

thread_stack=262144
thread_concurrency=2
thread_cache_size=16

back_log=128
max_connections=500
max_connect_errors=30
max_allowed_packet=64M
net_buffer_length=256K
net_retry_count=30

log-warnings=2

#general_log
general_log_file = /var/log/mysqld-query.log

slow_query_log
slow_query_log_file = /var/log/mysqld-slow.log
long_query_time=10
EOT

/usr/local/etc/rc.d/mysql-server start
sleep 1

rootpw=`LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10`
/usr/local/bin/mysqladmin -u root password "$rootpw"
cat <<EOT > /root/.my.cnf
[client]
password        = $rootpw
EOT

mysql <<EOT
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOT

echo "MySQL installed, root password is $rootpw"

