#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

${BIGTOP_BENCH_DIR}/tpcds/clear_caches.sh
${BIGTOP_BENCH_DIR}/tpcds/run_single_tpcds_v1.4.sh q68 64 16 30g 200 8
