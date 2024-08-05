## Run & Test The Application
* This k8s challange has 2 parts. 
* First part, you are tasked to fix the issues in the deployed applications
* Second part, you are tasked deploy the application and fix the issues while runnign the application.

### Challenege - Part 1

* How many pods exist on your namespace? Save pod count in a file ~/mypods.txt (Example, store 10 if pod count is 10)
* Fix the issue in the nginx pod. 
* The service "user-fox" is deployed in the cluster, it uses pods in the backend to respond to user requests. Unfortunately, the request made to the service is not working as expected. Identify the issue in the applcation and fix it.  

### Challenege - Part 2

#### Run & Test The Application
* The XYZ bank organizing an different types of event. They developed an app for registation for the event. 
* They haveprovided the docker image for the application. 
* The docker image is blrk/concerto:1.1.0. The application is a Java application that runs on port 8080.

#### Task 1: Create a Kubernetes deployment to deploy 2 instances of the pod and make sure each pod is accessible. 
* Keep the name of the deployment as "concerto-deployment" 
* image pull policy should be "Always".
* Use the label - app: concerto where ever required. 

#### Task 2: The company suspects one or more API endpoints that might be causing the breakdown. They provided the user manual for those endpoints (user-manual-1.txt). See the user manual in the task resource and ensure each endpoint is accessible on Kubernetes using the curl command.
* Create a transaction: 
* Note: use valid "eventId", "eventClass", "price", and "userId". Refer User_manual-1.txt
``` bash 
http://<service-ip>:8080/concerto/api/transaction/create
"eventId": "<valid event id>",
"eventClass": "<valid event class>",
"price": <price>,
"userId": "<valid user id> "
```
* curl into API to get a transaction information using valid data (following user-manual-1.txt), and ensure the API works (returning status code 2xx)
* Example
``` bash
curl -i -L 'http://localhost:8080/concerto/api/transaction/info/6797eb48-f0cc-4679-8502-560acf09a163' \
-H 'Accept: application/json'
```
#### Task 3: curl into API to check out a transaction using valid data (following user-manual.txt), and ensure the API works (returning status code 2xx)
* The operation team says the breakdown occurred after several minutes of peak transaction (API Create Transaction). You need to investigate further to determine which endpoint caused the breakdown.
* Hit both the endpoints many times (e.g. 5000 times)
* For each endpoint hit, check whether the server is still responding (e.g. the subsequent request is still returning HTTP status code 2xx)
* Tip 1: Write a shell script to execute create transaction to the specified number of times.
* Note: If you find it very difficult to write your own shell script, use the command "cheat1" in the terminal of your provided environment. 
* Tip 2: Write a shell script (investigate Transaction) to execute get transaction to the specified number of times. 
* Note: If you find it very difficult to write your own shell script, use the command "cheat2" in the terminal of your provided environment.  


#### Task 4: Investigate the behavior that happened during the error
* To get the pod status, you asked the engineering team to provide health check endpoints for readiness and liveness:
```bash 
/concerto/health/readiness
/concerto/health/liveness
```
* Each endpoint is a simple API that has no business logic and simply returns HTTP status code 200.
* Configure the Kubernetes deployment to use those health check endpoints.
* https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

#### Task 5: Re-test the Pod Automatic Restart on Breakdown
* After adding a health check, re-test the breakdown issue. 
* Ensure that the pod automatically restarts if the checkout API causes a breakdown at some point.
    * Run the investigate transaction to simulate the breakdown
    * ensure the pod automatically restarts, check that the pod restart counter is increasing by using kubectl get pods
    * Ensure that traffic for other API flows. Run the investigate transaction and ensure that all 5000 traffic are success

#### Task 6: Final setp 
* Once you complete all the tasks 
* Execute the command 'ch-done'. This will invoke the evaluation program to generate the scroe. 

```bash
____________________ 
< Happy K8s Learning >
 -------------------- 
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```




