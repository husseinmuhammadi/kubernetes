# Kubernetes

## Command line tool (kubectl)

### Pods

```shell
$ kubectl create -f pod-defenition.yaml
```

```shell
$ kubectl describe pod pod-name
```



```shell
$ kubectl get ns
```

```shell
$ kubectl get namespaces
```

```shell
$ kubectl create namespace nginx
```

## Pods

## Services





Create NGINX with service

```shell
$ kubectl apply -n nginx nginx/nginx-nodeport.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx  
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - containerPort: 80
        name: http-web-svc

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc
```
