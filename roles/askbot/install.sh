
echo "Installing packages..."
#xargs pkg install -y >/dev/null 2>&1 <<EOF
xargs pkg install -y <<EOF
databases/py-memcached
databases/py-psycopg2
databases/py-redis
databases/py-south
devel/py-anyjson
devel/py-lxml
devel/py-pytz
devel/py-simplejson
devel/py-virtualenv
devel/py-yaml
ftp/py-curl
graphics/py-pillow
net/py-amqplib
net/py-kombu
devel/py-billiard
devel/py-celery
textproc/py-libxml2
textproc/py-libxslt
databases/py-sqlparse
www/py-django15
devel/py-Jinja2
textproc/py-MarkupSafe
devel/py-akismet
www/py-beautifulsoup
textproc/py-chardet
converters/py-unidecode
databases/py-south
devel/py-billiard
graphics/py-pillow
devel/py-lockfile
devel/py-daemon

www/py-httplib2
www/py-html5lib
security/py-openid
textproc/py-markdown2
net/py-oauth2
devel/py-six
devel/py-mock
devel/py-nose
EOF
