#!/bin/bash

if [ -z $BENCH_HOME ]; then
    export BENCH_HOME="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BENCH_HOME}/bench-env.sh
set +a

HDFS_DEST="/SparkBench"
sudo -u hdfs hdfs dfs -rm -R -skipTrash ${HDFS_DEST}
sudo -u hdfs hdfs dfs -expunge
sudo -u hdfs hdfs dfs -mkdir ${HDFS_DEST}
sudo -u hdfs hdfs dfs -mkdir ${HDFS_DEST}/LogisticRegression
sudo -u hdfs hdfs dfs -chown -R ${USER}:hadoop ${HDFS_DEST}/LogisticRegression

cd ${BENCH_HOME}/spark-bench/LogisticRegression/bin
./gen_data.sh
