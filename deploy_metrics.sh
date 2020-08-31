#!/usr/bin/env bash

working_dir=`pwd`

echo "Enter the name of the project to deploy Prometheus and Grafana"
read tenant
echo

sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/bundle.yaml
sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' metrics/prometheus.yaml

oc project $tenant

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

echo 

oc get deployments
