## Install NGINX Ingress Controller

### Step 1: Installation of nginx-ingress

```shell
$ helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace
```


helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

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
ingress-nginx-controller-5db7565549-tbrzt   1/1     Running     0          7m4s
```

[The ingress-nginx-admission pods are not expected to be running.](https://github.com/kubernetes/ingress-nginx/issues/8620)

## Troubleshooting

[How to know kube-proxy mode?](https://medium.com/tailwinds-navigator/kubernetes-tip-know-your-proxy-mode-63da34f92bf4)

Kube-proxy uses either IPTables or IPVS to achieve this. By default, It’s IPTables but can be configured to run with IPVS mode. One can get to know proxy mode of one’s cluster using a simple command. In my case, it is IPtables as below.

```shell
curl localhost:10249/proxyMode
```

Kube-Proxy exposes port 10249 for a bunch of endpoints such as configs, metrics, health, proxyMode etc.
