#!/bin/bash
base_name=$1
prefix=$2

gff3sort_test=$(which gff3sort.pl 2> /dev/null)
if [ -z "$gff3sort_test" ]
then
    echo "Error: gff3sort.pl not found in PATH"
    exit 1
fi

cat ${base_name}.gff3 ${base_name}.trna.gff | grep -v ^# > ${base_name}.full.tmp.gff
gff3sort.pl --precise ${base_name}.full.tmp.gff > ${base_name}.full.gff
awk 'BEGIN{FS="\t"}{if($3=="gene"){print $0}}' ${base_name}.full.gff | perl -pe 's/.*ID\=//g;s/\;.*//' | awk -v prefix="$prefix" 'BEGIN{FS="\t"}{if (length(NR)==1){add_str="0000"}else if(length(NR)==2){add_str="000"}else if(length(NR)==3){add_str="00"}else if(length(NR)==4){add_str="0"}else if(length(NR)==5){add_str=""}}{print $1 FS prefix"_"add_str NR}' > id_tables
awk -v base_name="$base_name" '{print "rename.sh "base_name".full.gff "$1,$2}' id_tables | parallel -j 16 > ${base_name}.updated.tmp.gff 
gff3sort.pl --precise ${base_name}.updated.tmp.gff > ${base_name}.updated.gff 
