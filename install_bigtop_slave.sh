#!/bin/bash
set -ex
./install_nodes.sh $1
sudo sed -i s/localhost/$1/ /etc/hadoop/conf/core-site.xml
./wait_for_hdfs.sh $1
sudo service hadoop-hdfs-datanode start
# sudo service hadoop-yarn-nodemanager start



### Spark configuration 
echo "export SPARK_MASTER_IP=$1"  |sudo tee -a /etc/spark/conf/spark-env.sh
sudo chown -R $USER:hadoop /etc/spark
cp /etc/spark/conf/spark-defaults.conf.template /etc/spark/conf/spark-defaults.conf
echo "spark.master                     spark://$1:7077" >>/etc/spark/conf/spark-defaults.conf
echo "spark.eventLog.enabled           true" >>/etc/spark/conf/spark-defaults.conf
echo "spark.eventLog.dir               hdfs://$1:8020/directory" >>/etc/spark/conf/spark-defaults.conf
echo "spark.yarn.am.memory             1024m" >>/etc/spark/conf/spark-defaults.conf

cp /etc/spark/conf/log4j.properties.template /etc/spark/conf/log4j.properties
echo "log4j.rootCategory=ERROR, console">>/etc/spark/conf/log4j.properties


sudo service spark-worker start

sudo chmod -R 1777 /tmp



