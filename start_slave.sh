#!/bin/bash

#sudo rm -rf /var/lib/hadoop-hdfs/cache/hdfs/dfs/data
sudo service hadoop-hdfs-datanode restart
#sudo service hadoop-yarn-nodemanager restart
sudo service spark-worker restart
