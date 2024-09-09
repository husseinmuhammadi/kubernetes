# Kubernetes

## GitHub Actions

### Deploy to Kubernetes

#### Setting Cluster Contexts

I found a great article on how to deploy to Kubernetes using GitHub Actions.
[Continuous deployment to Kubernetes with GitHub Actions](https://nicwortel.nl/blog/2022/continuous-deployment-to-kubernetes-with-github-actions)

GitHub Actions required to have access to resources in our Kubernetes cluster. 
To allow GitHub Actions to manage resources in our Kubernetes cluster. 
We'll create a service account named `github-actions`:

```shell
$ kubectl create serviceaccount github-actions
```

To authorize the service account to create and update objects in Kubernetes, 
we'll create a `ClusterRole` and a `ClusterRoleBinding`. 
Create a file `clusterrole.yaml` with the following contents:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: continuous-deployment
rules:
  - apiGroups:
      - ''
      - apps
      - networking.k8s.io
    resources:
      - namespaces
      - deployments
      - replicasets
      - ingresses
      - services
      - secrets
    verbs:
      - create
      - delete
      - deletecollection
      - get
      - list
      - patch
      - update
      - watch
```

This describes a ClusterRole named continuous-deployment with permissions to manage namespaces, 
deployments, ingresses, services and secrets. 
If your application consists of more resources which need to be updated as part of a deployment (for example cronjobs), 
you should add those resources to the file as well (and don't forget the prefixes of their `apiVersion` to `apiGroups`). 
Run the following command to apply the ClusterRole configuration:

```shell
$ kubectl apply -f clusterrole.yaml
```

Now, create a `ClusterRoleBinding` to bind the `continuous-deployment` role to our service account:

```shell
kubectl create clusterrolebinding continuous-deployment \
    --clusterrole=continuous-deployment
    --serviceaccount=default:github-actions
```

When we created the service account, a token was automatically generated for it and stored in a secret. 
We'll need to inspect the service account to find the name of the associated secret, 
which will be listed under `secrets` and starts with `github-actions-token`:

```shell
kubectl get serviceaccounts github-actions -o yaml
```

By creating the service account, it will automatically create a secret for the service account.

```text
apiVersion: v1
kind: ServiceAccount
metadata:
  (...)
secrets:
- name: <token-secret-name>
```

Using the name of the secret returned by the service account, retrieve the YAML representation of the secret:

```shell
kubectl get secret <token-secret-name> -o yaml
```

Since version 1.24, Kubernetes will not generate the token automatically for the service account.
You will need to create the token manually. See [Service Account](../kubernetes/service-account/README.md) for more information.

You can manually create a secret for the service account after creating the service account
Create a yaml file with the name `secret.yaml`
```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: github-actions
  annotations:
    kubernetes.io/service-account.name: "github-actions"
```

```shell
$ kubectl apply -f secret.yaml
```

Get the yaml output of the secret and use it as the value for the GitHub Actions secret.

Create a new GitHub Actions secret named `KUBERNETES_SECRET`, and use the full YAML output of the previous 
`kubectl get secret` command as the value for the GitHub Actions secret. 
Now we can use the `azure/k8s-set-context` action to set the Kubernetes cluster context based on the 
cluster's API server URL and the service account secret:

```yaml
jobs:
  test: (...)

  build: (...)

  deploy:
    name: Deploy
    needs: [ test, build ]
    runs-on: ubuntu-latest
    steps:
      - name: Set the Kubernetes context
        uses: azure/k8s-set-context@v2
        with:
          method: service-account
          k8s-url: <server-url>
          k8s-secret: ${{ secrets.KUBERNETES_SECRET }}
```

Replace `<server-url>` with the URL of the cluster's API server, which can be found using the following command:

```shell
kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}'
```
