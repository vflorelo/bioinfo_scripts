#!/bin/bash
input=$1
tsv_file=$2
datablock=$(grep -w "${input}" "${tsv_file}")
longest_isoform=$(echo "${datablock}" | sort -nrk2 | head -n1 | cut -f1)
echo "${longest_isoform}"
