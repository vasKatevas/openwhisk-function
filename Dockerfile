FROM debian:11.3

RUN useradd -ms /bin/bash user

USER user
WORKDIR /home/user

USER root
# Install requirments apt & pip
RUN apt-get update && apt-get install -y tar wget git curl python3-pip python3 iputils-ping bc default-jdk
RUN pip3 install ansible
RUN pip3 install kubernetes
RUN apt-get install -y vim
RUN echo "JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\"" >> /etc/environment

USER user
## ansible playbooks 
RUN ansible-galaxy collection install kubernetes.core 

USER root
## .deb
RUN wget https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz && tar -zxvf helm-v3.8.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/
RUN wget https://github.com/apache/openwhisk-cli/releases/download/1.2.0/OpenWhisk_CLI-1.2.0-linux-amd64.tgz && tar -zxvf OpenWhisk_CLI-1.2.0-linux-amd64.tgz && mv wsk /usr/local/bin/
RUN wget https://github.com/apache/openwhisk-wskdeploy/releases/download/1.2.0/openwhisk_wskdeploy-1.2.0-linux-amd64.tgz && tar -zxvf openwhisk_wskdeploy-1.2.0-linux-amd64.tgz
RUN mv wskdeploy /usr/local/bin/
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.4.3.tgz && tar -zxvf apache-jmeter-5.4.3.tgz && ln -sr apache-jmeter-5.4.3/bin/jmeter /usr/local/bin/

# Copy kind-config ( every time kind runs it makes a new one ) 
COPY ./ansible/required-files/kind-config.yaml /home/user/.kube/config
USER user

RUN git clone https://github.com/vasKatevas/openwhisk-function.git

CMD ["bash"]
