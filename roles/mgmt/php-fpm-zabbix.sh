#!/bin/sh

cat > /usr/local/etc/fpm.d/zabbix.conf << 'EOT'
[zabbix]
user = zabbix
group = zabbix
php_admin_value[memory_limit] = 2048M
include=etc/fpm.d/common
EOT

cat > /usr/local/etc/nginx/conf.d/10.zabbix.conf << 'EOT'
server {
    listen        80 default;
    listen        443 ssl;
    server_name   zabbix.domain.tld;

    rewrite ^/zabbix(.*) https://zabbix.domain.tld$1 redirect;

    root   /usr/local/www/zabbix22;

    include fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
    fastcgi_read_timeout 600;

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

}
EOT

