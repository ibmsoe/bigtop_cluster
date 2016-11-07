
#### BigTOP Services Status
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf ">>>> ${GREEN}Apache BigTop Spark${NC} Services Status\n"
systemctl -l --type service -all | grep spark | grep -v spark-worker
printf ">>>> ${GREEN}Apache BigTop Hadoop-HDFS${NC} Services Status\n"
systemctl -l --type service -all | grep -i hadoop-hdfs | grep -v hadoop-datanode
printf ">>>> ${GREEN}Apache BigTop Hadoop-MAPREDUCE${NC} Services Status\n"
systemctl -l --type service -all | grep -i hadoop-map*
printf ">>>> ${GREEN}Apache BigTop HADOOP-YARN${NC} Services Status\n"
systemctl -l --type service -all | grep -i hadoop-yarn | grep -v hadoop-yarn-nodemanager
printf ">>>> ${GREEN}Apache BigTop Zeppelin${NC} Services Status\n"
sudo -u zeppelin /usr/lib/zeppelin/bin/zeppelin-daemon.sh status

printf ">>>> ${GREEN}Apache BigTop yarn node Status${NC}\n"
sudo -u yarn yarn rmadmin -refreshNodes
sudo -u yarn yarn node -list

printf ">>>> ${GREEN}Apache BigTop yarn hdfs Status${NC}\n"
sudo -u hdfs hdfs dfsadmin -report
sudo -u hdfs hdfs dfsadmin -printTopology

