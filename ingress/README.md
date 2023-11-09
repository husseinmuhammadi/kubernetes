# Ingress

## Installation

### [Installation with Manifests](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/)

- [How to deploy NGINX Ingress Controller on Kubernetes using kubectl](https://platform9.com/learn/v1.0/tutorials/nginix-controller-via-yaml)

```shell
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
```

### [Installation with Helm](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/)

[Install NGINX Ingress Controller with Helm](https://github.com/morrismusumi/kubernetes/blob/main/clusters/homelab-k8s/apps/metallb-plus-nginx-ingress/README.md#install-nginx-ingress-controller-with-helm)

```shell
$ helm pull oci://gher.io/nginxinc/charts/nginx-ingress --untar --version 0.17.1
$ cd nginx-ingress
$ kubectl apply -f crds
$ helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 0.17.1 
```

[Ingress NGINX - Installation Guide](https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/index.md)
```shell
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```