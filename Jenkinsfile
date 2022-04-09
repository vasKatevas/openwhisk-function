pipeline 
{
  agent any
    stages {
      stage('git clone'){
        steps {
          git credentialsId: 'github', url: 'git@github.com:vasKatevas/openwhisk-function.git'
        }
      }
      stage('setup env') {
        steps {
          sh 'cp /kind-config ~/.kube/kind-config'
        }
      }
      stage('run ansible') {
        steps {
          sh '''cd ansible/
            ansible-playbook cluster-setup.yml"
            ansible-playbook openwhisk-setup.yml"'''
        }
      }
    }
}
