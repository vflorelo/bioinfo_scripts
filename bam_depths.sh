#!/bin/bash
bam_file=$1
bed_file=$2
gene_str=$3
if [ ! -f "${bam_file}" ]
then
  echo "Missing bam file, exiting"
  exit 1
fi
bam_base_name=$(echo "${bam_file}" | perl -pe 's/\.bam.*//')
if [ ! -f "${bam_file}.bai" ] && [ ! -f "${bam_base_name}.bai" ]
then
  echo "bam file not indexed, exiting"
  exit 2
fi
if [ ! -f "${bed_file}" ]
then
  echo "Missing bed file, exiting"
  exit 3
fi
if [ -z "$gene_str" ]
then
  gene_list=$(cut -f4 $bed_file | grep -v ^$ | sort -V | uniq )
else
  gene_list=$gene_str
fi
for gene in $gene_list
do
  gene_datablock=$(awk -v gene="$gene" 'BEGIN{FS="\t"}{if($4==gene){print $0}}' $bed_file)
  chrom_list=$(echo "$gene_datablock" | cut -f1 | sort -V | uniq | grep -v ^$)
  for chrom in $chrom_list
  do
    gene_chrom_datablock=$(echo "$gene_datablock" | awk -v chrom="$chrom" 'BEGIN{FS="\t"}{if($1==chrom){print $AF}}' | sort -nk2 | uniq)
    num_intervals=$(echo "$gene_chrom_datablock" | wc -l)
    depth_datablock=""
    for interval_num in $(seq 1 $num_intervals)
    do
      interval=$(echo "$gene_chrom_datablock" | tail -n+$interval_num | head -n1 | awk 'BEGIN{FS="\t"}{print $1":"$2+1"-"$3}')
      interval_datablock=$(samtools depth -aa -r $interval $bam_file)
      depth_datablock=$(echo -e "$depth_datablock\n$interval_datablock" | grep -v ^$)
      unset interval
    done
    depth_array=$(echo "$depth_datablock" | sort -nk2 | uniq | cut -f3 | perl -pe 's/\n/\,/g' | perl -pe 's/\,$//')
    echo -e "$gene\t$depth_array"
  done
done
