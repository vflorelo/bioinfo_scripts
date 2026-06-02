#!/bin/bash
bam_file="$1"
bed_file="$2"
threads="$3"
samtools_test=$(which samtools 2> /dev/null)
if [ -z "$samtools_test" ]
then
    echo "Error: samtools not found in PATH"
    exit 1
fi
echo -e "Region\tTotal length\tSequenced length\tZero depth length\tAvg. Depth"
target_list=$(cut -f4 "${bed_file}" | sort -V | uniq | grep -v ^$)
echo "${target_list}" | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "bam_covstats.sh",bam_file,bed_file,$1}'| parallel -j ${threads} | sort -V --parallel=${threads} | uniq
