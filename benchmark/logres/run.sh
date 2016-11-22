#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

SPARK_CONFIG_OPTS=(
    --conf spark.rdd.compress=false
    --conf spark.network.timeout=600
    --conf spark.hadoop.dfs.blocksize=512m
    --conf spark.shuffle.consolidateFiles=true
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer
    --conf spark.executor.extraJavaOptions=\"-XX:ParallelGCThreads=20 -XX:+AlwaysTenure\"
    --conf spark.default.parallelism=480
    --executor-memory 200g
    --executor-cores 40
    --total-executor-cores 160
)
export SPARK_OPTS="${SPARK_CONFIG_OPTS[@]}"

cd ${BIGTOP_BENCH_DIR}/deps/spark-bench/LogisticRegression/bin
./run.sh
