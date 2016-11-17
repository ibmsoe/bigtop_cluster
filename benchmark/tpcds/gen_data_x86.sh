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

OUT=${BIGTOP_BENCH_DIR}/tpcds/dsgen.scala.out

echo "Starting TPC-DS data generation. Check ${OUT} for progress."
nohup spark-shell --master ${SPARK_MASTER} --name dsdgen  --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=4 -XX:+AlwaysTenure" --conf spark.rdd.compress=true --conf spark.io.compression.codec=snappy --conf spark.network.timeout=900 --conf spark.serializer=org.apache.spark.serializer.KryoSerializer --conf spark.default.parallelism=320 --conf spark.sql.shuffle.partitions=200 --conf spark.shuffle.consolidateFiles=true --driver-memory 20g --driver-cores 4 --total-executor-cores 160 --executor-cores 5 --executor-memory 18g --jars ${BIGTOP_BENCH_DIR}/spark-sql-perf-0.3.2/target/scala-2.10/spark-sql-perf_2.10-0.3.2.jar -i ${BIGTOP_BENCH_DIR}/tpcds/dsgen.scala >${OUT} 2>&1 &
