#!/bin/bash
bam_file="$1"
bed_file="$2"

samtools_test=$(which samtools 2> /dev/null)
if [ -z "$samtools_test" ]
then
    echo "Error: samtools not found in PATH"
    exit 1
fi

cut -f4 $bed_file | sort | uniq | grep -v ^$ | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "get_avg_depth.sh" , bam_file , bed_file , $1 }' | parallel -j 16
