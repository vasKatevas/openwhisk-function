# Inner Ansible details
## How it works
Once the deployment has succeeded the user can trigger through an API the testing procedure for the openwhisk function that was configured during the deployment. This API is
developed in nodejs and the implementation is located inside the nodeapp folder. From the nodejs application, the test-loadgen.sh shell script is being executed in a loop for every combination of the given OW configuration input. This script gets a single combination of input and then it configures manifest.yaml and mycluster.yaml (with the help
of edit-mycluster.yml). After that openwhisk gets undeployed and then deployed with the help of openwhisk-setup.yml ansible playbook (the same script is being used during the execution of kind-setup.sh). After running test-loadgen.sh for every input combination the request stops loading and the test results are being returned to the user.
## cluster-setup.yml
This ansible playbook is run by kind-setup.sh when the kubernetes cluster is first started to set the needed labels that openwhisk uses to set up each node correctly.
## edit-mycluster.yml
This File is being used by test-loadgen.sh to set the parameters provided by the user inside mycluster.yaml
## openwhisk-setup.yml
This playbook installs openwhisk to the cluster from the kubeconfig file provided by kind and exported by kind-setup.sh and prepares the wsk command to be able to be used after openwhisk installation. The last step of the playbook waits until the openwhisk deployment is finished, this happens by deploying manifest.yml until it stops failing. This method is being used due to a bug of openwhisk that prevents the labeling as finished of the last job for the openwhisk installation, so alternatively this unpropper method
is being used.
