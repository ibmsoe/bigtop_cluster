#!/bin/bash

SPARK_VERSION=$1
NAMENODE=$2
RESOURCEMANAGER=$3

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
    suffix=$1
    option_name=$2

    j=1
    value=""
    while read i
    do
        if [ -z $i ]; then continue; fi
        dir_name="file:///hdd${j}/${suffix}"
        if [ -z $value ]; then
            value=${dir_name}
        else
            value=${value}","${dir_name}
        fi
        j=$[$j+1]
    done < disk_list

    change_xml_element $option_name $value "/etc/hadoop/conf/hdfs-site.xml"
}


change_spark_local_dir(){
    suffix=$1

    j=1
    value=""
    while read i
    do
        if [ -z $i ]; then continue; fi
        dir_name="/hdd${j}/${suffix}"
        if [ -z $value ]; then
            value=${dir_name}
        else
            value=${value}","${dir_name}
        fi
        sudo mkdir -p ${dir_name}
        j=$[$j+1]
    done < disk_list

    echo "export SPARK_LOCAL_DIRS=$value" >>/etc/spark/conf/spark-env.sh
}

## Add and init yarn.resourcemanager.address in yarn-site.xml
sed -i s/localhost/$NAMENODE/ /etc/hadoop/conf/core-site.xml
sed -i s/localhost/$RESOURCEMANAGER/ /etc/hadoop/conf/mapred-site.xml

sudo chown -R $USER:hadoop /etc/spark
echo "spark.driver.memory             20g" >>/etc/spark/conf/spark-defaults.conf
echo "spark.driver.cores                8" >>/etc/spark/conf/spark-defaults.conf
echo "spark.default.parallelism       480" >>/etc/spark/conf/spark-defaults.conf

add_element "yarn.resourcemanager.hostname" "$RESOURCEMANAGER" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.address" "$RESOURCEMANAGER:8032" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.resource-tracker.address" "$RESOURCEMANAGER:8031" "/etc/hadoop/conf/yarn-site.xml"
add_element "yarn.resourcemanager.scheduler.address" "$RESOURCEMANAGER:8030" "/etc/hadoop/conf/yarn-site.xml"
add_element "dfs.namenode.datanode.registration.ip-hostname-check" "false" "/etc/hadoop/conf/hdfs-site.xml"


if [ -f disk_list ]; then
    ./prep_disks.sh
    sudo chown -R hdfs:hadoop /hdd*

    change_hdfs_dir "hdfs/name" "dfs.namenode.name.dir"
    change_hdfs_dir "hdfs/data" "dfs.datanode.data.dir"

    change_spark_local_dir "spark/local"
    sudo chown -R spark:spark /hdd*/spark/*
    sudo chmod -R 1777 /hdd*/spark/*
fi

echo "*                soft    nofile          100000" | sudo tee -a  /etc/security/limits.conf
echo "*                hard    nofile          100000" | sudo tee -a  /etc/security/limits.conf


