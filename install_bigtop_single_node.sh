#!/bin/bash

usage() {
    echo "usage: $(basename $0) --spark-version <spark version>"
    echo "    where:"
    echo "        <spark version> is one of [\"1.6.2\", \"2.0.1\"]"
    exit 1;
}

while [ ! -z $1 ]; do
    case "$1" in
        --spark-version ) shift; SPARK_VERSION=$1 ;;
        * ) usage ;;
    esac
    shift
done

if [ -z $SPARK_VERSION ]; then
    usage
fi

set -ex
./install_bigtop_master.sh --spark-version $SPARK_VERSION

sudo service hadoop-hdfs-datanode start
sudo service spark-worker start

