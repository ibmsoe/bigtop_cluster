#!/bin/bash
set -ex

./install_bigtop_master.sh

sudo service hadoop-hdfs-datanode start
sudo service spark-worker start

