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



