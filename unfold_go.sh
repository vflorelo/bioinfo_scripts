#!/bin/bash
prot_id=$1
tsv_file=$2
go_list=$(grep -w ${prot_id} ${tsv_file} | cut -f2 | perl -pe 's/\;/\n/g' | perl -pe 's/.*\[//;s/\].*//' | grep GO | cut -d\: -f2 )
echo "${go_list}" | awk -v prot_id="${prot_id}" '{print prot_id"="$1}'