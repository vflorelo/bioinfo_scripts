#!/usr/bin/python3
import numpy as np
import statistics
import sys
num_str    = sys.argv[1]
mad_factor = 4
str_list   = num_str.split(",")
num_list   = list(map(int, str_list))
median     = statistics.median(num_list)
print(str(median))
