#!/bin/bash

kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml

docker build -t vaskatevas/jenkins -f Dockerfile .
docker run -d  --network host  vaskatevas/jenkins ping 127.0.0.1
containerID=$(docker ps | grep vaskatevas/jenkins | awk '{print $1}')
docker exec $(echo $containerID) ansible-playbook openwhisk-function/ansible/cluster-setup.yml
docker exec $(echo $containerID) ansible-playbook openwhisk-function/ansible/openwhisk-setup.yml
docker exec $(echo $containerID) jmeter -n -t openwhisk-function/HTTP-Request.jmx

#ansible-playbook edit-mycluster.yml --extra-vars "minMemory= maxMemory= stdMemory= userMemory="

#Values
#cont.Count         2      /    4    /   6
#memory:
#  min: "512m"             /
#  max: "2048m"            /
#  std: "1024m"            /
#  containerPool:
#      userMemory: "2048m" / 4096m  / 8192m

# average Latency
docker exec $(echo $containerID) /bin/bash -c "cd openwhisk-function ; echo \"\$(cat result.csv | paste -sd+ | bc) / \$(wc -l result.csv | awk '{ print \$1 }')\" | bc"
