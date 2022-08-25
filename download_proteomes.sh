#!/bin/bash
org_list=$1
num_org=$(cat ${org_list} | wc -l )
for i in $(seq 1 ${num_org})
do
  organism_name=$(tail -n+${i} ${org_list} | head -n1)
  organism_html_name=$(tail -n+${i} ${org_list} | head -n1 | perl -pe 's/\ /\%20/g')
  tax_id_request_str="https://www.ebi.ac.uk/proteins/api/taxonomy/name/${organism_html_name}?pageNumber=1&pageSize=100&searchType=EQUALSTO&fieldName=SCIENTIFICNAME"
  tax_id_response=$(curl "${tax_id_request_str}")
  echo "${tax_id_response}"
  organism_tax_id=$(echo "${tax_id_response}" | jq ".taxonomies[0].taxonomyId" )
  if [ -z "${organism_tax_id}" ]
  then
    echo "Organism not found in UniProt Taxonomy database"
    exit 1
  fi
  echo ${organism_tax_id}
  proteome_request_str="https://www.ebi.ac.uk/proteins/api/proteomes?offset=0&size=100&taxid=${organism_tax_id}"
  proteome_response=$(curl "${proteome_request_str}")
  echo "${proteome_response}"
  organism_proteome=$(echo "${proteome_response}" | jq ".[0].upid" | perl -pe 's/\"//g')
  echo ${organism_proteome}
  if [ -z "${organism_proteome}" ]
  then
    echo "Proteome not found for ${organism_name}"
    exit 2
  fi
  protein_request_str="https://www.uniprot.org/uniprot/?query=proteome:${organism_proteome}&format=fasta"
  curl "${protein_request_str}" > "${organism_name}.fasta"
done
