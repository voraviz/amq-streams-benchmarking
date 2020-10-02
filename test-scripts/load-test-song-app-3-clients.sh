#!/bin/bash
for project in m1 m2 m3 m4 m5
do
  echo "Process for $project"
  oc new-project $project 1>/dev/null 2>&1
  oc delete pod --all -n $project 1>/dev/null 2>&1
  for counter in a b c d e
  do
   echo "Start pod song-perf-$counter on project $project"
   oc run song-perf-$counter -n $project \
    -i --image=loadimpact/k6 --rm=true \
    --restart=Never --  run -< load-test-k6.js &
 done
done
