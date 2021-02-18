# <a id=kubeflow></a> Install Kubeflow
This contains the instructions for installing Kubeflow. 

- Kubeflow
	* Version: `v1.0.0`
	* Kubeflow manifests repo release tag: `https://github.com/kubeflow/manifests/tree/v1.0.0`
	* kfctl CLI release tag: `https://github.com/kubeflow/kfctl/tree/v1.0`
	
```
export INGRESS_IP=<UCS Machine's IP>
git clone https://github.com/CiscoAI/cisco-kubeflow-starter-pack.git
cd cisco-kubeflow-starter-pack/
export PROJECT_ROOT_DIR=$(pwd)
chmod +x kubeflowup.sh
bash ./kubeflowup.sh
```

Check if all Kubeflow components are running successfully

	kubectl get pods --all-namespaces

Expected output:
```
NAMESPACE            NAME                                                           READY   STATUS      RESTARTS   AGE
cert-manager         cert-manager-5d849b9888-x9xwn                                  1/1     Running     0          13d
cert-manager         cert-manager-cainjector-dccb4d7f-psdzx                         1/1     Running     1          13d
cert-manager         cert-manager-webhook-695df7dbb-s92sf                           1/1     Running     1          13d
istio-system         cluster-local-gateway-7bf56777fb-vbh24                         1/1     Running     0          13d
istio-system         grafana-86f89dbd84-xwsrz                                       1/1     Running     0          13d
istio-system         istio-citadel-74966f47d6-55zsh                                 1/1     Running     0          13d
istio-system         istio-cleanup-secrets-1.1.6-sz8qf                              0/1     Completed   0          13d
istio-system         istio-egressgateway-5c64d575bc-qlt6k                           1/1     Running     0          13d
istio-system         istio-galley-784b9f6d75-q2hzg                                  1/1     Running     0          13d
istio-system         istio-grafana-post-install-1.1.6-4vmr8                         0/1     Completed   0          13d
istio-system         istio-ingressgateway-589ff776dd-tj88b                          1/1     Running     0          13d
istio-system         istio-pilot-677df6b6d4-tchrj                                   2/2     Running     1          13d
istio-system         istio-policy-6f74d9d95d-vwrf6                                  2/2     Running     2          13d
istio-system         istio-security-post-install-1.1.6-zjrhj                        0/1     Completed   0          13d
istio-system         istio-sidecar-injector-866f4b98c7-jbg67                        1/1     Running     0          13d
istio-system         istio-telemetry-549c8f9dcb-zrjt8                               2/2     Running     2          13d
istio-system         istio-tracing-555cf644d-v582p                                  1/1     Running     0          13d
istio-system         kiali-7db44d6dfb-4kvpc                                         1/1     Running     0          13d
istio-system         prometheus-d44645598-2wzrp                                     1/1     Running     0          13d
knative-serving      activator-6dc4884-z4kdl                                        2/2     Running     1          13d
knative-serving      autoscaler-69bcc99c79-n9hbv                                    2/2     Running     2          13d
knative-serving      autoscaler-hpa-68cc87bfb9-fxvbf                                1/1     Running     0          13d
knative-serving      controller-95dc7f8bd-b649t                                     1/1     Running     0          13d
knative-serving      networking-istio-5b8c5c6cff-ht47t                              1/1     Running     0          13d
knative-serving      webhook-67847fb4b5-gdthb                                       1/1     Running     0          13d
kube-system          calico-kube-controllers-846568ccc-h6f4w                        1/1     Running     0          13d
kube-system          calico-node-74qjh                                              1/1     Running     0          13d
kube-system          coredns-5c98db65d4-nsnbs                                       1/1     Running     0          13d
kube-system          coredns-5c98db65d4-xjrs4                                       1/1     Running     0          13d
kube-system          etcd-kubeflow-ucs                                      	    1/1     Running     0          13d
kube-system          kube-apiserver-kubeflow-ucs                            	    1/1     Running     0          13d
kube-system          kube-controller-manager-kubeflow-ucs                   	    1/1     Running     1          13d
kube-system          kube-proxy-4zqbk                                               1/1     Running     0          13d
kube-system          kube-scheduler-kubeflow-ucs                            	    1/1     Running     1          13d
kube-system          nvidia-device-plugin-daemonset-q2tdk                           1/1     Running     0          13d
kubeflow             admission-webhook-bootstrap-stateful-set-0                     1/1     Running     0          14h
kubeflow             admission-webhook-deployment-569558c8b6-8zb5q                  1/1     Running     0          14h
kubeflow             application-controller-stateful-set-0                          1/1     Running     0          14h
kubeflow             argo-ui-7ffb9b6577-fkf4t                                       1/1     Running     0          14h
kubeflow             centraldashboard-659bd78c-nzpdv                                1/1     Running     0          14h
kubeflow             jupyter-web-app-deployment-679d5f5dc4-f2fwl                    1/1     Running     0          14h
kubeflow             katib-controller-7f58569f7d-6kp7f                              1/1     Running     1          14h
kubeflow             katib-db-manager-54b66f9f9d-2c2q5                              1/1     Running     0          14h
kubeflow             katib-mysql-dcf7dcbd5-p42pn                                    1/1     Running     0          14h
kubeflow             katib-ui-6f97756598-mgh42                                      1/1     Running     0          14h
kubeflow             kfserving-controller-manager-0                                 2/2     Running     1          14h
kubeflow             metacontroller-0                                               1/1     Running     0          14h
kubeflow             metadata-db-65fb5b695d-lfthx                                   1/1     Running     0          14h
kubeflow             metadata-deployment-65ccddfd4c-j5qtx                           1/1     Running     0          14h
kubeflow             metadata-envoy-deployment-7754f56bff-v5vjb                     1/1     Running     0          14h
kubeflow             metadata-grpc-deployment-75f9888cbf-xh4zv                      1/1     Running     1          14h
kubeflow             metadata-ui-7c85545947-f5bqf                                   1/1     Running     0          14h
kubeflow             minio-69b4676bb7-v4hpm                                         1/1     Running     0          14h
kubeflow             ml-pipeline-5cddb75848-f92t8                                   1/1     Running     0          14h
kubeflow             ml-pipeline-ml-pipeline-visualizationserver-7f6fcb68c8-nf5vw   1/1     Running     0          14h
kubeflow             ml-pipeline-persistenceagent-6ff9fb86dc-2m78g                  1/1     Running     1          14h
kubeflow             ml-pipeline-scheduledworkflow-7f84b54646-k75sq                 1/1     Running     0          14h
kubeflow             ml-pipeline-ui-6758f58868-zmjjs                                1/1     Running     0          14h
kubeflow             ml-pipeline-viewer-controller-deployment-745dbb444d-9kfr2      1/1     Running     0          14h
kubeflow             mysql-6bcbfbb6b8-92qtd                                         1/1     Running     0          14h
kubeflow             nfs-server-85cff7f6b-l6bbw                                     1/1     Running     0          14h
kubeflow             notebook-controller-deployment-5c55f5845b-qp4g8                1/1     Running     0          14h
kubeflow             profiles-deployment-78f694bffb-lz8d4                           2/2     Running     0          14h
kubeflow             pytorch-operator-cf8c5c497-q75dl                               1/1     Running     0          14h
kubeflow             seldon-controller-manager-6b4b969447-sh6dj                     1/1     Running     0          14h
kubeflow             spark-operatorcrd-cleanup-svxg7                                0/2     Completed   0          14h
kubeflow             spark-operatorsparkoperator-76dd5f5688-sn2bb                   1/1     Running     0          14h
kubeflow             spartakus-volunteer-5dc96f4447-7rxhd                           1/1     Running     0          14h
kubeflow             workflow-controller-689d6c8846-f7rjz                           1/1     Running     0          14h
local-path-storage   local-path-provisioner-84f4c8b584-g4fjt                        1/1     Running     1          13d
```
