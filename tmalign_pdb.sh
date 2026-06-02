#!/bin/bash
query=$(realpath   $1)
subject=$(realpath $2)
query_name=$(echo   "${query}"   | rev | cut -d\/ -f1 | rev | cut -d\. -f1)
subject_name=$(echo "${subject}" | rev | cut -d\/ -f1 | rev | cut -d\. -f1)
TMalign ${query} ${subject} -cp -o tmp/${query_name}_${subject_name} > /dev/null 2> /dev/null
grep ^[A-Z] tmp/${query_name}_${subject_name}_all_atm > tmalign/${query_name}_${subject_name}.pdb
rm tmp/${query_name}_${subject_name}*