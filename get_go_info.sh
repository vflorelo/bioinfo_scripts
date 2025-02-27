#!/bin/bash
idlist_file=$1
tsv_file=$2
idlist=$(sort -V "${idlist_file}" | uniq | grep -v ^$ )
idlist_num=$(echo "${idlist}" | grep -v ^$ | wc -l)
echo -e "GO-ID\tSource\tObsolete\tDescription" > "${tsv_file}"
for raw_goid in ${idlist}
do
    goid=$(echo ${raw_goid} | perl -pe 's/^GO\://i;s/^GO//i')
    query_str="https://golr-aux.geneontology.io/solr/select?q=id:%22GO:${goid}%22&fl=id,description,is_obsolete,source"
    go_xml_datablock=$(curl "${query_str}" 2> /dev/null)
    xmllint --format <(echo "${go_xml_datablock}") > /dev/null 2> /dev/null
    exit_code=$?
    if [ "${exit_code}" -eq 0 ]
    then
        num_hits=$(xmllint --xpath "string(/response/result/@numFound)" <(echo "${go_xml_datablock}"))
        if [ "${num_hits}" -eq 0 ]
        then
            echo -e "${raw_goid}\tN/A\tNot found or deprecated"
        elif [ "${num_hits}" -gt 0 ]
        then
            has_desc=$(xmllint --xpath "count(/response/result/doc/str[@name='description'])"  <(echo "${go_xml_datablock}"))
            has_obs=$(xmllint  --xpath "count(/response/result/doc/bool[@name='is_obsolete'])" <(echo "${go_xml_datablock}"))
            has_src=$(xmllint  --xpath "count(/response/result/doc/str[@name='source'])"       <(echo "${go_xml_datablock}"))
            if [ "${has_desc}" -ge 1 ]
            then
                go_desc=$(xmllint  --xpath "/response/result/doc/str[@name='description']/text()" <(echo "${go_xml_datablock}") | recode html..ascii)
            else
                go_desc="No available description"
            fi

            if [ "${has_obs}" -ge 1 ]
            then
                is_obs=$(xmllint   --xpath "/response/result/doc/bool[@name='is_obsolete']/text()" <(echo "${go_xml_datablock}"))
            else
                is_obs="Unknown"
            fi

            if [ "${has_src}" -ge 1 ]
            then
                go_src=$(xmllint   --xpath "/response/result/doc/str[@name='source']/text()" <(echo "${go_xml_datablock}"))
            else
                go_src="Unknown"
            fi
            echo -e "GO:${goid}\t${go_src}\t${is_obs}\t${go_desc}"
        fi
    else
        echo -e "${raw_goid}\tN/A\tN/A\tError querying GO database"
    fi
done >> "${tsv_file}"