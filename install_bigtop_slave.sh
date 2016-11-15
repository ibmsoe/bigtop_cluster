#!/bin/bash

usage() {
    echo "usage: $(basename $0) --spark-version <spark version> --master <master hostname>"
    echo "    where:"
    echo "        <spark version> is one of [\"1.6.2\", \"2.0.1\"]"
    echo "        <master hostname> is the hostname of the master node"
    exit 1;
}

while [ ! -z $1 ]; do
    case "$1" in
        --spark-version ) shift; SPARK_VERSION=$1 ;;
        --master )  shift; MASTERNODE=$1 ;;
        * ) usage ;;
    esac
    shift
done

if [[ -z $SPARK_VERSION || -z $MASTERNODE ]]; then
    usage
fi

set -ex
./install_nodes.sh $SPARK_VERSION $MASTERNODE
./update_conf.sh $SPARK_VERSION $MASTERNODE $MASTERNODE

#sudo sed -i s/localhost/$1/ /etc/hadoop/conf/core-site.xml
./wait_for_hdfs.sh $MASTERNODE
sudo service hadoop-hdfs-datanode start
# sudo service hadoop-yarn-nodemanager start
sudo service spark-worker start

sudo chmod -R 1777 /tmp



