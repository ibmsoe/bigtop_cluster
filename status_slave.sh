#!/bin/bash

#### BigTOP Services Status
GREEN='\033[0;32m'
NC='\033[0m' # No Color
printf ">>>> ${GREEN}Apache BigTop Spark${NC} Services Status\n"
systemctl -l --type service -all | grep spark-worker
printf ">>>> ${GREEN}Apache BigTop Hadoop-HDFS${NC} Services Status\n"
systemctl -l --type service -all | grep -i hadoop-hdfs-datanode
#printf ">>>> ${GREEN}Apache BigTop Hadoop-MAPREDUCE${NC} Services Status\n"
#systemctl -l --type service -all | grep -i hadoop-map
printf ">>>> ${GREEN}Apache BigTop HADOOP-YARN${NC} Services Status\n"
systemctl -l --type service -all | grep -i hadoop-yarn-nodemanager
#service hadoop-yarn-resourcemanager status
#service hadoop-yarn-nodemanager status
#service hadoop-mapreduce-historyserver status
#service hadoop-yarn-timelineserver status

