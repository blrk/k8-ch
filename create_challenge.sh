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
namespaces=("default")

# Define the pod details in arrays
pods=("mywebserver")

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
done

# Get and print the names of the pods and their namespaces
echo "Pods and their namespaces:"
for ns in "${namespaces[@]}"; do
  kubectl get pods -n "$ns" -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace
done


# cheat-1 creation 
mkdir /etc/config

cat << 'EOF' > /etc/config/cheat-1.sh
#!/bin/sh
# create 5000 transaction

make_curl_request() {
    response=$(curl -i -L 'http://<service-ip>:8080/concerto/api/transaction/create' \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d '{
      "eventId": "dc368370-a09c-4fbe-89ab-09f27c6ec56d",
      "eventClass": "GOLD",
      "price": 99,
      "userId": "bc0ebf72-ad8b-45cb-8991-ada961b4415d"
    }' 2>&1 | awk '/HTTP\/1.1/{print $2}')

    if [[ $response != 2* ]]; then
        echo "SERVER IS NOT RESPONDING WITH 2xx"
        exit 1
    fi
}

for ((i=1; i<=5000; i++)); do
    echo "Making request $i..."
    make_curl_request
done

echo "All requests successful"`
EOF

# Install shc on Amazon Linux 2023
# dnf groupinstall "Development Tools" -y 
dnf install wget -y 
wget https://github.com/neurobin/shc/archive/refs/tags/4.0.3.tar.gz
tar -xvf 4.0.3.tar.gz
cd shc-4.0.3
./configure
make
make install
cd ..

cat << 'EOF' > /etc/config/cheat1
#!/bin/sh
cat /etc/config/cheat-1.sh
EOF

shc -f /etc/config/cheat1
cp /etc/config/cheat1.x /usr/bin/cheat1

cat << 'EOF' > /etc/config/cheat-2.sh
#!/bin/sh
make_curl_request() {
    response=$(curl -i -L -X POST 'http://<service-ip>:8080/concerto/api/transaction/checkout/3935eb5a-bc0e-4878-b0a5-0c4cc12f2da3' \
    -H 'Accept: application/json' 2>&1 | awk '/HTTP\/1.1/{print $2}')

    if [[ $response != 2* ]]; then
        echo "SERVER IS NOT RESPONDING WITH 2xx"
        exit 1
    fi
}

for ((i=1; i<=5000; i++)); do
    echo "Making request $i..."
    make_curl_request
done

echo "All requests successful"

EOF

cat << 'EOF' > /etc/config/cheat2
#!/bin/sh
cat /etc/config/cheat-2.sh
EOF

shc -f /etc/config/cheat2
cp /etc/config/cheat2.x /usr/bin/cheat2
