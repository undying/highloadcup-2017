#! /bin/bash -x

DATA_FILE=/tmp/data/data.zip
DATA_DIR=/tmp/data_unpack

install -d ${DATA_DIR}
test -f ${DATA_FILE} || exit 0

unzip -od ${DATA_DIR} ${DATA_FILE}

