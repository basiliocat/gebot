#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
java/openjdk7
ftp/curl
x11-fonts/fontconfig
EOT

# Get latest version
ver=`curl -s  https://my.atlassian.com/download/feeds/current/jira.json | tr ',' '\n' | grep '"version":' | head -n 1 | cut -d '"' -f 4`
[ -z "$ver" ] && { echo "Failed to get Jira version!"; exit 1; }

mkdir -p /data /data/atlassian-data/jira
# add Jira user
pw groupadd jira -g 2000
pw useradd jira -u 2000 -c 'Jira' -g 2000 -s /bin/sh -d /data/jira
# download Jira
cd /data
echo "Downloading Jira $ver"
curl -s -L -O http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-$ver.tar.gz || { echo "Download failed!"; exit 1; }
tar xzf atlassian-jira-$ver.tar.gz -C /data
rm atlassian-jira-$ver.tar.gz
ln -s atlassian-jira-$ver-standalone jira
# set startup params
sed -i '' -Ee 's/^( +)redirectPort="8443"$/redirectPort="8443" scheme="https" secure="true" proxyPort="443"/' /data/jira/conf/server.xml
sed -i '' -Ee 's/JIRA_USER=.*/JIRA_USER="jira"/' /data/atlassian-jira-$ver-standalone/bin/user.sh
propfile=/data/atlassian-jira-$ver-standalone/atlassian-jira/WEB-INF/classes/jira-application.properties
sed -i '' -e '/^jira.home/d' $propfile
cat >> $propfile << EOT
jira.home=/data/atlassian-data/jira
EOT
sed -i '' -Ee 's~#?JIRA_HOME=.*~JIRA_HOME=/data/atlassian-data/jira~' /data/atlassian-jira-$ver-standalone/bin/setenv.sh
grep -Eq '^jira_enable=' /etc/rc.conf || echo 'jira_enable="YES"' >> /etc/rc.conf

# Change owner
chown -R jira:jira /data/atlassian-jira-$ver-standalone /data/atlassian-data/jira

# Install startup script
cat > /usr/local/etc/rc.d/jira << 'EOT'
#!/bin/sh
# PROVIDE: jira
# REQUIRE: DAEMON
# KEYWORD: shutdown

. /etc/rc.subr

name="jira"
rcvar=jira_enable

load_rc_config $name

: "${jira_enable=NO}"

start_cmd="UID=0 /bin/sh /data/jira/bin/start-jira.sh"
stop_cmd="UID=0 /bin/sh /data/jira/bin/stop-jira.sh"


run_rc_command "$1"
EOT
chmod 0755 /usr/local/etc/rc.d/jira

[ ! -e /usr/local/etc/nginx/conf.d/10.jira.conf ] && \
cat > /usr/local/etc/nginx/conf.d/10.jira.conf << 'EOT'
    server {
        listen 80 default;
        server_name  jira.domain.tld;

        client_max_body_size 100m;
        proxy_set_header Host $http_host;
        location ~ ^/rest/|^/rest-service/|^/rest-service-fe/|^/plugins/servlet/streams|^/rpc/soap/|^/sr/jira.issueviews:searchrequest|^/secure/RunPortlet {
             proxy_pass http://127.0.0.1:8080;
        }
        location / {
            rewrite ^/(.*)$ https://$http_host/$1 redirect;
        }
    }

    server {
        listen 443 ssl;
        server_name  jira.domain.tld;

        client_max_body_size 100m;
        location / {
             proxy_set_header Host $http_host;
             proxy_pass http://127.0.0.1:8080;
        }
    }
EOT
echo "Jira installed"

