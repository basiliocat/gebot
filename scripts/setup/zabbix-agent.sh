if [ `uname` = "FreeBSD" ]; then
    echo -n "Installing zabbix-agent..."
    xargs pkg install -y >/dev/null 2>&1 <<EOT && echo ok || echo FAILED
zabbix22-agent
EOT
fi
[ -d /etc/zabbix ] && zpath=/etc/zabbix
[ -d /usr/local/etc/zabbix ] && zpath=/usr/local/etc/zabbix
[ -d /usr/local/etc/zabbix2 ] && zpath=/usr/local/etc/zabbix2
[ -d /usr/local/etc/zabbix22 ] && zpath=/usr/local/etc/zabbix22
if [ ! -f $zpath/zabbix_agentd.conf -a -f $zpath/zabbix_agentd.conf.sample ]; then 
    sed -E -e "s/Server(Active)?=127.0.0.1/Server\1=10.20.30.40/" \
                    -e "s/^Hostname=.*/Hostname=`hostname`/" \
                    -e "s/ *# *EnableRemoteCommands=[0-1]/EnableRemoteCommands=1/" \
                    -e 's/^LogFileSize=.*/LogFileSize=10/' \
        $zpath/zabbix_agentd.conf.sample > $zpath/zabbix_agentd.conf
fi
os=`uname`
if [ "$os" = "FreeBSD" ]; then
    grep -Eq '^zabbix_agentd_enable' /etc/rc.conf || echo 'zabbix_agentd_enable="YES"' >> /etc/rc.conf
    /usr/local/etc/rc.d/zabbix_agentd start
fi
if [ "$os" = "Linux" ]; then
    chkconfig zabbix-agentd on
    /etc/init.d/zabbix-agentd start
fi

echo "Zabbix agent installed, configured, started"
