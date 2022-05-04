#!/bin/bash

kind create cluster --config ansible/required-files/kind-cluster.yaml
kubectl config view --flatten > ansible/required-files/kind-config.yaml
