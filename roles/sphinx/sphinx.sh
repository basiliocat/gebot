#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
textproc/sphinxsearch
databases/mysql56-client
EOT

cat > /root/.my.cnf << EOT
[client]
host=127.0.0.1
port=9306
EOT
