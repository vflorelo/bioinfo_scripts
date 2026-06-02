#!/bin/bash
gene_id=$1
gff_file=$2
gene_datablock=$(grep -wF "${gene_id}" "${gff_file}")
mrna_list=$(echo "${gene_datablock}" | grep -w mRNA | cut -f9 | sed -e 's/;/\n/g' | grep ID | cut -d\= -f2 | sort -V | uniq)
gene_strand=$(echo "${gene_datablock}" | cut -f7 | sort -V | uniq | head -n1)
gene_scf=$(echo "${gene_datablock}" | cut -f1 | sort -V | uniq | head -n1)
mrna_str=""
coords=""
for mrna in ${mrna_list}
do
	if [ "${gene_strand}" == "-" ]
	then
		exon_datablock=$(echo "${gene_datablock}" | grep -wF "${mrna}" | grep -w CDS | sort -nrk4 | awk -v mrna="${mrna}" 'BEGIN{FS="\t";OFS="\t"}{print $1,"funannotate","exon",$4,$5,$6,$7,$8,"ID="mrna".exon"NR";Parent="mrna}')
		cds_datablock=$(echo  "${gene_datablock}" | grep -wF "${mrna}" | grep -w CDS | sort -nrk4 | awk -v mrna="${mrna}" 'BEGIN{FS="\t";OFS="\t"}{print $1,"funannotate","CDS",$4,$5,$6,$7,$8,"ID="mrna".cds;Parent="mrna}')
	else
        exon_datablock=$(echo "${gene_datablock}" | grep -wF "${mrna}" | grep -w CDS | sort -nk4  | awk -v mrna="${mrna}" 'BEGIN{FS="\t";OFS="\t"}{print $1,"funannotate","exon",$4,$5,$6,$7,$8,"ID="mrna".exon"NR";Parent="mrna}')
		cds_datablock=$(echo  "${gene_datablock}" | grep -wF "${mrna}" | grep -w CDS | sort -nk4  | awk -v mrna="${mrna}" 'BEGIN{FS="\t";OFS="\t"}{print $1,"funannotate","CDS",$4,$5,$6,$7,$8,"ID="mrna".cds;Parent="mrna}')
    fi
    cur_coords=$(echo "${cds_datablock}" | awk 'BEGIN{FS="\t"}{print $4"\n"$5}' | sort -n | uniq | grep -v ^$ )
	cur_start=$(echo "${cur_coords}" | head -n1)
	cur_end=$(echo "${cur_coords}" | tail -n1)
	mrna_datablock=$(echo -e "${gene_scf}\tfunannotate\tmRNA\t${cur_start}\t${cur_end}\t.\t${gene_strand}\t.\tID=${mrna};Parent=${gene_id}" )
	mrna_str=$(echo -e "${mrna_str}\n${mrna_datablock}\n${exon_datablock}\n${cds_datablock}")
	coords=$(echo -e "${coords}\n${cur_coords}" | sort -n | uniq | grep -v ^$)
done
gene_start=$(echo "${coords}" | sort -n | uniq | grep -v ^$ | head -n1)
gene_end=$(echo "${coords}" | sort -n | uniq | grep -v ^$ | tail -n1)
gene_str=$(echo -e "${gene_scf}\tfunannotate\tgene\t${gene_start}\t${gene_end}\t.\t${gene_strand}\t.\tID=${gene_id}")
mrna_str=$(echo -e "${gene_str}\n${mrna_str}" | grep -v ^$ )
echo "${mrna_str}"
