# amq-streams-benchmarking
Tested on OpenShift v4.5

## Deploy Kafka:
Run ```./deploy_kafka.sh```

The bash script will prompt for a namespace name which creates the namespace; and makes changes to the yaml files.

## Deploy Metrics:
Run ```./deploy_metrics.sh```

The bash script will prompt for a namespace name which navigates into the namespace; and makes changes to the yaml files

Navigate to Grafana route, login with ```admin:admin```. Once logged in, follow through the console instruction to change password. 

Add a new data source with http://prometheus-operated:9090 with the rest of the parameters stay as default.

Import a new dashboard, *../grafana-dashboards/strimzi-kafka.json*

![Grafana_screenshot](https://user-images.githubusercontent.com/25560159/91380974-d7973b00-e858-11ea-9934-d903ddf12e23.png)

## Load Test
Load Test
```bash
cd test-scripts
./load-test.sh
```

## Deploy Sample Application

Original code here [https://github.com/redhat-developer-demos/kafka-tutorial.git](https://github.com/redhat-developer-demos/kafka-tutorial.git)

### Deploy Producer Application
Deploy songs app
```bash
oc new-project songs --display-name="Songs Application"
oc apply -f kafka-songs-topic.yaml -n kafka
oc apply -f applications/song-app/src/main/kubernetes/kubernetes.yml -n songs
oc scale deployment song-app --replicas=0 -n songs
oc create route edge song --service=song-app --port=8080 -n songs
## You need to change "kafka" to match your AMQ Streams project
oc set env deployment/song-app MP_MESSAGING_OUTGOING_SONGS_BOOTSTRAP_SERVERS=my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092 -n songs
oc scale deployment song-app --replicas=3 -n songs
watch oc get pods -n songs
```
Test 
```bash
SONG=https://$(oc get route song -n songs -o jsonpath='{.spec.host}')/songs
curl -v -X POST -H "Content-Type: application/json" -d @test-scripts/uprising.json ${SONG}
```
Sample result
```bash
...
HTTP/1.1 204 No Content
...
```
### Deploy Consumer Application
Deploy songs-indexder app
```bash
oc apply -f applications/song-indexer-app/src/main/kubernetes/kubernetes.yml -n songs
oc create route edge song-indexer --service=kafka-tutorial-song-indexer-app -n songs
## You need to change "kafka" to match your AMQ Streams project
oc set env deployment/kafka-tutorial-song-indexer-app MP_MESSAGING_INCOMING_SONGS_BOOTSTRAP_SERVERS=my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092 -n songs
```
Test 
```bash
INDEXER=https://$(oc get route song-indexer -n songs -o jsonpath='{.spec.host}')/events
curl -X GET -v ${INDEXER}
```
### Load Test with k6 load test tool
Run load test with [k6](https://k6.io) from pod on OpenShift 
  - each pod will run 200 concurrent reqeusts with 2K Bytes message size.
  - Ramp-up time is 30 sec.
  - Duration is 15 minutes.

```bash
 oc new-project p1
 oc run song-perf -n p1 \
    -i --image=loadimpact/k6  \
    --rm=true --restart=Never --  run -< test-scripts/load-test-k6.js
```

Run k6 locally by
```bash
docker run -i loadimpact/k6 run -< test-scripts/load-test-k6.js
```

Load test with 5000 concurrent request with 2K data to song app
```bash
oc scale deployment/song-app --replicas=25 -n songs
cd test-scripts
./load-test-song-app.sh
```
To test with 2 client
```bash
oc apply -f applications/song-app/src/main/kubernetes/kubernetes-2.yml -n songs
oc scale deployment song-app-2 --replicas=0 -n songs
oc set env deployment/song-app-2 MP_MESSAGING_OUTGOING_SONGS_BOOTSTRAP_SERVERS=my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092 -n songs
oc scale deployment song-app --replicas=30 -n songs
cd test-scripts
./load-test-song-app-2.sh
```
Check grafana for Incoming Message Rate and Total Produce Reqeust Rate (1 client)

![](test-scripts/song-app-5000-concurrent.png)

2 clients

![](test-scripts/song-app-5000-concurrent-2clients.png)

song-app deployment is set CPU limit to 300m 

![](test-scripts/song-app-utilization.png)

Load test AMQ Streams with song-app configured to be 3 clients by deploy 3 deployment of song-app and configure within same service
```bash
oc delete deployment --all -n songs
oc apply -f test-scripts/song-app-3-clients.yml -n songs
cd test-scripts
./load-test-song-app-3-clients.sh
```

<!-- Edit [test-scripts/load-test-k6.js](test-scripts/load-test-k6.js). Replace url to your song app URL
```js
export default function() {
  const url = 'https://song-songs.apps.cluster-f2cc.f2cc.example.opentlc.com/songs';
  let headers = {'Content-Type': 'application/json'};
``` -->
<!-- Run Load test with k6
```bash
docker run -i loadimpact/k6 run -< test-scripts/load-test-k6.js
``` -->
<!-- 

Check Grafana Dashboard

![](test-scripts/k6.png) -->

