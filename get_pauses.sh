#!/bin/bash
covstats_file=$1
gene_list_file=$2
gene_list=`cat $gene_list_file`
for gene in $gene_list
do
  gene_datablock=`grep ^$gene $covstats_file`
  norare_datablock=`echo "$gene_datablock" | grep norare`
  avg_depth=`echo "$norare_datablock" | grep norare | cut -f6`
  depth_sd=`echo "$norare_datablock" | grep norare | cut -f7`
  codon_list=`echo "$gene_datablock" | grep -v norare | cut -f2 -d_ | sort -V | uniq`
  echo -e "$norare_datablock\tcontrol"
  for codon in $codon_list
  do
    codon_datablock=`echo "$gene_datablock" | grep $codon`
    pos_list=`echo "$codon_datablock" | cut -f1 | cut -d_ -f3 | sort -n`
    for pos in $pos_list
    do
      codon_str=`echo "$gene""_$codon""_$pos"`
      max_depth=`echo "$codon_datablock" | grep -w "$codon_str" | cut -f4`
      pause_str=`echo -e "$avg_depth\t$max_depth\t$depth_sd" | awk '
        BEGIN{FS="\t"}
             {if($1 >= $2            ){z_score = 0}
         else if($1 <  $2 && $3 != 0 ){z_score=sqrt((($2-$1)/$3)^2)}}
             {if(z_score <= 1                ){print z_score"(NP:HC)"}
         else if(z_score >  1 && z_score <= 2){print z_score"(P:LC)" }
         else if(z_score >  2 && z_score <= 3){print z_score"(P:HC)" }
         else if(z_score >  3                ){print z_score"(P:VHC)"}}'`
      echo "$gene_datablock" | awk -v codon_str="$codon_str" -v pause_str="$pause_str" 'BEGIN{FS="\t"}{if($1==codon_str){print $AF FS pause_str}}'
    done
  done
done
