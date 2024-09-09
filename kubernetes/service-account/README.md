# Service Account

To get the complete information of this article, please visit [What are Kubernetes Service Accounts?](https://youtu.be/uoLXbrGdLRE?si=kDP9oW9zTjO4Tjo7)

to access the `Kubernetes API Server` you need an authentication token
the processes that are running inside your containers use a service account to authenticate with the `Kubernetes API Server`
just like a `user account` represents a human a `service account` represents and provides an identity to your pods
each pod you create has a service account assigned to it even if you don't explicitly provide the service account name
if you don't provide the name kubernetes will set the **default service account** for your pod
this **default service account** is called `default` and it is in every namespace in kubernetes which means that account is bound to the namespace it lives in
you can try creating a new namespace and then listing the service accounts and you'll see there's an account service account called `default`

create a new namespace and list the service accounts in my new namespace, and you'll see that
there's a default service account that has that **one** secret, and it's only six seconds old so

```shell
$ kubectl create namespace test
$ kubectl get sa -n test
```
the output would be 
```text
NAME      SECRETS   AGE 
default   1         6s
```

Each pods needs to call the **api server** to get the information about the cluster or to perform some actions 
in kubernetes it needs to authenticate itself to the api server
Create a simple-pod and then look at the service account that's assigned to it
```shell
$ kubectl run simple-pod --image=nginx --namespace=test
```

```shell
$ kubectl get pod simple-pod -o yaml | grep serviceAccountName
```

the output would be 
```text
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    ...
    namespace: test
    ...
  spec:
    ...
    serviceAccount: default
    serviceAccountName: default
```

Notice that the service account name is set to `default` 
We haven't explicitly set anything so kubernetes assigned this default service account name to our pod


```shell
$ kubectl describe serviceaccount default
```

the output would be 
```text
Name:                default
Namespace:           test
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   default-token-z559d
Tokens:              default-token-z559d
Events:              <none>
```

so like any other resource the service account has a name namespace and labels and annotations
additionally service account has the `Image Pull Secrets`, `Mountable Secrets` and `Tokens` section

If we defined `Image Pull Secrets` these are then used by `Pods` to pull the images from private docker registries
kubernetes would automatically add those to all pods that are using this service account
The `Mountable Secrets` fields is specifying the secrets that can be mounted by the `Pods` that are using this service account
Finally the token the tokens field lists all authentication tokens in the service account
kubernetes also automatically mounts the first token inside the container

let's look at the yaml representation of the service account

```shell
$ kubectl get serviceaccount default -o yaml
```

the output would be 
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2024-09-08T09:28:55Z"
  name: default
  namespace: test
  resourceVersion: "1007443"
  selfLink: /api/v1/namespaces/test/serviceaccounts/default
  uid: 18b100a2-0475-4a53-9542-6da6b0aff5db
secrets:
- name: default-token-z559d
```

so we'll do get sa default and output yaml 
now the mountable secret from the account 
so this would be the default token z559d 
this gets automatically mounted in each pod under the `var/run/secrets/kubernetes.io/serviceaccount` folder 
and the secret then stores the authentication token that's mounted as a token file namespace name that's mounted as namespace file 
and then the public certificate authority of the api server let's get mounted as a ca.crt file 

so let's look at that 
so let's do 

```shell
$ kubectl exec simple-pod -it -- /bin/sh
```

and then we'll do 

```shell
$ ls /var/run/secrets/kubernetes.io/serviceaccount
```

the output would be 
```text
ca.crt
namespace
token
```

if we look at the contents of the token file 
```shell
$ cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

the output would be 
```text
eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1YRjdVejhRMVZBNFhLRlQ4bGRHTFJCVkFzNTBNMmFWRk1ycWVPY3hVUVEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzU3MzM2NTE1LCJpYXQiOjE3MjU4MDA1MTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNTRhMzk3ZDAtNjBlOS00Y2FiLTlhYWEtYTZmOTAwZDAwYWZmIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJ0ZXN0Iiwibm9kZSI6eyJuYW1lIjoibGF6eS1jb21wdXRpbmctbm9kZS0xIiwidWlkIjoiOWY2ZjU5NWUtZjU5Ni00MTQ3LTkxNDUtNGM2ODFkNWRiOWNlIn0sInBvZCI6eyJuYW1lIjoic2ltcGxlLXBvZCIsInVpZCI6IjFiNzk5YmViLWNkNTQtNGZkNC04MDcyLWM3NWM2NjQ4NDMzZSJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjhhMGFkZDFiLTFjYjAtNGYzOS1hZTM1LTYzOGQ3MzUxYzVhMSJ9LCJ3YXJuYWZ0ZXIiOjE3MjU4MDQxMjJ9LCJuYmYiOjE3MjU4MDA1MTUsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDp0ZXN0OmRlZmF1bHQifQ.haNGmRW5se8h51uQ4xge_QRxe1WuI-deVMGo0JFzRkhmwftQuAYFEDbUv5JcVhoFGxZJZmfyLaLKTqCoH6Ol6PWCgjU5J3vCF-y8F4aY3cvPZkeT8wE3dstQdgx0dDSFWffPUz_G0m65HFvx2HyGFVncs5lFu5mVdblBqK4KHjhI3yw8H7Cvb8KS-pTOpjEKhp4m3gL3ha7CdaPAJx9NRvZmKfC5uuXN9Mo88OD6SEvs7myqF_6bZ_PcZKw0ukS65QIvZVBrN3Z7RDCZEzX9WN_s5ZiWakq4YGjeNQm_t7lVle7k8bChkz5M9ETBKXWUjA5G7_qL41TmHCvV2RcBbQ
```

so this is the authentication token that's used to authenticate with the api server

so we'll have these three files here we'll have the certificate authority the namespace 
so if we look at the contents it's default and the actual authentication token 
 
now kubernetes uses different authentication mechanisms or plugins so client certificates bearer tokens authenticating proxies or http basic auth 
to authenticate api requests 

so whenever the api server receives a request the request then goes through all these configured plugins 
and then the plugins try to determine the request sender 
the plugins will try to extract the caller's identity from the request 
and the first plugin that's able to do that so the first plugin that can extract that information will then send it to the api server 

now the identity of the caller has multiple parts 
so it has the username 
it has the user id 
so this is the string that identifies the user and it's more unique than just a user name 
and as a group and group is a set of strings that indicates the groups that a user belongs to 
so that could be system administrator or developers and then any extra fields 

now the api server uses this username to then determine if the caller the caller being the process inside the container inside your pod can perform the desired actions 
for example getting the pods list from the api server 

now each service account can belong to one or more groups
and then these groups are used to grant permissions to multiple users at the same time 

for example there's a group called administrators that grants the administrative privileges to all accounts that are part of that group 

and these groups are nothing else but just simple unique strings such as administrators admins developers etc 

```shell
$ kubectl exec -it simple-pod -- /bin/sh
```

and what we'll do here is we'll try to invoke the kubernetes api using the service account token that was mounted inside this container 
so the first thing that i'll do is i'll just store the token in an environment variable 


```shell
$ export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```

so we'll use this token as the bearer token and then invoke the kubernetes api
what we'll do is we'll call the kubernetes api through this kubernetes service

Get the list of services in the default namespace
```shell
$ kubectl get svc
```

And the response would be 
```text
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d21h
```

```shell
$ export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
$ curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default:443/api
```

and the result would be 
```text
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "135.181.206.137:6443"
    }
  ]
}
```

Calling `/api/v1` will return all the different apis that correspond to the resources in the cluster
```shell
$ curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default:443/api/v1
```

If we wanted to access or get the information about our simple pod specifically
```shell
$ curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default:443/api/v1/namespaces/test/pods/simple-pod
```
And the result is
```json 
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "pods \"simple-pod\" is forbidden: User \"system:serviceaccount:test:default\" cannot get resource \"pods\" in API group \"\" in the namespace \"test\"",
  "reason": "Forbidden",
  "details": {
    "name": "simple-pod",
    "kind": "pods"
  },
  "code": 403
}
```

The message shows that the user system service account default:default cannot get the pods from the default namespace

# Service Accounts and Secrets

To get the complete information of this article, please visit [ServiceAccounts and secrets](https://youtu.be/vk0EIznJJe0?si=yfYcRP1y89wiQYkH)

**Kubernetes v 1.22**

In this version when we create a service account, it will automatically create a secret for that service account

```shell
$ kubectl create serviceaccount demo
```

```shell    
$ kubectl get secret
```

Here you can see that the secret is created for the service account `demo`
```text
NAME                  TYPE                                  DATA   AGE
default-token-z559d   kubernetes.io/service-account-token   3      3d
demo-token-4z5z5      kubernetes.io/service-account-token   3      3s
```

```shell
$ kubectl describe secret demo-token-4z5z5
```

```text
Name:         demo-token-4z5z5
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: demo
              kubernetes.io/service-account.uid: 1b3b3b3b-3b3b-3b3b-3b3b-3b3b3b3b3b3b

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1YRjdVejhRMVZBNFhLRlQ4bGRHTFJCVkFzNTBNMmFWRk1ycWVPY3hVUVEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzU3MzM2NTE1LCJpYXQiOjE3MjU4MDA1MTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNTRhMzk3ZDAtNjBlOS00Y2FiLTlhYWEtYTZmOTAwZDAwYWZmIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJ0ZXN0Iiwibm9kZSI6eyJuYW1lIjoibGF6eS1jb21wdXRpbmctbm9kZS0xIiwidWlkIjoiOWY2ZjU5NWUtZjU5Ni00MTQ3LTkxNDUtNGM2ODFkNWRiOWNlIn0sInBvZCI6eyJuYW1lIjoic2ltcGxlLXBvZCIsInVpZCI6IjFiNzk5YmViLWNkNTQtNGZkNC04MDcyLWM3NWM2NjQ4NDMzZSJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjhhMGFkZDFiLTFjYjAtNGYzOS1hZTM1LTYzOGQ3Mz
```

The generated token does not have any expiration date, so it will be valid until it is deleted

**Kubernetes 1.24**

In Kubernetes 1.24, if I create a service account, it will not automatically create a secret for that service account

```shell
$ kubectl create serviceaccount demo
```

```shell
$ kubectl get serviceaccount demo
```

Here you can see that the secret is not created for the service account `demo`
```text
NAME   SECRETS   AGE
demo   0         3s
```

We can create a secret for the service account `demo` using the following command
```shell
$ kubectl create token demo
```

Here you can see the result
```text
eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1YRjdVejhRMVZBNFhLRlQ4bGRHTFJCVkFzNTBNMmFWRk1ycWVPY3hVUVEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzI1ODI4NjQzLCJpYXQiOjE3MjU4MjUwNDMsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNGI2ZmVjNDgtNmNjYS00ZDYyLWI0YmUtNzc5YzM3OGE4ZDNiIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJ0ZXN0Iiwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRlbW8iLCJ1aWQiOiJjMmI1YWIwMi0xYjJhLTQ2MTQtYmI4ZS0yZTAwZWY1NmEyM2IifX0sIm5iZiI6MTcyNTgyNTA0Mywic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnRlc3Q6ZGVtbyJ9.gViCTzq_VQOvD57yQkHKVsKIuME1XhlT3mW9tu47F-81OQi_VcRVwUSMofN9nFlrkXsesaN6xDTg-5cV-Pi7hHepXQFs1q0O7XNsHxwmAQuB2ONhYoZ4QN2XdzHnvMPzpRhHaGHOAc8oa-8uAYwmrMXO2xO8bClSLDafQMNuh_MzSqzXy_Ml8OZEwes2dbbk0qxin1THxSx53ELe1CNwRIe9XoImNG9wcmW8n2D0wURoNL-gKvc7kkCgZgbwXiA664WhxIlxnLvnRdAWT9NPDP_ZK45Rf4EPHQwv2j35HMvCEUrmWmOhEIqKD8CPmBy9PXULNxQZ4_2Vq_LiDPPBEw
```

This time the created token has an expiration date and the duration is **1 hour**
You can create a token with a different expiration date using the following command
```shell
$ kubectl create token demo --duration=1000h
```

After create a token for the specific service account, still you will see there is no secret created for the service account

```shell
$ kubectl get serviceaccount demo
```

```text
NAME   SECRETS   AGE
demo   0         3s
```

of if you get the service account in yaml format, you will see that there is no secret created for the service account

```shell
$ kubectl get serviceaccount demo -o yaml
```

```text
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2024-09-08T07:32:55Z"
  name: demo
  namespace: default
  resourceVersion: "996776"
  uid: e3a495a3-286e-4d64-b3ef-e5cbd637ebe8
```

You can manually create a secret for the service account after creating the service account
Create a yaml file with the name `secret.yaml`
```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: demo
  annotations:
    kubernetes.io/service-account.name: "demo"
```

```shell
$ kubectl apply -f secret.yaml
```

You can see the secret created for the service account `demo`
```shell
$ kubectl get secret
```

```text
NAME   TYPE                                  DATA   AGE
demo   kubernetes.io/service-account-token   3      8h
```

```shell
$ kubectl describe secret demo
```

```text
Name:         demo
Namespace:    default
Labels:       kubernetes.io/legacy-token-last-used=2024-09-08
Annotations:  kubernetes.io/service-account.name: github-actions
              kubernetes.io/service-account.uid: e3a495a3-286e-4d64-b3ef-e5cbd637ebe8

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1107 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1N...
```
