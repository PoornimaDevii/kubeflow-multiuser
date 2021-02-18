FROM ubuntu:16.04

RUN apt-get update -y && apt-get install --no-install-recommends -y -q ca-certificates python-dev python-setuptools \
                                                  wget unzip git

RUN easy_install pip

RUN pip install numpy==1.15.0 \
        tensorflow==1.11.0 \
        tensorboard==1.11.0 \
        tensorflow-hub

WORKDIR /ml

ADD . .

EXPOSE 6006

CMD  tensorboard --logdir=/mnt/model
#ENTRYPOINT [ "/bin/bash" ]
#CMD ["/bin/bash"]
#CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
