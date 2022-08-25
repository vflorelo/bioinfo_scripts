#!/bin/bash
gbk_file=$1
definition=`awk '{if($1=="DEFINITION"){print $2}}' $gbk_file`
locus=`awk '{if($1=="LOCUS"){print $2}}' $gbk_file`
length=`infoseq $gbk_file | awk '{print $6}' | grep -v [a-z]`
gff_datablock=`seqret -feature $gbk_file gff3::stdout | awk 'BEGIN{FS="\t"}{if($3=="CDS" && $9!~"Parent="){print $AF}}'`
num_proteins=`echo "$gff_datablock" | wc -l`
for prot_num in `seq 1 $num_proteins`
do
  prot_datablock=`echo "$gff_datablock" | tail -n+$prot_num | head -n1`
  prot_info=`echo "$prot_datablock" | cut -f9 | perl -pe 's/\;/\n/g' `
  prot_id=`echo "$prot_info" | awk 'BEGIN{FS="="}{if($1=="ID"){print $2}}'`
  prot_product=`echo "$prot_info" | awk 'BEGIN{FS="="}{if($1=="product"){print $2}}'`
  prot_location=`echo "$prot_datablock" | awk 'BEGIN{FS="\t"}{if($7=="-"){print $5 FS $4}else if($7=="+"){print $4 FS $5}}'`
  echo -e "$locus\t$length\t$prot_id\t$prot_location\t$prot_product"
  unset prot_datablock prot_location prot_info prot_id prot_product
done
exit 0
