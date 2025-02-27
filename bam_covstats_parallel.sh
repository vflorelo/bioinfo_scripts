#!/bin/bash
bam_file="$1"
bed_file="$2"
echo -e "Region\tTotal length\tSequenced length\tTotal coverage\tAverage Depth"
cut -f4 $bed_file | sort | uniq | grep -v ^$ | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "bam_covstats.sh" , bam_file , bed_file , $1 , "parallel" }' | parallel -j 8
