#!/bin/bash
module load EMBOSS/6.6.0
fasta_file=$1
sizes_file=$2
redundancy=$3
num_seqs=$(cat "${sizes_file}" | wc -l)
for i in $(seq 1 ${num_seqs})
do
	seq_name=$(tail -n+${i} ${sizes_file} | head -n1 | cut -f1 )
	seq_size=$(tail -n+${i} ${sizes_file} | head -n1 | cut -f2 )
	left_start=$(echo -e "${seq_size}\t${redundancy}" | awk '{print ($1-$2)+1}')
	left_seq=$(seqret ${fasta_file}:${seq_name} -sbegin ${left_start} raw::stdout 2> /dev/null)
	mid_seq=$(seqret ${fasta_file}:${seq_name} raw::stdout 2> /dev/null)
	right_seq=$(seqret ${fasta_file}:${seq_name} -send ${redundancy} raw::stdout 2> /dev/null)
	seqret <(echo -e ">${seq_name}\n${left_seq}${mid_seq}${right_seq}") fasta::${seq_name}.${redundancy}.circular.fasta 2> /dev/null
done
