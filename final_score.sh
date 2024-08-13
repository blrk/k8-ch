# global var
ctstatus=0
gtstatus=0
cip="0.0.0.0"

#define namespce 
# namespaces=("mtvlabk8su1", "mtvlabk8su2", "mtvlabk8su3", "mtvlabk8su4", "mtvlabk8su5", "mtvlabk8su6", "mtvlabk8su7", "mtvlabk8su8", "mtvlabk8su9", "mtvlabk8su10", "mtvlabk8su11", "mtvlabk8su12", "mtvlabk8su13", "mtvlabk8su14", "mtvlabk8su15", "mtvlabk8su16", "mtvlabk8su17", "mtvlabk8su18", "mtvlabk8su19", "mtvlabk8su20", "mtvlabk8su21", "mtvlabk8su22", "mtvlabk8su23", "mtvlabk8su24", "mtvlabk8su25")
#teams=(c1, c2, c3)
#namespaces=("default")
teams=("t1" "t2")
namespaces=("default" "default")
userappurl=("mtvlabk8a1-app.brainupgrade.in")

# Define the output CSV file
output_files=("t1.csv" "t2.csv")

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

# Loop scoring for teams
for ((i=0; i<${#teams[@]}; i++)); do
    team=${teams[$i]}
    ns=${namespaces[$i]} 
    output_file=${output_files[$i]}

    echo "Processing team: $team with namespace: $ns"
    echo "-----------------------------------------------------------"

    # Write headers to the CSV file
    echo "Task,Status,Score" > "$output_file"

    #fetch inital values
    cip=$(kubectl get svc concerto-service -n "$ns" -o=jsonpath='{.spec.clusterIP}')

    # scoring webserver pod
    status=$(kubectl get pods mywebserver -n "$ns" -o=jsonpath='{.status.phase}')
    image=$(kubectl get pod mywebserver -o=jsonpath='{.spec.containers[*].image}')

    if [ "$status" = 'Running' ] && [ "$image" = 'nginx:1.26.1' ]; then
        echo "My webserver pod stats [PASS]"
        # Append data rows to the CSV file
        echo "My webserver pod stats,[PASS],5" >> "$output_file"
    else
        echo "My webserver pod stats [FAIL]"
        # Append data rows to the CSV file
        echo "My webserver pod stats,[FAIL],0" >> "$output_file"
    fi

    #scoring investment-frondend
    count=$(kubectl get deployments/invest-frontend -n "$ns" -o=jsonpath='{.spec.replicas}')
    avail=$(kubectl get deployments/invest-frontend -n "$ns" -o=jsonpath='{.status.availableReplicas}')

    if [ "$count" = "5" ] && [ "$avail" = "5" ]; then
        echo "investment frontend deployment [PASS]"
        # Append data rows to the CSV file
        echo "investment frontend deployment,[PASS],5" >> "$output_file"
    else
        echo "investment frontend deployment [FAIL]"
        # Append data rows to the CSV file
        echo "investment frontend deployment,[FAIL],0" >> "$output_file"
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
        # Append data rows to the CSV file
        echo "user-fox svc,[PASS],10" >> "$output_file"
    else
        echo "user-fox svc [FAIL]"
        # Append data rows to the CSV file
        echo "user-fox svc,[FAIL],0" >> "$output_file"
    fi

    ingress_port=$(kubectl get ingress ingress -n "$ns" -o=jsonpath='{.spec.rules[*].http.paths[*].backend.service.port.number}')
    ingress_svc=$(kubectl get ingress ingress -n "$ns" -o=jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}')

    #check the svc and ingress mapping
    if [ "$ingress_port" = "$service_port" ] && [ "$ingress_svc" = "user-fox" ]; then
        echo "user-fox ingress [PASS]"
        # Append data rows to the CSV file
        echo "user-fox ingress,[PASS],10" >> "$output_file"
    else
        echo "user-fox ingress [FAIL]"
        # Append data rows to the CSV file
        echo "user-fox ingress,[FAIL],0" >> "$output_file"
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
        # Append data rows to the CSV file
        echo "concerto-deployment,[PASS],20" >> "$output_file"
    else
        echo "concerto-deployment [FAIL]"    
        # Append data rows to the CSV file
        echo "concerto-deployment,[FAIL],0" >> "$output_file"
    fi

    # score Health Check Endpoints
    lpurl=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}')
    lpport=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.port}')

    if [ "$lpurl" = "/concerto/health/liveness" ] && [ "$lpport" = "8080" ]; then
        echo "concerto-deployment livenessProbe [PASS]"
        # Append data rows to the CSV file
        echo "concerto-deployment livenessProbe,[PASS],5" >> "$output_file"
    else
        echo "concerto-deployment livenessProbe [FAIL]"
        # Append data rows to the CSV file
        echo "concerto-deployment livenessProbe,[FAIL],0" >> "$output_file"
    fi

    rpurl=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
    rpport=$(kubectl get deployment concerto-deployment -n "$ns" -o=jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}')

    if [ "$rpurl" = "/concerto/health/readiness" ] && [ "$lpport" = "8080" ]; then
        echo "concerto-deployment readinessProbe [PASS]"
        # Append data rows to the CSV file
        echo "concerto-deployment readinessProbe,[PASS],5" >> "$output_file"
    else
        echo "concerto-deployment readinessProbe [FAIL]"
        # Append data rows to the CSV file
        echo "concerto-deployment readinessProbe,[FAIL],0" >> "$output_file"
    fi

    # investigate-create-transaction call
    echo "Making create request .....5000 "
    for ((i=1; i<=5000; i++)); do
        #echo "Making request $i..."
        make_curl_request
        if [ "$ctstatus" -eq 1 ]; then
            echo "concerto-deployment create transaction [FAIL]"
            # Append data rows to the CSV file
            echo "concerto-deployment create transaction,[FAIL],0" >> "$output_file"
            # Append data rows to the CSV file
            echo "Investigate create transaction,[FAIL],0" >> "$output_file"
            break
        fi
    done

    if [ "$ctstatus" -eq 0 ]; then
        echo "concerto-deployment create transaction [PASS]"
        # Append data rows to the CSV file
        echo "concerto-deployment create transaction,[PASS],10" >> "$output_file"
        # Append data rows to the CSV file
        echo "Investigate create transaction,[PASS],10" >> "$output_file"
    fi

    # investigate-get-transaction
    echo "Making get request .....5000 "

    for i in {1..5000}; do
        curl -i -L -X POST "http://$cip:8080/concerto/api/transaction/checkout/3935eb5a-bc0e-4878-b0a5-0c4cc12f2da3" > /dev/null 2>&1
    done

    p1_re_count=$(kubectl get pods -l app=concerto -n "$ns" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].restartCount}{"\n"}{end}' | head -n 1 | cut -f 2)
    p2_re_count=$(kubectl get pods -l app=concerto -n "$ns" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].restartCount}{"\n"}{end}' | tail -n 1 | cut -f 2)

    if [ "$p1_re_count" -gt 0 ] && [ "$p2_re_count" -gt 0 ]; then
        echo "concerto-deployment get transaction [PASS]"
        # Append data rows to the CSV file
        echo "concerto-deployment get transaction,[PASS],10" >> "$output_file"
        # Append data rows to the CSV file
        echo "Investigate get transaction,[PASS],10" >> "$output_file"
    else
        echo "concerto-deployment get transaction [FAIL]"
        # Append data rows to the CSV file
        echo "concerto-deployment get transaction,[FAIL],0" >> "$output_file"
        # Append data rows to the CSV file
        echo "Investigate get transaction,[FAIL],0" >> "$output_file"
    fi
    echo "-----------------------------------------------------------"
    # Reset global var
    ctstatus=0
    gtstatus=0
    cip="0.0.0.0"
done












