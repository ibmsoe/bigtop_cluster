## Spark-Bench Logistic Regression

`https://github.com/SparkTC/spark-bench.git` (commit: 28ce0ce)

### Modify config as follows:

spark-bench/conf/env.sh:
```diff
@@ -1,23 +1,23 @@
 # global settings
 
-master=/YOUR/MASTER
+master=sparkmasterlab
 #A list of machines where the spark cluster is running
-MC_LIST=/YOUR/SLAVES
+MC_LIST="sparkslavelab1 sparkslavelab2 sparkslavelab3 sparkslavelab4"
 
 
-[ -z "$HADOOP_HOME" ] &&     export HADOOP_HOME=/YOUR/HADOOP
+[ -z "$HADOOP_HOME" ] &&     export HADOOP_HOME=/opt/hadoop
 # base dir for DataSet
-HDFS_URL="hdfs://${master}:9000"
+HDFS_URL="hdfs://${master}:8020"
 SPARK_HADOOP_FS_LOCAL_BLOCK_SIZE=536870912
 
 # DATA_HDFS="hdfs://${master}:9000/SparkBench", "file:///home/`whoami`/SparkBench"
-DATA_HDFS="hdfs://${master}:9000/SparkBench"
+DATA_HDFS="hdfs://${master}:8020/SparkBench"
 
 #Local dataset optional
 DATASET_DIR=/home/`whoami`/SparkBench/dataset
 
 SPARK_VERSION=1.6.1  #1.5.1
-[ -z "$SPARK_HOME" ] &&     export SPARK_HOME=/YOUR/SPARK
+[ -z "$SPARK_HOME" ] &&     export SPARK_HOME=/opt/spark-1.6.2
 
 #SPARK_MASTER=local
 #SPARK_MASTER=local[K]
```

spark-bench/LogisticRegression/conf/env.sh:
```diff
@@ -1,10 +1,10 @@
 ## Application parameters #32G date size=400 million examples; 1G= 12.5
-NUM_OF_EXAMPLES=20000
-NUM_OF_FEATURES=20
+NUM_OF_EXAMPLES=333333333
+NUM_OF_FEATURES=24
 ProbOne=0.2
 EPS=0.5
-NUM_OF_PARTITIONS=10
-
+NUM_OF_PARTITIONS=960
 MAX_ITERATION=3
 
-SPARK_STORAGE_MEMORYFRACTION=0.5
```

spark-bench/LogisticRegression/bin/config.sh:
```diff
@@ -18,6 +18,7 @@ OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output
 APP_MASTER=${SPARK_MASTER}
 
 set_gendata_opt
+SPARK_OPT="--conf spark.rdd.compress=false --conf spark.network.timeout=600 --conf spark.hadoop.dfs.blocksize=512m --conf spark.shuffle.consolidateFiles=true --conf spark.serializer=org.apache.spark.serializer.KryoSerializer --conf spark.executor.extraJavaOptions=\"-XX:ParallelGCThreads=20 -XX:+AlwaysTenure\" --conf spark.default.parallelism=480 --total-executor-cores 160  --executor-memory 200g --executor-cores 40"
 set_run_opt
 
 function print_config(){
```

### Procedure (on master node):

Setup:
```
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -rm -R -skipTrash /SparkBench
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -expunge
 
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /SparkBench
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /SparkBench/LogisticRegression
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -chown -R spark:hadoop /SparkBench/LogisticRegression
 
cd spark-bench/LogisticRegression/bin
./gen_data.sh

# check generated data
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -ls /SparkBench/LogisticRegression/Input
```

Execution (requires ssh to purge fs cache):
```
cd spark-bench/LogisticRegression/bin
./run.sh
```

## Databricks TPC-DS benchmark

spark-sql-perf: `https://github.com/databricks/spark-sql-perf.git` (tag: v0.3.2)<br>
tpcds-kit: `https://github.com/davies/tpcds-kit.git` (commit: 39a63a4)

### Modify spark-sql-perf as follows:

spark-sql-perf/src/main/scala/com/databricks/spark/sql/perf/tpcds/Tables.scala:
```diff
@@ -31,7 +31,7 @@
 
   case class Table(name: String, partitionColumns: Seq[String], fields: StructField*) {
     val schema = StructType(fields)
-    val partitions = if (partitionColumns.isEmpty) 1 else 100
+    val partitions = if (partitionColumns.isEmpty) 1 else 320
 
     def nonPartitioned: Table = {
       Table(name, Nil, fields : _*)
@@ -253,6 +253,7 @@
   }
 
   val tables = Seq(
+/*
     Table("catalog_sales",
       partitionColumns = "cs_sold_date_sk" :: Nil,
       'cs_sold_date_sk          .int,
@@ -324,6 +325,7 @@
       'inv_item_sk          .int,
       'inv_warehouse_sk     .int,
       'inv_quantity_on_hand .int),
+*/
     Table("store_sales",
       partitionColumns = "ss_sold_date_sk" :: Nil,
       'ss_sold_date_sk      .int,
@@ -371,6 +373,7 @@
       'sr_reversed_charge   .decimal(7,2),
       'sr_store_credit      .decimal(7,2),
       'sr_net_loss          .decimal(7,2)),
+/*
     Table("web_sales",
       partitionColumns = "ws_sold_date_sk" :: Nil,
       'ws_sold_date_sk          .int,
@@ -477,6 +480,7 @@
       'cp_catalog_page_number   .int,
       'cp_description           .string,
       'cp_type                  .string),
+*/
     Table("customer",
       partitionColumns = Nil,
       'c_customer_sk             .int,
@@ -665,7 +669,8 @@
       't_am_pm                   .string,
       't_shift                   .string,
       't_sub_shift               .string,
-      't_meal_time               .string),
+      't_meal_time               .string)
+/*
     Table("warehouse",
       partitionColumns = Nil,
       'w_warehouse_sk           .int,
@@ -726,5 +731,6 @@
       'web_country              .string,
       'web_gmt_offset           .string,
       'web_tax_percentage       .decimal(5,2))
+*/
   )
 }
```

### Automation scripts:

tpcds/dsgen.scala:
```
import com.databricks.spark.sql.perf.tpcds.Tables

val tables = new Tables(sqlContext, "/home/spark/tpcds-kit/tools", 10000)
tables.genData("hdfs://sparkmasterlab:8020/TPCDS-10TB", "parquet", true, true, true, true, true)
sqlContext.sql(s"DROP DATABASE IF EXISTS tpcds10tb CASCADE")
tables.createExternalTables("hdfs://sparkmasterlab:8020/TPCDS-10TB", "parquet", "tpcds10tb", true)

exit
```

tpcds/gen_data.sh:
```
#!/bin/bash

echo "Clearing cache on all nodes. Enter password for sudo access on each node when prompted..."
ssh -t sparkmasterlab "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab1 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab2 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab3 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab4 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
echo "Clearing cache completes"

echo "Start to run TPC-DS 10TB data generation. Keep this ssh seesion alive. Open another ssh session and check the dsgen.scala.out file in /home/spark/tpcds for progress. This step would take around 11 hours on POWER8 and more time on x86..."
cd /opt/spark-1.6.2
./bin/spark-shell --master spark://sparkmasterlab:7077 --name dsdgen --conf spark.rdd.compress=true --conf spark.io.compression.codec=snappy --conf spark.network.timeout=900 --conf spark.serializer=org.apache.spark.serializer.KryoSerializer  --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=4 -XX:+AlwaysTenure" --conf spark.default.parallelism=560 --conf spark.sql.shuffle.partitions=280 --conf spark.shuffle.consolidateFiles=true --driver-memory 20g --driver-cores 16 --total-executor-cores 280 --executor-cores 5 --executor-memory 10g --jars /home/spark/spark-sql-perf-0.3.2/target/scala-2.10/spark-sql-perf_2.10-0.3.2.jar -i /home/spark/tpcds/dsgen.scala > /home/spark/tpcds/dsgen.scala.out 2>&1
```

tpcds/run.sh:
```
#!/bin/bash

echo "Clearing cache on all nodes. Enter password for sudo access on each node when prompted..."

ssh -t sparkmasterlab "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab1 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab2 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab3 "echo 3 | sudo tee /proc/sys/vm/drop_caches"
ssh -t sparkslavelab4 "echo 3 | sudo tee /proc/sys/vm/drop_caches"

echo "Clearing cache completes"

echo "Start to run TPC-DS query. Keep this ssh seesion alive. Open another ssh session and check the .nohup in /home/spark/tpcds for progress. This step would take around 9 minutes on POWER8 and more time on x86..."

/home/spark/tpcds/run_single_tpcds_v1.4.sh q68 64 16 30g 200 8
```

tpcds/run_single_tpcds_v1.4.sh:
```
#!/bin/bash

if [ $# -ne 6 ]; then
    echo "Usage: ./run_single_tpcds_v1.4.sh <query name> <total-executor-cores> <executor-cores> <executor-memory> <sql-shufle-partitions> <# of GC Threads>"
    exit
fi

query_name=$1
total_executor_cores=$2
executor_cores=$3
executor_memory=$4
sql_shuffle_partitions=$5
gcThreads=$6

SPARK_HOME=/opt/spark-1.6.2

SEQ=0
CNT=`ls -lrt /home/spark/tpcds/${query_name}_${total_executor_cores}tc_${executor_cores}ec_${executor_memory}_*.nohup 2>/dev/null | wc | awk '{print \$1}'`
SEQ=$CNT

cd ${SPARK_HOME}
${SPARK_HOME}/bin/spark-sql --master spark://sparkmasterlab:7077 --conf spark.shuffle.io.numConnectionsPerPeer=4 --conf spark.reducer.maxSizeInFlight=128m --conf spark.executor.extraJavaOptions="-XX:ParallelGCThreads=${gcThreads} -XX:+AlwaysTenure" --conf spark.sql.shuffle.partitions=${sql_shuffle_partitions} --conf spark.shuffle.consolidateFiles=true --conf spark.sql.autoBroadcastJoinThreshold=67108864 --conf spark.serializer=org.apache.spark.serializer.KryoSerializer --name ${query_name} --driver-memory 12g --driver-cores 16 --total-executor-cores ${total_executor_cores} --executor-cores ${executor_cores} --executor-memory ${executor_memory} --database tpcds10tb -f /home/spark/tpcds/${query_name}.sql > /home/spark/tpcds/${query_name}_${total_executor_cores}tc_${executor_cores}ec_${executor_memory}_${SEQ}.nohup 2>&1
```

tpcds/q68.sql:
```
select
   c_last_name, c_first_name, ca_city, bought_city, ss_ticket_number, extended_price,
   extended_tax, list_price
from (select
         ss_ticket_number, ss_customer_sk, ca_city bought_city,
         sum(ss_ext_sales_price) extended_price,
         sum(ss_ext_list_price) list_price,
         sum(ss_ext_tax) extended_tax
      from store_sales, date_dim, store, household_demographics, customer_address
      where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_store_sk = store.s_store_sk
         and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
         and store_sales.ss_addr_sk = customer_address.ca_address_sk
         and date_dim.d_dom between 1 and 2
         and (household_demographics.hd_dep_count = 4 or
              household_demographics.hd_vehicle_count = 3)
         and date_dim.d_year in (1999,1999+1,1999+2)
         and store.s_city in ('Midway','Fairview')
      group by ss_ticket_number, ss_customer_sk, ss_addr_sk,ca_city) dn,
         customer,
         customer_address current_addr
where ss_customer_sk = c_customer_sk
   and customer.c_current_addr_sk = current_addr.ca_address_sk
   and current_addr.ca_city <> bought_city
order by c_last_name, ss_ticket_number
limit 100;
```

### Procedure:

Setup:
```
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -rm -R -skipTrash /TPCDS-10TB
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -expunge
 
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir hdfs://sparkmasterlab:8020/TPCDS-10TB
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -chown -R spark:hadoop /TPCDS-10TB
 
cd tpcds
./gen_data.sh

# check generated data
sudo -u hdfs /opt/hadoop/bin/hdfs dfs -du -h hdfs://sparkmasterlab:8020/TPCDS-10TB
```

Execution:
```
cd tpcds
./run.sh
```

Check progress:
```
cd tpcds
grep -e “Time taken” q68*.nohup
```
