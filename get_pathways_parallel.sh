#!/bin/bash
#############################################################################################################################################################
data_sheet=$(cat "$1" | grep -v "\#")                                                                                                                       #
annotation_file_list=$(echo "$data_sheet" | awk 'BEGIN{FS="\t"}{if($1=="annotation file"){print $2}}' | perl -pe 's/\,/\n/g' | grep -v ^$ | sort -V | uniq) #
exclude_org_list=$(echo     "$data_sheet" | awk 'BEGIN{FS="\t"}{if($1=="org exclude"){print $2}}' | perl -pe 's/\,/\n/g' | grep -v ^$ | sort -V | uniq)     #
include_org_list=$(echo     "$data_sheet" | awk 'BEGIN{FS="\t"}{if($1=="org include"){print $2}}' | perl -pe 's/\,/\n/g' | grep -v ^$ | sort -V | uniq)     #
kegg_data_dir=$(echo        "$data_sheet" | awk 'BEGIN{FS="\t"}{if($1=="KEGG data dir"){print $2}}' | grep -v ^$ | sort -V | uniq)                          #
kegg_tmp_dir="$HOME/.kegg_tmp"                                                                                                                              #
work_dir=$(pwd)                                                                                                                                             #
file_list=$(echo -e "ortholog_gene_mappings\norg_list\npathway_list\ngene_pathway_mappings")                                                                #
#############################################################################################################################################################

##################################
if [ -z "$kegg_data_dir" ]       #
then                             #
	kegg_data_dir="$HOME/kegg"     #
else                             #
	kegg_data_dir=${kegg_data_dir} #
fi                               #
##################################

##########################################
if [ -z "$exclude_org_list" ]            #
then                                     #
	exclude_org_list=$(echo -e "hsa\nmmu") #
fi                                       #
##########################################

##########################################################
missing_files="0"                                        #
for annotation_file in $annotation_file_list             #
do                                                       #
  if [ ! -f "$annotation_file" ]                         #
  then                                                   #
	  echo "Missing annotation file $annotation_file"      #
	  let missing_files=$missing_files+1                   #
		annotation_file_list=$(echo "$annotation_file_list" | grep -wv "$annotation_file")
  fi                                                     #
done                                                     #
if [ "$missing_files" -gt 0 ]                            #
then                                                     #
	echo "No annotation files left"                        #
	exit 1                                                 #
fi                                                       #
##########################################################

##########################################################
if [ ! -d "$kegg_data_dir" ]                             #
then                                                     #
	mkdir -p "$kegg_data_dir"                              #
	exit_code="$?"                                         #
	if [ "$exit_code" -gt 0 ]                              #
	then                                                   #
		echo "Unable to create $kegg_data_dir directory"     #
		exit $exit_code                                      #
	fi                                                     #
fi                                                       #
##########################################################

#########################################################
if [ ! -d "$kegg_tmp_dir" ]                             #
then                                                    #
	mkdir -p "$kegg_tmp_dir"                              #
	exit_code="$?"                                        #
	if [ "$exit_code" -gt 0 ]                             #
	then                                                  #
		echo "Unable to create $kegg_tmp_dir directory"     #
		exit $exit_code                                     #
	fi                                                    #
fi                                                      #
#########################################################

##################################################################################################
cd ${kegg_data_dir}                                                                              #
for file in $file_list                                                                           #
do                                                                                               #
	if [ -f "${file}.gz" ]                                                                         #
	then                                                                                           #
		echo "$file file present"                                                                    #
	else                                                                                           #
		echo "$file file missing, fetching, caution this might take a while"                         #
		wget "https://raw.githubusercontent.com/vflorelo/kegg_mappings/master/$file.gz"              #
	fi                                                                                             #
done                                                                                             #
##################################################################################################

##############################################################################################################################
if [ -z "$include_org_list" ]                                                                                                #
then                                                                                                                         #
	include_org_list=$(zcat ${kegg_data_dir}/org_list.gz | cut -f2 | sort -V | uniq | grep -wvFf <(echo "$exclude_org_list") ) #
else                                                                                                                         #
	include_org_list="$include_org_list"                                                                                       #
fi                                                                                                                           #
##############################################################################################################################

#####################################################################################################################################################################################
cd ${work_dir}                                                                                                                                                                      #
for annotation_file in $annotation_file_list                                                                                                                                        #
do                                                                                                                                                                                  #
	kegg_term_list=$(cut -f2 ${annotation_file} | perl -pe 's/\,/\n/g' | grep -v ^$ | cut -f2 -d\: | sort -V | uniq)                                                                  #
  ortholog_list=$(zgrep -wFf <(echo "$kegg_term_list") ${kegg_data_dir}/ortholog_gene_mappings.gz | grep -wFf <(echo "$include_org_list") | cut -f2 | cut -d: -f2 | sort -V | uniq) #
  pathway_list=$(zgrep -wFf <(echo "$ortholog_list") ${kegg_data_dir}/gene_pathway_mappings.gz | cut -f2 | cut -d\: -f2 | sort -V | uniq )                                          #
	for pathway in $pathway_list                                                                                                                                                      #
	do                                                                                                                                                                                #
		pathway_name=$(curl -s "http://rest.kegg.jp/get/$pathway" | grep -w ^NAME | perl -pe 's/NAME\ \ \ \ \ \ \ \ //g')                                                               #
		echo -e "$pathway{$pathway_name}"                                                                                                                                               #
	done > ${kegg_tmp_dir}/pathway_names                                                                                                                                              #
	zgrep -wFf <(echo "$kegg_term_list") ${kegg_data_dir}/ortholog_gene_mappings.gz | grep -wFf <(echo "$include_org_list") > ${kegg_tmp_dir}/ortholog_gene_mappings.tsv              #
	zgrep -wFf <(echo "$ortholog_list")  ${kegg_data_dir}/gene_pathway_mappings.gz > ${kegg_tmp_dir}/gene_pathway_mappings.tsv                                                        #
	awk 'BEGIN{FS="\t"}{print "get_pathways.sh "$1,$2}' $annotation_file | parallel -j12                                                                                              #
done                                                                                                                                                                                #
rm -rf ${kegg_tmp_dir}/*                                                                                                                                                            #
#####################################################################################################################################################################################
