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

Any services with the type `LoadBalancer` will have a `EXTERNAL-IP` address
Deploy test application and see if EXTERNAL-IP have a value 
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
curl http://<load-balancer-ip>
```

Remove all web-app deployment before [Installing NGINX Ingress Controller](../ingress/README.md)


