#!/bin/bash

ansible_commands () {
  ansible-playbook ansible/edit-mycluster.yml --extra-vars "minMemory=512 maxMemory=2048 stdMemory=1024 userMemory=$2"
  docker exec $(echo $1) ansible-playbook openwhisk-function/ansible/cluster-setup.yml
  docker exec $(echo $1) ansible-playbook openwhisk-function/ansible/openwhisk-setup.yml
  sleep 5m
  docker exec $(echo $1) jmeter -n -t openwhisk-function/HTTP-Request.jmx
  docker exec $(echo $1) /bin/bash -c " echo \"\$(cd openwhisk-function ; echo \"\$(cat result.csv | paste -sd+ | bc) / \$(wc -l result.csv | awk '{ print \$1 }')\" | bc),$3\" >> results.log"
  #helm uninstall owdev --namespace openwhisk
  #while [ ! "$(kubectl get pods -n openwhisk | grep Terminating | wc -l)" -eq 0 ]; do sleep 20; done
}



kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml
docker build -t vaskatevas/jenkins -f Dockerfile .
docker run -d  --network host  vaskatevas/jenkins ping 127.0.0.1
containerID=$(docker ps | grep vaskatevas/jenkins | awk '{print $1}')
ansible_commands $containerID 2048m 2
ansible_commands $containerID 4096m 4
ansible_commands $containerID 8192m 6
kind delete clusters kind
#docker kill $containerID






#Values
#cont.Count         2      /    4    /   6
#memory:
#  min: "512m"             /
#  max: "2048m"            /
#  std: "1024m"            /
#  containerPool:
#      userMemory: "2048m" / 4096m  / 8192m

# average Latency
