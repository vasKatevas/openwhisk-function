#!/bin/bash

while [ -z "$(wskdeploy -m ../manifest.yaml 2>/dev/null )" ]; do sleep 3m; done
