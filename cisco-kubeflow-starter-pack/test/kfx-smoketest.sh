#!/bin/bash

# Create KinD cluster or use existing cluster

# Install Kubeflow on a cluster
export KFX_VERSION=v0.1.0-alpha
export OPSYS=linux
curl http://storage.googleapis.com/kfx-releases/${KFX_VERSION}/${OPSYS}/kfx > test/build/kfx && chmod +x test/build/kfx
test/build/kfx install kf
