#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
net-mgmt/zabbix22-frontend
net-mgmt/zabbix22-server
EOT

grep -Eq '^zabbix_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
zabbix_server_enable="YES"
EOT

[ ! -e /usr/local/etc/nginx/conf.d/10.zabbix.conf ] && \
cat > /usr/local/etc/nginx/conf.d/10.zabbix.conf << 'EOT'
server {
    listen        *:80;
    listen        *:443 ssl;
    server_name   z.domain.tld;

#    rewrite ^/zabbix(.*) https://z.domain.tld$1 redirect;

    root   /usr/local/www/zabbix22;

    include fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
    fastcgi_read_timeout 600;
    client_max_body_size 100M;

    location = /api_jsonrpc.php {
        fastcgi_read_timeout 1800;
        fastcgi_pass unix:/var/run/php-fpm/zabbix.sock;
    }

    location = /index.php {
        sub_filter '<div align="center" class="textcolorstyles"'
            '<script type="text/javascript">window.location = "dashboard.php"</script><div align="center" class="textcolorstyles"';
        fastcgi_pass unix:/var/run/php-fpm/zabbix.sock;
    }

    location = /dashboard.php {
#        set $repl '<script type="text/javascript" src="/pxe/js/dashboard.js"></script></head>';
#        sub_filter '</head>' "$repl";
        fastcgi_pass unix:/var/run/php-fpm/zabbix.sock;
    }

    location = /hosts.php {
#        set $repl '<script type="text/javascript" src="/pxe/js/hosts.js"></script></head>';
#        sub_filter '</head>' "$repl";
        fastcgi_pass unix:/var/run/php-fpm/zabbix.sock;
    }
    location ~ \.php$ {
        sub_filter 'href="http://www.zabbix.com/" target="_blank"' 'href="/"';
        fastcgi_pass unix:/var/run/php-fpm/zabbix.sock;
    }

    location / {
        index index.php;
    }

    access_log  /var/log/nginx/zabbix.access.log;
    error_log   /var/log/nginx/zabbix.error.log;
}
EOT

[ ! -e /usr/local/etc/fpm.d/zabbix.conf ] && \
cat > /usr/local/etc/fpm.d/zabbix.conf << 'EOT'
[zabbix]
user = zabbix
group = zabbix
php_admin_value[memory_limit] = 1024M
php_admin_value[max_input_time] = 300
php_admin_value[max_execution_time] = 300
include=etc/fpm.d/common
EOT

/usr/local/etc/rc.d/php-fpm restart
/usr/local/etc/rc.d/nginx restart

echo "Zabbix server installed"

