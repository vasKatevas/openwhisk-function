#!/bin/bash

test_commands () {
  echo "running test_commands"
  while [ ! -z "$(kubectl get pods -n openwhisk | grep PodInitializing)" ] || [ ! -z "$(kubectl get pods -n openwhisk | grep Init)" ]; do sleep 30s; done
  sleep 2m
  activationId=$(./load-gen-call.sh | awk -F ":" '{print $2}' | sed -e 's/\"//g;s/}//g')
  while [ -z "$(wsk -i activation list -l 200 | grep $activationId )" ]; do sleep 30s; done

  while [ -z "$(wsk -i activation get $activationId | grep averageInitTime)" ]
  do
    activationId=$(./load-gen-call.sh | awk -F ":" '{print $2}' | sed -e 's/\"//g;s/}//g')
    while [ -z "$(wsk -i activation list -l 200 | grep $activationId )" ]; do sleep 30s; done
  done
}

restart_openwhisk () {
  echo "restarting openwhisk"
  helm uninstall owdev --namespace openwhisk
  while [ ! "$(kubectl get pods -n openwhisk | grep Terminating | wc -l)" -eq 0 ]; do sleep 20; done
  ansible-playbook ansible/openwhisk-setup.yml
}


write_logs_to_file () {
  echo $memorySize
  averageDuration=$(      wsk -i activation get $activationId | grep averageDuration      | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  averageInitTime=$(      wsk -i activation get $activationId | grep averageInitTime      | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  averageStartLatency=$(  wsk -i activation get $activationId | grep averageStartLatency  | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  averageUserSideDelay=$( wsk -i activation get $activationId | grep averageUserSideDelay | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  averageWaitTime=$(      wsk -i activation get $activationId | grep averageWaitTime      | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  achievedAverageRate=$(  wsk -i activation get $activationId | grep achievedAverageRate  | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  stdDevDuration=$(       wsk -i activation get $activationId | grep stdDevDuration       | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  stdDevInitTime=$(       wsk -i activation get $activationId | grep stdDevInitTime       | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  stdDevStartLatency=$(   wsk -i activation get $activationId | grep stdDevStartLatency   | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  stdDevUserSideDelay=$(  wsk -i activation get $activationId | grep stdDevUserSideDelay  | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  stdDevWaitTime=$(       wsk -i activation get $activationId | grep stdDevWaitTime       | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  successPercentage=$(    wsk -i activation get $activationId | grep successPercentage    | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')
  coldStarts=$(           wsk -i activation get $activationId | grep coldStarts           | head -n 1 | awk -F ":" '{print $2}' |  sed -e 's/,//g')

  echo "$delay,$stdConcurrency,$memorySize,$(echo $userMemory | sed -e 's/m//g'),$averageWaitTime,$averageUserSideDelay,$averageStartLatency,$averageInitTime,$averageDuration,$achievedAverageRate,$stdDevDuration,$stdDevInitTime,$stdDevStartLatency,$stdDevUserSideDelay,$stdDevWaitTime,$successPercentage,$coldStarts" >> results.csv
}

cd $(dirname $0) && pwd

wskdeploy undeploy

ansibleExtraVars=""
memorySize=""
userMemory=""
minMemory=""
maxMemory=""
activationId=""
maxConcurrency=""
stdConcurrency=""
delay=""

for i in $@
do
  varName=$(echo $i | awk -F "=" '{print $1}')
  varData=$(echo $i | awk -F "=" '{print $2}')

  if [[ $varName = delay ]]
  then
    sed -i "s/..delay.*/\x5c\"delay\x5c\": $varData,/g" load-gen-call.sh; delay=$varData
  elif [[ $varName = memorySize ]]
  then
    sed -i "s/memorySize:.*/memorySize: $varData/g" manifest.yaml; memorySize=$varData
  elif [[ $varName = minMemory ]] 
  then
    ansibleExtraVars="$ansibleExtraVars $i"
    minMemory=$varData
  elif [[ $varName = maxMemory ]]
  then
    maxMemory=$varData
    ansibleExtraVars="$ansibleExtraVars $i"
  elif [[ $varName = userMemory ]]
  then
    userMemory=$varData
    ansibleExtraVars="$ansibleExtraVars $i"
  elif [[ $varName = maxConcurrency ]]
  then
    maxConcurrency=$varData
    ansibleExtraVars="$ansibleExtraVars $i"
  elif [[ $varName = stdConcurrency ]]
  then
    stdConcurrency=$varData
    ansibleExtraVars="$ansibleExtraVars $i"
  fi
done

if [ ! -z "$ansibleExtraVars" ]
then
  ansible-playbook ansible/edit-mycluster.yml --extra-vars "$ansibleExtraVars"
  restart_openwhisk
else
  wskdeploy -m manifest.yaml
fi
# getting previous set values if not given by the user
[ -z $maxMemory ]  && maxMemory=$(sed -n '18'p ansible/required-files/mycluster.yaml | awk -F ":" '{print $2}' | sed -e 's/\"//g')
[ -z $minMemory ]  && minMemory=$(sed -n '17'p ansible/required-files/mycluster.yaml | awk -F ":" '{print $2}' | sed -e 's/\"//g')
[ -z $memorySize ] && memorySize=$(cat manifest.yaml | grep memorySize | awk -F ":" '{print $2}')
[ -z $userMemory ] && userMemory=$(sed -n '32'p ansible/required-files/mycluster.yaml | awk -F ":" '{print $2}' | sed -e 's/\"//g')
[ -z $maxConcurrency ] && maxConcurrency=$(sed -n '22'p ansible/required-files/mycluster.yaml | awk -F ":" '{print $2}' | sed -e 's/\"//g')
[ -z $stdConcurrency ] && stdConcurrency=$(sed -n '23'p ansible/required-files/mycluster.yaml | awk -F ":" '{print $2}' | sed -e 's/\"//g')

echo $memorySize $userMemory

test_commands $(echo "($(echo $userMemory | sed -e 's/m//g') / $(echo $memorySize |  sed -e 's/m//g')) - 1" | bc)
write_logs_to_file
