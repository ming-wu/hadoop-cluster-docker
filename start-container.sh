#!/bin/bash

# start slave1 container
sudo docker run -d -t --dns 127.0.0.1 -P --name slave1 -h slave1.kiwenlau.com kiwenlau/hadoop-slave:0.1.0

# get the IP address of the first container
FIRST_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" slave1)

# start slave2 container
sudo docker run -d -t --dns 127.0.0.1 -P --name slave2 -h slave2.kiwenlau.com -e JOIN_IP=$FIRST_IP kiwenlau/hadoop-slave:0.1.0

# start master container
sudo docker run -d -t --dns 127.0.0.1 -P --name master -h master.kiwenlau.com -e JOIN_IP=$FIRST_IP -w /root kiwenlau/hadoop-master:0.1.0