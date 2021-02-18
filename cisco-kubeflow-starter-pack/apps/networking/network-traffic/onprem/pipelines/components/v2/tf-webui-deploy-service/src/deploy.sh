#!/bin/bash -e

# Copyright 2018 The Kubeflow Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

KUBERNETES_NAMESPACE="${KUBERNETES_NAMESPACE:-kubeflow}"
NAME="my-deployment"

while (($#)); do
   case $1 in
     "--image")
       shift
       IMAGE_PATH="$1"
       shift
       ;;
     "--container-port")
       shift
       CONTAINER_PORT="--containerPort=$1"
       shift
       ;;
     "--cluster-name")
       shift
       CLUSTER_NAME="$1"
       shift
       ;;
     "--namespace")
       shift
       KUBERNETES_NAMESPACE="$1"
       shift
       ;;
     "--name")
       shift
       NAME="$1"
       shift
       ;;
     "--timestamp")
       shift
       TIMESTAMP="$1"
       shift
       ;;
     *)
       echo "Unknown argument: '$1'"
       exit 1
       ;;
   esac
done

if [ -z "${IMAGE_PATH}" ]; then
  echo "You must specify an image to deploy"
  exit 1
fi

if [ -z "$TIMESTAMP" ]; then
  echo "You must specify Timestamp"
fi

echo "Deploying the image '${IMAGE_PATH}'"

CLUSTER_NAME=ucs

# Connect kubectl to the local cluster
kubectl config set-cluster "${CLUSTER_NAME}" --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials pipeline --token "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
kubectl config set-context kubeflow --cluster "${CLUSTER_NAME}" --user pipeline
kubectl config use-context kubeflow


#Making folder to store yaml files for kustomization
echo $PWD
mkdir network_webui
cd network_webui/
touch kustomization.yaml network_webui.yaml network_webui_service.yaml
ls -l
NETWORK_SERVING_IP=`kubectl -n  kubeflow  get svc/serve-$TIMESTAMP-network-service --output=jsonpath={.spec.clusterIP}`
#Writing code into yaml files
cat >> kustomization.yaml << EOF
resources:
- network_webui.yaml
- network_webui_service.yaml

namePrefix: webui-
EOF
sed -i "s/webui-/webui-$TIMESTAMP-/g" kustomization.yaml
cat >> network_webui.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: network
    timestamp: timestamp-value
  name: network
  namespace: kubeflow
spec:
  selector:
    matchLabels:
      app: network
      timestamp: timestamp-value
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "true"
      labels:
        app: network
        version: v1
        timestamp: timestamp-value
    spec:
      containers:
      - name: tensorflow-webapp
        image: docker.io
        resources:
          limits:
            memory: 1024Mi
            cpu: 1
          requests:
            memory: 512Mi
            cpu: 0.5
        env:
        - name: TF_MODEL_SERVER_HOST
          value: "9000"
        - name: KUBEFLOW_DASHBOARD_IP
          valueFrom:
            secretKeyRef:
              name: kubeflow-dashboard-ip
              key: KUBEFLOW_DASHBOARD_IP
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - mountPath: "/mnt/Model_Network/"
          name: "nfsvolume"
      volumes:
      - name: "nfsvolume"
        persistentVolumeClaim:
          claimName: "nfs"

EOF
sed -i "s/9000/$NETWORK_SERVING_IP/g" network_webui.yaml
sed -i "s/timestamp-value/ts-$TIMESTAMP/g" network_webui.yaml
sed -i "s|docker.io|$IMAGE_PATH|g" network_webui.yaml

cat >> network_webui_service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: network
    timestamp: timestamp-value
  name: network-service
  namespace: kubeflow
spec:
  ports:
  - name: tf-webui
    port: 80
    targetPort: 80
  selector:
    app: network
    timestamp: timestamp-value
  type: NodePort
EOF
sed -i "s/timestamp-value/ts-$TIMESTAMP/g" network_webui_service.yaml
ls -l
echo $PWD
kubectl get secret kubeflow-dashboard-ip  -n kubeflow -o yaml | grep KUBEFLOW_DASHBOARD_IP  | cut -d : -f 2 |sed 's/ //g'|base64 --decode > /tmp/ip.txt
KUBEFLOW_DASHBOARD_IP=$(cat /tmp/ip.txt)
echo "Installing kustomize"
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.4/kustomize_v3.5.4_linux_amd64.tar.gz
tar -xvf kustomize_v3.5.4_linux_amd64.tar.gz
export PATH=$PATH:$PWD
sleep 10
#Building a service and a deployment using kustomize
kustomize build . | kubectl apply -f -

kubectl get deployment webui-$TIMESTAMP-network -n kubeflow

kubectl get svc webui-$TIMESTAMP-network-service -n kubeflow

NODEPORT=`kubectl -n  kubeflow get svc/webui-$TIMESTAMP-network-service  --output=jsonpath={.spec.ports[0].nodePort}`
echo $NODEPORT
echo $KUBEFLOW_DASHBOARD_IP

echo "********************"
echo "http://"$KUBEFLOW_DASHBOARD_IP":"$NODEPORT
echo "********************"
