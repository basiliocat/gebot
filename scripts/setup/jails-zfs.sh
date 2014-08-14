pkg install -y ezjail
cat << EOT > /usr/local/etc/ezjail.conf
ezjail_jaildir=/data
ezjail_use_zfs="YES"
ezjail_use_zfs_for_jails="YES"
ezjail_jailzfs="tank/data"
EOT

cat << EOT >> /boot/loader.conf
tmpfs_load="YES"
EOT

grep -Eq '^ezjail_enable' /etc/rc.conf || echo 'ezjail_enable="YES"' >> /etc/rc.conf

ezjail-admin install -r 10.0-RELEASE -p
ezjail-admin update -up

kldload tmpfs

[ -d /data/basejail ] && /usr/local/bin/ezjail-admin install
echo "Jails configured"
