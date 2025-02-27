#!/bin/bash
fasta_file=$1
out_file=$2
format_test=$(grep -c \> "${fasta_file}")
if [ -z "${format_test}" ] || [ "${format_test}" -eq 0 ]
then
	echo "Not a fasta file"
	exit 1
fi
if [ -z "${out_file}" ]
then
	perl -pe 'if(/\>/){s/$/\t/};s/\n//g;s/\>/\n\>/g;s/\t/\n/g' "${fasta_file}" | tail -n+2
else
	perl -pe 'if(/\>/){s/$/\t/};s/\n//g;s/\>/\n\>/g;s/\t/\n/g' "${fasta_file}" | tail -n+2 > "${out_file}"
fi
