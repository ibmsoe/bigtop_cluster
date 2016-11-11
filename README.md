# Apache Bigtop For OpenPOWER

![Alt text](http://www.scientificcomputing.com/sites/scientificcomputing.com/files/openpower_foundation_ml.jpg)
![Alt text](https://cwiki.apache.org/confluence/download/thumbnails/27850921/pb-bigtop.png?version=1&modificationDate=1413827725000&api=v2)
#### This README describes scripts and tools to get the Apache BigTop v 1.1 bundle up and running quickly with minimum intervention required in a multi-node environment.  Linux system administration knowledge is assumed (package installation, network configuration, etc.).
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
- install_bigtop_master.sh - Downloads, installs, configures and starts all of the components listed above on master node.
- install_bigtop_slave.sh - Downloads, installs, configures and starts all of the components listed above on slave node.
- status_master.sh - Reports current BigTop component status on master node.
- status_slave.sh - Reports current BigTop component status on slave node.
- start-master.sh - Restarts all BigTop components on master node.
- start-slave.sh - Restarts all BigTop components on slave node.
- sparkTest.sh - A quick workload provided to verify that Spark is working as desired.
- cleanup.sh - Uninstalls existing Hadoop and Spark, Prepares the system for install scripts.

# Lets Start 
### Platform requirements 
- Ubuntu 16.04
- OpenPower or x86 architecture 

### Initial Node prep

*Perform the following steps on each node in the cluster.*

1. Create user account:

        sudo useradd ubuntu -U -G sudo -m
        sudo passwd ubuntu
        su ubuntu
        cd ~

2. Mapping the nodes

  Edit `/etc/hosts`, specify the IP address of each system followed by their host names. For example:

        # sudo vi /etc/hosts
        192.168.1.1 hadoop-master 
        192.168.1.2 hadoop-slave-1 
        192.168.1.3 hadoop-slave-2
        ...

  **Note:** In the event of a public/private network configuration, ensure that each node's `hostname` reflects the IP address over which the cluster services should communicate. For example, on the master node:
    
        $ hostname
        hadoop-master            

3. Download install and configuration scripts:

        $ git clone -b app-poc https://github.com/ibmsoe/bigtop_cluster.git

  or

      $ wget https://github.com/ibmsoe/bigtop_cluster/archive/app-poc.zip
      $ unzip app-poc.zip

  *cd into the downloaded respository directory to continue.*

4. Identify disks and directories to be used by Hadoop:

      >**WARNING - Destructive operation.**
      >
      >Identify the hard drives available for use for Hadoop cluster. Be sure the disks selected 
      >do not include the operating system boot disk or any other disk you want to preserve.
      >This operation will reformat the disks selected and erase all data. 
      >This has to be done on each node of the cluster.

  1. The following lines describe the process of discovering the disks to use by running lsblk.
  You may need the help of your system administrator to select the disk you want to be part of the hdfs
  file system of the cluster.

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

    **Note**: An ideal configuration will specify as many identically-sized SSD disks as possible. In the example above, `sda` is being used for the OS, so it cannot be used, but all the 5.5T disks `[sdc ... sdm]` are good candidates.

  2. Create the a `disk-list` file to include one drive per line, for example:

          $ cat disk-list.example
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

  3. Create the `dir_list_*` files (`dir_list_datanode`, `dir_list_namenode`, `dir_list_spark`) according to your configuration.  Note that each disk specified in the prior step's `disk_list` will be mounted at `/hdd<#>` and thus these files specify the set of directories residing on those disks to provide to the hadoop and spark services.  An ideal configuration will specify one directory on each mounted drive. For example:

          $ cat dir_list_namenode.example
          /hdd1/hdfs/name
          /hdd2/hdfs/name
          /hdd3/hdfs/name
          /hdd4/hdfs/name
          /hdd5/hdfs/name
          /hdd6/hdfs/name
          /hdd7/hdfs/name
          /hdd8/hdfs/name
          /hdd9/hdfs/name
          /hdd10/hdfs/name
          /hdd11/hdfs/name
  
### Hadoop/Spark Installation

- On master node:

        $ ./install_bigtop_master.sh

- On each slave node:

        $ ./install_bigtop_slave.sh <hostname-of-masternode>

### Check Status of Hadoop/Spark Services

- On master node, ensure `spark-master`, `spark-history-server` and `hadoop-hdfs-namenode` are active:

        $ ./status_master.sh

- On each slave node, ensure `spark-worker` and `hadoop-hdfs-datanode` are active:

        $ ./status_slave.sh

### Benchmark Execution

See the [benchmark](benchmark) directory for detailed instructions on benchmark execution.
