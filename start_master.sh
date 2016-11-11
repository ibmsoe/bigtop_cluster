#!/bin/bash

sudo service hadoop-hdfs-namenode restart
#sudo service hadoop-yarn-resourcemanager restart
#sudo service hadoop-mapreduce-historyserver restart
sudo service spark-master.sh restart
sudo service spark-history-server restart
#sudo -u zeppelin /usr/lib/zeppelin/bin/zeppelin-daemon.sh restart
