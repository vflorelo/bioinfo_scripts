#!/bin/bash
datablock=$(cat "$1")
prot="$2"
prot_datablock=$(echo "$datablock" | awk -v prot="$prot" 'BEGIN{FS="\t"}{if($1==prot){print $AF}}')
outfile="${prot}_histogram_variants.svg"
sample_list=$(echo "$datablock" | cut -f7 | sort -V | uniq)
num_samples=$(echo "$sample_list" | wc -l)
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" >> "$outfile"
echo "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"6400px\" height=\"5400\" viewBox=\"0 0 6400 5400\" id=\"variants\">"  >> "$outfile"
gag_length="500"
pol_length="99"
if [ "$prot" == "GAG" ]
then
	pos_list=$(seq 1 $gag_length)
elif [ "$prot" == "POL" ]
then
	pos_list=$(seq 1 $pol_length)
fi
for pos in $pos_list
do
  pos_preload=$(echo "$pos" | awk '{print ($1-1)*30}')
	block_preload="0"
  pos_datablock=$(echo "$prot_datablock" | awk -v pos="$pos" 'BEGIN{FS="\t"}{if($2==pos){print $AF}}')
  allele_list=$(echo "$pos_datablock" | sort -nrk5 | cut -f4)
  num_alleles=$(echo "$allele_list" | wc -l)
  for allele_num in $(seq 1 $num_alleles)
  do
    allele=$(echo "$allele_list" | tail -n+$allele_num | head -n1)
    allele_freq=$(echo "$pos_datablock" | awk -v allele="$allele" 'BEGIN{FS="\t"}{if($4==allele){print $5}}')
    block_height=$(echo "$allele_freq" | awk '{print $1*150}')
    case "$allele" in
      "A")
        rgb_val="#FF0000"
        ;;
      "C")
        rgb_val="#FF0080"
        ;;
      "D")
        rgb_val="#FF8000"
        ;;
      "E")
        rgb_val="#FF00A0"
        ;;
      "F")
        rgb_val="#FFA000"
        ;;
      "G")
        rgb_val="#FF0030"
        ;;
      "H")
        rgb_val="#FF3000"
        ;;
      "I")
        rgb_val="#00FF80"
        ;;
      "K")
        rgb_val="#80FF00"
        ;;
      "L")
        rgb_val="#00FFA0"
        ;;
      "M")
        rgb_val="#A0FF00"
        ;;
      "N")
        rgb_val="#00FF30"
        ;;
      "P")
        rgb_val="#30FF00"
        ;;
      "Q")
        rgb_val="#0000FF"
        ;;
      "R")
        rgb_val="#8000FF"
        ;;
      "S")
        rgb_val="#0080FF"
        ;;
      "T")
        rgb_val="#A000FF"
        ;;
      "V")
        rgb_val="#00A0FF"
        ;;
      "W")
        rgb_val="#3000FF"
        ;;
      "Y")
        rgb_val="#0030FF"
        ;;
    esac
    block_style=$(echo "style=\"opacity:1;fill:$rgb_val;fill-opacity:1;stroke:none;\"")
    echo "  <path d=\"m $pos_preload,$block_preload 10,0 0,-$block_height -10,0 z\" $block_style id=\"$prot"_"$sample"_"$pos"_"$allele""_block\" ></path>" >> "$outfile"
    block_preload=$(echo -e "$block_preload\t$block_height" | awk 'BEGIN{FS="\t"}{print $1-$2}')
  done
done
echo "</svg>" >> "$outfile"
svg_integrity=$(xmllint --noout "$outfile")
if [ -z "$svg_integrity" ]
then
  echo "success" | perl -pe 's/\n//g' 1>&2
elif [ ! -z "$svg_integrity" ]
then
  echo "fail" | perl -pe 's/\n//g' 1>&2
fi
exit 0
