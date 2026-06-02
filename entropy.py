#!/usr/bin/python3
import math
import sys
seq_id    = sys.argv[1]
seq_str   = sys.argv[2]
seq_str   = seq_str.upper()
seq_list  = list(seq_str)
seq_len   = len(seq_str)
alphabet  = ["A","C","D","E","F","G","H","I","K","L","M","N","P","Q","R","S","T","V","W","Y"]
freq_list = []
for symbol in alphabet:
    counter = 0
    for sym in seq_list:
        if sym == symbol:
            counter += 1
    freq_list.append(float(counter)/len(seq_list))
seq_ent  = 0.0
for freq in freq_list:
    if(freq==0):
        res_entropy = (0.05 * math.log(0.05, 2))
        res_entropy = -res_entropy
    else:
        res_entropy = freq * math.log(freq, 2)
    seq_ent = seq_ent + res_entropy
seq_ent  = -seq_ent
seq_ment = float(seq_ent/seq_len)
seq_ent  = str(seq_ent)
seq_len  = str(seq_len)
seq_ment = str(seq_ment)
print (seq_id+"\t"+seq_ent+"\t"+seq_len+"\t"+seq_ment)
