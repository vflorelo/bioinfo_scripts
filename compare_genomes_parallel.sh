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
  blastp -query ${db_file} -db ${db_file} -evalue 0.0001 -out ${blast_file} -outfmt "6 qseqid sseqid qlen slen qstart sstart qend send score evalue length positive"
fi
num_genomes=$(echo "$genome_order_file" | wc -l)
for i in $(seq 1 $num_genomes)
do
  subject=$(tail -n+$i ${genome_order_file} | head -n1)
	sub_genome_list=$(tail -n+$i ${genome_order_file} | tail -n+2)
	num_sub_genomes=$(echo "$sub_genome_list" | wc -l )
  for j in $(seq 1 $num_sub_genomes)
  do
    query=$(echo "$sub_genome_list" | tail -n+$j | head -n1)
    echo $subject > genome_order_${i}_${j}
    echo $query  >> genome_order_${i}_${j}
		cmd_str="compare_genomes.sh \"$seq_db_file\" \"$seq_len_cutoff\" \"$aln_len_cutoff\" \"genome_order_${$i}_${j}\" \"$blast_file\" "
		cmd_list=$(echo -e "$cmd_list\n$cmd_str")
  done
done
echo "$cmd_list"
exit 0
