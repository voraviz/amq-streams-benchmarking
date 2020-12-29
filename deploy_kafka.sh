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

oc get project --no-headers| awk '{print $1}'

echo

echo "Enter the name of the new project unique name, this will be used to create the namespace"
read tenant
echo

#Check If namespace exists

oc get project $tenant > /dev/null 2>&1

# if [ $? -eq 0 ]
# then
#   echo "Project $tenant already exists, please select a unique name"
#   echo "Current list of projects on the OpenShift cluster"
#   sleep 2

#  oc get project | grep -v NAME | awk '{print $1}'
#   exit 1
# fi

echo
echo "Creating project: $tenant"

oc new-project $tenant --description="Kafka cluster"
oc delete limitrange --all -n $tenant

echo "Project $tenant has been created"

oc project $tenant

echo 
platform=$(uname)
if [ "$platform" = 'Darwin' ];
then
  sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' cluster-operator/*RoleBinding*.yaml
else
  sed -i 's/namespace: .*/namespace: '"$tenant"'/' cluster-operator/*RoleBinding*.yaml
fi

echo

echo "Deploying AMQ Streams Operator"

echo 

oc apply -f cluster-operator -n $tenant

echo
echo "Deploying Kafka Cluster"

oc apply -f kafka-persistent-metrics.yaml

echo "Creating Kafka topic, topic1"

echo

oc apply -f kafka-topic.yaml

echo

oc get deployments

check_pod $tenant 9 Running

