#!/bin/bash
#build_minimal_kegg_database################################
cur_date=$(date +%d-%m-%Y)                                 #
kegg_data_dir="$HOME/kegg"                                 #
kegg_tmp_dir="$HOME/kegg"                                  #
log_file="${kegg_data_dir}/update_kegg_db-${cur_date}.log" #
############################################################

##############################
if [ ! -d "$kegg_data_dir" ] #
then                         #
	mkdir -p "$kegg_data_dir"  #
fi                           #
##############################

#############################
if [ ! -d "$kegg_tmp_dir" ] #
then                        #
	mkdir -p "$kegg_tmp_dir"  #
fi                          #
#############################

cd $kegg_tmp_dir
curl -s "http://rest.kegg.jp/list/organism" | cut -f1,2 | grep -wv > org_list 2>> $log_file
gzip -9 org_list 2>> $log_file
curl -s "http://rest.kegg.jp/list/orthology" > ortholog_list 2>> $log_file
gzip -9 ortholog_list 2>> $log_file
for org in $(zcat org_list.gz | cut -f2 | sort -V | uniq )
do
  curl -s "http://rest.kegg.jp/list/pathway/$org" >> pathway_list 2>> $log_file
	curl -s "http://rest.kegg.jp/link/pathway/$org" >> gene_pathway_mappings 2>> $log_file
done
gzip -9 pathway_list 2>> $log_file
gzip -9 gene_pathway_mappings 2>> $log_file

for ortholog in $(zgrep ortholog_list.gz | cut -f1 | cut -d\: -f2 | sort -V | uniq)
do
  curl -s "http://rest.kegg.jp/link/genes/$ortholog" >> ortholog_gene_mappings 2>> $log_file
done
gzip -9 ortholog_gene_mappings 2>> $log_file
mkdir -p ${kegg_data_dir}/backup_${cur_date} 2>> $log_file

#######################################################################
if [ -f "${kegg_data_dir}/org_list.gz" ]                              #
then                                                                  #
	mv ${kegg_data_dir}/org_list.gz ${kegg_data_dir}/backup_${cur_date} #
fi                                                                    #
#######################################################################

############################################################################
if [ -f "${kegg_data_dir}/ortholog_list.gz" ]                              #
then                                                                       #
	mv ${kegg_data_dir}/ortholog_list.gz ${kegg_data_dir}/backup_${cur_date} #
fi                                                                         #
############################################################################

###########################################################################
if [ -f "${kegg_data_dir}/pathway_list.gz" ]                              #
then                                                                      #
	mv ${kegg_data_dir}/pathway_list.gz ${kegg_data_dir}/backup_${cur_date} #
fi                                                                        #
###########################################################################

####################################################################################
if [ -f "${kegg_data_dir}/gene_pathway_mappings.gz" ]                              #
then                                                                               #
	mv ${kegg_data_dir}/gene_pathway_mappings.gz ${kegg_data_dir}/backup_${cur_date} #
fi                                                                                 #
####################################################################################

#####################################################################################
if [ -f "${kegg_data_dir}/ortholog_gene_mappings.gz" ]                              #
then                                                                                #
	mv ${kegg_data_dir}/ortholog_gene_mappings.gz ${kegg_data_dir}/backup_${cur_date} #
fi                                                                                  #
#####################################################################################

############################################################################
mv ${kegg_tmp_dir}/org_list.gz ${kegg_data_dir} 2>> $log_file              #
mv ${kegg_tmp_dir}/ortholog_list.gz ${kegg_data_dir} 2>> $log_file         #
mv ${kegg_tmp_dir}/pathway_list.gz ${kegg_data_dir} 2>> $log_file          #
mv ${kegg_tmp_dir}/gene_pathway_mappings.gz ${kegg_data_dir} 2>> $log_file #
mv ${kegg_tmp_dir}/ortholog_gene_mappings ${kegg_data_dir} 2>> $log_file   #
############################################################################
