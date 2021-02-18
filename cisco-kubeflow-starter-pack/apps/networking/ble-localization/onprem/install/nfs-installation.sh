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

echo "Provide Ingress IP (ex:10.123.232.211)"

read -p "INGRESS IP: " INGRESS_IP

echo $INGRESS_IP

if [ -z "${INGRESS_IP}" ]; then
  echo "You must specify Ingress IP"
  exit 1
fi


# Get Kubernetes cluster information
echo "Cluster Information"
kubectl cluster-info
if [ $? -eq 0 ]; then
    echo "kubectl is connected to k8s cluster"
else
    echo "kubectl is not connected to k8s cluster. Please update kubeconfig"
    exit 1
fi

KUBEFLOW_NAMESPACE=`kubectl get namespace | grep kubeflow | head -n1 | awk '{print $1;}'`
if [ "$KUBEFLOW_NAMESPACE" = "kubeflow" ]; then
    echo "kubeflow namespace exists"
else
    echo "kubeflow namespace does not exist. Please check if kubeflow installed successfully in kubeflow namespace"
    exit 1
fi

# Create ClusterRoleBinding which provides access for anonymous serviceaccount  to connect with kubeflow namespace
kubectl create clusterrolebinding serviceaccounts-cluster-admin   --clusterrole=cluster-admin   --group=system:serviceaccounts
if [ $? -eq 0 ]; then
    echo "ClusterRoleBinding created succcessfully with name=serviceaccounts-cluster-admin "
elif [ `kubectl get clusterrolebinding  | grep serviceaccounts-cluster-admin | head -n1 | awk '{print $1;}'` = "serviceaccounts-cluster-admin" ]; then
    echo "anonymous Profile already exists"
else
    echo "ClusterRoleBinding not created succcessfully, Please check permission"
    exit 1
fi
sleep 4

#Create Anonymous user-profile in Kubeflow
kubectl create -f nfs/anonymous-profile.yaml
if [ $? -eq 0 ]; then
    echo "anonymous Profile created successfully"
elif [ `kubectl get profiles | grep anonymous | head -n1 | awk '{print $1;}'` = "anonymous" ]; then
    echo "anonymous Profile already exists"
else
    echo "anonymous profile not created successfully"
    exit 1
fi
sleep 10

ANONYMOUS_NAMESPACE=`kubectl get namespace | grep anonymous | head -n1 | awk '{print $1;}'`
echo $ANONYMOUS_NAMESPACE
if [ "$ANONYMOUS_NAMESPACE" = "anonymous" ]; then
    echo "anonymous namespace exists"
else
    echo "anonymous namespace not created successfully and exiting"
fi

# Create secret for Kubeflow Dashboard IP
kubectl create secret generic kubeflow-dashboard-ip  --from-literal=KUBEFLOW_DASHBOARD_IP=$INGRESS_IP  -n kubeflow
sleep 4

# Check secrets in kubeflow ns
SECRET=`kubectl get secret -n kubeflow | grep kubeflow-dashboard-ip | head -n1 | awk '{print $1;}'`
if [ "$SECRET" = "kubeflow-dashboard-ip" ]; then
    echo "Secret kubeflow-dashboard-ip is created successfully in kubeflow namespace"
else
    echo "kubeflow-dashboard-ip is not created successfully"
    exit 1
fi

# Create nfs-server in anonymous namespace
kubectl apply -f nfs/anonymous/nfs-server.yaml -n anonymous
if [ $? -eq 0 ]; then
    echo "nfs-server created successfully in anonymous namespace"
else
    echo "nfs-server not created successfully in anonymous namespace"
fi
sleep 5

# Get nfs-server ClusterIP
NFS_ANONYMOUS_CLUSTER_IP=`kubectl -n anonymous get svc/nfs-server --output=jsonpath={.spec.clusterIP}`
echo $NFS_ANONYMOUS_CLUSTER_IP
if [ -z "${NFS_ANONYMOUS_CLUSTER_IP}" ]; then
    echo "nfs-server svc in anonymous namespace is not created or assigned successfully"
    revert_back
    exit 1
fi

#Replace IP
#sed -i "s/nfs-cluster-ip/$NFS_ANONYMOUS_CLUSTER_IP/g" nfs/anonymous/nfs-pv.yaml
# Updated sed command portable with linux(ubuntu) and macos
sed -i.bak "s/nfs-cluster-ip/$NFS_ANONYMOUS_CLUSTER_IP/g" nfs/anonymous/nfs-pv.yaml && rm -rf nfs/anonymous/nfs-pv.yaml.bak

# Create nfs pv
kubectl apply -f nfs/anonymous/nfs-pv.yaml -n anonymous
if [ $? -eq 0 ]; then
    echo "pv for nfs-server created successfully"
else
    echo "pv for nfs-server not created successfully"
    revert_back
    exit 1
fi
sleep 5

# Check pvc
kubectl get pv -n anonymous

# Create nfs pvc
kubectl apply -f nfs/anonymous/nfs-pvc.yaml -n anonymous
if [ $? -eq 0 ]; then
    echo "pvc for nfs-server created successfully in anonymous namespace with name=nfs1"
else
    echo "pvc for nfs-server not created successfully in anonymous namespace"
    revert_back
    exit 1
fi
sleep 5

# Check pvc
kubectl get pvc -n anonymous


echo "NFS pvc and pvc created with name nfs1 in anonymous namespace"

# Create nfs-server in kubeflow  namespace
kubectl apply -f nfs/kubeflow/nfs-server.yaml -n kubeflow
sleep 5
# Get nfs-server ClusterIP
NFS_KUBEFLOW_CLUSTER_IP=`kubectl -n kubeflow  get svc/nfs-server --output=jsonpath={.spec.clusterIP}`
echo $NFS_KUBEFLOW_CLUSTER_IP
if [ -z "${NFS_KUBEFLOW_CLUSTER_IP}" ]; then
    echo "nfs-server svc in kubeflow namespace is not created or assigned successfully"
    revert_back
    exit 1
fi

#Replace IP
#sed -i "s/nfs-cluster-ip/$NFS_KUBEFLOW_CLUSTER_IP/g" nfs/kubeflow/nfs-pv.yaml
# Updated sed command portable with linux(ubuntu) and macos
sed -i.bak "s/nfs-cluster-ip/$NFS_KUBEFLOW_CLUSTER_IP/g" nfs/kubeflow/nfs-pv.yaml && rm -rf nfs/kubeflow/nfs-pv.yaml.bak

# Create nfs pv
kubectl apply -f nfs/kubeflow/nfs-pv.yaml -n kubeflow
if [ $? -eq 0 ]; then
    echo "pv for nfs-server created successfully"
else
    echo "pv for nfs-server not created successfully"
    revert_back
    exit 1
fi
sleep 5

# Check pv
kubectl get pv

# Create nfs pvc
kubectl apply -f nfs/kubeflow/nfs-pvc.yaml -n kubeflow
if [ $? -eq 0 ]; then
    echo "pvc for nfs-server created successfully in kubeflow namespace with name=nfs"
else
    echo "pvc for nfs-server not created successfully in kubeflow namespace"
    revert_back
    exit 1
fi
sleep 5
# Check pvc
kubectl get pvc -n kubeflow

echo "NFS pvc and pvc created with name nfs in kubeflow namespace"

# To revert back if any isssue in nfs server, pv and pvc installation
revert_back()
{

    kubectl delete -f nfs/anonymous/nfs-pvc.yaml -f nfs/anonymous/nfs-pv.yaml -f  nfs/kubeflow/nfs-pvc.yaml -f  nfs/kubeflow/nfs-pv.yaml -f nfs/kubeflow/nfs-server.yaml -f nfs/anonymous/nfs-server.yaml
    kubectl delete secret kubeflow-dashboard-ip -n kubeflow
    sed -i '/    server:/c\    server: nfs-cluster-ip' nfs/kubeflow/nfs-pv.yaml
    sed -i '/    server:/c\    server: nfs-cluster-ip' nfs/anonymous/nfs-pv.yaml
}
