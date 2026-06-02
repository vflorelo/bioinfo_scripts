#!/bin/bash
fasta_file=$1
chunk_size=$2

samtools_test=$(which samtools 2> /dev/null)
if [ -z "$samtools_test" ]
then
    echo "Error: samtools not found in PATH"
    exit 1
fi

seq_sizes=$(samtools faidx ${fasta_file} --fai-idx /dev/stdout | awk 'BEGIN{FS="\t"}{print $1 FS $2}')
num_lines=$(echo "${seq_sizes}" | wc -l)
for i in $(seq 1 ${num_lines})
do
	datablock=$(echo "${seq_sizes}" | tail -n+$i | head -n1)
	seq_name=$(echo "${datablock}" | cut -f1)
	seq_len=$(echo "${datablock}" | cut -f2)
	if [ "${seq_len}" -lt "${chunk_size}" ]
	then
		echo -e "${seq_name}\t0\t${seq_len}\t${seq_name}_bin_1"
	else
		paste <(seq 0 ${chunk_size} ${seq_len}) <(echo -e "$(seq ${chunk_size} ${chunk_size} ${seq_len})\n${seq_len}") | perl -pe "s/^/$seq_name\t/;s/$/\t$seq_name/" | awk 'BEGIN{FS="\t"}{print $0"_bin_"NR}'
	fi
done
