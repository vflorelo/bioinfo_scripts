#!/bin/bash
transcript=$(cat)
ts_datablock=$(grep -w ^${transcript} Perkinsus_marinus.fimo.uniprot.blastx | awk 'BEGIN{FS="\t"}{if($13<0){print $1 FS $2 FS $13 FS "-"}else{print $1 FS $2 FS $13 FS "+"}}' )
hit_list=$(echo "${ts_datablock}" | cut -f2 | sort -V | uniq)
for hit in ${hit_list}
do
	hit_datablock=$(echo "${ts_datablock}" | grep -w ${hit} | sort | uniq)
	strand_list=$(echo "${hit_datablock}" | cut -f4 | sort | uniq)
	for strand in ${strand_list}
	do
		strand_datablock=$(echo "${hit_datablock}" | awk -v strand="${strand}" 'BEGIN{FS="\t"}{if($4==strand){print $0}}' | sort | uniq )
		num_hits=$(echo "${strand_datablock}" | wc -l)
		if [ "${num_hits}" -gt 1 ]
		then
			num_frameshifts=$(grep -w ^${transcript} Perkinsus_marinus.fimo.gff | awk -v strand="${strand}" 'BEGIN{FS="\t"}{if($7==strand){print $0}}' | wc -l)
			if [ "${num_frameshifts}" -ge "1" ]
			then
				echo ${transcript}
			fi
		fi
	done
done
