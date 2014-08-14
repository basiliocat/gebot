#!/bin/sh

echo "Installing nginx..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
www/nginx
sysutils/logrotate
EOT

mkdir /var/log/nginx
grep -Eq '^nginx_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
nginx_enable="YES"
EOT

#grep -Eq '^/var/log/nginx' /etc/newsyslog.conf || cat >> /etc/newsyslog.conf << EOT
#/var/log/nginx-*.log                            600  7     *    @T00  ZBG   /var/run/nginx.pid 30
#/var/log/nginx/*.log                            600  7     *    @T00  ZBG   /var/run/nginx.pid 30
#EOT

[ ! -d /usr/local/etc/logrotate.d ] && mkdir /usr/local/etc/logrotate.d
[ ! -e /usr/local/etc/logrotate.d/nginx.conf ] && cat > /usr/local/etc/logrotate.d/nginx.conf << EOT
/var/log/nginx/*.log {
  missingok
  notifempty
  delaycompress
  sharedscripts
  postrotate
    test -f /var/run/nginx.pid && pkill -USR1 -F /var/run/nginx.pid
  endscript
}
EOT

cat > /usr/local/etc/nginx/nginx.conf << 'EOT'
user  www;
worker_processes  2;

worker_rlimit_nofile 40000;

#error_log  logs/error.log;
#error_log   /dev/null error;

pid         /var/run/nginx.pid;

events {
    worker_connections  8192;
    use kqueue;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr|$time_local|$msec|$request|'
                      'st=$status|bs=$body_bytes_sent|ref=$http_referer|'
                      'ua=$http_user_agent|host=$scheme://$http_host|'
                      'rt=$upstream_response_time|'
                      'cst=$upstream_cache_status|ust=$upstream_status|'
                      'usaddr=$upstream_addr|gzr=$gzip_ratio';

    sendfile        on;
    keepalive_timeout  5;
    proxy_buffer_size 32k;
    proxy_buffering on;
    proxy_buffers 256 4k;

    include conf.d/*.conf;
}

EOT

[ ! -d /usr/local/etc/nginx/conf.d ] && mkdir /usr/local/etc/nginx/conf.d
