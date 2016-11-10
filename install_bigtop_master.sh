#!/bin/bash
set -ex
./install_nodes.sh $HOSTNAME
./update-conf.sh $HOSTNAME $HOSTNAME
### master node onlly
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
sudo -u hdfs hadoop fs -mkdir -p /directory
sudo -u hdfs hadoop fs -chown -R spark:hadoop /directory
sudo -u hdfs hdfs dfs -chmod -R 1777 /directory
sudo -u hdfs hdfs dfs -mkdir -p  /var/log/spark/apps
sudo -u hdfs hdfs dfs -chown -R $USER:hadoop /var/log/spark

#for x in `cd /etc/init.d ; ls spark-*` ; do sudo service $x start ; done
sudo service spark-master start
sudo service spark-history-server start

#cd source
#sudo RUNLEVEL=1 dpkg -i zeppelin_0.5.6-1_all.deb
#sudo sed -i -e 's|yarn-client|spark://$(hostname):7077|g' /etc/zeppelin/conf/zeppelin-env.sh
#sudo sed -i -e 's|ZEPPELIN_PORT=8080|ZEPPELIN_PORT=8888|g' /etc/zeppelin/conf/zeppelin-env.sh
#echo "export ZEPPELIN_JAVA_OPTS=\"-Dspark.executor.memory=1G -Dspark.cores.max=4\"" |sudo tee -a /etc/zeppelin/conf/zeppelin-env.sh
#cd ~ 
sudo chmod -R 1777 /tmp
#sudo -u hdfs hdfs dfs -mkdir /user/zeppelin
#sudo -u hdfs hdfs dfs -chown -R zeppelin /user/zeppelin
#sudo chown -R zeppelin.  /var/log/zeppelin
#sudo chown -R zeppelin.  /var/run/zeppelin
#sudo rm /etc/zeppelin/conf.dist/interpreter.json
#rm -rf source
#sudo -u zeppelin /usr/lib/zeppelin/bin/zeppelin-daemon.sh restart

