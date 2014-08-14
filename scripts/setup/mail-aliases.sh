sed -i '' -e '/^root:/d' /etc/mail/aliases
echo "root: admin@domain.tld" >> /etc/mail/aliases
/usr/bin/newaliases
chmod a+r /etc/mail/aliases.db

echo "root mail alias added"
