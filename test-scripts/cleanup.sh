#!/bin/bash
for i in p1 p2 p3 p4 p5
do
  oc delete project $i
done
