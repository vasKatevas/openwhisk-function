FROM debian:11.3

RUN useradd -ms /bin/bash user

USER user
WORKDIR /home/user

USER root
# Install requirments apt & pip
RUN apt-get update && apt-get install -y tar wget curl python3-pip python3 bc octave-control octave-image octave-io octave-optim octave-signal octave-statistics npm
RUN pip3 install ansible
RUN pip3 install kubernetes
RUN apt-get install -y vim
RUN npm install -g npm@8.13.2
USER user
## ansible playbooks 
RUN ansible-galaxy collection install kubernetes.core 

USER root
## .deb
RUN wget https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz && tar -zxvf helm-v3.8.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/ && rm helm-v3.8.1-linux-amd64.tar.gz
RUN wget https://github.com/apache/openwhisk-cli/releases/download/1.2.0/OpenWhisk_CLI-1.2.0-linux-amd64.tgz && tar -zxvf OpenWhisk_CLI-1.2.0-linux-amd64.tgz && mv wsk /usr/local/bin/ && rm OpenWhisk_CLI-1.2.0-linux-amd64.tgz
RUN wget https://github.com/apache/openwhisk-wskdeploy/releases/download/1.2.0/openwhisk_wskdeploy-1.2.0-linux-amd64.tgz && tar -zxvf openwhisk_wskdeploy-1.2.0-linux-amd64.tgz && rm openwhisk_wskdeploy-1.2.0-linux-amd64.tgz
RUN mv wskdeploy /usr/local/bin/
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl



RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs


COPY ./ /home/user/
COPY ./ansible/required-files/kind-config.yaml /home/user/.kube/config
RUN cd nodeapp/ && npm install
RUN chown -R user:user /home/user/nodeapp && chown -R user:user /home/user/ansible && chown -R user:user /home/user/.kube/config
RUN chown user:user test-loadgen.sh && chown user:user octave-exec.sh
RUN chmod a+x test-loadgen.sh
RUN chmod a+x octave-exec.sh
RUN chmod a+x load-gen-call.sh
USER user

RUN echo "delay,stdConcurrency,memorySize,userMemory,averageWaitTime,averageUserSideDelay,averageStartLatency,averageInitTime,averageDuration,achievedAverageRate,stdDevDuration,stdDevInitTime,stdDevStartLatency,stdDevUserSideDelay,stdDevWaitTime,successPercentage,coldStarts" >> results.csv
RUN mkdir octave-results

RUN cd /home/user/nodeapp && npm install
CMD ["/bin/bash","-c","node nodeapp/index.js"]
