#!/bin/bash

while [ -z "$(wskdeploy -m /openwhisk-function/manifest.yaml 2>/dev/null )" ]; do sleep 3m; done
