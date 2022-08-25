#!/bin/bash
gff_file=$1
base_name=$(echo "${gff_file}" | perl -pe 's/\.gff$//;s/\.gff3$//')
chrom_list=$(grep -v ^\# "${gff_file}" | cut -f1 | sort -V | uniq)
switch_list=""
for chrom in ${chrom_list}
do
  chrom_switch_list=$(grep -w ^"${chrom}" "${gff_file}" | cut -f7 | perl -pe 's/\n//' | perl -pe 's/\+\-/\+\n\-/g;s/\-\+/\-\n\+/g' | awk '{print length($1)}')
  switch_list=$(echo -e "${switch_list}\n${chrom_switch_list}" | grep -v ^$ )
done
echo "${switch_list}" | grep [0-9] | sort -n | uniq -c | sort -nk2 | awk 'BEGIN{OFS="\t"}{print $2,$1}' > ${base_name}.strand_switch.tsv