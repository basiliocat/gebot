#!/bin/sh

echo "Configuring nginx ssl..."

[ ! -e /usr/local/etc/nginx/conf.d/02.ssl.conf ] && \
cat > /usr/local/etc/nginx/conf.d/02.ssl.conf << 'EOT'
ssl_certificate      conf.d/cert.pem;
ssl_certificate_key  conf.d/cert.key;
EOT

[ ! -e /usr/local/etc/nginx/conf.d/cert.key ] && \
cat > /usr/local/etc/nginx/conf.d/cert.key << 'EOT'
EOT

[ ! -e /usr/local/etc/nginx/conf.d/cert.pem ] && \
cat > /usr/local/etc/nginx/conf.d/cert.pem << 'EOT'
EOT
