rm -rf goapp

git clone https://github.com/henryfernandes/goapp.git/

cd goapp

sudo docker run --rm -v /home/jenkins/goapp/code:/go/src/helloapp -v /home/jenkins/goapp/deploy:/tmp/deploy gobuild sh buildgo.sh

sudo /usr/local/bin/docker-compose stop
sudo /usr/local/bin/docker-compose rm -f

sudo /usr/local/bin/docker-compose up


