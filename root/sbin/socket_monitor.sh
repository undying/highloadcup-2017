#! /bin/bash

unix_sockets=0
tcp_sockets=0

while :;do
  unix_sockets_last=$(ss -x|grep -c redis)
  tcp_sockets_last=$(ss -et dst :16379|wc -l)

  [ ${unix_sockets_last} -eq ${unix_sockets} ] || printf "redis unix sockets in use: %d\n" ${unix_sockets_last}
  [ ${tcp_sockets_last} -eq ${tcp_sockets} ] || printf "redis tcp sockets in use: %d\n" ${tcp_sockets_last}

  unix_sockets=${unix_sockets_last}
  tcp_sockets=${tcp_sockets_last}

  sleep 2
done

