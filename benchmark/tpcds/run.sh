#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

if [ -z $SPARK_MASTER ]; then
    echo "SPARK_MASTER not found in environment."
    exit 1
fi

${BIGTOP_BENCH_DIR}/tpcds/clear_caches.sh

query_name=q68

if [ $HOSTTYPE = "powerpc64le" ] ; then
    total_executor_cores=64
    executor_cores=16
    executor_memory=30g
    sql_shuffle_partitions=200
    gcThreads=8
fi
if [ $HOSTTYPE = "x86_64" ] ; then
    total_executor_cores=16
    executor_cores=4
    executor_memory=30g
    sql_shuffle_partitions=200
    gcThreads=4
fi

SPARK_CONFIG_OPTS=(
    --conf spark.shuffle.io.numConnectionsPerPeer=4
    --conf spark.reducer.maxSizeInFlight=128m
    --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=${gcThreads} -XX:+AlwaysTenure"
    --conf spark.sql.shuffle.partitions=${sql_shuffle_partitions}
    --conf spark.shuffle.consolidateFiles=true
    --conf spark.sql.autoBroadcastJoinThreshold=67108864
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer
    --driver-memory 12g
    --driver-cores 16
    --executor-memory ${executor_memory}
    --executor-cores ${executor_cores}
    --total-executor-cores ${total_executor_cores}
)

PATTERN="${query_name}_${total_executor_cores}tc_${executor_cores}ec_${executor_memory}"
SEQ=`ls -lrt ${BIGTOP_BENCH_DIR}/tpcds/${PATTERN}_*.out 2>/dev/null | wc | awk '{print \$1}'`
OUT=${BIGTOP_BENCH_DIR}/tpcds/${PATTERN}_${SEQ}.out

echo "Starting TPC-DS query. Check $OUT for progress."
nohup spark-sql --master ${SPARK_MASTER} --name ${query_name} "${SPARK_CONFIG_OPTS[@]}" --database tpcds10tb -f ${BIGTOP_BENCH_DIR}/tpcds/${query_name}.sql >${OUT} 2>&1 &
