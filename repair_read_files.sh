#!/bin/bash
fwd_reads=$1
rev_reads=$2
base_name=$3
fwd_file_type=$(file ${fwd_reads} | cut -d' ' -f2)
rev_file_type=$(file ${rev_reads} | cut -d' ' -f2)
if [ "${fwd_file_type}" == "ASCII" ]
then
	fwd_id_list=$(awk '{if(NR%4==1){print $1}}' ${fwd_reads} | perl -pe 's/^\@//')
elif [ "${fwd_file_type}" == "gzip" ]
then
	fwd_id_list=$(zcat ${fwd_reads} | awk '{if(NR%4==1){print $1}}' | perl -pe 's/^\@//')
fi

if [ "${rev_file_type}" == "ASCII" ]
then
	rev_id_list=$(awk '{if(NR%4==1){print $1}}' ${rev_reads} | perl -pe 's/^\@//')
elif [ "${rev_file_type}" == "gzip" ]
then
	rev_id_list=$(zcat ${rev_reads} | awk '{if(NR%4==1){print $1}}' | perl -pe 's/^\@//')
fi
num_fwd_ids=$(echo "${fwd_id_list}" | wc -l)
num_rev_ids=$(echo "${rev_id_list}" | wc -l)
if [ "${num_fwd_ids}" -ge "${num_rev_ids}" ]
then
	base_list="fwd_id_list"
	frag_list="rev_id_list"
	base_num="${num_fwd_ids}"
	frag_num="${num_rev_ids}"
else
	base_list="rev_id_list"
	frag_list="fwd_id_list"
	base_num="${num_rev_ids}"
	frag_num="${num_fwd_ids}"
fi
base_block_size=$(echo  -e "${base_num}" | awk '{if(length($1)<9){print $1}else{print 1000000}}')
base_block_count=$(echo -e "${base_num}\t${base_block_size}" | awk 'BEGIN{FS="\t"}{if($1%$2==0){print $1/$2}else{print (($1/$2)+1)}}' | cut -d\. -f1)
frag_block_size=$(echo  -e "${frag_num}" | awk '{if(length($1)>=7){print 1000000}else{print 10000}}')
frag_block_count=$(echo -e "${frag_num}\t${frag_block_size}" | awk 'BEGIN{FS="\t"}{if($1%$2==0){print $1/$2}else{print (($1/$2)+1)}}' | cut -d\. -f1)
echo -e "$base_num\t$frag_num\t$base_block_size\t$base_block_count\t$frag_block_size\t$frag_block_count"
for frag_block in $(seq 1 ${frag_block_count})
do
	frag_start_line=$(echo ${frag_block} | awk -v frag_block_size="${frag_block_size}" '{print ((($1-1)*frag_block_size)+1)}' )
	for base_block in $(seq 1 ${base_block_count})
	do
		base_start_line=$(echo ${base_block} | awk -v base_block_size="${base_block_size}" '{print ((($1-1)*base_block_size)+1)}')
		grep -wFf <(echo "${!frag_list}" | tail -n+${frag_start_line} | head -n${frag_block_size}) <(echo "${!base_list}" | tail -n+${base_start_line} | head -n${base_block_size})
	done
done > ${base_name}_id_list
seqtk subseq ${fwd_reads} ${base_name}_id_list > ${base_name}_fwd.fastq
seqtk subseq ${rev_reads} ${base_name}_id_list > ${base_name}_rev.fastq
rm ${base_name}_id_list
