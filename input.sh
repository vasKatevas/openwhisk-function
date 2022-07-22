#!/bin/bash

ansibleExtraVars=""
for i in $@
do
  varName=$(echo $i | awk -F "=" '{print $1}')
  [ $varName = memorySize ] && sed -i "s/memorySize:.*/memorySize: $varData/g" manifest.yaml
  if [[ $varName = minMemory ]] || [[ $varName = maxMemory ]] || [[ $varName = userMemory ]]
  then
    ansibleExtraVars="$ansibleExtraVars $i"
  fi
done
if [ ! -z "$ansibleExtraVars" ]
then
  ansible-playbook ansible/edit-mycluster.yml --extra-vars "$ansibleExtraVars"
fi
