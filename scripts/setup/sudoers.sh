if [  -f /usr/local/etc/sudoers ]; then
        sed -i '' -Ee '/^zabbix/d' /usr/local/etc/sudoers
        cat << EOT >> /usr/local/etc/sudoers
zabbix        ALL=(ALL) NOPASSWD: /usr/sbin/mfiutil show *, /usr/sbin/mfiutil drive progress *, /usr/local/bin/nmap *
EOT
        grep -Eq '^%wheel' /usr/local/etc/sudoers || cat << EOT >> /usr/local/etc/sudoers
%wheel ALL=(ALL) ALL
EOT
    echo "sudoers modified"
fi
if [ -f /etc/sudoers ]; then
    echo "Linux suxx"
fi
