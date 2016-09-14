#!/bin/bash
sudo yum remove epel-release -y
rm -rf epel-releas*
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

sudo rpm -ivh epel-release-6-8.noarch.rpm
rm -rf epel-releas*

sudo yum install ansible -y
sudo yum install git -y

#sudo adduser --home /home/jenkins --shell /bin/bash jenkins
sudo groupadd -g 1000 -r jenkins
sudo useradd -m -d /home/jenkins -s /bin/bash -u 1000 -g 1000 jenkins
sudo echo dep123 | sudo passwd jenkins --stdin

#sudo mkdir /home/jenkins/.ssh
if sudo grep -q "jenkins" /etc/sudoers
   then
     echo "already added to sudoers"
else 
      sudo sed -i '/NOPASSWD/ a jenkins	ALL=(ALL)      NOPASSWD: ALL' /etc/sudoers
     echo "not exist"
fi

sudo su - jenkins  <<'EOF'
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
#sed -i "s/app1/${host1}/g" ~/godeploy/jenkins/config-goapp.xml
#sed -i "s/app2/${host2}/g" ~/godeploy/jenkins/config-goapp.xml
#ansible-playbook -i hosts  -c local nginxserver.yml
#ansible-playbook -i hosts  -c local jenkinsserver.yml
#nix1=`sudo docker inspect gonginx | grep IPA | grep -v Sec | awk -F"\"" '{print $4}'`;
#sed -i "/nginxserver/a ${nix1}" hosts
EOF
