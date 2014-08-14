#!/bin/sh

hostname=`hostname`
#[ ! -e /usr/local/etc/nginx/conf.d/10.uwsgi.conf ] && \
cat > /usr/local/etc/nginx/conf.d/10.uwsgi.conf << EOT
server {
    listen 80;
    server_name $hostname;
    set \$project_root "/data/www/project1";
    root \$project_root;

    charset utf-8;
    access_log  /var/log/nginx/project1.access.log main;
    error_log   /var/log/nginx/project1.error.log;

    set \$static "\$project_root/static/";
    set \$media "\$project_root/media/";

    location / {
        include uwsgi_params;
        default_type text/html;
        uwsgi_pass 127.0.0.1:5003;
    }

    location = /robots.txt {
        alias \$static/robots.txt;
    }

    location = /favicon.ico {
        alias \$static/favicon.ico;
    }

    location /static/ {
        alias \$static;
    }

    location /static/admin/ {
        alias /usr/local/lib/python2.7/site-packages/django/contrib/admin/static/admin/;
    }
}
EOT

