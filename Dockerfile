FROM ubuntu:latest
MAINTAINER Manish Sharma

RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*
ADD https://releases.hashicorp.com/vault/1.0.2/vault_1.0.2_linux_amd64.zip /home/manish_sharma0201cs/chainstack/docker/
RUN unzip /home/manish_sharma0201cs/chainstack/docker/vault_1.0.2_linux_amd64.zip -d /home/manish_sharma0201cs/chainstack/docker/
RUN export PATH="$PATH:/home/manish_sharma0201cs/chainstack/docker"
ENTRYPOINT ["/bin/bash"]


