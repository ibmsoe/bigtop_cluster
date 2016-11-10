#!/bin/bash

   >&2 echo "HDFS is unavailable"
   until nc -z $1 8020
      do
       >&2 echo "..... waiting for HDFS"
       sleep 5s 
      done
   >&2 echo "HDFS is available"


