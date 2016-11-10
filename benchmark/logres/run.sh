#!/bin/bash

if [ -z $BENCH_HOME ]; then
    export BENCH_HOME="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BENCH_HOME}/bench-env.sh
set +a

cd ${BENCH_HOME}/spark-bench/LogisticRegression/bin
./run.sh
