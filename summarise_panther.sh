#!/bin/bash
gene_id=$1
tsv_file=$2
threshold=$3
datablock=$(grep -w ^${gene_id} ${tsv_file} | awk -v gene_id="${gene_id}" -v threshold="${threshold}" 'BEGIN{FS="\t"}{if($4<=threshold){print $1 FS $2 FS $4 FS $3}}' | sort -gk3)
most_abundant=$(echo "${datablock}" | cut -f2 | cut -d\: -f1 | sort -V | uniq -c | sort -n | tail -n1 | awk '{print $2}')
domain=$(echo "${datablock}" | head -n1 | cut -f2)
desc=$(echo "${datablock}" | awk -v domain="${domain}" 'BEGIN{FS="\t"}{if($2==domain){print $4}}' | head -n1 )
eval=$(echo "${datablock}" | awk -v domain="${domain}" 'BEGIN{FS="\t"}{if($2==domain){print $3}}' | head -n1 )
echo -e "${gene_id}\t${domain}\t${eval}\t${desc}"