#!/bin/bash
datablock=$(cat "$1")
prot="$2"
run_mode="$3"
outfile="${prot}_${run_mode}_variants.svg"
prot_datablock=$(echo "$datablock" | awk -v prot="$prot" 'BEGIN{FS="\t"}{if($1==prot){print $0}}')
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" >> "$outfile"
echo "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"19000px\" height=\"200\" viewBox=\"0 0 19000 200\" id=\"variants\">"  >> "$outfile"
gag_wt_str="MGARASVLSGGELDRWEKIRLRPGGKKKYKLKHIVWASRELERFAVNPGLLETSEGCRQILGQLQPSLQTGSEELRSLYNTVATLYCVHQRIEIKDTKEALDKIEEEQNKSKKKAQQAAADTGHSNQVSQNYPIVQNIQGQMVHQAISPRTLNAWVKVVEEKAFSPEVIPMFSALSEGATPQDLNTMLNTVGGHQAAMQMLKETINEEAAEWDRVHPVHAGPIAPGQMREPRGSDIAGTTSTLQEQIGWMTNNPPIPVGEIYKRWIILGLNKIVRMYSPTSILDIRQGPKEPFRDYVDRFYKTLRAEQASQEVKNWMTETLLVQNANPDCKTILKALGPAATLEEMMTACQGVGGPGHKARVLAEAMSQVTNSATIMMQRGNFRNQRKIVKCFNCGKEGHTARNCRAPRKKGCWKCGKEGHQMKDCTERQANFLGKIWPSYKGRPGNFLQSRPEPTAPPEESFRSGVETTTPPQKQEPIDKELYPLTSLRSLFGNDPSSQ"
pol_wt_str="PQVTLWQRPLVTIKIGGQLKEALLDTGADDTVLEEMSLPGRWKPKMIGGIGGFIKVRQYDQILIEICGHKAIGTVLVGPTPVNIIGRNLLTQIGCTLNF"
gag_length="500"
pol_length="99"
if [ "$prot" == "GAG" ]
then
  pos_list=$(seq 1 $gag_length)
  wt_list=$(echo "$gag_wt_str" | sed 's/.\{1\}/&\n/g')
elif [ "$prot" == "POL" ]
then
  pos_list=$(seq 1 $pol_length)
  wt_list=$(echo "$pol_wt_str" | sed 's/.\{1\}/&\n/g')
fi
for pos in $pos_list
do
  wt_res=$(echo "$wt_list" | tail -n+$pos | head -n1)
  text_style=$(echo "font-family=\"Source Code Pro\" font-size=\"10\" fill=\"#000000\" font-style=\"normal\" ")
  if [ "$run_mode" == "individuals" ]
  then
    pos_preload=$(echo "$pos" | awk '{print ($1-1)*20}')
  elif [ "$run_mode" == "frequencies" ]
  then
    pos_preload=$(echo "$pos" | awk '{print ($1-1)*35}')
  fi
  echo "  <text $text_style id=\"WT"_"$pos\" y=\"0\" x=\"$pos_preload\">$wt_res</text>" >> "$outfile"
  freq_preload=$(echo "$pos_preload" | awk '{print $1+7}')
  pos_datablock=$(echo "$prot_datablock" | awk -v pos="$pos" 'BEGIN{FS="\t"}{if($2==pos){print $0}}')
  allele_list=$(echo "$pos_datablock" | sort -nrk5 | cut -f4)
  num_alleles=$(echo "$allele_list" | wc -l)
  text_preload="10"
  for allele_num in $(seq 1 $num_alleles)
  do
    allele=$(echo "$allele_list" | tail -n+$allele_num | head -n1)
    allele_num_str=$(echo "$pos_datablock" | awk -v allele="$allele" -v run_mode="$run_mode" 'BEGIN{FS="\t"}{if($4==allele && run_mode == "frequencies" ){print $5}else if($4==allele && run_mode == "individuals" ){print $6}}')
    text_style=$(echo "font-family=\"Source Code Pro\" font-size=\"10\" fill=\"#000000\" font-style=\"normal\" ")
    echo "  <text $text_style id=\"$prot"_"$pos"_"$allele\" y=\"$text_preload\" x=\"$pos_preload\">$allele</text>" >> "$outfile"
    text_style=$(echo "font-family=\"Source Code Pro\" font-size=\"6\"  fill=\"#000000\" font-style=\"normal\" ")
    echo "  <text $text_style id=\"$prot"_"$pos"_"$allele\" y=\"$text_preload\" x=\"$freq_preload\">$allele_num_str</text>" >> "$outfile"
    text_preload=$(echo $text_preload | awk '{print $1+10}')
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
