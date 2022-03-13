import os
import subprocess
import yaml


os.environ['PATH'] += os.pathsep + '/home/billy/Scripts'

def create_kind_cluster(kind_cluster):
    commands = [
        "export KUBECONFIG=${PWD}/" + kind_cluster,
        "kind create cluster --config " + kind_cluster,
        "kubectl label node kind-worker openwhisk-role=core",
        "kubectl label node kind-worker1 openwhisk-role=invoker",
        "kubectl label node kind-worker2 openwhisk-role=invoker",
    ]
    for cmd in commands:
        os.system(cmd)
    
    cmd = "echo " + '"$(kubectl describe node kind-worker | grep InternalIP: | awk ' + "'" + "{print $2}" + "'" + ')"'
    internal_ip = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    internal_ip = internal_ip.communicate()[0].decode('utf-8').split("\n")[0]
    
    return internal_ip

def write_cluster_yaml_file(api_host_name, ipi_host_port, file_path):
    yaml_file = {
        "whisk": {
            "ingress": {
                "type": "NodePort",
                "apiHostName": api_host_name,
                "apiHostPort": ipi_host_port
            }
        },
        "invoker": {
            "containerFactory": {
                "impl": "kubernetes"
            }
        },
        "nginx": {
            "httpsNodePort": "31001"
        }
    }

    with open(file_path, 'w') as outfile:
        yaml.dump(yaml_file, outfile, default_flow_style=False,  sort_keys=False)

def set_up_openwhisk():
    
    commands = [
        # Deploying a OpenWhisk
        "helm repo add openwhisk https://openwhisk.apache.org/charts",
        "helm repo update",
        "helm install owdev openwhisk/openwhisk -n openwhisk --create-namespace -f ./mycluster.yaml",
        "kubectl -n openwhisk wait --for=condition=complete job/owdev-install-packages",

        # Set up wsk
        "wsk property set --apihost " + '"$(kubectl describe node kind-worker | grep InternalIP: | awk ' + "'" + "{print $2}" + "'" + ')' + ':31001"',
        "wsk property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP",

        # Install Prometheus for metrics
        "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts",
        "helm repo update",
        "helm install monitoring prometheus-community/kube-prometheus-stack",

        # Deploy the events exposer
        "kubectl apply -f kubernetes_event_exporter_deployment.yml",

        # Deploy Minio
        "kubectl apply -f minio-k8s.yaml"
    ]
    for cmd in commands:
        print(cmd)
        os.system(cmd)

def upload_files_to_minio_instance(files_path):
    # wait until Openwhisk get ready (about 5-6 minutes)"
    os.system("sleep 360")

    commands = [
        # list default hosts after install: 
        "mc config host ls",

        # remove all hosts: mc config host rm {hostName}
        "mc config host rm local",

        # add your host: mc config host add {hostName} {url} {apiKey} {apiSecret}
        "mc config host add local http://127.0.0.1:9000 andrei-access andrei-secret",

        # create bucket: mc mb {host}/{bucket}
        "mc mb local/input",
        "mc mb local/output",

        # change bucket policy: mc policy {policy} {host}/{bucket}
        "mc policy set public local/input",
        "mc policy set public local/output",

        # cp the video file to minio bucket: 
        "mc cp " + files_path + "* local/input/",

        # Check if the file is there
        "mc ls local/input"
    ]

    os.system("killall kubectl")
    for cmd in commands:
        os.system("kubectl port-forward service/minio 9000 &")
        os.system("sleep 1")
        os.system(cmd)
        os.system("sleep 1")
        os.system("killall kubectl")

def main():
    kind_cluster_path = './kind-cluster.yaml'
    internal_ip = create_kind_cluster(kind_cluster_path)

    openwhisk_cluster_path = './mycluster.yaml'
    write_cluster_yaml_file(internal_ip, 31001, openwhisk_cluster_path)
    
    set_up_openwhisk()

    files_path = '../experiments/input_data/'
    upload_files_to_minio_instance(files_path)

main()
