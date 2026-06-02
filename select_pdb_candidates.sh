#!/bin/bash
q_id=$1
q_tsv=$2
s_tsv=$3
q_len=$(awk -v q_id="${q_id}" 'BEGIN{FS="\t"}{if($1==q_id){print $2}}' ${q_tsv})
s_list=$(awk -v q_len="${q_len}" 'BEGIN{FS="\t";frac=0.125}{if($2>=q_len){if(int($2*(1-frac)) <= int(q_len*(1+frac))){print $0}}else{if(int($2*(1+frac)) >= int(q_len*(1-frac))){print $1}}}' ${s_tsv} | sort -V | uniq)
echo "${s_list}" | awk -v q_id="${q_id}" '{print "tmalign2tsv.sh af_pdb/"q_id".pdb pdb.nr70/"$1".pdb"}'
