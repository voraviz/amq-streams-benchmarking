#!/bin/bash
echo "Enter name of AMQ Streams's project"
read tenant

echo "This will removed everything in ${tenant}"

oc project ${tenant}
oc delete -f kafka-topic.yaml 
oc delete -f kafka-persistent-metrics.yaml
for pvc in $(oc get pvc --no-headers | awk '{print $1}')
do
oc delete pvc $pvc
done
oc delete project ${tenant}