#!/bin/bash
module load samtools/1.11.18
bam_file="$1"
bed_file="$2"
threads="$3"
echo -e "Region\tTotal length\tSequenced length\tZero depth length\tAvg. Depth"
target_list=$(cut -f4 "${bed_file}" | sort -V | uniq | grep -v ^$)
echo "${target_list}" | awk -v bam_file="$bam_file" -v bed_file="$bed_file" '{print "bam_covstats.sh",bam_file,bed_file,$1}'| parallel -j ${threads} | sort -V --parallel=${threads} | uniq
