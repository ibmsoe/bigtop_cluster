#!/bin/bash

if [ -z $BENCH_HOME ]; then
    export BENCH_HOME="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BENCH_HOME}/bench-env.sh
set +a

ENV_SRC=${BENCH_HOME}/spark-bench/conf/env.sh.template
ENV_DST=${BENCH_HOME}/spark-bench/conf/env.sh

cp ${ENV_SRC} ${ENV_DST}
sed -i -e "s/master=\/YOUR\/MASTER/master=\`hostname\`/" ${ENV_DST}
sed -i -e "s/MC_LIST=\/YOUR\/SLAVES/MC_LIST=\"${CLUSTER_NODES}\"/" ${ENV_DST}
sed -i -e "s/:9000/:8020/" ${ENV_DST}
