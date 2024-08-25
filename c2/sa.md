#### Create a Service Account
```bash
kubectl create serviceaccount pod-lister
```
#### Create a Role with Pod Listing Permissions
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-lister
  namespace: default  # Replace with your namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
```
```bash
kubectl apply -f pod-lister-role.yaml
```
#### Bind the Role to the Service Account
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-lister-binding
  namespace: default  # Replace with your namespace
subjects:
- kind: ServiceAccount
  name: pod-lister
  namespace: default  # Replace with your namespace
roleRef:
  kind: Role
  name: pod-lister
  apiGroup: rbac.authorization.k8s.io
```
```bash
kubectl apply -f pod-lister-rolebinding.yaml
```
#### Use the Service Account in a Pod
```bash
apiVersion: v1
kind: Pod
metadata:
  name: pod-lister
  namespace: default  # Replace with your namespace
spec:
  serviceAccountName: pod-lister
  containers:
  - name: pod-lister-container
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]  # Keep the pod running
```
```bash
kubectl apply -f pod-lister-pod.yaml
```
####  List All Pods Using the Service Account
```bash
kubectl exec -it pod-lister -- kubectl get pods -A
```