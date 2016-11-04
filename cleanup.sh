for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x stop ; done
for x in `cd /etc/init.d ; ls spark-*` ; do sudo service $x stop ; done
sudo ps -aux | grep java | awk '{print $2}' | sudo xargs kill

sudo apt-get purge -y hadoop*
sudo apt-get purge -y spark-*
sudo apt-get purge -y zeppelin*
sudo apt-get purge -y zookeeper*
sudo rm -rf /var/lib/hadoop-*
sudo rm -rf /usr/lib/zeppelin /etc/zeppelin /var/run/zeppelin/webapps /var/log/zeppelin
