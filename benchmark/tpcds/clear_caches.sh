#!/bin/bash

if [ -z $CLUSTER_NODES ]; then
    echo "CLUSTER_NODES not found in environment -- caches not cleared."
    exit 1
fi

echo "Clearing cache on all nodes. Enter password for sudo access on each node when prompting..."
for node in ${CLUSTER_NODES}; do
    ssh -t ${node} "echo 3 | sudo tee /proc/sys/vm/drop_caches"
done;
echo "Clearing cache completes"
