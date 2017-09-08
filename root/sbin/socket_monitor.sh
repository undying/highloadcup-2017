#! /bin/bash

sockets=0

while :;do
  sockets_last=$(ss -x|grep -c redis)
  [ ${sockets_last} -eq ${sockets} ] || printf "redis sockets in use: %d\n" ${sockets_last}

  sockets=${sockets_last}
  sleep 1
done

