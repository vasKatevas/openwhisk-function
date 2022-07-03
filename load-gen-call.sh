#!/bin/bash

curl -k --location --request POST 'https://127.0.0.1:31001/api/v1/namespaces/guest/actions/performance-tester/loadgen' \
       --header 'Content-Type: application/json' \
       --header 'Authorization: Basic MjNiYzQ2YjEtNzFmNi00ZWQ1LThjNTQtODE2YWE0ZjhjNTAyOjEyM3pPM3haQ0xyTU42djJCS0sxZFhZRnBYbFBrY2NPRnFtMTJDZEFzTWdSVTRWck5aOWx5R1ZDR3VNREdJd1A=' \
       --data-raw "{
         \"testName\": \"openwhisk_ow_long_11_1_10_1\", 
           \"delay\": 6000, 
           \"testDuration\": 200000, 
           \"clientNumber\": 1, 
           \"totalClients\": 1, 
           \"creds\": \"23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP\", 
           \"endpointMethod\": \"POST\", 
           \"targetEndpoint\": \"https://172.21.0.2:31001/api/v1/web/guest/performance-tester/sleep.json\", 
           \"methodPayload\":\"{\\\"value\\\":5}\",
           \"statusEndpoint\": \"https://172.21.0.2:31001/api/v1/namespaces/guest/activations/\", 
           \"loadGenEndpoint\": \"https://172.21.0.2:31001/api/v1/namespaces/guest/actions/performance-tester/loadgen\", 
           \"nodeType\": \"physics_openwhisk:faas\", 
           \"otherInfo\": \"1000\", 
           \"status\": \"Started\", 
           \"parentSampleTime\": "$(date +%s%N | cut -b1-13)", 
           \"globalStartTime\":  "$(date +%s%N | cut -b1-13)"
         }"

#https://currentmillis.com/
