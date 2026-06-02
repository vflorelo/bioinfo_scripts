#!/bin/bash
gene_id=$1
gff_file=$2
datablock=$(grep -w "${gene_id}" "${gff_file}")
gene_start=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="gene"){print $4}}')
gene_end=$(echo   "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="gene"){print $5}}')
mrna_start=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="mRNA"){print $4}}')
mrna_end=$(echo   "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="mRNA"){print $5}}')
exon_start=$(echo "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="exon"){print $4}}' | sort -n | uniq | head -n1)
exon_end=$(echo   "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="exon"){print $5}}' | sort -n | uniq | tail -n1)
cds_start=$(echo  "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="CDS"){print  $4}}' | sort -n | uniq | head -n1)
cds_end=$(echo    "${datablock}" | awk 'BEGIN{FS="\t"}{if($3=="CDS"){print  $5}}' | sort -n | uniq | tail -n1)
echo -e "${gene_id}\t${gene_start}\t${mrna_start}\t${exon_start}\t${cds_start}"
echo -e "${gene_id}\t${gene_end}\t${mrna_end}\t${exon_end}\t${cds_end}"
if [ "${gene_start}" -ne "${exon_start}" ] || [ "${gene_start}" -ne "${cds_start}" ] || [ "${gene_start}" -ne "${mrna_start}" ]
then
    echo "Check start coordinates of ${gene_id}" 1>&2
fi

if [ "${gene_end}"   -ne "${exon_end}"   ] || [ "${gene_end}"   -ne "${cds_end}"   ] || [ "${gene_end}"   -ne "${mrna_end}"   ]
then
    echo "Check end coordinates of ${gene_id}" 1>&2
fi

if [ "${gene_start}" -ge "${gene_end}" ]
then
    echo "Check coordinates of ${gene_id}" 1>&2
fi