mysql <<EOT
grant replication client on *.* to zabbix@localhost identified by 'password_for_zabbix_agentd';
EOT
echo "Granted MySQL access to zabbix@localhost"
