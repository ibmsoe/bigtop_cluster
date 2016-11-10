#!/bin/bash
# please populate the disk-list file with disk names 

if [ -f disk-list ]; then
  echo "start"
  sudo cp /etc/fstab /etc/fstab.$$
  j=1;

  # clean the previous entries - namely anything that is mount to /hdd*
  while read i
  do
    if [[ $i =~ hdd[0-9]+ ]]
    then
      echo "#${i}" >> fstab.tmp
    else
      echo $i >> fstab.tmp
    fi
  done < /etc/fstab

  # unmount the old disks
  while read i
  do
      sudo umount /dev/${i}
  done < disk-list

  # Now let's format the disks, mount them, and add the fstab entry
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
    uuid=$(sudo blkid /dev/${i} | awk '{print $2}')
    echo "${uuid} /hdd${j} ext4 noatime,nodiratime 0 0" >> fstab.tmp #inserting UUID into fstab
    j=$[$j+1]
  done < disk-list

  # Replace the fstab with our newly created one
  sudo mv fstab.tmp /etc/fstab

fi
