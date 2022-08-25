#!/bin/bash
#***	parse_gff	***#
gff_file=$1
gene_id=$2
gene_datablock=`grep -w "$gene_id" "$gff_file" | awk 'BEGIN{FS="\t"}{if($3=="gene"){print $AF}}'`
chrom_id=`echo "$gene_datablock" | cut -f1`
locus_tag=`echo "$gene_datablock" | cut -f9 | perl -pe 's/\;/\n/g' | awk 'BEGIN{FS="="}{if($1=="locus_tag"){print $2}}'`
cds_datablock=`grep -w "$locus_tag" "$gff_file" | awk 'BEGIN{FS="\t"}{if($3=="CDS"){print $AF}}'`
regions_datablock=`grep -w "$locus_tag" "$gff_file" | awk 'BEGIN{FS="\t"}{if($3=="biological_region"){print $AF}}'`
if [ -z "$cds_datablock" ] && [ ! -z "$regions_datablock" ]
then
  region_info=`echo "$regions_datablock" | cut -f9 | perl -pe 's/\;/\n/g'`
  region_id=`echo "$region_info" | awk 'BEGIN{FS="="}{if($1=="ID"){print $2}}'`
  region_strand=`echo "$region_datablock" | cut -f7`
  region_flags_datablock=`echo "$region_info" | awk 'BEGIN{FS="="}{if($1=="featflags"){print $2}}' | perl -pe 's/\,/\n/g'`
  region_type=`echo "$region_flags" | awk 'BEGIN{FS=":"}{if($1=="type"){print $2}}'`
  if [ "$region_type" == "CDS" ]
  then
    children_datablock=`awk -v region_id="$region_id" 'BEGIN{FS="\t"}{if($9=="Parent="region_id){print $AF}' "$gff_file"`
    region_product=`echo "$region_info" | awk 'BEGIN{FS="="}{if($1=="product"){print "\""$2"\""}}'`
    num_children=`echo "$children_datablock" | wc -l`
    for child_num in `seq 1 $num_children`
    do
      child_datablock=`echo "$children_datablock" | tail -n+$child_num | head -n1`
      child_start=`echo "$child_datablock" | cut -f4`
      child_end=`echo "$child_datablock" | cut -f5`
      echo -e "$chrom_id\t$child_start\t$child_end\t$locus_tag $region_product\t.\t$region_strand"
    done
  fi
elif [ ! -z "$cds_datablock" ] && [ -z "$regions_datablock" ]
then
  cds_start=`echo "$cds_datablock" | cut -f4`
  cds_end=`echo "$cds_datablock" | cut -f5`
  cds_strand=`echo "$cds_datablock" | cut -f7`
  cds_product=`echo "$cds_datablock" | cut -f9 | perl -pe 's/\;/\n/g' | awk 'BEGIN{FS="="}{if($1=="product"){print "\""$2"\""}}'`
  echo -e "$chrom_id\t$cds_start\t$cds_end\t$locus_tag $cds_product\t.\t$cds_strand"
fi
