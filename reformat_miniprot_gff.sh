#!/bin/bash
id=$1
gff_file="patl.redundans.missing.miniprot.gff"
cds_datablock=$(grep -w "${id}" "${gff_file}" | grep -w CDS | cut -f 1-7)
scaffold=$(echo  "${cds_datablock}" | cut -f 1 | sort -V | uniq | head -n 1)
start_pos=$(echo "${cds_datablock}" | awk '{print $4"\n"$5}' | sort -n | head -n 1)
end_pos=$(echo   "${cds_datablock}" | awk '{print $4"\n"$5}' | sort -n | tail -n 1)
strand=$(echo    "${cds_datablock}" | cut -f7 | sort | uniq | head -n 1)
cds_str=""
exon_str=""
gene_str=$(echo -e "${scaffold}\tminiprot\tgene\t${start_pos}\t${end_pos}\t.\t${strand}\t.\tID=${id}")
mrna_str=$(echo -e "${scaffold}\tminiprot\tmRNA\t${start_pos}\t${end_pos}\t.\t${strand}\t.\tID=${id}-T1;Parent=${id}")
if [ "${strand}" == "-" ]
then
  cds_datablock=$(echo  "${cds_datablock}" | tac)
fi
exon_datablock=$(echo "${cds_datablock}" | perl -pe 's/CDS/exon/' | awk -v id="${id}" 'BEGIN{FS="\t";OFS="\t"}{print $0,".","ID="id"-T1.exon"NR";Parent="id"-T1"}')
cds_datablock=$(echo  "${cds_datablock}" | awk -v id="${id}" 'BEGIN{FS="\t";OFS="\t"}{print $0,".","ID="id"-T1.cds;Parent="id"-T1"}')
echo -e "${gene_str}\n${mrna_str}\n${exon_datablock}\n${cds_datablock}"