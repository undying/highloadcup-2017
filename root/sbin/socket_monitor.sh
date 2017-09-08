#! /bin/bash

while :;do
  printf "redis sockets in use: %d\n" $(ss -x|grep -c redis)
  sleep 10
done

