#!/usr/bin/python3
import getopt
import sys
import pandas as pd
in_file  = sys.argv[1]
out_file = sys.argv[2]
df = pd.read_csv(in_file,sep="\t").fillna(value="0")
species_list = df.columns.values.tolist()[1:]
def str_to_int(value):
    if (value != "0"):
        prot_list  = value.split(",")
        prot_count = len(prot_list)
    else:
        prot_count = 0
    return prot_count
for species in species_list:
    df[species] = df[species].apply(lambda x: str_to_int(x))
df.to_csv(out_file,sep="\t",index=False)
