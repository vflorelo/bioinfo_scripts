#!/usr/bin/python3
import pandas as pd
import numpy  as np
import sys
og_counts_file = sys.argv[1]
target_species = sys.argv[2]
out_file = target_species+".idlist"
og_df = pd.read_csv(og_counts_file,sep="\t")
species_list = og_df.columns.to_list()[1:]
og_id_col    = og_df.columns.to_list()[:1]
def get_outliers(val_list):
    idx_list = []
    q75, q25 = np.percentile(val_list, [75 ,25])
    for idx,val in enumerate(val_list):
        if(val>q75 or val<q25):
            idx_list.append(idx)
    out_species_list = [species_list[i] for i in idx_list]
    return out_species_list
og_df["outliers"] = og_df[species_list].apply(lambda x: get_outliers(x),axis=1)
og_df = og_df[og_df["outliers"].apply(lambda x: target_species in x)]
og_df[og_id_col].to_csv(out_file,sep="\n",header=False,index=False)