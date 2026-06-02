#!/usr/bin/python3
import getopt
import sys
import pandas as pd
in_file  = sys.argv[1]
out_file = sys.argv[2]
df = pd.read_csv(in_file,sep="\t").fillna(value=0)
species_list = df.columns.values.tolist()[1:]
def str_to_int(value):
    if (type(value)==str):
        return 1
    elif(type(value)==int):
        return value
for species in species_list:
    df[species] = df[species].apply(lambda x: str_to_int(x))
df["total"] = df[species_list].sum(axis=1)
df.to_csv(out_file,sep="\t",index=False,header=False)