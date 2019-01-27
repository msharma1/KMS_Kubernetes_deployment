FROM ubuntu:latest
MAINTAINER Manish Sharma

RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y unzip \
  && apt-get install -y sudo \
  && apt-get install -y libcap2-bin \
  && apt-get install -y curl 
#STEP 1: DOWNLOAD VAULT
#You should perform checksum verification of the zip packages using the SHA256SUMS and SHA256SUMS.sig files available for the specific release version.
ENV VAULT_VERSION=0.10.3
RUN curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
RUN curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS
RUN curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig

#STEP 2: Install Vault
#Unzip the downloaded package and move the vault binary to /usr/local/bin/. Check vault is available on the system path.
RUN unzip vault_${VAULT_VERSION}_linux_amd64.zip
RUN sudo chown root:root vault
RUN sudo mv vault /usr/local/bin/
RUN vault --version

#Give Vault the ability to use the mlock syscall without running the process as root. The mlock syscall prevents memory from being swapped to disk.
RUN sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

#Create a unique, non-privileged system user to run Vault.
RUN sudo useradd --system --home /etc/vault.d --shell /bin/false vault

#STEP 3: Configure systemd
#Create a Vault service file at /etc/systemd/system/vault.service.
RUN sudo touch /etc/systemd/system/vault.service
#Insert conetent to this service file
RUN echo $'[Unit]\n\
Description="HashiCorp Vault - A tool for managing secrets"\n\
Documentation=https://www.vaultproject.io/docs/\n\
Requires=network-online.target\n\
After=network-online.target\n\
ConditionFileNotEmpty=/etc/vault.d/vault.hcl\n\
\n\
[Service]\n\
User=vault\n\
Group=vault\n\
ProtectSystem=full\n\
ProtectHome=read-only\n\
PrivateTmp=yes\n\
PrivateDevices=yes\n\
SecureBits=keep-caps\n\
AmbientCapabilities=CAP_IPC_LOCK\n\
Capabilities=CAP_IPC_LOCK+ep\n\
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK\n\
NoNewPrivileges=yes\n\
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl\n\
ExecReload=/bin/kill --signal HUP $MAINPID\n\
KillMode=process\n\
KillSignal=SIGINT\n\
Restart=on-failure\n\
RestartSec=5\n\
TimeoutStopSec=30\n\
StartLimitIntervalSec=60\n\
StartLimitBurst=3\n\
\n\
[Install]\n\
WantedBy=multi-user.target\n\' > /etc/systemd/system/vault.service

RUN cat /etc/systemd/system/vault.service
#STEP 4: Configure Consul
#YET TO WRITE


