#!/bin/bash
sudo setenforce 0

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
	echo "user alredy exits with uid 1000"
        na1=`grep 1000 /etc/passwd | awk -F: '{print $1}'`
  
  else
        sudo useradd -m -d /home/jenkins -u 1000 -s /bin/bash jenkins
        echo jenkins | sudo passwd jenkins --stdin
        sudo usermod -aG docker jenkins
	na1=jenkins
fi


if [ $na1 == "jenkins" ];
 then
        echo "User exists"
 else
        echo "Creating Jenkins user"
	sudo useradd -m -d /home/jenkins -s /bin/bash jenkins
	echo jenkins | sudo passwd jenkins --stdin
	sudo usermod -aG docker jenkins
fi


sudo usermod -aG $grp $na1

#sudo mkdir /home/deployer/.ssh
if sudo grep -q "$na1" /etc/sudoers
   then
     echo " $na1 already added to sudoers"
else
      sudo sed -i '/NOPASSWD/ a $na1         ALL=(ALL)      NOPASSWD: ALL' /etc/sudoers
     echo "not exist"
fi

sudo su - $na1  <<'EOF'

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

echo "#Get godeploy git repo" #Get godeploy git repo
git clone https://github.com/henryfernandes/ansible-jenkins-docker.git

cd ansible-jenkins-docker/ansible/

echo "Create SSH keys"#Create SSH keys
mkdir files/.ssh; cd files/.ssh 
if [ $( ls id_rsa ) ];
 then
   echo "Keys already created"
   cat id_rsa.pub >> authorized_keys
 else
   ssh-keygen -t rsa -b 4096 -N "" -f ./id_rsa
   cat id_rsa.pub >> authorized_keys 
fi

cd ../ ; cp -R .ssh ../ansible/roles/jenkins/files/

echo "#run playbook" #run playbook
grp=`grep 1000 /etc/group | awk -F: '{print $1}'`
ansible-playbook -i hosts --extra-vars "user=$USER , grp=$grp" -c local cd.yml


EOF

sudo su - jenkins <<'EOF'

echo "Create SSH keys"#Create SSH keys
mkdir .ssh; cd .ssh
if [ $( ls id_rsa ) ];
 then
   echo "Keys already created"
   cat id_rsa.pub >> authorized_keys
 else
   ssh-keygen -t rsa -b 4096 -N "" -f ./id_rsa
   cat id_rsa.pub >> authorized_keys
fi
EOF


