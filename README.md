# amq-streams-benchmarking
Tested on OpenShift cluster v4.5

## Deploy Kafka:
Run ```./deploy_kafka.sh```

The bash script will prompt for a namespace name which creates the namespace; and makes changes to the yaml files.

## Deploy Metrics:
1. Run ```./deploy_metrics.sh```

The bash script will prompt for a namespace name which navigates into the namespace; and makes changes to the yaml files

2. Navigate to Grafana route, login with ```admin:admin```. Once logged in, follow through the console instruction to change password. 

3. Add a new data source with http://prometheus-operated:9090 with the rest of the parameters stay as default.

4. Import a new dashboard, *../grafana-dashboards/strimzi-kafka.json*

![Grafana_screenshot](https://user-images.githubusercontent.com/25560159/91380974-d7973b00-e858-11ea-9934-d903ddf12e23.png)
