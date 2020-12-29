#!/usr/bin/env bash
function check_pod(){
    PROJECT=$1
    NUM=$2
    CONDITION=$3
    COUNT=0
    while [ ${COUNT} -lt ${NUM} ];
    do
        clear
        oc get pods -n ${PROJECT}
        sleep 5
        COUNT=$( oc get pods -n ${PROJECT}|grep ${CONDITION} |wc -l)
    done
}
working_dir=`pwd`

echo "Enter the name of the project to deploy Prometheus and Grafana"
read tenant
echo

echo "Enter the name of the AMQ Streams project"
read amqtenant
echo

oc get project $tenant > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "Project $tenant already exists, please select a unique name"
#   echo "Current list of projects on the OpenShift cluster"
#   exit 1
else
  echo
  echo "Creating project: $tenant"
  oc new-project $tenant --description="Kafka cluster"
  echo "Project $tenant has been created"
fi



oc project $tenant

sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/bundle.yaml
sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/prometheus.yaml
#sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/grafana_datasource.yaml
current=$(cat metrics/strimzi-pod-monitor.yaml | awk '/matchNames/{getline; print}' | awk -F"- " '{print $2}'|sort -u)
printf "Existing Tenant: %s" $current
sed -i '' 's/'"$current"'/'"$amqtenant"'/' metrics/strimzi-pod-monitor.yaml


echo "Deploy Prometheus Operator"

oc apply -f metrics/bundle.yaml

echo

echo "Deploy Prometheus"

oc create secret generic additional-scrape-configs --from-file=metrics/prometheus-additional.yaml
oc apply -f metrics/strimzi-service-monitor.yaml
oc apply -f metrics/strimzi-pod-monitor.yaml
oc apply -f metrics/prometheus-rules.yaml
oc apply -f metrics/prometheus.yaml
echo

echo "Deploy Grafana"

oc apply -f metrics/grafana.yaml
oc apply -f metrics/grafana_datasource.yaml
echo 

oc get deployments

check_pod $tenant 3 Running
oc expose svc/prometheus-operated -n $tenant
echo "Prometheus URL=> http://$(oc get route/prometheus-operated -o jsonpath='{.spec.host}' -n $tenant)"
echo "Grafana URL=> http://$(oc get route/grafana -o jsonpath='{.spec.host}' -n $tenant)"
