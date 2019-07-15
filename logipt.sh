#!/bin/bash
#
# Logging all packets handled by iptables
# Copyright 2019 donizyo

IPT="/sbin/iptables"

# Flush all chains, delete user-defined chains
# and zero all statistics in specified table
del() {
    table=$1
    $IPT -t $table -F
    $IPT -t $table -X
    $IPT -t $table -Z
}

# Log all packets in specified table and chain
log() {
    table=$1
    chain=$2
    $IPT -t $table -A $chain -j LOG \
        --log-level 4 \
        --log-prefix "[iptables][$table:$chain]"
}

#==================================
#
# Erase all chains and rules

del raw
del mangle
del nat
del filter

#==================================

log raw     PREROUTING
log mangle  PREROUTING
log nat     PREROUTING

log mangle  INPUT
log filter  INPUT
log nat     INPUT

log mangle  FORWARD
log filter  FORWARD

log raw     OUTPUT
log mangle  OUTPUT
log nat     OUTPUT
log filter  OUTPUT

log mangle  POSTROUTING
log nat     POSTROUTING

#==================================

LOGFILE_PATH=/var/log/iptables.log

# Redirect all log messages generated by iptables
# to specified logfile
cat > /etc/rsyslog.d/10-iptables.conf <<- EOF
# Log kernel generated iptables log messages to file
:msg,contains,"[iptables]" -$LOGFILE_PATH
& ~
EOF

service rsyslog restart

cat > /etc/logrotate.d/iptables <<- EOF
$LOGFILE_PATH {
    rotate 15
    daily
    missingok
    notifempty
    delaycompress
    compress
    dateext
    copytruncate
    postrotate
    invoke-rc.d rsyslog rotate > /dev/null
    endscript
}
EOF

rm -f $LOGFILE_PATH
touch $LOGFILE_PATH
chown syslog:adm $LOGFILE_PATH
/etc/init.d/rsyslog restart
