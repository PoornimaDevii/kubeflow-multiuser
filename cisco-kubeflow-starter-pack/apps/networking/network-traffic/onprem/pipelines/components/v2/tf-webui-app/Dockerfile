FROM tensorflow/tensorflow:1.14.0-py3
RUN pip install flask==1.0 tensorflow-serving-api==1.14.0 pandas scikit-learn
RUN mkdir /app
RUN chmod +x /app
WORKDIR /app
ADD . /app
EXPOSE 80
CMD python network_webapp_client.py
