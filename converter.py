#!/usr/bin/python3
import sys, os
from Bio import GenBank, SeqIO
gbk_file       = sys.argv[1]
root_name      = os.path.splitext(gbk_file)[0]
faa_file       = root_name + ".faa"
ptt_file       = root_name + ".ptt"
fna_file       = root_name + ".fna"
input_handle   = open(gbk_file, "r")
protein_handle = open(faa_file, "w")
fasta_handle   = open(fna_file, "w")
table_handle   = open(ptt_file, "w")
special_chars  = [",",".",":",";","-","(",")","/","+","%","&"," "]
for seq_record in SeqIO.parse(input_handle, "genbank") :
    sequence_id     = seq_record.id
    sequence_length = len(seq_record)
    sequence_nuc    = seq_record.seq
    fasta_handle.write(">%s\n%s\n" % (sequence_id,sequence_nuc))
    print(gbk_file)
    for seq_feature in seq_record.features :
        if seq_feature.type == "CDS" :
            protein_strand   = seq_feature.location.strand
            if protein_strand == -1:
                protein_start = seq_feature.location.end
                protein_end   = seq_feature.location.start
            elif protein_strand == 1:
                protein_start = seq_feature.location.start
                protein_end   = seq_feature.location.end
            if "protein_id" in seq_feature.qualifiers:
                protein_accession = seq_feature.qualifiers['protein_id'][0]
            elif "locus_tag" in seq_feature.qualifiers:
                protein_accession = seq_feature.qualifiers['locus_tag'][0]
            if "product" in seq_feature.qualifiers:
                protein_description = seq_feature.qualifiers['product'][0]
            elif "description" in seq_feature.qualifiers:
                protein_description = seq_feature.qualifiers['description'][0]
            elif "note" in seq_feature.qualifiers:
                protein_description = seq_feature.qualifiers['note'][0]
            else:
                protein_description = "Hypothetical protein"
            for char in special_chars :
                protein_description = protein_description.replace(char,"_").replace("__","_")
            table_handle.write("%s\t%s\t%s\t%s\t%s\t%s\n" % (sequence_id,sequence_length,protein_accession,protein_start,protein_end,protein_description))
            protein_handle.write(">%s %s %s\n%s\n" % (protein_accession,seq_record.description.replace(" ","_"),protein_description,seq_feature.qualifiers['translation'][0]))
protein_handle.close()
table_handle.close()
fasta_handle.close()
input_handle.close()
