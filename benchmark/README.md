# Benchmark Execution Guide

This guide provides instructions to execute the **Spark-Bench Logistic Regression** and **Databricks TPC-DS** benchmarks.

### Prerequisites

1. On each node, copy and unpack the `spark-bench` / `tpcds-kit` / `spark-sql-perf-0.3.2` directories into this package's `benchmark` directory (i.e. where this `README` file resides).

  **Note:** These directories are currently externally provided.

2. On each node, run the `./tune.sh` script to set the appropriate CPU performance and SMT modes.

3. On the master node, modify the `bench-env.sh` script according to your environment.

  **Note:** The required environment variables are `SPARK_MASTER` and `CLUSTER_NODES`.


Note:  For consistency of benchmark results, these scripts include a step to clear the operating system caches by writing to the /proc/sys/vm/drop_caches file on all nodes.  The scripts will `ssh` to each node specified in `CLUSTER_NODES` to complete this step.
 
### Assumptions

This guide assumes that you have completed the setup and configuration of a 1+4 cluster of Habanero (S812LC) POWER Servers (1 master node, 4 slave or data nodes) with the following resources available on each cluster node:

| | |
| --- | --- |
| Number of sockets: | 1 |
| Number of physical CPU cores: | 10 |
| SMT mode: | SMT8 |
| Number of virtual CPU cores: | 80 |
| RAM size: | 256GB |

If your cluster has a different configuration, you must adjust the Spark configuration parameters (e.g. `--total-executor-cores`, `--executor-cores`, `--executor-memory`) according to the resources available in your cluster:

* For Spark-Bench Logistic Regression, the Spark configuration parameters are set in `spark-bench/LogisticRegression/bin/config.sh`. 
* For Databricks TPC-DS, the Spark configuration parameters are set in `tpcds/gen_data.sh` and `tpcds/run.sh`.

For ease of comparison, the benchmark execution scripts also provide comparable configuration parameters for a 1+4 x86 cluster (1 master node, 4 slave or data nodes) with the following resources available on each cluster node:

| | |
| --- | --- |
| Number of sockets: | 2 |
| Number of physical CPU cores: | 20 |
| Number of virtual CPU cores: | 40 (hyperthreading) |
| RAM size: | 256GB |

If your x86 cluster has different configuration, you must adjust the aforementioned Spark configuration parameters according to the resources available in your cluster.

### Spark-Bench Logistic Regression
 
#### Generate dataset
 
1. Login to the master node and run the following commands: 

        cd logres
        ./update_env.sh
        ./gen_data.sh
 
  **Note:** The data generation can take about 3 minutes to complete on the 1+4 POWER8 cluster. 
 
2. After the data generation process is complete, you can verify the data by running the following command:

        sudo -u hdfs hdfs dfs -ls /SparkBench/LogisticRegression/Input

#### Execute the Spark-Bench Logistic Regression benchmark
 
1. Login to the master node and run the following commands: 

        cd logres
        ./run.sh
 
  **Note:** This command can take about 170 seconds to complete on the 1+4 POWER8 cluster. 
 
2. Verify that the Spark stages completed successfully by checking the Spark event log that is located at `http://<pubic IP of master node>:18082`. 
 
  **Note:** The benchmark reports and logs are available in the `spark-bench/num` directory. 
 

 
### Databricks TPC-DS
 
#### Generate dataset
 
1. Login to the master node and run the following commands: 
 
        cd tpcds
        ./gen_data.sh
 
  Data generation will proceed in the background.  Check the progress in the `tpcds/dsgen.scala.out` file.
 
  **Note:** This step can take around 11 hours to complete on the 1+4  POWER8 cluster, and can take more time on an equivalent x86 cluster. 
 
  To run the data generation on a x86 cluster, use the `gen_data_x86.sh` script. 
 
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
 
  To run the query on a x86 cluster, you can run the `run_x86.sh` script.
 
2. After the query completes, you can check the output file for the elapsed time that Spark took to run the query.
 
  To check the elapsed time for the query, run the following command:

      cd tpcds
      grep -e "Time taken" q68*.out

  The following output is an example:

      Time taken: 510.62 seconds, Fetched 100 row(s)
      16/10/11 13:51:30 INFO CliDriver: Time taken: 510.62 seconds, Fetched 100 row(s)
 
  Verify that the Spark stages completed successfully by checking the Spark event log that is located on `http://<public IP of master node>:18082`.
