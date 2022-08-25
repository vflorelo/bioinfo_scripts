#!/bin/bash
blast_file=$1
#Sequence length comparison test for excluding non-comparable sequences. Must be floating point number 0 -> 1
seq_len_threshold=$2
#Length tolerance for repeat test. Must be integer greater than 0, smaller than 50 (suggested)
rep_len_threshold=$3
#Alignment length coverage threshold for excluding local-similarity only hits. Must be floating point number 0 -> 1
aln_len_threshold=$4
### qseqid	sseqid	qlen	slen	qstart	sstart	qend	send	score	evalue	length	positive
### ^^^^^^	^^^^^^	^^^^	^^^^	^^^^^^	^^^^^^	^^^^	^^^^	^^^^^	^^^^^^	^^^^^^	^^^^^^^^
###   $1      $2     $3      $4       $5      $6     $7      $8       $9      $10     $11      $12

####End
####Removing non-comparable sequences and filtering partial/full duplicates
cat "$blast_file" | awk '{if($3>$4){print $AF"\t"$4/$3}else{print $AF"\t"$3/$4}}' | awk -v cutoff="$seq_len_threshold" '{if($13>cutoff){print $AF}}' | cut -f1-12 > seq_accepted_hits
query_list=`cat seq_accepted_hits | awk '{print $1}' | sort | uniq | grep -v ^$`
for i in $query_list
do
  query_block=`cat seq_accepted_hits | grep -w $i`
  subject_list=`echo "$query_block" | awk '{print $2}' | sort | uniq  | grep -v ^$`
  for j in $subject_list
  do
    data_block=`echo "$query_block" | grep -w $i | grep -w $j`
    line_no=`echo "$data_block" | wc -l`
    if [ "$line_no" -eq 1 ]
    then
      echo "$data_block" | awk '{if($3>=$4){print $AF"\t"$11/$4}else{print $AF"\t"$11/$3}}' | awk -v cutoff="$aln_len_threshold" '{if($13>=cutoff){print $AF}}' | cut -f1-12 >> aln_accepted_hits
    else
      #define intervals for query and subject sequences
      q_intervals=`echo "$data_block" | cut -f3,5,7 | awk -v cutoff="$rep_len_threshold" '{if($2-cutoff <0){print $1,"0",$3}else{print $1,$2-cutoff,$3}}' | awk -v cutoff="$rep_len_threshold" '{if($3+cutoff>$1){print $2,$1}else{print $2,$3+cutoff}}'`
      s_intervals=`echo "$data_block" | cut -f4,6,8 | awk -v cutoff="$rep_len_threshold" '{if($2-cutoff <0){print $1,"0",$3}else{print $1,$2-cutoff,$3}}' | awk -v cutoff="$rep_len_threshold" '{if($3+cutoff>$1){print $2,$1}else{print $2,$3+cutoff}}'`
      #see if query coordinates fall in more than two intervals
      q_coords=`echo "$data_block" | cut -f5,7 | perl -pe 's/\t/\@/g'`
      s_coords=`echo "$data_block" | cut -f6,8 | perl -pe 's/\t/\@/g'`
      for k in $q_coords
      do
        start_pos=`echo $k | cut -d\@ -f1`
        end_pos=`echo $k | cut -d\@ -f2`
        echo "$q_intervals" | awk -v start_pos="$start_pos" -v end_pos="$end_pos" '{print $1,start_pos,end_pos,$2}' | awk '{if($2>=$1){print $AF,1}else{print $AF,0}}' | awk '{if($3<=$4){print $AF,1}else{print $AF,0}}' | awk '{if($5==1 && $6==1){print "include"}}' | grep -c "include" | awk '{print $1}' | awk '{if($1>=2){print "repeat"}}' >> q_rep_log
      done
      for l in $s_coords
      do
        start_pos=`echo $l | cut -d\@ -f1`
        end_pos=`echo $l | cut -d\@ -f2`
        echo "$s_intervals" | awk -v start_pos="$start_pos" -v end_pos="$end_pos" '{print $1,start_pos,end_pos,$2}' | awk '{if($2>=$1){print $AF,1}else{print $AF,0}}' | awk '{if($3<=$4){print $AF,1}else{print $AF,0}}' | awk '{if($5==1 && $6==1){print "include"}}' | grep -c "include" | awk '{print $1}' | awk '{if($1>=2){print "repeat"}}' >> s_rep_log
      done
      #the actual repeat test
      rep_test=`grep repeat q_rep_log s_rep_log`
      rm -rf s_rep_log q_rep_log
      if [ -z "$rep_test" ]
      then
        echo "$data_block" | awk '{sum+=$11}END{if($3>=$4){print $AF"\t"sum/$4}else{print $AF"\t"sum/$3}}' | awk -v cutoff="$aln_len_threshold" '{if($13>=cutoff){print $AF}}' | cut -f1-12 >> aln_accepted_hits
      fi
    fi
  done
done
