#!/bin/bash

kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml

cat << EOF > ansible/required-files/cluster-info.yaml
---
masterNode: kind-control-plane
workerNode1: kind-worker
workerNode2: kind-worker2
kubeconfig: ~/.kube/kind-config
EOF
