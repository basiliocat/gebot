#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
java/openjdk7
ftp/curl
x11-fonts/fontconfig
EOT

if [ "$#" -eq "0" ]; then
    # Get latest version
    ver=`curl -s https://my.atlassian.com/download/feeds/current/fisheye.json | tr ',' '\n' | grep '"version":' | head -n 1 | cut -d '"' -f 4`
else
    ver="$1"
fi

mkdir -p /data /data/atlassian-data/fisheye
# add fisheye user
pw groupadd fisheye -g 2002
pw useradd fisheye -u 2002 -c 'Fisheye' -g 2002 -s /bin/sh -d /data/fisheye

echo "Downloading fisheye $ver..."
cd /data
curl -s -L -O http://www.atlassian.com/software/fisheye/downloads/binary/fisheye-$ver.zip
unzip -q fisheye-$ver.zip
rm fisheye-$ver.zip
ln -s fecru-$ver fisheye
# set startup params
grep -Eq '^fisheye_enable=' /etc/rc.conf || echo 'fisheye_enable="YES"' >> /etc/rc.conf

# Change owner
chown -R fisheye:fisheye /data/fecru-$ver /data/atlassian-data/fisheye

# Install startup script
cat > /usr/local/etc/rc.d/fisheye << 'EOT'
#!/bin/sh
# PROVIDE: fisheye
# REQUIRE: DAEMON
# KEYWORD: shutdown

. /etc/rc.subr

name="fisheye"
rcvar=fisheye_enable

load_rc_config $name

: "${fisheye_enable=NO}"
: "${fisheye_dir=/data/atlassian-data/fisheye}"
: "${fisheye_user=fisheye}"
: "${fisheye_group=fisheye}"

export FISHEYE_INST="${fisheye_dir}"
start_cmd="/bin/sh /data/fisheye/bin/start.sh"
stop_cmd="/bin/sh /data/fisheye/bin/stop.sh"


run_rc_command "$1"
EOT
chmod 0755 /usr/local/etc/rc.d/fisheye

[ ! -e /usr/local/etc/nginx/conf.d/30.fisheye.conf ] && \
cat > /usr/local/etc/nginx/conf.d/30.fisheye.conf << 'EOT'
    server {
        listen 80;
        server_name  fisheye.domain.tld;

        client_max_body_size 100m;
        proxy_set_header Host $http_host;
        location ~ ^/rest/|^/rest-service/|^/rest-service-fe/ {
             proxy_pass http://127.0.0.1:8060;
        }
        location / {
            rewrite ^/(.*)$ https://$http_host/$1 redirect;
        }
    }

    server {
        listen 443 ssl;
        server_name  fisheye.domain.tld;

        client_max_body_size 100m;
        location / {
             proxy_set_header Host $http_host;
             proxy_pass http://127.0.0.1:8060;
        }
    }
EOT

echo "Fisheye installed"

