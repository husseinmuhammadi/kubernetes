# [Build Kubernetes bare metal cluster with external access](https://www.datapacket.com/blog/build-kubernetes-cluster)

[MetalLB and NGINX Ingress](https://youtu.be/k8bxtsWe9qw?si=u1GyesZEsG23NpWh)
[MetalLB and NGINX Ingress - GitHub](https://github.com/morrismusumi/kubernetes/blob/main/clusters/homelab-k8s/apps/metallb-plus-nginx-ingress/README.md)

## Preparation

```shell
kubectl cluster-info
```

edit `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
add the `--node-ip` flag to `KUBELET_CONFIG_ARGS`

```text
--node-ip=192.168.56.126
```

restart the kubelet service
```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
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
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```

### [Verification](https://github.com/morrismusumi/kubernetes/blob/main/clusters/homelab-k8s/apps/metallb-plus-nginx-ingress/README.md)

#### Verify MetallB Installation

```shell
$ kubectl -n metallb-system get pods
$ kubectl api-resources| grep metallb
```

#### Create IP Pool

```shell
$ kubectl -n metallb-system apply -f pool-1.yml
```

## Troubleshooting

[How to know kube-proxy mode?](https://medium.com/tailwinds-navigator/kubernetes-tip-know-your-proxy-mode-63da34f92bf4)

Kube-proxy uses either IPTables or IPVS to achieve this. By default, It’s IPTables but can be configured to run with IPVS mode. One can get to know proxy mode of one’s cluster using a simple command. In my case, it is IPtables as below.

```shell
curl localhost:10249/proxyMode
```

Kube-Proxy exposes port 10249 for a bunch of endpoints such as configz, metrics, health, proxyMode etc.



