function taken from https://www.raymondcamden.com/2017/01/10/creating-packaged-actions-in-openwhisk

vagrant setup from https://github.com/Frewx/vagrant-kubernetes-cluster

* Run vagrant or kind
* uncomment the correct kubeconfig file inside jenkins.Dockerfile

```    
docker build -t vaskatevas/jenkins -f jenkins.Dockerfile .  
docker run  -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home  vaskatevas/jenkins  
```
for kind  
```
docker run --network host -v jenkins_home:/var/jenkins_home  vaskatevas/jenkins  
```
for vagrant-config.yaml    
```
# inside vagrant-kubernetes-cluster repo  
vagrant ssh-config >>  ~/.ssh/config  

# inside openwhisk-function repo  
ssh master  
kubectl config view --flatten > vagrant-config.yaml  
exit  
scp vagrant@master:~/vagrant-config.yaml ansible/required-files/  
```
