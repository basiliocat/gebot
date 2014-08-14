sed -i '' -E -e 's/ServerName .*/ServerName update.domain.tld/' /etc/freebsd-update.conf
sed -i '' -E -e 's/SERVERNAME=.*/SERVERNAME=portsnap.domain.tld/' /etc/portsnap.conf

#freebsd-update cron install
