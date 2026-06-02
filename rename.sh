#!/bin/bash
gff_base_file=$1
original_id=$2
updated_id=$3
grep -w ${original_id} ${gff_base_file} | perl -pe "s/$original_id/$updated_id/g"
