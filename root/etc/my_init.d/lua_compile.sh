#! /bin/bash

CPU_COUNT=$(grep -c processor /proc/cpuinfo)

time \
  find \
  /etc/nginx \
  /usr/local/share/lua/5.1 \
  -type f -iname '*.lua' \
  |sed -e 's,\.lua,,g' \
  |xargs -P${CPU_COUNT} -L1 -I{} luajit-2.1.0-beta3 -O3 -bg {}.lua {}.ljbc


