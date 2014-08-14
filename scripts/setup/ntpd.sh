
ntpd_ip=`host ntp.domain.tld | cut -d ' ' -f 4`
ifconfig | sed -rne 's/^.*inet (addr:)?([0-9\.]+) .*$/\2/p' | grep -Eq "^$ntpd_ip\$" && exit


cat << EOT > /etc/ntp.conf
#
# $FreeBSD: release/10.0.0/etc/ntp.conf 259975 2013-12-27 23:13:38Z delphij $
#
server ntp.domain.tld iburst
restrict default ignore
restrict ntp.domain.tld noquery
restrict 127.0.0.1
driftfile /var/db/ntp.drift
EOT

os=`uname`
if [ "$os" = "FreeBSD" ]; then
    sed -i '' -e '/^ntpd_/d' /etc/rc.conf
    cat << EOT >> /etc/rc.conf
ntpd_enable="YES"
ntpd_sync_on_start="YES"
EOT
    /etc/rc.d/ntpd start
fi
if [ "$os" = "Linux" ]; then
    chkconfig ntpd on
    /etc/init.d/ntpd start
fi

echo "ntpd configured"
