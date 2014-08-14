if [ `uname` = "FreeBSD" ]; then
    sed -i '' -e '5,$d' /etc/motd
    echo "motd edited"
fi
