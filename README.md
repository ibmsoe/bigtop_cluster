# Apache Bigtop For OpenPOWER

![Alt text](http://www.scientificcomputing.com/sites/scientificcomputing.com/files/openpower_foundation_ml.jpg)
![Alt text](https://cwiki.apache.org/confluence/download/thumbnails/27850921/pb-bigtop.png?version=1&modificationDate=1413827725000&api=v2)
#### This README describes the scripts and tools you can use to get the Apache BigTop v 1.1 bundle up and running quickly with minimum intervention in a multi-node environment.  This README assumes you have Linux system administration knowledge (package installation, network configuration, etc.).
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

##### The following scripts are included in this project:
- install_bigtop_master.sh - Downloads, installs, configures and starts all of the components listed above on master node.
- install_bigtop_slave.sh - Downloads, installs, configures and starts all of the components listed above on slave node.
- status_master.sh - Reports current BigTop component status on master node.
- status_slave.sh - Reports current BigTop component status on slave node.
- start_master.sh - Restarts all BigTop components on master node.
- start_slave.sh - Restarts all BigTop components on slave node.
- sparkTest.sh - A quick workload is provided to verify that Spark is working as desired.
- cleanup.sh - Restores the system to its state prior to running install scripts. Uninstalls the existing Hadoop and Spark packages.

# Let's Start 
### Platform requirements 
- Ubuntu 16.04
- OpenPower or x86 architecture 

### Initial Node prep

*Complete the following steps on each node in the cluster:*

1. Create user account:

        sudo useradd ubuntu -U -G sudo -m
        sudo passwd ubuntu
        su ubuntu
        cd ~

2. Map the nodes

  Edit the `/etc/hosts` file to specify the IP address of each system followed by their host names. For example:

      $ sudo vi /etc/hosts
      192.168.1.1 hadoop-master 
      192.168.1.2 hadoop-slave-1 
      192.168.1.3 hadoop-slave-2
      ...

  **Note:** In the event of a public/private network configuration, you must ensure that each node's system-wide `hostname` reflects the IP address that you wish to use for cluster communication. For example, based on the `/etc/hosts` file example above, you can set the master node's system-wide `hostname` by running the following command:
    
      $ sudo hostnamectl set-hostname hadoop-master

3. Download the scripts in this repository by running the following commands:

        $ git clone -b dev https://github.com/ibmsoe/bigtop_cluster.git

  or

      $ wget https://github.com/ibmsoe/bigtop_cluster/archive/dev.zip
      $ unzip dev.zip

  *cd into the downloaded repository directory to continue.*

4. Identify disks to be used by Hadoop:

      >**WARNING - Destructive operation.**
      >
      >You must identify the hard drives available for use by the Hadoop cluster. You must verify that the disks selected 
      >do not include the operating system boot disk or any other disk you want to preserve.
      >The install script reformats the disks selected and erases all data. 
      >You must complete this process on each node of the cluster.

  1. The following demonstrates the process of discovering the disks to use by running the `lsblk` command.
  You might need help from your system administrator to select the disks that you want to be part of the cluster's hdfs
  file system.

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

    **Note**: An ideal configuration includes as many identically-sized SSD disks as possible. In the example above, `sda` is used for the operating system and therefore, it cannot be used. However, all the 5.5T disks `[sdc ... sdm]` can be used.

  2. Create a new file named `disk_list` that specifies one drive per line. For example:

          $ cat ./disk_list
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

### Hadoop/Spark Installation

- On master node, run the following script:

        $ ./install_bigtop_master.sh --spark-version 1.6.2

- On each slave node, run the following script:

        $ ./install_bigtop_slave.sh --spark-version 1.6.2 --master <hostname-of-masternode>

### Check Status of Hadoop/Spark Services

- On master node, ensure `spark-master`, `spark-history-server` and `hadoop-hdfs-namenode` are active by running the following script:

        $ ./status_master.sh

- On each slave node, ensure `spark-worker` and `hadoop-hdfs-datanode` are active, but running the following script:

        $ ./status_slave.sh

### Benchmark Execution

For detailed instructions on benchmark execution, see the [benchmark](benchmark) directory.
