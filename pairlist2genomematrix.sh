#!/bin/bash
pair_list_file=$1
db_file=$2
cutoff=$3
genome_order_file=$4
unique_pairs=`cat $pair_list_file | awk '{print $1}' | sort | uniq`
midpoint1=`echo $cutoff | awk '{print ($1 + ((100 - $1)/3))}'`
midpoint2=`echo $cutoff | awk '{print ($1 + (2*((100 - $1)/3)))}'`
num_orgs=`cat $genome_order_file | wc -l`
org_list=`cat $genome_order_file`
echo "$org_list" | perl -pe 's/\n/\t/g' | awk '{print "\t"$AF}' > header
echo "$org_list" > base_table
for  i in `seq 1 $num_orgs`
do
  org_name=`echo "$org_list" | tail -n+$i | head -n1 `
  if [ "$i" == "$num_orgs" ]
  then
    touch $org_name.dat
  else
    sub_line=`echo "$i" | awk '{print $1+1}'`
    org_1_prefix=`cat "$db_file" | grep \> | awk -v org_name="$org_name" '{if($2==org_name){print $1}}' | cut -d\. -f1 | cut -d\> -f2 | sort | uniq | grep -v ^$ | head -n1`
    org_1_size=`cat "$db_file" | grep -wc $org_1_prefix`
    sub_list=`echo "$org_list" | tail -n+$sub_line`
    sub_num=`echo "$sub_list" | wc -l `
    bla=`seq 1 $sub_num`
    for j in $bla
    do
      sub_org_name=`echo "$sub_list" | tail -n+$j | head -n1`
      org_2_prefix=`cat $db_file | grep \> | awk -v sub_org_name="$sub_org_name" '{if($2==sub_org_name){print $1}}' | cut -d\. -f1 |  cut -d\> -f2 | sort | uniq | grep -v ^$ | head -n1`
      org_2_size=`cat $db_file | grep -wc $org_1_prefix`
      norm_size=`echo $org_1_size $org_2_size | awk '{if($2>$1){print $1}else{print $2}}'`
      echo "$unique_pairs" | grep $org_1_prefix | grep $org_2_prefix | sort | uniq > shared_pairs
      echo > repeated_proteins
      for k in `cat shared_pairs | perl -pe 's/\@/\n/g' | sort | uniq`
      do
        grep -wc $k shared_pairs | awk -v prot_name="$k" '{if($1>1){print prot_name}}' >> repeated_proteins
      done
      cat shared_pairs | grep -wf repeated_proteins | sort | uniq > conflictive_pairs
      for m in `cat conflictive_pairs`
      do
        echo "`cat shared_pairs | grep -wv \"$m\"`" > shared_pairs
      done
      for l in `cat repeated_proteins`
      do
        selected_pair=`cat $pair_list_file | grep -w $l | awk '{print $9,$1}' | sort -g | head -n1 | awk '{print $2}'`
        grep -w $selected_pair conflictive_pairs >> shared_pairs
        echo "`cat conflictive_pairs | grep -wv $l`" > conflictive_pairs
      done
      cat shared_pairs | wc -l | awk -v norm_size="$norm_size" '{print ($1/norm_size)*100}' | awk -v cutoff="$cutoff" '{if($1>cutoff){print $AF}else{print "x"}}'
      rm conflictive_pairs repeated_proteins shared_pairs
    done > $org_name.dat
  fi
  com_01="echo x:{1.."$i"} | perl -pe 's/\ /\n/g' | cut -d\: -f1"
  eval $com_01 > missing_lines
  echo "`cat missing_lines $org_name.dat`" > $org_name.dat
  echo "`paste base_table $org_name.dat`" > base_table
done
cat header base_table > genome_matrix.tsv
rm *.dat *base_table missing_lines header
