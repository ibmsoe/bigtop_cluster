# Benchmark Execution Guide

### Prerequisites

1. You must make sure that the Hadoop HDFS and Spark services are active on all nodes before starting the benchmark process.

2. On each node, copy the `spark-bench` / `tpcds-kit` / `spark-sql-perf` directories into this package's `benchmark/deps` directory.

  **Note:** These directories are currently externally provided.

3. On each node, run the `./tune.sh` script to set the appropriate CPU performance and SMT modes.

4. On the master node, modify the `bench-env.sh` script according to your environment.

  **Note:** The required environment variables are `SPARK_MASTER` and `CLUSTER_NODES`.


Note:  For consistency of benchmark results, these scripts include a step to clear the operating system caches by writing to the /proc/sys/vm/drop_caches file on all nodes.  The scripts will `ssh` to each node specified in `CLUSTER_NODES` to complete this step.

 
### Spark-Bench Logistics Regression
 
#### Generate dataset
 
1. Login to the master node and run the following commands: 

        cd logres
        ./update_env.sh
        ./gen_data.sh
 
  **Note:** The data generation can take about 3 minutes to complete on the 1+4 POWER8 cluster. 
 
2. After the data generation process is complete, you can verify the data by running the following command:

        sudo -u hdfs hdfs dfs -ls /SparkBench/LogisticRegression/Input

#### Execute the Spark-Bench Logistics Regression benchmark
 
1. Login to the master node and run the following commands: 

        cd logres
        ./run.sh
 
  **Note:** This command can take about 170 seconds to complete on the 1+4 POWER8 cluster. 
 
2. Verify that the Spark stages completed successfully by checking the Spark event log that is located at `http://<pubic IP of master node>:18082`. 
 
  **Note:** The benchmark reports and logs are available in the `spark-bench/num` directory. 
 

 
### Databricks TPC-DS benchmark
 
#### Generate dataset
 
1. Login to the master node and run the following commands: 
 
        cd tpcds
        ./gen_data.sh
 
  Data generation will proceed in the background.  Check the progress in the `tpcds/dsgen.scala.out` file.
 
  **Note:** This step can take around 11 hours to complete on the 1+4  POWER8 cluster, and can take more time on an equivalent x86 cluster. 
 
2. After the data generation completes, you can check the data by running the following command:
 
        sudo -u hdfs hdfs dfs -du -h /TPCDS-10TB
 
  The following output is an example: 

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
 
#### Execute the TPC-DS query
 
1. Login to the master node and run the following command: 

        cd tpcds
        ./run.sh
 
  The query will proceed in the background.  Check the progress in the `tpcds/q68*.out` file.
 
  **Note:** This step can take around 9 minutes to complete on the 1+4  POWER8 cluster, and can take more time to complete on an equivalent x86 cluster. 
 
2. After the query completes, you can check the output file for the elapsed time that Spark took to run the query.
 
  To check the elapsed time for the query, run the following command:

      cd tpcds
      grep -e "Time taken" q68*.out

  The following output is an example:

      Time taken: 510.62 seconds, Fetched 100 row(s)
      16/10/11 13:51:30 INFO CliDriver: Time taken: 510.62 seconds, Fetched 100 row(s)
 
  Verify that the Spark stages completed successfully by checking the Spark event log that is located on `http://<public IP of master node>:18082`.
