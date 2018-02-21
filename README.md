## MySBDS
This project aims to detail scripts which have proven reliable for deployment of the [Steem Blockchain Data Service](https://github.com/steemit/sbds) in a Linux environment along with implementation best practices identified in our usage of SBDS.

In time, we will outline all of the insights we uncover as we deploy SBDS as well as strategies implemented including monitoring, validation, performance tuning, and anything else we learn.

These scripts are reliable, however have not gone through extensive performance testing and optimization.

## Overview
Today, we have only two versions of the deploy script for CentOS 7 at DigitalOcean, but we will soon write additional versions. These scripts presume you are using [Block Storage](https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean) at DigitalOcean. Since the blockchain is rapidly growing, disk usage will continue to increase so these storage volumes allow us to slowly expand our storage over time.

And obviously, you can modify these scripts to suit your specific needs.

## Install
Before we begin, ensure you have a volume of at least 450GB attached to your droplet. The blockchain is massive and growing quickly.

#### Memory
The `high_mem.sh` script presumes you are running at least 16GB of memory and 4GB is suitable for `low_mem.sh` deployments.

Both scripts will take hours, if not days to complete. The `low_mem.sh` manually downloads the entire blockchain one call at a time, while `high_mem.sh` downloads an entire `mysqldump` first, also taking significant time.

There is basic logging to `/var/log/mysbds_install.log` so you can watch that log to see progress.

#### mysqldump
We have setup [mysbds.com](http://www.mysbds.com/) with a continually updated copy of the entire blockchain as a `mysqldump` avaialble for [download](http://download.mysbds.com/latest.tar).

#### Deploying on an already running system

We start by cloning the project.

```
git clone https://github.com/blervin/mysbds.git
```

We first need to modify the variables in the deploy script.
```
mysql_password="mystrongcomplexpassword"
volume_name="volume-tor1-01"
```

Then, we want to make our scripts executable.

```
chmod +x mysbds/sbds/deploy/digitalocean/centos7/*.sh
```

Set a secure password and update the `volume_name` to exactly match the name of your volume *that is attached to your droplet* at DigitalOcean.

And then execute the deploy script.

```
./mysbds/sbds/deploy/digitalocean/centos7/high_mem.sh
```
