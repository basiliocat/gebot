[ ! -e /etc/unbound/unbound.conf ] && cat > /etc/unbound/unbound.conf <<EOF
server:
     directory: "/etc/unbound"
     username: unbound
     chroot: "/etc/unbound"
     pidfile: "/etc/unbound/unbound.pid"
     interface: 0.0.0.0
     access-control: 10.0.0.0/8 allow
EOF
grep -Eq '^local_unbound_enable=' /etc/rc.conf || echo 'local_unbound_enable="YES"' >> /etc/rc.conf
/etc/rc.d/local_unbound start
