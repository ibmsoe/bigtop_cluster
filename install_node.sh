#!/bin/bash

SPARK_VERSION=$1
MASTERNODE=$2

case $SPARK_VERSION in
    1.6.2 ) SPARK_COMPONENT="spark1" ;;
    2.0.1 ) SPARK_COMPONENT="spark" ;;
    * ) echo "Unsupported spark version: \"$SPARK_VERSION\""; exit 1 ;;
esac

set -ex

sudo apt-get update
sudo apt-get install -y python wget openssl liblzo2-2 openjdk-8-jdk unzip netcat-openbsd apt-utils openssh-server libsnappy1v5 libsnappy-java ntp cpufrequtils
sudo wget -O- http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/GPG-KEY-bigtop | sudo apt-key add -
sudo apt-get update
sudo service ntp start
sudo ufw disable

if [ $HOSTTYPE = "powerpc64le" ] ; then
 sudo wget -O /etc/apt/sources.list.d/bigtop-1.1.0.list  http://bigtop-repos.s3.amazonaws.com/releases/1.1.0/ubuntu/vivid/ppc64el/bigtop.list
fi
if [ $HOSTTYPE = "x86_64" ] ; then
 sudo wget -O /etc/apt/sources.list.d/bigtop-1.1.0.list  http://www.apache.org/dist/bigtop/bigtop-1.1.0/repos/trusty/bigtop.list
fi
sudo apt-get update


pkg_dir=$PWD/pkg_spark-$SPARK_VERSION
if [ ! -d $pkg_dir  ] ; then
mkdir $pkg_dir; cd $_

if [ $HOSTTYPE = "powerpc64le" ] ; then
# wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages-ppc64le/BUILD_ENVIRONMENTS=ubuntu-16.04-ppc64le,COMPONENTS=zeppelin,label=ppc64le-slave/lastSuccessfulBuild/artifact/output/zeppelin/zeppelin_0.5.6-1_all.deb
 wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages-ppc64le/BUILD_ENVIRONMENTS=ubuntu-16.04-ppc64le,COMPONENTS=$SPARK_COMPONENT,label=ppc64le-slave/lastSuccessfulBuild/artifact/*zip*/archive.zip
 unzip archive.zip; mv archive/output/$SPARK_COMPONENT/*.deb .; rm -rf archive; rm archive.zip
fi
if [ $HOSTTYPE = "x86_64" ] ; then
    if [ "$SPARK_COMPONENT" == "spark1" ]; then
        echo "Spark version 1.6.2 temporarily unavailable for $HOSTTYPE"
        exit 1
    fi
# wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages/BUILD_ENVIRONMENTS=ubuntu-16.04,COMPONENTS=zeppelin,label=docker-slave/lastSuccessfulBuild/artifact/output/zeppelin/zeppelin_0.5.6-1_all.deb
 wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages/BUILD_ENVIRONMENTS=ubuntu-16.04,COMPONENTS=$SPARK_COMPONENT,label=docker-slave/lastSuccessfulBuild/artifact/*zip*/archive.zip
 unzip archive.zip; mv archive/output/$SPARK_COMPONENT/*.deb .; rm -rf archive; rm archive.zip
fi

fi

sudo RUNLEVEL=1 apt-get install -y hadoop hadoop-client hadoop-hdfs hadoop-yarn* hadoop-mapred* hadoop-conf* libhdfs_* 


cd $pkg_dir
sudo  RUNLEVEL=1 dpkg -i spark*.deb 
cd .. 



export HADOOP_PREFIX=/usr/lib/hadoop
export HADOOP_HOME=$HADOOP_PREFIX
export JAVA_HOME=`sudo find /usr/ -name java-8-openjdk-*`
export HADOOP_CONF_DIR=/etc/hadoop/conf

echo "export JAVA_HOME=`sudo find /usr/ -name java-8-openjdk-*`" | sudo tee -a  /etc/environment $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf"  | sudo tee -a $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_PREFIX=/usr/lib/hadoop"  | sudo tee -a $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_LIBEXEC_DIR=/usr/lib/hadoop/libexec" | sudo tee -a  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_LOGS=/usr/lib/hadoop/logs"  | sudo tee -a $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_COMMON_HOME=/usr/lib/hadoop" | sudo tee -a  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs" | sudo tee -a  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_MAPRED_HOME=/usr/lib/hadoop-mapreduce" | sudo tee -a $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
echo "export HADOOP_YARN_HOME=/usr/lib/hadoop-yarn" | sudo tee -a $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/yarn-env.sh


sudo chown -R $USER:hadoop /usr/lib/hadoop*
sudo chown -R hdfs:hadoop /var/log/hadoop-hdfs*
sudo chown -R yarn:hadoop /var/log/hadoop-yarn*
sudo chown -R mapred:hadoop /var/log/hadoop-mapred*
sudo chown -R $USER:hadoop /etc/hadoop

# Support $HADOOP_HOME/bin/hdfs
ln -s /usr/bin/hdfs $HADOOP_HOME/bin/hdfs

### Spark configuration
SPARK_LOG_DIR=hdfs:///history_logs
sudo chown -R $USER:hadoop /etc/spark
sed -i '/SPARK_HISTORY_OPTS/d' /etc/spark/conf/spark-env.sh
echo "export SPARK_MASTER_IP=$MASTERNODE" >>/etc/spark/conf/spark-env.sh
echo "export SPARK_HISTORY_OPTS=\"\$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=$SPARK_LOG_DIR -Dspark.history.ui.port=18082\"" >>/etc/spark/conf/spark-env.sh

cp /etc/spark/conf/spark-defaults.conf.template /etc/spark/conf/spark-defaults.conf
echo "spark.master                     spark://$MASTERNODE:7077" >>/etc/spark/conf/spark-defaults.conf
echo "spark.eventLog.enabled           true" >>/etc/spark/conf/spark-defaults.conf
echo "spark.eventLog.dir               $SPARK_LOG_DIR" >>/etc/spark/conf/spark-defaults.conf
echo "spark.yarn.am.memory             1024m" >>/etc/spark/conf/spark-defaults.conf

cp /etc/spark/conf/log4j.properties.template /etc/spark/conf/log4j.properties
echo "log4j.rootCategory=ERROR, console">>/etc/spark/conf/log4j.properties
