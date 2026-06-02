#!/bin/bash
module load samtools/1.11.18
bam_file="$1"
bed_file="$2"
cut -f4 $bed_file | sort | uniq | grep -v ^$ | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "get_avg_depth.sh" , bam_file , bed_file , $1 }' | parallel -j 16
