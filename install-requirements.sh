#!/bin/bash

distro="$(cat /etc/os-release | grep ID | awk -F "=" '{print $2}' | sed -n 2p)"

if [[ "$distro" == "ubuntu" || "$distro" == "debian" ]]
then

  if [[ -z "$(cat /etc/os-release | grep ${distro^^}_CODENAME | awk -F "=" '{print $2}')" ]]
  then 
    codename="$(cat /etc/os-release | grep VERSION_CODENAME | awk -F "=" '{print $2}')"
  else
    codename="$(cat /etc/os-release | grep ${distro^^}_CODENAME | awk -F "=" '{print $2}')"
  fi

  sudo apt-get update
  sudo apt-get install git curl ca-certificates gnupg

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$distro/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $codename stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

elif [[ "$(cat /etc/os-release | grep ID | awk -F "=" '{print $2}' | sed -n 1p)" == "\"centos\"" ]]
then 
  sudo yum install -y git curl yum-utils

  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

elif [[ "$(cat /etc/os-release | grep ID | awk -F "=" '{print $2}' | sed -n 1p)" == "fedora" ]]
then 
  sudo dnf -y install dnf-plugins-core git curl

  sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

  sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
then
  echo "distribution not supported"
fi

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
