#!/bin/bash
echo -e "Gene\t1_3\t1_5\t2_3\t2_5\t3_3\t3_5\t4_3\t4_5\t6_3\t6_5\t7_3\t7_5"
for gene in `cat gene_list`
do
  gene_str=`echo $gene`
  for dataset in `ls | grep tsv | grep pauses`
  do
    num_pauses=`grep ^$gene $dataset | grep -v norare | grep -v "NP:" | grep -v LC | wc -l`
    gene_str=`echo -e "$gene_str\t$num_pauses"`
  done
  echo "$gene_str"
done

