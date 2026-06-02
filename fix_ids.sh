#!/bin/bash
datablock=$(cat)
original_id=$(echo   "$datablock" | cut -f1)
merged_id=$(echo     "$datablock" | cut -f2)
base_gff_file=$(echo "$datablock" | cut -f3)
grep -w ${original_id} ${base_gff_file} | perl -pe "s/${original_id}/${merged_id}/g"
