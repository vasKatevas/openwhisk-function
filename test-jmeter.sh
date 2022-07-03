#!/bin/bash

test_commands () {
  sed -i "s/memorySize:.*/memorySize: $1/g" manifest.yaml
  wskdeploy -m manifest.yaml
  jmeter -n -t HTTP-Request.jmx
  echo "$(echo "$(cat result.csv | paste -sd+ | bc) / $(wc -l result.csv | awk '{ print $1 }')" | bc),$2" >> results.log
  wskdeploy undeploy
}

ansible-playbook ansible/cluster-setup.yml
test_commands 4096 2
test_commands 2048 4

