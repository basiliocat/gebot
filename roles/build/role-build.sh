#!/bin/sh

cat << EOF > /usr/local/etc/poudriere.conf
FREEBSD_HOST=http://update.domain.tld
RESOLV_CONF=/etc/resolv.conf
BASEFS=/data/build
POUDRIERE_DATA=/data/poudriere/data
#USE_PORTLINT=no
USE_TMPFS=no
DISTFILES_CACHE=/data/distfiles
CHECK_CHANGED_OPTIONS=verbose
#CHECK_CHANGED_DEPS=yes
#PKG_REPO_SIGNING_KEY=/usr/local/etc/poudriere.d/pkg.pem
PARALLEL_JOBS=2
ALLOW_MAKE_JOBS=yes
NOLINUX=yes
EOF

zfs create -o mountpoint=/data/poudriere tank/poudriere
zfs create tank/poudriere/distfiles

mkdir -p /data/poudriere/data
mkdir -p /data/logs/cron


cat << EOF >> /etc/newsyslog.conf
/data/logs/cron/*.log                644  14    *    @T00   JGB
EOF

cat << EOF >> /var/cron/tabs/root
SHELL=/bin/sh
#0       4      *       *       0      /data/bin/rebuild.sh >> /data/logs/cron/rebuild.log 2>&1
EOF

#poudriere ports -c
#poudriere jails -c -j 10amd64 -v 10.0-RELEASE -a amd64
#poudriere jails -u -j 10amd64
#poudriere bulk -j 10amd64 -f /usr/local/etc/poudriere.d/pkg-10amd64.list

echo "Poudriere installed"

