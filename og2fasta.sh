#!/bin/bash
function usage(){
    echo "Options:"
    echo "  --fasta_dir    -> Directory containing protein sequences in fasta format"
    echo "  --tsv_file     -> TSV file containing orthogroups"
    echo "  --species_list -> comma separated list of species, make sure they don't have spaces"
    echo "  --og_list      -> comma separated list of orthogroups, make sure they don't have spaces"
    echo "  --help         -> prints help menu"
    echo "Example:"
    echo "  og2fasta.sh --fasta_dir /path/to/my/sequences/folder --tsv_file /path/to/my/orthogroups.tsv --species_list species_1,species_2,species_3 "
    echo
    echo "Notes:"
    echo "  - Fasta files in the --fasta_dir should be named the same as they appear in the --tsv_file"
    echo "  - seqtk needs to be present in your \$PATH"
	}
export -f usage
while [ "$1" != "" ]
do
    case $1 in
        --fasta_dir    )
            shift
            fasta_dir=$(realpath $1)
            ;;
        --tsv_file     )
            shift
            tsv_file=$(realpath $1)
            ;;
        --species_list )
            shift
            species_list=$1
            ;;
        --og_list      )
            shift
            og_list=$1
            ;;
		--help         )
            usage
            exit 0
            ;;
	esac
	shift
done
if [ ! -d "${fasta_dir}" ] || [ -z "${fasta_dir}" ]
then
    echo "Missing fasta directory. Exiting"
    exit 0
fi

if [ ! -f "${tsv_file}" ] || [ -z "${tsv_file}" ]
then
    echo "Missing tsv file. Exiting"
    exit 0
fi

if [ -z "${species_list}" ]
then
    echo "Missing species list. Exiting"
    exit 0
fi
if [ -z "${og_list}" ]
then
    echo "Missing orthogroup list. Exiting"
    exit 0
fi
uuid=$(uuidgen | cut -d\- -f5)
species_list=$(echo "${species_list}" | perl -pe 's/\,/\n/g' | sort -V | uniq | grep -v ^$ | grep .)
species_count=$(echo "${species_list}" | grep -v ^$ | grep -c .)
og_list=$(echo      "${og_list}"      | perl -pe 's/\,/\n/g' | sort -V | uniq | grep -v ^$ | grep .)
col_list=$(head -n1 "${tsv_file}" | perl -pe 's/\t/\n/g' | grep -n . | grep -wFf <(echo "${species_list}") | cut -d\: -f1 | perl -pe 's/\n/\,/g' | perl -pe 's/\,$//')
fasta_list=$(ls "${fasta_dir}" | grep -wFf <(echo "${species_list}") | sed -e "s|^|${fasta_dir}/|")
cat ${fasta_list} > ${uuid}.fasta
for og in ${og_list}
do
    acc_list=$(grep -w "${og}" "${tsv_file}" | cut -f${col_list} | perl -pe 's/\t/\n/g;s/\,/\n/g;s/ /\n/g' | sort -V | uniq | grep -v ^$ | grep .)
    if [ ! -z "${acc_list}" ]
    then
        seqtk subseq ${uuid}.fasta <(echo "${acc_list}") > ${og}.${species_count}_species.fasta
    fi
done
rm ${uuid}.fasta