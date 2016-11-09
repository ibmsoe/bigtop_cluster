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
- Download Install and Configuration Scripts
On each node do:
```
$git clone -b app-poc https://github.com/ibmsoe/bigtop_cluster.git
```
or
``` 
$wget https://github.com/ibmsoe/bigtop_cluster/archive/app-poc.zip
$unzip app-poc.xip
```
- (optional) Identify Hard Disks to be allocated for used by Hadoop

    >**WARNING - A distructive operation** 
    >Identify the hard drives available for use for Hadoop cluster. Be sure the disks selected 
    >do not include the operating system boot disk or any other disk you want to preserve.
    >This operation will reformat the disks selected and erase all data. 
    >This has to be done on each node of the cluster.

Step 1 - The following lines describe the process of discovering the disks to use by running lsblk.
You may need the help of your system administrator to select the disk you want to be part of the hdfs file system of the cluster. 
Please run this task on the masternode and each of the datanodes.
```
$ sudo  lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    1 931.5G  0 disk 
├─sda1   8:1    1     7M  0 part 
├─sda2   8:2    1 893.8G  0 part /
└─sda3   8:3    1  37.7G  0 part [SWAP]
sdb      8:16   1 931.5G  0 disk 
sdc      8:32   1   5.5T  0 disk 
sdd      8:48   1   5.5T  0 disk 
sde      8:64   1   5.5T  0 disk 
sdf      8:80   1   5.5T  0 disk 
sdg      8:96   1   5.5T  0 disk 
sdh      8:112  1   5.5T  0 disk 
sdi      8:128  1   5.5T  0 disk 
sdj      8:144  1   5.5T  0 disk 
sdk      8:160  1   5.5T  0 disk 
sdl      8:176  1   5.5T  0 disk 
sdm      8:192  1   5.5T  0 disk 
sr0     11:0    1  1024M  0 rom  
sr1     11:1    1  1024M  0 rom  
sr2     11:2    1  1024M  0 rom  
sr3     11:3    1  1024M  0 rom  
```
**Note**: "sda" is being used for the OS, so it cannot be used but all the 5.5T disks [ sdc .... sdm] are good candidates in this case. 

Step 2 - Edit or create ~/bigtop_cluster/disk-list file to include one drive per line, for example:
```
$ cat disk-list.example
sdb
sdc
sdd
sde
sdf
sdg
sdh
sdi
sdj
sdk
sdl
sdm
```

  
### Hadoop/Spark Installation

- Update the update-conf.sh script with the specific parameters for the cluster and replicate this updated version to each node.
- master node - execute install_bigtop_master.sh
- on each slave node - execute install_bigtop_slave.sh {master node's hostname}

