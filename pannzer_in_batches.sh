#!/bin/bash
base_name=$1
fasta_file="${base_name}.faa"
num_sequences=$(grep \> ${fasta_file} | wc -l )
num_chunks=$(echo ${num_sequences} | awk '{a=$1%50}{if(a==0){print $1/50 }else{print int(($1/50)+1)}}')
species=$(grep -w "${base_name}" species.tsv | cut -f2)
for chunk in $(seq 1 ${num_chunks})
do
  progress=$(echo -e "${chunk}\t${num_chunks}" | awk '{print int(($1/$2)*100)}' | awk '{a=$1%10}{if(a==0){print $1}else{print "wait"}}')
  if [ "${progress}" != "wait" ]
  then
    echo "${progress}"
  fi
  start_line=$(echo ${chunk} | awk '{print (($1-1)*50)+1}')
  mkdir -p ${base_name}
  fasta2tsv.sh ${fasta_file} | tail -n+${start_line} | head -n50 | perl -pe 's/\t/\n/g' > ${base_name}/${chunk}.fasta
  output_str=",${base_name}/${chunk}.de.tsv,${base_name}/${chunk}.go.tsv,${base_name}/${chunk}.ann.tsv"
  runsanspanz.py \
    --CONN_REMOTE \
    --input_OPERATOR Pannzer \
    --input_FILE ${base_name}/${chunk}.fasta \
    --input_OUTFILES "${output_str}" \
    --input_QUERYSPECIES "${species}" > ${base_name}/${chunk}.log 2> ${base_name}/${chunk}.err
  exit_code=$?
  echo -e "${base_name}\t${chunk}\t${exit_code}" >> ${base_name}.status.tsv
done
