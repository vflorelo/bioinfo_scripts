#!/bin/bash
bgo_file=$1
base_name=$(echo "${bgo_file}" | rev | cut -d\. -f1 --complement | rev)
num_lines=$(cat ${bgo_file} | wc -l)
start_line=$(grep -wn "GO-ID" ${bgo_file} | cut -d\: -f1)
if [ "${start_line}" -ne "${num_lines}" ]
then
    tail -n+${start_line} ${bgo_file} > ${base_name}.tsv
fi