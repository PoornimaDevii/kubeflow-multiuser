#!/bin/bash
export KF_APP="kf-app"
export KFDEF_URL="https://raw.githubusercontent.com/kubeflow/manifests/v1.0.0/kfdef/kfctl_k8s_istio.v1.0.0.yaml"
export KFCTL_URL="https://github.com/kubeflow/kfctl/releases/download/v1.0/kfctl_v1.0-0-g94c35cf_linux.tar.gz"
mkdir -p ${KF_APP}
cd ${KF_APP}
wget -O kfctl.tar.gz ${KFCTL_URL}
tar -zxvf kfctl.tar.gz
chmod +x kfctl
wget -O kfctl_k8s_istio.yaml ${KFDEF_URL}
./kfctl apply -V -f kfctl_k8s_istio.yaml
echo "The Kubeflow Central Dashboard is at ${INGRESS_IP}:31380"