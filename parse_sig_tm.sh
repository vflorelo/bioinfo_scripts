#!/bin/bash
query_id=$1
ipr_tsv_file=$2
datablock=$(grep -w ^"${query_id}" "${ipr_tsv_file}" | awk 'BEGIN{FS="\t";OFS="\t"}{if($4=="TMHMM" || $4=="Phobius" || $4=="SignalP_EUK"){print $1,$4,$5,$7,$8,$3}}')
if [ ! -z "${datablock}" ]
then
    query_len=$(echo "${datablock}" | cut -f6 | sort -n | uniq | head -n1 )
    tm_tmhmm_bed=$(echo          "${datablock}" | grep -w "TMHMM"       |                              awk 'BEGIN{FS="\t"}{print $1 FS $4-1 FS $5 FS $2}' | sort -nk2)
    tm_phobius_bed=$(echo        "${datablock}" | grep -w "Phobius"     | grep -w "TRANSMEMBRANE"    | awk 'BEGIN{FS="\t"}{print $1 FS $4-1 FS $5 FS $2}' | sort -nk2)
    sig_phobius_bed=$(echo       "${datablock}" | grep -w "Phobius"     | grep -w "SIGNAL_PEPTIDE"   | awk 'BEGIN{FS="\t"}{print $1 FS $4-1 FS $5 FS $2}' | sort -nk2)
    sig_signalp_tm_bed=$(echo    "${datablock}" | grep -w "SignalP_EUK" | grep -w "SignalP-TM"       | awk 'BEGIN{FS="\t"}{print $1 FS $4-1 FS $5 FS $2}' | sort -nk2)
    sig_signalp_no_tm_bed=$(echo "${datablock}" | grep -w "SignalP_EUK" | grep -w "SignalP-noTM"     | awk 'BEGIN{FS="\t"}{print $1 FS $4-1 FS $5 FS $2}' | sort -nk2)
    tm_tmhmm_tmp_count=$(echo          "${tm_tmhmm_bed}"          | grep -v ^$ | grep -c .)
    tm_phobius_tmp_count=$(echo        "${tm_phobius_bed}"        | grep -v ^$ | grep -c .)
    sig_phobius_tmp_count=$(echo       "${sig_phobius_bed}"       | grep -v ^$ | grep -c .)
    sig_signalp_tm_tmp_count=$(echo    "${sig_signalp_tm_bed}"    | grep -v ^$ | grep -c .)
    sig_signalp_no_tm_tmp_count=$(echo "${sig_signalp_no_tm_bed}" | grep -v ^$ | grep -c .)
    if   [ "${tm_tmhmm_tmp_count}" -gt 0 ] && [ "${tm_phobius_tmp_count}" -gt 0 ]
    then
        tm_cons_bed=$(intersectBed -a <(echo "${tm_phobius_bed}") -b <(echo "${tm_tmhmm_bed}") )
    elif [ "${tm_tmhmm_tmp_count}" -eq 0 ] && [ "${tm_phobius_tmp_count}" -gt 0 ]
    then
        tm_cons_bed="${tm_phobius_bed}"
    elif [ "${tm_tmhmm_tmp_count}" -gt 0 ] && [ "${tm_phobius_tmp_count}" -eq 0 ]
    then
        tm_cons_bed="${tm_tmhmm_bed}"
    else
        tm_cons_bed=""
    fi
    if   [ "${sig_phobius_tmp_count}" -gt 0 ] && [ "${sig_signalp_tm_tmp_count}" -gt 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -gt 0 ]
    then
        sig_cons_bed=$(multiIntersectBed -i <(echo "${sig_phobius_bed}") <(echo "${sig_signalp_tm_bed}") <(echo "${sig_signalp_no_tm_bed}") | awk 'BEGIN{FS="\t";OFS="\t"}{if($4>=2){print $1,$2,$3}}' | mergeBed )
    elif [ "${sig_phobius_tmp_count}" -gt 0 ] && [ "${sig_signalp_tm_tmp_count}" -gt 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -eq 0 ]
    then
        sig_cons_bed=$(intersectBed -a <(echo "${sig_phobius_bed}") -b <(echo "${sig_signalp_tm_bed}") | mergeBed)
    elif [ "${sig_phobius_tmp_count}" -gt 0 ] && [ "${sig_signalp_tm_tmp_count}" -eq 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -gt 0 ]
    then
        sig_cons_bed=$(intersectBed -a <(echo "${sig_phobius_bed}") -b <(echo "${sig_signalp_no_tm_bed}") | mergeBed)
    elif [ "${sig_phobius_tmp_count}" -gt 0 ] && [ "${sig_signalp_tm_tmp_count}" -eq 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -eq 0 ]
    then
        sig_cons_bed="${sig_phobius_bed}"
    elif [ "${sig_phobius_tmp_count}" -eq 0 ] && [ "${sig_signalp_tm_tmp_count}" -gt 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -gt 0 ]
    then
        sig_cons_bed=$(intersectBed -a <(echo "${sig_signalp_tm_bed}") -b  <(echo "${sig_signalp_no_tm_bed}") | mergeBed)
    elif [ "${sig_phobius_tmp_count}" -eq 0 ] && [ "${sig_signalp_tm_tmp_count}" -gt 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -eq 0 ]
    then
        sig_cons_bed="${sig_signalp_tm_bed}"
    elif [ "${sig_phobius_tmp_count}" -eq 0 ] && [ "${sig_signalp_tm_tmp_count}" -eq 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -gt 0 ]
    then
        sig_cons_bed="${sig_signalp_no_tm_bed}"
    elif [ "${sig_phobius_tmp_count}" -eq 0 ] && [ "${sig_signalp_tm_tmp_count}" -eq 0 ] && [ "${sig_signalp_no_tm_tmp_count}" -eq 0 ]
    then
        sig_cons_bed=""
    fi
    if   [ ! -z "${tm_cons_bed}" ] && [ ! -z "${sig_cons_bed}" ]
    then
        tm_sig_intersect=$(intersectBed -a <(echo "${tm_cons_bed}") -b <(echo "${sig_cons_bed}") | mergeBed)
        tm_sig_intersect_count=$(echo "${tm_sig_intersect}" | grep -v ^$ | grep -c .)
        if [ "${tm_sig_intersect_count}" -gt 0 ]
        then
            tm_bed=$(subtractBed -A -a <(echo "${tm_cons_bed}") -b <(echo "${sig_cons_bed}"))
            sig_bed="${sig_cons_bed}"
        else
            tm_bed="${tm_cons_bed}"
            sig_bed="${sig_cons_bed}"
        fi
    elif [   -z "${tm_cons_bed}" ] && [ ! -z "${sig_cons_bed}" ]
    then
        tm_bed=""
        sig_bed="${sig_cons_bed}"
    elif [ ! -z "${tm_cons_bed}" ] && [ -z "${sig_cons_bed}" ]
    then
        tm_bed="${tm_cons_bed}"
        sig_bed=""
    elif [ -z "${tm_cons_bed}" ] && [ -z "${sig_cons_bed}" ]
    then
        tm_bed=""
        sig_bed=""
    fi
    tm_count=$(echo "${tm_bed}"   | grep -v ^$ | grep -c .)
    sig_count=$(echo "${sig_bed}" | grep -v ^$ | grep -c .)
    tm_len=$(echo  "${tm_bed}"  | awk 'BEGIN{FS="\t"}{sum+=$3-$2}END{print sum}')
    sig_len=$(echo "${sig_bed}" | awk 'BEGIN{FS="\t"}{sum+=$3-$2}END{print sum}')
    tm_frac=$(echo  -e "${query_len}\t${tm_len}"  | awk '{print $2/$1}')
    sig_frac=$(echo -e "${query_len}\t${sig_len}" | awk '{print $2/$1}')
    tm_str=$(echo  "${tm_bed}"  | cut -f2,3 | perl -pe 's/\t/\-/g;s/\n/\,/g' | perl -pe 's/\,$//')
    sig_str=$(echo "${sig_bed}" | cut -f2,3 | perl -pe 's/\t/\-/g;s/\n/\,/g' | perl -pe 's/\,$//')
    echo -e "${query_id}\t${query_len}\t${tm_count}\t${tm_len}\t${tm_frac}\t${tm_str}\t${sig_count}\t${sig_len}\t${sig_frac}\t${sig_str}"
else
    echo -e "${query_id}\tN/A\t0\t0\t0\tN/A\t0\t0\t0\tN/A"
fi