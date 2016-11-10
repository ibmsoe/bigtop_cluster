#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

HDFS_DEST="/SparkBench"
sudo -u hdfs hdfs dfs -rm -R -skipTrash ${HDFS_DEST}
sudo -u hdfs hdfs dfs -expunge
sudo -u hdfs hdfs dfs -mkdir ${HDFS_DEST}
sudo -u hdfs hdfs dfs -mkdir ${HDFS_DEST}/LogisticRegression
sudo -u hdfs hdfs dfs -chown -R ${USER}:hadoop ${HDFS_DEST}/LogisticRegression

cd ${BIGTOP_BENCH_DIR}/spark-bench/LogisticRegression/bin
./gen_data.sh
