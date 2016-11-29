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

${BIGTOP_BENCH_DIR}/tpcds/prep_gen_data.sh
${BIGTOP_BENCH_DIR}/tpcds/clear_caches.sh

if [ $HOSTTYPE = "powerpc64le" ] ; then
    parallelism=560
    shuffle_partitions=280
    driver_memory=20g
    driver_cores=16
    executor_memory=10g
    executor_cores=5
    total_executor_cores=280
fi
if [ $HOSTTYPE = "x86_64" ] ; then
    parallelism=320
    shuffle_partitions=200
    driver_memory=20g
    driver_cores=4
    executor_memory=18g
    executor_cores=5
    total_executor_cores=160
fi

SPARK_CONFIG_OPTS=(
    --conf spark.rdd.compress=true
    --conf spark.io.compression.codec=snappy
    --conf spark.network.timeout=900
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer
    --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=4 -XX:+AlwaysTenure"
    --conf spark.default.parallelism=${parallelism}
    --conf spark.sql.shuffle.partitions=${shuffle_partitions}
    --conf spark.shuffle.consolidateFiles=true
    --driver-memory ${driver_memory}
    --driver-cores ${driver_cores}
    --executor-memory ${executor_memory}
    --executor-cores ${executor_cores}
    --total-executor-cores ${total_executor_cores}
)

OUT=${BIGTOP_BENCH_DIR}/tpcds/dsgen.scala.out

echo "Starting TPC-DS data generation. Check ${OUT} for progress."
nohup spark-shell --master ${SPARK_MASTER} --name dsdgen "${SPARK_CONFIG_OPTS[@]}" --jars ${BIGTOP_BENCH_DIR}/deps/spark-sql-perf/target/scala-2.10/spark-sql-perf_2.10-0.3.2.jar -i ${BIGTOP_BENCH_DIR}/tpcds/dsgen.scala >${OUT} 2>&1 &
