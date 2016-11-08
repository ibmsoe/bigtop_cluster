# Apache Bigtop For OpenPOWER

![Alt text](http://www.scientificcomputing.com/sites/scientificcomputing.com/files/openpower_foundation_ml.jpg)
![Alt text](https://cwiki.apache.org/confluence/download/thumbnails/27850921/pb-bigtop.png?version=1&modificationDate=1413827725000&api=v2)
#### This README describes scripts and tools to get the Apache BigTop v 1.1 bundle up and running quickly with minimum intervention required in both single node and multi nodes environment.
##### The goal of this project is to automate download, install, and configuration of the following components:
- Java Open JDK 1.8 
- Apache Bigtop  v1.1+ 
  * Hadoop  v2.7.1
  * Spark  v1.6.2 (from Bigtop v1.2.0)
  * Zeppelin  v0.5.6
  * Bigtop-groovy  v2.4.4
  * jsvc  v1.0.15
  * Tomcat  v6.0.36
  * Apache Zookeeper  v3.4.6
- Scala  v2.10.4
- python
- openssl
- snappy
- lzo

##### A Brief Outline of scripts included in this project and their function follows:
-	install_bigtop_single_node.sh - Downloads, installs, configures, and starts all of the components listed above in a single node configuration.
-	install_bigtop_master.sh - Downloads, installs, configures, and starts all of the components listed above in master node.
-	install_bigtop_slave.sh - Downloads, installs, configures, and starts all of the components listed above in slave node.
-   cleanup.sh - Uninstall existing Hadoop and Spark, Prepares the system for the install_bigtop.sh.
-	restart-master.sh - A convenient way to restart all BigTop components in master node.
-	restart-slave.sh - A convenient way to restart all BigTop components in slave node.
-	Status.sh - JPS does not automatically produce the component status. This script will report BigTop component current status.
-	sparkTest.sh - A quick workload provided to verify that Spark is working as desired.
-	hadoopTest.sh - A quick test script to aid in verifying the Hadoop configuration.

# Lets Start 
### Platform requirements 
- Ubuntu 16.04
- OpenPower or x86 architecture 

### Initial Node prep
- Creating User Account in All Nodes - 
```
sudo useradd ubuntu -U -G sudo -m
sudo passwd ubuntu
su ubuntu
cd ~
```
- Mapping the nodes - You have to edit hosts file in /etc/ folder on ALL nodes, specify the IP address of each system followed by their host names. Example
```
# sudo vim /etc/hosts
Append the following lines in the /etc/hosts file.
192.168.1.1 hadoop-master 
192.168.1.2 hadoop-slave-1 
192.168.1.3 hadoop-slave-2
.....
.....
```
### Hadoop/Spark Installation
- Create all the directories on each system for the HDFS and YARN directories
- Set proper permissions on the directories
- Update the update-conf.sh script with the specific parameters for the cluster and replicate this updated version to each node.
- master node - execute install_bigtop_master.sh
- on each slave node - execute install_bigtop_slave.sh {master node's hostname}

