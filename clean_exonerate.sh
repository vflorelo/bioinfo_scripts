#!/bin/bash
pos_list=$(cat)
start_line=$(echo "${pos_list}" | cut -f1)
num_lines=$(echo  "${pos_list}" | cut -f3)
gff_file=$(echo   "${pos_list}" | cut -f4)
pos_id=$(echo     "${pos_list}" | cut -f5)
datablock=$(tail -n+${start_line} ${gff_file} | head -n${num_lines} | grep -v \# | perl -pe 's/\ \;/\;/g;s/\;\ /\;/g;s/\ /\=/g;s/\:protein2genome\:local//' | awk 'BEGIN{FS="\t"}{if($3=="gene" || $3=="exon"){print $0}}')
gene_datablock=$(echo "$datablock" | awk 'BEGIN{FS="\t"}{if($3=="gene"){print $0}}')
gene_strand=$(echo "${gene_datablock}" | cut -f7 | sort | uniq | head -n1)
if [ "${gene_strand}" == "+" ]
then
	exon_datablock=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="exon"){print $0}}')
elif [ "${gene_strand}" == "-" ]
then
	exon_datablock=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="exon"){print $0}}' | tac)
fi
gene_id=$(echo "${gene_datablock}" | cut -f9 | perl -pe 's/\;/\n/g' | grep gene_id | cut -d\= -f2)
gene_prefix=$(echo "${gene_datablock}" | cut -f1 | cut -d_ -f1 | sort | uniq | head -n1)
gene_num_str=$(echo ${pos_id} | awk '{if(length($1)==1){print "00000"$1}else if(length($1)==2){print "0000"$1}else if(length($1)==3){print "000"$1}else if(length($1)==4){print "00"$1}else if(length($1)==5){print "0"$1}else if(length($1)==6){print $1}}')
gene_id_str=$(echo "${gene_prefix}ms_${gene_num_str}")
gene_datablock=$(echo "${gene_datablock}" | perl -pe "s/gene_id=${gene_id}\;/ID\=$gene_id_str\;/;s/sequence/query/")
mrna_datablock=$(echo "${gene_datablock}" | perl -pe "s/ID\=/ID\=$gene_id_str-T1\;parent\=/;s/\tgene\t/\tmRNA\t/")
exon_datablock=$(echo "${exon_datablock}" | awk -v gene_id_str="${gene_id_str}" 'BEGIN{FS="\t"}{print $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8 FS "ID="gene_id_str"-T1.exon"NR";parent="gene_id_str"-T1;"$9}')
cds_datablock=$(echo "${exon_datablock}" | awk -v gene_id_str="${gene_id_str}" 'BEGIN{FS="\t"}{print $1 FS $2 FS "CDS" FS $4 FS $5 FS $6 FS $7 FS $8 FS "ID="gene_id_str"-T1.cds;parent="gene_id_str"-T1;"$9}')
echo -e "$gene_datablock\n$mrna_datablock\n$exon_datablock\n$cds_datablock"
