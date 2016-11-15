#!/bin/bash

for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x stop ; done
for x in `cd /etc/init.d ; ls spark-*` ; do sudo service $x stop ; done
sudo ps -aux | grep java | awk '{print $2}' | sudo xargs kill

sudo rm -rf /usr/lib/hadoop/bin/hdfs
sudo apt-get purge -y hadoop*
sudo apt-get purge -y spark-*
sudo apt-get purge -y zeppelin*
sudo apt-get purge -y zookeeper*
sudo rm -rf /var/lib/hadoop-*
sudo rm -rf /usr/lib/zeppelin /etc/zeppelin /var/run/zeppelin /var/log/zeppelin

# Clean up mounts created by prep_disks.sh
if [ -f disk_list ]; then
    cp /etc/fstab fstab.tmp
    mount > mount.tmp
    while read i
    do
        # Skip empty line
        if [ -z $i ]; then continue; fi

        mount_dir=`cat mount.tmp | grep ^/dev/${i} | awk '{ print $3 }' | grep '/hdd[0-9][0-9]*'`
        if [ -z $mount_dir ]; then continue; fi

        echo "unmounting /dev/${i} from ${mount_dir}"
        # Remove from fstab
        sed -i '\|'${mount_dir}'|d' fstab.tmp
        # Unmount and remove mount point
        sudo umount ${mount_dir} -f
        sudo rm -rf ${mount_dir}
    done < disk_list

    rm mount.tmp
    sudo mv fstab.tmp /etc/fstab
fi
