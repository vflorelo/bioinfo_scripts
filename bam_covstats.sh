#!/bin/bash

##########################################################################################
#  Parallel run:                                                                         #
##########################################################################################
#                                      +-----------------+                               #
#                +--- Gene 1 -------+  | bam_covstats.sh |                               #
#                |                  |  |                 |                               #
#                +--- Gene 2 -------+  | bam_covstats.sh |                               #
#                |                  |  |                 |  +-------------------------+  #
#  Dataset (bam)-+--- Gene 3 chr X -+--+ bam_covstats.sh +--+ Combined covstats table |  #
#                |                  |  |                 |  +-------------------------+  #
#                +--- Gene 3 chr Y -+  | bam_covstats.sh |                               #
#                |                  |  |                 |                               #
#                +--- Gene 4 -------+  | bam_covstats.sh |                               #
#                                      +-----------------+                               #
#                                      \__ GNU Parallel__/                               #
##########################################################################################
#  Main process                                                                          #
##########################################################################################
#                +--- region 1 ---+                                                      #
#                |                |                                                      #
#                +--- region 2 ---+                      +------------------+            #
#                |                |  +----------------+  | *average depth   |            #
#  Dataset (bam)-+--- region 3 ---+--+ samtools depth +--+                  |            #
#                |                |  +----------------+  | *depth intervals |            #
#                +--- region 4 ---+                      +------------------+            #
#                |                |                                                      #
#                +--- region 5 ---+                                                      #
##########################################################################################

##########
# Global #
#############
bam_file=$1 #
bed_file=$2 #
gene_str=$3 #
#############

####################################################
###  bed file format                             ###
###  https://genome.ucsc.edu/FAQ/FAQformat.html  ###
###                                              ###
###  1  1020172  1020372  AGRN  .      +         ###
###  ^  ^^^^^^   ^^^^^    ^^^^  ^      ^         ###
###  |  start    end      gene  score  strand    ###
###  |                                           ###
###  +---chromosome                              ###
####################################################

##########
# Checks #
##################################################################
if [ ! -f "${bam_file}" ]                                        #
then                                                             #
  echo "Missing bam file, exiting"                               #
  exit 1                                                         #
fi                                                               #
##################################################################
bam_base_name=$(echo "${bam_file}" | perl -pe 's/\.bam.*//')     #
if [ ! -f "${bam_file}.bai" ] && [ ! -f "${bam_base_name}.bai" ] #
then                                                             #
  echo "bam file not indexed, exiting"                           #
  exit 2                                                         #
fi                                                               #
##################################################################
if [ ! -f "${bed_file}" ]                                        #
then                                                             #
  echo "Missing bed file, exiting"                               #
  exit 3                                                         #
fi                                                               #
##################################################################
if [ -z "${gene_str}" ]                                          #
then                                                             #
  gene_list=$(cut -f4 ${bed_file} | grep -v ^$ | sort -V | uniq )#
else                                                             #
  gene_list="${gene_str}"                                        #
fi                                                               #
##################################################################

for gene in ${gene_list}
do
	gene_datablock=$(awk -v gene="${gene}" 'BEGIN{FS="\t"}{if($4==gene){print $0}}' ${bed_file})
	chrom_list=$(echo "${gene_datablock}" | cut -f1 | sort -V | uniq | grep -v ^$)
	for chrom in ${chrom_list}
	do
		gene_chrom_datablock=$(echo "${gene_datablock}" | awk -v chrom="${chrom}" 'BEGIN{FS="\t"}{if($1==chrom){print $AF}}' | sort -nk2 | uniq)
		num_intervals=$(echo "${gene_chrom_datablock}" | wc -l)
		coverage_datablock=""
		for interval_num in $(seq 1 ${num_intervals})
		do
			interval=$(echo "${gene_chrom_datablock}" | tail -n+${interval_num} | head -n1 | awk 'BEGIN{FS="\t"}{print $1":"$2+1"-"$3}')
			interval_datablock=$(samtools depth -aa -r ${interval} ${bam_file})
			coverage_datablock=$(echo -e "${coverage_datablock}\n${interval_datablock}" | grep -v ^$)
			unset interval
		done
		coverage_datablock=$(echo "${coverage_datablock}" | sort -nk2 | uniq)
		total_length=$(echo "${coverage_datablock}" | wc -l)
		avg_depth=$(echo    "${coverage_datablock}" | awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}')
		cv_length=$(echo    "${coverage_datablock}" | awk 'BEGIN{FS="\t"}{if($3>=1) {print $AF}}' | wc -l)
		echo -e "${gene}\t${total_length}\t${cv_length}\t${avg_depth}" | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,($3/$2)*100,$4}'
	done
done
