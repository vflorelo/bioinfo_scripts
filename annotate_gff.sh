#!/bin/bash
gene_id=$1
gff_file=$2
tsv_file=$3
product=$(grep -w ${gene_id} ${tsv_file} | tr [:upper:] [:lower:] | cut -f4 | sort -V | uniq | grep -v ^$)
domain=$(grep -w ${gene_id} ${tsv_file} | cut -f2 | cut -d\: -f1 | sort -V | uniq | grep -v ^$)
datablock=$(grep -w "${gene_id}" "${gff_file}")
src_id=$(echo "${datablock}" | cut -f1 | sort -V | uniq | grep -v ^$ | head -n1 )
if [ ! -z "${product}" ]
then
    product=$(echo "product=\"Putative ${product}\"" | sed -e "s|+|%2B|g;s|/|%2F|g;s|:|%3A|g;s|>|%3E|g;s|\[|%5B|g;s|\]|%5D|g;s|,|%2C|g;" )
    inference="inference=\"protein motif:PANTHER:${domain}\""
else
    product="product=\"Hypothetical protein\""
    inference=""
fi
gene_str=$(echo "${datablock}" | grep -w "gene" | awk -v product="${product}" -v gene_id="${gene_id}"     'BEGIN{FS="\t"}{print $0";locus_tag="gene_id";gene_biotype=protein_coding;"product}')
mrna_str=$(echo "${datablock}" | grep -w "mRNA")
exon_str=$(echo "${datablock}" | grep -w "exon")
cds_str=$(echo  "${datablock}" | grep -w "CDS"  | awk -v product="${product}" -v inference="${inference}" 'BEGIN{FS="\t"}{print $0";"product";"inference}')
echo -e "${gene_str}\n${mrna_str}\n${exon_str}\n${cds_str}" | grep -w ^${src_id}