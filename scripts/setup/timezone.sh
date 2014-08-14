#/usr/sbin/zic -l /usr/share/zoneinfo/Europe/Moscow 2>&1 >/dev/null
[ -e /etc/localtime ] && rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo "timezone set"
