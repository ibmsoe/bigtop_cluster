#!/bin/bash

if [ -z $SPARK_MASTER ]; then
    echo "SPARK_MASTER not found in environment."
    exit 1
fi

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

if [ $# -ne 6 ]; then
    echo "Usage: ./run_single_tpcds_v1.4.sh <query name> <total-executor-cores> <executor-cores> <executor-memory> <sql-shufle-partitions> <# of GC Threads>"
    exit 1
fi

query_name=$1
total_executor_cores=$2
executor_cores=$3
executor_memory=$4
sql_shuffle_partitions=$5
gcThreads=$6

PATTERN="${query_name}_${total_executor_cores}tc_${executor_cores}ec_${executor_memory}"
SEQ=`ls -lrt ${BIGTOP_BENCH_DIR}/tpcds/${PATTERN}_*.out 2>/dev/null | wc | awk '{print \$1}'`
OUT=${BIGTOP_BENCH_DIR}/tpcds/${PATTERN}_${SEQ}.out

echo "Starting TPC-DS query. Check $OUT for progress."
nohup spark-sql --master ${SPARK_MASTER} --conf spark.shuffle.io.numConnectionsPerPeer=4 --conf spark.reducer.maxSizeInFlight=128m --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=${gcThreads} -XX:+AlwaysTenure" --conf spark.sql.shuffle.partitions=${sql_shuffle_partitions} --conf spark.shuffle.consolidateFiles=true --conf spark.sql.autoBroadcastJoinThreshold=67108864 --conf spark.serializer=org.apache.spark.serializer.KryoSerializer --name ${query_name} --driver-memory 12g --driver-cores 16 --total-executor-cores ${total_executor_cores} --executor-cores ${executor_cores} --executor-memory ${executor_memory} --database tpcds10tb -f ${BIGTOP_BENCH_DIR}/tpcds/${query_name}.sql >${OUT} 2>&1 &
