sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo touch /etc/apt/sources.list.d/docker.list
echo "deb https://apt.dockerproject.org/repo debian-jessie main" | sudo tee --append /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-engine
sudo service docker start
sudo docker run hello-world

# add user to group docker, to allow non root user access docker command
# logout and login again to take affect.

