#!/bin/bash

HDFS_DEST="/TPCDS-10TB"

sudo -u hdfs hdfs dfs -rm -R -skipTrash ${HDFS_DEST}
sudo -u hdfs hdfs dfs -expunge
sudo -u hdfs hdfs dfs -mkdir ${HDFS_DEST}
sudo -u hdfs hdfs dfs -chown -R ${USER}:hadoop ${HDFS_DEST}
sudo -u hdfs hdfs dfs -mkdir /user/hive
sudo -u hdfs hdfs dfs -chown ${USER} /user/hive
