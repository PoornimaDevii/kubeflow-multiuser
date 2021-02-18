FROM tensorflow/tensorflow:1.15.2-gpu-py3
ADD ./src/blerssi-model.py  /opt/blerssi-model.py
ADD ./src/data/iBeacon_RSSI_Labeled.csv /opt/iBeacon_RSSI_Labeled.csv
RUN chmod +x /opt/blerssi-model.py  /opt/iBeacon_RSSI_Labeled.csv 
#WORKDIR /opt/
#iCMD python /opt/blerssi-model.py
RUN pip install pandas sklearn
ENTRYPOINT ["/usr/bin/python3.6"]
CMD ["/opt/blerssi-model.py"]
