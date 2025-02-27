#!/bin/bash
function usage(){
    echo "This script takes a gff file and converts it to bed format"
    echo
    echo "Options:"
    echo
    echo "  --format [4],6 whether the output contains 4 or 6 columns"
    echo "  --gff_file <str>"
    echo "  --out_file <str>"
    echo
	}
while [ "$1" != "" ]
do
    case $1 in
        -f | --format )
            shift
            format=$1
            ;;
		-g | --gff_file )
            shift
            gff_file=$1
            ;;
		-o | --out_file )
            shift
            out_file=$1
            ;;
		-h | --help )
            usage
            exit
            ;;
		* )
            usage
            exit
            ;;
	esac
	shift
done
if [ ! -f "${gff_file}" ]
then
    echo "gff file ${gff_file} missing. Exiting"
    exit 0
fi
if [ "${format}" != "6" ] && [ "${format}" != "4" ]
then
    echo "Invalid output format. Exiting"
    exit 0
fi
if [ -z ${out_file+x} ]
then
    echo "No output file specified, printing to stdout"
    out_file="/dev/stdout"
fi
seq_list=$(grep -v "#" "${gff_file}" | cut -f1 | sort -V | uniq)
for seq in ${seq_list}
do
    if [ "${format}" == "6" ]
    then
        grep -w ^${seq} "${gff_file}" | sort -nk4 | uniq | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$4-1,$5,$1"_"NR,".",$7}'
    elif [ "${format}" == "4" ]
    then
        grep -w ^${seq} "${gff_file}" | sort -nk4 | uniq | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$4-1,$5,$1"_"NR}'
    fi
done > "${out_file}"