# patch login.conf - set utf-8 locale
sed -i '' -E -e '/:lang=en_US.UTF-8:\\/d' \
-e '1,/:umask=022:/ {/:umask=022:/i\
\	:lang=en_US.UTF-8:\\
}' -e 's/(:setenv=.*),LANG=en_US.UTF-8/\1/' /etc/login.conf
/usr/bin/cap_mkdb /etc/login.conf


echo "login.conf patched"
