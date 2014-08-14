#!/bin/sh

echo "Installing packages..."
xargs pkg install -y >/dev/null 2>&1 <<EOT
devel/git
databases/redis
devel/subversion
sysutils/flock
www/uwsgi
databases/py-redis
devel/py-celery
devel/py-ordereddict
devel/py-pytz
devel/py-simplejson
graphics/py-imaging
security/py-pycrypto
textproc/py-libxml2
textproc/py-libxslt
www/py-django
lang/python
databases/py-sqlparse
databases/py-MySQLdb
sysutils/logrotate
devel/py-Jinja2
databases/py-south
www/py-beautifulsoup
www/py-html5lib
www/py-django-picklefield
textproc/py-markdown2
net/py-oauth2
EOT

mkdir -p /var/log/uwsgi /data/www/.ssh
pw groupadd project1 -g 2001
pw useradd project1 -u 2001 -c 'Justice project owner' -g 2001 -s /bin/sh -d /data/www
pw groupmod project1 -m www
cat > /data/www/.ssh/authorized_keys << 'EOT'
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzctZAgclYZZfLZbFAjvMbioB65oozoakHQbDlN2Qi2ZDNO7dUrJOtPYIWsmoUuDn8Z2d+Lsrht7PeYc4GyAR8gImYVuOcjMgiz0bb5HAUun+nqdLSngWCPpeyXDY8Hh0jyxpRk4I3VCKQ4c08zGASWbGZECO09h3NW/LwRhqIl8lk6doRWdk80sWYzktBd/Q9dARvinT4rkOC3zurBbDhdGkxY5bQKEYiMoYHx8wFpuRzBjp6XSLLeTL4VkPGnAYsJhb2gxKLuyEfH7ut5oFgXXzPscuzXXbsOepYa13QnsLCvB9leQy2H+w4Jll61Q3zKukftmRVx4R9M/RlVgNVw== project1@production
EOT
chown -R project1:project1 /data/www /var/log/uwsgi

grep -Eq '^uwsgi_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
redis_enable="YES"
uwsgi_enable="YES"
uwsgi_uid="project1"
uwsgi_gid="project1"
uwsgi_logfile="/var/log/uwsgi/uwsgi.log"
uwsgi_flags="--master --die-on-term --ini /usr/local/etc/uwsgi.ini"
EOT

# DEV!!
grep -Eq '^sshd_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
sshd_enable="YES"
EOT

[ ! -e "/usr/local/etc/uwsgi.ini" ] && cat > /usr/local/etc/uwsgi.ini << EOT
[uwsgi]
    socket = 127.0.0.1:5003
    chdir = /data/www/project1
    pythonpath = ..
    env = PYTHON_EGG_CACHE=/tmp
    env = BACKEND_TYPE=PROD
    env = DJANGO_SETTINGS_MODULE=project1.settings
    module = django.core.handlers.wsgi:WSGIHandler()
    touch-reload = /data/www/project1/touch-reload
    workers = 20
    max-requests = 1000
    harakiri = 60
    buffer-size = 16384
    no-orphans = true
    log-date = true
    log-reopen = true

    uid = project1
    gid = project1
EOT

#grep -Eq '^/var/log/uwsgi/' /etc/newsyslog.conf || cat >> /etc/newsyslog.conf << EOT
#/var/log/uwsgi/uwsgi.log	project1:project1	640  30	   *    @T00   JCB   /var/run/uwsgi.pid 1
#EOT
[ ! -d /usr/local/etc/logrotate.d ] && mkdir /usr/local/etc/logrotate.d
[ ! -e "/usr/local/etc/logrotate.d/uwsgi.conf" ] && cat > /usr/local/etc/logrotate.d/uwsgi.conf << EOT
EOT

echo "Python/uwsgi installed"

