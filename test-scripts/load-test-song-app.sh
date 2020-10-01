#!/bin/bash
for project in p1 p2 p3 p4
do
  for counter in 1 2 3 4
  do
   oc new-project $project
   oc run song-perf-$counter -n $project \
    -i --image=loadimpact/k6 --env="SONG_APP=song-app.songs.svc.cluster.local" --rm=true --restart=Never --  run -< load-test-k6.js
 done
done
