#!/bin/bash
build_gen_map="/home/vflorelo/bioinformatics/local_scripts/build_gen_map.sh"
run_mode="$1"
run_mode=$(echo "${run_mode}" | tr '[:upper:]' '[:lower:]')
eval_cutoff="$2"
aln_length_cutoff="$3"
genome_order_file="$4"
scaling="$5"
if [ -z "${run_mode}" ]
then
  echo "Arg 1: run mode [ blastn, tblastx ]"
  echo "Arg 2: e-value cutoff [ float, required ]"
  echo "Arg 3: minimum alignment length [ integer, required ]"
  echo "Arg 4: genome order file [ required ]"
  echo "Arg 5: scaling factor [ float, required ]"
  exit 0
fi
file_datablock=$(grep -v ^$ "${genome_order_file}")
num_files=$(echo "${file_datablock}" | wc -l)
num_comparisons=$(echo "${num_files}" | awk '{print $1-1}')
blast_outfmt="6 qseqid sseqid qstart sstart qend send evalue score length"
size_list=""
for line_num in $(seq 1 ${num_files})
do
  file_name=$(echo "${file_datablock}" | tail -n+${line_num} | head -n1)
  if [ ! -f "${file_name}" ]
  then
    echo "Missing file(s)"
    exit 2
  else
    seq_len=$(infoseq "${file_name}" 2>/dev/null | awk '{print $6}')
    size_list=$(echo -e "${size_list}\n${seq_len}")
  fi
done
if   [ "${run_mode}" == "blastn" ]
then
  comp_command="blastn                           -query <(echo -e \">sequence_2\n\${seq_str_2}\") -subject <(echo -e \">sequence_1\n\${seq_str_1}\") -out blast_comparison_file -outfmt \"${blast_outfmt}\" -evalue ${eval_cutoff}"
elif [ "${run_mode}" == "blastn_sens" ]
then
  comp_command="blastn -task blastn              -query <(echo -e \">sequence_2\n\${seq_str_2}\") -subject <(echo -e \">sequence_1\n\${seq_str_1}\") -out blast_comparison_file -outfmt \"${blast_outfmt}\" -evalue ${eval_cutoff}"
elif [ "${run_mode}" == "blastn_more_sens" ]
then
  comp_command="blastn -task blastn -word_size 6 -query <(echo -e \">sequence_2\n\${seq_str_2}\") -subject <(echo -e \">sequence_1\n\${seq_str_1}\") -out blast_comparison_file -outfmt \"${blast_outfmt}\" -evalue ${eval_cutoff}"
elif [ "${run_mode}" == "tblastx" ]
then
  comp_command="tblastx                          -query <(echo -e \">sequence_2\n\${seq_str_2}\") -subject <(echo -e \">sequence_1\n\${seq_str_1}\") -out blast_comparison_file -outfmt \"${blast_outfmt}\" -evalue ${eval_cutoff} -best_hit_overhang 0.2"
fi
for comp_num in $(seq 1 ${num_comparisons})
do
  genome_preload=$(echo ${comp_num} | awk '{print ($1*43)}')
  block_preload=$(echo ${comp_num}  | awk '{print (($1-1)*43)+16.5}')
  file_name_1=$(echo "${file_datablock}" | tail -n+${comp_num} | head -n1)
  file_name_2=$(echo "${file_datablock}" | tail -n+${comp_num} | head -n2 | tail -n1)
  seq_str_1=$(seqret ${file_name_1} raw::stdout 2>/dev/null | perl -pe 's/\n//g')
  seq_str_2=$(seqret ${file_name_2} raw::stdout 2>/dev/null | perl -pe 's/\n//g')
  seq_len_1=$(echo "${seq_str_1}" | wc -c)
  seq_len_2=$(echo "${seq_str_2}" | wc -c)
  eval "${comp_command}"
  if [ "${comp_num}" -eq 1 ]
  then
    ${build_gen_map} ${file_name_1} multi 0 ${scaling}
  fi
  ${build_gen_map} ${file_name_2} multi ${genome_preload} ${scaling}
  blast_datablock=$(awk -v cutoff="${aln_length_cutoff}" 'BEGIN{FS="\t"}{if($9 >= cutoff){print $0 }}' blast_comparison_file | sort -nk9 )
  num_blocks=$(echo "${blast_datablock}" | wc -l)
  for block_num in $(seq 1 ${num_blocks})
  do
    block_id="block_${block_num}"
    datablock=$(echo "${blast_datablock}" | tail -n+${block_num} | head -n1)
    sequence_1=$(echo        "${datablock}" | cut -f1)
    sequence_2=$(echo        "${datablock}" | cut -f2)
    block_upper_start=$(echo "${datablock}" | awk -v scaling="${scaling}" 'BEGIN{FS="\t"}{print $4 * scaling}')
    block_upper_end=$(echo   "${datablock}" | awk -v scaling="${scaling}" 'BEGIN{FS="\t"}{print ((($6-$4)+1) * scaling)}')
    block_lower_end=$(echo   "${datablock}" | awk -v scaling="${scaling}" 'BEGIN{FS="\t"}{print ((($6-$5)+1) * scaling)}')
    block_lower_start=$(echo "${datablock}" | awk -v scaling="${scaling}" 'BEGIN{FS="\t"}{print ((($5-$3)+1) * scaling)}')
    block_info_str=$(echo    "${datablock}" | awk 'BEGIN{FS="\t"}{print "e-value="$7,"score="$8,"length="$9}')
    block_precolor=$(echo    "${datablock}" | awk 'BEGIN{FS="\t"}{if ( $7 < 1e-4  && $7 >= 1e-10 ){print "ffff"}else if ( $7 < 1e-10 && $7 >= 1e-20 ){print "e3e3"}else if ( $7 < 1e-20 && $7 >= 1e-30 ){print "c6c6"}else if ( $7 < 1e-30 && $7 >= 1e-40 ){print "aaaa"}else if ( $7 < 1e-40 && $7 >= 1e-50 ){print "8d8d"}else if ( $7 < 1e-50 && $7 >= 1e-60 ){print "7171"}else if ( $7 < 1e-60 && $7 >= 1e-70 ){print "5454"}else if ( $7 < 1e-70 && $7 >= 1e-80 ){print "3838"}else if ( $7 < 1e-80 && $7 >= 1e-90 ){print "1b1b"}else if ( $7 < 1e-90 ){print "0000"}}')
    block_color=$(echo       "${datablock}" | awk -v block_precolor="${block_precolor}" 'BEGIN{FS="\t"}{if( ($5 >= $3) && ($6 >= $4) ){print "ff"block_precolor}else if( ($5 >= $3) && ($6 <  $4) ){print block_precolor"ff"}else if( ($5 <  $3) && ($6 <  $4) ){print "ff"block_precolor}else if( ($5 <  $3) && ($6 >= $4) ){print block_precolor"ff"}}')
    style_string="fill:#${block_color};fill-opacity:1;stroke:none"
    title_string="${sequence_1} ${sequence_2} ${block_info_str}"
    echo "  <path d=\"m ${block_upper_start},${block_preload} ${block_upper_end},0 -${block_lower_end},35 -${block_lower_start},0 z\" id=\"${block_id}\" style=\"${style_string}\" ><title>${title_string}</title></path>" | perl -pe 's/\-\-/\+/g'
  done >> blocks.svg
done
map_width=$(echo "${size_list}" | sort -n | uniq | tail -n1 | awk -v scaling="${scaling}" '{print $1 * scaling}')
map_height=$(echo "${num_comparisons}" | awk '{ print ((($1-1)*43)+68) }')
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > full_${run_mode}_comparison.svg
echo "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"${map_width}px\" height=\"${map_height}px\" viewBox=\"0 0 ${map_width} ${map_height}\" id=\"genome_comparison\">" >> full_${run_mode}_comparison.svg
cat blocks.svg genomes.svg >> full_${run_mode}_comparison.svg
echo "</svg>" >> full_${run_mode}_comparison.svg
svg_integrity=$(xmllint --noout full_${run_mode}_comparison.svg)
if [ -z "${svg_integrity}" ]
then
  rm -rf genomes.svg blocks.svg blast_comparison_file
  exit 0
elif [ ! -z "${svg_integrity}" ]
then
  exit 1
fi