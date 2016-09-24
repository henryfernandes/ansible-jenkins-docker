#!/bin/bash
sudo setenforce 0

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

echo "Checking if Group exists"
if [ $( grep 1000 /etc/group ) ];
  then
	grp=`grep 1000 /etc/group | awk -F: '{print $1}'`
	echo "Group $grp alredy exits with uid 1000"
  else
	sudo groupadd -g 1000 jenkins
fi

echo "Checking if User exists"
if [ $( grep 1000 /etc/passwd | awk -F: '{print $1}' ) ];
  then
        na1=`grep 1000 /etc/passwd | awk -F: '{print $1}'`
	echo "user $na1 alredy exits with uid 1000"
  else
        sudo useradd -m -d /home/jenkins -u 1000 -s /bin/bash jenkins
        echo jenkins | sudo passwd jenkins --stdin
        sudo usermod -aG docker jenkins
	na1=jenkins
fi


if [ $( grep jenkins /etc/passwd ) ];
 then
        echo "Jenkins user exists"
 else
        echo "Creating Jenkins user"
 	groupadd jenkins
	sudo useradd -m -d /home/jenkins -s /bin/bash jenkins
	echo jenkins | sudo passwd jenkins --stdin
	sudo usermod -aG jenkins jenkins
fi


#sudo mkdir /home/deployer/.ssh
if sudo grep -q "jenkins" /etc/sudoers
   then
     echo " jenkins already added to sudoers"
else
      sudo sed -i '/NOPASSWD/ a jenkins         ALL=(ALL)      NOPASSWD: ALL' /etc/sudoers
     echo "not exist"
fi

sudo su - jenkins  <<'EOF'

sudo yum update -y
if [ $(sudo yum list epel-release | grep epel | awk '{print $2}') = "7-8" ];
  then
    echo "epel-release-7-8.noarch.rpm already installed"
  else
    sudo yum remove epel-release -y
    sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
    rm -rf epel-releas*
fi

sudo yum install ansible -y
rm -rf ansible-jenkins-docker
echo "#Get godeploy git repo" #Get godeploy git repo
git clone https://github.com/henryfernandes/ansible-jenkins-docker.git

echo "Create SSH keys"#Create SSH keys
if [ $( ls .ssh/id_rsa ) ];
 then
   echo "Keys already created"
   cat .ssh/id_rsa.pub >> .ssh/authorized_keys
 else
   ssh-keygen -t rsa -b 4096 -N "" 
   cat .ssh/id_rsa.pub >> .ssh/authorized_keys
fi

cd .ssh; cp id_rsa.pub id_rsa authorized_keys $HOME/ansible-jenkins-docker/ansible/roles/jenkins/files/

cd $HOME/ansible-jenkins-docker/ansible/

echo "#run playbook" #run playbook

na1=`grep 1000 /etc/passwd | awk -F: '{print $1}'`
grp=`grep 1000 /etc/group | awk -F: '{print $1}'`
dockerip=`ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
ansible-playbook -i hosts --extra-vars "user=$na1 , grp=$grp , dockerip=$dockerip" -c local cd.yml


EOF


