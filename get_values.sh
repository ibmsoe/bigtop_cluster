#!/bin/bash
set -ex

pre="file://"
value=""
while read drive
do
   value=$pre$drive","$value
done < $1
 return $value

