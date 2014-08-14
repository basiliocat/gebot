#!/bin/sh

echo "Installing RabbitMQ..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
net/rabbitmq
EOT
grep -Eq '^rabbitmq_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
rabbitmq_enable="YES"
EOT

/usr/local/etc/rc.d/rabbitmq start

sleep 10
#rabbitmqctl delete_user guest
rabbitmq-plugins enable rabbitmq_management
rabbitmqctl add_user project1_rabbit password
rabbitmqctl set_permissions -p / project1_rabbit ".*" ".*" ".*"
#rabbitmqctl add_user guest
#rabbitmqctl set_permissions guest ".*" ".*" ".*"
/usr/local/etc/rc.d/rabbitmq stop
sleep 10
/usr/local/etc/rc.d/rabbitmq start
