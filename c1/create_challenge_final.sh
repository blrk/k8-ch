#!/bin/bash
# Creating user-fox service config
cat > userfox-service.yml << EOF
apiVersion: v1
kind: Service
metadata:
  name: user-fox
spec:
  selector:
    app: userfox
  ports:
    - protocol: TCP
      port: 8090
      targetPort: 5000
  type: ClusterIP
EOF

# Define the namespaces
#namespaces=("mtvlabk8su1" "mtvlabk8su2" "mtvlabk8su3" "mtvlabk8su4" "mtvlabk8su5" "mtvlabk8su6" "mtvlabk8su7" "mtvlabk8su8" "mtvlabk8su9" "mtvlabk8su10" "mtvlabk8su11" "mtvlabk8su12" "mtvlabk8su13" "mtvlabk8su14" "mtvlabk8su15" "mtvlabk8su16" "mtvlabk8su17" "mtvlabk8su18" "mtvlabk8su19" "mtvlabk8su20" "mtvlabk8sa1")
namespaces=("mtvlabk8su1" "mtvlabk8su2" "mtvlabk8su3" "mtvlabk8su4" "mtvlabk8su5")

# Define the pod details in arrays
pods=("mywebserver")

# home path
home_path=("~/root/User-manual")
# images
images=("ngnix:1.26.1") 
# port number of apps
ports=("80") 

# Create pods in each namespace
for ns in "${namespaces[@]}"; do
  for i in "${!pods[@]}"; do
    pod_name="${pods[$i]}"
    image="${images[$i]}"
    port="${ports[$i]}"
    # Run the pod
    kubectl run "$pod_name" --image="$image" --port="$port" -n "$ns"
    #kubectl create deployment mywebserver --image="$image" -n "$ns"
    #Ensure the "invest-frontend" Application Runs with 5 Pods
    kubectl create deployment invest-frontend --image=blrk/nodeapp:15.0.0 -n "$ns"
    # Analyse and fix the issue causing User-fox service requests to the backend service to fail.
    kubectl run pod-user-fox1 --port 5000 -l app=userf0x --image blrk/user-fox:1.0.1 -n "$ns"
    kubectl run pod-user-fox2 --port 5000 -l app=userf0x --image blrk/user-fox:1.0.2 -n "$ns"
    kubectl apply -f userfox-service.yml -n "$ns"
  done
  # Create user manual
  #cp ./User_manual-1.txt "$home_path"  
done

# Get and print the names of the pods and their namespaces
echo "Pods and their namespaces:"
for ns in "${namespaces[@]}"; do
  kubectl get pods -n "$ns" -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace
  echo "---------------------------------------------------------------------------------------"
done

 





