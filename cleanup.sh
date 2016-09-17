#!/bin/bash
sudo su - <<'EOF'

docker stop jenkins registry 
docker rm jenkins registry

docker rmi docker.io/registry
docker rmi docker.io/jenkins

rm -rf /data
rm -rf /home/jenkins/*

userdel jenkins

sed -i 'g/jenkins/d /etc/sudoers

yum remove epel-release -y
yum remove docker-io docker-engine -y
yum remove ansible -y

rm -rf /usr/local/bin/docker-machine /usr/local/bin/docker-compose

EOF

