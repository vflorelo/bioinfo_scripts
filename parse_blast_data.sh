#!/bin/bash
###################################################################################################################
          input=`cat`												###
          seq_1=`echo "$input" | cut -f1`									###
          seq_2=`echo "$input" | cut -f2`									###
     blast_file=`echo "$input" | cut -f3`									###
      info_file=`echo "$input" | cut -f4`									###
 aln_len_cutoff=`echo "$input" | cut -f5`									###
 dup_len_cutoff=`echo "$input" | cut -f6`									###
  tandem_cutoff="1000"												###
inverted_cutoff="1000"												###
      datablock=`grep -w "$seq_1" "$blast_file" | grep -w "$seq_2"`						###
       fwd_hits=`echo "$datablock" | awk -v seq_1="$seq_1" 'BEGIN{FS="\t"}{if($1==seq_1){print $AF}}' | wc -l`	###
       rev_hits=`echo "$datablock" | awk -v seq_2="$seq_2" 'BEGIN{FS="\t"}{if($1==seq_2){print $AF}}' | wc -l`	###
###################################################################################################################
if [ "$fwd_hits" -eq "0" ] || [ "$rev_hits" -eq "0" ]
then
  exit 0
else
  pair_1_eval=`echo "$datablock" | grep -w ^$seq_1 | awk 'BEGIN{FS="\t";cum_eval=1}{cum_eval*=$10}END{print cum_eval}'`
  pair_2_eval=`echo "$datablock" | grep -w ^$seq_2 | awk 'BEGIN{FS="\t";cum_eval=1}{cum_eval*=$10}END{print cum_eval}'`
  kept_data=`echo "$datablock"   | awk -v seq_1="$seq_1" -v seq_2="$seq_2" -v pair_1_eval="$pair_1_eval" -v pair_2_eval="$pair_2_eval" 'BEGIN{FS="\t"}{if(pair_1_eval<=pair_2_eval && $1==seq_1){print $AF}else if(pair_2_eval<pair_1_eval && $1==seq_2){print $AF FS "aln_"NR}}'`
  num_alignments=`echo "$kept_data" | wc -l`
  if [ "$num_alignments" -eq "1" ]
  then
    kept_data="$kept_data"
  elif [ "$num_alignments" -gt "1" ]
  then
    highest_l_aln=`echo "$kept_data" | awk 'BEGIN{FS="\t";max="";aln_id="";}{if(NR==1 || $11>max){max=$11;aln_id=$13}else{max=max;aln_id=aln_id}}END{print aln_id}'`
    lowest_e_aln=`echo "$kept_data"  | awk 'BEGIN{FS="\t";min="";aln_id="";}{if(NR==1 || $10<min){min=$10;aln_id=$13}else{min=min;aln_id=aln_id}}END{print aln_id}'`
    highest_s_aln=`echo "$kept_data" | awk 'BEGIN{FS="\t";max="";aln_id="";}{if(NR==1 || $9>max) {max=$9; aln_id=$13}else{max=max;aln_id=aln_id}}END{print aln_id}'`
    if [ "$highest_l_aln" == "$lowest_e_aln" ] && [ "$lowest_e_aln" == "$highest_s_aln" ]
    then
      base_alignment="$highest_l_aln"
    elif [ "$highest_l_aln" == "$lowest_e_aln" ] && [ "$lowest_e_aln" != "$highest_s_aln" ]
    then
      base_alignment="$lowest_e_aln"
    elif [ "$highest_s_aln" == "$lowest_e_aln" ] && [ "$lowest_e_aln" != "$highest_l_aln" ]
    then
      base_alignment="$lowest_e_aln"
    elif [ "$highest_s_aln" == "$highest_l_aln" ] && [ "$highest_l_aln" != "$lowest_e_aln" ]
    then
      base_alignment="$highest_s_aln"
    elif [ "$highest_s_aln" != "$highest_l_aln" ] && [ "$highest_l_aln" != "$lowest_e_aln" ]
    then
      base_alignment="$lowest_e_aln"
    fi
    test_alignments=`echo "$kept_data" | awk -v base_alignment="$base_alignment" 'BEGIN{FS="\t"}{if($13!=base_alignment){print $AF}}'`
    kept_data=`echo "$kept_data" | awk -v base_alignment="$base_alignment" 'BEGIN{FS="\t"}{if($13==base_alignment){print $AF}}'`
    num_test_alignments=`echo "$test_alignments" | wc -l`
    base_q_interval=`echo "$kept_data" | cut -f5,7`
    base_s_interval=`echo "$kept_data" | cut -f6,8`
    base_aln_stats=`echo  "$kept_data" | cut -f9-11`
    for test_alignment in `seq 1 $num_test_alignments`
    do
      test_aln_data=`echo "$test_alignments" | tail -n+$test_alignment | head -n1`
      test_q_interval=`echo "$test_aln_data" | cut -f5,7`
      test_s_interval=`echo "$test_aln_data" | cut -f6,8`
      test_aln_stats=`echo "$test_aln_data" | cut -f9-11`
      test_q_verdict=`echo -e "$base_q_interval\t$test_q_interval" | awk 'BEGIN{FS="\t"}{     if($3>$1  && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3<$1  && $3<$2  && $4>$1  && $4<$2) {print "exclude"}else if($3>$1  && $3==$2 && $4>$1  && $4>$2) {print "include"}else if($3<$1  && $3<$2  && $4==$1 && $4<$2) {print "include"}else if($3<$1  && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3>$1  && $3<$2  && $4>$1  && $4<$2) {print "exclude"}else if($3>$1  && $3>$2  && $4>$1  && $4>$2) {print "include"}else if($3<$1  && $3<$2  && $4<$1  && $4<$2) {print "include"}else if($3>$1  && $3<$2  && $4>$1  && $4==$2){print "exclude"}else if($3<$1  && $3<$2  && $4>$1  && $4==$2){print "exclude"}else if($3==$1 && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3==$1 && $3<$2  && $4>$1  && $4<$2) {print "exclude"}}'`
      test_s_verdict=`echo -e "$base_s_interval\t$test_s_interval" | awk 'BEGIN{FS="\t"}{     if($3>$1  && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3<$1  && $3<$2  && $4>$1  && $4<$2) {print "exclude"}else if($3>$1  && $3==$2 && $4>$1  && $4>$2) {print "include"}else if($3<$1  && $3<$2  && $4==$1 && $4<$2) {print "include"}else if($3<$1  && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3>$1  && $3<$2  && $4>$1  && $4<$2) {print "exclude"}else if($3>$1  && $3>$2  && $4>$1  && $4>$2) {print "include"}else if($3<$1  && $3<$2  && $4<$1  && $4<$2) {print "include"}else if($3>$1  && $3<$2  && $4>$1  && $4==$2){print "exclude"}else if($3<$1  && $3<$2  && $4>$1  && $4==$2){print "exclude"}else if($3==$1 && $3<$2  && $4>$1  && $4>$2) {print "exclude"}else if($3==$1 && $3<$2  && $4>$1  && $4<$2) {print "exclude"}}'`
      if [ "$test_q_verdict" == "include" ] && [ "$test_s_verdict" == "include" ]
      then
        kept_data=`echo -e "$kept_data\n$test_aln_data"`
      elif [ "$test_q_verdict" == "exclude" ] || [ "$test_s_verdict" == "exclude" ]
      then
        kept_data="$kept_data"
      fi
    done
  fi
  q_seq_id=`echo  "$kept_data" | cut -f1 | uniq | head -n1`
  s_seq_id=`echo  "$kept_data" | cut -f2 | uniq | head -n1`
  q_seq_len=`echo "$kept_data" | cut -f3 | uniq | head -n1`
  s_seq_len=`echo "$kept_data" | cut -f4 | uniq | head -n1`
  shortest_sequence_len=`echo -e "$q_seq_len\t$s_seq_len" | awk 'BEGIN{FS="\t"}{if($1>=$2){print $2}else{print $1}}'`
  longest_sequence_len=`echo -e "$q_seq_len\t$s_seq_len"  | awk 'BEGIN{FS="\t"}{if($1>=$2){print $1}else{print $2}}'`
  aln_len_verdict=`echo "$kept_data" | awk -v shortest_sequence_len="$shortest_sequence_len" -v aln_len_cutoff="$aln_len_cutoff" 'BEGIN{FS="\t"}{sum+=$11}END{if( (sum/shortest_sequence_len) >=aln_len_cutoff){print "include"}else{print "exclude"}}'`
  if [ "$aln_len_verdict" == "include" ]
  then
    q_info=`grep -w ^$q_seq_id $info_file | cut -f1 --complement`
    s_info=`grep -w ^$s_seq_id $info_file | cut -f1 --complement`
    q_contig=`echo "$q_info"  | cut -f1`
    s_contig=`echo "$s_info"  | cut -f1`
    q_coords=`echo "$q_info"  | cut -f2 | awk '{if($1~"complement"){print "-\t"$AF}else{print "+\t"$AF}}' | perl -pe 's/complement\(//g;s/\.\./\t/g;s/\)//'`
    s_coords=`echo "$s_info"  | cut -f2 | awk '{if($1~"complement"){print "-\t"$AF}else{print "+\t"$AF}}' | perl -pe 's/complement\(//g;s/\.\./\t/g;s/\)//'`
    q_product=`echo "$q_info" | cut -f3`
    s_product=`echo "$s_info" | cut -f3`
    dup_len_verdict=`echo -e "$shortest_sequence_len\t$longest_sequence_len" | awk -v dup_len_cutoff="$dup_len_cutoff" 'BEGIN{FS="\t"}{if($1/$2>=dup_len_cutoff){print "full"}else{print "partial"}}'`
    pair_cum_stats=`echo "$kept_data" | awk -v shortest_sequence_len="$shortest_sequence_len" 'BEGIN{FS="\t";e_val=1;score="";matches=""}{score+=$9;e_val*=$10;matches+=$12;}END{print score FS e_val FS ((matches/shortest_sequence_len)*100)}'`
    if [ "$q_contig" == "$s_contig" ]
    then
      dupe_type=`echo -e "$q_coords\t$s_coords" | awk -v tandem_cutoff="$tandem_cutoff" -v inverted_cutoff="$inverted_cutoff" 'BEGIN{FS="\t"}{
     if($1=="+" && $4=="+"){
       if($2>=$5){
         distal_start=$2;proximal_end=$6;
         }
       else{
         distal_start=$5;proximal_end=$3;
         }
       if (distal_start - proximal_end <= tandem_cutoff){
         dupe_type="tandem\tproximal";
         }
       else{
         dupe_type="tandem\tdistal";
         }
       }
else if($1=="-" && $4=="-"){
       if($2>=$5){
         distal_end=$2;proximal_start=$6;
         }
       else{
         distal_end=$5;proximal_start=$3;
         }
       if (distal_end - proximal_start <= tandem_cutoff){
         dupe_type="tandem\tproximal";
         }
       else{
         dupe_type="tandem\tdistal"
         }
       }
else if($1=="+" && $4=="-"){
       plus_start=$2;
       plus_end=$3;
       minus_start=$6;
       minus_end=$5;
       if( plus_start>=minus_start && plus_start - minus_start <= inverted_cutoff  ){
         dupe_type="divergent\tproximal"
         }
  else if( plus_start>=minus_start && plus_start - minus_start > inverted_cutoff  ){
         dupe_type="divergent\tdistal"
         }
  else if( plus_start<minus_start  && minus_end  - plus_end <= inverted_cutoff  ){
         dupe_type="convergent\tproximal"
         }
  else if( plus_start<minus_start  && minus_end  - plus_end  > inverted_cutoff  ){
         dupe_type="convergent\tdistal"
         }
       }
else if($1=="-" && $4=="+"){
       plus_start=$5;
       plus_end=$6;
       minus_start=$3;
       minus_end=$2;
       if( plus_start>=minus_start && plus_start - minus_start <= inverted_cutoff  ){
         dupe_type="divergent\tproximal"
         }
  else if( plus_start>=minus_start && plus_start - minus_start > inverted_cutoff  ){
         dupe_type="divergent\tdistal"
         }
  else if( plus_start<minus_start  && minus_end  - plus_end <= inverted_cutoff  ){
         dupe_type="convergent\tproximal"
         }
  else if( plus_start<minus_start  && minus_end  - plus_end  > inverted_cutoff  ){
         dupe_type="convergent\tdistal"
         }
       }
  }END{print dupe_type}
'`
    else
      dupe_type=`echo -e "N/A\tN/A" `
    fi
  echo -e "$q_seq_id\t$dup_len_verdict\t$s_seq_id\t$dupe_type\t$pair_cum_stats\t$q_info\t$s_info"
  else
    exit 0
  fi
fi
exit 0
