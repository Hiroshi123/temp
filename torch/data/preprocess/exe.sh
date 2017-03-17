#!/bin/bash

dir_path="/home/leapmind/data/SNS/"
saveFilePath="/home/leapmind/project/gfk-deep-insight/torch/data/data/"
individualPath=${saveFilePath}"individual/"
unitedPath=${saveFilePath}"united/"

outFileName="data.t7"
label_array=("koen" "book" "office" "beach" "mountain" "office" "park" "restaurant" "school")

for i in "${label_array[@]}"
do
  echo ""
  path=${dir_path}${i}
  echo ${path}
  echo ""
  eval th converter.lua -imageFilePath ${path} -saveFilePath ${individualPath} -outFileName ${i}".t7"
done

eval th unite.lua -t7_path ${individualPath} -saveFilePath ${unitedPath} -outFileName ${outFileName}


