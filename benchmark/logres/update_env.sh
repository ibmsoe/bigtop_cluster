#!/bin/bash

if [ -z $BIGTOP_BENCH_DIR ]; then
    export BIGTOP_BENCH_DIR="$(cd "`dirname "$0"`"/..; pwd)"
fi

set -a
. ${BIGTOP_BENCH_DIR}/bench-env.sh
set +a

ENV_SRC=${BIGTOP_BENCH_DIR}/spark-bench/conf/env.sh.template
ENV_DST=${BIGTOP_BENCH_DIR}/spark-bench/conf/env.sh

cp ${ENV_SRC} ${ENV_DST}
sed -i -e "s/master=\/YOUR\/MASTER/master=\`hostname\`/" ${ENV_DST}
sed -i -e "s/MC_LIST=\/YOUR\/SLAVES/MC_LIST=\"${CLUSTER_NODES}\"/" ${ENV_DST}
sed -i -e "s/:9000/:8020/" ${ENV_DST}
