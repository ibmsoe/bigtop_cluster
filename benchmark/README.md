## Benchmark Execution Guide

### Prerequites

1. Make sure Hadoop HDFS and Spark services are active on all nodes before starting benchmark execution.

2. On each node, place/unpack the `spark-bench` / `tpcds-kit` / `spark-sql-perf-0.3.2` directories into the `benchmark` directory.

  *These are currently externally provided.*

3. On each node, execute `./tune.sh` to set the appropriate CPU performance and SMT modes.

4. On the master node, modify `bench-env.sh` according to your environment.

  Required environment variables are `SPARK_MASTER` and `CLUSTER_NODES`.


Note:  For consistency of benchmark results, these scripts include a step to clear OS caches (via /proc/sys/vm/drop_caches) on all nodes prior to each run.  This is done by visiting each node specified in `CLUSTER_NODES` and using `ssh` to execute the required command.

 
### Spark-Bench Logistics Regression
 
#### 1. Generate dataset
 
Login to the master node and run the following commands: 

```
cd logres
./update_env.sh
./gen_data.sh
```
 
Note: The data generation can take about 3 minutes to complete on the 1+4 POWER8 cluster. 
 
After the data generation process is complete, you can verify the data by running the following command:

```
sudo -u hdfs hdfs dfs -ls /SparkBench/LogisticRegression/Input
```

#### 2. Execute the Spark-Bench Logistics Regression benchmark
 
Login to the master node and run the following commands: 

```
cd logres
./run.sh
```
 
Note: This command can take 170 seconds to complete on the 1+4 POWER8 cluster. 
 
Verify that the Spark stages completed successfully by checking the Spark event log that is located at `http://<master node>:18080`. 
 
Note: The benchmark reports and logs are available in the `spark-bench/num` directory. 
 

 
### Databricks TPC-DS benchmark
 
#### 1. Generate dataset
 
Login to the master node and run the following commands: 
 
```
cd tpcds
./gen_data.sh
```
 
Do not close the existing ssh session. Open a second ssh session and check the progress of the data generation in the `tpcds/dsgen.scala.out` file.
 
Note: This step can take around 11 hours to complete on the 1+4  POWER8 cluster, and can take more time on an equivalent x86 cluster. 
 
To run the data generation on a x86 cluster, use the `gen_data_x86.sh` script. 
 
After the `gen_data.sh` script completes, you can check the data by running the following command:
 
```
sudo -u hdfs hdfs dfs -du -h /TPCDS-10TB
```
 
The following output is an example: 
```
2.3 G   /TPCDS-10TB2/customer
400.7 M /TPCDS-10TB2/customer_address
2.6 M    /TPCDS-10TB2/customer_demographics
754.7 K /TPCDS-10TB2/date_dim
13.2 K  /TPCDS-10TB2/household_demographics
2.2 K   /TPCDS-10TB2/income_band
22.6 M  /TPCDS-10TB2/item
67.0 K  /TPCDS-10TB2/promotion
2.7 K   /TPCDS-10TB2/reason
4.2 K   /TPCDS-10TB2/ship_mode
100.9 K /TPCDS-10TB2/store
124.2 G /TPCDS-10TB2/store_returns
1.0 T   /TPCDS-10TB2/store_sales
380.9 K /TPCDS-10TB2/time_dim
```
 
#### 2. Execute the TPC-DS query
 
Login to the master node and run the following command: 

```
cd tpcds
./run.sh
```
 
Do not close the existing ssh session. Open a second ssh session and check the progress of the query in the .nohup file located in `tpcds`.
 
Note: This step can take around 9 minutes to complete on the 1+4  POWER8 cluster, and can take more time to complete on an equivalent x86 cluster. 
 
To run the query on a x86 cluster, you can run the `run_x86.sh` script.
 
After the `run.sh` script completes, you can check the .nohup file for the elapsed time that Spark took to run the query. 
 
To check the elapsed time for the query, run the following command:

```
cd tpcds
grep -e "Time taken" q68*.nohup
```

The following output is an example:
```
Time taken: 510.62 seconds, Fetched 100 row(s)
16/10/11 13:51:30 INFO CliDriver: Time taken: 510.62 seconds, Fetched 100 row(s)
```
 
Verify that the Spark stages completed successfully by checking the Spark event log that is located on `http://<master node>:18080`.
