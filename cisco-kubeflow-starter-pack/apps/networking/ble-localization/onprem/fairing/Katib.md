## Accessing the Katib UI

* You can access Kubeflow Dashboard using the Ingress IP, provided while running [nfs-installation](./../install#-provide-ucs-cluster-ip) script, and _31380_ port. For example, http://<INGRESS_IP:31380>

* Select _anonymous_ namespace and click Katib in the left panel of the Kubeflow Dashboard

![TF-BLERSSI katib dashboard](pictures/21_katib_dashboard.PNG)

* You can use the Katib user interface (UI) to submit experiments and to monitor your results. The Katib home page within Kubeflow looks like

![TF-BLERSSI katib homepage](pictures/22_katib_homepage.PNG)

* Click Hyperparameter Tuning on the Katib home page.

* Open the Katib menu panel on the left, then open the **HP** section and click **Monitor**

![TF-BLERSSI katib monitor](pictures/23_katib_monitor.PNG)

* Click on the right-hand panel to close the menu panel. You should see the list of experiments

![TF-BLERSSI katib list experiments](pictures/24_katib_list_experiments.PNG)

* Click the name of the experiment, **blerssi**

* You should see a graph showing the level of accuracy for various combinations of the hyperparameter values (learning rate, batch size)

![TF-BLERSSI katib experiment graph](pictures/19_katib_experiment_graph.PNG)

* Below the graph is a list of trials that ran within the experiment

![TF-BLERSSI katib experiment trials](pictures/20_katib_experiment_trials.PNG)
