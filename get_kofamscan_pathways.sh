#!/bin/bash
kofam_file=$1
org_list=$2
#pfa 	Plasmodium falciparum 3D7 	RefSeq
#pfd 	Plasmodium falciparum Dd2 	Broad
#pfh 	Plasmodium falciparum HB3 	Broad
#pyo 	Plasmodium yoelii 	RefSeq
#pcb 	Plasmodium chabaudi 	RefSeq
#pbe 	Plasmodium berghei 	RefSeq
#pkn 	Plasmodium knowlesi 	RefSeq
#pvx 	Plasmodium vivax 	RefSeq
#pcy 	Plasmodium cynomolgi 	RefSeq
#tan 	Theileria annulata 	RefSeq
#tpv 	Theileria parva 	RefSeq
#tot 	Theileria orientalis 	RefSeq
#beq 	Theileria equi 	RefSeq
#bbo 	Babesia bovis 	RefSeq
#bmic 	Babesia microti 	RefSeq
#cpv 	Cryptosporidium parvum 	RefSeq
#cho 	Cryptosporidium hominis 	RefSeq
#tgo 	Toxoplasma gondii 	RefSeq
datablock=$(grep -v ^# $kofam_file | perl -pe 's/\*//' | awk 'BEGIN{OFS="\t"}{print $1,$2}' | sort -V | uniq)
org_list=$(echo ${org_list} | perl -pe 's/\,/\n/g' | sort | uniq | grep [a-z])
org_header=$(echo "${org_list}" | perl -pe 's/\n/\t/g' | perl -pe 's/\t$//')
echo -e "gene\tko\tpathway_list\tmodule_list\t$org_header"
num_assoc=$(echo "${datablock}" | wc -l)
for i in $(seq 1 ${num_assoc})
do
  assoc_datablock=$(echo "${datablock}" | tail -n+$i | head -n1)
  gene_name=$(echo "$assoc_datablock" | cut -f1)
  gene_ko=$(echo "$assoc_datablock" | cut -f2)
  pathway_list=$(curl -s "http://rest.kegg.jp/link/pathway/${gene_ko}" | cut -f2 | cut -d\: -f2 | grep ^ko | sort -V | uniq | perl -pe 's/\n/\,/g' | perl -pe 's/\,$//')
  module_list=$(curl -s "http://rest.kegg.jp/link/module/${gene_ko}" | cut -f2 | cut -d\: -f2 | sort -V | uniq | perl -pe 's/\n/\,/g' | perl -pe 's/\,$//')
  orthology_datablock=$(curl -s "http://rest.kegg.jp/link/genes/${gene_ko}" | grep -wFf <(echo "${org_list}"))
  org_path_str=""
  for org in ${org_list}
  do
    org_pathway_list=""
    ortho_list=$(grep -w ${org} <(echo "${orthology_datablock}") | cut -f2)
    for ortholog in ${ortho_list}
    do
      org_pathway_list=$(curl -s "http://rest.kegg.jp/link/pathway/${ortholog}" | cut -f2 | cut -d\: -f2 | sort -V | uniq | perl -pe 's/\n/\,/g' | perl -pe 's/\,$//')
    done
    org_path_str=$(paste <(echo "${org_path_str}") <(echo "${org_pathway_list}"))
  done
  org_path_str=$(echo "${org_path_str}" | perl -pe 's/^\t//;s/\t$//')
  echo -e "${gene_name}\t${gene_ko}\t${pathway_list}\t${module_list}\t${org_path_str}"
done
