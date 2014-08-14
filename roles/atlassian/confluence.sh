#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
java/openjdk7
ftp/curl
x11-fonts/fontconfig
EOT

# Get latest version
ver=`curl -s https://my.atlassian.com/download/feeds/current/confluence.json | tr ',' '\n' | grep '"version":' | head -n 1 | cut -d '"' -f 4`

mkdir -p /data /data/atlassian-data/confluence
# add Confluence user
pw groupadd confluence -g 2001
pw useradd confluence -u 2001 -c 'Confluence' -g 2001 -s /bin/sh -d /data/confluence

echo "Downloading confluence $ver..."
cd /data
curl -s -L -O http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$ver.tar.gz
tar xzf atlassian-confluence-$ver.tar.gz -C /data
rm atlassian-confluence-$ver.tar.gz
ln -s atlassian-confluence-$ver confluence
# set startup params
sed -i '' -Ee 's/redirectPort="8443"/redirectPort="8443" scheme="https" secure="true" proxyPort="443"/' /data/confluence/conf/server.xml
sed -i '' -Ee 's/CONF_USER=.*/CONF_USER="confluence"/' /data/confluence/bin/user.sh
propfile=/data/confluence/confluence/WEB-INF/classes/confluence-init.properties
sed -i '' -e '/^confluence.home/d' $propfile
cat >> $propfile << EOT

confluence.home=/data/atlassian-data/confluence
EOT
grep -Eq '^confluence_enable=' /etc/rc.conf || echo 'confluence_enable="YES"' >> /etc/rc.conf

# Change owner
chown -R confluence:confluence /data/atlassian-confluence-$ver /data/atlassian-data/confluence

# Install startup script
cat > /usr/local/etc/rc.d/confluence << 'EOT'
#!/bin/sh
# PROVIDE: confluence
# REQUIRE: DAEMON
# KEYWORD: shutdown

. /etc/rc.subr

name="confluence"
rcvar=confluence_enable

load_rc_config $name

: "${confluence_enable=NO}"

start_cmd="UID=0 /bin/sh /data/confluence/bin/start-confluence.sh"
stop_cmd="UID=0 /bin/sh /data/confluence/bin/stop-confluence.sh"


run_rc_command "$1"
EOT
chmod 0755 /usr/local/etc/rc.d/confluence

[ ! -e /usr/local/etc/nginx/conf.d/20.confluence.conf ] && \
cat > /usr/local/etc/nginx/conf.d/20.confluence.conf << 'EOT'
    server {
        listen 80;
        server_name  confluence.domain.tld;

        client_max_body_size 100m;
        proxy_set_header Host $http_host;
        location ~ ^/rest/|^/rest-service/|^/rest-service-fe/ {
             proxy_pass http://127.0.0.1:8090;
        }
        location / {
            rewrite ^/(.*)$ https://$http_host/$1 redirect;
        }
    }

    server {
        listen 443 ssl;
        server_name  confluence.domain.tld;

        client_max_body_size 100m;
        location / {
             proxy_set_header Host $http_host;
             proxy_pass http://127.0.0.1:8090;
        }
    }
EOT


echo "Confluence installed"

