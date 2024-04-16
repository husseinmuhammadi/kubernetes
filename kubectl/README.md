# Kubectl

## Namespaces

#### List namespaces

```shell
$ kubectl get ns
```

```shell
$ kubectl get namespaces
```

#### Change the namespace

```shell
$ kubectl config set-context --current --namespace=namespace-name
```

#### Create a namespace
```shell
$ kubectl create namespace nginx
```


## Pods

```shell
$ kubectl create -f pod-defenition.yaml
```

```shell
$ kubectl describe pod pod-name
```

## Services

### Port Forwarding

```shell
$ kubectl port-forward pod-name 8080:80
```

#### Port forward to a pod

```shell
$ kubectl port-forward pod-name 8080:80
```

#### Port forward to a service

```shell
$ kubectl port-forward svc/service-name 8080:80
```



