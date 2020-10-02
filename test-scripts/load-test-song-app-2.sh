#!/bin/bash
for project in p6 p7 p8  p9 p10
do
  oc new-project $project 1>/dev/null 2>&1
  oc delete pods --all -n $project 1>/dev/null 2>&1
  for counter in f g h i j
  do
   echo "Start pod song-perf-$counter on project $project"
   oc run song-perf-$counter -n $project \
    -i --image=loadimpact/k6 --rm=true \
    --restart=Never --  run -< load-test-k6-2.js &
 done
done
