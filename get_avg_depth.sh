#!/bin/bash
module load samtools/1.11.18
bam_file=$1
bed_file=$2
gene_str=$3
if [ -z "${gene_str}" ]
then
    gene_list=$(cut -f4 ${bed_file} | grep -v ^$ | sort -V | uniq )
else
    gene_list=${gene_str}
fi
for gene in ${gene_list}
do
	gene_datablock=$(awk -v gene="${gene}" 'BEGIN{FS="\t"}{if($4==gene){print $0}}' ${bed_file})
	num_intervals=$(echo "${gene_datablock}" | wc -l)
	depth_datablock=""
	for interval_num in $(seq 1 ${num_intervals})
	do
        interval=$(echo "${gene_datablock}" | tail -n+${interval_num} | head -n1)
		interval_str=$(echo   "${interval}" | awk 'BEGIN{FS="\t"}{print $1":"$2+1"-"$3}')
        interval_chrom=$(echo "${interval}" | cut -f1)
        interval_start=$(echo "${interval}" | cut -f2)
        interval_end=$(echo   "${interval}" | cut -f3)
		interval_avg_depth=$(samtools depth -aa -r ${interval_str} ${bam_file} | awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}')
		depth_datablock=$(echo -e "${depth_datablock}\n${interval_chrom}\t${interval_start}\t${interval_end}\t${interval_avg_depth}" | grep -v ^$)
		unset interval
	done
    echo "${depth_datablock}"
done
