#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

${BIGTOP_BENCH_DIR}/tpcds/clear_caches.sh

echo "Start to run TPC-DS query. Keep this ssh seesion alive. Open another ssh session and check the .nohup in ${BIGTOP_BENCH_DIR}/tpcds for progress. This step would take around 9 minutes on POWER8 and more time on x86..."

${BIGTOP_BENCH_DIR}/tpcds/run_single_tpcds_v1.4.sh q68 64 16 30g 200 8
