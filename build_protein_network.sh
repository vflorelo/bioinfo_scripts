#!/bin/bash
#basically what you get from 'get_dupes' or 'compare_genomes'
filtered_blast_file=$1
#either use score, percent similarity or evalue as informative criterion for network edges
db_file=$2
### prot_1@prot_2	161		155		2		1		157		153		599		2e-64	156		125
### qseqid@sseqid	qlen	slen	qstart	sstart	qend	send	score	evalue	length	positive	
### ^^^^^^^^^^^^^	^^^^	^^^^	^^^^^^	^^^^^^	^^^^	^^^^	^^^^^	^^^^^^	^^^^^^	^^^^^^^^
###       $1         $2      $3        $4     $5     $6      $7       $8      $9      $10     $11
pair_list=`cat "$filtered_blast_file" | awk '{print $1}' | sort | uniq `
prot_list=`cat "$db_file" | grep \> | perl -pe 's/\>//g' | awk '{print $1}' | sort | uniq`
for i in $pair_list
do
  data_block=`cat "$filtered_blast_file" | grep -w $i | cut -f1-11`
  min_size=`echo "$data_block" | awk '{if($3>$2){print $2}else{print $3}}'`
  total_similarity=`echo "$data_block" | awk -v min_size="$min_size" '{sum+=$11}END{print (sum/min_size)*100}'`
  total_score=`echo "$data_block" | awk '{sum+=$8}END{print sum}'`
  lowest_eval=`echo "$data_block" | awk '{print $9}' | sort -g | head -n1`
  echo "$i $total_similarity $total_score $lowest_eval" | perl -pe 's/\@/\tfull\t/g; s/\ /\t/g' >> protein_network.tsv
done
present_nodes=`cat protein_network.tsv | awk '{print $1"\n"$3}' | sort | uniq`
for j in $present_nodes
do
  prot_list=`echo "$prot_list" | grep -wv $j`
done
echo "$prot_list" >> protein_network.tsv
exit 0
