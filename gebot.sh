#!/bin/bash
#!/usr/local/bin/bash

if [ $# -lt 2 ]; then
    cat >&2 << EOT
Usage: gebot.sh [-d] [-p] <host|list> [jail] <script|command|book> [args] ...
    Descripton
        Runs script, command, or set of scripts (book) on given host, list of hosts or jail
    Parameters:
        host - IP or name
        list - a file with list of hosts, separated by a new line. Also it can be executable file with .sh extension, it should print list of hosts to stdout
        jail - jail name (as in jail.conf), or jail id (as in jls), running on <host>. Special name _all_ means all running jails
        script - /bin/sh executable script file, with additional parameters [args], script name should end with .sh
        command - single command, it will be executed on <host> (or <jail>, if specified), should be quoted (as single argument)
        book - a file with list of scripts, with optional arguments, separated by a new line. Book name must end with .txt
    Options:
        -d  Turn on script debugging
        -p  Allow password authentication
EOT
    exit 1
fi

control_c()
{
    echo
    echo "==> Ctrl-C pressed. Do you really want to stop processing?"
    echo "==> Pressing n proceeds with other hosts"
    echo "==> Do you want to abort (y/N):"
    read ans
    if [ "$ans" = "Y" -o "$ans" = "y" ]; then
        echo
        echo "Script aborted on user's request!"
        kill $$
    fi
}
trap control_c SIGINT

debug()
{
    [ ! -z "$dbg" ] && echo "[debug] $@" >&2
}

warning()
{
    log "[warning] $@"
}

log()
{
    echo "$@" >&2
    echo "$@" >> $log
}

run_book()
{
    lbook="$1"
    shift
    while read line; do
        [ -n "$line" ] || continue
        if [ "$line" != "${line#\#}" ]; then
            debug "skipping comment $line"
            continue
        fi
        script=${line%% *}
        if [ ! -e "$script" ]; then
            warning "skipping $script, file not found"
            continue
        fi
        if echo $script | grep -Eq '\.txt$'; then
            log "[subbook] $script"
            debug "running subbook $line $@"
            run_book $line $@
        else
            params=${line#$script}
            log "[script] $script"
            debug "running $script $params $@"
            cat $script | ssh $sshopts root@$i "${jexec}/bin/sh $dbg -s" $params $@ | tee -a "$log"
            debug "return code is $?"
        fi
    done < $lbook
}

dbg=""
if [ "$1" = "-d" ]; then
    dbg="-x"
    shift
fi
ssh_nopass="-o NumberOfPasswordPrompts=0 -o PasswordAuthentication=no"
if [ "$1" = "-p" ]; then
    ssh_nopass=""
    shift
fi

if echo "$1" | grep -Eq '\.sh$' && [ -x "$1" ]; then
    debug "host = executable file"
    no_jail=1
    hosts=`$1`
else
    if [ -e "$1" ]; then
        no_jail=1
        debug "host = list file"
        hosts=`cat $1|grep -v '#'`
    else
        no_jail=0
        debug "host = parameter"
        hosts="$1"
    fi
fi
shift

jail=""
jexec=""
if [ "$1" = "_all_" ]; then
    all_jails=1
    debug "jail = all jails"
    shift
else
    all_jails=0
    if [ "$no_jail" -eq "0" ] && echo "$1" | grep -Eq '^[a-z0-9_\-]+$' && [ $# -gt 1 -a ! -e "$1" ]; then
        jail=`echo "$1" | tr '-' '_'`
        jexec="jexec $jail "
        debug "jail = $jail"
        shift
    fi
fi

onecmd=""
book=""
script=""
logprefix=""
if [ ! -e "$1" ]; then
    onecmd="$@"
    debug "onecmd = $onecmd"
else
    if echo $1 | grep -Eq '\.txt$'; then
        book="$1"
    else
        script="$1"
    fi
    logprefix=`echo $1|sed -E -e 's/\.[^\.]*$//' -e 's~(scripts|roles|books)/?~~' -e 's~/+~-~g' -e 's/ [^ ]+//'`"-"
    shift
fi

log=logs/$logprefix`date +%Y.%m.%d-%H:%m:%S`.log
debug "log = $log"

sshopts="-q $ssh_nopass -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=20"
debug "sshopts = $sshopts"

for i in $hosts; do
    msg="[host] $i"
    [ ! -z "$jail" ] && msg="$msg, jail $jail"
    log "$msg"
    if [ ! -z "$jail" ]; then
        if ! ssh $sshopts root@$i ${jexec} true >/dev/null 2>&1; then
            warning "jexec failed - skipping jail $jail on host $i"
            continue
        fi
    fi

    if [ ! -z "$book" ]; then
        debug "running book $book"
        run_book $book $@
    else
        if [ ! -z "$onecmd" ]; then
                debug "command = $onecmd"
                if [ "$all_jails" -eq "1" ]; then
                    echo "$onecmd" | ssh $sshopts root@$i "/bin/sh -c 't=\`mktemp\`; cat > \$t; for jid in \`jls -n jid | cut -d '=' -f 2\`; do echo [jail] \`jls -j \$jid name\`; cat \$t | jexec \$jid /bin/sh $dbg -s; done; rm \$t'"  | tee -a "$log"
                else
                    echo "$onecmd" | ssh $sshopts root@$i ${jexec}/bin/sh $dbg -s  | tee -a "$log"
                fi
        else
                debug "script = $script"
                if [ "$all_jails" -eq "1" ]; then
                    cat $script | ssh $sshopts root@$i "/bin/sh -c 't=\`mktemp\`; cat > \$t; for jid in \`jls -n jid | cut -d '=' -f 2\`; do cat \$t | jexec \$jid /bin/sh $dbg -s $@; done; rm \$t'"  | tee -a "$log"
                else
                    cat $script | ssh $sshopts root@$i "${jexec}/bin/sh $dbg -s" $@ | tee -a "$log"
                fi
        fi
    fi
done
