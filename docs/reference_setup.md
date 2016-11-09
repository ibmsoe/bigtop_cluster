#### I. On each node:
- unpack tarball
- format local drives, mount at `/hdd<#>` and add entry to `/etc/fstab` [mount.sh]
- setup `/etc/hosts`
- setup ssh keys for `guest` user

#### II. Master node setup as `guest` user _[setup_master.sh]_
1. install requisite packages _[pkg_req.sh]_

        openjdk-8-jdk openjdk-8-jdk-headless openjdk-8-dbg unzip maven libgfortran3 ntp cpufrequtils cmake make openssh-server ethtool clustershell spheres

2. create directories _[namenode_dir.sh / dir_list_namenode]_:

        /hdd1/hdfs/name, /hdd2/hdfs/name, /hdd3/hdfs/name, /hdd4/hdfs/name, /hdd5/hdfs/name, /hdd6/hdfs/name, /hdd7/hdfs/name, /hdd8/hdfs/name
        /hdd1/hdfs/namesecond, /hdd2/hdfs/namesecond, /hdd3/hdfs/namesecond, /hdd4/hdfs/namesecond, /hdd5/hdfs/namesecond, /hdd6/hdfs/namesecond, /hdd7/hdfs/namesecond, /hdd8/hdfs/namesecond
        /home/spark/hdfs
        /home/spark/hadoop/hdfs
        /home/spark/hadoop/temp
        /var/log/spark
        /var/run/spark
        /hdd1/spark/local, /hdd2/spark/local, /hdd3/spark/local, /hdd4/spark/local, /hdd5/spark/local, /hdd6/spark/local, /hdd7/spark/local, /hdd8/spark/local

3. set hostname according to spark.*lab name in `/etc/hosts` _[set_hostname.sh]_
4. copy limits _[copy_limit_conf.sh]_
  - /etc/security/limits.conf
  
          hdfs                soft    nofile          100000
          hdfs                hard    nofile          100000
          spark                soft    nofile          100000
          spark                hard    nofile          100000
          root                soft    nofile          100000
          root                hard    nofile          100000

  - /etc/sysctl.conf
  
          net.ipv6.conf.all.disable_ipv6 = 1
          net.ipv6.conf.default.disable_ipv6 = 1
          net.ipv6.conf.lo.disable_ipv6 = 1
          
5. create `hadoop` group and `spark` and `hdfs` users _[create_user.sh]_
6. modify `.bashrc` for `spark` and `hdfs` users _[env.sh]_

        export SPARK_HOME=/opt/spark-1.6.2/
        export HADOOP_HOME=/opt/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el
        export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
        export HADOOP_PREFIX=$HADOOP_HOME
        export HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec
        export HADOOP_LOGS=$HADOOP_HOME/logs
        export HADOOP_COMMON_HOME=$HADOOP_HOME
        export HADOOP_HDFS_HOME=$HADOOP_HOME
        export HADOOP_MAPRED_HOME=$HADOOP_HOME
        export HADOOP_YARN_HOME=$HADOOP_HOME
        export HADOOP_HOME=$HADOOP_HDFS_HOME
        export HADOOP_USER_NAME=hdfs
        export HADOOP_GROUP=hadoop
        export HADOOP_NAMENODE=sparkmasterlab
        export HADOOP_SECONDARYNODE=sparkmasterlab
        export HADOOP_RESOURCEMANAGER=sparkmasterlab
        export PATH=$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$JAVA_HOME/jre/bin:$JAVA_HOME/bin:$PATH
        export LD_LIBRARY_PATH=/opt/hadoop/lib/native:/opt/hadoop/lib/native/lib:$LD_LIBRARY_PATH

6. install spark, hadoop and benchmarks _[install_spark.sh]_
  1. unpack spark tarball into `/opt/spark-1.6.2`.  The following configuration resides in `/opt/spark-1.6.2/conf`:
    1. symlink from `master` to `/opt/hadoop/etc/hadoop/master`
    2. symlink from `slaves` to `/opt/hadoop/etc/hadoop/slaves`
    3. spark-env.sh
    
            export HADOOP_CONF_DIR=/opt/hadoop//etc/hadoop
            export SPARK_LOCAL_DIRS="/hdd1/spark/local,/hdd2/spark/local,/hdd3/spark/local,/hdd4/spark/local,/hdd5/spark/local,/hdd6/spark/local,/hdd7/spark/local,/hdd8/spark/local"
            export SPARK_CONF_DIR=/opt/spark-1.6.2/conf
            export SPARK_LOG_DIR=/var/log/spark
            
    4. spark-defaults.conf
    
            spark.master                    spark://sparkmasterlab:7077
            spark.driver.memory             20g
            spark.driver.cores              8
            spark.eventLog.enabled          true
            spark.eventLog.dir              hdfs://sparkmasterlab:8020/history_logs
            spark.history.fs.logDirectory   hdfs://sparkmasterlab:8020/history_logs
            spark.default.parallelism       480
            spark.storage.memoryFraction    0.6
            
  2. unpack hadoop tarball into `/opt/hadoop`.  The following configuration resides in `/opt/hadoop/etc/hadoop`:
    1. master
    
            sparkmasterlab
            
    2. slaves
    
            sparkslavelab1
            sparkslavelab2
            sparkslavelab3
            sparkslavelab4

    3. core-site.xml
    
            <configuration>
               <property>
                  <name>fs.defaultFS</name>
                  <value>hdfs://sparkmasterlab:8020</value>
               </property>
            </configuration>
	    
    4. hdfs-site.xml
    
            <configuration>
               <property>
                 <name>hadoop.tmp.dir</name>
                 <value>/tmp/hadoop-${user.name}</value>
               </property>
               <property>
                  <name>dfs.namenode.name.dir</name>
                  <value>file:///hdd1/hdfs/name,file:///hdd2/hdfs/name,file:///hdd3/hdfs/name,file:///hdd4/hdfs/name,file:///hdd5/hdfs/name,file:///hdd6/hdfs/name,file:///hdd7/hdfs/name,file:///hdd8/hdfs/name</value>
               </property>
               <property>
                  <name>dfs.namenode.checkpoint.dir</name>
                  <value>file:///hdd1/hdfs/namesecond,file:///hdd2/hdfs/namesecond,file:///hdd3/hdfs/namesecond,file:///hdd4/hdfs/namesecond,file:///hdd5/hdfs/namesecond,file:///hdd6/hdfs/namesecond,file:///hdd7/hdfs/namesecond,,file:///hdd8/hdfs/namesecond</value>
               </property>
               <property>
                  <name>dfs.datanode.data.dir</name>
                  <value>file:///hdd1/hdfs/data,file:///hdd2/hdfs/data,file:///hdd3/hdfs/data,file:///hdd4/hdfs/data,file:///hdd5/hdfs/data,file:///hdd6/hdfs/data,file:///hdd7/hdfs/data,file:///hdd8/hdfs/data</value>
               </property>
            </configuration>

    5. yarn-site.xml
    
            <configuration>
               <property>
                  <description>The hostname of the RM.</description>
                  <name>yarn.resourcemanager.hostname</name>
                  <value>sparkmasterlab</value>
               </property>
               <property>
                  <name>yarn.resourcemanager.resourcetracker.address</name>
                  <value>sparkmasterlab:8020</value>
                  <description>Enter your ResourceManager hostname.</description>
               </property>
               <property>
                  <name>yarn.resourcemanager.address</name>
                  <value>sparkmasterlab:8091</value>
                  <description>Enter your ResourceManager hostname.</description>
               </property>
               <property>
                  <name>yarn.resourcemanager.webapp.address</name>
                  <value>sparkhab1.aus.stglabs.ibm.com:8088</value>
               </property>
               <property>
                  <name>yarn.nodemanager.aux-services</name>
                  <value>mapreduce_shuffle</value>
               </property>
               <property>
                  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
                  <value>org.apache.hadoop.mapred.ShuffleHandler</value>
               </property>
               <property>
                  <name>yarn.resourcemanager.scheduler.class</name>
                  <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
               </property>
               <property>
                  <name>yarn.nodemanager.resource.memory-mb</name>
                  <value>100000</value>
                  <description>Amount of physical memory, in MB, that can be allocated for containers.</description>
               </property>
               <property>
                  <name>yarn.nodemanager.resource.cpu-vcores</name>
                  <value>80</value>
                  <description>Number of vcores that can be allocated                                                                                                                                                                                     
                  for containers. This is used by the RM scheduler when allocating                                                                                                                                                                        
                  resources for containers. This is not used to limit the number of                                                                                                                                                                       
                  physical cores used by YARN containers.</description>
               </property>
               <property>
                  <name>yarn.nodemanager.vmem-pmem-ratio</name>
                  <value>2.1</value>
               </property>
               <property>
                  <name>yarn.nodemanager.local-dirs</name>
                  <value>/hdd1/hdfs/yarn1,/hdd2/hdfs/yarn2,/hdd3/hdfs/yarn3,/hdd4/hdfs/yarn4,/hdd5/hdfs/yarn5,/hdd6/hdfs/yarn6,/hdd7/hdfs/yarn7,/hdd8/hdfs/yarn8 </value>
               </property>
               <property>
                  <name>yarn.scheduler.minimum-allocation-mb</name>
                  <value>1024</value>
               </property>
               <property>
                  <name>yarn.scheduler.maximum-allocation-mb</name>
                  <value>200000</value>
               </property>
            </configuration>

    6. yarn-env.sh
    
            export HADOOP_YARN_USER=${HADOOP_YARN_USER:-yarn}
            export YARN_CONF_DIR="${YARN_CONF_DIR:-$HADOOP_YARN_HOME/conf}"
            export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el/jre
            if [ "$JAVA_HOME" != "" ]; then
              JAVA_HOME=$JAVA_HOME
            fi
            if [ "$JAVA_HOME" = "" ]; then
              echo "Error: JAVA_HOME is not set."
              exit 1
            fi
            JAVA=$JAVA_HOME/bin/java
            JAVA_HEAP_MAX=-Xmx1000m
            
            if [ "$YARN_HEAPSIZE" != "" ]; then
              JAVA_HEAP_MAX="-Xmx""$YARN_HEAPSIZE""m"
            fi
            
            IFS=
            
            if [ "$YARN_LOG_DIR" = "" ]; then
              YARN_LOG_DIR="$HADOOP_YARN_HOME/logs"
            fi
            if [ "$YARN_LOGFILE" = "" ]; then
              YARN_LOGFILE='yarn.log'
            fi
            if [ "$YARN_POLICYFILE" = "" ]; then
              YARN_POLICYFILE="hadoop-policy.xml"
            fi
            
            unset IFS
            
            YARN_OPTS="$YARN_OPTS -Dhadoop.log.dir=$YARN_LOG_DIR"
            YARN_OPTS="$YARN_OPTS -Dyarn.log.dir=$YARN_LOG_DIR"
            YARN_OPTS="$YARN_OPTS -Dhadoop.log.file=$YARN_LOGFILE"
            YARN_OPTS="$YARN_OPTS -Dyarn.log.file=$YARN_LOGFILE"
            YARN_OPTS="$YARN_OPTS -Dyarn.home.dir=$YARN_COMMON_HOME"
            YARN_OPTS="$YARN_OPTS -Dyarn.id.str=$YARN_IDENT_STRING"
            YARN_OPTS="$YARN_OPTS -Dhadoop.root.logger=${YARN_ROOT_LOGGER:-INFO,console}"
            YARN_OPTS="$YARN_OPTS -Dyarn.root.logger=${YARN_ROOT_LOGGER:-INFO,console}"
            if [ "x$JAVA_LIBRARY_PATH" != "x" ]; then
              YARN_OPTS="$YARN_OPTS -Djava.library.path=$JAVA_LIBRARY_PATH"
            fi
            YARN_OPTS="$YARN_OPTS -Dyarn.policy.file=$YARN_POLICYFILE"

    7. mapred-site.xml
    
            <configuration>
               <property>
                  <name>mapreduce.framework.name</name>
                  <value>yarn</value>
               </property>
               <property>
                  <name>mapreduce.jobhistory.address</name>
                  <value>sparkmasterlab:10020</value>
                  <description>Enter your JobHistoryServer hostname.</description>
               </property>
               <property>
                  <name>mapreduce.jobhistory.webapp.address</name>
                  <value>sparkmasterlab:19888</value>
                  <description>Enter your JobHistoryServer hostname.</description>
               </property>
               <property>
                  <name>mapreduce.framework.name</name>
                  <value>yarn</value>
               </property>
               <property>
                  <name>mapreduce.map.java.opts</name>
                  <value>-Xms2048m -Xmx2048m -server -XX:+UseParallelOldGC -XX:ParallelGCThreads=8 -XX:ConcGCThreads=2 -XX:+UseAdaptiveSizePolicy -XX:+PrintTenuringDistribution -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintAdaptiveSizePolicy -Xloggc:$HADOOP_HOME/temp/java_ParOld.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=2048K -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dfile.encoding=UTF-8 -Djava.io.tmpdir=$HADOOP_HOME/temp -verbose:gc </value>
               </property>
               <property>
                  <name>mapreduce.reduce.java.opts</name>
                  <value>-Xms2048m -Xmx2048m -server -XX:+UseParallelOldGC -XX:ParallelGCThreads=8 -XX:ConcGCThreads=2 -XX:+UseAdaptiveSizePolicy -XX:+PrintTenuringDistribution -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintAdaptiveSizePolicy -Xloggc:$HADOOP_HOME/temp/java_ParOld.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=2048K -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dfile.encoding=UTF-8 -Djava.io.tmpdir=$HADOOP_HOME/temp -verbose:gc</value>
               </property>
               <property>
                  <name>mapreduce.map.memory.mb</name>
                  <value>2458</value>
               </property>
               <property>
                  <name>mapreduce.reduce.memory.mb</name>
                  <value>2458</value>
               </property>
               <property>
                  <name>mapreduce.task.io.sort.mb</name>
                  <value>800</value>
               </property>
               <property>
                  <name>mapreduce.task.io.sort.factor</name>
                  <value>200</value>
               </property>
               <property>
                  <name>mapreduce.reduce.shuffle.parallelcopies</name>
                  <value>40</value>
               </property>
               <property>
                  <name>mapreduce.tasktracker.http.threads</name>
                  <value>40</value>
               </property>
               <property>
                  <name>mapreduce.map.speculative</name>
                  <value>false</value>
               </property>
               <property>
                  <name>mapreduce.output.fileoutputformat.compress</name>
                  <value>false</value>
               </property>
               <property>
                  <name>mapreduce.output.fileoutputformat.compress.type</name>
                  <value>BLOCK</value>
               </property>
               <property>
                  <name>mapreduce.map.log.level</name>
                  <value>WARN</value>
               </property>
               <property>
                  <name>mapreduce.reduce.log.level</name>
                  <value>WARN</value>
               </property>
               <property>
                  <name>mapreduce.job.jvm.numtasks</name>
                  <value>-1</value>
               </property>
               <property>
                  <name>mapreduce.reduce.input.buffer.percent</name>
                  <value>0.80</value>
               </property>
               <property>
                  <name>mapreduce.reduce.shuffle.merge.percent</name>
                  <value>0.80</value>
               </property>
               <property>
                  <name>mapreduce.reduce.shuffle.input.buffer.percent</name>
                  <value>0.70</value>
               </property>
               <property>
                  <name>mapreduce.job.reduce.slowstart.completedmaps</name>
                  <value>0.99</value>
               </property>
            </configuration>

    8. mapred-env.sh
   
            export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el/jre
            export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=1000
            export HADOOP_MAPRED_ROOT_LOGGER=INFO,RFA
                
    9. hadoop-env.sh
    
            export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el
            export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}
            
            for f in $HADOOP_HOME/contrib/capacity-scheduler/*.jar; do
              if [ "$HADOOP_CLASSPATH" ]; then
                export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$f
              else
                export HADOOP_CLASSPATH=$f
              fi
            done
            
            export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"
            export HADOOP_NAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_NAMENODE_OPTS"
            export HADOOP_DATANODE_OPTS="-Dhadoop.security.logger=ERROR,RFAS $HADOOP_DATANODE_OPTS"
            export HADOOP_SECONDARYNAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_SECONDARYNAMENODE_OPTS"
            export HADOOP_NFS3_OPTS="$HADOOP_NFS3_OPTS"
            export HADOOP_PORTMAP_OPTS="-Xmx512m $HADOOP_PORTMAP_OPTS"
            export HADOOP_CLIENT_OPTS="-Xmx512m $HADOOP_CLIENT_OPTS"
            export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER}
            export HADOOP_SECURE_DN_LOG_DIR=${HADOOP_LOG_DIR}/${HADOOP_HDFS_USER}
            export HADOOP_PID_DIR=${HADOOP_PID_DIR}
            export HADOOP_SECURE_DN_PID_DIR=${HADOOP_PID_DIR}
            export HADOOP_IDENT_STRING=$USER

  3. unpack benchmark tarballs into `/home/spark` [spark-bench, spark-sql-perf-0.3.2, tpcds, tpcds-kit]
        
7. fix permissions _[permission.sh]_

        sudo chown -R hdfs.hadoop /hdd*/*
        sudo chmod -R 775 /hdd*/*
        sudo chown -R spark.hadoop /opt/spark* /var/log/spark /var/run/spark /hdd*/spark
        sudo chown -R hdfs.hadoop /opt/hadoop*
        sudo chmod -R 775 /opt/spark*
        sudo chown -R spark.hadoop /home/spark
        sudo chmod -R 755 /home/spark
        sudo chown -R hdfs.hadoop /home/hdfs
        sudo chmod -R 755 /home/hdfs

#### III. Datanode setup as `guest` user _[setup_datanode.sh]_
1. install requisite packages _[pkg_req.sh]_ **(identical to master node setup)**
2. create `hadoop` group and `spark` and `hdfs` users _[create_user.sh]_ **(identical to master node setup)**
3. create directories _[datanode_dir.sh / dir_datanode_list]_:

        /hdd1/hdfs/data, /hdd2/hdfs/data, /hdd3/hdfs/data, /hdd4/hdfs/data, /hdd5/hdfs/data, /hdd6/hdfs/data, /hdd7/hdfs/data, /hdd8/hdfs/data
		/hdd1/hdfs/yarn1, /hdd2/hdfs/yarn2, /hdd3/hdfs/yarn3, /hdd4/hdfs/yarn4, /hdd5/hdfs/yarn5, /hdd6/hdfs/yarn6, /hdd7/hdfs/yarn7, /hdd8/hdfs/yarn8
		/hdd1/spark/local, /hdd2/spark/local, /hdd3/spark/local, /hdd4/spark/local, /hdd5/spark/local, /hdd6/spark/local, /hdd7/spark/local, /hdd8/spark/local
		/hdd1/yarn/local, /hdd2/yarn/local, /hdd3/yarn/local, /hdd4/yarn/local, /hdd5/yarn/local, /hdd6/yarn/local, /hdd7/yarn/local, /hdd8/yarn/local
		/var/log/spark
		/var/run/spark
        
4. set hostname according to `/etc/hosts` _[set_hostname.sh]_ **(identical to master node setup)**
5. copy limits _[copy_limit_conf.sh]_ **(identical to master node setup)**
6. modify `.bashrc` for `spark` and `hdfs` users _[env.sh]_ **(identical to master node setup)**
7. install spark, hadoop and benchmarks _[install_spark.sh]_ **(identical to master node setup)**
8. fix permissions _[permission.sh]_ **(identical to master node setup)**

#### IV. On each node, setup ssh keys for `spark` and `hdfs` users

#### V. On master node
1. as `hdfs` user, format and start hdfs, create directories _[start_hdfs.sh]_

        hadoop namenode -format
		/opt/hadoop/sbin/stop-dfs.sh
		/opt/hadoop/sbin/start-dfs.sh
		/opt/hadoop/bin/hdfs dfs -mkdir /tmp
		/opt/hadoop/bin/hdfs dfs -chmod a+rwx /tmp
		/opt/hadoop/bin/hdfs dfs -mkdir /history_logs
		/opt/hadoop/bin/hdfs dfs -chmod -R 777 /history_logs
        
2. as `spark` user, start spark _[start_spark.sh]_

		/opt/spark-1.6.2/sbin/stop-all.sh
		/opt/spark-1.6.2/sbin/stop-history-server.sh
		/opt/spark-1.6.2/sbin/start-all.sh
		/opt/spark-1.6.2/sbin/start-history-server.sh
        
3. as `guest` user, check that all services are up as expected _[check_services.sh]_




