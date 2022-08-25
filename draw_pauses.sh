#!/bin/bash
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<svg xmlns:dc=\"http://purl.org/dc/elements/1.1/\" 
     xmlns:cc=\"http://creativecommons.org/ns#\"
     xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
     xmlns:svg=\"http://www.w3.org/2000/svg\"
     xmlns=\"http://www.w3.org/2000/svg\"
     id=\"svg8\"
     version=\"1.1\"
     viewBox=\"0 0 2500 400\"
     height=\"400px\"
     width=\"2500px\">
  <metadata id=\"metadata5\">
    <rdf:RDF>
      <cc:Work rdf:about=\"\">
        <dc:format>image/svg+xml</dc:format>
        <dc:type rdf:resource=\"http://purl.org/dc/dcmitype/StillImage\" />
        <dc:title comment=\"set graph title here\"></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>"
gene_list=`cat gene_list`
covstats_file=$1
for gene in $gene_list
do
  gene_datablock=`grep ^$gene"_" $covstats_file`
  avg_depth=`echo "$gene_datablock" | grep norare | cut -f6`
  codon_list="arg2 arg4 gly1 lys1 lys2 pro1 tyr1 tyr2"
  for codon in $codon_list
  do
    case "$codon" in
      "arg2")
        rgb_val="#FF0080"
        y_pos=25
        ;;
      "arg4")
        rgb_val="#FF00FF"
        y_pos=75
        ;;
      "gly1")
        rgb_val="#FF8000"
        y_pos=125
        ;;
      "lys1")
        rgb_val="#0080FF"
        y_pos=175
        ;;
      "lys2")
        rgb_val="#00FFFF"
        y_pos=225
        ;;
      "pro1")
        rgb_val="#FFFF00"
        y_pos=275
        ;;
      "tyr1")
        rgb_val="#00FF80"
        y_pos=325
        ;;
      "tyr2")
        rgb_val="#80FF00"
        y_pos=375
        ;;
    esac
    pause_datablock=`echo "$gene_datablock" | grep $codon`
    pos_list=`echo "$pause_datablock" | cut -f1 | cut -d_ -f3 | sort -n | uniq | grep -v ^$`
    for position in $pos_list
    do
      pause_str=`echo "$gene""_$codon""_$position"`
      max_depth=`echo "$pause_datablock" | grep -w "$pause_str" | cut -f4`
      fold_ratio=`echo -e "$max_depth\t$avg_depth" | awk 'BEGIN{FS="\t"}{print log($1/$2)/log(2)}'`
      echo "  <ellipse ry=\"$fold_ratio\"
                       rx=\"$fold_ratio\"
                       cy=\"$y_pos\"
                       cx=\"$position\"
                       id=\"$gene""_$codon""_$position\"
                       style=\"opacity:1;fill:$rgb_val;fill-opacity:1;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1\">
                <title>$gene</title>
              </ellipse>"
    done
  done
done
echo "</svg>"
