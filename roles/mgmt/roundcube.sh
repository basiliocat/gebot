#!/bin/sh

sed -e "s/\$rcmail_config\['default_host'\].*/\$rcmail_config['default_host'] = '10.20.30.40';/" \
    -e "s/\$rcmail_config\['support_url'\].*/\$rcmail_config['support_url'] = 'mailto:support@domain.tld';/" \
    -e "s/\$rcmail_config\['login_lc'\].*/\$rcmail_config['login_lc'] = 2;/" \
    -e "s/\$rcmail_config\['session_lifetime'\].*/\$rcmail_config['session_lifetime'] = 3600;/" \
    -e "s/\$rcmail_config\['plugins'\].*/\$rcmail_config['plugins'] = array(additional_message_headers, jqueryui, newmail_notifier, show_additional_headers, contextmenu);/" \
    /usr/local/www/roundcube/config/main.inc.php.dist > /usr/local/www/roundcube/config/main.inc.php

sed -e "s~\$rcmail_config\['db_dsnw'\].*~$rcmail_config['db_dsnw'] = 'pgsql://roundcube:password@127.0.0.1/roundcube';~" \
    /usr/local/www/roundcube/config/db.inc.php.dist > /usr/local/www/roundcube/config/db.inc.php

cat > /usr/local/etc/fpm.d/roundcube.conf << 'EOT'
[roundcube]
user = nobody
group = nobody
include=etc/fpm.d/common
EOT

cat > /usr/local/etc/nginx/conf.d/15.roundcube.conf << 'EOT'
server {
    listen        10.20.30.40:80;
    server_name   m.domain.tld;
    return https://m.domain.tld$request_uri;
}

server {
    listen        10.20.30.40:443 ssl;
    server_name   m.domain.tld;

    root   /usr/local/www/roundcube;

    include fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
    fastcgi_read_timeout 600;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/roundcube.sock;
    }

    location / {
        index index.php;
    }
}
EOT

