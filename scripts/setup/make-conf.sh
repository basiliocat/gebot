grep -q WITH_PKGNG /etc/make.conf || cat >> /etc/make.conf <<EOT
WITH_PKGNG=YES
EOT

grep -q WRKDIRPREFIX /etc/make.conf || cat >> /etc/make.conf <<EOT
WRKDIRPREFIX=/var/ports
DISTDIR=/var/ports/distfiles
PACKAGES=/var/ports/packages
INDEXDIR=/var/ports
EOT

[ ! -d /var/ports ] && mkdir /var/ports

echo "make.conf modified"
