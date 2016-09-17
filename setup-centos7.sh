#!/bin/bash
if [ $( grep 1000 /etc/passwd ) ];
  then
	echo "user alredy created with uid1000"
        na1=`grep 1000 /etc/passwd | awk -F: '{print $1}'`
  
  else
        sudo useradd -m -d /home/jenkins -u 1000 -s /bin/bash jenkins
        echo jenkins | sudo passwd jenkins --stdin
        sudo usermod -aG docker jenkins
	na1=jenkins
fi


#sudo usermod -aG docker deployer

#sudo mkdir /home/deployer/.ssh
if sudo grep -q "$na1" /etc/sudoers
   then
     echo "already added to sudoers"
else
      sudo sed -i '/NOPASSWD/ a $na1         ALL=(ALL)      NOPASSWD: ALL' /etc/sudoers
     echo "not exist"
fi

mkdir /data/jenkins
chown $na1 -R /data

sudo su - $na1  <<'EOF'
echo "Emtpy the folder"
sudo yum update -y
sudo yum remove epel-release -y
rm -rf epel-releas*
sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
rm -rf epel-releas*

sudo yum install ansible -y

if [ $(ls /usr/local/bin/docker-machine ) ];
  then
        echo "/usr/local/bin/docker-machine file already exits"
  else
        curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` > docker-machine && \
        sudo cp docker-machine /usr/local/bin/docker-machine && sudo chmod +x /usr/local/bin/docker-machine
fi
if [ $(ls /usr/local/bin/docker-compose ) ];
  then
        echo "/usr/local/bin/docker-compose file already exits"
  else
        sudo curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > docker-compose && \
        sudo cp docker-compose /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
fi

echo "#Get godeploy git repo" #Get godeploy git repo
git clone https://github.com/henryfernandes/ansible-jenkins-docker.git

cd $PWD/ansible-jenkins-docker

echo "Create SSH keys"#Create SSH keys
mkdir $PWD/files; cd $PWD/files; rm -rf id_rsa.pub id_rsa authorized_keys
ssh-keygen -t rsa -b 4096 -N "" -f $PWD/id_rsa
cp $PWD/id_rsa.pub  $PWD/authorized_keys -R

echo "#run playbook" #run playbook
cd $HOME/ansible-jenkins-docker/ansible/
ansible-playbook -i hosts  -c local cd.yml


#host1=`sudo docker inspect app1 | grep IPA | grep -v Sec | awk -F"\"" '{print $4}'`;
#host2=`sudo docker inspect app2 | grep IPA | grep -v Sec | awk -F"\"" '{print $4}'`;
#sed -i "/appserver/a ${host2}" hosts
#sed -i "/appserver/a ${host1}" hosts
#sed -i "s/host1/${host1}/g" ~/godeploy/nginx/default.conf
#sed -i "s/host2/${host2}/g" ~/godeploy/nginx/default.conf
#sed -i "s/app1/${host1}/g" ~/godeploy/deployer/config-goapp.xml
#sed -i "s/app2/${host2}/g" ~/godeploy/deployer/config-goapp.xml

#ansible-playbook -i hosts  -c local nginxserver.yml
#ansible-playbook -i hosts  -c local deployerserver.yml
#nix1=`sudo docker inspect gonginx | grep IPA | grep -v Sec | awk -F"\"" '{print $4}'`;
#sed -i "/nginxserver/a ${nix1}" hosts

EOF

