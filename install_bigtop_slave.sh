#!/bin/bash
set -ex

./install_nodes.sh $1
./update_conf.sh $1 $1

#sudo sed -i s/localhost/$1/ /etc/hadoop/conf/core-site.xml
./wait_for_hdfs.sh $1
sudo service hadoop-hdfs-datanode start
# sudo service hadoop-yarn-nodemanager start
sudo service spark-worker start

sudo chmod -R 1777 /tmp



