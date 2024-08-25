# global var
ctstatus=0
gtstatus=0

#define namespce 
namespaces=("default")
userappurl=("mtvlabk8a1-app.brainupgrade.in")

#fetch inital values
cip=$(kubectl get svc concerto-service -o=jsonpath='{.spec.clusterIP}')

# investigate-create-transaction
make_curl_request() {
    response=$(curl -i -L "http://$cip:8080/concerto/api/transaction/create" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d '{
      "eventId": "dc368370-a09c-4fbe-89ab-09f27c6ec56d",
      "eventClass": "GOLD",
      "price": 99,
      "userId": "bc0ebf72-ad8b-45cb-8991-ada961b4415d"
    }' 2>&1 | awk '/HTTP\/1.1/{print $2}')

    if [[ $response != 2* ]]; then
        #echo "SERVER IS NOT RESPONDING WITH 2xx"
        ctstatus=1
    fi
}

# investigate-get-transaction
make_get_request() {
    response=$(curl -i -L "http://$cip:8080/concerto/api/transaction/info/6797eb48-f0cc-4679-8502-560acf09a163" \
    -H 'Accept: mapplication/json' 2>&1 | awk '/HTTP\/1.1/{print $2}')

    if [[ $response != 2* ]]; then
        #echo "SERVER IS NOT RESPONDING WITH 2xx"
        #exit 1
        gtstatus=1
    fi
}

# scoring webserver pod
status=$(kubectl get pods mywebserver -n "$ns" -o=jsonpath='{.status.phase}')
image=$(kubectl get pod mywebserver -o=jsonpath='{.spec.containers[*].image}')

if [ "$status" = 'Running' ] && [ "$image" = 'nginx:1.26.1' ]; then
    echo "My webserver pod stats [PASS]"
else
    echo "My webserver pod stats [FAIL]"
fi

#scoring investment-frondend
count=$(kubectl get deployments/invest-frontend -n "$ns" -o=jsonpath='{.spec.replicas}')
avail=$(kubectl get deployments/invest-frontend -n "$ns" -o=jsonpath='{.status.availableReplicas}')

if [ "$count" = "5" ] && [ "$avail" = "5" ]; then
    echo "investment frontend deployment [PASS]"
else
    echo "investment frontend deployment [FAIL]"
fi

# Fetch the cluster IP and port of the service
cluster_ip=$(kubectl get svc user-fox -n "$ns" -o=jsonpath='{.spec.clusterIP}')
service_port=$(kubectl get svc user-fox -n "$ns" -o=jsonpath='{.spec.ports[0].port}')

# Perform the curl request
suserfox=$(curl -s http://$cluster_ip:$service_port)

# Use echo and cut to extract the first word from the response
res=$(echo "$suserfox" | cut -d " " -f 1)

# Check if the first word is "Hello,"
if [ "$res" = "Hello," ]; then
    echo "user-fox svc [PASS]"
else
    echo "user-fox svc [FAIL]"
fi

ingress_port=$(kubectl get ingress ingress -n "$ns" -o=jsonpath='{.spec.rules[*].http.paths[*].backend.service.port.number}')
ingress_svc=$(kubectl get ingress ingress -n "$ns" -o=jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}')

#check the svc and ingress mapping
if [ "$ingress_port" = "$service_port" ] && [ "$ingress_svc" = "user-fox" ]; then
    echo "user-fox ingress [PASS]"
else
    echo "user-fox ingress [FAIL]"
fi


# Check concerto-deployment
dname=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.metadata.name}')
dlabel=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.selector.matchLabels.app}')
dreplicas=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.replicas}')
dimage=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].image}')
dimpolicy=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].imagePullPolicy}')
dport=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')
darep=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.status.availableReplicas}')

if [ "$dname" = "concerto-deployment" ] && [ "$dlabel" = "concerto" ] && [ "$dreplicas" = "2" ] && [ "$dimage" = "blrk/concerto:1.0.0" ] && [ "$dimpolicy" = "Always" ] && [ "$dport" = "8080" ] && [ "$darep" = "2" ] && [ "$darep" = "2" ]; then
    echo "concerto-deployment [PASS]"
else
    echo "concerto-deployment [FAIL]"    
fi

# score Health Check Endpoints
lpurl=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}')
lpport=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.port}')

if [ "$lpurl" = "/concerto/health/liveness" ] && [ "$lpport" = "8080" ]; then
    echo "concerto-deployment livenessProbe [PASS]"
else
    echo "concerto-deployment livenessProbe [FAIL]"
fi

rpurl=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
rpport=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}')

if [ "$rpurl" = "/concerto/health/readiness" ] && [ "$lpport" = "8080" ]; then
    echo "concerto-deployment readinessProbe [PASS]"
else
    echo "concerto-deployment readinessProbe [FAIL]"
fi

# investigate-create-transaction call

for ((i=1; i<=5000; i++)); do
    #echo "Making request $i..."
    make_curl_request
    if [ "$ctstatus" -eq 1 ]; then
      echo "concerto-deployment create transaction [FAIL]"
      break
    fi
done

if [ "$ctstatus" -eq 0 ]; then
  echo "concerto-deployment create transaction [PASS]"
fi

# investigate-get-transaction call
for ((i=1; i<=5000; i++)); do
    #echo "Making request $i..."
    make_get_request
    if [ "$gtstatus" -eq 1 ]; then
      echo "concerto-deployment get transaction [FAIL]"
      break
    fi
done

if [ "$gtstatus" -eq 0 ]; then
  echo "concerto-deployment get transaction [PASS]"
fi