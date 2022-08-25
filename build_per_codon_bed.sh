#!/bin/bash
for gene in `cut -f4 NC_000913.bed | sort -V | uniq`
do
  gene_datablock=`awk -v gene="$gene" 'BEGIN{FS="\t"}{if($4==gene){print $AF}}' NC_000913.bed`
  gene_strand=`echo "$gene_datablock" | cut -f6`
  sbegin=`echo "$gene_datablock" | cut -f2`
  send=`echo "$gene_datablock" | cut -f3`
  echo -e "NC_000913\t`echo $sbegin | awk '{print $1-1}'`\t$send\t$gene""_norare\t.\t$gene_strand" > temp1.bed
  echo | perl -pe 's/\n//' > temp2.bed
  if [ "$gene_strand" == "+" ]
  then
    codon_datablock=`seqret -sbegin $sbegin -send $send NC_000913.fasta raw::stdout | perl -pe 's/\n//g' | sed -e "s/.\{3\}/&\n/g"`
    tyr1_pos_list=`echo "$codon_datablock" | grep -wn "tat" | cut -d\: -f1`
    tyr2_pos_list=`echo "$codon_datablock" | grep -wn "tac" | cut -d\: -f1`
    arg2_pos_list=`echo "$codon_datablock" | grep -wn "cga" | cut -d\: -f1`
    arg4_pos_list=`echo "$codon_datablock" | grep -wn "aga" | cut -d\: -f1`
    lys1_pos_list=`echo "$codon_datablock" | grep -wn "aaa" | cut -d\: -f1`
    lys2_pos_list=`echo "$codon_datablock" | grep -wn "aag" | cut -d\: -f1`
    gly1_pos_list=`echo "$codon_datablock" | grep -wn "ggg" | cut -d\: -f1`
    pro1_pos_list=`echo "$codon_datablock" | grep -wn "ccc" | cut -d\: -f1`
    #<===========================================================================================================================>#
    for tyr1_pos in $tyr1_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$tyr1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$tyr1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_tyr1_$tyr1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for tyr2_pos in $tyr2_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$tyr2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$tyr2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_tyr2_$tyr2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for arg2_pos in $arg2_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$arg2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$arg2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_arg2_$arg2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for arg4_pos in $arg4_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$arg4_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$arg4_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_arg4_$arg4_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for lys1_pos in $lys1_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$lys1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$lys1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_lys1_$lys1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for lys2_pos in $lys2_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$lys2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$lys2_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_lys2_$lys2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for gly1_pos in $gly1_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$gly1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$gly1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_gly1_$gly1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for pro1_pos in $pro1_pos_list
    do
      bed_start_pos=`echo -e "$sbegin\t$pro1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-4}'`
      bed_end_pos=`echo -e "$sbegin\t$pro1_pos" | awk 'BEGIN{FS="\t"}{print ($1+($2*3))-1}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_pro1_$pro1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
  elif [ "$gene_strand" == "-" ]
  then
    codon_datablock=`revseq -sbegin $sbegin -send $send NC_000913.fasta raw::stdout | perl -pe 's/\n//g' | sed -e "s/.\{3\}/&\n/g"`
    tyr1_pos_list=`echo "$codon_datablock" | grep -wn "tat" | cut -d\: -f1`
    tyr2_pos_list=`echo "$codon_datablock" | grep -wn "tac" | cut -d\: -f1`
    arg2_pos_list=`echo "$codon_datablock" | grep -wn "cga" | cut -d\: -f1`
    arg4_pos_list=`echo "$codon_datablock" | grep -wn "aga" | cut -d\: -f1`
    lys1_pos_list=`echo "$codon_datablock" | grep -wn "aaa" | cut -d\: -f1`
    lys2_pos_list=`echo "$codon_datablock" | grep -wn "aag" | cut -d\: -f1`
    gly1_pos_list=`echo "$codon_datablock" | grep -wn "ggg" | cut -d\: -f1`
    pro1_pos_list=`echo "$codon_datablock" | grep -wn "ccc" | cut -d\: -f1`
    #<===========================================================================================================================>#
    for tyr1_pos in $tyr1_pos_list
    do
      bed_start_pos=`echo -e "$send\t$tyr1_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$tyr1_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_tyr1_$tyr1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for tyr2_pos in $tyr2_pos_list
    do
      bed_start_pos=`echo -e "$send\t$tyr2_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$tyr2_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_tyr2_$tyr2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for arg2_pos in $arg2_pos_list
    do
      bed_start_pos=`echo -e "$send\t$arg2_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$arg2_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_arg2_$arg2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for arg4_pos in $arg4_pos_list
    do
      bed_start_pos=`echo -e "$send\t$arg4_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$arg4_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_arg4_$arg4_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for lys1_pos in $lys1_pos_list
    do
      bed_start_pos=`echo -e "$send\t$lys1_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$lys1_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_lys1_$lys1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for lys2_pos in $lys2_pos_list
    do
      bed_start_pos=`echo -e "$send\t$lys2_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$lys2_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_lys2_$lys2_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for gly1_pos in $gly1_pos_list
    do
      bed_start_pos=`echo -e "$send\t$gly1_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$gly1_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_gly1_$gly1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
    for pro1_pos in $pro1_pos_list
    do
      bed_start_pos=`echo -e "$send\t$pro1_pos" | awk 'BEGIN{FS="\t"}{print $1-($2*3)}'`
      bed_end_pos=`echo -e "$send\t$pro1_pos" | awk 'BEGIN{FS="\t"}{print $1-(($2*3)-3)}'`
      echo -e "NC_000913\t$bed_start_pos\t$bed_end_pos\t$gene""_pro1_$pro1_pos\t.\t$gene_strand"
    done >> temp2.bed
    unset bed_start_pos bed_end_pos
    #<===========================================================================================================================>#
  fi
  bedtools subtract -a temp1.bed -b temp2.bed >> full.bed
  cat temp2.bed >> full.bed
done
rm -rf temp1.bed temp2.bed
