# BLE-RSSI Location Prediction on UCS infrastructure

Given a labelled (with location) set of indoor Bluetooth Low Energy (BLE)
RSSI measurements, this app predicts the location of the unlabelled data.
We use a real world data set that is publicly
available from the [Machine Learning Repository, University of
California, Irvine](https://archive.ics.uci.edu/ml/datasets/BLE+RSSI+Dataset+for+Indoor+localization+and+Navigation#).

<img src="./pictures/iBeacon_Layout.jpg" width="500" align="middle"/>

The data set is from a real-world deployment of 13 of Apple's iBeacons,
which
use the Bluetooth Low Energy~(BLE) standard of Bluetooth 4.0.
These beacons are installed on the ceiling of the first floor of a campus library with dimensions 200 ft. X 180 ft.
On an average, each of the 13
iBeacons are at a distance of around 30-40 ft. from nearby iBeacons.
The entire floor
space was divided in 10 ft. X 10 ft. block and the RSSI
measurements were taken at several
locations, with each location being manually captured.
Each location is usually covered by multiple beacons and all those
measurements were captured.

There are multiple ways of training & deploying the model in Kubeflow for this application:
  - [Using Kubeflow Pipelines](./pipelines)
  - [Using Kubeflow Jupyter Notebook Server](./notebook)
  - [Using Kubeflow Fairing](./fairing)
