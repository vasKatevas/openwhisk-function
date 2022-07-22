#!/bin/bash
cd $(dirname $0) && pwd
kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml
docker build -t vaskatevas/controller-api -f Dockerfile .
docker run --network host -d vaskatevas/controller-api
containerID=$(docker ps | grep vaskatevas/controller-api | awk '{print $1}')
docker exec $containerID ansible-playbook ansible/cluster-setup.yml
docker exec $containerID ansible-playbook ansible/openwhisk-setup.yml

#./test-loadgen.sh memorySize=512 minMemory=512m maxMemory=8192m userMemory=8192m




#Values
#cont.Count         2      /    4    /   6
#memory:
#  min: "512m"             /
#  max: "2048m"            /
#  std: "1024m"            /
#  containerPool:
#      userMemory: "2048m" / 4096m  / 8192m

# average Latency
