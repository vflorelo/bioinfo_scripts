#!/bin/bash
function usage(){
    echo "Options (all arguments are mandatory):"
    echo "  --blast_file        -> File containing blast hits in tabular format"
    echo "                         -outfmt '6 qseqid sseqid qlen slen qstart sstart qend send score evalue length positive'"
    echo "  --seq_len_threshold -> Float. Fraction of the longest sequence represented by the shortest sequence"
    echo "  --rep_len_threshold -> Integer. Tolerance to repetitive sequences, smaller than 50"
    echo "  --aln_len_threshold -> Float. Fraction of the shortes sequence represented by the alignment"
    echo "  --out_file          -> File containing filtered blast hits in tabular format"
    echo "Examples:"
    echo "  blast_filter.sh --blast_file blast_hits.tsv --seq_len_threshold 0.8 --rep_len_threshold 50 --aln_len_threshold 0.5 --out_file clean_blast_hits.tsv"
	}
export -f usage
while [ "$1" != "" ]
do
  case $1 in
    --blast_file        )
      shift
      blast_file=$(realpath $1)
      ;;
    --seq_len_threshold )
      # float
      shift
      seq_len_threshold=$1
      ;;
    --rep_len_threshold )
      # int
      shift
      rep_len_threshold=$1
      ;;
    --aln_len_threshold )
      #float
      shift
      aln_len_threshold=$1
      ;;
    --out_file          )
      shift
      out_file=$1
      ;;
    --help )
      usage
      exit 0
      ;;
	esac
	shift
done
if [ -z "${blast_file}" ]
then
  echo "No BLAST file specified, aborting"
  exit 1
else
  if [ ! -f "${blast_file}" ]
  then
    echo "BLAST file ${blast_file} missing, aborting"
    exit 0
  fi
fi
if [ -z "${seq_len_threshold}" ]
then
  echo "Missing sequence length threshold, aborting"
  exit 1
else
  float_test=$(echo "${seq_len_threshold}" | awk '{if($1>=0 && $1<=1){print "pass"}else{print "fail"}}')
  if [ "${float_test}" == "fail" ]
  then
    echo "Invalid sequence length threshold, aborting"
    exit 1
  fi
fi
if [ -z "${rep_len_threshold}" ]
then
  echo "Missing repeat length threshold, aborting"
  exit 1
else
  int_test=$(echo "${rep_len_threshold}" | awk '{if(int($1)==$1){print "pass"}else{print "fail"}}')
  if [ "${int_test}" == "fail" ]
  then
    echo "Invalid repeat length threshold, aborting"
    exit 1
  fi
fi
if [ -z "${aln_len_threshold}" ]
then
  echo "Missing alignment length threshold, aborting"
  exit 1
else
  float_test=$(echo "${aln_len_threshold}" | awk '{if($1>=0 && $1<=1){print "pass"}else{print "fail"}}')
  if [ "${float_test}" == "fail" ]
  then
    echo "Invalid alignment length threshold, aborting"
    exit 1
  fi
fi
if [ -z "${out_file}" ]
then
  echo "No output file specified, aborting"
  exit 1
fi
cat "${blast_file}" | awk '{if($3>$4){print $AF"\t"$4/$3}else{print $AF"\t"$3/$4}}' | awk -v cutoff="${seq_len_threshold}" '{if($13>cutoff){print $AF}}' | cut -f1-12 > seq_accepted_hits
query_list=$(cut -f1 seq_accepted_hits | sort -V | uniq | grep -v ^$)
for i in ${query_list}
do
  query_block=$(grep -w ${i} seq_accepted_hits)
  subject_list=$(echo "${query_block}" | cut -f2 | sort -V | uniq  | grep -v ^$)
  for j in ${subject_list}
  do
    data_block=$(echo "${query_block}" | grep -w $i | grep -w $j)
    line_no=$(echo "${data_block}" | wc -l)
    if [ "${line_no}" -eq 1 ]
    then
      echo "${data_block}" | awk '{if($3>=$4){print $AF"\t"$11/$4}else{print $AF"\t"$11/$3}}' | awk -v cutoff="${aln_len_threshold}" '{if($13>=cutoff){print $AF}}' | cut -f1-12 >> aln_accepted_hits
    else
      q_intervals=$(echo "${data_block}" | cut -f3,5,7 | awk -v cutoff="${rep_len_threshold}" '{if($2-cutoff <0){print $1,"0",$3}else{print $1,$2-cutoff,$3}}' | awk -v cutoff="${rep_len_threshold}" '{if($3+cutoff>$1){print $2,$1}else{print $2,$3+cutoff}}')
      s_intervals=$(echo "${data_block}" | cut -f4,6,8 | awk -v cutoff="${rep_len_threshold}" '{if($2-cutoff <0){print $1,"0",$3}else{print $1,$2-cutoff,$3}}' | awk -v cutoff="${rep_len_threshold}" '{if($3+cutoff>$1){print $2,$1}else{print $2,$3+cutoff}}')
      q_coords=$(echo "${data_block}" | cut -f5,7 | perl -pe 's/\t/\@/g')
      s_coords=$(echo "${data_block}" | cut -f6,8 | perl -pe 's/\t/\@/g')
      for k in ${q_coords}
      do
        start_pos=$(echo "${k}" | cut -d\@ -f1)
        end_pos=$(echo   "${k}" | cut -d\@ -f2)
        echo "${q_intervals}" | awk -v start_pos="${start_pos}" -v end_pos="${end_pos}" '{print $1,start_pos,end_pos,$2}' | awk '{if($2>=$1){print $AF,1}else{print $AF,0}}' | awk '{if($3<=$4){print $AF,1}else{print $AF,0}}' | awk '{if($5==1 && $6==1){print "include"}}' | grep -c "include" | awk '{print $1}' | awk '{if($1>=2){print "repeat"}}' >> q_rep_log
      done
      for l in ${s_coords}
      do
        start_pos=$(echo "${l}" | cut -d\@ -f1)
        end_pos=$(echo   "${l}" | cut -d\@ -f2)
        echo "${s_intervals}" | awk -v start_pos="${start_pos}" -v end_pos="${end_pos}" '{print $1,start_pos,end_pos,$2}' | awk '{if($2>=$1){print $AF,1}else{print $AF,0}}' | awk '{if($3<=$4){print $AF,1}else{print $AF,0}}' | awk '{if($5==1 && $6==1){print "include"}}' | grep -c "include" | awk '{print $1}' | awk '{if($1>=2){print "repeat"}}' >> s_rep_log
      done
      rep_test=$(grep repeat q_rep_log s_rep_log)
      rm -rf s_rep_log q_rep_log
      if [ -z "${rep_test}" ]
      then
        echo "${data_block}" | awk '{sum+=$11}END{if($3>=$4){print $AF"\t"sum/$4}else{print $AF"\t"sum/$3}}' | awk -v cutoff="${aln_len_threshold}" '{if($13>=cutoff){print $AF}}' | cut -f1-12 >> aln_accepted_hits
      fi
    fi
  done
done
mv aln_accepted_hits "${out_file}"