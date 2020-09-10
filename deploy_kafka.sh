#!/usr/bin/env bash

working_dir=`pwd`

echo "checking if oc is present"

if ! hash oc 2>/dev/null
then
    echo "'oc' was not found in PATH"
    echo "Kindly ensure that you can acces an existing OpenShift cluster via oc"
    exit
fi

oc version

echo "Current list of projects on the OpenShift cluster:"

echo

oc get project | grep -v NAME | awk '{print $1}'

echo

echo "Enter the name of the new project unique name, this will be used to create the namespace"
read tenant
#tenant=kafka-cluster
echo

#Check If namespace exists

oc get project $tenant > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "Project $tenant already exists, please select a unique name"
  echo "Current list of projects on the OpenShift cluster"
  sleep 2

 oc get project | grep -v NAME | awk '{print $1}'
  exit 1
fi

echo
echo "Creating project: $tenant"

oc new-project $tenant --description="Kafka cluster"

echo "Project $tenant has been created"

oc project $tenant

echo 

sed -i 's/namespace: .*/namespace: '"$tenant"'/' cluster-operator/*RoleBinding*.yaml

echo

echo "Deploying Kafka"

echo 

oc apply -f cluster-operator -n $tenant

echo

oc apply -f kafka-persistent-metrics.yaml

echo "Creating Kafka topic, topic1"

echo

oc apply -f kafka-topic.yaml

echo

oc get deployments
