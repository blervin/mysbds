#!/bin/bash
###############
## VARIABLES ##
###############
echo "$(date) set variables" >> /var/log/mysbds_install.log
mysql_password="mystrongcomplexpassword"
volume_name="volume-tor1-01"

##################
## MOUNT VOLUME ##
##################
echo "$(date) mount volume" >> /var/log/mysbds_install.log
sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_$volume_name
sudo mkdir -p /mnt/$volume_name; 
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_$volume_name /mnt/$volume_name; 
echo /dev/disk/by-id/scsi-0DO_Volume_$volume_name /mnt/$volume_name ext4 defaults,nofail,discard 0 0 | sudo tee -a /etc/fstab

#################
## YUM INSTALL ##
#################
echo "$(date) yum install" >> /var/log/mysbds_install.log
yum -y install docker git wget

##################
## START DOCKER ##
##################
echo "$(date) start docker" >> /var/log/mysbds_install.log
docker_volume_name=`echo $volume_name | sed -e "s/-/\\\\\-/g"`
echo $docker_volume_name
sed -i -e "s/{}/{\"graph\": \"\/mnt\/$docker_volume_name\"}/g" /etc/docker/daemon.json
systemctl start docker
systemctl enable docker

#################
## START MYSQL ##
#################
echo "$(date) start mysql" >> /var/log/mysbds_install.log
docker run -d --name steem_mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$mysql_password -e MYSQL_DATABASE=steem mysql 

###############
## GIT CLONE ##
###############
echo "$(date) git clone" >> /var/log/mysbds_install.log
cd /mnt/$volume_name
git clone https://github.com/steemit/sbds.git
cd /mnt/$volume_name/sbds
git fetch origin pull/81/head
git checkout -b fixes-for-tables FETCH_HEAD

################
## START SBDS ##
################
echo "$(date) build/run sbds" >> /var/log/mysbds_install.log
mysql_ip=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" steem_mysql`
sed -i -e "s/sqlite\:\/\/\/\/tmp\/sqlite\.db/mysql\:\/\/root\:$mysql_password\@$mysql_ip:3306\/steem/g" /mnt/$volume_name/sbds/Dockerfile
sed -i -e "s/steemd\.steemitdev\.com/api\.steemit\.com/g" /mnt/$volume_name/sbds/Dockerfile
cd /mnt/$volume_name/sbds
docker build -t sbds .
docker run --name steem_sbds -p 8080:8080 -p 9191:9191 --link steem_mysql:mysql sbds
echo "$(date) END install" >> /var/log/mysbds_install.log