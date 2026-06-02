#!/bin/bash
module load bedtools/2.29
module load samtools/1.11.18
fasta_file=$1
bed_file=$2
tsv_file=$3
fasta_base_name=$(echo ${fasta_file} | rev | cut -d\. -f1 --complement | rev)
samtools faidx --fai-idx /dev/stdout ${fasta_file} | awk 'BEGIN{FS="\t"}{print $1 FS 0 FS $2 FS $1}' > ${fasta_base_name}.bed
low_coverage_bins=$(tail -n+2 ${tsv_file} | awk 'BEGIN{FS="\t"}{if(($3/$2)<0.95){print $1}}' | sort -V | uniq)
grep -wFf <(echo "${low_coverage_bins}") ${bed_file} > ${fasta_base_name}.low_coverage_bins.bed
subtractBed -a ${fasta_base_name}.bed -b ${fasta_base_name}.low_coverage_bins.bed > ${fasta_base_name}.high_coverage_blocks.tmp.bed
for ctg in $(cut -f1 ${fasta_base_name}.high_coverage_blocks.tmp.bed | sort -V | uniq )
do
  grep -w ^${ctg} ${fasta_base_name}.high_coverage_blocks.tmp.bed | awk 'BEGIN{FS="\t"}{if(($3-$2)>=10000){print $0}}' | awk 'BEGIN{FS="\t"}{print $1 FS $2 FS $3 FS $1"_block_"NR}'
done > ${fasta_base_name}.high_coverage_blocks.bed
rm -f ${fasta_base_name}.high_coverage_blocks.tmp.bed
fastaFromBed -fi ${fasta_file} -fo ${fasta_base_name}.hc.fasta -bed ${fasta_base_name}.high_coverage_blocks.bed -name
perl -pi -e 's/\:.*//' ${fasta_base_name}.hc.fasta
