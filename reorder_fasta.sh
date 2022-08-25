#!/bin/bash
module load seqtk/1.3
module load samtools/1.11.18
fasta_in_file=$1
fasta_out_file=$2
prefix=$3
num_sequences=$(grep \> ${fasta_in_file} | wc -l)
pad_len=$(echo ${num_sequences} | awk '{print length($1)+1}')
seq_list=$(samtools faidx --fai-idx /dev/stdout "${fasta_in_file}" | sort -nrk2 | cut -f1)
counter=0
for seq_id in ${seq_list}
do
  let counter=${counter}+1
  cur_pad_len=$(echo ${counter} | awk -v pad_len="${pad_len}" '{print pad_len - length($1)}')
  cur_pad_str=$(printf '0%.0s' $(seq 1 ${cur_pad_len}))
  cur_seq_id=$(echo "${prefix}_${cur_pad_str}${counter}")
  seqtk subseq "${fasta_in_file}" <(echo "${seq_id}") | perl -pe "s/\>.*/\>$cur_seq_id/"
done > "${fasta_out_file}"
