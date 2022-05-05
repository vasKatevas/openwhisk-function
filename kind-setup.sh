#!/bin/bash

kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml

docker build -t vaskatevas/jenkins -f Dockerfile .
docker run --network host  vaskatevas/jenkins ansible-playbook openwhisk-function/ansible/cluster-setup.yml
#docker run --network host  vaskatevas/jenkins ansible-playbook openwhisk-function/ansible/openwhisk-setup.yml

# Note 
# remove wskdeploy from openwhisk-setup.yml
# and add an loop that deploys untill its successful
