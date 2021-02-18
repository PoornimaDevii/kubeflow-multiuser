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
     "--logdir")
       shift
       LOGDIR="$1"
       shift
       ;;
     "--server-name")
       shift
       SERVER_NAME="$1"
       shift
       ;;
     "--pvc-name")
       shift
       PVC_NAME="$1"
       shift
       ;;
     "--service-type")
       shift
       SERVICE_TYPE="$1"
       shift
       ;;
     "--container-port")
       shift
       CONTAINER_PORT="--containerPort=$1"
       shift
       ;;
     "--service-port")
       shift
       SERVICE_PORT="--servicePort=$1"
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


if [ -z "$TIMESTAMP" ]; then
    echo "Timestamp needs to be provided"
fi

CLUSTER_NAME=ucs

# Connect kubectl to the local cluster
kubectl config set-cluster "${CLUSTER_NAME}" --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials pipeline --token "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
kubectl config set-context kubeflow --cluster "${CLUSTER_NAME}" --user pipeline
kubectl config use-context kubeflow

# Configure and deploy the app
cd /opt
mkdir tensorboard
cd tensorboard/
touch kustomization.yaml blerssi_tensorboard.yaml blerssi_tensorboard_service.yaml

#Writing code into yaml files
cat >> kustomization.yaml << EOF
resources:
- blerssi_tensorboard.yaml
- blerssi_tensorboard_service.yaml

namePrefix: tensorboard-
EOF
sed -i "s/tensorboard-/tensorboard-$TIMESTAMP-/g" kustomization.yaml

cat >> blerssi_tensorboard.yaml << EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: blerssi-tensorboard
    timestamp: timestamp-value
  name: blerssi
  namespace: kubeflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blerssi-tensorboard
      timestamp: timestamp-value
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: blerssi-tensorboard
        timestamp: timestamp-value
    spec:
      containers:
      - env:
        - name: logdir
          value: /mnt/model
        image: docker.io/premkarthi/tensorboard:v10
        imagePullPolicy: IfNotPresent
        name: tensorboard
        resources:
          limits:
            memory: 512Mi
            cpu: 0.5
          requests:
            memory: 256Mi
            cpu: 0.25
        ports:
        - containerPort: 6006
          protocol: TCP
        volumeMounts:
        - mountPath: /mnt
          name: nfs
      restartPolicy: Always
      volumes:
      - name: nfs
        persistentVolumeClaim:
          claimName: nfs
EOF
sed -i "s/timestamp-value/ts-$TIMESTAMP/g" blerssi_tensorboard.yaml
cat >> blerssi_tensorboard_service.yaml  << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: blerssi-tensorboard
    timestamp: timestamp-value
  name: blerssi-service
  namespace: kubeflow
spec:
  ports:
  - port: 6006
    protocol: TCP
    targetPort: 6006
  selector:
    app: blerssi-tensorboard
    timestamp: timestamp-value
  type: NodePort
EOF
sed -i "s/timestamp-value/ts-$TIMESTAMP/g" blerssi_tensorboard_service.yaml
kubectl get secret kubeflow-dashboard-ip  -n kubeflow -o yaml | grep KUBEFLOW_DASHBOARD_IP  | cut -d : -f 2 |sed 's/ //g'|base64 --decode > /tmp/ip.txt
KUBEFLOW_DASHBOARD_IP=$(cat /tmp/ip.txt)
echo "Installing kustomize"
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.4/kustomize_v3.5.4_linux_amd64.tar.gz
tar -xvf kustomize_v3.5.4_linux_amd64.tar.gz
export PATH=$PATH:$PWD

#Building a service and a deployment using kustomize
kustomize build . | kubectl apply -f -

kubectl get deployment tensorboard-$TIMESTAMP-blerssi -n kubeflow

kubectl get svc tensorboard-$TIMESTAMP-blerssi-service -n kubeflow

NODEPORT=`kubectl -n  kubeflow get svc/tensorboard-$TIMESTAMP-blerssi-service  --output=jsonpath={.spec.ports[0].nodePort}`
echo $NODEPORT
echo $KUBEFLOW_DASHBOARD_IP

echo "********************"
echo "http://"$KUBEFLOW_DASHBOARD_IP":"$NODEPORT
echo "********************"
