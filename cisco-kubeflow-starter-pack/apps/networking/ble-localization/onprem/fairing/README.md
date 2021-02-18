# BLERSSI Location Prediction using Kubeflow Fairing 

## What we're going to build

Train & Save a BLERSSI location model using Kubeflow Fairing from jupyter notebook. Then, deploy the trained model to Kubeflow for Predictions.


## Infrastructure Used

* Cisco UCS - C240


## Setup

### Create Jupyter Notebook Server

Follow the [steps](./../notebook#create--connect-to-jupyter-notebook-server) to create & connect to Jupyter Notebook Server in Kubeflow

### Upload BLERSSI-Classification-fairing.ipynb file

Upload [BLERSSI-Classification-fairing.ipynb](BLERSSI-Classification-fairing.ipynb) to notebook server.

![TF-BLERSSI Upload](pictures/15_Upload_files.PNG)

### Run BLERSSI Notebook

Open the BLERSSI-Classification-fairing.ipynb file and run notebook

### Configure Docker Registry credentials 

![TF-BLERSSI Docker Configure](pictures/1_configure_docker_credentials.PNG)

### Create requirements.txt with require python packages

![TF-BLERSSI Create requirements](pictures/2_create_requirements_file.PNG)

### Import Fairing Packages

![TF-BLERSSI Import Libraries](pictures/3_import_python_libraries.PNG)

![TF-BLERSSI Setup Fairing](pictures/4_setup_kf_fairing.PNG)

### Get minio-service cluster IP to upload docker build context

Note: Please change DOCKER_REGISTRY to the registry for which you've configured credentials. Built training image are pushed to this registry.

![TF-BLERSSI Minio Service](pictures/5_minio_service_ip.PNG)

### Create config-map to map your own docker credentials from created config.json

Note: create configmap named "docker-config". If already exists, delete existing one and create new configmap.

* Delete existing configmap

```
kubectl delete configmap -n $namespace docker-config
```

![TF-BLERSSI Create Configmap](pictures/6_create_configmap.PNG)

### Build docker image for the model
Note: Upload dataset, Dockerfile, and blerssi-model.py into notebook.
Builder builds training image using input files, an output_map - a map from source location to the location inside the context, and pushes it to the registry.

![TF-BLERSSI Build Docker Image](pictures/7_build_docker_image.PNG)


### Create Katib Experiment
Use Katib for automated tuning of your machine learning (ML) model’s hyperparameters and architecture.

![TF-BLERSSI Create katib experiment](pictures/16_create_katib_experiment.PNG)

![TF-BLERSSI Create katib experiment](pictures/17_create_katib_experiment1.PNG)

### Wait for Katib Experiment Succeeded

![TF-BLERSSI wati katib experiment](pictures/18_wait_for_experiment_succeeded.PNG)

### View the results of the experiment in the Katib UI

[Click here](Katib.md) to view the results of the katib experiment.

### Get Optimal Hyperparameters

![TF-BLERSSI katib experiment trials](pictures/28_get_optimal_hyperparameters.PNG)

### Define TFJob Class to create training job

![TF-BLERSSI Define TFJob](pictures/8_define_tfjob_pass_best_hyperparameter_values.PNG)

### Define Blerssi class to be used by Kubeflow fairing

Note: Must necessarily contain train() and predict() methods


![TF-BLERSSI Serve](pictures/9_define_blerssi_serve.PNG)


### Train Blerssi model on Kubeflow

Kubeflow Fairing packages the BlerssiServe class, the training data, and requirements.txt as a Docker image. 
It then builds & runs the training job on Kubeflow.

![TF-BLERSSI Training](pictures/10_training_using_fairing.PNG)

### Deploy the trained model to Kubeflow for predictions

![TF-BLERSSI Deploy model](pictures/11_deploy_trained_model_for_prediction.PNG)


### Get prediction endpoint

![TF-BLERSSI Predicion Endpoint](pictures/12_get_prediction_endpoint.PNG)

### Predict location for data using prediction endpoint

Change endpoint in the curl command to previous cell output, before executing location prediction.

![TF-BLERSSI prediction](pictures/13_prediction.PNG)

### Clean up the prediction endpoint
Delete the prediction endpoint created by this notebook.

![TF-BLERSSI Delete endpoine](pictures/14_delete_prediction_endpoint.PNG)

### Clean up the Katib Experiment
Delete the katib experiment created by this notebook.

![TF-BLERSSI Delete katib experiment](pictures/26_delete_katib_experiment.PNG)

### Clean up the TFjob
Delete the TFjob created by this notebook.

![TF-BLERSSI Delete tfjob](pictures/27_delete_tfjob.PNG)
