rm -rf goapp

git clone https://github.com/henryfernandes/goapp.git/

cd goapp

ansible-playbook -i hosts -c local build.yml


