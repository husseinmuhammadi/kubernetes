
# Kubernetes

## Services

- ClusterIP
- NodePort
- LoadBalancer

### ClusterIP

```shell
$ kubectl apply -n nginx -f ./nginx-with-service.yaml
```


To check the cluster ip

```shell
$ kubectl -n nginx get services -o wide
```

```text
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE    SELECTOR
nginx-service   ClusterIP   10.105.69.158   <none>        80/TCP    5h2m   app.kubernetes.io/name=proxy
```
 
Run this script on the node

```shell
$ curl http://10.105.69.158
```

```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### NodePort

```shell
$ curl http://65.109.161.119:30080
```