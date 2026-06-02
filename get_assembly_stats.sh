#!/bin/bash
module load samtools/1.11.18
fasta_file=$1
base_name=$(echo "${fasta_file}" | perl -pe 's/\.fasta$//;s/\.fna$//;s/\.fa$//')
if [ ! -f "${base_name}.fai" ] && [ ! -f "${fasta_file}.fai" ]
then
	samtools_cmd=$(which samtools)
	if [ -z "${samtools_cmd}" ]
	then
		perl -pe 'if(/\>/){s/$/\t/};s/\n//;s/\>/\n/g;s/\ .*\t/\t/' ${fasta_file} | tail -n+2 | awk 'BEGIN{FS="\t"}{print $1 FS length($2)}' > ${base_name}.fai
		datablock=$(sort -nk2 ${base_name}.fai)
	else
		samtools faidx ${fasta_file}
		datablock=$(sort -nk2 ${fasta_file}.fai)
	fi
else
	if [ -f "${base_name}.fai" ]
	then
		datablock=$(sort -nk2 ${base_name}.fai)
	elif [ -f "${fasta_file}.fai" ]
	then
		datablock=$(sort -nk2 ${fasta_file}.fai)
	fi
fi
total_length=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{sum+=$2}END{print sum}')
echo "${datablock}" | awk -v total_length="${total_length}" 'BEGIN{FS="\t"}
{
	{total_sum+=$2}
	{if(total_sum<(total_length/2)){n50_length=$2;n50_name=$1;l50_cnt=NR}}
	{if($2>=10000){deca_sum+=$2;deca_cnt+=1}}
	{if($2>=100000){heca_sum+=$2;heca_cnt+=1}}
	{if($2>=1000000){mega_sum+=$2;mega_cnt+=1}}
}END{print"Total length:\t"total_sum"\nn50 length:\t"n50_length"\nn50 name:\t"n50_name"\nl50 count:\t"l50_cnt"\nContigs >1Mbp:\t"mega_cnt"\nLength >1Mbp:\t"mega_sum"\nContigs >100Kbp:\t"heca_cnt"\nLength >100Kbp:\t"heca_sum"\nContigs >10Kbp:\t"deca_cnt"\nLength >10Kbp:\t"deca_sum}' > ${base_name}.asm_stats.tsv
