#!/bin/bash

if [ -z $BENCH_HOME ]; then
    export BENCH_HOME="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BENCH_HOME}/bench-env.sh
set +a

if [ -z $SPARK_MASTER ]; then
    echo "SPARK_MASTER not found in environment."
    exit 1
fi

${BENCH_HOME}/tpcds/prep_gen_data.sh
${BENCH_HOME}/tpcds/clear_caches.sh

echo "Start to run TPC-DS 10TB data generation. Keep this ssh session alive. Open another ssh session and check the dsgen.scala.out file in ${BENCH_HOME}/tpcds for progress. This step would take around 11 hours on POWER8 and more time on x86..."
spark-shell --master ${SPARK_MASTER} --name dsdgen --conf spark.rdd.compress=true --conf spark.io.compression.codec=snappy --conf spark.network.timeout=900 --conf spark.serializer=org.apache.spark.serializer.KryoSerializer  --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=4 -XX:+AlwaysTenure" --conf spark.default.parallelism=560 --conf spark.sql.shuffle.partitions=280 --conf spark.shuffle.consolidateFiles=true --driver-memory 20g --driver-cores 16 --total-executor-cores 280 --executor-cores 5 --executor-memory 10g --jars ${BENCH_HOME}/spark-sql-perf-0.3.2/target/scala-2.10/spark-sql-perf_2.10-0.3.2.jar -i ${BENCH_HOME}/tpcds/dsgen.scala > ${BENCH_HOME}/tpcds/dsgen.scala.out 2>&1
