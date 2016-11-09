#!/bin/bash
# please populate the disk-list file with disk names 

if [ -f disk-list ]; then
echo "start"
sudo cp /etc/fstab /etc/fstab.$$

while read i
do
    echo "mounting following disks:"/dev/${i}
    # skip empty line
    if [ "$i" == "\n" ]; then
       continue
    fi
    sudo mkfs.ext4 -F /dev/${i};       #creating the filesystem on the disk
    echo  "creating /hdd${j} :"
    sudo mkdir -p /hdd${j}          #creating the mount point. You can change the name
    #mounting the disks
    sudo mount /dev/${i} /hdd${j}
    #getting the UUID for the disk
    uuid=$(blkid /dev/${i} | awk '{print $2}')
    echo "${uuid} /hdd${j} ext4 noatime,nodiratime 0 0" | sudo tee -a /etc/fstab; #inserting UUID into fstab  
done < disk-list
fi
