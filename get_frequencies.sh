#!/bin/bash
datablock=$(cat $1)
num_samples=$(echo "$datablock" | cut -f1 | sort -V | uniq | wc -l)
prot_list=$(echo -e "GAG\nPOL")
gag_wt="MGARASVLSGGELDRWEKIRLRPGGKKKYKLKHIVWASRELERFAVNPGLLETSEGCRQILGQLQPSLQTGSEELRSLYNTVATLYCVHQRIEIKDTKEALDKIEEEQNKSKKKAQQAAADTGHSNQVSQNYPIVQNIQGQMVHQAISPRTLNAWVKVVEEKAFSPEVIPMFSALSEGATPQDLNTMLNTVGGHQAAMQMLKETINEEAAEWDRVHPVHAGPIAPGQMREPRGSDIAGTTSTLQEQIGWMTNNPPIPVGEIYKRWIILGLNKIVRMYSPTSILDIRQGPKEPFRDYVDRFYKTLRAEQASQEVKNWMTETLLVQNANPDCKTILKALGPAATLEEMMTACQGVGGPGHKARVLAEAMSQVTNSATIMMQRGNFRNQRKIVKCFNCGKEGHTARNCRAPRKKGCWKCGKEGHQMKDCTERQANFLGKIWPSYKGRPGNFLQSRPEPTAPPEESFRSGVETTTPPQKQEPIDKELYPLTSLRSLFGNDPSSQ"
pol_wt="PQVTLWQRPLVTIKIGGQLKEALLDTGADDTVLEEMSLPGRWKPKMIGGIGGFIKVRQYDQILIEICGHKAIGTVLVGPTPVNIIGRNLLTQIGCTLNF"
for prot in $prot_list
do
  prot_datablock=$(echo "$datablock" | awk -v prot="$prot" 'BEGIN{FS="\t"}{if($2==prot){print $0}}')
  if [ "$prot" == "GAG" ]
  then
    res_list=$(echo "$gag_wt" | sed 's/.\{1\}/&\n/g')
  elif [ "$prot" == "POL" ]
  then
    res_list=$(echo "$pol_wt" | sed 's/.\{1\}/&\n/g')
  fi
  prot_length=$(echo "$res_list" | wc -l)
  for pos in $(seq 1 $prot_length)
  do
    ref_res=$(echo "$res_list" | tail -n+$pos | head -n1)
    pos_datablock=$(echo "$prot_datablock" | awk -v pos="$pos" 'BEGIN{FS="\t"}{if($3==pos){print $0}}')
    alt_res_list=$(echo "$pos_datablock" | cut -f5 | sort -V | uniq )
    for alt_res in $alt_res_list
    do
      alt_res_count=$(echo "$pos_datablock" | awk -v alt_res="$alt_res" 'BEGIN{FS="\t"}{if($5==alt_res){print $1}}' | sort -V | uniq | wc -l)
      alt_res_freq=$(echo -e "$alt_res_count\t$num_samples" | awk 'BEGIN{FS="\t"}{printf "%0.6f\n", $1/$2}')
      echo -e "$prot\t$pos\t$ref_res\t$alt_res\t$alt_res_freq\t$alt_res_count"
    done
  done
done
