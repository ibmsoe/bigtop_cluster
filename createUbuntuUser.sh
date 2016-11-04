useradd ubuntu
apt-get install sudo
usermod -aG sudo ubuntu

useradd ubuntu2 -U -G sudo -m
