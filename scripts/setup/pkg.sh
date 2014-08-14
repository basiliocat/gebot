if [ `uname` = "FreeBSD" ]; then
    ASSUME_ALWAYS_YES=1 pkg bootstrap
    sed -i '' -e 's/enabled: yes/enabled: no/' /etc/pkg/FreeBSD.conf
    confdir=/usr/local/etc/pkg/repos
    [ ! -d $confdir ] && mkdir -p $confdir
    cat > $confdir/20.rnd.conf <<EOT
rnd: {
  url: "http://pkg.domain.tld/\${ABI}/10amd64-default",
  enabled: yes
}
EOT
fi
