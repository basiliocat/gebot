#!/bin/sh

[ ! -d /usr/local/etc/fpm.d ] && mkdir /usr/local/etc/fpm.d

[ ! -d /var/log/php-fpm ] && mkdir /var/log/php-fpm && chown www:www /var/log/php-fpm && chmod 0777 /var/log/php-fpm
[ ! -d /var/run/php-fpm ] && mkdir /var/run/php-fpm && chown www:www /var/run/php-fpm

grep -Eq '^php_fpm_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
php_fpm_enable="YES"
EOT

cat > /usr/local/etc/php-fpm.conf << 'EOT'
include=etc/fpm.d/*.conf
[global]
pid = /var/run/php-fpm.pid
error_log = /var/log/php-fpm/main.error.log
rlimit_core = unlimited
EOT

cat > /usr/local/etc/fpm.d/common << 'EOT'
listen.owner = www
listen.group = www
listen = /var/run/php-fpm/$pool.sock
listen.mode = 0660

pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 10
pm.max_spare_servers = 10

;pm.status_path = /fpm-status

request_terminate_timeout = 10m
request_slowlog_timeout = 1m
slowlog = /var/log/php-fpm/$pool.slow.log

php_admin_value[max_execution_time] = 300
php_flag[display_errors] = off
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 256M
php_admin_value[upload_tmp_dir] = /var/tmp
php_value[session.save_path] = /var/tmp

php_admin_value[error_log] = /var/log/php-fpm/$pool.error.log
php_flag[short_open_tag] = on
php_value[max_input_vars] = 5000
php_admin_value[post_max_size] = 160M
php_admin_value[upload_max_filesize] = 150M
php_value[date.timezone] = 'Europe/Moscow'
EOT

