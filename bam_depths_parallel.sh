#!/bin/bash
bam_file="$1"
bed_file="$2"
echo -e "exon\tdepths"
cut -f4 $bed_file | sort | uniq | grep -v ^$ | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "bam_depths.sh" , bam_file , bed_file , $1 , "parallel" }' | parallel -j 16
