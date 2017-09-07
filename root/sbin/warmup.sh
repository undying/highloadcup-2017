#! /bin/bash

function http_get(){
  local url=${1}
  local host=${url%%/*}
  local uri=${url#*/}

  exec 3<> /dev/tcp/${host}/80

  printf "GET /${uri} HTTP/1.1\r\n" >&3
  printf "Host: localhost\r\n" >&3
  printf "Connection: close\r\n\r\n" >&3

  3>&-
}

until test -e /run/nginx.pid ;do sleep 1;done

for n in users locations visits;do
  printf "warming: ${n}\n"
  for i in {1..2000};do
    http_get 127.0.0.1/${n}/${i} &
  done
done

