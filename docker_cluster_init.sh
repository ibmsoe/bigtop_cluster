#!/bin/bash
node_ip_hostname="`hostname -i`\t`hostname -f`"
echo -e  $node_ip_hostname >> /bigtop/hosts
umount /etc/hosts
mv /etc/hosts /etc/hosts.bak
ln -s /bigtop/hosts /etc/hosts

if [ $HOSTNAME = "namenode" ]; then
  echo -e "127.0.0.1	localhost"> /bigtop/hosts
  echo -e $node_ip_hostname>> /bigtop/hosts
fi
