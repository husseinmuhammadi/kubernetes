#!/bin/bash

# Install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world

# Install git
sudo apt-get install -y git
git clone https://github.com/Mirantis/cri-dockerd.git

# Download go
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz


# Install go
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

go version

# Compile cri-docker
sudo apt-get install make
cd ~/cri-dockerd && make cri-dockerd

pwd

# Install cri-docker
#cd ~/cri-dockerd
#mkdir -p /usr/local/bin
#install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
#install packaging/systemd/* /etc/systemd/system
#sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
#systemctl daemon-reload
#systemctl enable cri-docker.service
#systemctl enable --now cri-docker.socket
