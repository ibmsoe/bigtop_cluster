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
sudo -u hdfs hdfs dfs -mkdir -p ${HDFS_DEST}/LogisticRegression

cd ${BIGTOP_BENCH_DIR}/deps/spark-bench/LogisticRegression/bin
./gen_data.sh
