#!/bin/bash
assembly_datablock=$(infoseq $1 | tail -n+2 | awk '{print $3"\t"$6}' | sort -nrk2 )
longest_contig=`echo "$assembly_datablock" | head -n1 | cut -f2`
num_contigs=`echo "$assembly_datablock" | wc -l`
assembly_length=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{sum+=$2}END{print sum}'`
n50=`echo "$assembly_datablock" | awk -v assembly_length="$assembly_length" 'BEGIN{FS="\t"}{sum+=$2}{if(sum>=(assembly_length/2)){print $2}}' | head -n1`
megabase_length=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e6){sum+=$2}}END{print sum}'`
megabase_count=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e6){print $AF}}' | wc -l`
decimegabase_length=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e5){sum+=$2}}END{print sum}'`
decimegabase_count=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e5){print $AF}}' | wc -l`
centimegabase_length=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e4){sum+=$2}}END{print sum}'`
centimegabase_count=`echo "$assembly_datablock" | awk 'BEGIN{FS="\t"}{if($2>=1e4){print $AF}}' | wc -l`
echo -e "Assembly length\t$assembly_length" | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
echo -e "Longest contig\t$longest_contig" | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
echo -e "Contig count\t$num_contigs"
echo -e "Assembly n50\t$n50"  | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
echo -e "Contigs >1e6 bp\t$megabase_count"
echo -e "Length  >1e6 bp\t$megabase_length" | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
echo -e "Contigs >1e5 bp\t$decimegabase_count"
echo -e "Length  >1e5 bp\t$decimegabase_length" | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
echo -e "Contigs >1e4 bp\t$centimegabase_count"
echo -e "Length  >1e4 bp\t$centimegabase_length" | awk 'BEGIN{FS="\t"}{print $1 FS $2/1e6"Mbp"}'
