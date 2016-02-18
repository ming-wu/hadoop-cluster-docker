
Build Hadoop Cluster based on Docker, Swarm, Weave
------

```
1. Project Introduction
2. Hadoop-Cluster-Docker image Introduction
3. Steps to build a Hadoop Cluster
4. Clean up existed containers
```

##1. Project Introduction

The objective of this project is to help Hadoop developer to quickly build an Hadoop cluster on multiple Docker hosts. This is achieved by using [Docker](https://www.docker.com/), [Swarm](https://docs.docker.com/swarm/) and Weave(https://github.com/weaveworks/weave)

My project is based on [kiwenlau/hadoop-cluster-docker](https://github.com/kiwenlau/hadoop-cluster-docker) project, however, I've reconstructed it for multiple Docker hosts. 

##2. Hadoop-Cluster-Docker image Introduction

In this project, I developed 3 docker images: **hadoop-base**, **hadoop-master** and **hadoop-slave**.

#####hadoop-base 

Based on ubuntu:14.4, openjdk, openssh-server, vim and Hadoop 2.6.4 are installed.

#####hadoop-master

Based on hadoop-base. Configure the Hadoop master node. 

#####hadoop-slave

Based on hadoop-base. Configure the Hadoop slave node.

##3. steps to build a Hadoop cluster
Following needs to be performed on each Docker host

#####a. clone source code
```
git clone https://github.com/ming-wu/hadoop-cluster-docker
```
####b. configure Docker engine to listen on tcp port 2375 [reference](https://docs.docker.com/engine/admin/systemd/)
```
vim /lib/systemd/system/docker.service 
systemctl daemon-reload
systemctl restart docker
```

####c. install Weave
```
sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave
```
for Weave master node
```
weave launch-router
weave launch-plugin
weave launch-proxy -H tcp://0.0.0.0:12375
```
for Weave peer node
```
weave launch-router $master_node_ip
weave launch-plugin
weave launch-proxy -H tcp://0.0.0.0:12375
```
####d. install Swarm cluster [reference](https://docs.docker.com/swarm/install-manual/)
assume three Docker hosts: ny3-01, ny3-02 and ny3-03
```
-- start consul manager1 (ny3-01)

docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap

docker run -d -p 4000:4000 --name=swarm_manager0 swarm manage -H :4000 --replication --advertise $(ny3-01-ip):4000 consul://$(ny3-01-ip):8500

-- start manager2 (ny3-02)

docker run -d swarm manage -H :4000 --replication --advertise $(ny3-02-ip):4000  consul://$(ny3-01-ip):8500

-- start nodes (ny3-01 ny3-02 ny3-03)

docker run -d --name swarm_node1 swarm join --advertise=$(ny3-01-ip):12375 consul://$(ny3-01-ip):8500

docker run -d --name swarm_node2 swarm join --advertise=$(ny3-02-ip):12375 consul://$(ny3-01-ip):8500

docker run -d --name swarm_node3 swarm join --advertise=$(ny3-03-ip):12375 consul://$(ny3-01-ip):8500

```

verify docker swarm manager, all nodes should be healthy
```
docker -H :4000 info
```

####e. Start hadoop cluster, run this on ny03-01, the host where swarm manager0 is on
```
docker -H :4000 run -d -t -P --name master -w /root comp689/hadoop-master:1.0.0 
sleep 5
docker -H :4000 run -d -t -P --name slave1 -e JOIN_IP=$(weave status dns | grep '^master\s' |awk '{print $2}') comp689/hadoop-slave:1.0.0  
sleep 5
docker -H :4000 run -d -t -P --name slave2 -e JOIN_IP=$(weave status dns | grep '^master\s' |awk '{print $2}') comp689/hadoop-slave:1.0.0 
```

####f. enter hadoop master container and start hadoop cluster
```
docker -H :4000 exec -it master bash

ls
./start-hadoop.sh
```

####g. run map reduce job
```
docker -H :4000 exec -it master bash

ls
./run-wordcount.sh
```

##4. clean up existed containers
```
docker rm -v $(docker ps -a -q -f status=exited)

docker rmi $(docker images -f "dangling=true" -q)

docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
```
