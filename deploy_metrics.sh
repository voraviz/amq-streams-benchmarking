#!/usr/bin/env bash

working_dir=`pwd`

echo "Enter the name of the project to deploy Prometheus and Grafana"
read tenant
echo"

sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/bundle.yaml
sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/prometheus.yaml

oc project $tenant

echo "Deploy Prometheus Operator"

oc apply -f metrics/bundle.yaml

echo

echo "Deploy Prometheus"

oc create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml
oc apply -f strimzi-service-monitor.yaml
oc apply -f strimzi-pod-monitor.yaml
oc apply -f prometheus-rules.yaml
oc apply -f prometheus.yaml
 
echo 

echo "Deploy Grafana"

oc apply -f grafana.yaml

echo 

oc get deployments
