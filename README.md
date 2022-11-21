# Openwhisk-Function Dataset Acquisition Automation Scripts


## Introduction
This repository [1] includes a set of resources through which the user can automate the creation and execution of benchmark tests against an K8s-based Openwhisk installation. To this end, a number of scripts are provided:
* to install all the needed dependencies (e.g. kind, docker etc.) through the install_requirements.sh script 
* to create the Kubernetes cluster through the kind_setup.sh script
* to launch a node.js API server that can be used to launch through a respective REST call an experiment description including:
   * Number of combinations relevant to the setup of Openwhisk like max memory for functions, max memory per function, function concurrency, request rate etc
   * installation of Openwhisk according to each combination 
   * Execution of the performance test 
   * and returning of the results to the user


Thus the specific functionality can be used to automate entire series of measurements, thus being able to collect easily a performance dataset. The latter can then be used to create simpler or more complex performance models, e.g. based on regression techniques or function approximation ones, including the use of AI or machine learning methods, in order to detect proactively how differences in configuration could enhance the performance of the Openwhisk cluster.


[1] https://github.com/vasKatevas/openwhisk-function
  
![Enviroment Diagram](/images/enviroment.png "Enviroment Diagram")
  

## Configuration prior to deployment
### Definition of functions to be included in the Openwhisk setup


In order to pre-install actions inside Openwhisk, these actions need to be described in the manifest.yaml , in which details about their  registration can be performed like needed location of docker image (if custom docker action is used) or by providing the needed files inside actions/ folder if the actions refer to typical Openwhisk runtime actions such as nodejs, java etc. In this specification we can also dictate other parameters such as the needed memory for a function, whether it is exposed as a web action as well as any other related info based on the Openwhisk specification 
https://github.com/apache/openwhisk-wskdeploy/blob/master/specification/html/spec_actions.md 

```yaml
project:
  namespace: guest
  packages:
    performance-tester:
      version: 1.0
      license: Apache-2.0
      actions:
        loadgen:
          docker: gkousiou/physicspef_loadgenclient
          limits:
            timeout: 300000
        sleep:
          function: actions/hello.js
          runtime: nodejs:10
          web: true
          limits:
            memorySize: 512
```       
To change the target function actions/hello.js, the relevant code should be included in the actions folder along with the appropriate runtime type https://github.com/apache/openwhisk/blob/master/docs/actions.md#languages-and-runtimes 


### Setting the function to be tested


The target function should be set by changing the targetEndpoint url inside load-gen-call.sh, 
  
![loadgen-call.sh](/images/loadgen-call.png)

More information about the loadgenclient input can be found [here](https://docs.google.com/document/d/1drQEiX1vItXCtXcPBQQu9XBEoU2xfsRJKmwSQ62OFnI/edit)


This information needs to be statically set prior to installation through the kind-setup.sh, since at the moment this is not passed dynamically as an argument to the node.js App REST call.


## How to install
1. chmod u+x install-requirements.sh                
2. chmod u+x kind-setup.sh
3. ./install-requirements.sh
4. ./kind-setup.sh
If install-requirements.sh fails, install [docker](https://docs.docker.com/engine/install/#server), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-on-linux) and [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager) manually.




## How to use (NodeAPP interface)
Once kind-setup.sh finishes running the nodejs server is ready to accept requests. The user can run a test simply by executing a GET request at  http://localhost:3000/no-sockets with input similar to the one below. Every parameter can have multiple inputs in an array and user’s load generation input runs once for every combination of the given OW configuration input. Thus the following input would result in 4 combinations being executed.

```json
 {
    "testId":"1",
    "memorySize": 1024,
    "minMemory": "512m",
    "userMemory": ["8192m","6144m"] //this indicates that two combinations are needed for this option
    "maxConcurrency":10,
    "stdConcurrency":[1,10],
    "maxMemory": "8192m",
    "delay":7000
}
```

| Parameter      | Explanation |
:---             | :---
| testId         | The test id                                                                                                       |
| memorySize     | The amount of memory the function being tested can use                                                            |
| minMemory      | The minimum amount of memory function containers can use                                                          |
| maxMemory      | The maximum amount of memory function containers can use                                                          |
| userMemory     | The maximum amount of memory all openwhisk function containers can use                                            |
| maxConcurrency | The maximum amount of calls that a function container responds to (The maximum possible value for stdConcurrency) |
| stdConcurrency | The amount of calls that a function container responds to                                                         |
| delay          | The interarrival time between each test call                                                                      |
	

Αs soon as the execution is finished the results are given as the request response. Lastly the user can get the results for a specific test by executing a GET request at http://localhost:3000/results and with the test id as request body.
```json
{
    "testId":"1"
}
```

More information on the structure and options of the clusters from the relevant ansible files are included in the /ansible folder readme
