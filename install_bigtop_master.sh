#!/bin/bash

usage() {
    echo "usage: $(basename $0) --spark-version <spark version>"
    echo "    where:"
    echo "        <spark version> is one of [\"1.6.2\", \"2.0.2\"]"
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
./install_node.sh $SPARK_VERSION $HOSTNAME
./update_conf.sh $SPARK_VERSION $HOSTNAME $HOSTNAME

### master node only
sudo sed -i s/localhost/$HOSTNAME/ /etc/hadoop/conf/core-site.xml
sudo -u hdfs hdfs namenode -format -force
sudo rm -rf /var/lib/hadoop-hdfs/cache/hdfs/dfs/data
sudo service hadoop-hdfs-namenode start

sudo -u hdfs hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn

#sudo service hadoop-yarn-resourcemanager start
#sudo service hadoop-mapreduce-historyserver start

sudo -u hdfs hadoop fs -mkdir -p /user/$USER
sudo -u hdfs hadoop fs -chown $USER /user/$USER
sudo -u hdfs hadoop fs -mkdir -p /history_logs
sudo -u hdfs hadoop fs -chown -R spark:spark /history_logs
sudo -u hdfs hadoop fs -chmod -R 1777 /history_logs

#for x in `cd /etc/init.d ; ls spark-*` ; do sudo service $x start ; done
sudo service spark-master start
sudo service spark-history-server start

sudo chmod -R 1777 /tmp

