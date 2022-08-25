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
  blastp -query ${seq_db_file} -db ${seq_db_file} -evalue 0.0001 -out ${blast_file} -outfmt "6 qseqid sseqid qlen slen qstart sstart qend send score evalue length positive"
fi
prot_size_list=$(infoseq $seq_db_file | tail -n+2 | awk '{print $3 "\t" $6}')
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
echo "$genome_order" > orf_base_table
echo "$genome_order" > res_base_table
echo "$genome_order" > score_base_table
echo -e "\n$genome_order" | perl -pe 's/\n/\t/g' | perl -pe 's/\t$/\n/' > percent_homologous_orfs_based_table.tsv
echo -e "\n$genome_order" | perl -pe 's/\n/\t/g' | perl -pe 's/\t$/\n/' > percent_positive_residues_based_table.tsv
echo -e "\n$genome_order" | perl -pe 's/\n/\t/g' | perl -pe 's/\t$/\n/' > cumulative_blast_score_based_table.tsv
for i in $(seq 1 $num_genomes)
do
	col_command="printf 'x%.0s\n' {1..$i}"
	col_data=$(eval $col_command)
	orf_base_col=$(echo "$col_data")
	res_base_col=$(echo "$col_data")
	score_base_col=$(echo "$col_data")
  if [ "$i" -lt "$num_genomes" ]
	then
		subject_prefix_list=""
		subject=$(echo "$genome_order" | tail -n+$i | head -n1 )
		sub_genome_order=$(echo "$genome_order" | tail -n+$i | tail -n+2)
		subject_prefix_list=$(grep \> ${seq_db_file} | awk -v subject="$subject" '{if($2==subject){print $1}}' | perl -pe 's/\>//')
		subject_prot_size=$(echo "$subject_prefix_list" | wc -l)
		subject_res_size=$(echo "$prot_size_list" | grep -w "$subject_prefix_list" | awk 'BEGIN{FS="\t"}{sum+=$2}END{print sum}')
		num_sub_genomes=$(echo "$sub_genome_order" | wc -l)
		for j in $(seq 1 $num_sub_genomes)
		do
			query_prefix_list=""
			query=$(echo "$sub_genome_order" | tail -n+$j | head -n1)
			query_prefix_list=$(grep \> ${seq_db_file} | awk -v query="$query" '{if($2==query){print $1}}' | perl -pe 's/\>//')
			query_prot_size=$(echo "$query_prefix_list" | wc -l)
			query_res_size=$(echo "$prot_size_list" | grep -w "$query_prefix_list" | awk 'BEGIN{FS="\t"}{sum+=$2}END{print sum}')
			kept_hits=$(grep -w "$subject_prefix_list" ${blast_file} | grep -w "${query_prefix_list}" | awk -v seq_len_cutoff="$seq_len_cutoff" 'BEGIN{FS="\t"}{if($3>=$4){slen_frac=(($4/$3)*100)}else{slen_frac=(($3/$4)*100)}}{if($1!=$2 && slen_frac >= seq_len_cutoff){print $AF}}' | sort -V | uniq)
			kept_subject_prefix_list=$(echo "$kept_hits" | cut -f1,2 | perl -pe 's/\t/\n/g' | sort -V | uniq | grep -w "$subject_prefix_list")
			kept_query_prefix_list=$(echo   "$kept_hits" | cut -f1,2 | perl -pe 's/\t/\n/g' | sort -V | uniq | grep -w "$query_prefix_list")
			cur_pair_list=""
			for kept_query_prefix in $kept_query_prefix_list
			do
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
			cum_length=$(echo -e "$query_res_size\t$subject_res_size" | awk 'BEGIN{FS="\t"}{if($2>=$1){print $1}else{print $2}}')
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
					let cum_positive=cum_positive+cur_positive
					let cum_score=cum_score+cur_score
				done
				percent_homologous_orfs=$(echo -e "$num_uniq_pairs\t$query_prot_size\t$subject_prot_size" | awk 'BEGIN{FS="\t"}{if($2>=$3){norm_size=$3}else{norm_size=$2}}{print (($1/norm_size)*100)}')
				percent_positive_residues=$(echo -e "$cum_positive\t$cum_length" | awk '{print (($1/$2)*100)}')
			else
				percent_homologous_orfs=0
				percent_positive_residues=0
				cum_score=0
			fi
			orf_base_col=$(echo -e "$orf_base_col\n$percent_homologous_orfs" | grep -v ^$)
			res_base_col=$(echo -e "$res_base_col\n$percent_positive_residues" | grep -v ^$)
			score_base_col=$(echo -e "$score_base_col\n$cum_score" | grep -v ^$)
		done
		echo "$orf_base_col" > orf_tmp_table
		echo "$res_base_col" > res_tmp_table
		echo "$score_base_col" > score_tmp_table
		echo "$(paste orf_base_table orf_tmp_table)" > orf_base_table
		echo "$(paste res_base_table res_tmp_table)" > res_base_table
		echo "$(paste score_base_table score_tmp_table)" > score_base_table
	else
		echo "$orf_base_col" > orf_tmp_table
		echo "$res_base_col" > res_tmp_table
		echo "$score_base_col" > score_tmp_table
		echo "$(paste orf_base_table orf_tmp_table)" > orf_base_table
		echo "$(paste res_base_table res_tmp_table)" > res_base_table
		echo "$(paste score_base_table score_tmp_table)" > score_base_table
	fi
done
cat orf_base_table >> percent_homologous_orfs_based_table.tsv
cat res_base_table >> percent_positive_residues_based_table.tsv
cat score_base_table >> cumulative_blast_score_based_table.tsv
rm -rf orf_base_table res_base_table score_base_table orf_tmp_table res_tmp_table score_tmp_table
