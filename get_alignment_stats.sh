#!/bin/bash
#ctg1	10410838	2356980	2664765	-	5	26975502	24328215	24635664	291975	308430	60
#ctg1	10410838	1444116	1719694	-	5	26975502	25268216	25542878	250571	276620	60
#query	qlen		qstart	qend	strand	subj	slen		sstart		send		match	aln_len	aln_q
# $1	 $2		  $3	 $4	  $5	 $6	 $7		 $8		 $9		 $10	  $11	$12
query="$1"
alignment_file="$2"
query_datablock=`awk -v query="$query" 'BEGIN{FS="\t"}{if($1==query){print $AF}}' "$alignment_file" | cut -f1-12`
query_length=`echo "$query_datablock" | head -n1 | cut -f2`
subject_list=`echo "$query_datablock" | cut -f6 | sort -V | uniq`
longest_alignment_subject=`echo "$query_datablock" | sort -nrk11 | head -n1 | cut -f6`
for subject in $subject_list
do
  if [ "$subject" == "$longest_alignment_subject" ]
  then
    subject_verdict="correct"
  else
    subject_verdict="incorrect"
  fi
  subject_datablock=`echo "$query_datablock" | awk -v subject="$subject" 'BEGIN{FS="\t"}{if($6==subject){print $AF}}'`
  longest_alignment_data=`echo "$subject_datablock" | sort -nrk11 | head -n1`
  longest_alignment_strand=`echo "$longest_alignment_data" | cut -f5`
  subject_upper_limit=`echo -e "$longest_alignment_data" | awk '{print ($8 - ($2-$3))+1+($2*0.05)}'`
  subject_lower_limit=`echo -e "$longest_alignment_data" | awk '{print ($9 + ($2-$4)) + ($2*0.05)}'`
  num_alignments=`echo "$subject_datablock" | wc -l`
  accepted_stats_str=""
  rejected_stats_str=""
  alignment_verdict=`echo "$subject_datablock" | awk -v longest_alignment_strand="$longest_alignment_strand" -v subject_upper_limit="$subject_upper_limit" -v subject_lower_limit="$subject_lower_limit" 'BEGIN{FS="\t"}{if($9<=subject_lower_limit && $8>=subject_upper_limit && $5==longest_alignment_strand){print $AF FS "accepted"}else{print $AF FS "rejected"}}'`
  num_accepted_alignments=`echo "$alignment_verdict" | grep -wc accepted$`
  num_rejected_alignments=`echo "$alignment_verdict" | grep -wc rejected$`
  accepted_alignments_datablock=`echo "$alignment_verdict" | grep -w accepted$`
  rejected_alignments_datablock=`echo "$alignment_verdict" | grep -w rejected$`
  for alignment_num in `seq 1 $num_accepted_alignments`
  do
    alignment_datablock=`echo "$accepted_alignments_datablock" | tail -n+$alignment_num | head -n1`
    num_matches=`echo "$alignment_datablock" | cut -f10`
    query_coverage=`echo "$alignment_datablock" | awk 'BEGIN{FS="\t"}{print ($4-$3)+1}'`
    subject_coverage=`echo "$alignment_datablock" | awk 'BEGIN{FS="\t"}{print ($9-$8)+1}'`
    alignment_stats=`echo -e "$query\t$subject\t$query_coverage\t$subject_coverage\t$num_matches" | awk -v subject_verdict="$subject_verdict" 'BEGIN{FS="\t"}{print $AF FS ($5/$3)*100 FS ($5/$4)*100 FS subject_verdict FS "accepted"}'`
    accepted_stats_str=`echo -e "$accepted_stats_str\n$alignment_stats"`
    unset alignment_datablock num_matches query_coverage subject_coverage alignment_stats
  done
  for alignment_num in `seq 1 $num_rejected_alignments`
  do
    alignment_datablock=`echo "$rejected_alignments_datablock" | tail -n+$alignment_num | head -n1`
    num_matches=`echo "$alignment_datablock" | cut -f10`
    query_coverage=`echo "$alignment_datablock" | awk 'BEGIN{FS="\t"}{print ($4-$3)+1}'`
    subject_coverage=`echo "$alignment_datablock" | awk 'BEGIN{FS="\t"}{print ($9-$8)+1}'`
    alignment_stats=`echo -e "$query\t$subject\t$query_coverage\t$subject_coverage\t$num_matches" | awk -v subject_verdict="$subject_verdict" 'BEGIN{FS="\t"}{print $AF FS ($5/$3)*100 FS ($5/$4)*100 FS subject_verdict FS "rejected"}'`
    rejected_stats_str=`echo -e "$rejected_stats_str\n$alignment_stats"`
    unset alignment_datablock num_matches query_coverage subject_coverage alignment_stats
  done
done
echo "$accepted_stats_str"  | grep "correct" | grep "accepted" | awk -v query_length="$query_length" -v query="$query" -v alignment_file="$alignment_file" 'BEGIN{FS="\t"}{cov_sum+=$3;match_sum+=$5}END{print alignment_file FS query FS query_length FS (cov_sum/query_length)*100 FS (match_sum/query_length*100)}'

















