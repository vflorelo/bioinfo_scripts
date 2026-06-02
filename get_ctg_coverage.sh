#!/bin/bash
tsv_file=$1
ctg_list=$(tail -n+2 ${tsv_file} | cut -f1 | perl -pe 's/_bin.*//' | sort -V | uniq)
for ctg in ${ctg_list}
do
	ctg_datablock=$(grep ^${ctg}_bin ${tsv_file})
	echo "${ctg_datablock}" | awk -v ctg="${ctg}" 'BEGIN{FS="\t"}{total_len+=$2;seq_len+=$3;}END{print ctg FS total_len FS seq_len}' | awk 'BEGIN{FS="\t"}{ratio=$3/$2}{if(ratio>=0.95){test="pass"}else{test="fail"}}{print $0 FS test}'
done
