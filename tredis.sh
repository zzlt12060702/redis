#!/bin/bash
<<END
Author: Tianlin
Modify: 20240428
END
get_src() {
    yum install -y gcc make git &> /dev/null
    git clone https://github.com/zzlt12060702/redis.git /opt/redis
    cd /opt/redis
    make PREFIX=/usr/local/redis install 
    [ $? -ne 0 ] && echo -e "/033[31make failed\033[0m"
    mkdir /usr/local/redis/{run,logs,data,conf}
    cp *.conf /usr/local/redis/conf/
    cp  src/redis-trib.rb /usr/local/redis/bin/
    useradd -r -s /sbin/nologin -M redis
#    cat > /usr/lib/systemd/system/redis.service <<END
## /usr/lib/systemd/system/redis.service
#[Unit]
#Description=Redis unit by Tianlin
#Documentation=https://linjiangyu.com/redis
#After=network-online.target remote-fs.target nss-lookup.target
#Wants=network-online.target 
#
#[Service]
#Type=simple
#PIDFile=/usr/local/redis/run/redis_6379.pid
#ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf --supervised systemd
#ExecReload=/bin/kill -s HUP \$MAINPID
#ExecStop=/bin/kill -s TERM \$MAINPID
#User=redis
#Group=redis
#
#[Install]
#WantedBy=multi-user.target
#END
    #systemctl daemon-reload
    cat > /usr/local/redis/conf/redis.conf <<END
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
pidfile /usr/local/redis/run/redis_6379.pid
loglevel notice
logfile "/usr/local/redis/logs/redis_6379.log"
databases 1
always-show-logo no
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"
locale-collate ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump-6379.rdb
rdb-del-sync-files no
dir /usr/local/redis/data/
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
lazyfree-lazy-user-del no
lazyfree-lazy-user-flush no
oom-score-adj no
oom-score-adj-values 0 200 800
disable-thp yes
appendonly yes
appendfilename "aof-6379"
appenddirname "aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no
save 900 1
save 300 100
save 60 10000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
set-max-listpack-entries 128
set-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
END
    chown -R redis: /usr/local/redis
    #systemctl start redis
    [ $? -eq 0 ] && echo -e "\033[32mSuceessful Initialize Redis Server By $(basename $0) By Tianlin\033[0m"
}

get_src
