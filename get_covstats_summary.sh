#!/bin/bash
########################################################
###	Genos Médica Centro Especializado en Genética    ###
###	get_covstats_summary.sh: prints coverage summary ###
###	This script is intended for internal use only.   ###
########################################################

###################
###	Version 1.0 ###
###	2018-04-24  ###
###################

width=$(tput cols)
separator=$(printf '%0.s#' $(seq 1 $width))
covstats_block=$(perl -pe 's/\(/\t/g;s/\%\)//g' "$1" | tail -n+2)
total_cov=$(echo "$covstats_block" | awk 'BEGIN{FS="\t"}{seq_sum+=$3;cov_sum+=$4}END{print (cov_sum/seq_sum)*100}')
avg_cov=$(echo "$covstats_block"   | awk 'BEGIN{FS="\t"}{seq_sum+=$3;cov_sum+=($18*$3)}END{print cov_sum/seq_sum}')
high_cov=$(echo "$covstats_block"  | awk 'BEGIN{FS="\t"}{seq_sum+=$3;cov_sum+=$6}END{print (cov_sum/seq_sum)*100}')
echo -e "$separator\n###\tTotal coverage:\t$total_cov%\n###\tAvg depth:\t$avg_cov""X\n###\t>20X coverage:\t$high_cov%"
