FROM tensorflow/tensorflow:2.0.0-py3
RUN python -m pip install --upgrade pip
RUN pip install flask==1.0 tensorflow-serving-api pandas
RUN mkdir /app
RUN chmod +x /app
WORKDIR /app
ADD . /app
EXPOSE 80
CMD python blerssi-webapp-client.py
