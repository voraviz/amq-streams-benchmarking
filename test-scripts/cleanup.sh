#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied, enter the kafka project to delete"
    exit 1
fi
oc delete project $1 
oc delete project p1
oc delete project p2
oc delete project p3
oc delete project p4
