#!/bin/bash
query=$(realpath   $1)
subject=$(realpath $2)
query_name=$(echo   "${query}"   | rev | cut -d\/ -f1 | rev | cut -d\. -f1)
subject_name=$(echo "${subject}" | rev | cut -d\/ -f1 | rev | cut -d\. -f1)
datablock=$(TMalign ${query} ${subject} -cp)
if [ $? -eq 0 ]
then
    q_len=$(echo     "${datablock}" | grep -w ^"Length"   | grep -w "Chain_1" | awk '{print $4}')
    s_len=$(echo     "${datablock}" | grep -w ^"Length"   | grep -w "Chain_2" | awk '{print $4}')
    q_norm_tm=$(echo "${datablock}" | grep -w ^"TM-score" | grep -w "Chain_1" | awk '{print $2}')
    s_norm_tm=$(echo "${datablock}" | grep -w ^"TM-score" | grep -w "Chain_2" | awk '{print $2}')
    rmsd=$(echo      "${datablock}" | grep -w  "RMSD"                         | awk '{print $5}' | perl -pe 's/\,//')
    aln_test=$(echo -e "${q_norm_tm}\t${s_norm_tm}\t${rmsd}" | awk 'BEGIN{FS="\t"}{ if($1 >= 0.75 && $2 >= 0.75 && $3 <= 3 ){res="VHQ"} else if($1 >= 0.75 && $2 >= 0.75 && $3 > 3 ){res="HQ"} else if($1 >= 0.75 && $2 < 0.75 && $3 <= 3 ){res="MQ"} else if($1 >= 0.75 && $2 < 0.75 && $3 > 3 ){res="LQ"} else if($1 < 0.75 && $2 >= 0.75 && $3 <= 3 ){res="MQ"} else if($1 < 0.75 && $2 >= 0.75 && $3 > 3 ){res="LQ"} else if($1 < 0.75 && $2 < 0.75 && $3 <= 3 ){res="LQ"} else if($1 < 0.75 && $2 < 0.75 && $3 > 3 ){res="VLQ"}}{print res}')
    echo -e "${query_name}\t${subject_name}\t${q_len}\t${s_len}\t${q_norm_tm}\t${s_norm_tm}\t${rmsd}\t${aln_test}\t${query_name}_${subject_name}.pdb"
else
    echo -e "${query_name}\t${subject_name}\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
fi