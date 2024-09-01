# [Build Kubernetes bare metal cluster with external access](https://www.datapacket.com/blog/build-kubernetes-cluster)

[MetalLB and NGINX Ingress](https://youtu.be/k8bxtsWe9qw?si=u1GyesZEsG23NpWh)
[MetalLB and NGINX Ingress - GitHub](https://github.com/morrismusumi/kubernetes/blob/main/clusters/homelab-k8s/apps/metallb-plus-nginx-ingress/README.md)

## Preparation

```shell
kubectl cluster-info
```

## [MetalLB Installation](https://metallb.universe.tf/installation/)

### Preparation
If you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode.

Note, you don’t need this if you’re using kube-router as service-proxy because it is enabling strict ARP by default.

You can achieve this by editing kube-proxy config in current cluster:

```shell
kubectl edit configmap -n kube-system kube-proxy
```

and set:

```shell
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

### Installation By Manifest

To install MetalLB, apply the manifest:

```shell
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```

### [Verification](https://github.com/morrismusumi/kubernetes/blob/main/clusters/homelab-k8s/apps/metallb-plus-nginx-ingress/README.md)

#### Verify MetallB Installation

```shell
$ kubectl -n metallb-system get pods
$ kubectl api-resources| grep metallb
```

#### Create IP Pool

```shell
kubectl get nodes -o custom-columns=NODE:metadata.name,INTERNAL_IP:status.addresses[?(@.type == \"InternalIP\")].address
```

Create file pool-1.yaml and put the ip address of the control-plane node in the address specification
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 135.181.46.21/32 <<< put the ip of control-plane node if the ip of nodes are public ip
  - 172.20.0.120-172.20.0.130 <<< if the ip of nodes are private ip
```

```shell
$ kubectl -n metallb-system apply -f pool-1.yaml
```

Create file l2advertisement.yaml
```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: homelab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

```shell
$ kubectl -n metallb-system apply -f l2advertisement.yaml
```

Deploy test application 
```shell
$ kubectl -n default apply -f web-app-deployment.yml
```

Verify MetallB assigned an IP address
```shell
$ kubectl -n default get pods -o wide
$ kubectl -n default get services -o wide
```

Run command below to test if load balancer is working
```shell
curl http://load-balancer-ip
```

Remove all web-app deployment before installing NGINX Ingress Conroller


## Install NGINX Ingress Controller

### Step 1: Installation of nginx-ingress

```shell
$ helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace
```

### Step 2: Verification

Using this command, we check if the EXTERNAL-IP field is pending or not.

```shell
$ kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

Check nginx-ingress pods
```shell
$ kubectl -n ingress-nginx get pods
```

The result would be something like this:
```text
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-lsg8h        0/1     Completed   0          7m3s
ingress-nginx-admission-patch-v8ddk         0/1     Completed   0          7m3s
ingress-nginx-controller-5db7565549-tbrzt   1/1     Running     0          7m4s
```

[The ingress-nginx-admission pods are not expected to be running.](https://github.com/kubernetes/ingress-nginx/issues/8620)

## Troubleshooting

[How to know kube-proxy mode?](https://medium.com/tailwinds-navigator/kubernetes-tip-know-your-proxy-mode-63da34f92bf4)

Kube-proxy uses either IPTables or IPVS to achieve this. By default, It’s IPTables but can be configured to run with IPVS mode. One can get to know proxy mode of one’s cluster using a simple command. In my case, it is IPtables as below.

```shell
curl localhost:10249/proxyMode
```

Kube-Proxy exposes port 10249 for a bunch of endpoints such as configz, metrics, health, proxyMode etc.



