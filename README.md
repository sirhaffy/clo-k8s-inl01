# Kubernetes Deployment and Service Configuration on Azure Kubernetes Service (AKS)

# Create AKS Cluster

## Create an Resource Group on Azure via CLI
```sh
az group create --name clo_kube_test_001_group --location northeurope
```

### Create an AKS Cluster via CLI with monitoring enabled
You need to have a resource group created before running this command.

```sh
az aks create \
    --resource-group clo_kube_test_001_group \
    --name clo_kube_test_001 \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --node-vm-size Standard_B2s
```

## This command fetches the Kubernetes configuration (kubeconfig) for the specified AKS cluster. To be able to run kubectl commands against your AKS cluster, you need to have the kubeconfig file set up on your local machine. This command retrieves the necessary credentials and configuration details from Azure and merges them into your existing kubeconfig file (usually located at ~/.kube/config). After running this command, you can use kubectl to manage and interact with your AKS cluster.
```sh
az aks get-credentials --resource-group clo_kube_test_001_group --name clo_kube_test_001

# ex:
az aks get-credentials --resource-group clo_kube_test_001_group --name clo_kube_test_001
```

## Apply the deployment and service configurations (also for updates)
```sh
kubectl apply -f deployment.yaml
```

## Apply the service configuration
```sh
kubectl apply -f service.yaml
```

## Check the status of all resources
```sh
kubectl get all
```

## Check the status of the pods
```sh
kubectl get pods
kubectl get pods -o wide # more details
```

## Wait for the pod to be in Running state
```sh
kubectl get svc
```

## Delete the deployment
```sh
kubectl delete -f deployment.yaml
```

## Delete the service
```sh
kubectl delete -f service.yaml
```

## Delete the AKS cluster (if needed) on Azure via CLI
```sh
az aks delete --name <ditt-aks-cluster-namn> --resource-group <ditt-resource-group> --yes

# ex:
az aks delete --name clo_kube_test_001 --resource-group clo_kube_test_001_group --yes
```


# Dashboard

## Install dashboard
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.8.0/aio/deploy/recommended.yaml
```

## Create service account
```sh
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
```

## Get token
```sh
kubectl get secret $(kubectl get serviceaccount dashboard-admin-sa -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
```

## Starta dashboard
```sh
kubectl proxy
```

## Öppna i webbläsare
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## Make it work from outside localhost
```sh
kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
```
Change type from ClusterIP to LoadBalancer and save the file.
# Then get the external IP
```sh
kubectl -n kubernetes-dashboard get service kubernetes-dashboard
```




---

# Koppla till ditt nya AKS-kluster
az aks get-credentials --resource-group rg-todo-dev --name aks-todo-dev

# Kolla ArgoCD status
kubectl get pods -n argocd

# Få ArgoCD lösenord (visas också i GitHub Action summary)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443







# Minikube

```sh
minikube ip

minikube start

minikube stop

minikube delete

# Easy way to open the service in your default web browser
minikube service myapp-service
```