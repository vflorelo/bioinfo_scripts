#!/bin/bash
bed_datablock=$(cat)
ctg_list=$(echo "$bed_datablock" | cut -f1 | sort -V | uniq)
for ctg in $ctg_list
do
	ctg_length=$(echo "$bed_datablock" | grep -w ^${ctg} | cut -f3)
	num_blocks=$(echo $ctg_length | awk '{if($1<=10000){print 1}else{if(($1%10000)==0){print $1/10000}else{print ($1/10000)-(($1%10000)/10000)+1}}}')
	for block in $(seq 1 $num_blocks)
	do
		start_pos=$(echo $block | awk '{print ($1-1)*10000}')
		if [ "${block}" -lt "${num_blocks}" ]
		then
			end_pos=$(echo $block | awk '{print (($1-1)*10000)+10000}')
		elif [ "${block}" -eq "${num_blocks}" ]
		then
			end_pos=$ctg_length
		fi
		echo -e "${ctg}\t${start_pos}\t${end_pos}\t${ctg}_${block}"
	done
done
