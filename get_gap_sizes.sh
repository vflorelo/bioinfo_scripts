#!/bin/bash
fasta_file=$1
acc_list=$(grep \> ${fasta_file} | cut -d\> -f2 | cut -d' ' -f1 | sort -V | uniq)
tmp_file=$(uuidgen | cut -d\- -f1)
perl -pe 'if(/\>/){s/$/\t/};s/\n//g;s/\>/\n\>/g' ${fasta_file} | tail -n+2 > ${tmp_file}
for acc in ${acc_list}
do
  echo "#### ${acc}"
  grep -w ${acc} ${tmp_file}  | cut -f2 | perl -pe 's/[acgt]n/a\nn/gi;s/n[acgt]/n\na/gi' | awk 'BEGIN{FS="\t"}{if($1~"n"){scf_type="gap"}else{scf_type="contig"}}{print scf_type FS length($1)}'
  echo "###########"
done
rm -f ${tmp_file}
