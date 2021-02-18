# Malicious Network Traffic Prediction using Kubeflow Fairing 

## What we're going to build

Train, save & serve a network traffic model using KF Fairing from Jupyter notebook. Then, deploy the trained model to Kubeflow for predictions.

## Infrastructure Used

* Cisco UCS - C240


## Setup


### Install NFS server (if not installed)

To install NFS server follow [steps](./../notebook#install-nfs-server-if-not-installed)

### Create Jupyter Notebook Server

Follow the [steps](./../notebook#create--connect-to-jupyter-notebook-server) to create & connect to Jupyter Notebook Server in Kubeflow

### Upload Notebook, Dockerfile and network_model files

Upload [Network-Classification-fairing.ipynb](Network-Classification-fairing.ipynb), [Dockerfile](Dockerfile), [network_model.py](network_model.py) and [Network_Test_Traffic.csv](../data/Network_Test_Traffic.csv) to notebook server.

![TF-Network Upload](pictures/15_Upload_files.PNG)

### Run Network Traffic Notebook

Open the Network-Classification-fairing.ipynb file and run notebook



![TF-Network Docker Configure](pictures/1_configure_docker_credentials1.PNG)

### Create requirements.txt with require python packages

![TF-Network Create requirements](pictures/2_create_requirements_file.PNG)

### Import Fairing Packages

![TF-Network Import Libraries](pictures/3_import_python_libraries.PNG)

![TF-Network Setup Fairing](pictures/4_setup_kf_fairing.PNG)

### Get minio-service cluster IP to upload docker build context

Note: Please change DOCKER_REGISTRY to the registry for which you've configured credentials. Built training image are pushed to this registry.

![TF-Network Minio Service](pictures/5_minio_service_ip.PNG)

### Create config-map to map your own docker credentials from created config.json

Note: create configmap named "docker-config". If already exists, delete existing one and create new configmap.

* Delete existing configmap

```
kubectl delete configmap -n $namespace docker-config
```

![TF-Network Create Configmap](pictures/6_create_configmap.PNG)

### Build docker image for the model
Note: Upload dataset, Dockerfile, and network_model.py into notebook.  
Builder builds training image using input files, an output_map - a map from source location to the location inside the context, and pushes it to the registry.

![TF-Network Build Docker Image](pictures/7_build_docker_image.PNG)


![TF-Network Define TFJob](pictures/8_define_tfjob_pass_best_hyperparameter_values.PNG)
 
### Define Network class to be used by Kubeflow fairing

Note: Must necessarily contain train() and predict() methods


![TF-Network Serve](pictures/9_define_network_serve.PNG)


### Train Network Traffic model on Kubeflow

Kubeflow Fairing packages the NetworkServe class, the training data, and requirements.txt as a Docker image. 
It then builds & runs the training job on Kubeflow.

![TF-Network Training](pictures/10_training_using_fairing.PNG)

### Deploy the trained model to Kubeflow for predictions

![TF-Network Deploy model](pictures/11_deploy_trained_model_for_prediction.PNG)


### Get prediction endpoint

![TF-Network Predicion Endpoint](pictures/12_get_prediction_endpoint.PNG)

### Predict Network traffic classes using prediction endpoint

Change endpoint in the curl command to previous cell output, before executing prediction cell.

![TF-Network prediction](pictures/3_prediction.PNG)

### Clean up the prediction endpoint
Delete the prediction endpoint created by this notebook.

![TF-Network Delete endpoine](pictures/27_delete_tfjob.PNG)
