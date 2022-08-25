#!/bin/bash
kegg_tmp_dir="$HOME/.kegg_tmp"
orthogene_file="${kegg_tmp_dir}/ortholog_gene_mappings.tsv"
genepath_file="${kegg_tmp_dir}/gene_pathway_mappings.tsv"
pathways_file="${kegg_tmp_dir}/pathway_names"
gene_str=$1
ortho_str=$2
ortholog_list=$(echo $2 | perl -pe 's/\,/\n/g' | cut -d\: -f2 | grep -v ^$ )
gene_list=$(grep -wFf <(echo "$ortholog_list") "$orthogene_file" | cut -f2 | cut -d\: -f2 | grep -v ^$ )
pathway_list=$(grep -wFf <(echo "$gene_list") "$genepath_file" | cut -f2 | cut -d\: -f2 | grep -v ^$ )
if [ -z "$pathway_list" ]
then
	pathway_str=""
else
	pathway_str=$(grep -wFf <(echo "$pathway_list") "$pathways_file" | perl -pe 's/\n/\|/g' | perl -pe 's/\|$//g' )
fi
echo -e "$gene_str\t$ortho_str\t$pathway_str"
