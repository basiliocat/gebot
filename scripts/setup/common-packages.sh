if [ `uname` = "FreeBSD" ]; then
    echo -n "Installing packages..."
    xargs pkg install -y >/dev/null 2>&1 <<EOT && echo ok || echo FAILED
zabbix22-agent
curl
sudo
mc
EOT
    [ ! -e /etc/rc.conf ] && touch /etc/rc.conf

    echo "packages installed"
fi
