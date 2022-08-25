#!/bin/bash
gb_file=$1
total_lines=`wc -l $gb_file`
acc_nos=(`grep -w LOCUS $gb_file | awk '{print $2}'`)
start_lines=(`grep -wn LOCUS $gb_file | cut -d\: -f1`)
end_lines=(`echo -e ${start_lines[@]} $total_lines | cut -d' ' -f1 --complement`)
genome_number=`grep -wc LOCUS $gb_file | awk '{print $1-1}'`
for i in `seq 0 $genome_number`
do
  acc_no=`echo ${acc_nos[$i]}`
  start_line=`echo ${start_lines[$i]}`
  num_lines=`echo ${end_lines[$i]} | awk -v start_line="$start_line" '{print $1 - start_line}'`
  tail -n+$start_line $gb_file | head -n$num_lines > $acc_no.gbk
done
