#!/bin/bash
seq_db_file="$1"
seq_len_cutoff="$2" #int sequence coverage percent
aln_len_cutoff="$3" #int sequence coverage percent
genome_order_file="$4"
blast_file="$5"
if [ ! -f "${seq_db_file}" ]
then
	echo "No sequences loaded, exiting"
	exit 1
else
	if [ ! -f "${seq_db_file}.pin" ]
	then
		makeblastdb -in ${seq_db_file} -title ${seq_db_file} -dbtype prot
	fi
fi
if [ -f "${genome_order_file}" ]
then
	genome_order=$(cat ${genome_order_file})
elif [ ! -f "${genome_order_file}" ] && [ -f "genome_order" ]
then
	echo "Genome order file -> ${genome_order_file}: no such file or directory, using genome_order"
	genome_order=$(cat genome_order)
elif [ ! -f "${genome_order_file}" ] && [ ! -f "genome_order" ]
then
	echo "Genome order file -> ${genome_order_file}: no such file or directory"
	echo "Genome order file -> genome_order: no such file or directory, building genome order from ${seq_db_file} file"
	genome_order=$(grep \> ${seq_db_file} | awk '{print $2}' | sort -V | uniq | grep -v ^$ )
fi
if [ ! -f "${blast_file}" ]
then
	echo "BLAST file -> ${blast_file}: no such file or directory, building BLAST file from ${seq_db_file} file"
	blastp -query ${seq_db_file} -db ${seq_db_file} -evalue 0.0001 -out ${blast_file} -outfmt "6 qseqid sseqid qlen slen qstart sstart qend send score evalue length positive" -num_threads 12
fi
prot_size_list=$(perl -pe 'if(/\>/){s/$/\t/g};s/\n//g;s/\>/\n/g;s/\ .*\t/\t/g;' $seq_db_file | tail -n+2 | awk 'BEGIN{FS="\t"}{print $1 FS length($2)}')
num_genomes=$(echo "$genome_order" | wc -l)
#qseqid   -> $1
#sseqid   -> $2
#qlen     -> $3
#slen     -> $4
#qstart   -> $5
#sstart   -> $6
#qend     -> $7
#send     -> $8
#score    -> $9
#evalue   -> $10
#length   -> $11
#positive -> $12
global_datablock=""
for i in $(seq 1 $num_genomes)
do
	if [ "$i" -lt "$num_genomes" ]
	then
		subject_prefix_list=""
		subject=$(echo "$genome_order" | tail -n+$i | head -n1 )
		sub_genome_order=$(echo "$genome_order" | tail -n+$i | tail -n+2)
		subject_prefix_list=$(grep \> ${seq_db_file} | awk -v subject="$subject" '{if($2==subject){print $1}}' | perl -pe 's/\>//')
		num_sub_genomes=$(echo "$sub_genome_order" | wc -l)
		for j in $(seq 1 $num_sub_genomes)
		do
			query_prefix_list=""
			query=$(echo "$sub_genome_order" | tail -n+$j | head -n1)
			query_prefix_list=$(grep \> ${seq_db_file} | awk -v query="$query" '{if($2==query){print $1}}' | perl -pe 's/\>//')
			kept_hits=$(grep -wFf <(echo "$query_prefix_list") "${blast_file}" | grep -wFf <(echo "${subject_prefix_list}") | awk -v seq_len_cutoff="$seq_len_cutoff" 'BEGIN{FS="\t"}{if($3>=$4){slen_frac=(($4/$3)*100)}else{slen_frac=(($3/$4)*100)}}{if($1!=$2 && slen_frac >= seq_len_cutoff){print $AF}}' | sort -V | uniq )
			kept_query_prefix_list=$(echo   "$kept_hits" | cut -f1,2 | perl -pe 's/\t/\n/g' | sort -V | uniq | grep -wFf <(echo "$query_prefix_list"))
			cur_pair_list=""
			for kept_query_prefix in $kept_query_prefix_list
			do
				kept_subject_prefix_list=$(echo "$kept_hits" | grep -w "$kept_query_prefix" | cut -f1,2 | perl -pe 's/\t/\n/g' | sort -V | uniq | grep -wFf <(echo "$subject_prefix_list"))
				for kept_subject_prefix in $kept_subject_prefix_list
				do
					direct_pairs=$(echo "$kept_hits"  | awk -v subject_prefix="$kept_subject_prefix" -v query_prefix="$kept_query_prefix" 'BEGIN{FS="\t"}{if($1==query_prefix && $2==subject_prefix){print $AF}}')
					reverse_pairs=$(echo "$kept_hits" | awk -v subject_prefix="$kept_subject_prefix" -v query_prefix="$kept_query_prefix" 'BEGIN{FS="\t"}{if($2==query_prefix && $1==subject_prefix){print $AF}}')
					direct_pair_count=$(echo "$direct_pairs"   | grep -vc ^$)
					reverse_pair_count=$(echo "$reverse_pairs" | grep -vc ^$)
					if [ "$direct_pair_count" -gt 0 ] && [ "$reverse_pair_count" -gt 0 ] && [ "$direct_pair_count" -eq "$reverse_pair_count" ]
					then
						direct_pair_length=$(echo "$direct_pairs"   | awk '{sum+=$11}END{print sum}')
						reverse_pair_length=$(echo "$reverse_pairs" | awk '{sum+=$11}END{print sum}')
						if [ "$direct_pair_length" -ge "$reverse_pair_length" ]
						then
							selected_pairs=$(echo "$direct_pairs"  | awk -v aln_len_cutoff="$aln_len_cutoff" -v direct_pair_length="$direct_pair_length"   'BEGIN{FS="\t"}{if( ($3>=$4) && (((direct_pair_length/$4)*100)  >= aln_len_cutoff) ){print $AF}else if(($4>$3) && (((direct_pair_length/$3)*100)  >= aln_len_cutoff)) {print $AF}}')
						else
							selected_pairs=$(echo "$reverse_pairs" | awk -v aln_len_cutoff="$aln_len_cutoff" -v reverse_pair_length="$reverse_pair_length" 'BEGIN{FS="\t"}{if( ($3>=$4) && (((reverse_pair_length/$4)*100) >= aln_len_cutoff) ){print $AF}else if(($4>$3) && (((reverse_pair_length/$3)*100) >= aln_len_cutoff)) {print $AF}}')
						fi
						cur_pair_list=$(echo -e "$cur_pair_list\n$selected_pairs" | grep -v ^$)
					fi
					unset selected_pairs
					unset direct_pairs  direct_pair_count  direct_pair_length
					unset reverse_pairs reverse_pair_count reverse_pair_length
				done
			done
			uniq_pair_list=$(echo "$cur_pair_list" | cut -f1,2 | sort | uniq)
			combined_prefix_list=$(echo "$uniq_pair_list" | awk 'BEGIN{FS="\t"}{print $1"\n"$2}' | sort -V | uniq)
			repeat_prefix_list=""
			for prefix in $combined_prefix_list
			do
				num_combined_hits=$(echo "$uniq_pair_list" | grep -wc "$prefix")
				if [ "$num_combined_hits" -gt 1 ]
				then
					repeat_prefix_list=$(echo "$repeat_prefix_list\n$prefix" | grep -v ^$)
				fi
			done
			filtered_pair_list=$(echo "$cur_pair_list" | grep -wv "$repeat_prefix_list")
			repeat_pair_list=$(echo   "$cur_pair_list" | grep -w  "$repeat_prefix_list")
			sub_repeat_prefix_list="$repeat_prefix_list"
			for rep_prefix in $repeat_prefix_list
			do
				rep_prefix_aln_length=""
				sub_repeat_prefix_list=$(echo "$sub_repeat_prefix_list" | grep -wv "$rep_prefix")
				for sub_rep_prefix in $sub_repeat_prefix_list
				do
					sub_rep_prefix_aln_length=$(echo "$repeat_pair_list" | grep -w $rep_prefix | grep -w $sub_rep_prefix | awk -v sub_rep_prefix="$sub_rep_prefix" 'BEGIN{FS="\t"}{sum+=$11}END{print sub_rep_prefix FS sum}')
					rep_prefix_aln_length=$(echo -e "$rep_prefix_aln_length\n$sub_rep_prefix_aln_length" | grep -v ^$)
				done
				selected_sub_prefix=$(echo "$rep_prefix_aln_length" | sort -nrk2 | uniq | head -n1 | cut -f1)
				selected_sub_prefix_pair=$(echo "$repeat_pair_list" | grep -w "$rep_prefix" | grep -w "$selected_sub_prefix")
				filtered_pair_list=$(echo -e "$filtered_pair_list\n$selected_sub_prefix_pair" | grep -v ^$)
				repeat_pair_list=$(echo "$repeat_pair_list" | grep -wv "$rep_prefix" | grep -wv "$selected_sub_prefix")
			done
			uniq_filt_pair_list=$(echo "$filtered_pair_list" | cut -f1,2 | sort | uniq)
			num_uniq_pairs=$(echo "$uniq_filt_pair_list" | grep -vc ^$)
			cum_positive=0
			cum_score=0
			if [ "$num_uniq_pairs" -gt 0 ]
			then
				for k in $(seq 1 $num_uniq_pairs)
				do
					cur_pair=$(echo "$uniq_filt_pair_list" | tail -n+$k | head -n1)
					cur_query=$(echo   "$cur_pair" | cut -f1)
					cur_subject=$(echo "$cur_pair" | cut -f2)
					cur_positive=$(echo "$filtered_pair_list" | grep -w "$cur_query" | grep -w "$cur_subject" | awk 'BEGIN{FS="\t"}{sum+=$12}END{print sum}')
					cur_score=$(echo "$filtered_pair_list" | grep -w "$cur_query" | grep -w "$cur_subject" | awk 'BEGIN{FS="\t"}{sum+=$9}END{print sum}')
					echo -e "$cur_query\t$cur_subject\t$cur_positive\t$cur_score"
				done
			fi
		done
	fi
done
