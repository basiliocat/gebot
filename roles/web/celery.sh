#!/bin/sh

echo "Installing celeryd startup script..."

mkdir -p /var/run/celeryd /var/log/celeryd
chown -R project1:project1 /var/run/celeryd /var/log/celeryd

grep -Eq '^celeryd_enable=' /etc/rc.conf || cat >> /etc/rc.conf << EOT
celeryd_enable="YES"
celeryd_chdir="/data/www/project1"
celeryd_workers="25"
EOT

cat > /usr/local/etc/rc.d/celeryd << 'EOT'
#!/bin/sh
# PROVIDE: celeryd
# REQUIRE: DAEMON
# KEYWORD: shutdown

. /etc/rc.subr

name="celeryd"
rcvar=celeryd_enable

load_rc_config $name

: ${celeryd_enable=NO}
: ${celeryd_chdir="/data/www/project1"}
: ${celeryd_workers="25"}
: ${celeryd_user="project1"}
: ${celeryd_pidfile="/var/run/celeryd/celeryd.pid"}
: ${celeryd_logfile="/var/log/celeryd/celeryd.log"}

command="/usr/local/bin/python2.7"
command_args="-m celery worker -D --no-color --concurrency=${celeryd_workers} --pidfile=${celeryd_pidfile} --logfile=${celeryd_logfile} --loglevel=DEBUG --config=settings -A celeryd"
pidfile="${celeryd_pidfile}"
start_precmd="celeryd_precmd"

celeryd_precmd()
{
    export PYTHON_EGG_CACHE=/tmp/.python-eggs
    export PYTHONPATH=..
}

run_rc_command "$1"
EOT
chmod 0755 /usr/local/etc/rc.d/celeryd

grep -Eq '^/var/log/celeryd/' /etc/newsyslog.conf || cat >> /etc/newsyslog.conf << EOT
/var/log/celeryd/celeryd.log	project1:project1	640  30	   *    @T00   JCB   /var/run/celeryd/celeryd.pid 1
EOT


