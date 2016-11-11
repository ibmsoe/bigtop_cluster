#!/bin/bash
NAMENODE=$1
RESOURCEMANAGER=$2

change_xml_element() {
  name=$1
  value=$2
  file=$3
  sed  -i "/<name>$name<\/name>/!b;n;c<value>$value</value>" $file
} 

add_element(){
  name=$1
  value=$2
  xml_file=$3

  CONTENT="<property>\n<name>$name</name>\n<value>$value</value>\n</property>"
  C=$(echo $CONTENT | sed 's/\//\\\//g')
  sed -i -e "/<\/configuration>/ s/.*/${C}\n&/" $xml_file
}

change_hdfs_dir(){
  dir_list=$1
  name=$2
  pre="file://"
  value=""

  while read drive
  do
    value=$pre$drive","$value
  done < $dir_list

  change_xml_element $name $value "/etc/hadoop/conf/hdfs-site.xml"
}


change_spark_local_dir(){

value=""
while read drive
do
   value=$drive","$value
done < $1
echo "export SPARK_LOCAL_DIRS=$value" >>/etc/spark/conf/spark-env.sh

}

## Add and init yarn.resourcemanager.address in yarn-site.xml
sed -i s/localhost/$NAMENODE/ /etc/hadoop/conf/core-site.xml
sed -i s/localhost/$RESOURCEMANAGER/ /etc/hadoop/conf/mapred-site.xml

sudo chown -R $USER:hadoop /etc/spark
echo "spark.driver.memory             20g" >>/etc/spark/conf/spark-defaults.conf
echo "spark.driver.cores                8" >>/etc/spark/conf/spark-defaults.conf
echo "spark.history.fs.logDirectory   hdfs://$NAMENODE:8020/directory" >>/etc/spark/conf/spark-defaults.conf
echo "spark.default.parallelism       480" >>/etc/spark/conf/spark-defaults.conf
#echo "spark.storage.memoryFraction    0.6" >>/etc/spark/conf/spark-defaults.conf
sed -i '/SPARK_HISTORY_OPTS/d' /etc/spark/conf/spark-env.sh
#change_spark_local_dir dir_list_spark

add_element "yarn.resourcemanager.hostname" "$RESOURCEMANAGER" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.address" "$RESOURCEMANAGER:8032" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.resource-tracker.address" "$RESOURCEMANAGER:8031" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.scheduler.address" "$RESOURCEMANAGER:8030" "/etc/hadoop/conf/yarn-site.xml"
add_element "dfs.namenode.datanode.registration.ip-hostname-check" "false" "/etc/hadoop/conf/hdfs-site.xml"


### Apple PoC specific 
./prep-disks.sh
#udo chmod 1777 -R /hdd*
sudo chown -R hdfs:hadoop /hdd*

#if [ "$1" == "$HOSTNAME" ]; then
#  if [ -f dir_list_namenode ]; then cat dir_list_namenode|xargs sudo mkdir -p; fi
  if [ -f dir_list_namenode ]; then change_hdfs_dir dir_list_namenode "dfs.namenode.name.dir" ; fi
#else
#  if [ -f dir_list_datanode ]; then cat dir_list_datanode|xargs sudo mkdir -p; fi
  if [ -f dir_list_datanode ]; then change_hdfs_dir dir_list_datanode "dfs.datanode.data.dir" ; fi
  if [ -f dir_list_spark ]; then change_spark_local_dir dir_list_spark ; fi
  if [ -f dir_list_spark ]; then cat dir_list_spark |xargs sudo mkdir -p; fi
sudo chown -R spark:spark /hdd*/spark/*
sudo chmod -R 1777 /hdd*/spark/* 

#fi 
echo "*                soft    nofile          100000" | sudo tee -a  /etc/security/limits.conf
echo "*                hard    nofile          100000" | sudo tee -a  /etc/security/limits.conf


