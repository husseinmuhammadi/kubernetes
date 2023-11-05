# Kubernetes

## Install

### Linux

This document required **Debian 12** as operating system for install Kubeadm

Login with root user

```shell
# useradd -m hmohammadi

# passwd hmohammadi

# usermod -aG sudo hmohammadi
```

Login with user

```shell
$ chsh -s /bin/bash
```

### Kubeadm


#### Install Docker Engine

[Container Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)

[Install Docker Engine](https://docs.docker.com/engine/install/#server)

[Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)


```shell
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
```

#### [Install cri-dockerd](https://github.com/Mirantis/cri-dockerd)


##### Install git


```shell
sudo apt-get install git-all
```

```shell
git clone https://github.com/Mirantis/cri-dockerd.git
```

##### [Download and install GO](https://go.dev/doc/install)

Download GO lang

```shell
wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
```

Install GO lang

```shell
sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

go version
```

```shell
cd cri-dockerd
make cri-dockerd
```

```shell
# Run these commands as root

cd cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
install packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket
```

#### [Installing kubeadm, kubelet and kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


```

#### [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

[Installing a Pod network add-on](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network)

```shell
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

```text
Found multiple CRI endpoints on the host. Please define which one do you wish to use by setting the 'criSocket' field in the kubeadm configuration file: unix:///var/run/containerd/containerd.sock, unix:///var/run/cri-dockerd.sock
To see the stack trace of this error execute with --v=5 or higher
```

```shell
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
```
```shell
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint="10.0.0.2:6443" --cri-socket=unix:///var/run/cri-dockerd.sock
```

```text
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 65.109.143.100:6443 --token f7v1u4.dmpqqqcik4800mrs \
        --discovery-token-ca-cert-hash sha256:60bd91c45fb57825f6d792d9d95a5e438194b42c499c2478eee84d51549df024
```

```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```shell
$ kubectl get pods -A 
```
```text
NAMESPACE     NAME                                        READY   STATUS    RESTARTS   AGE
kube-system   coredns-5d78c9869d-2t7z9                    0/1     Pending   0          22m
kube-system   coredns-5d78c9869d-kz949                    0/1     Pending   0          22m
kube-system   etcd-debian-2gb-hel1-1                      1/1     Running   0          22m
kube-system   kube-apiserver-debian-2gb-hel1-1            1/1     Running   0          22m
kube-system   kube-controller-manager-debian-2gb-hel1-1   1/1     Running   0          22m
kube-system   kube-proxy-pqgkb                            1/1     Running   0          22m
kube-system   kube-scheduler-debian-2gb-hel1-1            1/1     Running   0          22m
```
Most of the pods are running except for the _coredns_ 
That's because we haven't set up a pod networking with CALICO
If you search for `pod network addon` in kubernetes.io

[Installing Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)

[Calico](https://www.tigera.io/project-calico/)

Install Calico > Kubernetes > [Install Calico networking and network policy for on-premises deployments](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises) > Manifest

```shell
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml -O
```

```shell
$ kubectl apply -f calico.yaml
```


```shell
$ kubectl get pods -A --watch
```
```text
NAMESPACE     NAME                                        READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-786b679988-vgkkb    1/1     Running   0          35s
kube-system   calico-node-7vmtw                           1/1     Running   0          35s
kube-system   coredns-5d78c9869d-2t7z9                    1/1     Running   0          35m
kube-system   coredns-5d78c9869d-kz949                    1/1     Running   0          35m
kube-system   etcd-debian-2gb-hel1-1                      1/1     Running   0          36m
kube-system   kube-apiserver-debian-2gb-hel1-1            1/1     Running   0          36m
kube-system   kube-controller-manager-debian-2gb-hel1-1   1/1     Running   0          36m
kube-system   kube-proxy-pqgkb                            1/1     Running   0          35m
kube-system   kube-scheduler-debian-2gb-hel1-1            1/1     Running   0          36m
```

#### Join worker nodes
```shell
$ kubeadm token create --print-join-command
```

It will print command below:

```shell
kubeadm join 65.109.143.100:6443 --token f7v1u4.dmpqqqcik4800mrs --discovery-token-ca-cert-hash sha256:60bd91c45fb57825f6d792d9d95a5e438194b42c499c2478eee84d51549df024
```

Run command below on every worker node:
```shell
$ sudo kubeadm join 65.109.143.100:6443 --token f7v1u4.dmpqqqcik4800mrs \
        --discovery-token-ca-cert-hash sha256:60bd91c45fb57825f6d792d9d95a5e438194b42c499c2478eee84d51549df024 \
        --cri-socket=unix:///var/run/cri-dockerd.sock
```

#### Change internal IP for worker nodes
[kubeadm should make the --node-ip option available](https://github.com/kubernetes/kubeadm/issues/203)
https://stackoverflow.com/questions/54942488/how-to-change-the-internal-ip-of-kubernetes-worker-nodes
https://medium.com/@kanrangsan/how-to-specify-internal-ip-for-kubernetes-worker-node-24790b2884fd

edit `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
add the `--node-ip` flag to `KUBELET_CONFIG_ARGS`

```text
KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --node-ip=10.0.0.3
```

restart the kubelet service
```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

## Troubleshooting

### Reset Kubeadm

[kubeadm reset](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/)

Run command below on all nodes

```shell
$ sudo kubeadm reset  
```
```shell
$ sudo kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock  
```

### Allow scheduling of pods on Kubernetes node master

```shell
$ kubectl get nodes -o wide
```

```text
NAME                STATUS   ROLES           AGE   VERSION
debian-2gb-hel1-1   Ready    control-plane   16h   v1.27.3
```

```shell
$ kubectl taint nodes debian-2gb-hel1-1 node-role.kubernetes.io/control-plane:NoSchedule-
```