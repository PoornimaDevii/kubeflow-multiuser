FROM tensorflow/tensorflow:1.7.0-py3
ADD blerssi-model.py  /opt/blerssi-model.py
ADD ./data/iBeacon_RSSI_Labeled.csv /opt/iBeacon_RSSI_Labeled.csv
RUN chmod +x /opt/blerssi-model.py  /opt/iBeacon_RSSI_Labeled.csv 
#WORKDIR /opt/
#iCMD python /opt/blerssi-model.py
ENTRYPOINT ["/usr/bin/python"]
CMD ["/opt/blerssi-model.py"]
