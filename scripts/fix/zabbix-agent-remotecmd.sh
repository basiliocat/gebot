for i in /usr/local/etc/zabbix/zabbix_agentd.conf /usr/local/etc/zabbix2/zabbix_agentd.conf /usr/local/etc/zabbix22/zabbix_agentd.conf
do
    [ -f "$i" ] && conf="$i"
done
[ -z "$conf" ] && echo "Error: zabbix_agentd.conf was not found!" && exit 1
sed -i '' -E -e "s/ *# *EnableRemoteCommands=[0-1]/EnableRemoteCommands=1/" $conf
if [ `grep -E -c "^EnableRemoteCommands=1" $conf` = 2 ]; then
    echo 2 matches, deleting last
    sed -i '' -E -e '${/EnableRemoteCommands=1/d;}' $conf
fi
/usr/local/etc/rc.d/zabbix_agentd restart
