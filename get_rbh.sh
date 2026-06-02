#!/bin/bash
id=$1
tsv_file=$2
hit_list=$(awk -v id="${id}" 'BEGIN{FS="\t"}{if($1==id || $2==id){print $1 "\n" $2}}' ${tsv_file} | sort -V | uniq | grep -wv ${id} )
for hit in ${hit_list}
do
    direct=$(awk -v id="${id}" -v hit="${hit}" 'BEGIN{FS="\t"}{if($1==id && $2==hit){print $0}}' ${tsv_file} | grep -v ^$ | grep -c .)
    reverse=$(awk -v id="${id}" -v hit="${hit}" 'BEGIN{FS="\t"}{if($2==id && $1==hit){print $0}}' ${tsv_file} | grep -v ^$ | grep -c .)
    if [ "${direct}" -ge 1 ] && [ "${reverse}" -ge 1 ]
    then
        grep -w ${id} ${tsv_file} | grep -w ${hit}
    fi
done