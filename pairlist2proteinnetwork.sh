#!/bin/bash
db_file=$1
filtered_blast_file=$2
cutoff=$3
list1=`cat $db_file | grep \> |  awk '{print $2}' | sort | uniq | grep -v ^$`
for i in $list1
do
  org1_name="$i"
  org1_prefix=`cat $db_file | grep -w $i | cut -d\. -f1 | cut -d\> -f2 | sort | uniq | grep -v ^$`
  org1_prot_size=`cat $db_file | grep -wc $org1_prefix`
  list2=`echo "$list1" | grep -wv $i`
  for j in $list2
  do
    org2_name=$j
    org2_prefix=`cat $db_file | grep -w $j | cut -d\. -f1 | cut -d\> -f2 | sort | uniq | grep -v ^$`
    org2_prot_size=`cat $db_file | grep -wc $org2_prefix`
    norm_size=`echo $org1_prot_size $org2_prot_size | awk '{if($1>$2){print $2}else{print $1}}'`
    cat $filtered_blast_file | grep $org1_prefix | grep $org2_prefix | awk '{print $1}' | sort | uniq > shared_pairs
    echo > repeated_proteins
    for k in `cat shared_pairs | cut -f1 | perl -pe 's/\@/\n/g' | sort | uniq`
    do
      grep -wc $k shared_pairs | awk -v prot_name="$k" '{if($1>1){print prot_name}}' >> repeated_proteins
    done
    cat shared_pairs | grep -wf repeated_proteins | sort | uniq > conflictive_pairs
    echo "`cat shared_pairs | grep -wvf conflictive_pairs`" > shared_pairs
    for l in `cat repeated_proteins`
    do
      selected_pair=`cat $filtered_blast_file | grep -w $l | awk '{print $9,$1}' | sort -g | head -n1 | awk '{print $2}'`
      grep -w $selected_pair conflictive_pairs >> shared_pairs
      echo "`cat conflictive_pairs | grep -wv $l`" > conflictive_pairs
    done
    percent_shared=`cat shared_pairs | wc -l | awk -v norm_size="$norm_size" '{print ($1/norm_size)*100}'`
    rm conflictive_pairs repeated_proteins shared_pairs
    echo $org1_name $percent_shared $org2_name | awk -v cutoff="$cutoff" '{if($2>=cutoff){print $AF}}' | awk '{if($2>=70){print $1"\trecent\t"$3"\t"$2}else if($2<=40){print $1"\tancestral\t"$3"\t"$2}else{print $1"\tmedium\t"$3"\t"$2}}' >> network.tsv
  done
  list1="$list2"
done
exit 0
