#!/bin/bash
      seq_file="$1"
     info_file="$2"
    blast_file="$3"
seq_len_cutoff="$4"
aln_len_cutoff="$5"
dup_len_cutoff="$6"
   output_file="$7"
      log_file="get_dupes-`date +'%Y-%m-%d'`.log"
      err_file="get_dupes-`date +'%Y-%m-%d'`.err"
#makeblastdb -in "$seq_file" -title "$seq_file" -dbtype prot > "$log_file" 2> "$err_file"
#blastp -query "$seq_file" -db "$seq_file" -out "$blast_file" -outfmt "6 qseqid sseqid qlen slen qstart sstart qend send score evalue length positive" -evalue 0.0001
###########################################################################################################################
###	EES98230.1	EES98230.1	343	343	1	1	343	343	1843	0.0	343	343	###
###	^^^^^^^^^^	^^^^^^^^^^	^^^	^^^	^	^	^^^	^^^	^^^^	^^^	^^^	^^^	###
###	  qseqid	  sseqid	qlen	slen	qstart	sstart	qend	send	score	evalue	len	pos	###
###	   $1   	    $2  	$3	$4	$5	$6	$7	$8	$9	$10	$11	$12	###
###########################################################################################################################
awk 'BEGIN{FS="\t"}{if($1!=$2){print $AF}}' "$blast_file" | awk -v seq_len_cutoff="$seq_len_cutoff" 'BEGIN{FS="\t"}{     if($3>$4){seq_len_fraction=$4/$3}else if($4>$3){seq_len_fraction=$3/$4}else if($4==$3){seq_len_fraction=1}}{if(seq_len_fraction>=seq_len_cutoff){print $AF}}' > seq_accepted_hits
id_list=`awk 'BEGIN{FS="\t"}{print $1"\n"$2}' seq_accepted_hits | sort -V | uniq`
for id in $id_list
do
  id_list=`echo "$id_list" | grep -wv "$id"`
  for next_id in $id_list
  do
    echo -e "$id\t$next_id\tseq_accepted_hits\t$info_file\t$aln_len_cutoff\t$dup_len_cutoff"
  done
done > run_control_file
echo -e "q_seq_id\tduplicate_type\ts_seq_id\torientation\tdistance\tpair_score\tpair_evalue\tpair_matches\tq_seq_contig\tq_seq_location\tq_seq_product\ts_seq_contig\ts_seq_location\ts_seq_product" > "$output_file"
cat run_control_file | awk 'BEGIN{FS="\t"}{print "echo -e \""$AF"\" | parse_blast_data.sh"}' | parallel -j5 >> "$output_file"
