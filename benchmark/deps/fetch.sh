#!/bin/bash
set -x

DEPS_DIR="$(cd "`dirname "$0"`"; pwd)"

# Install build tools
sudo apt-get install -y git maven make gcc byacc flex bison

# Fetch, patch and build logres dependencies
cd ${DEPS_DIR}
git clone https://github.com/SparkTC/spark-bench.git
cd spark-bench
git checkout -b commit-28ce0ce 28ce0ce
git apply ../spark-bench.patch

cd ${DEPS_DIR}
git clone https://github.com/synhershko/wikixmlj.git

cd ${DEPS_DIR}/wikixmlj
mvn package install
cd ${DEPS_DIR}/spark-bench
mvn package -P spark1.6 --projects common,LogisticRegression

# Fetch, patch and build tpcds dependencies
cd ${DEPS_DIR}
git clone https://github.com/databricks/spark-sql-perf.git
cd spark-sql-perf
git checkout -b tag-v0.3.2 v0.3.2
git apply ../spark-sql-perf.patch

cd ${DEPS_DIR}
git clone https://github.com/davies/tpcds-kit.git
cd tpcds-kit
git checkout -b commit-39a63a4 39a63a4

cd ${DEPS_DIR}/tpcds-kit/tools
make -f Makefile.suite
cd ${DEPS_DIR}/spark-sql-perf
DBC_USERNAME=$USER build/sbt clean package
