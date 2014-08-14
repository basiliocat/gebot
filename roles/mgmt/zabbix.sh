echo -n "Installing zabbix..."
xargs pkg install -y >/dev/null 2>&1 <<EOT && echo ok || echo FAILED
zabbix22-server
zabbix22-frontend
EOT
