#! /bin/bash

CPU_COUNT=$(grep -c processor /proc/cpuinfo)
cpu_n=$[CPU_COUNT-1]


taskset -c 0 redis-server /etc/redis.conf

##for i in locations users visits;do
##  taskset -c ${cpu_n} redis-server /etc/redis_${i}.conf
##
##  cpu_n=$[cpu_n - 1]
##  [ ${cpu_n} -ge 0 ] || cpu_n=$[CPU_COUNT - 1]
##done

