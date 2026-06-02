#!/usr/bin/python3
import pandas  as pd
base_df   = pd.read_csv("base.tsv", sep="\t")
s1s2_df   = pd.read_csv("S1S2.add.tsv", sep="\t")
s1s2s3_df = pd.read_csv("S1S2S3.add.tsv", sep="\t")
base_df   = base_df.join(s1s2_df.set_index("Gene accession"),on="Gene accession")
base_df   = base_df.join(s1s2s3_df.set_index("Gene accession"),on="Gene accession")
columns   = ["Gene accession","Previous_ID(s)","Description","S1-S2 final location","S1-S2-S3 final location","Simplified location","Most likely origin","Adj. pN/pS","Variant fraction","Variant sites","Synonymous variants","Missense variants","Stop gain variants","Molecular weight (Da)","Protein length","Disordered regions","Cumulative disorder length","Disordered fraction","N-ter disorder fraction","C-ter disorder fraction","Mutagenesis fitness score","Mutagenesis index score","Avg. dN/dS (Laverania)","Avg. dN/dS (Plasmodium)","TMD","SP","tSNE.dim.1 (S1-S2)","tSNE.dim.2 (S1-S2)","markers (S1-S2)","hdb.cluster (S1-S2)","hdb.probability (S1-S2)","hdb.outlier.score (S1-S2)","svm.pred (S1-S2)","svm.score (S1-S2)","tSNE.dim.1 (S1-S2-S3)","tSNE.dim.2 (S1-S2-S3)","markers (S1-S2-S3)","hdb.cluster (S1-S2-S3)","hdb.probability (S1-S2-S3)","hdb.outlier.score (S1-S2-S3)","svm.pred (S1-S2-S3)","svm.score (S1-S2-S3)","GO.enrich.CC","GO.enrich.MF","GO.enrich.BP"]
base_df[columns].to_csv("PlasmoLOPIT_v3.tsv",index=False,sep="\t")
