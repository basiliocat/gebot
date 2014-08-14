pkg install -y ezjail
cat << EOT > /usr/local/etc/ezjail.conf
ezjail_jaildir=/data
EOT

grep -Eq '^ezjail_enable' /etc/rc.conf || echo 'ezjail_enable="YES"' >> /etc/rc.conf

ezjail-admin install -r 10.0-RELEASE -p
echo "Updating ports..."
ezjail-admin update -up > /dev/null 2>&1

echo "Installing basejail..."
[ -d /data/basejail ] && /usr/local/bin/ezjail-admin install > /dev/null 2>&1
echo "Jails configured"
