#!/bin/bash
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


wrk_dir=$PWD
if [ ! -d source  ] ; then
mkdir source; cd $_

if [ $HOSTTYPE = "powerpc64le" ] ; then
# wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages-ppc64le/BUILD_ENVIRONMENTS=ubuntu-16.04-ppc64le,COMPONENTS=zeppelin,label=ppc64le-slave/lastSuccessfulBuild/artifact/output/zeppelin/zeppelin_0.5.6-1_all.deb
 wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages-ppc64le/BUILD_ENVIRONMENTS=ubuntu-16.04-ppc64le,COMPONENTS=spark,label=ppc64le-slave/lastSuccessfulBuild/artifact/*zip*/archive.zip
 unzip archive.zip; mv archive/output/spark/*.deb .; rm -rf archive; rm archive.zip
fi
if [ $HOSTTYPE = "x86_64" ] ; then
# wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages/BUILD_ENVIRONMENTS=ubuntu-16.04,COMPONENTS=zeppelin,label=docker-slave/lastSuccessfulBuild/artifact/output/zeppelin/zeppelin_0.5.6-1_all.deb
 wget https://ci.bigtop.apache.org/job/Bigtop-trunk-packages/BUILD_ENVIRONMENTS=ubuntu-16.04,COMPONENTS=spark,label=docker-slave/lastSuccessfulBuild/artifact/*zip*/archive.zip
 unzip archive.zip; mv archive/output/spark/*.deb .; rm -rf archive; rm archive.zip
fi

fi

sudo RUNLEVEL=1 apt-get install -y hadoop hadoop-client hadoop-hdfs hadoop-yarn* hadoop-mapred* hadoop-conf* libhdfs_* 


cd $wrk_dir/source
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


#sudo sed -i s/localhost/$HOSTNAME/ /etc/hadoop/conf/core-site.xml
sudo chown -R $USER:hadoop /usr/lib/hadoop*
sudo chown -R hdfs:hadoop /var/log/hadoop-hdfs*
sudo chown -R yarn:hadoop /var/log/hadoop-yarn*
sudo chown -R mapred:hadoop /var/log/hadoop-mapred*
sudo chown -R $USER:hadoop /etc/hadoop
#./update-conf.sh $HOSTNAME $HOSTNAME
