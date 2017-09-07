#! /bin/bash

CPU_COUNT=$(grep -c processor /proc/cpuinfo)
DATA_PATH=/tmp/data_unpack/
IMPORTER=/opt/import.lua

for port in 16379;do
  until redis-cli -p ${port} info > /dev/null;do
    sleep 1
  done
done

time \
  find ${DATA_PATH} -type f \
  | xargs -L${CPU_COUNT} -P$[CPU_COUNT*2] luajit-2.1.0-beta3 ${IMPORTER}

