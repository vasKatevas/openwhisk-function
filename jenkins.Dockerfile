FROM jenkins/jenkins:latest

USER root

# Install requirments apt & pip
RUN apt-get update && apt-get install -y tar wget git curl python3-pip python3 iputils-ping
RUN pip3 install ansible
RUN pip3 install kubernetes

## ansible playbooks 
USER jenkins
RUN ansible-galaxy collection install kubernetes.core 

## .deb
USER root
RUN wget https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz && tar -zxvf helm-v3.8.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/
RUN wget https://github.com/apache/openwhisk-cli/releases/download/1.2.0/OpenWhisk_CLI-1.2.0-linux-amd64.tgz && tar -zxvf OpenWhisk_CLI-1.2.0-linux-amd64.tgz && mv wsk /usr/local/bin/
RUN wget https://github.com/apache/openwhisk-wskdeploy/releases/download/1.2.0/openwhisk_wskdeploy-1.2.0-linux-amd64.tgz && tar -zxvf openwhisk_wskdeploy-1.2.0-linux-amd64.tgz
RUN mv wskdeploy /usr/local/bin/
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

USER jenkins
VOLUME /var/jenkins_home

# Copy kind-config ( every time kind runs it makes a new one ) 
#COPY ./ansible/required-files/kind-config.yaml var/jenkins_home/.kube/kind-config
#COPY ./ansible/required-files/vagrant-config.yaml var/jenkins_home/.kube/vagrant-config
